import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late List<AnimationController> _fcs;
  late List<Animation<double>> _fxs, _fys;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _slideCtrl.dispose();
    for (final c in _fcs) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      _snack('Please enter a valid email address', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Explicit 20-second timeout on the call level
      final result = await ApiService.sendResetCode(email).timeout(
        const Duration(seconds: 20),
        onTimeout: () => {'success': false, 'error': 'TIMEOUT'},
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _snack('Verification code sent to $email');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OtpVerificationPage(email: email, type: 'password_reset'),
          ),
        );
      } else {
        String errorMsg = result['error'] ?? 'An unknown error occurred';
        if (errorMsg == 'TIMEOUT') {
          errorMsg =
              'Request timed out. Please check your connection or try again.';
        }
        _snack(errorMsg, isError: true);
      }
    } on TimeoutException {
      _snack('The server took too long to respond. Please try again.',
          isError: true);
    } catch (e) {
      _snack('Connection error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
      backgroundColor:
          isError ? const Color(0xFFEF5350) : const Color(0xFF0796DE),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration:
          isError ? const Duration(seconds: 4) : const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: Column(
        children: [
          _buildAnimatedHeader(),
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Container(
                              width: 30,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 32),
                      Center(child: _buildLockIcon()),
                      const SizedBox(height: 28),
                      _lbl('Registered Email'),
                      _fld(
                          ctrl: _emailCtrl,
                          hint: 'example@email.com',
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _buildInfoNote(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                      const SizedBox(height: 28),
                      _buildSignInLink(),
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

  Widget _buildAnimatedHeader() {
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
              _blob(-25 + _fxs[2].value, 45 + _fys[2].value, 89, 0.57,
                  const Color(0xFFFDEDCA), const Color(0xFF0A9BE2)),
              _blob(52 + _fxs[3].value, 14 + _fys[3].value, 94, 3.03,
                  const Color(0xAFFDEDCA), const Color(0xFF0A9BE2)),
              _ring(240 + _fxs[4].value, 130 + _fys[4].value, 167, 0.40),
              _buildHeaderText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
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
              Image.asset('assets/images/New logo VERT 1.png',
                  width: 132,
                  height: 74,
                  errorBuilder: (_, __, ___) => const Text('MediFind',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0796DE)))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Forgot\nPassword',
              style: TextStyle(
                  color: Color(0xFF0A2C8B),
                  fontSize: 32,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                  letterSpacing: -0.32)),
          const SizedBox(height: 6),
          const Text(
              'Enter your registered email and we\'ll\nsend you a secure reset code.',
              style: TextStyle(
                  color: Color(0xFF034A83),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  letterSpacing: -0.12)),
        ],
      ),
    );
  }

  Widget _buildLockIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0796DE).withValues(alpha: 0.12),
        border: Border.all(
            color: const Color(0xFF0796DE).withValues(alpha: 0.4), width: 2),
      ),
      child: const Icon(Icons.lock_reset_rounded,
          color: Color(0xFF0796DE), size: 38),
    );
  }

  Widget _buildInfoNote() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text('A 6-digit reset code will be sent to this address.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontFamily: 'Poppins')),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendResetCode,
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0796DE),
            disabledBackgroundColor:
                const Color(0xFF0796DE).withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
            elevation: 4),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Text('Send Reset Code',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: RichText(
            text: const TextSpan(children: [
          TextSpan(
              text: 'Remembered it?  ',
              style: TextStyle(
                  color: Colors.white70, fontSize: 13, fontFamily: 'Poppins')),
          TextSpan(
              text: 'Sign In',
              style: TextStyle(
                  color: Color(0xFF0796DE),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700)),
        ])),
      ),
    );
  }

  Widget _lbl(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500)));

  Widget _fld(
          {required TextEditingController ctrl,
          String? hint,
          TextInputType? keyboardType}) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(
            color: Colors.white, fontSize: 13, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
              fontFamily: 'Poppins'),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.5), width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: const BorderSide(color: Colors.white, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      );

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
                          gradient: LinearGradient(
                              begin: const Alignment(0.93, 0.35),
                              end: const Alignment(0.06, 0.40),
                              colors: [c1, c2]))))));
}
