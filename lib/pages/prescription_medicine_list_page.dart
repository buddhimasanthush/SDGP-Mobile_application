import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ── Data model ────────────────────────────────────────────────────────────────
enum MedicineType { capsule, tablet, syrup, vitamin }

class Medicine {
  final String name;
  final MedicineType type;
  final String instruction;
  final String quantity;
  const Medicine(
      {required this.name,
      required this.type,
      required this.instruction,
      required this.quantity});
}

// ── Demo list — replace with OCR output later ─────────────────────────────────
const List<Medicine> _demoMedicines = [
  Medicine(
      name: 'Amoxicillin 500 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – 3 times daily after meals',
      quantity: 'Qty: 21 capsules (7 days)'),
  Medicine(
      name: 'Doxycycline 100 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – twice daily',
      quantity: 'Qty: 14 capsules'),
  Medicine(
      name: 'Omeprazole 20 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – before breakfast',
      quantity: 'Qty: 14 capsules'),
  Medicine(
      name: 'Cephalexin 500 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – every 8 hours',
      quantity: 'Qty: 21 capsules'),
  Medicine(
      name: 'Fluconazole 150 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – once daily',
      quantity: 'Qty: 3 capsules'),
  Medicine(
      name: 'Gabapentin 300 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – at night',
      quantity: 'Qty: 10 capsules'),
  Medicine(
      name: 'Clindamycin 300 mg capsule',
      type: MedicineType.capsule,
      instruction: 'Take 1 capsule – 3 times daily',
      quantity: 'Qty: 15 capsules'),
  Medicine(
      name: 'Paracetamol 500 mg tablet',
      type: MedicineType.tablet,
      instruction: 'Take 1–2 tablets every 6 hours if needed',
      quantity: 'Qty: 10 tablets'),
  Medicine(
      name: 'Ibuprofen 400 mg tablet',
      type: MedicineType.tablet,
      instruction: 'Take 1 tablet – twice daily after meals',
      quantity: 'Qty: 10 tablets'),
  Medicine(
      name: 'Metformin 500 mg tablet',
      type: MedicineType.tablet,
      instruction: 'Take 1 tablet – twice daily with meals',
      quantity: 'Qty: 20 tablets'),
  Medicine(
      name: 'Amoxicillin Oral Suspension 125 mg/5 ml',
      type: MedicineType.syrup,
      instruction: 'Take 5 ml – three times daily. Bottle: 60 ml',
      quantity: 'Duration: 5 days'),
  Medicine(
      name: 'Vitamin C 500 mg tablet',
      type: MedicineType.vitamin,
      instruction: 'Take 1 tablet daily after breakfast',
      quantity: 'Qty: 15 tablets'),
];

// ── Page (StatefulWidget for animations) ─────────────────────────────────────
class PrescriptionMedicineListPage extends StatefulWidget {
  final List<Medicine>? medicines;
  const PrescriptionMedicineListPage({super.key, this.medicines});
  @override
  State<PrescriptionMedicineListPage> createState() =>
      _PrescriptionMedicineListPageState();
}

class _PrescriptionMedicineListPageState
    extends State<PrescriptionMedicineListPage> with TickerProviderStateMixin {
  late final List<AnimationController> _sweepControllers;
  static const _pillCount = 4;

  List<Medicine> get _list => widget.medicines ?? _demoMedicines;
  int _count(MedicineType t) => _list.where((m) => m.type == t).length;

  @override
  void initState() {
    super.initState();
    _sweepControllers = List.generate(
      _pillCount,
      (i) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1200)),
    );
    // Stagger start: each pill animates 200ms after previous
    for (int i = 0; i < _pillCount; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _sweepControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _sweepControllers) c.dispose();
    super.dispose();
  }

  // Icon data per type: (svgPath, fallback icon)
  static const _iconAssets = [
    'assets/icons/Group 24.svg', // capsules
    'assets/icons/Icon (1).svg', // tablets
    'assets/icons/Group 25.svg', // syrups
    'assets/icons/Icon copy.svg', // vitamines
  ];
  static const _fallbackIcons = [
    Icons.medication_rounded,
    Icons.tablet_rounded,
    Icons.local_drink_rounded,
    Icons.health_and_safety_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final capsules =
        _list.where((m) => m.type == MedicineType.capsule).toList();
    final tablets = _list.where((m) => m.type == MedicineType.tablet).toList();
    final syrups = _list.where((m) => m.type == MedicineType.syrup).toList();
    final vitamins =
        _list.where((m) => m.type == MedicineType.vitamin).toList();
    final counts = [
      _count(MedicineType.capsule),
      _count(MedicineType.tablet),
      _count(MedicineType.syrup),
      _count(MedicineType.vitamin)
    ];
    final labels = ['capsules', 'tablets', 'syrups', 'vitamines'];

    return Scaffold(
      // White body — no blue bleed
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // ── Blue header (fixed, not scrollable) ──────────────────
          Container(
            color: const Color(0xFF0796DE),
            child: Stack(
              children: [
                // Decorative rings
                Positioned(
                  left: 37,
                  top: -60,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 20, color: const Color(0xFF10A2EA))),
                  ),
                ),
                Positioned(
                  right: -20,
                  top: 10,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 20, color: const Color(0xFF10A2EA))),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Column(children: [
                            SizedBox(height: 4),
                            Text('List of Medicine',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFFFAFAFA),
                                    fontSize: 20,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700)),
                            SizedBox(height: 6),
                            Text(
                                "We've scanned the prescription that you've\nuploaded and list down the medicines",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFFA2E0FF),
                                    fontSize: 10,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    height: 1.5)),
                          ]),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── White card (fills rest of screen) ────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              // Negative margin to overlap the blue header
              transform: Matrix4.translationValues(0, -20, 0),
              child: Column(
                children: [
                  // Drag handle
                  Center(
                      child: Container(
                    margin: const EdgeInsets.only(top: 14, bottom: 4),
                    width: 36,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEFEE),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  )),

                  // ── Animated summary pills ──────────────────────
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                          _pillCount,
                          (i) => _AnimatedSummaryPill(
                                controller: _sweepControllers[i],
                                count: counts[i],
                                label: labels[i],
                                svgPath: _iconAssets[i],
                                fallbackIcon: _fallbackIcons[i],
                              )),
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // ── Scrollable medicine list ──────────────────
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      children: [
                        if (capsules.isNotEmpty) ...[
                          _sectionHeader('Capsules'),
                          ...capsules.map((m) => _MedicineCard(medicine: m))
                        ],
                        if (tablets.isNotEmpty) ...[
                          _sectionHeader('Tablets'),
                          ...tablets.map((m) => _MedicineCard(medicine: m))
                        ],
                        if (syrups.isNotEmpty) ...[
                          _sectionHeader('Syrups'),
                          ...syrups.map((m) => _MedicineCard(medicine: m))
                        ],
                        if (vitamins.isNotEmpty) ...[
                          _sectionHeader('Vitamines'),
                          ...vitamins.map((m) => _MedicineCard(medicine: m))
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // ── Find nearby pharmacy button ───────────────
                  Container(
                    color: const Color(0xFFFAFAFA),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Nearby pharmacy search coming soon!'),
                              backgroundColor: Color(0xFF0796DE),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0796DE),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Find a nearby pharmacy to purchase',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        child: Text(title,
            style: const TextStyle(
                color: Color(0xFF0796DE),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      );
}

// ── Animated summary pill — sweep arc then settle ────────────────────────────
class _AnimatedSummaryPill extends StatelessWidget {
  final AnimationController controller;
  final int count;
  final String label;
  final String svgPath;
  final IconData fallbackIcon;

  const _AnimatedSummaryPill({
    required this.controller,
    required this.count,
    required this.label,
    required this.svgPath,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Sweep from 0 → full circle, then arc fades to just the ring
    final sweepAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    return Column(
      children: [
        SizedBox(
          width: 68,
          height: 68,
          child: AnimatedBuilder(
            animation: sweepAnim,
            builder: (_, child) => CustomPaint(
              painter: _SweepRingPainter(progress: sweepAnim.value),
              child: child,
            ),
            child: Center(
              child: _IconWidget(svgPath: svgPath, fallbackIcon: fallbackIcon),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${count.toString().padLeft(2, '0')}\n$label',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF11A2EB),
            fontSize: 10,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ── Sweep ring painter ────────────────────────────────────────────────────────
class _SweepRingPainter extends CustomPainter {
  final double progress;
  _SweepRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Draw ring just outside the SVG (SVG is 56px, container is 68px → radius ~31)
    final radius = size.width / 2 - 3;
    const strokeWidth = 4.0;

    // Background ring (light blue, always visible)
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFFABE3FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth);

    // Animated sweep arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = const Color(0xFF11A2EB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_SweepRingPainter old) => old.progress != progress;
}

// ── Icon widget — SvgPicture with fallback ────────────────────────────────────
class _IconWidget extends StatelessWidget {
  final String svgPath;
  final IconData fallbackIcon;
  const _IconWidget({required this.svgPath, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgPath,
      width: 56,
      height: 56,
      fit: BoxFit.contain,
      placeholderBuilder: (_) =>
          Icon(fallbackIcon, color: const Color(0xFF11A2EB), size: 28),
    );
  }
}

// ── Individual medicine card ──────────────────────────────────────────────────
class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  const _MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicine.name,
                    style: const TextStyle(
                        color: Color(0xFF11A2EB),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(medicine.instruction,
                    style: const TextStyle(
                        color: Color(0xFF9F9EA5),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(medicine.quantity,
              style: const TextStyle(
                  color: Color(0xFF585858),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
