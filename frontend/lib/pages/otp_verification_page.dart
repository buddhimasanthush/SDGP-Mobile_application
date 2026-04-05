import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'reset_password_page.dart';
import 'user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String type; // 'signup', 'login', or 'password_reset'

  const OtpVerificationPage({
    super.key,
    required this.email,
    this.type = 'login',
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late List<AnimationController> _fcs;
  late List<Animation<double>> _fxs, _fys;

  bool _isLoading = false;
  int _secondsRemaining = 600; // 10 minutes (600 seconds)
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    _slideCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();

    final dur = [3200, 4000, 5100, 3600, 4400];
    final dx = [18.0, -16.0, 22.0, -18.0, 14.0];
    final dy = [-22.0, 20.0, 14.0, -18.0, 20.0];
    _fcs = List.generate(
        5,
        (i) => AnimationController(
            vsync: this, duration: Duration(milliseconds: dur[i]))
          ..repeat(reverse: true));
    _fxs = List.generate(
        5,
        (i) => Tween<double>(begin: 0, end: dx[i]).animate(
            CurvedAnimation(parent: _fcs[i], curve: Curves.easeInOut)));
    _fys = List.generate(
        5,
        (i) => Tween<double>(begin: 0, end: dy[i]).animate(
            CurvedAnimation(parent: _fcs[i], curve: Curves.easeInOut)));
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _secondsRemaining = 600;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  String get _timerString {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _slideCtrl.dispose();
    for (final c in _fcs) {
      c.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_secondsRemaining <= 0) {
      _snack('Code has expired. Please request a new one.', isError: true);
      return;
    }

    String otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      _snack('Please enter the full 6-digit code', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.verifyOtp(widget.email, otp, widget.type);

      if (!mounted) return;

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in_via_smtp', true);
        await prefs.setString('smtp_logged_in_email', widget.email);

        if (widget.type == 'login') {
          try {
            await AuthService.signInByEmail(widget.email);
            await UserStore.instance.syncFromRemote();
          } catch (_) {}
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
          }
        } else if (widget.type == 'signup') {
          await UserStore.instance.syncFromRemote();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/onboarding', (r) => false);
          }
        } else if (widget.type == 'password_reset') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ResetPasswordPage(
                  email: widget.email,
                  otp: otp,
                  token: result['token'], // Pass the secure JWT token
                ),
              ),
            );
          }
        }
      } else {
        _snack(result['error'] ?? 'Verification failed', isError: true);
      }
    } catch (e) {
      _snack('Connection error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);
    try {
      // Use the generic sendOtp with the correct purpose for this flow
      final result = await ApiService.sendOtp(widget.email, widget.type);
      if (!mounted) return;
      if (result['success'] == true) {
        _startCountdown();
        _snack('Verification code resent to ${widget.email}');
      } else {
        _snack(result['error'] ?? 'Failed to resend code', isError: true);
      }
    } catch (e) {
      _snack('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF0796DE),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SlideTransition(
              position: _slideAnim,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF001D70),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                  child: Column(
                    children: [
                      _buildTimerDisplay(),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) => _otpBox(index)),
                      ),
                      const SizedBox(height: 48),
                      _buildVerifyButton(),
                      const SizedBox(height: 32),
                      _buildResendPrompt(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge(_fcs),
      builder: (ctx, _) => Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _ring(-21 + _fxs[0].value, -117 + _fys[0].value, 183, 0),
              _blob(72 + _fxs[1].value, 179 + _fys[1].value, 153, 3.03,
                  const Color(0xAFFDEDCA), const Color(0xFF0A9BE2)),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, size: 24),
                            color: const Color(0xFF0A2C8B)),
                        const Text('OTP Authenticator',
                            style: TextStyle(
                                color: Color(0xFF0796DE),
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Verify Your\nEmail',
                        style: TextStyle(
                            color: Color(0xFF0A2C8B),
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            height: 1.1)),
                    const SizedBox(height: 8),
                    Text('Enter the 6-digit code sent to ${widget.email}',
                        style: const TextStyle(
                            color: Color(0xFF034A83), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Column(
      children: [
        Text(_timerString,
            style: const TextStyle(
                color: Color(0xFF0796DE),
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace')),
        const SizedBox(height: 4),
        Text('Time remaining',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading || _secondsRemaining <= 0 ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0796DE),
            disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
            elevation: 8),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Text('Verify & Proceed',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildResendPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Didn't receive the code? ",
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        GestureDetector(
          onTap: _secondsRemaining < 540
              ? _resendCode
              : null, // Allow resend after 1 minute has passed
          child: Text(
            'Resend Now',
            style: TextStyle(
                color: _secondsRemaining < 540
                    ? const Color(0xFF0796DE)
                    : Colors.white24,
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _otpBox(int index) {
    return Container(
      width: 46,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _focusNodes[index].hasFocus
                ? const Color(0xFF0796DE)
                : Colors.white24,
            width: 2),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          decoration:
              const InputDecoration(counterText: "", border: InputBorder.none),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            }
            if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }

  Widget _ring(double l, double t, double sz, double angle) => Positioned(
      left: l,
      top: t,
      child: Transform.rotate(
          angle: angle,
          child: Container(
              width: sz,
              height: sz,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(width: 30, color: const Color(0xFF10A2EA))))));
  Widget _blob(
          double l, double t, double sz, double angle, Color c1, Color c2) =>
      Positioned(
          left: l,
          top: t,
          child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                  angle: angle,
                  child: Container(
                      width: sz,
                      height: sz,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [c1, c2]))))));
}
