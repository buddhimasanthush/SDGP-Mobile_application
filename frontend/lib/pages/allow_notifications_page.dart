import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'allow_tracking_page.dart';

class AllowNotificationsPage extends StatefulWidget {
  const AllowNotificationsPage({super.key});

  @override
  State<AllowNotificationsPage> createState() => _AllowNotificationsPageState();
}

class _AllowNotificationsPageState extends State<AllowNotificationsPage>
    with TickerProviderStateMixin {
  late AnimationController _floatController1;
  late AnimationController _floatController2;
  late AnimationController _floatController3;
  late AnimationController _floatController4;
  late Animation<Offset> _floatAnimation1;
  late Animation<Offset> _floatAnimation2;
  late Animation<Offset> _floatAnimation3;
  late Animation<Offset> _floatAnimation4;

  @override
  void initState() {
    super.initState();
    _floatController1 =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat(reverse: true);
    _floatController2 =
        AnimationController(duration: const Duration(seconds: 4), vsync: this)
          ..repeat(reverse: true);
    _floatController3 =
        AnimationController(duration: const Duration(seconds: 5), vsync: this)
          ..repeat(reverse: true);
    _floatController4 = AnimationController(
        duration: const Duration(seconds: 3, milliseconds: 500), vsync: this)
      ..repeat(reverse: true);
    _floatAnimation1 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(25, -35)).animate(
            CurvedAnimation(
                parent: _floatController1, curve: Curves.easeInOut));
    _floatAnimation2 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-20, 30)).animate(
            CurvedAnimation(
                parent: _floatController2, curve: Curves.easeInOut));
    _floatAnimation3 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(35, 20)).animate(
            CurvedAnimation(
                parent: _floatController3, curve: Curves.easeInOut));
    _floatAnimation4 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-25, -30)).animate(
            CurvedAnimation(
                parent: _floatController4, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatController1.dispose();
    _floatController2.dispose();
    _floatController3.dispose();
    _floatController4.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    // Request real notification permission from device
    await Permission.notification.request();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AllowTrackingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF0796DE)),
        child: Stack(
          children: [
            ..._buildDecorativeCircles(),

            // Gradient overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 280,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0796DE).withOpacity(0.0),
                        const Color(0xFF0796DE).withOpacity(0.3),
                        const Color(0xFF0564B8).withOpacity(0.7),
                        const Color(0xFF001F81),
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Top label
            const Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Allow Notifications',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Main content
            Positioned(
              left: 28,
              right: 28,
              top: MediaQuery.of(context).size.height * 0.28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    "We'll help you to stay in track",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tags
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTag(Icons.notifications_outlined, 'Notification'),
                      const SizedBox(width: 10),
                      _buildTag(Icons.error_outline, 'Must Allow',
                          mustAllow: true),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // iOS-style permission dialog
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 28),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            '"MediFind" Would Like to\nSend You Notifications',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF0796DE),
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            'Permission is required to alert you\neven on lock screen',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF9F9EA5),
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(height: 1, color: Colors.grey.shade200),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _handleNext,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        "Don't Allow",
                                        style: TextStyle(
                                          color: Color(0xFF9F9EA5),
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                  width: 1, color: Colors.grey.shade200),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _handleNext,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        'Allow',
                                        style: TextStyle(
                                          color: Color(0xFF0796DE),
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Next button
            Positioned(
              left: 0,
              right: 0,
              bottom: 90,
              child: Center(
                child: GestureDetector(
                  onTap: _handleNext,
                  child: Container(
                    width: 287,
                    height: 64,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(63)),
                    ),
                    child: const Center(
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Color(0xFF0796DE),
                          fontSize: 32,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, {bool mustAllow = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadows: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF0796DE), size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0796DE),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecorativeCircles() {
    return [
      AnimatedBuilder(
          animation: _floatAnimation1,
          builder: (c, _) {
            final o = _floatAnimation1.value;
            return Positioned(
                left: 124.48 + o.dx,
                top: 5.38 + o.dy,
                child: Transform.rotate(
                    angle: 0.53,
                    child: Container(
                        width: 183,
                        height: 183,
                        decoration: const ShapeDecoration(
                            shape: OvalBorder(
                                side: BorderSide(
                                    width: 30, color: Color(0xFF10A2EA)))))));
          }),
      AnimatedBuilder(
          animation: _floatAnimation2,
          builder: (c, _) {
            final o = _floatAnimation2.value;
            return Positioned(
                left: 112.01 + o.dx,
                top: 104.44 + o.dy,
                child: Opacity(
                    opacity: 0.30,
                    child: Transform.rotate(
                        angle: 3.03,
                        child: Container(
                            width: 153.81,
                            height: 153.81,
                            decoration: const ShapeDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment(0.93, 0.35),
                                    end: Alignment(0.06, 0.40),
                                    colors: [
                                      Color(0xAFFDEDCA),
                                      Color(0xFF0A9BE2)
                                    ]),
                                shape: OvalBorder())))));
          }),
      AnimatedBuilder(
          animation: _floatAnimation3,
          builder: (c, _) {
            final o = _floatAnimation3.value;
            return Positioned(
                left: 14.30 + o.dx,
                top: -19.87 + o.dy,
                child: Opacity(
                    opacity: 0.30,
                    child: Transform.rotate(
                        angle: 0.57,
                        child: Container(
                            width: 89.35,
                            height: 89.35,
                            decoration: const ShapeDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment(0.93, 0.35),
                                    end: Alignment(0.06, 0.40),
                                    colors: [
                                      Color(0xFFFDEDCA),
                                      Color(0xFF0A9BE2)
                                    ]),
                                shape: OvalBorder())))));
          }),
      AnimatedBuilder(
          animation: _floatAnimation4,
          builder: (c, _) {
            final o = _floatAnimation4.value;
            return Positioned(
                left: 92.99 + o.dx,
                top: 216.82 + o.dy,
                child: Opacity(
                    opacity: 0.30,
                    child: Transform.rotate(
                        angle: 3.03,
                        child: Container(
                            width: 94.08,
                            height: 94.08,
                            decoration: const ShapeDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment(0.93, 0.35),
                                    end: Alignment(0.06, 0.40),
                                    colors: [
                                      Color(0xAFFDEDCA),
                                      Color(0xFF0A9BE2)
                                    ]),
                                shape: OvalBorder())))));
          }),
      Positioned(
          left: 292.47,
          top: -117,
          child: Transform.rotate(
              angle: 0.40,
              child: Container(
                  width: 167,
                  height: 167,
                  decoration: const ShapeDecoration(
                      shape: OvalBorder(
                          side: BorderSide(
                              width: 30, color: Color(0xFF10A2EA))))))),
      Positioned(
          left: 69.13,
          top: 469.42,
          child: Transform.rotate(
              angle: 3.54,
              child: Container(
                  width: 167,
                  height: 167,
                  decoration: const ShapeDecoration(
                      shape: OvalBorder(
                          side: BorderSide(
                              width: 30, color: Color(0xFF10A2EA))))))),
      Positioned(
          left: 366.60,
          top: 719.60,
          child: Container(
              width: 183,
              height: 183,
              decoration: const ShapeDecoration(
                  shape: OvalBorder(
                      side: BorderSide(width: 30, color: Color(0xFF10A2EA)))))),
      Positioned(
          left: 273.59,
          top: 522.74,
          child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                  angle: 6.17,
                  child: Container(
                      width: 153.81,
                      height: 153.81,
                      decoration: const ShapeDecoration(
                          gradient: LinearGradient(
                              begin: Alignment(0.93, 0.35),
                              end: Alignment(0.06, 0.40),
                              colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]),
                          shape: OvalBorder()))))),
    ];
  }
}
