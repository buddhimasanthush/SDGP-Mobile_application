import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true, _obscureConfirm = true;
  String _emoji = '';
  Color _color = const Color(0xFF0796DE);

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late List<AnimationController> _fcs;
  late List<Animation<double>> _fxs, _fys;

  static const _palette = [
    Color(0xFF0796DE),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFFF44336),
    Color(0xFF009688),
  ];

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
    _nameCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _slideCtrl.dispose();
    for (final c in _fcs) c.dispose();
    super.dispose();
  }

  void _pickEmoji() {
    final ctrl = TextEditingController(text: _emoji);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF001D70),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 16),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Choose your avatar emoji',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Type or paste any emoji below',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              controller: ctrl,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40),
              maxLength: 2,
              decoration: InputDecoration(
                  counterText: '',
                  hintText: '😊',
                  hintStyle: TextStyle(
                      fontSize: 40, color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none)),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              Expanded(
                  child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Cancel',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: ElevatedButton(
                onPressed: () {
                  setState(() => _emoji = ctrl.text.trim());
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0796DE),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0),
                child: const Text('Done',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              )),
            ]),
          ),
          const SizedBox(height: 28),
        ]),
      ),
    );
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
                                Image.asset('assets/images/New logo VERT 1.png',
                                    width: 132,
                                    height: 74,
                                    errorBuilder: (_, __, ___) => const Text(
                                        'MediFind',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0796DE)))),
                              ]),
                          const SizedBox(height: 16),
                          const Text('Create Your\nFree Account',
                              style: TextStyle(
                                  color: Color(0xFF0A2C8B),
                                  fontSize: 32,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                  letterSpacing: -0.32)),
                          const SizedBox(height: 6),
                          const Text(
                              'Join thousands of users finding\ntheir medications with us.',
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
                        topRight: Radius.circular(32))),
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
                      const SizedBox(height: 24),

                      // Avatar
                      Center(
                          child: GestureDetector(
                        onTap: _pickEmoji,
                        child: Column(children: [
                          Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _emoji.isEmpty
                                      ? _color
                                      : Colors.white.withOpacity(0.1),
                                  border: Border.all(color: _color, width: 3)),
                              child: Center(
                                  child: _emoji.isEmpty
                                      ? const Icon(Icons.person_rounded,
                                          color: Colors.white, size: 40)
                                      : Text(_emoji,
                                          style:
                                              const TextStyle(fontSize: 38)))),
                          const SizedBox(height: 8),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.edit_rounded,
                                color: Colors.white.withOpacity(0.6), size: 13),
                            const SizedBox(width: 4),
                            Text('Tap to set avatar emoji',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 11,
                                    fontFamily: 'Poppins')),
                          ]),
                        ]),
                      )),
                      const SizedBox(height: 24),

                      _lbl('Profile Name'),
                      _fld(ctrl: _nameCtrl, hint: 'Enter your name'),
                      const SizedBox(height: 20),

                      _lbl('Password'),
                      _fld(
                          ctrl: _passCtrl,
                          obscure: _obscurePass,
                          suffix: IconButton(
                              icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white,
                                  size: 20),
                              onPressed: () => setState(
                                  () => _obscurePass = !_obscurePass))),
                      const SizedBox(height: 20),

                      _lbl('Confirm Password'),
                      _fld(
                          ctrl: _confirmCtrl,
                          obscure: _obscureConfirm,
                          suffix: IconButton(
                              icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white,
                                  size: 20),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm))),
                      const SizedBox(height: 24),

                      _lbl('Profile Colour'),
                      Text('Shown when no emoji is set',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 11,
                              fontFamily: 'Poppins')),
                      const SizedBox(height: 14),
                      Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _palette.map((c) {
                            final sel = c == _color;
                            return GestureDetector(
                              onTap: () => setState(() => _color = c),
                              child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: c,
                                      border: Border.all(
                                          color: sel
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 3),
                                      boxShadow: sel
                                          ? [
                                              BoxShadow(
                                                  color: c.withOpacity(0.6),
                                                  blurRadius: 8,
                                                  spreadRadius: 1)
                                            ]
                                          : []),
                                  child: sel
                                      ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 18)
                                      : null),
                            );
                          }).toList()),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/home'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0796DE),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              elevation: 4),
                          child: const Text('Create Account',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Center(
                          child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                            text: const TextSpan(children: [
                          TextSpan(
                              text: 'Already have an account?  ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontFamily: 'Poppins')),
                          TextSpan(
                              text: 'Sign In',
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
              fontWeight: FontWeight.w500)));

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
                  borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.5), width: 1)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: const BorderSide(color: Colors.white, width: 2)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              suffixIcon: suffix));

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
