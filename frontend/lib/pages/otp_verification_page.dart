import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import 'main_navigation_page.dart';
import 'onboarding_flow_page.dart';
import 'user_store.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String type; // 'signup', 'login', or 'magiclink'

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
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();

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

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = 60); // Match Supabase 60s default rate limit
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    _slideCtrl.dispose();
    for (final c in _fcs) c.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? errorMessage = await AuthService.verifyEmailOtp(
        email: widget.email,
        token: otp,
        type: widget.type,
      );

      if (errorMessage == null) {
        if (!mounted) return;
        
        // Sync user data
        await UserStore.instance.syncFromRemote();

        // Redirect based on signup vs login or onboarding status
        if (mounted) {
          final target = (widget.type == 'signup') ? '/onboarding' : '/home';
          Navigator.pushNamedAndRemoveUntil(
            context,
            target,
            (route) => false,
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $errorMessage')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_resendTimer > 0) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.sendEmailOtp(widget.email);
      _startTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code resent!')),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Provide more user-friendly error for rate limit
      String errorMsg = e.toString();
      if (errorMsg.contains('over_email_send_rate_limit')) {
        errorMsg = 'Please wait a bit longer before resending.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: Column(
        children: [
          // White top matching SignInPage
          AnimatedBuilder(
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
                    _ring(240 + _fxs[4].value, 130 + _fys[4].value, 167, 0.40),

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
                                color: const Color(0xFF0A2C8B),
                              ),
                              const Text('OTP Authenticator',
                                  style: TextStyle(
                                      color: Color(0xFF0796DE),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('Verify Your\nEmail',
                              style: TextStyle(
                                  color: Color(0xFF0A2C8B),
                                  fontSize: 32,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                  letterSpacing: -0.32)),
                          const SizedBox(height: 8),
                          Text(
                              'Please enter the 6-digit code sent to\n${widget.email}',
                              style: const TextStyle(
                                  color: Color(0xFF034A83),
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  letterSpacing: -0.12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Dark sliding card
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
                      // 6 boxes for OTP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) => _otpBox(index)),
                      ),
                      const SizedBox(height: 40),
                      
                      if (_isLoading)
                        const CircularProgressIndicator(color: Color(0xFF0796DE))
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _verifyOtp,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0796DE),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100)),
                                elevation: 8),
                            child: const Text('Verify & Proceed',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Didn't receive the code? ",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontFamily: 'Poppins')),
                          GestureDetector(
                            onTap: _resendCode,
                            child: Text(
                                _resendTimer > 0 
                                  ? 'Resend in ${_resendTimer}s' 
                                  : 'Resend Now',
                                style: TextStyle(
                                    color: _resendTimer > 0 
                                      ? Colors.white38 
                                      : const Color(0xFF0796DE),
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
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

  Widget _otpBox(int index) {
    return Container(
      width: 48,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus 
            ? const Color(0xFF0796DE) 
            : Colors.white24,
          width: 2,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }

  // Circles helpers
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
