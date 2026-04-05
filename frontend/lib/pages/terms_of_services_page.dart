import 'dart:math';
import 'package:flutter/material.dart';

class TermsOfServicesPage extends StatefulWidget {
  const TermsOfServicesPage({super.key});

  @override
  State<TermsOfServicesPage> createState() => _TermsOfServicesPageState();
}

// ── Orb physics state ─────────────────────────────────────────────────────────
class _OrbState {
  double x, y;
  final double size;
  final double opacity;
  final bool isBorder;
  final double speed;
  double vx, vy;
  double targetX, targetY;

  _OrbState({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.isBorder,
    required this.speed,
    required this.vx,
    required this.vy,
    required this.targetX,
    required this.targetY,
  });
}

class _TermsOfServicesPageState extends State<TermsOfServicesPage>
    with TickerProviderStateMixin {
  // ── Existing animations ───────────────────────────────────────────────────
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _acceptedTerms = false;

  // ── Orb floating system ───────────────────────────────────────────────────
  late AnimationController _ticker;
  late List<_OrbState> _orbs;
  final _rng = Random();
  bool _orbsInited = false;
  double _screenW = 390;
  double _screenH = 844;
  DateTime? _lastTime;

  static const _orbTemplates = [
    {'size': 183.0, 'op': 1.0, 'border': true, 'speed': 18.0},
    {'size': 167.0, 'op': 1.0, 'border': true, 'speed': 14.0},
    {'size': 190.0, 'op': 1.0, 'border': true, 'speed': 16.0},
    {'size': 140.0, 'op': 1.0, 'border': true, 'speed': 12.0},
    {'size': 154.0, 'op': 0.28, 'border': false, 'speed': 22.0},
    {'size': 89.0, 'op': 0.26, 'border': false, 'speed': 28.0},
    {'size': 94.0, 'op': 0.26, 'border': false, 'speed': 25.0},
    {'size': 120.0, 'op': 0.22, 'border': false, 'speed': 20.0},
    {'size': 75.0, 'op': 0.20, 'border': false, 'speed': 30.0},
    {'size': 110.0, 'op': 0.18, 'border': false, 'speed': 18.0},
    // Extra bottom gradient rings
    {'size': 200.0, 'op': 0.30, 'border': false, 'speed': 16.0, 'bottom': true},
    {'size': 150.0, 'op': 0.28, 'border': false, 'speed': 20.0, 'bottom': true},
    {'size': 100.0, 'op': 0.24, 'border': false, 'speed': 24.0, 'bottom': true},
    {'size': 70.0, 'op': 0.22, 'border': false, 'speed': 28.0, 'bottom': true},
    {'size': 130.0, 'op': 0.20, 'border': false, 'speed': 18.0, 'bottom': true},
  ];

  void _initOrbs() {
    _orbs = _orbTemplates.map((t) {
      final isBottom = (t['bottom'] ?? false) as bool;
      final startX = _rng.nextDouble() * (_screenW + 100) - 50;
      // Bottom orbs start in lower 40% of screen; others scatter everywhere
      final startY = isBottom
          ? _screenH * 0.60 + _rng.nextDouble() * (_screenH * 0.50)
          : _rng.nextDouble() * (_screenH + 100) - 50;
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = t['speed'] as double;
      // Bottom orbs pick targets in lower half; others target anywhere
      final tX = _rng.nextDouble() * (_screenW + 160) - 80;
      final tY = isBottom
          ? _screenH * 0.55 + _rng.nextDouble() * (_screenH * 0.55)
          : _rng.nextDouble() * (_screenH + 160) - 80;
      return _OrbState(
        x: startX,
        y: startY,
        size: t['size'] as double,
        opacity: t['op'] as double,
        isBorder: t['border'] as bool,
        speed: speed,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        targetX: tX,
        targetY: tY,
      );
    }).toList();
  }

  void _tick() {
    if (!mounted) return;
    final now = DateTime.now();
    if (_lastTime == null) {
      _lastTime = now;
      return;
    }
    final dt = now.difference(_lastTime!).inMicroseconds / 1e6;
    _lastTime = now;
    if (dt <= 0 || dt > 0.1) return;

    setState(() {
      for (final orb in _orbs) {
        final dx = orb.targetX - orb.x;
        final dy = orb.targetY - orb.y;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < 40) {
          orb.targetX = _rng.nextDouble() * (_screenW + 160) - 80;
          orb.targetY = _rng.nextDouble() * (_screenH + 160) - 80;
        } else {
          const steer = 0.012;
          orb.vx += ((dx / dist) * orb.speed - orb.vx) * steer;
          orb.vy += ((dy / dist) * orb.speed - orb.vy) * steer;
        }
        orb.x += orb.vx * dt;
        orb.y += orb.vy * dt;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Slide up animation for white card
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Fade in for title
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scrollController.addListener(_onScroll);
    _startAnimations();

    // Orb ticker
    _ticker =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _ticker.addListener(_tick);
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();
  }

  void _onScroll() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent - 10) {
      if (!_hasScrolledToBottom) setState(() => _hasScrolledToBottom = true);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    _ticker.removeListener(_tick);
    _ticker.dispose();
    super.dispose();
  }

  Widget _buildOrb(_OrbState orb) {
    return Positioned(
      left: orb.x - orb.size / 2,
      top: orb.y - orb.size / 2,
      child: Opacity(
        opacity: orb.opacity,
        child: Container(
          width: orb.size,
          height: orb.size,
          decoration: orb.isBorder
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 28, color: const Color(0xFF10A2EA)))
              : const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      begin: Alignment(0.93, 0.35),
                      end: Alignment(0.06, 0.40),
                      colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)])),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_orbsInited) {
      final size = MediaQuery.of(context).size;
      _screenW = size.width;
      _screenH = size.height;
      _initOrbs();
      _orbsInited = true;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0796DE),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ── Floating orbs background ──────────────────────────
            ..._orbs.map(_buildOrb),

            // ── Page content ──────────────────────────────────────
            SafeArea(
              child: Column(children: [
                // Title
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Terms of Services',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFFFAFAFA),
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                // White card
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 33),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25)),
                      child: Column(children: [
                        // Drag handle
                        Container(
                            width: 33,
                            height: 12,
                            decoration: BoxDecoration(
                                color: const Color(0xFFECEFEE),
                                borderRadius: BorderRadius.circular(2.5))),

                        const SizedBox(height: 20),

                        // Logo
                        Image.asset(
                          'assets/images/Medifind_logo.png',
                          width: 107,
                          height: 59,
                          errorBuilder: (_, __, ___) => Container(
                              width: 107,
                              height: 59,
                              color: const Color(0xFF0796DE),
                              child: const Icon(Icons.medical_services,
                                  color: Colors.white, size: 30)),
                        ),

                        const SizedBox(height: 20),

                        // Scrollable terms
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(children: [
                              const Text(
                                _termsText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF2D2D2D),
                                    fontSize: 14,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                    height: 1.3),
                              ),
                              const SizedBox(height: 30),

                              // Checkbox
                              AnimatedOpacity(
                                opacity: _hasScrolledToBottom ? 1.0 : 0.3,
                                duration: const Duration(milliseconds: 300),
                                child: InkWell(
                                  onTap: _hasScrolledToBottom
                                      ? () => setState(() =>
                                          _acceptedTerms = !_acceptedTerms)
                                      : null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                          value: _acceptedTerms,
                                          onChanged: _hasScrolledToBottom
                                              ? (v) => setState(() =>
                                                  _acceptedTerms = v ?? false)
                                              : null,
                                          activeColor: const Color(0xFF0796DE)),
                                      const Flexible(
                                          child: Text(
                                              'I accept the terms and conditions',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: 'Arimo',
                                                  color: Color(0xFF2D2D2D)))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ]),
                          ),
                        ),

                        // Accept button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _acceptedTerms
                                ? () => Navigator.pushReplacementNamed(
                                    context, '/welcome')
                                : null,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0796DE),
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: Text('Accept',
                                style: TextStyle(
                                    color: _acceptedTerms
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  static const String _termsText =
      '''By accessing and using the MediFind mobile application, you agree to comply with and be bound by these Terms of Service. If you do not agree with these terms, you may not access or use the application.\n\nMediFind is a digital platform that allows users to upload prescriptions, search for nearby pharmacies, check medicine availability, manage medicine reminders, and place medicine-related orders.\n\nThe system may use Optical Character Recognition (OCR) technology and other automated tools to extract text and information from uploaded prescription images. While MediFind utilizes digital processing technologies to improve convenience and efficiency, we do not guarantee one hundred percent accuracy of extracted prescription details.\n\nUsers are responsible for carefully reviewing and confirming all prescription information before placing any orders. Pharmacies using the platform are responsible for verifying prescriptions in accordance with applicable medical standards and regulations before dispensing medication.\n\nUsers agree to provide accurate and truthful information, upload only valid and legally obtained prescriptions, and use the application strictly for lawful medical purposes. Any misuse of the platform, including submitting false information or attempting to disrupt the system, may result in suspension or termination of access.\n\nPharmacies registering on the MediFind platform must submit accurate registration details and valid licensing documentation for verification. MediFind reserves the right to review, approve, or reject pharmacy registrations at its discretion.\n\nMediFind is committed to protecting user privacy. Prescription images and personal information are securely processed and stored solely for service-related purposes. Data will not be shared with unauthorized third parties except where required by law or with user consent.\n\nMediFind operates as an intermediary platform connecting users and pharmacies and is not responsible for incorrect medication dispensed by pharmacies, delays in order processing or delivery, or errors resulting from unclear or incomplete prescription uploads.\n\nUsers are encouraged to consult qualified healthcare professionals for medical advice. MediFind reserves the right to modify, suspend, or discontinue any part of the service at any time. Continued use of the application indicates acceptance of these terms.''';
}
