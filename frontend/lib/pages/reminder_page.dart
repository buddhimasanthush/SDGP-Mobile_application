import 'package:flutter/material.dart';
import 'reminder_store.dart';
import 'medical_reminder_page.dart';
import 'add_medicine_name_page.dart';

// Smart entry point from bottom nav:
// - Has reminders → MedicalReminderPage (calendar)
// - No reminders → original landing page
class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  @override
  Widget build(BuildContext context) {
    if (ReminderStore.instance.hasReminders) {
      return const MedicalReminderPage();
    }
    return _ReminderLandingPage();
  }
}

// ── Animated landing page ─────────────────────────────────────────────────────
class _ReminderLandingPage extends StatefulWidget {
  @override
  State<_ReminderLandingPage> createState() => _ReminderLandingPageState();
}

class _ReminderLandingPageState extends State<_ReminderLandingPage>
    with TickerProviderStateMixin {
  late List<AnimationController> _fcs;
  late List<Animation<Offset>> _fas;

  // Card bob animations — each card floats up/down independently
  late AnimationController _cardFloat1;
  late AnimationController _cardFloat2;
  late AnimationController _cardFloat3;
  late AnimationController _cardFloat4;
  late Animation<double> _cardAnim1;
  late Animation<double> _cardAnim2;
  late Animation<double> _cardAnim3;
  late Animation<double> _cardAnim4;

  @override
  void initState() {
    super.initState();
    final durations = [3000, 4000, 5000, 3500, 4200, 5500, 3700, 4800];
    final offsets = [
      const Offset(25, -35),
      const Offset(-20, 30),
      const Offset(35, 20),
      const Offset(-25, -30),
      const Offset(20, 28),
      const Offset(-30, -22),
      const Offset(18, -25),
      const Offset(-22, 32),
    ];
    _fcs = List.generate(
        8,
        (i) => AnimationController(
              vsync: this,
              duration: Duration(milliseconds: durations[i]),
            )..repeat(reverse: true));
    _fas = List.generate(
        8,
        (i) => Tween<Offset>(begin: Offset.zero, end: offsets[i]).animate(
            CurvedAnimation(parent: _fcs[i], curve: Curves.easeInOut)));

    // Card bob animations — all start immediately but from different points
    // so they're always out of phase with each other
    _cardFloat1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..forward();
    _cardFloat2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..value = 0.4 // start 40% through the cycle
      ..forward();
    _cardFloat3 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..value = 0.7 // start 70% through the cycle
      ..forward();
    _cardFloat4 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500))
      ..value = 0.2 // start 20% through the cycle
      ..forward();

    // Repeat all in reverse once they reach the end
    _cardFloat1.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _cardFloat1.reverse();
      } else if (s == AnimationStatus.dismissed) {
        _cardFloat1.forward();
      }
    });
    _cardFloat2.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _cardFloat2.reverse();
      } else if (s == AnimationStatus.dismissed) {
        _cardFloat2.forward();
      }
    });
    _cardFloat3.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _cardFloat3.reverse();
      } else if (s == AnimationStatus.dismissed) {
        _cardFloat3.forward();
      }
    });
    _cardFloat4.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _cardFloat4.reverse();
      } else if (s == AnimationStatus.dismissed) {
        _cardFloat4.forward();
      }
    });

    _cardAnim1 = Tween<double>(begin: 0, end: -12)
        .animate(CurvedAnimation(parent: _cardFloat1, curve: Curves.easeInOut));
    _cardAnim2 = Tween<double>(begin: 0, end: -10)
        .animate(CurvedAnimation(parent: _cardFloat2, curve: Curves.easeInOut));
    _cardAnim3 = Tween<double>(begin: 0, end: -14)
        .animate(CurvedAnimation(parent: _cardFloat3, curve: Curves.easeInOut));
    _cardAnim4 = Tween<double>(begin: 0, end: -11)
        .animate(CurvedAnimation(parent: _cardFloat4, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    for (final c in _fcs) {
      c.dispose();
    }
    _cardFloat1.dispose();
    _cardFloat2.dispose();
    _cardFloat3.dispose();
    _cardFloat4.dispose();
    super.dispose();
  }

  void _showUnderDevelopmentDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicineNamePage()),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [..._fcs, _cardFloat1, _cardFloat2, _cardFloat3, _cardFloat4]),
      builder: (context, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Color(0xFF0796DE)),
        child: Stack(
          children: [
            ..._buildDecorativeCircles(),

            // Back button — top left
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom gradient overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 280,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0796DE).withValues(alpha: 0.0),
                      const Color(0xFF0796DE).withValues(alpha: 0.3),
                      const Color(0xFF0564B8).withValues(alpha: 0.7),
                      const Color(0xFF001F81),
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Creatine card
            Positioned(
              left: -60.66,
              top: 41.61 + _cardAnim1.value,
              child: Transform.rotate(
                angle: -0.02,
                child: _buildReminderCard(
                  width: 307.07,
                  frequency: 'S M T W ',
                  frequencyHighlight: 'T F S',
                  title: 'Creatine',
                  times: ['8 : 00 AM'],
                  badge: _buildDoneBadge(),
                ),
              ),
            ),

            // Drink Water card
            Positioned(
              left: 146.82,
              top: 122 + _cardAnim2.value,
              child: Transform.rotate(
                angle: 0.09,
                child: _buildReminderCard(
                  width: 337,
                  frequency: 'S M T W T F S',
                  title: 'Drink Water',
                  times: ['8 : 00 AM', '1 : 00 PM', '7 : 00 PM'],
                  badge: _buildDoneBadge(),
                ),
              ),
            ),

            // Probiotics card
            Positioned(
              left: 13,
              top: 247.59 + _cardAnim3.value,
              child: Transform.rotate(
                angle: -0.08,
                child: _buildReminderCard(
                  width: 307.07,
                  frequency: 'Every 3 days',
                  title: 'Probiotics',
                  times: ['8 : 00 AM', '9 : 00 PM'],
                  badge: _buildCheckBadge(),
                ),
              ),
            ),

            // Birth Control card
            Positioned(
              left: 64.02,
              top: 330 + _cardAnim4.value,
              child: Transform.rotate(
                angle: 0.04,
                child: _buildReminderCard(
                  width: 307.07,
                  frequency: '21+7 Days',
                  title: 'Birth Control',
                  times: ['8 : 00 AM'],
                  badge: _buildSkippedBadge(),
                ),
              ),
            ),

            // MediFind logo
            Positioned(
              left: 0,
              right: 0,
              bottom: 180,
              child: Center(
                child: Image.asset(
                  'assets/images/Medifind logo with white letterings.png',
                  width: 119,
                  height: 66,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Add Reminder button
            Positioned(
              left: 0,
              right: 0,
              bottom: 90,
              child: Center(
                child: GestureDetector(
                  onTap: _showUnderDevelopmentDialog,
                  child: Container(
                    width: 287,
                    height: 64,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(63),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Add Reminder',
                        textAlign: TextAlign.center,
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

  Widget _buildReminderCard({
    required double width,
    required String frequency,
    String? frequencyHighlight,
    required String title,
    required List<String> times,
    required Widget badge,
  }) {
    return Container(
      width: width,
      height: 96.04,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        shadows: const [
          BoxShadow(
              color: Color(0xFF052F84), blurRadius: 48, offset: Offset(0, 2))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 23,
            top: frequencyHighlight != null ? 11 : 16,
            child: frequencyHighlight != null
                ? Text.rich(TextSpan(children: [
                    TextSpan(
                        text: frequency,
                        style: const TextStyle(
                            color: Color(0xFF9F9EA5),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1)),
                    TextSpan(
                        text: frequencyHighlight,
                        style: const TextStyle(
                            color: Color(0xFF11A2EB),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1)),
                  ]))
                : Text(frequency,
                    style: const TextStyle(
                        color: Color(0xFF9F9EA5),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
          ),
          Positioned(
            left: 23,
            top: frequencyHighlight != null ? 38 : 33,
            child: Text(title,
                style: const TextStyle(
                    color: Color(0xFF11A2EB),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
          ),
          Positioned(
            left: 18,
            top: 62,
            child: Row(
              children: times
                  .map((time) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildTimePill(time),
                      ))
                  .toList(),
            ),
          ),
          Positioned(right: 21, top: 16, child: badge),
        ],
      ),
    );
  }

  Widget _buildDoneBadge() {
    return Opacity(
      opacity: 0.40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: ShapeDecoration(
            color: const Color(0xFF11A2EB),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22))),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Text('O ',
              style: TextStyle(
                  color: Color(0xFF0091DB),
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1)),
          Text('Done',
              style: TextStyle(
                  color: Color(0xFF0091DB),
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1)),
        ]),
      ),
    );
  }

  Widget _buildCheckBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
          color: const Color(0xFF11A2EB),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Text('✓ ',
            style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                letterSpacing: 1)),
        Text('8.05',
            style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                letterSpacing: 1)),
      ]),
    );
  }

  Widget _buildSkippedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
          color: const Color(0xFF11A2EB),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
      child: const Text('Skipped',
          style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              letterSpacing: 1)),
    );
  }

  Widget _buildTimePill(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
          color: const Color(0xFF5FB6D7),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
      child: Text(time,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              letterSpacing: 1)),
    );
  }

  List<Widget> _buildDecorativeCircles() {
    return [
      Positioned(
          left: 124.48 + _fas[0].value.dx,
          top: 5.38 + _fas[0].value.dy,
          child: Transform.rotate(
              angle: 0.53,
              child: Container(
                  width: 183,
                  height: 183,
                  decoration: const ShapeDecoration(
                      shape: OvalBorder(
                          side: BorderSide(
                              width: 30, color: Color(0xFF10A2EA))))))),
      Positioned(
          left: 112.01 + _fas[1].value.dx,
          top: 104.44 + _fas[1].value.dy,
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
                              colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]),
                          shape: OvalBorder()))))),
      Positioned(
          left: 14.30 + _fas[2].value.dx,
          top: -19.87 + _fas[2].value.dy,
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
                              colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)]),
                          shape: OvalBorder()))))),
      Positioned(
          left: 92.99 + _fas[3].value.dx,
          top: 216.82 + _fas[3].value.dy,
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
                              colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]),
                          shape: OvalBorder()))))),
      Positioned(
          left: 292.47 + _fas[0].value.dx,
          top: -117 + _fas[0].value.dy,
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
          left: 366.60 + _fas[4].value.dx,
          top: 919.60 + _fas[4].value.dy,
          child: Container(
              width: 183,
              height: 183,
              decoration: const ShapeDecoration(
                  shape: OvalBorder(
                      side: BorderSide(width: 30, color: Color(0xFF10A2EA)))))),
      Positioned(
          left: 273.59 + _fas[5].value.dx,
          top: 622.74 + _fas[5].value.dy,
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
      Positioned(
          left: 371.30 + _fas[6].value.dx,
          top: 757.60 + _fas[6].value.dy,
          child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                  angle: 3.71,
                  child: Container(
                      width: 89.35,
                      height: 89.35,
                      decoration: const ShapeDecoration(
                          gradient: LinearGradient(
                              begin: Alignment(0.93, 0.35),
                              end: Alignment(0.06, 0.40),
                              colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)]),
                          shape: OvalBorder()))))),
      Positioned(
          left: 292.61 + _fas[7].value.dx,
          top: 787.82 + _fas[7].value.dy,
          child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                  angle: 6.17,
                  child: Container(
                      width: 94.08,
                      height: 94.08,
                      decoration: const ShapeDecoration(
                          gradient: LinearGradient(
                              begin: Alignment(0.93, 0.35),
                              end: Alignment(0.06, 0.40),
                              colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]),
                          shape: OvalBorder()))))),
      Positioned(
          left: 93.13 + _fas[1].value.dx,
          top: 755.42 + _fas[1].value.dy,
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
          left: 249.59 + _fas[2].value.dx,
          top: 336.74 + _fas[2].value.dy,
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
      Positioned(
          left: 371.17 + _fas[3].value.dx,
          top: 421.47 + _fas[3].value.dy,
          child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                  angle: 3.71,
                  child: Container(
                      width: 89.35,
                      height: 89.35,
                      decoration: const ShapeDecoration(
                          gradient: LinearGradient(
                              begin: Alignment(0.93, 0.35),
                              end: Alignment(0.06, 0.40),
                              colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)]),
                          shape: OvalBorder()))))),
      Positioned(
          left: 209 + _fas[4].value.dx,
          top: 505.49 + _fas[4].value.dy,
          child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                  angle: 6.17,
                  child: Container(
                      width: 94.08,
                      height: 94.08,
                      decoration: const ShapeDecoration(
                          gradient: LinearGradient(
                              begin: Alignment(0.93, 0.35),
                              end: Alignment(0.06, 0.40),
                              colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]),
                          shape: OvalBorder()))))),
      Positioned(
          left: 69.13 + _fas[5].value.dx,
          top: 469.42 + _fas[5].value.dy,
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
          left: 490 + _fas[6].value.dx,
          top: 284 + _fas[6].value.dy,
          child: Transform.rotate(
              angle: 3.14,
              child: Container(
                  width: 183,
                  height: 183,
                  decoration: const ShapeDecoration(
                      shape: OvalBorder(
                          side: BorderSide(
                              width: 30, color: Color(0xFF10A2EA))))))),
    ];
  }
}
