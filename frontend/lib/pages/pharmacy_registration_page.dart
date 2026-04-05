import 'dart:math';
import 'package:flutter/material.dart';
import 'pharmacy_details_form_page.dart';

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

class PharmacyRegistrationPage extends StatefulWidget {
  const PharmacyRegistrationPage({super.key});

  @override
  State<PharmacyRegistrationPage> createState() =>
      _PharmacyRegistrationPageState();
}

class _PharmacyRegistrationPageState extends State<PharmacyRegistrationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  late List<_OrbState> _orbs;
  final _rng = Random();
  bool _orbsInited = false;
  double _screenW = 390;
  double _screenH = 844;
  DateTime? _lastTime;

  static const _orbTemplates = [
    // Border rings
    {'size': 183.0, 'op': 1.0, 'border': true, 'speed': 18.0, 'bottom': false},
    {'size': 167.0, 'op': 1.0, 'border': true, 'speed': 14.0, 'bottom': false},
    {'size': 190.0, 'op': 1.0, 'border': true, 'speed': 16.0, 'bottom': false},
    {'size': 140.0, 'op': 1.0, 'border': true, 'speed': 12.0, 'bottom': false},
    // Top/mid gradient blobs
    {
      'size': 154.0,
      'op': 0.28,
      'border': false,
      'speed': 22.0,
      'bottom': false
    },
    {'size': 89.0, 'op': 0.26, 'border': false, 'speed': 28.0, 'bottom': false},
    {'size': 94.0, 'op': 0.26, 'border': false, 'speed': 25.0, 'bottom': false},
    {
      'size': 110.0,
      'op': 0.20,
      'border': false,
      'speed': 18.0,
      'bottom': false
    },
    // Bottom gradient rings
    {'size': 200.0, 'op': 0.30, 'border': false, 'speed': 16.0, 'bottom': true},
    {'size': 150.0, 'op': 0.28, 'border': false, 'speed': 20.0, 'bottom': true},
    {'size': 100.0, 'op': 0.24, 'border': false, 'speed': 24.0, 'bottom': true},
    {'size': 70.0, 'op': 0.22, 'border': false, 'speed': 28.0, 'bottom': true},
    {'size': 130.0, 'op': 0.20, 'border': false, 'speed': 18.0, 'bottom': true},
  ];

  void _initOrbs() {
    _orbs = _orbTemplates.map((t) {
      final isBottom = t['bottom'] as bool;
      final startX = _rng.nextDouble() * (_screenW + 100) - 50;
      final startY = isBottom
          ? _screenH * 0.60 + _rng.nextDouble() * (_screenH * 0.50)
          : _rng.nextDouble() * (_screenH * 0.65);
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = t['speed'] as double;
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
    _ticker =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _ticker.addListener(_tick);
  }

  @override
  void dispose() {
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
                    colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                  )),
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
            // ── Animated orbs ─────────────────────────────────────
            ..._orbs.map(_buildOrb),

            // ── Page content ──────────────────────────────────────
            SafeArea(
              child: Column(children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 10),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Column(children: [
                        Text('Pharmacy Registration',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFFAFAFA),
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 5),
                        Text('Register your pharmacy to the system',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFA2E0FF),
                                fontSize: 10,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400)),
                      ]),
                    ),
                    const SizedBox(width: 48),
                  ]),
                ),

                const Spacer(),

                // White card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 33),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(25)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 15),

                        // Drag handle
                        Container(
                            width: 33,
                            height: 8,
                            decoration: BoxDecoration(
                                color: const Color(0xFFECEFEE),
                                borderRadius: BorderRadius.circular(2.5))),

                        const SizedBox(height: 20),

                        // Logo — no wrapping container, transparent background
                        Image.asset(
                          'assets/images/Medifind_logo.png',
                          width: 160,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_pharmacy_rounded,
                                  color: Color(0xFF0796DE), size: 70),
                              const SizedBox(height: 6),
                              RichText(
                                  text: const TextSpan(children: [
                                TextSpan(
                                    text: 'Medi',
                                    style: TextStyle(
                                        color: Color(0xFF0796DE),
                                        fontSize: 28,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w800)),
                                TextSpan(
                                    text: 'Find',
                                    style: TextStyle(
                                        color: Color(0xFF57BFFF),
                                        fontSize: 28,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w800)),
                              ])),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Description
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          child: Text(
                              "Here's The portal for register\nyour pharmacy",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF2D2D2D),
                                  fontSize: 18,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.4)),
                        ),

                        const SizedBox(height: 30),

                        // Register button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const PharmacyDetailsFormPage())),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0796DE),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: const Text('Register',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
