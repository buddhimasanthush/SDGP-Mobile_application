import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';
import 'supabase_client.dart';

class AuthService {
  static final SupabaseClient _supabase = SupabaseService.client;

  static bool _isEmail(String value) => value.contains('@');

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    int? avatarColor,
    String? emoji,
    String role = 'patient',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final response = await _supabase.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user != null) {
      final userId = response.user!.id;

      await _supabase.from('profiles').upsert({
        'id': userId,
        'full_name': fullName,
        'email': normalizedEmail,
        'avatar_color': avatarColor,
        'emoji': emoji,
        'role': role,
      });

      // Backward-compatible credential mapping.
      // Passwords are never stored here; Supabase Auth keeps hashed credentials.
      await _supabase.from('user_logins').upsert({
        'id': userId,
        'username': normalizedEmail,
        'email': normalizedEmail,
      });

      // New normalized auth identity table (if migration is applied).
      try {
        await _supabase.from('user_credentials').upsert({
          'user_id': userId,
          'username': normalizedEmail,
          'email': normalizedEmail,
        });
      } catch (e) {
        debugPrint(
            'user_credentials upsert skipped (migration likely pending): $e');
      }
    }

    return response;
  }

  static Future<String?> getEmailByIdentifier(String identifier) async {
    final clean = identifier.trim();
    if (clean.isEmpty) return null;
    if (_isEmail(clean)) {
      return clean.toLowerCase();
    }

    // Preferred normalized table.
    try {
      final row = await _supabase
          .from('user_credentials')
          .select('email')
          .eq('username', clean)
          .maybeSingle();
      final email = row?['email'] as String?;
      if (email != null && email.isNotEmpty) return email.toLowerCase();
    } catch (_) {}

    // Backward compatibility.
    try {
      final row = await _supabase
          .from('user_logins')
          .select('email')
          .eq('username', clean)
          .maybeSingle();
      final email = row?['email'] as String?;
      if (email != null && email.isNotEmpty) return email.toLowerCase();
    } catch (_) {}

    // RPC compatibility.
    try {
      final response = await _supabase.rpc(
        'get_email_by_username',
        params: {'input_username': clean},
      );
      if (response is String && response.isNotEmpty) {
        return response.toLowerCase();
      }
    } catch (_) {}

    return null;
  }

  static Future<AuthResponse> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    final email = await getEmailByIdentifier(identifier);
    if (email == null) {
      throw const AuthException('No account found for this email/username.');
    }
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> sendPasswordReset(String identifier) async {
    final email = await getEmailByIdentifier(identifier);
    if (email == null) {
      throw const AuthException('No account found for this email/username.');
    }
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: kIsWeb ? null : 'io.supabase.flutter://reset-callback/',
    );
  }

  static Future<Map<String, String?>> sendPasswordResetOtp(
      String identifier) async {
    final result =
        await ApiService.requestPasswordResetOtp(identifier: identifier);
    final ok = result['success'] == true;
    if (!ok) {
      throw AuthException(result['error']?.toString() ?? 'Failed to send OTP.');
    }
    return {
      'email': (result['email']?.toString() ?? identifier).trim(),
      'delivery': result['delivery']?.toString(),
      'devOtp': result['dev_otp']?.toString(),
    };
  }

  static Future<void> resetPasswordWithOtp({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    final result = await ApiService.verifyPasswordResetOtp(
      identifier: identifier,
      otp: otp,
      newPassword: newPassword,
    );
    final ok = result['success'] == true;
    if (!ok) {
      throw AuthException(
          result['error']?.toString() ?? 'Failed to reset password.');
    }
  }

  // Backward compatibility with existing OTP screens.
  static Future<void> sendEmailOtp(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email.trim().toLowerCase(),
      shouldCreateUser: false,
    );
  }

  static Future<String?> verifyEmailOtp({
    required String email,
    required String token,
    required String type,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanToken = token.trim();

    List<OtpType> typesToTry;
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
        final response = await _supabase.auth.verifyOTP(
          email: cleanEmail,
          token: cleanToken,
          type: otpType,
        );
        if (response.user != null) {
          return null;
        }
      } catch (e) {
        lastError = e.toString();
      }
    }
    return lastError ?? 'Invalid OTP code';
  }

  static Future<void> signOut() => _supabase.auth.signOut();

  static Session? get currentSession => _supabase.auth.currentSession;
  static User? get currentUser => _supabase.auth.currentUser;
}
