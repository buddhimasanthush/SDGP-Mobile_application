import 'package:flutter/material.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  void _showUnderDevelopmentDialog() {
    Navigator.pushNamed(context, '/add_medicine_name');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Color(0xFF0796DE)),
        child: Stack(
          children: [
            // All decorative circles from Figma
            ..._buildDecorativeCircles(),

            // Gradient overlay at bottom - SMOOTHER & DARKER
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

            // Creatine card (top, partially off-screen) - ROTATED
            Positioned(
              left: -60.66,
              top: 41.61,
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

            // Drink Water card - ROTATED
            Positioned(
              left: 146.82,
              top: 122,
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

            // Probiotics card - ROTATED
            Positioned(
              left: 13,
              top: 247.59,
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

            // Birth Control card - ROTATED
            Positioned(
              left: 64.02,
              top: 330,
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

            // MediFind logo - CENTERED & LOWER
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

            // Add Reminder button - CENTERED & LOWER
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0xFF052F84),
            blurRadius: 48,
            offset: Offset(0, 2),
            spreadRadius: 0,
          )
        ],
      ),
      child: Stack(
        children: [
          // Frequency
          Positioned(
            left: 23,
            top: frequencyHighlight != null ? 11 : 16,
            child: frequencyHighlight != null
                ? Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: frequency,
                          style: const TextStyle(
                            color: Color(0xFF9F9EA5),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                        TextSpan(
                          text: frequencyHighlight,
                          style: const TextStyle(
                            color: Color(0xFF11A2EB),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    frequency,
                    style: const TextStyle(
                      color: Color(0xFF9F9EA5),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
          ),

          // Title
          Positioned(
            left: 23,
            top: frequencyHighlight != null ? 38 : 33,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF11A2EB),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),

          // Time pills
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

          // Badge (top right)
          Positioned(
            right: 21,
            top: 16,
            child: badge,
          ),
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
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'O ',
              style: TextStyle(
                color: Color(0xFF0091DB),
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
            Text(
              'Done',
              style: TextStyle(
                color: Color(0xFF0091DB),
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0xFF11A2EB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            '✓ ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
          Text(
            '8.05',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkippedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0xFF11A2EB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: const Text(
        'Skipped',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTimePill(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0xFF5FB6D7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: Text(
        time,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
        ),
      ),
    );
  }

  List<Widget> _buildDecorativeCircles() {
    return [
      Positioned(
        left: 124.48,
        top: 5.38,
        child: Transform.rotate(
          angle: 0.53,
          child: Container(
            width: 183,
            height: 183,
            decoration: const ShapeDecoration(
              shape: OvalBorder(
                side: BorderSide(width: 30, color: Color(0xFF10A2EA)),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 112.01,
        top: 104.44,
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
                  colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 14.30,
        top: -19.87,
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
                  colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 92.99,
        top: 216.82,
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
                  colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
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
                side: BorderSide(width: 30, color: Color(0xFF10A2EA)),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 366.60,
        top: 919.60,
        child: Container(
          width: 183,
          height: 183,
          decoration: const ShapeDecoration(
            shape: OvalBorder(
              side: BorderSide(width: 30, color: Color(0xFF10A2EA)),
            ),
          ),
        ),
      ),
      Positioned(
        left: 273.59,
        top: 622.74,
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
                  colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 371.30,
        top: 757.60,
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
                  colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 292.61,
        top: 787.82,
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
                  colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 93.13,
        top: 755.42,
        child: Transform.rotate(
          angle: 3.54,
          child: Container(
            width: 167,
            height: 167,
            decoration: const ShapeDecoration(
              shape: OvalBorder(
                side: BorderSide(width: 30, color: Color(0xFF10A2EA)),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 249.59,
        top: 336.74,
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
                  colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 371.17,
        top: 421.47,
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
                  colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 209,
        top: 505.49,
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
                  colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
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
                side: BorderSide(width: 30, color: Color(0xFF10A2EA)),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 490,
        top: 284,
        child: Transform.rotate(
          angle: 3.14,
          child: Container(
            width: 183,
            height: 183,
            decoration: const ShapeDecoration(
              shape: OvalBorder(
                side: BorderSide(width: 30, color: Color(0xFF10A2EA)),
              ),
            ),
          ),
        ),
      ),
    ];
  }
}
