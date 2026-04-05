import os
import secrets
import asyncio
import logging
from datetime import datetime, timedelta, timezone
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

import aiosmtplib
import bcrypt
from jose import jwt
from supabase import create_client, Client

# Logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ── SMTP Configuration ──────────────────────────────────────────────────────
SMTP_HOST = os.getenv("SMTP_HOST", "smtp.gmail.com")
SMTP_PORT = int(os.getenv("SMTP_PORT", "587"))
SMTP_USER = os.getenv("SMTP_USER", "")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "")
SMTP_FROM = os.getenv("SMTP_FROM", f"MediFind <{SMTP_USER}>")
SMTP_USE_SSL = os.getenv("SMTP_USE_SSL", "False").lower() == "true"
MAX_SMTP_RETRIES = int(os.getenv("MAX_SMTP_RETRIES", "3"))

# ── Security Configuration ──────────────────────────────────────────────────
JWT_SECRET = os.getenv("JWT_SECRET", os.getenv("SUPABASE_SERVICE_ROLE_KEY", "fallback_secret"))
JWT_ALGORITHM = "HS256"
OTP_EXPIRY_MINUTES = int(os.getenv("OTP_EXPIRY_MINUTES", "10"))

# ── Supabase Admin Client ───────────────────────────────────────────────────
def _admin_client() -> Client:
    url = os.getenv("SUPABASE_URL", "")
    key = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
    return create_client(url, key)

# ── OTP Logic ───────────────────────────────────────────────────────────────
def generate_safe_otp() -> str:
    """Generate a cryptographically secure 6-digit OTP."""
    return str(secrets.randbelow(900000) + 100000)

async def hash_otp(otp: str) -> str:
    """Hash the OTP using bcrypt."""
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(otp.encode(), salt).decode()

async def store_otp(email: str, otp: str, purpose: str = "general") -> None:
    """Store hashed OTP in otp_tokens table and invalidate any previous active tokens."""
    admin = _admin_client()
    otp_hash = await hash_otp(otp)
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=OTP_EXPIRY_MINUTES)

    # Invalidate all previous active tokens for this email
    admin.table("otp_tokens").update({"used": True}).eq("email", email).eq("used", False).execute()

    # Store the new hashed token
    admin.table("otp_tokens").insert({
        "email": email,
        "otp_hash": otp_hash,
        "expires_at": expires_at.isoformat(),
        "purpose": purpose,
    }).execute()

async def verify_otp_secure(email: str, otp: str) -> tuple[bool, str, str]:
    """
    Verify OTP against bcrypt hash.
    Returns (valid: bool, message: str, token: str).
    The JWT token is issued for any successful verification.
    """
    admin = _admin_client()
    result = (
        admin.table("otp_tokens")
        .select("*")
        .eq("email", email)
        .eq("used", False)
        .order("created_at", desc=True)
        .limit(1)
        .execute()
    )

    if not result.data:
        return False, "No active verification code found.", ""

    record = result.data[0]
    expires_at = datetime.fromisoformat(record["expires_at"].replace("Z", "+00:00"))

    if datetime.now(timezone.utc) > expires_at:
        return False, "Verification code has expired. Please request a new one.", ""

    if not bcrypt.checkpw(otp.encode(), record["otp_hash"].encode()):
        return False, "Invalid verification code. Please try again.", ""

    # Mark OTP as used
    admin.table("otp_tokens").update({"used": True}).eq("id", record["id"]).execute()

    # Issue a short-lived signed JWT for the reset session
    purpose = record.get("purpose", "general")
    token_data = {
        "sub": email,
        "exp": datetime.now(timezone.utc) + timedelta(minutes=15),
        "purpose": purpose if purpose else "password_reset",
    }
    encoded_jwt = jwt.encode(token_data, JWT_SECRET, algorithm=JWT_ALGORITHM)

    return True, "Verification successful.", encoded_jwt

# ── Password Update via Supabase Admin API ──────────────────────────────────
async def update_user_password(email: str, new_password: str) -> None:
    """
    Update a user's password in Supabase Auth using the admin (service role) client.
    Also updates the plain-text password stored in user_logins for OTP login.
    """
    admin = _admin_client()

    # Look up the user by email to get their UID
    user_list = admin.auth.admin.list_users()
    target_user = None
    for u in user_list:
        if u.email and u.email.lower() == email.lower():
            target_user = u
            break

    if target_user is None:
        raise ValueError(f"No Supabase Auth user found for email: {email}")

    # Update Supabase Auth password
    admin.auth.admin.update_user_by_id(
        target_user.id,
        {"password": new_password}
    )
    logger.info(f"Supabase Auth password updated for {email}")

    # Also update the plain-text copy in user_logins so OTP login keeps working
    try:
        admin.table("user_logins").update({"password_plain": new_password}).eq(
            "email", email.lower()
        ).execute()
        logger.info(f"user_logins password_plain updated for {email}")
    except Exception as e:
        logger.warning(f"Could not update user_logins for {email}: {e}")

# ── SMTP Email Delivery ────────────────────────────────────────────────────
async def send_otp_email_logic(email: str, otp: str, purpose: str = "general") -> bool:
    """
    Send an OTP email via SMTP with automatic retries.
    The email subject and heading adapt to the purpose: signup / login / password_reset.
    """
    subject, heading, body_intro = _resolve_email_copy(purpose)
    html_content = _build_otp_email(otp, heading, body_intro)

    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = SMTP_FROM
    msg["To"] = email
    msg.attach(MIMEText(html_content, "html"))

    for attempt in range(MAX_SMTP_RETRIES):
        try:
            logger.info(f"Sending '{purpose}' OTP to {email} (attempt {attempt + 1})")
            await aiosmtplib.send(
                msg,
                hostname=SMTP_HOST,
                port=SMTP_PORT,
                username=SMTP_USER,
                password=SMTP_PASSWORD,
                use_tls=SMTP_USE_SSL,
                start_tls=not SMTP_USE_SSL,
                timeout=15,
            )
            logger.info(f"OTP email sent successfully to {email}")
            return True
        except Exception as e:
            logger.error(f"SMTP error on attempt {attempt + 1}: {e}")
            if attempt < MAX_SMTP_RETRIES - 1:
                await asyncio.sleep(2)

    logger.error(f"All {MAX_SMTP_RETRIES} SMTP attempts failed for {email}")
    return False

def _resolve_email_copy(purpose: str) -> tuple[str, str, str]:
    """Return (subject, heading, body_intro) based on the OTP purpose."""
    if purpose == "signup":
        return (
            "Verify Your MediFind Account",
            "Confirm Your Email Address",
            "Thank you for creating a MediFind account! Please use the secure 6-digit code below to verify your email address and complete your registration.",
        )
    elif purpose == "login":
        return (
            "Your MediFind Login Code",
            "Sign In Without a Password",
            "You requested a one-time login code for MediFind. Use the code below to sign in. If you didn't request this, you can safely ignore this email.",
        )
    else:  # password_reset (default)
        return (
            "Reset Your MediFind Password",
            "Reset Your Password",
            "We received a request to reset your MediFind password. Use the secure 6-digit code below to proceed with resetting your password.",
        )

# ── Branded HTML Email Template ────────────────────────────────────────────
def _build_otp_email(otp: str, heading: str, body_intro: str) -> str:
    return f"""
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MediFind Verification</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f7f9;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color:#f4f7f9;">
    <tr>
      <td align="center" style="padding:40px 16px;">
        <table width="600" border="0" cellspacing="0" cellpadding="0"
               style="max-width:600px;background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#001D70 0%,#0796DE 100%);padding:36px 40px;text-align:center;">
              <h1 style="color:#ffffff;margin:0;font-size:30px;font-weight:700;letter-spacing:-0.5px;">MediFind</h1>
              <p style="color:rgba(255,255,255,0.75);margin:6px 0 0;font-size:13px;letter-spacing:0.5px;">Your trusted medicine companion</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:40px 40px 32px;">
              <h2 style="color:#001D70;margin:0 0 16px;font-size:22px;font-weight:700;">{heading}</h2>
              <p style="color:#444444;margin:0 0 28px;font-size:14px;line-height:1.7;">{body_intro}</p>

              <!-- OTP Box -->
              <div style="margin:0 0 28px;padding:28px 20px;background-color:#f0f8ff;border:2px dashed #0796DE;border-radius:12px;text-align:center;">
                <p style="margin:0 0 8px;color:#555555;font-size:12px;text-transform:uppercase;letter-spacing:1.5px;font-weight:600;">Your Verification Code</p>
                <span style="font-size:46px;font-weight:800;letter-spacing:14px;color:#001D70;font-family:monospace;">{otp}</span>
              </div>

              <!-- Expiry Notice -->
              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td style="background-color:#fff8e1;border-left:4px solid #f59e0b;border-radius:0 8px 8px 0;padding:12px 16px;">
                    <p style="margin:0;color:#92400e;font-size:13px;line-height:1.5;">
                      ⏱ This code expires in <strong>{OTP_EXPIRY_MINUTES} minutes</strong>.
                      Do not share it with anyone — MediFind will never ask for your code.
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color:#f4f7f9;padding:24px 40px;text-align:center;border-top:1px solid #e8edf2;">
              <p style="margin:0;color:#999999;font-size:12px;line-height:1.6;">
                If you didn't request this code, please ignore this email — your account is safe.<br>
                &copy; 2025 MediFind Application. All rights reserved.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
"""

# ── Compatibility stub ──────────────────────────────────────────────────────
async def send_otp_email(email: str, purpose: str) -> None:
    """Legacy stub — kept for backward compatibility."""
    pass
