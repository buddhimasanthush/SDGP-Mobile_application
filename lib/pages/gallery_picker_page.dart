import 'dart:math';
import 'package:flutter/material.dart';
import 'doc_verification_success_page.dart';
import 'doc_verification_pending_page.dart';
import 'doc_verification_failed_page.dart';

class GalleryPickerPage extends StatefulWidget {
  const GalleryPickerPage({super.key});

  @override
  State<GalleryPickerPage> createState() => _GalleryPickerPageState();
}

class _GalleryPickerPageState extends State<GalleryPickerPage> {
  bool _imageSelected = false;

  void _onBrowseTapped() {
    // Simulate selecting an image
    setState(() => _imageSelected = true);

    // Show uploading dialog then navigate to verification result
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF11A2EB)),
              SizedBox(height: 16),
              Text(
                'Uploading document...',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // close dialog

      final result = Random().nextInt(3);
      Widget page;
      if (result == 0) {
        page = const DocVerificationSuccessPage();
      } else if (result == 1) {
        page = const DocVerificationPendingPage();
      } else {
        page = const DocVerificationFailedPage();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    });
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
            // ── Background decorative circles ──────────────────────────
            Positioned(
              left: 37,
              top: -99,
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
                    side: BorderSide(width: 30, color: Color(0xFF10A2EA)),
                  ),
                ),
              ),
            ),

            // ── SafeArea content ───────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // ── Header ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                'Select Image',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFFAFAFA),
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Upload your valid pharmacy registration',
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

                  // ── White card ──────────────────────────────────────
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

                              // ── Tap to browse card ──────────────────
                              GestureDetector(
                                onTap: _onBrowseTapped,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 32, horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFEBF6FF),
                                        Color(0xFFF5FBFF),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFF11A2EB),
                                      width: 1.0,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1A000000),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Blue circle icon
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: const ShapeDecoration(
                                          color: Color(0xFF11A2EB),
                                          shape: OvalBorder(),
                                        ),
                                        child: const Icon(
                                          Icons.image_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // "Tap to browse"
                                      const Text(
                                        'Tap to browse',
                                        style: TextStyle(
                                          color: Color(0xFF2D2D2D),
                                          fontSize: 16,
                                          fontFamily: 'Arimo',
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Subtitle
                                      const Text(
                                        'Select a Registration image from your gallery',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF697282),
                                          fontSize: 12,
                                          fontFamily: 'Arimo',
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 36),

                              // ── Image Requirements ──────────────────
                              const Text(
                                'Image Requirements',
                                style: TextStyle(
                                  color: Color(0xFF2D2D2D),
                                  fontSize: 14,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildRequirement(
                                  'Image should be in JPG, PNG, or PDF format'),
                              _buildRequirement('Maximum file size: 10 MB'),
                              _buildRequirement(
                                  'Ensure text is clearly visible and not blurred'),
                              _buildRequirement(
                                  'Avoid shadows or glare on the parharmacy registration'),

                              const SizedBox(height: 40),

                              // ── Need help uploading? ────────────────
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
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {},
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

  Widget _buildRequirement(String text) {
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
}
