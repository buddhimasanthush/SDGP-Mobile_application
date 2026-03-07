import 'dart:math';
import 'package:flutter/material.dart';
import 'upload_prescription_options_page.dart';

class UploadPrescriptionMainPage extends StatefulWidget {
  const UploadPrescriptionMainPage({super.key});

  @override
  State<UploadPrescriptionMainPage> createState() =>
      _UploadPrescriptionMainPageState();
}

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

class _UploadPrescriptionMainPageState extends State<UploadPrescriptionMainPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  late List<_OrbState> _orbs;
  final _rng = Random();
  DateTime? _lastTime;

  // Orb templates: size, opacity, isBorder, speed
  static const _templates = [
    [183.0, 1.0, 1, 18.0],
    [167.0, 1.0, 1, 14.0],
    [190.0, 1.0, 1, 16.0],
    [140.0, 1.0, 1, 12.0],
    [154.0, 0.30, 0, 22.0],
    [89.0, 0.28, 0, 28.0],
    [94.0, 0.28, 0, 25.0],
    [120.0, 0.25, 0, 20.0],
    [75.0, 0.22, 0, 30.0],
    [110.0, 0.20, 0, 18.0],
    [60.0, 0.20, 0, 32.0],
    [80.0, 0.18, 0, 26.0],
  ];

  double _sw = 390;
  double _sh = 844;

  @override
  void initState() {
    super.initState();
    _initOrbs();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _ticker.addListener(_tick);
  }

  void _initOrbs() {
    _orbs = _templates.map((t) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = t[3] as double;
      return _OrbState(
        x: _rng.nextDouble() * (_sw + 100) - 50,
        y: _rng.nextDouble() * (_sh + 100) - 50,
        size: t[0] as double,
        opacity: t[1] as double,
        isBorder: (t[2] as int) == 1,
        speed: speed,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        targetX: _rng.nextDouble() * (_sw + 160) - 80,
        targetY: _rng.nextDouble() * (_sh + 160) - 80,
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
          orb.targetX = _rng.nextDouble() * (_sw + 160) - 80;
          orb.targetY = _rng.nextDouble() * (_sh + 160) - 80;
        } else {
          final desiredVx = (dx / dist) * orb.speed;
          final desiredVy = (dy / dist) * orb.speed;
          orb.vx += (desiredVx - orb.vx) * 0.012;
          orb.vy += (desiredVy - orb.vy) * 0.012;
        }

        orb.x += orb.vx * dt;
        orb.y += orb.vy * dt;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _sw = size.width;
    _sh = size.height;
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
                  border: Border.all(width: 28, color: const Color(0xFF10A2EA)),
                )
              : const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(0.93, 0.35),
                    end: Alignment(0.06, 0.40),
                    colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0796DE),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ── Floating orbs ─────────────────────────────────────
            ..._orbs.map(_buildOrb),

            // ── Page content ──────────────────────────────────────
            SafeArea(
              child: Column(children: [
                // App bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 24),
                    ),
                    const Expanded(
                      child: Column(children: [
                        Text('Upload Prescription',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700)),
                        Text('Upload your pharmacy to the system',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontFamily: 'Poppins')),
                      ]),
                    ),
                    const SizedBox(width: 24),
                  ]),
                ),

                // ── White card ────────────────────────────────────
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 44),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.14),
                                blurRadius: 40,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/Medifind_logo.png',
                              height: 100,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_pharmacy_rounded,
                                      color: Color(0xFF0796DE), size: 64),
                                  const SizedBox(height: 6),
                                  RichText(
                                      text: const TextSpan(children: [
                                    TextSpan(
                                        text: 'Medi',
                                        style: TextStyle(
                                            color: Color(0xFF0796DE),
                                            fontSize: 26,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w800)),
                                    TextSpan(
                                        text: 'Find',
                                        style: TextStyle(
                                            color: Color(0xFF57BFFF),
                                            fontSize: 26,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w800)),
                                  ])),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "Here's The portal for upload\nyour prescription",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF2D2D2D),
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  height: 1.6),
                            ),
                            const SizedBox(height: 36),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            UploadPrescriptionOptionsPage())),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0796DE),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30))),
                                child: const Text('Upload',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
