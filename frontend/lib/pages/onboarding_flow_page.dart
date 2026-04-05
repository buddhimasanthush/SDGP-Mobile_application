import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_store.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — shown once after sign-up, before home
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingFlowPage extends StatefulWidget {
  final Widget destination;
  const OnboardingFlowPage({super.key, required this.destination});

  @override
  State<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends State<OnboardingFlowPage> {
  int _step = 0;

  void _next() {
    if (_step < 4) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _finish() {
    UserStore.instance.hasCompletedOnboarding = true;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => widget.destination),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepPhone(onNext: _next, onSkip: _finish, step: 0, total: 5),
      _StepDOB(onNext: _next, onSkip: _finish, step: 1, total: 5),
      _StepBloodType(onNext: _next, onSkip: _finish, step: 2, total: 5),
      _StepAllergies(onNext: _next, onSkip: _finish, step: 3, total: 5),
      _StepChronic(onNext: _next, onSkip: _finish, step: 4, total: 5),
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      child: KeyedSubtree(key: ValueKey(_step), child: steps[_step]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared scaffold used by every step
// ─────────────────────────────────────────────────────────────────────────────
class _OnboardingScaffold extends StatelessWidget {
  final int step, total;
  final String emoji, title, subtitle, nextLabel;
  final Widget picker;
  final VoidCallback onNext, onSkip;

  const _OnboardingScaffold({
    required this.step,
    required this.total,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.nextLabel,
    required this.picker,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0796DE),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0796DE),
        child: Stack(
          children: [
            // Decorative circles
            ..._circles(),

            // Bottom gradient fade
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 300,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0796DE).withOpacity(0.0),
                      const Color(0xFF0796DE).withOpacity(0.3),
                      const Color(0xFF0564B8).withOpacity(0.7),
                      const Color(0xFF001F81),
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top bar: progress dots + skip
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(total, (i) {
                            final active = i == step;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 6),
                              width: active ? 22 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(4)),
                            );
                          }),
                        ),
                        GestureDetector(
                          onTap: onSkip,
                          child: Text('Skip',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Emoji circle
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle),
                    child: Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 32))),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),

                  const SizedBox(height: 6),

                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13.5,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 1.5)),
                  ),

                  const SizedBox(height: 24),

                  // White picker card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF052F84).withOpacity(0.25),
                              blurRadius: 40,
                              offset: const Offset(0, 8))
                        ],
                      ),
                      child: picker,
                    ),
                  ),

                  const Spacer(),

                  // Next / Done button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                    child: GestureDetector(
                      onTap: onNext,
                      child: Container(
                        width: double.infinity,
                        height: 62,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(63)),
                        child: Center(
                          child: Text(nextLabel,
                              style: const TextStyle(
                                  color: Color(0xFF0796DE),
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3)),
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

  List<Widget> _circles() => [
        _c(left: 124, top: 5, size: 183, border: true, angle: 0.53),
        _c(
            left: 112,
            top: 104,
            size: 154,
            border: false,
            angle: 3.03,
            op: 0.30),
        _c(left: 14, top: -20, size: 89, border: false, angle: 0.57, op: 0.30),
        _c(left: 93, top: 217, size: 94, border: false, angle: 3.03, op: 0.30),
        _c(left: 292, top: -117, size: 167, border: true, angle: 0.40),
        _c(
            left: 249,
            top: 337,
            size: 154,
            border: false,
            angle: 6.17,
            op: 0.28),
        _c(left: 371, top: 421, size: 89, border: false, angle: 3.71, op: 0.28),
        _c(left: 69, top: 469, size: 167, border: true, angle: 3.54),
      ];

  Widget _c(
      {required double left,
      required double top,
      required double size,
      required bool border,
      double angle = 0,
      double op = 1.0}) {
    return Positioned(
        left: left,
        top: top,
        child: Opacity(
            opacity: op,
            child: Transform.rotate(
                angle: angle,
                child: Container(
                    width: size,
                    height: size,
                    decoration: border
                        ? const ShapeDecoration(
                            shape: OvalBorder(
                                side: BorderSide(
                                    width: 30, color: Color(0xFF10A2EA))))
                        : const ShapeDecoration(
                            gradient: LinearGradient(
                                begin: Alignment(0.93, 0.35),
                                end: Alignment(0.06, 0.40),
                                colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]),
                            shape: OvalBorder())))));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable drum-roll wheel picker
// ─────────────────────────────────────────────────────────────────────────────
class _WheelPicker extends StatefulWidget {
  final List<String> items;
  final FixedExtentScrollController controller;
  final double itemHeight;
  final double fontSize;

  const _WheelPicker({
    required this.items,
    required this.controller,
    this.itemHeight = 52,
    this.fontSize = 22,
  });

  @override
  State<_WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<_WheelPicker> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.itemHeight;
    return SizedBox(
      height: h * 5,
      child: Stack(children: [
        // Highlight band
        Center(
            child: Container(
                height: h,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: const Color(0xFF0796DE),
                    borderRadius: BorderRadius.circular(14)))),
        // Wheel
        ListWheelScrollView.useDelegate(
          controller: widget.controller,
          itemExtent: h,
          perspective: 0.004,
          diameterRatio: 1.8,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (_) => HapticFeedback.selectionClick(),
          childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (_, i) {
                final sel = widget.controller.hasClients &&
                    widget.controller.selectedItem == i;
                return Center(
                    child: Text(widget.items[i],
                        style: TextStyle(
                            color: sel ? Colors.white : const Color(0xFF0796DE),
                            fontSize:
                                sel ? widget.fontSize + 1 : widget.fontSize - 2,
                            fontFamily: 'Poppins',
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.w400)));
              }),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — Phone number
// ─────────────────────────────────────────────────────────────────────────────
class _StepPhone extends StatefulWidget {
  final VoidCallback onNext, onSkip;
  final int step, total;
  const _StepPhone(
      {required this.onNext,
      required this.onSkip,
      required this.step,
      required this.total});
  @override
  State<_StepPhone> createState() => _StepPhoneState();
}

class _StepPhoneState extends State<_StepPhone> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      emoji: '📱',
      title: 'Your Phone Number',
      subtitle: "We'll use this to send you\nreminders & important updates.",
      nextLabel: 'Next →',
      onNext: () {
        UserStore.instance.phone = _ctrl.text.trim();
        widget.onNext();
      },
      onSkip: widget.onSkip,
      picker: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mobile Number',
              style: TextStyle(
                  color: const Color(0xFF0796DE).withOpacity(0.6),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                    color: const Color(0xFF0796DE).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14)),
                child: const Text('+94 🇱🇰',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0796DE)))),
            const SizedBox(width: 12),
            Expanded(
                child: TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.phone,
                    autofocus: true,
                    style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A)),
                    decoration: const InputDecoration(
                        hintText: '77 123 4567',
                        hintStyle: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFBBBBBB)),
                        border: InputBorder.none))),
          ]),
          const SizedBox(height: 4),
          Divider(color: const Color(0xFF0796DE).withOpacity(0.15)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.lock_outline_rounded,
                size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 5),
            Text('Your number stays private',
                style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade400)),
          ]),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 — Date of Birth
// ─────────────────────────────────────────────────────────────────────────────
class _StepDOB extends StatefulWidget {
  final VoidCallback onNext, onSkip;
  final int step, total;
  const _StepDOB(
      {required this.onNext,
      required this.onSkip,
      required this.step,
      required this.total});
  @override
  State<_StepDOB> createState() => _StepDOBState();
}

class _StepDOBState extends State<_StepDOB> {
  final _days = List.generate(31, (i) => '${i + 1}'.padLeft(2, '0'));
  final _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final _years = List.generate(100, (i) => '${2005 - i}');

  late final FixedExtentScrollController _dayCtrl, _monCtrl, _yearCtrl;

  @override
  void initState() {
    super.initState();
    _dayCtrl = FixedExtentScrollController(initialItem: 0);
    _monCtrl = FixedExtentScrollController(initialItem: 0);
    _yearCtrl = FixedExtentScrollController(initialItem: 25); // ~1980
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _monCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      emoji: '🎂',
      title: 'Date of Birth',
      subtitle:
          'Scroll to pick your birthday.\nWe use this to calculate your age.',
      nextLabel: 'Next →',
      onNext: () {
        UserStore.instance.dateOfBirth = '${_months[_monCtrl.selectedItem]} '
            '${_days[_dayCtrl.selectedItem]}, '
            '${_years[_yearCtrl.selectedItem]}';
        widget.onNext();
      },
      onSkip: widget.onSkip,
      picker: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(
              child: _WheelPicker(
                  items: _days, controller: _dayCtrl, fontSize: 20)),
          Expanded(
              flex: 2,
              child: _WheelPicker(
                  items: _months, controller: _monCtrl, fontSize: 18)),
          Expanded(
              flex: 2,
              child: _WheelPicker(
                  items: _years, controller: _yearCtrl, fontSize: 20)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3 — Blood Type
// ─────────────────────────────────────────────────────────────────────────────
class _StepBloodType extends StatefulWidget {
  final VoidCallback onNext, onSkip;
  final int step, total;
  const _StepBloodType(
      {required this.onNext,
      required this.onSkip,
      required this.step,
      required this.total});
  @override
  State<_StepBloodType> createState() => _StepBloodTypeState();
}

class _StepBloodTypeState extends State<_StepBloodType> {
  final _types = ['A', 'B', 'AB', 'O'];
  final _rh = ['+', '−'];
  late final FixedExtentScrollController _typeCtrl, _rhCtrl;

  @override
  void initState() {
    super.initState();
    _typeCtrl = FixedExtentScrollController(initialItem: 3); // O
    _rhCtrl = FixedExtentScrollController(initialItem: 0); // +
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _rhCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      emoji: '🩸',
      title: 'Blood Type',
      subtitle: 'Scroll to select your blood type.\nCritical in emergencies.',
      nextLabel: 'Next →',
      onNext: () {
        UserStore.instance.bloodType =
            '${_types[_typeCtrl.selectedItem]}${_rh[_rhCtrl.selectedItem]}';
        widget.onNext();
      },
      onSkip: widget.onSkip,
      picker: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(
              flex: 2,
              child: _WheelPicker(
                  items: _types,
                  controller: _typeCtrl,
                  itemHeight: 60,
                  fontSize: 28)),
          Expanded(
              child: _WheelPicker(
                  items: _rh,
                  controller: _rhCtrl,
                  itemHeight: 60,
                  fontSize: 28)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4 — Allergies
// ─────────────────────────────────────────────────────────────────────────────
class _StepAllergies extends StatefulWidget {
  final VoidCallback onNext, onSkip;
  final int step, total;
  const _StepAllergies(
      {required this.onNext,
      required this.onSkip,
      required this.step,
      required this.total});
  @override
  State<_StepAllergies> createState() => _StepAllergiesState();
}

class _StepAllergiesState extends State<_StepAllergies> {
  static const _options = [
    'Penicillin',
    'Aspirin',
    'Ibuprofen',
    'Sulfa Drugs',
    'Peanuts',
    'Shellfish',
    'Latex',
    'Pollen',
    'Dust',
  ];
  final Set<String> _selected = {};
  final _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      emoji: '⚠️',
      title: 'Known Allergies',
      subtitle:
          'Tap all that apply, or type your own.\nHelps pharmacists keep you safe.',
      nextLabel: 'Next →',
      onNext: () {
        final custom = _customCtrl.text.trim();
        final all = [..._selected, if (custom.isNotEmpty) custom];
        UserStore.instance.allergies =
            all.isEmpty ? 'None recorded' : all.join(', ');
        widget.onNext();
      },
      onSkip: widget.onSkip,
      picker: _ChipPicker(
        options: _options,
        selected: _selected,
        customCtrl: _customCtrl,
        onChanged: () => setState(() {}),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 5 — Chronic Conditions
// ─────────────────────────────────────────────────────────────────────────────
class _StepChronic extends StatefulWidget {
  final VoidCallback onNext, onSkip;
  final int step, total;
  const _StepChronic(
      {required this.onNext,
      required this.onSkip,
      required this.step,
      required this.total});
  @override
  State<_StepChronic> createState() => _StepChronicState();
}

class _StepChronicState extends State<_StepChronic> {
  static const _options = [
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Heart Disease',
    'Arthritis',
    'Thyroid',
    'High Cholesterol',
    'Kidney Disease',
    'COPD',
    'Depression',
  ];
  final Set<String> _selected = {};
  final _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      emoji: '🏥',
      title: 'Chronic Conditions',
      subtitle:
          'Select any long-term conditions.\nHelps us personalise your care.',
      nextLabel: 'All Done! 🎉',
      onNext: () {
        final custom = _customCtrl.text.trim();
        final all = [..._selected, if (custom.isNotEmpty) custom];
        UserStore.instance.chronicConditions =
            all.isEmpty ? 'None recorded' : all.join(', ');
        widget.onNext();
      },
      onSkip: widget.onSkip,
      picker: _ChipPicker(
        options: _options,
        selected: _selected,
        customCtrl: _customCtrl,
        onChanged: () => setState(() {}),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared chip picker widget (used by steps 4 & 5)
// ─────────────────────────────────────────────────────────────────────────────
class _ChipPicker extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final TextEditingController customCtrl;
  final VoidCallback onChanged;

  const _ChipPicker({
    required this.options,
    required this.selected,
    required this.customCtrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // "None" chip
        GestureDetector(
          onTap: () {
            selected.clear();
            onChanged();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
                color: selected.isEmpty
                    ? const Color(0xFF0796DE)
                    : const Color(0xFF0796DE).withOpacity(0.08),
                borderRadius: BorderRadius.circular(30)),
            child: Text('✓  None',
                style: TextStyle(
                    color: selected.isEmpty
                        ? Colors.white
                        : const Color(0xFF0796DE),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
        // Option chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((o) {
            final sel = selected.contains(o);
            return GestureDetector(
              onTap: () {
                sel ? selected.remove(o) : selected.add(o);
                onChanged();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF0796DE)
                        : const Color(0xFF0796DE).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30)),
                child: Text(o,
                    style: TextStyle(
                        color: sel ? Colors.white : const Color(0xFF0796DE),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        Divider(color: const Color(0xFF0796DE).withOpacity(0.12)),
        const SizedBox(height: 8),
        TextField(
          controller: customCtrl,
          style: const TextStyle(
              fontSize: 14, fontFamily: 'Poppins', color: Color(0xFF1A1A1A)),
          decoration: InputDecoration(
              hintText: 'Other (type here)…',
              hintStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade400),
              border: InputBorder.none,
              isDense: true),
        ),
      ]),
    );
  }
}
