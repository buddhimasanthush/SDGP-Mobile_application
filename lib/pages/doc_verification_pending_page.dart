import 'package:flutter/material.dart';

class DocVerificationPendingPage extends StatelessWidget {
  const DocVerificationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Submitted Documents',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFAFAFA),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Spacer(),

                // White card with content
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 21),
                  width: 333,
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pending icon with document and warning symbol
                      SizedBox(
                        width: 132,
                        height: 132,
                        child: Stack(
                          children: [
                            // Outer circle
                            Container(
                              width: 132,
                              height: 132,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE4EAFB),
                                border: Border.all(
                                  width: 5,
                                  color: const Color(0xFFBADDE9),
                                ),
                              ),
                            ),
                            // Document illustration (simplified)
                            Positioned(
                              left: 40,
                              top: 30,
                              child: Container(
                                width: 52,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            // Orange warning circle
                            Positioned(
                              left: 44,
                              top: 83,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFEFA83E),
                                      Color(0xFFF89A7D)
                                    ],
                                  ),
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.access_time,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Pending message
                      const Text(
                        'Your submitted documents are currently under review.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontSize: 22,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Subtitle
                      const Text(
                        'Our team is verifying your registration details.\nYou will be notified once the review process\nis completed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF495565),
                          fontSize: 12,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            // Go back to home
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0796DE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0796DE),
      child: Stack(
        children: [
          Positioned(
            left: 37,
            top: -99,
            child: Container(
              width: 183,
              height: 183,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 30, color: const Color(0xFF10A2EA)),
              ),
            ),
          ),
          Positioned(
            left: 130.01,
            top: 197.85,
            child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                angle: 3.03,
                child: Container(
                  width: 153.81,
                  height: 153.81,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: const Alignment(0.93, 0.35),
                      end: const Alignment(0.06, 0.40),
                      colors: [
                        const Color(0xAFFDEDCA),
                        const Color(0xFF0A9BE2)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 32.30,
            top: 63,
            child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                angle: 0.57,
                child: Container(
                  width: 89.35,
                  height: 89.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: const Alignment(0.93, 0.35),
                      end: const Alignment(0.06, 0.40),
                      colors: [
                        const Color(0xFFFDEDCA),
                        const Color(0xFF0A9BE2)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 110.98,
            top: 32.77,
            child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                angle: 3.03,
                child: Container(
                  width: 94.08,
                  height: 94.08,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: const Alignment(0.93, 0.35),
                      end: const Alignment(0.06, 0.40),
                      colors: [
                        const Color(0xAFFDEDCA),
                        const Color(0xFF0A9BE2)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 310.47,
            top: 65.17,
            child: Transform.rotate(
              angle: 0.40,
              child: Container(
                width: 167,
                height: 167,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 30, color: const Color(0xFF10A2EA)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
