import 'package:flutter/material.dart';
import 'user_store.dart';
import 'onboarding_flow_page.dart';
import 'main_navigation_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _obscureRePassword = true;
  String _selectedEmoji = '';
  Color _selectedColor = const Color(0xFF0796DE);

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
  static const _emojiOptions = [
    '😀',
    '😎',
    '🥳',
    '😍',
    '🤩',
    '😊',
    '🔥',
    '💪',
    '🌟',
    '🦁',
    '🐯',
    '🦊',
    '🐧',
    '🐬',
    '🦋',
    '🌈',
    '⚡',
    '🎯',
    '🏆',
    '💎',
  ];

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _slideController, curve: Curves.easeOutCubic));
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
      backgroundColor: const Color(0xFFEF5350),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final rePass = _rePasswordController.text;

    if (name.isEmpty) {
      _showError('Please enter your full name');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email address');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (password != rePass) {
      _showError('Passwords do not match');
      return;
    }

    UserStore.instance.name = name[0].toUpperCase() + name.substring(1);
    UserStore.instance.email = email;
    UserStore.instance.avatarColorValue = _selectedColor.value;
    UserStore.instance.emoji = _selectedEmoji;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                OnboardingFlowPage(destination: const MainNavigationPage())));
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF001D70),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 18),
          const Text('Choose your avatar',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Tap an emoji to set it as your avatar',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 20),
          Wrap(spacing: 12, runSpacing: 12, children: [
            GestureDetector(
                onTap: () {
                  setState(() => _selectedEmoji = '');
                  Navigator.pop(context);
                },
                child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedEmoji.isEmpty
                            ? _selectedColor
                            : Colors.white.withOpacity(0.1),
                        border: Border.all(
                            color: _selectedEmoji.isEmpty
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                            width: 2)),
                    child: Icon(Icons.person_rounded,
                        color: _selectedEmoji.isEmpty
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        size: 28))),
            ..._emojiOptions.map((e) => GestureDetector(
                onTap: () {
                  setState(() => _selectedEmoji = e);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedEmoji == e
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.07),
                        border: Border.all(
                            color: _selectedEmoji == e
                                ? Colors.white
                                : Colors.transparent,
                            width: 2)),
                    child: Center(
                        child:
                            Text(e, style: const TextStyle(fontSize: 28)))))),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: Column(
        children: [
          // ── WHITE top section — bleeds behind status bar ──────────────
          ClipRect(
            child: Container(
              color: Colors.white,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Decorative circles
                  Positioned(
                      left: -21,
                      top: -117,
                      child: Container(
                          width: 183,
                          height: 183,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 30, color: const Color(0xFF10A2EA))))),
                  Positioned(
                      left: 72,
                      top: 80,
                      child: Opacity(
                          opacity: 0.25,
                          child: Container(
                              width: 154,
                              height: 154,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      begin: Alignment(0.93, 0.35),
                                      end: Alignment(0.06, 0.40),
                                      colors: [
                                        Color(0xAFFDEDCA),
                                        Color(0xFF0A9BE2)
                                      ]))))),
                  Positioned(
                      left: -26,
                      top: 45,
                      child: Opacity(
                          opacity: 0.25,
                          child: Container(
                              width: 89,
                              height: 89,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      begin: Alignment(0.93, 0.35),
                                      end: Alignment(0.06, 0.40),
                                      colors: [
                                        Color(0xFFFDEDCA),
                                        Color(0xFF0A9BE2)
                                      ]))))),
                  Positioned(
                      left: 265,
                      top: 30,
                      child: Transform.rotate(
                          angle: 0.40,
                          child: Container(
                              width: 167,
                              height: 167,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 30,
                                      color: const Color(0xFF10A2EA)))))),
                  // Content — padded below status bar
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, topPadding + 8, 24, 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon:
                                        const Icon(Icons.arrow_back, size: 24),
                                    color: const Color(0xFF0A2C8B)),
                                Image.asset('assets/images/New logo VERT 1.png',
                                    width: 120,
                                    height: 66,
                                    errorBuilder: (_, __, ___) => const Text(
                                        'MediFind',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0796DE)))),
                              ]),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Create Your\nFree Account',
                                      style: TextStyle(
                                          color: Color(0xFF0A2C8B),
                                          fontSize: 28,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          height: 1.15,
                                          letterSpacing: -0.3)),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Join thousands finding their medications with us.',
                                      style: TextStyle(
                                          color: const Color(0xFF034A83)
                                              .withOpacity(0.75),
                                          fontSize: 12,
                                          fontFamily: 'Poppins')),
                                ]),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),

          // ── DARK sliding card ─────────────────────────────────────────
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                decoration: const BoxDecoration(
                    color: Color(0xFF001D70),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32))),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // drag handle
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
                            child: Column(children: [
                          GestureDetector(
                            onTap: _showEmojiPicker,
                            child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      width: 88,
                                      height: 88,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _selectedEmoji.isEmpty
                                              ? _selectedColor
                                              : Colors.white.withOpacity(0.12),
                                          border: Border.all(
                                              color: _selectedColor, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                                color: _selectedColor
                                                    .withOpacity(0.45),
                                                blurRadius: 20,
                                                offset: const Offset(0, 6))
                                          ]),
                                      child: Center(
                                          child: _selectedEmoji.isEmpty
                                              ? const Icon(Icons.person_rounded,
                                                  color: Colors.white, size: 44)
                                              : Text(_selectedEmoji,
                                                  style: const TextStyle(
                                                      fontSize: 42)))),
                                  Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                          color: _selectedColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: const Color(0xFF001D70),
                                              width: 2)),
                                      child: const Icon(Icons.edit_rounded,
                                          color: Colors.white, size: 13)),
                                ]),
                          ),
                          const SizedBox(height: 8),
                          Text('Tap to choose avatar',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 11,
                                  fontFamily: 'Poppins')),
                        ])),
                        const SizedBox(height: 24),

                        _label('Full Name'), const SizedBox(height: 8),
                        _field(
                            controller: _nameController,
                            hint: 'Enter your name'),
                        const SizedBox(height: 16),

                        _label('Email'), const SizedBox(height: 8),
                        _field(
                            controller: _emailController,
                            hint: 'example@email.com',
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 16),

                        _label('Password'), const SizedBox(height: 8),
                        _field(
                            controller: _passwordController,
                            obscure: _obscurePassword,
                            suffix: IconButton(
                                icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white,
                                    size: 20),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword))),
                        const SizedBox(height: 16),

                        _label('Re-Enter Password'), const SizedBox(height: 8),
                        _field(
                            controller: _rePasswordController,
                            obscure: _obscureRePassword,
                            suffix: IconButton(
                                icon: Icon(
                                    _obscureRePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white,
                                    size: 20),
                                onPressed: () => setState(() =>
                                    _obscureRePassword = !_obscureRePassword))),
                        const SizedBox(height: 24),

                        _label('Profile Colour'),
                        const SizedBox(height: 4),
                        Text(
                            'Changes the avatar background colour in real time',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 11,
                                fontFamily: 'Poppins')),
                        const SizedBox(height: 14),
                        Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _palette.map((c) {
                              final sel = c == _selectedColor;
                              return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedColor = c),
                                  child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 40,
                                      height: 40,
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
                                                      color:
                                                          c.withOpacity(0.65),
                                                      blurRadius: 10,
                                                      spreadRadius: 1)
                                                ]
                                              : []),
                                      child: sel
                                          ? const Icon(Icons.check_rounded,
                                              color: Colors.white, size: 20)
                                          : null));
                            }).toList()),
                        const SizedBox(height: 20),

                        Row(children: [
                          SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  fillColor: WidgetStateProperty.all(
                                      const Color(0xFF2196F3)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2)))),
                          const SizedBox(width: 6),
                          const Text('Remember me',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400)),
                        ]),
                        const SizedBox(height: 28),

                        SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0796DE),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.2)),
                                child: const Text('Create Account',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700)))),
                        const SizedBox(height: 28),

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
                                ])))),
                      ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          letterSpacing: -0.36));

  Widget _field({
    required TextEditingController controller,
    String? hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500),
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
            suffixIcon: suffix));
  }
}
