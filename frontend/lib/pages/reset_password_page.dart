import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_store.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String otp;
  final String? token; // The secure JWT token from verification

  const ResetPasswordPage({
    super.key,
    required this.email,
    this.otp = '',
    this.token,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with TickerProviderStateMixin {
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _success = false;

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
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _slideCtrl.dispose();
    for (final c in _fcs) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final newPass = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (newPass.length < 6) {
      _snack('Password must be at least 6 characters', isError: true);
      return;
    }
    if (newPass != confirm) {
      _snack('Passwords do not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.resetPassword(
        email: widget.email,
        otp: widget.otp,
        newPassword: newPass,
        token: widget.token,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() => _success = true);
        try {
          await AuthService.signIn(email: widget.email, password: newPass);
          await UserStore.instance.syncFromRemote();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in_via_smtp', true);
          await prefs.setString('smtp_logged_in_email', widget.email);
        } catch (_) {}
      } else {
        _snack(result['error'] ?? 'Failed to update password', isError: true);
      }
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                  child: _success ? _successView() : _formView(),
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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
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
                    const Text('Reset\nPassword',
                        style: TextStyle(
                            color: Color(0xFF0A2C8B),
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            height: 1.1)),
                    const SizedBox(height: 6),
                    const Text('Choose a strong new password for your account.',
                        style:
                            TextStyle(color: Color(0xFF034A83), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _successView() => Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0796DE).withValues(alpha: 0.12),
                border: Border.all(color: const Color(0xFF0796DE), width: 4)),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFF0796DE), size: 54),
          ),
          const SizedBox(height: 32),
          const Text('Password Updated!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
              'Your password has been changed successfully. You are now logged in.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (r) => false),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0796DE),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100))),
              child: const Text('Go to Home',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );

  Widget _formView() => Column(
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
          _lbl('New Password'),
          _passFld(
              ctrl: _newPassCtrl,
              hint: 'At least 6 characters',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew)),
          const SizedBox(height: 20),
          _lbl('Confirm Password'),
          _passFld(
              ctrl: _confirmPassCtrl,
              hint: 'Repeat your password',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm)),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updatePassword,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0796DE),
                  disabledBackgroundColor:
                      const Color(0xFF0796DE).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  elevation: 4),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('Update Password',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );

  Widget _lbl(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(t,
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)));

  Widget _passFld(
          {required TextEditingController ctrl,
          String? hint,
          required bool obscure,
          required VoidCallback onToggle}) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.2))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF0796DE), width: 2)),
          suffixIcon: IconButton(
              icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white60,
                  size: 20),
              onPressed: onToggle),
          contentPadding: const EdgeInsets.all(20),
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
                          gradient: LinearGradient(colors: [c1, c2]))))));
}
