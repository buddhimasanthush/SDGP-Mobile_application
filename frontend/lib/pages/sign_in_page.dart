import 'package:flutter/material.dart';
import 'sign_up_page.dart';
import 'user_store.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePass = true;

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
    _slideCtrl.dispose();
    for (final c in _fcs) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: Column(
        children: [
          // ── White top with animated circles ON TOP ──────────────────
          AnimatedBuilder(
            animation: Listenable.merge(_fcs),
            builder: (ctx, _) => Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Decorative circles painted over the white area
                    _ring(-21 + _fxs[0].value, -117 + _fys[0].value, 183, 0),
                    _blob(72 + _fxs[1].value, 179 + _fys[1].value, 153, 3.03,
                        const Color(0xAFFDEDCA), const Color(0xFF0A9BE2)),
                    _blob(-25 + _fxs[2].value, 45 + _fys[2].value, 89, 0.57,
                        const Color(0xFFFDEDCA), const Color(0xFF0A9BE2)),
                    _blob(52 + _fxs[3].value, 14 + _fys[3].value, 94, 3.03,
                        const Color(0xAFFDEDCA), const Color(0xFF0A9BE2)),
                    _ring(240 + _fxs[4].value, 130 + _fys[4].value, 167, 0.40),

                    // Actual content on top of circles
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

          // ── Dark sliding card ───────────────────────────────────────
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
                      Center(
                          child: Container(
                              width: 30,
                              height: 9,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFF979797))))),
                      const SizedBox(height: 28),
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
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  fillColor: WidgetStateProperty.all(
                                      const Color(0xFF0796DE)),
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
                                onPressed: () {},
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
                          onPressed: () {
                            final u = _usernameCtrl.text.trim();
                            if (u.isNotEmpty) {
                              UserStore.instance.profileName =
                                  u[0].toUpperCase() + u.substring(1);
                            }
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0796DE),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              elevation: 4),
                          child: const Text('Sign In',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Center(
                          child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpPage())),
                        child: RichText(
                            text: const TextSpan(children: [
                          TextSpan(
                              text: "Don't have an account?  ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontFamily: 'Poppins')),
                          TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                  color: Color(0xFF0796DE),
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700)),
                        ])),
                      )),
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

  Widget _lbl(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500)),
      );

  Widget _fld(
          {TextEditingController? ctrl,
          String? hint,
          bool obscure = false,
          Widget? suffix}) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(
            color: Colors.white, fontSize: 13, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13,
              fontFamily: 'Poppins'),
          filled: false,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.5), width: 1)),
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
