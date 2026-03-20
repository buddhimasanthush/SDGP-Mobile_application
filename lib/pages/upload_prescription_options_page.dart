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
    extends State<UploadPrescriptionOptionsPage>
    with SingleTickerProviderStateMixin {
  String? _selectedOption;
  final TextEditingController _otpController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showManual = false;
  final List<_Med> _meds = [_Med()];

  late AnimationController _ac;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _anim = CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _otpController.dispose();
    _scrollController.dispose();
    _ac.dispose();
    for (var m in _meds) m.dispose();
    super.dispose();
  }

  void _requireOtp(VoidCallback onSuccess) {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your doctor-issued OTP first.'),
        backgroundColor: Color(0xFF0796DE),
      ));
      return;
    }
    onSuccess();
  }

  void _toggleManual() {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your doctor-issued OTP first.'),
        backgroundColor: Color(0xFF0796DE),
      ));
      return;
    }
    setState(() {
      _showManual = !_showManual;
      if (_showManual) _selectedOption = 'manual';
    });
    _showManual ? _ac.forward() : _ac.reverse();
    if (_showManual) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut);
        }
      });
    }
  }

  void _addMed() {
    setState(() => _meds.add(_Med()));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _removeMed(int i) {
    if (_meds.length == 1) return;
    _meds[i].dispose();
    setState(() => _meds.removeAt(i));
  }

  void _onContinue() {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select an upload method'),
        backgroundColor: Color(0xFF0796DE),
      ));
      return;
    }
    if (_selectedOption == 'manual') {
      if (_meds.any((m) => m.name.text.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in all medicine names'),
          backgroundColor: Color(0xFFEF5350),
        ));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Prescription submitted successfully!'),
        backgroundColor: Color(0xFF4CAF50),
      ));
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pop(context);
      });
      return;
    }
    if (_selectedOption == 'camera') {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => PrescriptionCameraPage()));
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => PrescriptionGalleryPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0796DE),
        child: Stack(children: [
          // Background circles (unchanged)
          Positioned(
              left: 37,
              top: -99,
              child: Container(
                  width: 183,
                  height: 183,
                  decoration: const ShapeDecoration(
                      shape: OvalBorder(
                          side: BorderSide(
                              width: 30, color: Color(0xFF10A2EA)))))),
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
                          shape: OvalBorder())))),
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
                          shape: OvalBorder())))),
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
                          shape: OvalBorder())))),
          Positioned(
              left: 310.47,
              top: 65.17,
              child: Container(
                  transform: Matrix4.identity()..rotateZ(0.40),
                  width: 167,
                  height: 167,
                  decoration: const ShapeDecoration(
                      shape: OvalBorder(
                          side: BorderSide(
                              width: 30, color: Color(0xFF10A2EA)))))),

          SafeArea(
            child: Column(children: [
              // Header (unchanged)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context)),
                  const Expanded(
                      child: Column(children: [
                    Text('Upload Prescription',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFFFAFAFA),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            height: 1)),
                    SizedBox(height: 5),
                    Text(
                        'Upload your valid prescription or\nenter medicines manually',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFFA2E0FF),
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1)),
                  ])),
                  const SizedBox(width: 48),
                ]),
              ),

              // White card
              Expanded(
                child: Stack(children: [
                  // White fill to cover blue at very bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: Container(color: const Color(0xFFFAFAFA)),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25))),
                    child: SingleChildScrollView(
                      controller: _scrollController,
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
                                          borderRadius:
                                              BorderRadius.circular(2.5)))),
                              const SizedBox(height: 24),

                              // ── OTP Field (moved to TOP so it's required first) ──
                              const Text(
                                  'Prescription Authentication Code (OTP)',
                                  style: TextStyle(
                                      color: Color(0xFF2D2D2D),
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                    color: const Color(0xFFEDEDED),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x1A000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2))
                                    ]),
                                child: TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: Color(0xFF2D2D2D)),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter doctor-issued OTP...',
                                    hintStyle: TextStyle(
                                        color: Color(0xFF9E9E9E),
                                        fontFamily: 'Poppins',
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
                                      fontWeight: FontWeight.w400)),
                              const SizedBox(height: 24),

                              // ── Take Photo ──────────────────────────────────
                              _buildOptionCard(
                                icon: Icons.camera_alt_rounded,
                                label: 'Take Photo',
                                isSelected: _selectedOption == 'camera',
                                onTap: () => _requireOtp(() {
                                  setState(() => _selectedOption = 'camera');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              PrescriptionCameraPage()));
                                }),
                              ),
                              const SizedBox(height: 19),

                              // ── Upload From Gallery ─────────────────────────
                              _buildOptionCard(
                                icon: Icons.image_rounded,
                                label: 'Upload From Gallery',
                                isSelected: _selectedOption == 'gallery',
                                onTap: () => _requireOtp(() {
                                  setState(() => _selectedOption = 'gallery');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              PrescriptionGalleryPage()));
                                }),
                              ),
                              const SizedBox(height: 19),

                              // ── Enter Manually toggle ───────────────────────
                              GestureDetector(
                                onTap: _toggleManual,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: double.infinity,
                                  height: 94,
                                  decoration: ShapeDecoration(
                                    color: _showManual
                                        ? const Color(0xFFE8F6FF)
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: _showManual
                                          ? const BorderSide(
                                              color: Color(0xFF11A2EB),
                                              width: 1.5)
                                          : BorderSide.none,
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                          color: Color(0x3F000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 4))
                                    ],
                                  ),
                                  child: Row(children: [
                                    const SizedBox(width: 19),
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                          color: _showManual
                                              ? const Color(0xFF0796DE)
                                              : const Color(0xFF11A2EB),
                                          shape: BoxShape.circle),
                                      child: Icon(
                                          _showManual
                                              ? Icons.edit_note_rounded
                                              : Icons.edit_rounded,
                                          color: Colors.white,
                                          size: 27),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                          Text('Enter Medicines Manually',
                                              style: TextStyle(
                                                  color: _showManual
                                                      ? const Color(0xFF0796DE)
                                                      : const Color(0xFF2D2D2D),
                                                  fontSize: 16,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400)),
                                          const SizedBox(height: 2),
                                          const Text(
                                              'Type medicine names and dosages',
                                              style: TextStyle(
                                                  color: Color(0xFF94A3B8),
                                                  fontSize: 11,
                                                  fontFamily: 'Poppins')),
                                        ])),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 14),
                                      child: AnimatedRotation(
                                        turns: _showManual ? 0.5 : 0,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: _showManual
                                                ? const Color(0xFF0796DE)
                                                : const Color(0xFF94A3B8),
                                            size: 24),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),

                              // ── Manual entry section ────────────────────────
                              SizeTransition(
                                sizeFactor: _anim,
                                axisAlignment: -1,
                                child: FadeTransition(
                                  opacity: _anim,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                            color: const Color(0xFFE5E7EB),
                                            width: 0.83),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2))
                                        ]),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('Medicines List',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF0F172A),
                                                        fontSize: 14,
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                GestureDetector(
                                                  onTap: _addMed,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFF0796DE),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: const Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                              Icons.add_rounded,
                                                              color:
                                                                  Colors.white,
                                                              size: 16),
                                                          SizedBox(width: 4),
                                                          Text('Add',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                        ]),
                                                  ),
                                                ),
                                              ]),
                                          const SizedBox(height: 14),
                                          ...List.generate(
                                              _meds.length,
                                              (i) => Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 12),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            14),
                                                    decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFF8FAFC),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xFFE2E8F0))),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4),
                                                                  decoration: BoxDecoration(
                                                                      color: const Color(
                                                                              0xFF0796DE)
                                                                          .withOpacity(
                                                                              0.1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20)),
                                                                  child: Text(
                                                                      'Medicine ${i + 1}',
                                                                      style: const TextStyle(
                                                                          color: Color(
                                                                              0xFF0796DE),
                                                                          fontSize:
                                                                              11,
                                                                          fontFamily:
                                                                              'Poppins',
                                                                          fontWeight:
                                                                              FontWeight.w600)),
                                                                ),
                                                                if (_meds
                                                                        .length >
                                                                    1)
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        _removeMed(
                                                                            i),
                                                                    child:
                                                                        Container(
                                                                      width: 28,
                                                                      height:
                                                                          28,
                                                                      decoration: BoxDecoration(
                                                                          color: const Color(0xFFEF5350).withOpacity(
                                                                              0.1),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8)),
                                                                      child: const Icon(
                                                                          Icons
                                                                              .remove_rounded,
                                                                          color: Color(
                                                                              0xFFEF5350),
                                                                          size:
                                                                              16),
                                                                    ),
                                                                  ),
                                                              ]),
                                                          const SizedBox(
                                                              height: 10),
                                                          _lbl(
                                                              'Medicine Name *'),
                                                          const SizedBox(
                                                              height: 5),
                                                          _tf(
                                                              _meds[i].name,
                                                              'e.g. Paracetamol 500mg',
                                                              Icons
                                                                  .medication_rounded),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(children: [
                                                            Expanded(
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                  _lbl(
                                                                      'Dosage'),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  _tf(
                                                                      _meds[i]
                                                                          .dosage,
                                                                      'e.g. 2x daily',
                                                                      Icons
                                                                          .access_time_rounded),
                                                                ])),
                                                            const SizedBox(
                                                                width: 10),
                                                            Expanded(
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                  _lbl(
                                                                      'Quantity'),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  _tf(
                                                                      _meds[i]
                                                                          .qty,
                                                                      'e.g. 10',
                                                                      Icons
                                                                          .numbers_rounded,
                                                                      num:
                                                                          true),
                                                                ])),
                                                          ]),
                                                        ]),
                                                  )),
                                        ]),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // ── Guidelines ──────────────────────────────────
                              const Text('Important Guidelines',
                                  style: TextStyle(
                                      color: Color(0xFF2D2D2D),
                                      fontSize: 14,
                                      fontFamily: 'Arimo',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43)),
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

                              // ── Privacy ─────────────────────────────────────
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(13),
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            width: 0.83,
                                            color: Color(0x3310A1EB)),
                                        borderRadius:
                                            BorderRadius.circular(14))),
                                child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('🔒 Privacy Protected:',
                                          style: TextStyle(
                                              color: Color(0xFF11A2EB),
                                              fontSize: 12,
                                              fontFamily: 'Arimo',
                                              fontWeight: FontWeight.w400,
                                              height: 1.33)),
                                      SizedBox(height: 4),
                                      Text(
                                          'Your prescription data is encrypted and securely stored.',
                                          style: TextStyle(
                                              color: Color(0xFF354152),
                                              fontSize: 12,
                                              fontFamily: 'Arimo',
                                              fontWeight: FontWeight.w400,
                                              height: 1.33)),
                                    ]),
                              ),
                              const SizedBox(height: 24),

                              // ── Continue ────────────────────────────────────
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _onContinue,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0796DE),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  child: const Text('Continue',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          height: 1)),
                                ),
                              ),
                              const SizedBox(height: 22),

                              Center(
                                  child: Column(children: [
                                const Text('Need help uploading?',
                                    style: TextStyle(
                                        color: Color(0xFF697282),
                                        fontSize: 12,
                                        fontFamily: 'Arimo',
                                        fontWeight: FontWeight.w400,
                                        height: 1.33)),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text('Contact Support',
                                      style: TextStyle(
                                          color: Color(0xFF11A2EB),
                                          fontSize: 12,
                                          fontFamily: 'Arimo',
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFF11A2EB))),
                                ),
                              ])),
                              const SizedBox(height: 30),
                            ]),
                      ),
                    ),
                  ),
                ]), // closes Stack
              ),
            ]),
          ),
        ]),
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
                color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))
          ],
        ),
        child: Row(children: [
          const SizedBox(width: 19),
          Container(
            width: 55.99,
            height: 55.99,
            decoration: const ShapeDecoration(
                color: Color(0xFF11A2EB), shape: OvalBorder()),
            child: Icon(icon, color: Colors.white, size: 27),
          ),
          const SizedBox(width: 20),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontSize: 16,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.50)),
        ]),
      ),
    );
  }

  Widget _buildGuideline(String text) {
    return Padding(
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

  Widget _lbl(String t) => Text(t,
      style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 11,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500));

  Widget _tf(TextEditingController c, String hint, IconData icon,
      {bool num = false}) {
    return TextField(
      controller: c,
      keyboardType: num ? TextInputType.number : TextInputType.text,
      style: const TextStyle(
          color: Color(0xFF0F172A), fontSize: 13, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'Poppins'),
        prefixIcon: Icon(icon, color: const Color(0xFF0796DE), size: 18),
        prefixIconConstraints: const BoxConstraints(minWidth: 36),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0796DE), width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      ),
    );
  }
}

class _Med {
  final name = TextEditingController();
  final dosage = TextEditingController();
  final qty = TextEditingController();
  void dispose() {
    name.dispose();
    dosage.dispose();
    qty.dispose();
  }
}
