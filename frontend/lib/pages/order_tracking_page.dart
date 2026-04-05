import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'delivery_success_page.dart';

class OrderTrackingPage extends StatefulWidget {
  final String pharmacyName;
  final String pharmacyAddress;
  final String amount;

  const OrderTrackingPage({
    super.key,
    required this.pharmacyName,
    required this.pharmacyAddress,
    required this.amount,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnim;
  late Animation<Offset> _slideAnim;

  // Simulated courier dot position on the fake map (0.0 → 1.0)
  double _courierProgress = 0.0;
  Timer? _progressTimer;
  bool _delivered = false;

  // Estimated minutes (counts down)
  int _etaMinutes = 32;
  Timer? _etaTimer;

  final String _courierName = 'Thisanda';
  final String _orderId = '#MF${Random().nextInt(900000) + 100000}';

  // Fake map path points (fraction of map widget size)
  static const _pathPoints = [
    Offset(0.18, 0.72), // start (pharmacy)
    Offset(0.28, 0.58),
    Offset(0.42, 0.52),
    Offset(0.55, 0.40),
    Offset(0.68, 0.30),
    Offset(0.78, 0.22), // end (home)
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim =
        Tween<double>(begin: 0.85, end: 1.15).animate(_pulseController);

    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));
    _slideController.forward();

    // Move courier every 2 seconds
    _progressTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        _courierProgress = (_courierProgress + 0.035).clamp(0.0, 1.0);
        if (_courierProgress >= 1.0 && !_delivered) {
          _delivered = true;
          _progressTimer?.cancel();
          _etaTimer?.cancel();
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!mounted) return;
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => DeliverySuccessPage(
                          pharmacyName: widget.pharmacyName,
                          amount: widget.amount,
                          orderId: _orderId,
                        )));
          });
        }
      });
    });

    // Count down ETA every 30 seconds
    _etaTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {
        if (_etaMinutes > 1) _etaMinutes--;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _progressTimer?.cancel();
    _etaTimer?.cancel();
    super.dispose();
  }

  void _showCallModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: Color(0xFFF5F7FF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFCDD5E0),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0796DE).withOpacity(0.1)),
            child: const Icon(Icons.call_rounded,
                color: Color(0xFF0796DE), size: 34),
          ),
          const SizedBox(height: 16),
          const Text('Call Courier',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Calling $_courierName...',
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          const Text('+94 77 123 4567',
              style: TextStyle(
                  color: Color(0xFF0796DE),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100))),
                child: const Text('Cancel',
                    style: TextStyle(
                        color: Color(0xFF64748B),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Calling courier...',
                        style: TextStyle(fontFamily: 'Poppins')),
                    backgroundColor: const Color(0xFF0796DE),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  ));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0796DE),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    elevation: 0),
                child: const Text('Call Now',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  final _messageController = TextEditingController();

  void _showMessageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
              color: Color(0xFFF5F7FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFCDD5E0),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0796DE).withOpacity(0.1)),
                child: const Icon(Icons.chat_bubble_rounded,
                    color: Color(0xFF0796DE), size: 22),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Message Courier',
                    style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700)),
                Text('Send a message to $_courierName',
                    style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontFamily: 'Poppins')),
              ]),
            ]),
            const SizedBox(height: 16),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Please call me 📞',
                  'How far are you? 📍',
                  'Ring the doorbell 🔔',
                  'Leave at the door 🚪',
                ]
                    .map((msg) => GestureDetector(
                          onTap: () => _messageController.text = msg,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                                color:
                                    const Color(0xFF0796DE).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFF0796DE)
                                        .withOpacity(0.2))),
                            child: Text(msg,
                                style: const TextStyle(
                                    color: Color(0xFF0796DE),
                                    fontSize: 12,
                                    fontFamily: 'Poppins')),
                          ),
                        ))
                    .toList()),
            const SizedBox(height: 14),
            TextField(
              controller: _messageController,
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    fontFamily: 'Poppins'),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF0796DE), width: 1.5)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final msg = _messageController.text.trim();
                  Navigator.pop(context);
                  _messageController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        msg.isEmpty
                            ? 'Message sent to $_courierName!'
                            : 'Sent: "$msg"',
                        style: const TextStyle(fontFamily: 'Poppins')),
                    backgroundColor: const Color(0xFF0796DE),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  ));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0796DE),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    elevation: 0),
                child: const Text('Send Message',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Offset _courierPosition(Size mapSize) {
    final t = _courierProgress * (_pathPoints.length - 1);
    final idx = t.floor().clamp(0, _pathPoints.length - 2);
    final frac = t - idx;
    final a = _pathPoints[idx];
    final b = _pathPoints[idx + 1];
    return Offset(
      (a.dx + (b.dx - a.dx) * frac) * mapSize.width,
      (a.dy + (b.dy - a.dy) * frac) * mapSize.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001D70),
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const Expanded(
                    child: Text('Track Order',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.info_outline,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // ── Fake map ──────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8))
                    ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size =
                          Size(constraints.maxWidth, constraints.maxHeight);
                      final courierPos = _courierPosition(size);
                      final homePos = Offset(_pathPoints.last.dx * size.width,
                          _pathPoints.last.dy * size.height);
                      final pharmacyPos = Offset(
                          _pathPoints.first.dx * size.width,
                          _pathPoints.first.dy * size.height);

                      return Stack(
                        children: [
                          // Map background
                          _FakeMap(size: size),

                          // Route path
                          CustomPaint(
                            size: size,
                            painter: _RoutePainter(
                                points: _pathPoints,
                                progress: _courierProgress),
                          ),

                          // Pharmacy pin (orange)
                          Positioned(
                            left: pharmacyPos.dx - 16,
                            top: pharmacyPos.dy - 36,
                            child: _MapPin(
                                color: const Color(0xFFF97316),
                                icon: Icons.local_pharmacy),
                          ),

                          // Home pin (blue)
                          Positioned(
                            left: homePos.dx - 16,
                            top: homePos.dy - 36,
                            child: _MapPin(
                                color: const Color(0xFF0796DE),
                                icon: Icons.home_rounded),
                          ),

                          // Courier dot (animated pulse)
                          Positioned(
                            left: courierPos.dx - 18,
                            top: courierPos.dy - 18,
                            child: ScaleTransition(
                              scale: _pulseAnim,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF0796DE),
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                          color: const Color(0xFF0796DE)
                                              .withOpacity(0.5),
                                          blurRadius: 12,
                                          spreadRadius: 2)
                                    ]),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/courier_avatar.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.delivery_dining,
                                        color: Colors.white,
                                        size: 18),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Bottom sheet ──────────────────────────────────────────
            SlideTransition(
              position: _slideAnim,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FF),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32))),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // drag handle
                    Center(
                        child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                                color: const Color(0xFFCDD5E0),
                                borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 14),

                    // ETA
                    Text('Estimated delivery time',
                        style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 12,
                            fontFamily: 'Poppins')),
                    Text('$_etaMinutes – ${_etaMinutes + 10} min',
                        style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 22,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),

                    // Progress stepper
                    _OrderStepper(progress: _courierProgress),
                    const SizedBox(height: 16),

                    // Route info
                    _RouteRow(
                        icon: Icons.storefront_rounded,
                        color: const Color(0xFFF97316),
                        title: widget.pharmacyName,
                        subtitle: widget.pharmacyAddress),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Container(
                          width: 2, height: 20, color: const Color(0xFFCDD5E0)),
                    ),
                    _RouteRow(
                        icon: Icons.home_rounded,
                        color: const Color(0xFF0796DE),
                        title: 'Home',
                        subtitle: '95/5 St. Sebastien road, Nugegoda'),
                    const Divider(height: 24, color: Color(0xFFE2E8F0)),

                    // Courier row
                    Row(children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFFFFEDD5)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/images/courier_avatar.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                color: Color(0xFFF97316),
                                size: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('Medicine courier',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontFamily: 'Poppins')),
                            Text(_courierName,
                                style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600)),
                          ])),
                      _IconBtn(
                          icon: Icons.call_rounded,
                          onTap: () => _showCallModal(context)),
                      const SizedBox(width: 8),
                      _IconBtn(
                          icon: Icons.chat_bubble_rounded,
                          onTap: () => _showMessageModal(context)),
                    ]),
                    const SizedBox(height: 16),

                    // Order detail button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0796DE),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            elevation: 0),
                        child: const Text('Order Detail',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _MapPin extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _MapPin({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)
            ]),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
      CustomPaint(
          size: const Size(12, 8), painter: _PinTailPainter(color: color)),
    ]);
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RoutePainter extends CustomPainter {
  final List<Offset> points;
  final double progress;
  _RoutePainter({required this.points, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Grey remaining path
    final greyPaint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Blue completed path
    final bluePaint = Paint()
      ..color = const Color(0xFF0796DE)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fullPath = Path();
    final completedPath = Path();

    final scaledPoints = points
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    fullPath.moveTo(scaledPoints[0].dx, scaledPoints[0].dy);
    for (final p in scaledPoints.skip(1)) {
      fullPath.lineTo(p.dx, p.dy);
    }

    // Compute total length for progress
    double totalLen = 0;
    for (int i = 0; i < scaledPoints.length - 1; i++) {
      totalLen += (scaledPoints[i + 1] - scaledPoints[i]).distance;
    }
    double targetLen = totalLen * progress;
    double drawn = 0;

    completedPath.moveTo(scaledPoints[0].dx, scaledPoints[0].dy);
    for (int i = 0; i < scaledPoints.length - 1; i++) {
      final segLen = (scaledPoints[i + 1] - scaledPoints[i]).distance;
      if (drawn + segLen <= targetLen) {
        completedPath.lineTo(scaledPoints[i + 1].dx, scaledPoints[i + 1].dy);
        drawn += segLen;
      } else {
        final frac = (targetLen - drawn) / segLen;
        completedPath.lineTo(
          scaledPoints[i].dx +
              (scaledPoints[i + 1].dx - scaledPoints[i].dx) * frac,
          scaledPoints[i].dy +
              (scaledPoints[i + 1].dy - scaledPoints[i].dy) * frac,
        );
        break;
      }
    }

    canvas.drawPath(fullPath, greyPaint);
    canvas.drawPath(completedPath, bluePaint);
  }

  @override
  bool shouldRepaint(_RoutePainter old) => old.progress != progress;
}

class _FakeMap extends StatelessWidget {
  final Size size;
  const _FakeMap({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _MapPainter(),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFEAE6DF);
    canvas.drawRect(Offset.zero & size, bg);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final thinRoad = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 7;

    final blockPaint = Paint()..color = const Color(0xFFD5CFC7);

    // Draw some blocks
    void block(double x, double y, double w, double h) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x * size.width, y * size.height, w * size.width,
                  h * size.height),
              const Radius.circular(4)),
          blockPaint);
    }

    block(0.02, 0.05, 0.20, 0.18);
    block(0.25, 0.02, 0.18, 0.14);
    block(0.47, 0.04, 0.22, 0.16);
    block(0.72, 0.02, 0.25, 0.20);
    block(0.02, 0.32, 0.15, 0.22);
    block(0.20, 0.28, 0.20, 0.18);
    block(0.44, 0.25, 0.18, 0.20);
    block(0.65, 0.24, 0.20, 0.18);
    block(0.88, 0.25, 0.12, 0.20);
    block(0.02, 0.62, 0.18, 0.22);
    block(0.24, 0.60, 0.20, 0.20);
    block(0.48, 0.60, 0.18, 0.22);
    block(0.70, 0.58, 0.22, 0.20);
    block(0.02, 0.88, 0.30, 0.10);
    block(0.36, 0.88, 0.30, 0.10);
    block(0.70, 0.86, 0.28, 0.12);

    // Horizontal roads
    for (final y in [0.24, 0.55, 0.83]) {
      canvas.drawLine(Offset(0, y * size.height),
          Offset(size.width, y * size.height), roadPaint);
    }
    for (final y in [0.10, 0.40, 0.68]) {
      canvas.drawLine(Offset(0, y * size.height),
          Offset(size.width, y * size.height), thinRoad);
    }
    // Vertical roads
    for (final x in [0.22, 0.45, 0.68, 0.90]) {
      canvas.drawLine(Offset(x * size.width, 0),
          Offset(x * size.width, size.height), roadPaint);
    }
    for (final x in [0.10, 0.34, 0.57, 0.80]) {
      canvas.drawLine(Offset(x * size.width, 0),
          Offset(x * size.width, size.height), thinRoad);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _OrderStepper extends StatelessWidget {
  final double progress;
  const _OrderStepper({required this.progress});

  @override
  Widget build(BuildContext context) {
    final steps = ['Confirmed', 'Preparing', 'On the way', 'Delivered'];
    final activeStep = progress < 0.01
        ? 0
        : progress < 0.33
            ? 1
            : progress < 0.66
                ? 2
                : progress < 1.0
                    ? 2
                    : 3;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final lineActive = (i ~/ 2) < activeStep;
          return Expanded(
              child: Container(
                  height: 2,
                  color: lineActive
                      ? const Color(0xFF0796DE)
                      : const Color(0xFFE2E8F0)));
        }
        final idx = i ~/ 2;
        final done = idx < activeStep;
        final current = idx == activeStep;
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || current
                    ? const Color(0xFF0796DE)
                    : const Color(0xFFE2E8F0),
                border: current
                    ? Border.all(
                        color: const Color(0xFF0796DE).withOpacity(0.3),
                        width: 4)
                    : null),
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : current
                    ? Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle))
                    : null,
          ),
          const SizedBox(height: 4),
          Text(steps[idx],
              style: TextStyle(
                  fontSize: 9,
                  fontFamily: 'Poppins',
                  color: done || current
                      ? const Color(0xFF0796DE)
                      : const Color(0xFF94A3B8),
                  fontWeight: current ? FontWeight.w600 : FontWeight.w400)),
        ]);
      }),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _RouteRow(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600)),
        Text(subtitle,
            style: const TextStyle(
                color: Color(0xFF94A3B8), fontSize: 11, fontFamily: 'Poppins')),
      ])),
    ]);
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF64748B), size: 20),
      ),
    );
  }
}
