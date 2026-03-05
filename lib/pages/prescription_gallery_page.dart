import 'package:flutter/material.dart';
import 'prescription_medicine_list_page.dart';

class PrescriptionGalleryPage extends StatelessWidget {
  const PrescriptionGalleryPage({super.key});

  void _onBrowseTapped(BuildContext context) {
    _showDialog(context, 'Uploading prescription...', 'Please wait a moment',
        () {
      _showDialog(context, 'MediFind AI is scanning\nyour prescription...',
          'Extracting medicine details', () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const PrescriptionMedicineListPage()),
        );
      });
    });
  }

  void _showDialog(BuildContext context, String title, String subtitle,
      VoidCallback onDone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => Material(
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
        color: const Color(0xFF0796DE),
        child: Stack(
          children: [
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
                        colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]),
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
                        colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)]),
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
                        colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]),
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
                          child: Column(children: [
                            Text('Select Image',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFFFAFAFA),
                                    fontSize: 20,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    height: 1)),
                            SizedBox(height: 6),
                            Text('Upload your valid prescription',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFFA2E0FF),
                                    fontSize: 10,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    height: 1)),
                          ]),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 19),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: Container(
                                margin: const EdgeInsets.only(top: 14),
                                width: 36,
                                height: 9,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFECEFEE),
                                    borderRadius: BorderRadius.circular(2.5)),
                              )),
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () => _onBrowseTapped(context),
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
                                          Color(0xFFF5FBFF)
                                        ]),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: const Color(0xFF11A2EB),
                                        width: 1.0),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x1A000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 4))
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: const ShapeDecoration(
                                            color: Color(0xFF11A2EB),
                                            shape: OvalBorder()),
                                        child: const Icon(Icons.image_rounded,
                                            color: Colors.white, size: 28),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text('Tap to browse',
                                          style: TextStyle(
                                              color: Color(0xFF2D2D2D),
                                              fontSize: 16,
                                              fontFamily: 'Arimo',
                                              fontWeight: FontWeight.w400,
                                              height: 1.50)),
                                      const SizedBox(height: 6),
                                      const Text(
                                          'Select a prescription image from your gallery',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xFF697282),
                                              fontSize: 12,
                                              fontFamily: 'Arimo',
                                              fontWeight: FontWeight.w400,
                                              height: 1.33)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                              const Text('Image Requirements',
                                  style: TextStyle(
                                      color: Color(0xFF2D2D2D),
                                      fontSize: 14,
                                      fontFamily: 'Arimo',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43)),
                              const SizedBox(height: 10),
                              _req(
                                  'Image should be in JPG, PNG, or PDF format'),
                              _req('Maximum file size: 10 MB'),
                              _req(
                                  'Ensure text is clearly visible and not blurred'),
                              _req(
                                  'Avoid shadows or glare on the prescription'),
                              const SizedBox(height: 40),
                              Center(
                                  child: Column(children: [
                                const Text('Need help uploading?',
                                    style: TextStyle(
                                        color: Color(0xFF697282),
                                        fontSize: 12,
                                        fontFamily: 'Arimo',
                                        height: 1.33)),
                                const SizedBox(height: 4),
                                GestureDetector(
                                    onTap: () {},
                                    child: const Text('Contact Support',
                                        style: TextStyle(
                                            color: Color(0xFF11A2EB),
                                            fontSize: 12,
                                            fontFamily: 'Arimo',
                                            height: 1.33,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                Color(0xFF11A2EB)))),
                              ])),
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

  Widget _req(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('• ',
              style: TextStyle(
                  color: Color(0xFF11A2EB),
                  fontSize: 12,
                  fontFamily: 'Arimo',
                  height: 1.33)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: Color(0xFF495565),
                      fontSize: 12,
                      fontFamily: 'Arimo',
                      height: 1.33))),
        ]),
      );
}
