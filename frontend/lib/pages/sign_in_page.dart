import 'package:flutter/material.dart';
import 'sign_up_page.dart';
import 'otp_verification_page.dart';
import 'forgot_password_page.dart';
import 'user_store.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _otpEmailCtrl = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePass = true;
  bool _isLoading = false;

  // Tab: 0 = Password login, 1 = OTP login
  int _selectedTab = 0;

  // ── Animation controllers ──────────────────────────────────────────────────
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
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _otpEmailCtrl.dispose();
    _slideCtrl.dispose();
    for (final c in _fcs) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Password sign-in ───────────────────────────────────────────────────────
  Future<void> _signInWithPassword() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty) {
      _snack('Please enter your username', isError: true);
      return;
    }
    if (password.isEmpty) {
      _snack('Please enter your password', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Resolve email from username
      final email = await AuthService.getEmailByUsername(username);
      if (email == null) {
        _snack('Username not found', isError: true);
        return;
      }
      await AuthService.signIn(email: email, password: password);
      final u = username;
      if (u.isNotEmpty) {
        UserStore.instance.profileName = u[0].toUpperCase() + u.substring(1);
      }
      UserStore.instance.email = email;
      await UserStore.instance.syncFromRemote();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _snack('Sign in failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── OTP sign-in ────────────────────────────────────────────────────────────
  Future<void> _sendLoginOtp() async {
    final email = _otpEmailCtrl.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      _snack('Please enter a valid email address', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.sendOtp(email, 'login');
      if (!mounted) return;
      if (result['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationPage(email: email, type: 'login'),
          ),
        );
      } else {
        _snack(result['error'] ?? 'Failed to send OTP', isError: true);
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
      content: Text(msg,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
      backgroundColor:
          isError ? const Color(0xFFEF5350) : const Color(0xFF0796DE),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: Column(
        children: [
          // ── White top with animated circles ─────────────────────────────
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
                    _blob(52 + _fxs[3].value, 14 + _fys[3].value, 94, 3.03,
                        const Color(0xAFFDEDCA), const Color(0xFF0A9BE2)),
                    _ring(240 + _fxs[4].value, 130 + _fys[4].value, 167, 0.40),
                    Padding(
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
                                color: const Color(0xFF0A2C8B),
                              ),
                              Image.asset(
                                'assets/images/New logo VERT 1.png',
                                width: 132,
                                height: 74,
                                errorBuilder: (_, __, ___) => const Text(
                                    'MediFind',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0796DE))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('Welcome\nBack',
                              style: TextStyle(
                                  color: Color(0xFF0A2C8B),
                                  fontSize: 32,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                  letterSpacing: -0.32)),
                          const SizedBox(height: 6),
                          const Text(
                              'Log in to explore the best\nmedicine app tailored for you.',
                              style: TextStyle(
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

          // ── Dark sliding card ────────────────────────────────────────────
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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                          child: Container(
                              width: 30,
                              height: 9,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFF979797))))),
                      const SizedBox(height: 20),

                      // ── Tab switcher ────────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _tab('Password', 0),
                            _tab('Login with OTP', 1),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Form based on selected tab ───────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _selectedTab == 0 ? _passwordForm() : _otpForm(),
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

  // ── Tab chip ───────────────────────────────────────────────────────────────
  Widget _tab(String label, int index) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedTab = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 38,
            decoration: BoxDecoration(
              color: _selectedTab == index
                  ? const Color(0xFF0796DE)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                    color: _selectedTab == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: _selectedTab == index
                        ? FontWeight.w700
                        : FontWeight.w400),
              ),
            ),
          ),
        ),
      );

  // ── Password login form ────────────────────────────────────────────────────
  Widget _passwordForm() => Column(
        key: const ValueKey('password'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lbl('Username'),
          _fld(ctrl: _usernameCtrl, hint: 'Enter your username'),
          const SizedBox(height: 20),
          _lbl('Password'),
          _fld(
            ctrl: _passwordCtrl,
            obscure: _obscurePass,
            suffix: IconButton(
              icon: Icon(
                  _obscurePass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white,
                  size: 20),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              SizedBox(
                width: 18,
                height: 18,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (v) => setState(() => _rememberMe = v ?? false),
                  fillColor: WidgetStateProperty.all(const Color(0xFF0796DE)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(width: 6),
              const Text('Remember me',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontFamily: 'Poppins')),
            ]),
            TextButton(
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage()),
                    ),
                child: const Text('Forgot password?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white))),
          ]),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signInWithPassword,
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
                  : const Text('Sign In',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 28),
          _signUpLink(),
        ],
      );

  // ── OTP login form ─────────────────────────────────────────────────────────
  Widget _otpForm() => Column(
        key: const ValueKey('otp'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0796DE).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFF0796DE).withValues(alpha: 0.35),
                  width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.mail_outline_rounded,
                    color: Color(0xFF0796DE), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Enter your registered email and we\'ll send a one-time login code.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _lbl('Email Address'),
          _fld(
            ctrl: _otpEmailCtrl,
            hint: 'example@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendLoginOtp,
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
                  : const Text('Send OTP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 28),
          _signUpLink(),
        ],
      );

  // ── Shared widgets ─────────────────────────────────────────────────────────
  Widget _signUpLink() => Center(
        child: GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const SignUpPage())),
          child: RichText(
              text: const TextSpan(children: [
            TextSpan(
                text: "Don't have an account?  ",
                style: TextStyle(
                    color: Colors.white, fontSize: 13, fontFamily: 'Poppins')),
            TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                    color: Color(0xFF0796DE),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700)),
          ])),
        ),
      );

  Widget _lbl(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500)),
      );

  Widget _fld({
    TextEditingController? ctrl,
    String? hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(
            color: Colors.white, fontSize: 13, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
              fontFamily: 'Poppins'),
          filled: false,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.5), width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: const BorderSide(color: Colors.white, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: suffix,
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
