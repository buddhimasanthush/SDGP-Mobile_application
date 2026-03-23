import 'package:flutter/material.dart';
import 'prescription_camera_page.dart';
import 'prescription_gallery_page.dart';

class UploadPrescriptionOptionsPage extends StatefulWidget {
  const UploadPrescriptionOptionsPage({super.key});

  @override
  State<UploadPrescriptionOptionsPage> createState() =>
      _UploadPrescriptionOptionsPageState();
}

class _UploadPrescriptionOptionsPageState
    extends State<UploadPrescriptionOptionsPage> {
  String? _selectedOption;
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0796DE),
        child: Stack(
          children: [
            // Background circles
            Positioned(
              left: 37,
              top: -99,
              child: Container(
                width: 183,
                height: 183,
                decoration: const ShapeDecoration(
                  shape: OvalBorder(
                      side: BorderSide(width: 30, color: Color(0xFF10A2EA))),
                ),
              ),
            ),
            Positioned(
              left: 130.01,
              top: 197.85,
              child: Opacity(
                opacity: 0.30,
                child: Container(
                  transform: Matrix4.identity()..rotateZ(3.03),
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
            Positioned(
              left: 32.30,
              top: 63,
              child: Opacity(
                opacity: 0.30,
                child: Container(
                  transform: Matrix4.identity()..rotateZ(0.57),
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
            Positioned(
              left: 110.98,
              top: 32.77,
              child: Opacity(
                opacity: 0.30,
                child: Container(
                  transform: Matrix4.identity()..rotateZ(3.03),
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
            Positioned(
              left: 310.47,
              top: 65.17,
              child: Container(
                transform: Matrix4.identity()..rotateZ(0.40),
                width: 167,
                height: 167,
                decoration: const ShapeDecoration(
                  shape: OvalBorder(
                      side: BorderSide(width: 30, color: Color(0xFF10A2EA))),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
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
                                  height: 1,
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
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // White card
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 19),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Drag handle
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 14),
                                  width: 36,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECEFEE),
                                    borderRadius: BorderRadius.circular(2.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Take Photo card
                              _buildOptionCard(
                                icon: Icons.camera_alt_rounded,
                                label: 'Take Photo',
                                isSelected: _selectedOption == 'camera',
                                onTap: () {
                                  if (_otpController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please enter your doctor-issued OTP first.'),
                                        backgroundColor: Color(0xFF0796DE),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => _selectedOption = 'camera');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PrescriptionCameraPage()),
                                  );
                                },
                              ),
                              const SizedBox(height: 19),

                              // Upload From Gallery card
                              _buildOptionCard(
                                icon: Icons.image_rounded,
                                label: 'Upload From Gallery',
                                isSelected: _selectedOption == 'gallery',
                                onTap: () {
                                  if (_otpController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please enter your doctor-issued OTP first.'),
                                        backgroundColor: Color(0xFF0796DE),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => _selectedOption = 'gallery');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PrescriptionGalleryPage()),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // OTP Field
                              const Text(
                                'Prescription Authentication Code (OTP)',
                                style: TextStyle(
                                  color: Color(0xFF2D2D2D),
                                  fontSize: 13,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDEDED),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color(0x1A000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2)),
                                  ],
                                ),
                                child: TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                      fontFamily: 'Arimo',
                                      fontSize: 14,
                                      color: Color(0xFF2D2D2D)),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter doctor-issued OTP...',
                                    hintStyle: TextStyle(
                                        color: Color(0xFF9E9E9E),
                                        fontFamily: 'Arimo',
                                        fontSize: 13),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'This code is provided by your doctor to verify authenticity.',
                                style: TextStyle(
                                  color: Color(0xFF697282),
                                  fontSize: 11,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              const SizedBox(height: 28),

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
                                  "Doctor's signature and stamp must be visible"),
                              _buildGuideline(
                                  'Patient name and date should be clearly visible'),

                              const SizedBox(height: 20),

                              // Privacy Protected box
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(13),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 0.83, color: Color(0x3310A1EB)),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
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
                                    SizedBox(height: 4),
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

                              const SizedBox(height: 24),

                              // Continue Button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_selectedOption == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please select Take Photo or Upload From Gallery'),
                                          backgroundColor: Color(0xFF0796DE),
                                        ),
                                      );
                                      return;
                                    }
                                    if (_selectedOption == 'camera') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrescriptionCameraPage()),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrescriptionGalleryPage()),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0796DE),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),
                              Center(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Need help uploading?',
                                      style: TextStyle(
                                        color: Color(0xFF697282),
                                        fontSize: 12,
                                        fontFamily: 'Arimo',
                                        fontWeight: FontWeight.w400,
                                        height: 1.33,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {},
                                      child: const Text(
                                        'Contact Support',
                                        style: TextStyle(
                                          color: Color(0xFF11A2EB),
                                          fontSize: 12,
                                          fontFamily: 'Arimo',
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFF11A2EB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
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
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        height: 94,
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFE8F6FF) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isSelected
                ? const BorderSide(color: Color(0xFF11A2EB), width: 1.5)
                : BorderSide.none,
          ),
          shadows: const [
            BoxShadow(
                color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 19),
            Container(
              width: 55.99,
              height: 55.99,
              decoration: const ShapeDecoration(
                  color: Color(0xFF11A2EB), shape: OvalBorder()),
              child: Icon(icon, color: Colors.white, size: 27),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
                color: Color(0xFF11A2EB),
                fontSize: 12,
                fontFamily: 'Arimo',
                height: 1.33),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: Color(0xFF495565),
                  fontSize: 12,
                  fontFamily: 'Arimo',
                  height: 1.33),
            ),
          ),
        ],
      ),
    );
  }
}
