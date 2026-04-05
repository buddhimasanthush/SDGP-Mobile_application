import 'package:flutter/material.dart';
import 'camera_capture_page.dart';
import 'gallery_picker_page.dart';

class UploadPrescriptionPage extends StatefulWidget {
  const UploadPrescriptionPage({super.key});

  @override
  State<UploadPrescriptionPage> createState() => _UploadPrescriptionPageState();
}

class _UploadPrescriptionPageState extends State<UploadPrescriptionPage> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            children: [
              // Header with SafeArea
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Upload Prescription',
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
                              'Upload your valid prescription or\nenter medicines manually',
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
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // White content area - SCROLLABLE
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 36,
                            height: 9,
                            decoration: BoxDecoration(
                              color: const Color(0xFFECEFEE),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Take Photo option
                        _buildOptionCard(
                          icon: Icons.camera_alt,
                          label: 'Take Photo',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CameraCapturePage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 15),

                        // Upload From Gallery option
                        _buildOptionCard(
                          icon: Icons.image,
                          label: 'Upload From Gallery',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GalleryPickerPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // OTP Section
                        const Text(
                          'Prescription Authentication Code (OTP)',
                          style: TextStyle(
                            color: Color(0xFF2D2D2D),
                            fontSize: 14,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // OTP Input Field
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0x33F9FAFB),
                            border: Border.all(
                              width: 0.83,
                              color: const Color(0xFFE5E7EB),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _otpController,
                            decoration: const InputDecoration(
                              hintText: 'Enter doctor-issued OTP…',
                              hintStyle: TextStyle(
                                color: Color(0x7F0A0A0A),
                                fontSize: 14,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'This code is provided by your doctor to verify authenticity.',
                          style: TextStyle(
                            color: Color(0xFF697282),
                            fontSize: 12,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Important Guidelines
                        const Text(
                          'Important Guidelines',
                          style: TextStyle(
                            color: Color(0xFF2D2D2D),
                            fontSize: 14,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),

                        const SizedBox(height: 10),

                        _buildGuideline(
                            'Ensure prescription is clear and readable'),
                        _buildGuideline(
                            'Prescription must be issued within the last 6 months'),
                        _buildGuideline(
                            'Doctor signature and stamp must be visible'),
                        _buildGuideline(
                            'Patient name and date should be clearly visible'),

                        const SizedBox(height: 25),

                        // Privacy Protected Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            border: Border.all(
                              width: 0.83,
                              color: const Color(0x3310A1EB),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🔒 Privacy Protected:',
                                style: TextStyle(
                                  color: Color(0xFF11A2EB),
                                  fontSize: 12,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.33,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Your prescription data is encrypted and securely stored.',
                                style: TextStyle(
                                  color: Color(0xFF354152),
                                  fontSize: 12,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.33,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle continue action
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Prescription uploaded successfully!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0796DE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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

                        const SizedBox(height: 20),

                        // Need help section
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'Need help uploading?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF697282),
                                  fontSize: 12,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.33,
                                ),
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Contact support at: support@medifind.com')),
                                  );
                                },
                                child: const Text(
                                  'Contact Support',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF11A2EB),
                                    fontSize: 12,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                    height: 1.33,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFF11A2EB),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Color(0xFF11A2EB),
              fontSize: 12,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF495565),
                fontSize: 12,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
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
