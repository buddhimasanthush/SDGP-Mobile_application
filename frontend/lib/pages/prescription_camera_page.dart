import 'package:flutter/material.dart';
import 'prescription_medicine_list_page.dart';

class PrescriptionCameraPage extends StatefulWidget {
  const PrescriptionCameraPage({super.key});
  @override
  State<PrescriptionCameraPage> createState() => _PrescriptionCameraPageState();
}

class _PrescriptionCameraPageState extends State<PrescriptionCameraPage> {
  bool _flashOn = false;

  void _onCapture() {
    _showDialog('Uploading prescription...', 'Please wait a moment', () {
      // Step 2: AI scanning dialog
      _showDialog('MediFind AI is scanning\nyour prescription...',
          'Extracting medicine details', () {
        // Step 3: go to medicine list
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const PrescriptionMedicineListPage()),
        );
      });
    });
  }

  void _showDialog(String title, String subtitle, VoidCallback onDone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF0796DE),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 20,
                    offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFFA2E0FF),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context);
      onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, 0.00),
            end: Alignment(1.00, 1.00),
            colors: [Color(0xFF354152), Color(0xFF101727)],
          ),
        ),
        child: Stack(
          children: [
            // Top gradient
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0)
                    ],
                  ),
                ),
              ),
            ),
            // Viewfinder
            Positioned(
              left: 22,
              top: 130,
              right: 22,
              bottom: 168,
              child: Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side:
                        const BorderSide(width: 1.48, color: Color(0x66FFFEFE)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            // Pill
            Positioned(
              left: 0,
              right: 0,
              top: 100,
              child: Center(
                child: IntrinsicWidth(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: ShapeDecoration(
                      color: Colors.black.withValues(alpha: 0.70),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Align prescription within frame',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Arimo',
                            height: 1.43),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom gradient + capture button
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Container(
                height: 168,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.60),
                      Colors.black.withValues(alpha: 0)
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _onCapture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 3.70, color: Color(0xFF11A2EB)),
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                          ),
                          shadows: [
                            BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                                spreadRadius: -4),
                            BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 15,
                                offset: Offset(0, 10),
                                spreadRadius: -3),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const ShapeDecoration(
                                color: Color(0xFF11A2EB), shape: OvalBorder()),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap to capture prescription',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xCCFFFEFE),
                          fontSize: 12,
                          fontFamily: 'Arimo',
                          height: 1.33),
                    ),
                  ],
                ),
              ),
            ),
            // Top bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                child: SizedBox(
                  height: 58,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: ShapeDecoration(
                              color: Colors.black.withValues(alpha: 0.40),
                              shape: const OvalBorder()),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const Text(
                        'Take Photo',
                        style: TextStyle(
                            color: Color(0xFFFAFAFA),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            height: 1),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _flashOn = !_flashOn),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: ShapeDecoration(
                              color: Colors.black.withValues(alpha: 0.40),
                              shape: const OvalBorder()),
                          child: Icon(
                              _flashOn ? Icons.flash_on : Icons.flash_off,
                              color: _flashOn
                                  ? const Color(0xFF11A2EB)
                                  : Colors.white,
                              size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
