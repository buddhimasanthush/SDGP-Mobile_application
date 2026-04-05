import os
import logging
import secrets
import shutil
import tempfile
from datetime import datetime, timezone
from typing import Optional

import uvicorn
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, BackgroundTasks, Depends, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, Field
from jose import jwt, JWTError

load_dotenv()

from services import email_service
from services.email_service import (
    generate_safe_otp,
    store_otp,
    send_otp_email_logic,
    verify_otp_secure,
    update_user_password,
    JWT_SECRET,
    JWT_ALGORITHM,
)
from services.ocr_service import process_prescription_image

# Logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="MediFind Backend API")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Dependency: JWT Authentication ──────────────────────────────────────────
async def get_reset_email(token: str = Depends(lambda x: x)) -> str:
    """Validate reset JWT and extract email."""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        email = payload.get("sub")
        if email is None or payload.get("purpose") != "password_reset":
            raise HTTPException(status_code=401, detail="Invalid token.")
        return email
    except JWTError:
        raise HTTPException(status_code=401, detail="Authentication failed.")

# ── Request Models ─────────────────────────────────────────────────────────
class SendOtpRequest(BaseModel):
    email: EmailStr
    purpose: str = Field(..., pattern="^(signup|login|password_reset)$")

class VerifyOtpRequest(BaseModel):
    email: EmailStr
    otp: str = Field(..., min_length=6, max_length=6)
    purpose: str

class ResetPasswordRequest(BaseModel):
    email: EmailStr
    otp: str # For backward compatibility with simpler verification
    new_password: str = Field(..., min_length=6)
    token: str # Signed JWT for authorized reset

# ── Endpoints ─────────────────────────────────────────────────────────────

@app.get("/")
def read_root():
    return {"message": "Welcome to the MediFind Backend API!"}

@app.post("/api/email/send-otp")
async def api_send_otp(req: SendOtpRequest):
    """
    Send a secure 6-digit OTP to the given email.
    Awaits the SMTP response so the client knows if it succeeded or failed.
    """
    logger.info(f"OTP request received for {req.email} (Purpose: {req.purpose})")
    
    try:
        email_clean = req.email.lower().strip()
        otp = generate_safe_otp()
        await store_otp(email_clean, otp, req.purpose)
        
        # Send email synchronously (waits for attempt)
        success = await send_otp_email_logic(email_clean, otp, req.purpose)
        
        if not success:
            raise HTTPException(status_code=500, detail="Failed to send email. Please check server SMTP configuration.")
        
        return {"message": "Verification code sent successfully.", "success": True}
    except Exception as e:
        logger.error(f"Failed to queue OTP for {req.email}: {e}")
        raise HTTPException(status_code=500, detail="An error occurred while processing your request.")

@app.post("/api/email/verify-otp")
async def api_verify_otp(req: VerifyOtpRequest):
    """
    Verify a 6-digit code against the bcrypt-hashed storage.
    Returns a signed JWT (short-lived) upon success.
    """
    email = req.email.lower().strip()
    logger.info(f"OTP verification attempt for {email}")
    
    valid, message, token = await verify_otp_secure(email, req.otp.strip())
    
    if not valid:
        logger.warning(f"Failed verification for {email}: {message}")
        raise HTTPException(status_code=403, detail=message)
        
    return {"valid": True, "message": message, "token": token}

@app.post("/api/email/reset-password")
async def api_reset_password(req: ResetPasswordRequest):
    """
    Secure password reset using a signed verification token.
    Validates email format and password strength.
    """
    logger.info(f"Password reset request for {req.email}")
    
    # 1. Validate JWT token independently
    try:
        payload = jwt.decode(req.token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        if payload.get("sub") != req.email.lower().strip():
            raise HTTPException(status_code=401, detail="Token mismatch.")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid reset session. Please verify again.")

    try:
        # Update password via Supabase Admin API
        await update_user_password(req.email.lower().strip(), req.new_password)
        
        logger.info(f"Password reset successful for {req.email}")
        return {"message": "Password updated successfully.", "success": True}
    except Exception as e:
        logger.error(f"Reset failed for {req.email}: {e}")
        raise HTTPException(status_code=500, detail="Failed to update password.")
# ── OCR Endpoints ──────────────────────────────────────────────────────────

@app.post("/api/ocr/upload")
async def api_upload_prescription(file: UploadFile = File(...)):
    """
    Upload a prescription image, run EasyOCR + DeepSeek for extraction.
    Returns structured medical data.
    """
    logger.info(f"OCR upload request received: {file.filename}")
    
    # Create a temporary file to store the upload
    suffix = os.path.splitext(file.filename)[1]
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        try:
            shutil.copyfileobj(file.file, tmp)
            tmp_path = tmp.name
        finally:
            file.file.close()

    try:
        # Process the image using the OCR service
        result = process_prescription_image(tmp_path)
        
        if "error" in result:
            logger.error(f"OCR processing error: {result['error']}")
            raise HTTPException(status_code=500, detail=result["error"])
            
        return {"success": True, "data": result}
        
    except Exception as e:
        logger.error(f"OCR endpoint exception: {e}")
        raise HTTPException(status_code=500, detail="Prescription processing failed.")
    finally:
        # Clean up the temporary file
        if os.path.exists(tmp_path):
            os.remove(tmp_path)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)
