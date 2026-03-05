import 'package:flutter/material.dart';
import 'pharmacy_details_form_page.dart';

class PharmacyRegistrationPage extends StatelessWidget {
  const PharmacyRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with decorative circles (same as home page)
          _buildBackground(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Pharmacy Registration',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFAFAFA),
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Register your pharmacy to the system',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFA2E0FF),
                                fontSize: 10,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),

                const Spacer(),

                // White card with logo and button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 33),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(25),
                    ),
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
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // MediFind Logo
                        Container(
                          width: 326,
                          height: 200,
                          padding: const EdgeInsets.all(30),
                          child: Image.asset(
                            'assets/images/Medifind_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if logo file not found
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_pharmacy,
                                    size: 70,
                                    color: const Color(0xFF0796DE),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'MediFind',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0796DE),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Description text
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          child: Text(
                            'Here\'s The portal for register your pharmacy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF2D2D2D),
                              fontSize: 20,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Register Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PharmacyDetailsFormPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0796DE),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Register',
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
                        ),

                        const SizedBox(height: 35),
                      ],
                    ),
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
          // Top left circle
          Positioned(
            left: 37,
            top: -99,
            child: Container(
              width: 183,
              height: 183,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 30,
                  color: const Color(0xFF10A2EA),
                ),
              ),
            ),
          ),
          // Middle gradient circle
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
          // Top left small circle
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
          // Top middle circle
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
          // Top right border circle
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
                  border: Border.all(
                    width: 30,
                    color: const Color(0xFF10A2EA),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
