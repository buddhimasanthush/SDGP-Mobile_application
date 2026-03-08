import 'package:flutter/material.dart';
import 'doc_verification_success_page.dart';

class GalleryPickerPage extends StatelessWidget {
  const GalleryPickerPage({super.key});

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
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Upload your valid pharmacy registration',
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

                const SizedBox(height: 10),

                // White content area
                Expanded(
                  child: Container(
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
                        padding: const EdgeInsets.all(20.0),
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

                            const SizedBox(height: 30),

                            // Tap to browse card
                            GestureDetector(
                              onTap: () {
                                // Simulate picking image, show uploading, then go to success
                                _showUploadingDialog(context);
                                Future.delayed(const Duration(seconds: 2), () {
                                  Navigator.pop(context); // Close dialog
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DocVerificationSuccessPage(),
                                    ),
                                  );
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 40),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F4FD),
                                  border: Border.all(
                                    width: 2,
                                    color: const Color(0xFF11A2EB),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    // Image icon
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF11A2EB),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.image_outlined,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Tap to browse
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

                                    const SizedBox(height: 8),

                                    // Description
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

                            const SizedBox(height: 40),

                            // Image Requirements
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

                            const SizedBox(height: 15),

                            _buildRequirement(
                                'Image should be in JPG, PNG, or PDF format'),
                            _buildRequirement('Maximum file size: 10 MB'),
                            _buildRequirement(
                                'Ensure text is clearly visible and not blurred'),
                            _buildRequirement(
                                'Avoid shadows or glare on the pharmacy registration'),

                            const SizedBox(height: 60),

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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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

                            const SizedBox(height: 20),
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
    );
  }

  Widget _buildRequirement(String text) {
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

  void _showUploadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF0796DE).withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF0796DE)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Uploading document...',
                  style: TextStyle(
                    color: Color(0xFF2D2D2D),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Please wait',
                  style: TextStyle(
                    color: Color(0xFF9F9EA5),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
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
