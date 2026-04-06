import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _identifierCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  bool _loading = false;
  bool _otpSent = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String _resolvedEmail = '';
  String? _message;

  String _friendlyError(Object error) {
    final raw = error.toString();
    if (raw.contains('Not Found')) {
      return 'Password reset service is temporarily unavailable. Please try again shortly.';
    }
    if (raw.contains('TimeoutException')) {
      return 'Request timed out. Please check your connection and try again.';
    }
    if (raw.contains('Cannot connect to server')) {
      return 'Cannot connect to server right now. Please try again.';
    }
    if (raw.contains('No account found')) {
      return 'No account found for this email or username.';
    }
    return 'Failed to send OTP. Please try again.';
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _otpCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final identifier = _identifierCtrl.text.trim();
    if (identifier.isEmpty) {
      setState(() => _message = 'Please enter email or username.');
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final result = await AuthService.sendPasswordResetOtp(identifier);
      final email = (result['email'] ?? identifier).trim();
      final delivery = result['delivery'];
      final devOtp = result['devOtp'];
      final message =
          (delivery == 'dev_mode' && devOtp != null && devOtp.isNotEmpty)
              ? 'OTP (dev mode): $devOtp'
              : 'OTP sent to $email';

      setState(() {
        _resolvedEmail = email;
        _otpSent = true;
        _message = message;
      });
    } catch (e) {
      setState(() {
        _message = _friendlyError(e);
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _verifyOtpAndReset() async {
    final otp = _otpCtrl.text.trim();
    final newPass = _newPasswordCtrl.text;
    final confirm = _confirmPasswordCtrl.text;

    if (otp.length < 6) {
      setState(() => _message = 'Enter the 6-digit OTP.');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _message = 'Password must be at least 6 characters.');
      return;
    }
    if (newPass != confirm) {
      setState(() => _message = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await AuthService.resetPasswordWithOtp(
        identifier: _resolvedEmail.isNotEmpty
            ? _resolvedEmail
            : _identifierCtrl.text.trim(),
        otp: otp,
        newPassword: newPass,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _message = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 24),
                      color: const Color(0xFF0A2C8B),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Forgot\nPassword',
                      style: TextStyle(
                        color: Color(0xFF0A2C8B),
                        fontSize: 32,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _otpSent
                          ? 'Enter OTP and set your new password.'
                          : 'Enter your email or username and we will send an OTP.',
                      style: const TextStyle(
                        color: Color(0xFF034A83),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF001D70),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 30,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF979797)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Email or Username',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _identifierCtrl,
                      enabled: !_otpSent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                      decoration: _inputDecoration(
                        hint: 'Enter your email or username',
                      ),
                    ),
                    if (_otpSent) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'OTP Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _otpCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                        decoration: _inputDecoration(hint: 'Enter 6-digit OTP'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'New Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newPasswordCtrl,
                        obscureText: _obscureNew,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                        decoration: _inputDecoration(
                          hint: 'Enter new password',
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _obscureNew = !_obscureNew),
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Confirm Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirm,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                        decoration: _inputDecoration(
                          hint: 'Confirm new password',
                          suffix: IconButton(
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (_message != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.startsWith('OTP sent')
                              ? const Color(0xFF98FFB5)
                              : const Color(0xFFFFB3B3),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : (_otpSent ? _verifyOtpAndReset : _sendOtp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0796DE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 4,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _otpSent
                                    ? 'Verify OTP & Reset Password'
                                    : 'Send OTP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.45),
        fontSize: 13,
        fontFamily: 'Poppins',
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      suffixIcon: suffix,
    );
  }
}
