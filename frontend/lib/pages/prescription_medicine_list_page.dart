import 'dart:math';
import 'package:flutter/material.dart';
import 'nearby_pharmacy_page.dart';

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

// ── Demo list ─────────────────────────────────────────────────────────────────
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

// ── Page ──────────────────────────────────────────────────────────────────────
class PrescriptionMedicineListPage extends StatefulWidget {
  final List<Medicine>? medicines;
  final List<dynamic>? rawMedications;
  const PrescriptionMedicineListPage(
      {super.key, this.medicines, this.rawMedications});
  @override
  State<PrescriptionMedicineListPage> createState() =>
      _PrescriptionMedicineListPageState();
}

class _PrescriptionMedicineListPageState
    extends State<PrescriptionMedicineListPage> with TickerProviderStateMixin {
  // One controller per pill — shared with _AnimatedSummaryPill
  late final List<AnimationController> _pillControllers;
  static const _pillCount = 4;

  List<Medicine> get _list => widget.medicines ?? _demoMedicines;
  int _count(MedicineType t) => _list.where((m) => m.type == t).length;

  static const _pillTypes = [
    _PillType.capsule,
    _PillType.tablet,
    _PillType.syrup,
    _PillType.vitamin,
  ];

  @override
  void initState() {
    super.initState();
    _pillControllers = List.generate(
      _pillCount,
      (i) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1400)),
    );
    // Stagger: 200ms gap between each pill's animation start
    for (int i = 0; i < _pillCount; i++) {
      Future.delayed(Duration(milliseconds: i * 220), () {
        if (mounted) _pillControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _pillControllers) {
      c.dispose();
    }
    super.dispose();
  }

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
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // ── Blue header ───────────────────────────────────────────
          Container(
            color: const Color(0xFF0796DE),
            child: Stack(
              children: [
                Positioned(
                    left: 37,
                    top: -60,
                    child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 20, color: const Color(0xFF10A2EA))))),
                Positioned(
                    right: -20,
                    top: 10,
                    child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 20, color: const Color(0xFF10A2EA))))),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 16, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 4),
                              Text('List of Medicine',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFFAFAFA),
                                    fontSize: 20,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                  )),
                              SizedBox(height: 8),
                              // ← BOLDER + centred subtitle
                              Text(
                                "We've scanned the prescription that\nyou've uploaded and list down\nthe medicines",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFA2E0FF),
                                  fontSize: 11,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
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
              ],
            ),
          ),

          // ── White card ────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
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

                  // ── Summary pills row ─────────────────────────────
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                          _pillCount,
                          (i) => _AnimatedSummaryPill(
                                controller: _pillControllers[i],
                                count: counts[i],
                                label: labels[i],
                                type: _pillTypes[i],
                              )),
                    ),
                  ),

                  // ── Blue separator ────────────────────────────────
                  const SizedBox(height: 14),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0796DE),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),

                  // ── Scrollable list ───────────────────────────────
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
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

                  // ── Find nearby pharmacy button ───────────────────
                  Container(
                    color: const Color(0xFFFAFAFA),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => NearbyPharmacyPage(
                                      rawMedications: widget.rawMedications,
                                    ))),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0796DE),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
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
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Text(title,
            style: const TextStyle(
              color: Color(0xFF0796DE),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            )),
      );
}

// ── Pill type enum for custom icon drawing ────────────────────────────────────
enum _PillType { capsule, tablet, syrup, vitamin }

// ── Animated pill widget ──────────────────────────────────────────────────────
class _AnimatedSummaryPill extends StatefulWidget {
  final AnimationController controller;
  final int count;
  final String label;
  final _PillType type;

  const _AnimatedSummaryPill({
    required this.controller,
    required this.count,
    required this.label,
    required this.type,
  });

  @override
  State<_AnimatedSummaryPill> createState() => _AnimatedSummaryPillState();
}

class _AnimatedSummaryPillState extends State<_AnimatedSummaryPill> {
  late final Animation<double> _sweepAnim; // 0→1 during first 65% of anim
  late final Animation<double> _dotAnim; // 0→1 during last 45% (orbit)

  @override
  void initState() {
    super.initState();
    _sweepAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _dotAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeInOut)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: widget.controller,
          builder: (_, __) => CustomPaint(
            size: const Size(72, 72),
            painter: _PillIconPainter(
              type: widget.type,
              sweepProgress: _sweepAnim.value,
              dotProgress: _dotAnim.value,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${widget.count.toString().padLeft(2, '0')}\n${widget.label}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF0796DE),
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

// ── Single painter: draws ring + icon + animated dot ─────────────────────────
class _PillIconPainter extends CustomPainter {
  final _PillType type;
  final double sweepProgress; // 0→1: arc sweeps around ring
  final double dotProgress; // 0→1: dot travels around ring

  static const _blue = Color(0xFF0796DE);
  static const _white = Colors.white;

  _PillIconPainter({
    required this.type,
    required this.sweepProgress,
    required this.dotProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final ringR = size.width / 2 - 4; // outer ring radius
    const ringW = 5.0;
    const dotR = 6.0; // orbiting dot radius

    // ── 1. Light-blue background ring ────────────────────────────
    canvas.drawCircle(
        Offset(cx, cy),
        ringR,
        Paint()
          ..color = const Color(0xFFABE3FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW);

    // ── 2. Blue sweep arc (animates over the light ring) ─────────
    if (sweepProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: ringR),
        -pi / 2,
        2 * pi * sweepProgress,
        false,
        Paint()
          ..color = const Color(0xFF0796DE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW
          ..strokeCap = StrokeCap.round,
      );
    }

    // Once animation finishes, revert arc back to light blue so only the ring shows
    if (sweepProgress >= 0.99) {
      canvas.drawCircle(
          Offset(cx, cy),
          ringR,
          Paint()
            ..color = const Color(0xFFABE3FF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = ringW);
    }

    // ── 3. Blue filled inner circle ───────────────────────────────
    final innerR = ringR - ringW / 2 - 4;
    canvas.drawCircle(Offset(cx, cy), innerR, Paint()..color = _blue);

    // ── 4. White icon (drawn per type) ────────────────────────────
    switch (type) {
      case _PillType.capsule:
        _drawCapsuleIcon(canvas, cx, cy, innerR);
        break;
      case _PillType.tablet:
        _drawTabletIcon(canvas, cx, cy, innerR);
        break;
      case _PillType.syrup:
        _drawSyrupIcon(canvas, cx, cy, innerR);
        break;
      case _PillType.vitamin:
        _drawVitaminIcon(canvas, cx, cy, innerR);
        break;
    }

    // ── 5. Orbiting dot on ring ───────────────────────────────────
    if (dotProgress > 0) {
      final angle = -pi / 2 + (2 * pi * dotProgress);
      final dx = cx + ringR * cos(angle);
      final dy = cy + ringR * sin(angle);
      // White halo
      canvas.drawCircle(
          Offset(dx, dy), dotR + 1.5, Paint()..color = Colors.white);
      // Blue dot
      canvas.drawCircle(Offset(dx, dy), dotR, Paint()..color = _blue);
    }
  }

  // ── Capsule icon: two overlapping pills ───────────────────────
  void _drawCapsuleIcon(Canvas canvas, double cx, double cy, double r) {
    final p = Paint()
      ..color = _white
      ..style = PaintingStyle.fill;
    final s = r * 0.38;
    // Left pill (vertical capsule shape)
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx - s * 0.6, cy), width: s * 0.9, height: s * 1.8),
      Radius.circular(s * 0.45),
    );
    canvas.drawRRect(rr, p);
    // Right pill (angled)
    canvas.save();
    canvas.translate(cx + s * 0.5, cy);
    canvas.rotate(0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 0.85, height: s * 1.7),
        Radius.circular(s * 0.42),
      ),
      p,
    );
    canvas.restore();
    // Divider line on left pill
    canvas.drawLine(
      Offset(cx - s * 0.6 - s * 0.45, cy),
      Offset(cx - s * 0.6 + s * 0.45, cy),
      Paint()
        ..color = _blue
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  // ── Tablet icon: two round tablets side by side ───────────────
  void _drawTabletIcon(Canvas canvas, double cx, double cy, double r) {
    final p = Paint()
      ..color = _white
      ..style = PaintingStyle.fill;
    final s = r * 0.35;
    // Left tablet
    canvas.drawCircle(Offset(cx - s * 0.85, cy - s * 0.1), s, p);
    canvas.drawLine(
      Offset(cx - s * 0.85 - s * 0.7, cy - s * 0.1),
      Offset(cx - s * 0.85 + s * 0.7, cy - s * 0.1),
      Paint()
        ..color = _blue
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    // Right tablet (angled)
    canvas.save();
    canvas.translate(cx + s * 0.7, cy + s * 0.1);
    canvas.rotate(0.4);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: s * 1.5, height: s * 2.1),
        p);
    canvas.drawLine(
      Offset(0, -s * 0.9),
      Offset(0, s * 0.9),
      Paint()
        ..color = _blue
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();
  }

  // ── Syrup icon: medicine bottle ───────────────────────────────
  void _drawSyrupIcon(Canvas canvas, double cx, double cy, double r) {
    final p = Paint()
      ..color = _white
      ..style = PaintingStyle.fill;
    final s = r * 0.28;
    // Bottle body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy + s * 0.4), width: s * 2.4, height: s * 2.8),
        Radius.circular(s * 0.5),
      ),
      p,
    );
    // Bottle neck
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(cx, cy - s * 0.85), width: s * 1.2, height: s * 0.8),
      p,
    );
    // Cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy - s * 1.45), width: s * 1.6, height: s * 0.6),
        Radius.circular(s * 0.2),
      ),
      p,
    );
    // Cross on bottle
    final cp = Paint()
      ..color = _blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy + s * 0.1), Offset(cx, cy + s * 1.1), cp);
    canvas.drawLine(Offset(cx - s * 0.6, cy + s * 0.6),
        Offset(cx + s * 0.6, cy + s * 0.6), cp);
  }

  // ── Vitamin icon: capsule + shield/circle ──────────────────────
  void _drawVitaminIcon(Canvas canvas, double cx, double cy, double r) {
    final p = Paint()
      ..color = _white
      ..style = PaintingStyle.fill;
    final s = r * 0.35;
    // Left: tall capsule
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx - s * 0.7, cy), width: s * 0.9, height: s * 2.0),
        Radius.circular(s * 0.45),
      ),
      p,
    );
    canvas.drawLine(
      Offset(cx - s * 0.7 - s * 0.45, cy),
      Offset(cx - s * 0.7 + s * 0.45, cy),
      Paint()
        ..color = _blue
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    // Right: circle with cross (vitamin symbol)
    canvas.drawCircle(Offset(cx + s * 0.75, cy), s * 0.85, p);
    final cp = Paint()
      ..color = _blue
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx + s * 0.75, cy - s * 0.5),
        Offset(cx + s * 0.75, cy + s * 0.5), cp);
    canvas.drawLine(Offset(cx + s * 0.25, cy), Offset(cx + s * 1.25, cy), cp);
  }

  @override
  bool shouldRepaint(_PillIconPainter old) =>
      old.sweepProgress != sweepProgress ||
      old.dotProgress != dotProgress ||
      old.type != type;
}

// ── Medicine card ─────────────────────────────────────────────────────────────
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
              color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(medicine.name,
                  style: const TextStyle(
                      color: Color(0xFF11A2EB),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3)),
              const SizedBox(height: 4),
              Text(medicine.instruction,
                  style: const TextStyle(
                      color: Color(0xFF9F9EA5),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500)),
            ]),
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
