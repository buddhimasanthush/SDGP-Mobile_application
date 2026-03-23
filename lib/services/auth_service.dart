import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'supabase_client.dart';

class AuthService {
  static final SupabaseClient _supabase = SupabaseService.client;

  // Sign up with Email and Password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    int? avatarColor,
    String? emoji,
    String role = 'patient', // Default to patient
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user != null) {
      // Create initial profile record
      try {
        await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': fullName,
          'email': email,
          'avatar_color': avatarColor,
          'emoji': emoji,
          'role': role,
        });
      } catch (e) {
        debugPrint('Error creating profile during signup: $e');
        // If profile creation fails, the user is in a broken state. Throw to the UI so it can handle it.
        throw Exception('Account created but profile setup failed. Please contact support. Details: $e');
      }
    }

    return response;
  }

  // Sign in with Email and Password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Save custom username and plain-text password to user_logins table
  static Future<void> saveCustomCredentials({
    required String uid,
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      debugPrint('DEBUG: saveCustomCredentials called — uid=$uid, username=$username, email=$email');
      debugPrint('DEBUG: Current session user: ${_supabase.auth.currentUser?.id}');
      await _supabase.from('user_logins').upsert({
        'id': uid,
        'username': username,
        'password_plain': password,
        'email': email,
      });
      debugPrint('DEBUG: saveCustomCredentials SUCCESS ✓');
    } catch (e) {
      debugPrint('ERROR: saveCustomCredentials FAILED — $e');
      // Rethrow so the caller knows something went wrong
      rethrow;
    }
  }

  // Send OTP to email
  static Future<void> sendEmailOtp(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false, // Ensure we don't create new users here
    );
  }

  // Verify OTP token
  // Verify OTP token with fallback support
  static Future<String?> verifyEmailOtp({
    required String email,
    required String token,
    required String type, // Preferred type: 'signup', 'login', or 'magiclink'
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    final cleanToken = token.trim();
    
    // List of types to try in order
    List<OtpType> typesToTry = [];
    if (type == 'signup') {
      typesToTry = [OtpType.signup, OtpType.email];
    } else if (type == 'magiclink') {
      typesToTry = [OtpType.magiclink, OtpType.email, OtpType.signup];
    } else {
      typesToTry = [OtpType.email, OtpType.magiclink, OtpType.signup];
    }

    String? lastError;
    for (final otpType in typesToTry) {
      try {
        debugPrint('Attempting verification: email=$cleanEmail, token=$cleanToken, type=$otpType');
        final response = await _supabase.auth.verifyOTP(
          email: cleanEmail,
          token: cleanToken,
          type: otpType,
        );
        
        if (response.user != null) {
          debugPrint('Verification successful with type: $otpType');
          return null; // No error means success
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('Verification failed for type $otpType: $lastError');
      }
    }

    return lastError ?? 'Invalid OTP code';
  }

  // Sign in using custom credentials (username and plain-text password)
  static Future<Map<String, dynamic>?> getCredentialsByUsername(String username) async {
    return await _supabase
        .from('user_logins')
        .select('id, password_plain')
        .eq('username', username)
        .maybeSingle();
  }

  // Get profile by UID (to get the email for Supabase Auth)
  static Future<Map<String, dynamic>?> getProfile(String uid) async {
    return await _supabase
        .from('profiles')
        .select('email')
        .eq('id', uid)
        .maybeSingle();
  }

  // Get email by username — tries RPC first, falls back to direct table query
  static Future<String?> getEmailByUsername(String username) async {
    // 1. Try the RPC function (if it exists)
    try {
      final response = await _supabase.rpc(
        'get_email_by_username',
        params: {'input_username': username},
      );
      if (response != null) {
        debugPrint('DEBUG: getEmailByUsername via RPC → $response');
        return response as String;
      }
    } catch (e) {
      debugPrint('DEBUG: RPC get_email_by_username not available: $e');
    }

    // 2. Fallback: query user_logins table directly
    try {
      final row = await _supabase
          .from('user_logins')
          .select('email')
          .eq('username', username)
          .maybeSingle();
      if (row != null && row['email'] != null) {
        debugPrint('DEBUG: getEmailByUsername via table → ${row['email']}');
        return row['email'] as String;
      }
    } catch (e) {
      debugPrint('DEBUG: user_logins table query failed: $e');
    }

    return null;
  }

  // Custom Admin Sign In (checks custom 'admins' table)
  static Future<Map<String, dynamic>?> signInAsAdmin({
    required String username,
    required String password,
  }) async {
    final response = await _supabase
        .from('admins')
        .select()
        .eq('username', username)
        .eq('password_hash', password) // Plain text as per screenshot
        .maybeSingle();
    return response;
  }

  // Sign in using Email OTP (Passwordless)
  static Future<void> signInWithEmailOtp(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: kIsWeb ? null : 'io.supabase.flutter://login-callback/',
    );
  }

  // Sign out
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current session
  static Session? get currentSession => _supabase.auth.currentSession;

  // Get current user
  static User? get currentUser => _supabase.auth.currentUser;
}
