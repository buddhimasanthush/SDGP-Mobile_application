import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'prescription_medicine_list_page.dart';
import '../services/api_service.dart';

class PrescriptionGalleryPage extends StatefulWidget {
  const PrescriptionGalleryPage({super.key});

  @override
  State<PrescriptionGalleryPage> createState() =>
      _PrescriptionGalleryPageState();
}

class _PrescriptionGalleryPageState extends State<PrescriptionGalleryPage> {
  final ImagePicker _picker = ImagePicker();
  bool _processing = false;

  Future<void> _onBrowseTapped(BuildContext context) async {
    if (_processing) return;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
        maxWidth: 2200,
      );
      if (image == null) return;
      await _processPrescription(File(image.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open gallery. Please try again.'),
          backgroundColor: Color(0xFF0796DE),
        ),
      );
    }
  }

  Future<void> _processPrescription(File imageFile) async {
    setState(() => _processing = true);
    _showDialog(context, 'MediFind AI is scanning\nyour prescription...',
        'Extracting medicine details');

    final result = await ApiService.uploadPrescription(imageFile);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _processing = false);

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PrescriptionMedicineListPage(
            medicines: (result['medicines'] as List<Medicine>?) ?? const [],
            rawMedications: result['rawMedications'] as List<dynamic>?,
          ),
        ),
      );
      return;
    }

    final err =
        (result['error'] ?? 'Failed to process prescription').toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err),
        backgroundColor: const Color(0xFF0796DE),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String subtitle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0796DE),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 6),
                        Text('Upload your valid prescription',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFA2E0FF),
                                fontSize: 10,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400)),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 19, vertical: 24),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _processing
                              ? null
                              : () => _onBrowseTapped(context),
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
                                  color: const Color(0xFF11A2EB), width: 1.0),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 4))
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const ShapeDecoration(
                                      color: Color(0xFF11A2EB),
                                      shape: OvalBorder()),
                                  child: _processing
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.2),
                                        )
                                      : const Icon(Icons.image_rounded,
                                          color: Colors.white, size: 28),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                    _processing
                                        ? 'Processing...'
                                        : 'Tap to browse',
                                    style: const TextStyle(
                                        color: Color(0xFF2D2D2D),
                                        fontSize: 16,
                                        fontFamily: 'Arimo',
                                        fontWeight: FontWeight.w400)),
                                const SizedBox(height: 6),
                                const Text(
                                    'Select a prescription image from your gallery',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color(0xFF697282),
                                        fontSize: 12,
                                        fontFamily: 'Arimo',
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
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
      ),
    );
  }
}
