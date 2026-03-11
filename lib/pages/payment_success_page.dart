import 'package:flutter/material.dart';
import 'dart:math' as math;

class PaymentSuccessPage extends StatefulWidget {
  final String amount;
  final String pharmacyName;

  const PaymentSuccessPage({
    super.key,
    required this.amount,
    required this.pharmacyName,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _circleCtrl;
  late AnimationController _checkCtrl;
  late AnimationController _contentCtrl;
  late AnimationController _particleCtrl;

  late Animation<double> _circleScale;
  late Animation<double> _circleOpacity;
  late Animation<double> _checkScale;
  late Animation<double> _contentSlide;
  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();

    _circleCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _circleCtrl, curve: Curves.elasticOut));
    _circleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _circleCtrl,
            curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));

    _checkCtrl = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _checkScale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut));

    _contentCtrl = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _contentSlide = Tween<double>(begin: 40.0, end: 0.0)
        .animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));
    _contentFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeIn));

    _particleCtrl = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);

    // Sequence the animations
    _circleCtrl.forward().then((_) => _checkCtrl.forward().then((_) {
          _contentCtrl.forward();
          _particleCtrl.forward();
        }));
  }

  @override
  void dispose() {
    _circleCtrl.dispose();
    _checkCtrl.dispose();
    _contentCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: Stack(children: [
        // Animated background circles
        _buildBackground(),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // ── Success circle + checkmark ──────────────────────
                AnimatedBuilder(
                  animation: Listenable.merge(
                      [_circleCtrl, _checkCtrl, _particleCtrl]),
                  builder: (ctx, _) => SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(alignment: Alignment.center, children: [
                      // Particle confetti
                      ..._buildParticles(),
                      // Outer ring
                      Transform.scale(
                          scale: _circleScale.value,
                          child: Opacity(
                              opacity: _circleOpacity.value,
                              child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0xFF0796DE)
                                              .withOpacity(0.3),
                                          width: 20))))),
                      // Inner circle
                      Transform.scale(
                          scale: _circleScale.value,
                          child: Container(
                              width: 110,
                              height: 110,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF0796DE),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0x660796DE),
                                        blurRadius: 30,
                                        spreadRadius: 5)
                                  ]))),
                      // Checkmark
                      Transform.scale(
                          scale: _checkScale.value,
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 54)),
                    ]),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Text content ─────────────────────────────────────
                AnimatedBuilder(
                  animation: _contentCtrl,
                  builder: (ctx, _) => Transform.translate(
                    offset: Offset(0, _contentSlide.value),
                    child: Opacity(
                      opacity: _contentFade.value,
                      child: Column(children: [
                        const Text('Payment Successful!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Text(
                            'Your order from ${widget.pharmacyName}\nhas been confirmed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                height: 1.5)),
                        const SizedBox(height: 32),

                        // Receipt card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.12))),
                          child: Column(children: [
                            _receiptRow('Pharmacy', widget.pharmacyName),
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(color: Colors.white12)),
                            _receiptRow('Amount Paid', widget.amount,
                                valueColor: const Color(0xFF0796DE),
                                valueBold: true,
                                valueLarge: true),
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(color: Colors.white12)),
                            _receiptRow('Status', 'Confirmed',
                                valueColor: const Color(0xFF4CAF50)),
                            const SizedBox(height: 8),
                            _receiptRow('Transaction ID',
                                '#MF${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Back to Home button ───────────────────────────────
                AnimatedBuilder(
                  animation: _contentCtrl,
                  builder: (ctx, _) => Opacity(
                    opacity: _contentFade.value,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamedAndRemoveUntil('/home', (_) => false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0796DE),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            elevation: 8,
                            shadowColor:
                                const Color(0xFF0796DE).withOpacity(0.4),
                          ),
                          child: const Text('Back to Home',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildParticles() {
    if (_particleCtrl.value == 0) return [];
    final rng = math.Random(42);
    return List.generate(12, (i) {
      final angle = (i / 12) * 2 * math.pi;
      final distance = 80.0 + rng.nextDouble() * 20;
      final t = _particleCtrl.value;
      final x = math.cos(angle) * distance * t;
      final y = math.sin(angle) * distance * t;
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      final colors = [
        const Color(0xFF0796DE),
        const Color(0xFF11B4F5),
        Colors.white,
        const Color(0xFF4CAF50),
        const Color(0xFFFFEB3B),
      ];
      return Transform.translate(
        offset: Offset(x, y),
        child: Opacity(
            opacity: opacity,
            child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: colors[i % colors.length]))),
      );
    });
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF001D70)),
      child: Stack(children: [
        Positioned(
            left: -30,
            top: -60,
            child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 30,
                        color: const Color(0xFF0796DE).withOpacity(0.15))))),
        Positioned(
            right: -40,
            bottom: 100,
            child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 25,
                        color: const Color(0xFF0796DE).withOpacity(0.10))))),
        Positioned(
            right: 30,
            top: 80,
            child: Opacity(
                opacity: 0.06,
                child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFF11B4F5))))),
      ]),
    );
  }

  Widget _receiptRow(String label, String value,
      {Color? valueColor, bool valueBold = false, bool valueLarge = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontFamily: 'Poppins')),
      Text(value,
          style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: valueLarge ? 16 : 13,
              fontFamily: 'Poppins',
              fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500)),
    ]);
  }
}
