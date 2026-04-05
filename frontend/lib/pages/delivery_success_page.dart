import 'dart:math';
import 'order_store.dart';
import 'package:flutter/material.dart';

class DeliverySuccessPage extends StatefulWidget {
  final String pharmacyName;
  final String amount;
  final String orderId;

  const DeliverySuccessPage({
    super.key,
    required this.pharmacyName,
    required this.amount,
    required this.orderId,
  });

  @override
  State<DeliverySuccessPage> createState() => _DeliverySuccessPageState();
}

class _DeliverySuccessPageState extends State<DeliverySuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _checkController;
  late AnimationController _contentController;
  late AnimationController _confettiController;

  late Animation<double> _circleScale;
  late Animation<double> _checkScale;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;
  late Animation<double> _confettiAnim;

  final _confettiItems = List.generate(
      22,
      (i) => _ConfettiDot(
            x: Random().nextDouble(),
            y: Random().nextDouble() * 0.6,
            size: Random().nextDouble() * 8 + 5,
            color: [
              const Color(0xFF0796DE),
              const Color(0xFF4CAF50),
              const Color(0xFFFFD700),
              const Color(0xFFFF6B6B),
              Colors.white,
              const Color(0xFF9C27B0),
            ][Random().nextInt(6)],
            speed: Random().nextDouble() * 0.4 + 0.3,
          ));

  @override
  void initState() {
    super.initState();

    _circleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _checkController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _confettiController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _circleScale =
        CurvedAnimation(parent: _circleController, curve: Curves.elasticOut);
    _checkScale =
        CurvedAnimation(parent: _checkController, curve: Curves.bounceOut);
    _contentOpacity =
        Tween<double>(begin: 0, end: 1).animate(_contentController);
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _contentController, curve: Curves.easeOut));
    _confettiAnim =
        CurvedAnimation(parent: _confettiController, curve: Curves.easeOut);

    // Save to order history
    final now = DateTime.now();
    OrderStore.instance.addOrder(OrderItem(
      pharmacyName: widget.pharmacyName,
      amount: widget.amount,
      orderId: widget.orderId,
      deliveredAt:
          '${now.day}/${now.month}/${now.year}  •  ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      status: 'Delivered',
    ));

    Future.delayed(
        const Duration(milliseconds: 100), () => _circleController.forward());
    Future.delayed(
        const Duration(milliseconds: 500), () => _checkController.forward());
    Future.delayed(
        const Duration(milliseconds: 750), () => _contentController.forward());
    Future.delayed(
        const Duration(milliseconds: 600), () => _confettiController.forward());
  }

  @override
  void dispose() {
    _circleController.dispose();
    _checkController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: Stack(
        children: [
          // Background circles
          Positioned(
              left: -40,
              top: -40,
              child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 30,
                          color: const Color(0xFF10A2EA)
                              .withValues(alpha: 0.3))))),
          Positioned(
              right: -50,
              bottom: 100,
              child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 30,
                          color: const Color(0xFF10A2EA)
                              .withValues(alpha: 0.2))))),

          // Confetti
          AnimatedBuilder(
            animation: _confettiAnim,
            builder: (_, __) => Stack(
              children: _confettiItems.map((dot) {
                final t = (_confettiAnim.value / dot.speed).clamp(0.0, 1.0);
                return Positioned(
                  left: dot.x * size.width,
                  top: dot.y * size.height + t * size.height * 0.35,
                  child: Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: t * pi * 4,
                      child: Container(
                          width: dot.size,
                          height: dot.size,
                          decoration: BoxDecoration(
                              color: dot.color,
                              borderRadius: BorderRadius.circular(2))),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Animated icon
                  ScaleTransition(
                    scale: _circleScale,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              const Color(0xFF0796DE).withValues(alpha: 0.15),
                          border: Border.all(
                              color: const Color(0xFF0796DE)
                                  .withValues(alpha: 0.3),
                              width: 2)),
                      child: Center(
                        child: ScaleTransition(
                          scale: _checkScale,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF11A2EB),
                                      Color(0xFF0796DE)
                                    ])),
                            child: const Icon(Icons.home_rounded,
                                color: Colors.white, size: 46),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Text
                  SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: Column(children: [
                        const Text('Order Delivered!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                            'Your order from ${widget.pharmacyName}\nhas been delivered successfully.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                height: 1.5)),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Receipt card
                  SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12))),
                        padding: const EdgeInsets.all(20),
                        child: Column(children: [
                          _ReceiptRow(
                              label: 'Pharmacy',
                              value: widget.pharmacyName,
                              valueColor: Colors.white),
                          const Divider(color: Colors.white12, height: 24),
                          _ReceiptRow(
                              label: 'Amount Paid',
                              value: widget.amount,
                              valueColor: const Color(0xFF11A2EB),
                              valueBold: true),
                          const Divider(color: Colors.white12, height: 24),
                          const _ReceiptRow(
                              label: 'Status',
                              value: 'Delivered ✓',
                              valueColor: Color(0xFF4CAF50)),
                          const SizedBox(height: 8),
                          _ReceiptRow(
                              label: 'Order ID',
                              value: widget.orderId,
                              valueColor: Colors.white70),
                        ]),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Button
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (_) => false),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0796DE),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            elevation: 8,
                            shadowColor:
                                const Color(0xFF0796DE).withValues(alpha: 0.5)),
                        child: const Text('Back to Home',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool valueBold;
  const _ReceiptRow(
      {required this.label,
      required this.value,
      required this.valueColor,
      this.valueBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              fontFamily: 'Poppins')),
      Text(value,
          style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500)),
    ]);
  }
}

class _ConfettiDot {
  final double x, y, size, speed;
  final Color color;
  const _ConfettiDot(
      {required this.x,
      required this.y,
      required this.size,
      required this.color,
      required this.speed});
}
