import 'package:flutter/material.dart';
import 'reminder_store.dart';
import 'add_medicine_name_page.dart';

class MedicalReminderPage extends StatefulWidget {
  const MedicalReminderPage({super.key});

  @override
  State<MedicalReminderPage> createState() => _MedicalReminderPageState();
}

class _MedicalReminderPageState extends State<MedicalReminderPage>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  int _selectedDayIndex = DateTime.now().weekday % 7;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  static const _dayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // ── Day circle animations ────────────────────────────────────────────────────
  late List<AnimationController> _dayControllers;
  late List<Animation<Offset>> _daySlideAnims;
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotFadeAnims;

  // ── FAB breathing animation ──────────────────────────────────────────────────
  late AnimationController _breathController;
  late Animation<double> _breathAnim;

  // ── Background circle float animations (matching home page) ─────────────────
  late List<AnimationController> _bgControllers;
  late List<Animation<Offset>> _bgAnims;

  @override
  void initState() {
    super.initState();

    // Day circles
    _dayControllers = List.generate(
        7,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 400)));
    _daySlideAnims = _dayControllers
        .map((c) => Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    _dotControllers = List.generate(
        7,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 300)));
    _dotFadeAnims = _dotControllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeIn)))
        .toList();

    // FAB breath
    _breathController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _breathAnim = Tween<double>(begin: 0.30, end: 0.06).animate(
        CurvedAnimation(parent: _breathController, curve: Curves.easeInOut));

    // Background circles — 5 controllers, each with its own speed and direction
    final bgDurations = [3200, 4100, 5000, 3600, 4500];
    final bgOffsets = [
      const Offset(20, -28),
      const Offset(-18, 25),
      const Offset(28, 18),
      const Offset(-22, -20),
      const Offset(15, 22),
    ];
    _bgControllers = List.generate(
        5,
        (i) => AnimationController(
            vsync: this, duration: Duration(milliseconds: bgDurations[i]))
          ..repeat(reverse: true));
    _bgAnims = List.generate(
        5,
        (i) => Tween<Offset>(begin: Offset.zero, end: bgOffsets[i]).animate(
            CurvedAnimation(
                parent: _bgControllers[i], curve: Curves.easeInOut)));

    _triggerDayAnimations();
  }

  void _triggerDayAnimations() async {
    for (int i = 0; i < 7; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) {
        _dayControllers[i].forward();
        Future.delayed(const Duration(milliseconds: 260), () {
          if (mounted) _dotControllers[i].forward();
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in _dayControllers) c.dispose();
    for (final c in _dotControllers) c.dispose();
    for (final c in _bgControllers) c.dispose();
    _breathController.dispose();
    super.dispose();
  }

  // ── Month picker dialog ──────────────────────────────────────────────────────
  Future<void> _showMonthPicker() async {
    int tempYear = _selectedDate.year;
    int tempMonth = _selectedDate.month;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: Color(0xFF0796DE)),
                        onPressed: () => setDialogState(() => tempYear--),
                      ),
                      Text(
                        '$tempYear',
                        style: const TextStyle(
                          color: Color(0xFF0796DE),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: Color(0xFF0796DE)),
                        onPressed: () => setDialogState(() => tempYear++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Month grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(12, (i) {
                      final isSelected = (i + 1) == tempMonth &&
                          tempYear == _selectedDate.year;
                      final shortName = _monthNames[i].substring(0, 3);
                      return GestureDetector(
                        onTap: () => setDialogState(() => tempMonth = i + 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0796DE)
                                : const Color(0xFF0796DE).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              shortName,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF0796DE),
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel',
                            style: TextStyle(
                              color: Color(0xFF9F9EA5),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0796DE),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            // Move to the 1st of the selected month/year,
                            // keep day index on Sunday (0) as default
                            _selectedDate = DateTime(tempYear, tempMonth, 1);
                            _selectedDayIndex = _selectedDate.weekday % 7;
                          });
                        },
                        child: const Text('OK',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  List<DateTime> _getWeekDays() {
    final now = _selectedDate;
    final weekday = now.weekday % 7;
    final sunday = now.subtract(Duration(days: weekday));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  List<ReminderModel> _getRemindersForDay() {
    return ReminderStore.instance.reminders.where((r) {
      final dayIndex = _selectedDate.weekday % 7;
      return r.days[dayIndex];
    }).toList();
  }

  Map<String, List<ReminderModel>> _groupByTime(List<ReminderModel> reminders) {
    final Map<String, List<ReminderModel>> map = {};
    for (final r in reminders) {
      for (final t in r.times) {
        map.putIfAbsent(t, () => []).add(r);
      }
    }
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => _compareTime(a.key, b.key)));
  }

  int _compareTime(String a, String b) {
    int toMinutes(String t) {
      final clean = t.replaceAll(' ', '');
      final colonIdx = clean.indexOf(':');
      int h = int.tryParse(clean.substring(0, colonIdx)) ?? 0;
      final rest = clean.substring(colonIdx + 1);
      final isPm = rest.contains('PM');
      final m = int.tryParse(rest.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (isPm && h != 12) h += 12;
      if (!isPm && h == 12) h = 0;
      return h * 60 + m;
    }

    return toMinutes(a).compareTo(toMinutes(b));
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();
    final dayReminders = _getRemindersForDay();
    final grouped = _groupByTime(dayReminders);

    return Scaffold(
      backgroundColor: const Color(0xFF0796DE),
      body: Stack(
        children: [
          // ── Animated background circles (home page style) ──────────────────
          AnimatedBuilder(
            animation: Listenable.merge(_bgControllers),
            builder: (context, _) {
              return Stack(children: [
                // Top-left border ring
                Positioned(
                  left: 47 + _bgAnims[0].value.dx,
                  top: -96 + _bgAnims[0].value.dy,
                  child: Container(
                    width: 183,
                    height: 183,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(width: 30, color: const Color(0xFF10A2EA)),
                    ),
                  ),
                ),
                // Large gradient blob behind header
                Positioned(
                  left: 140 + _bgAnims[1].value.dx,
                  top: -30 + _bgAnims[1].value.dy,
                  child: Opacity(
                    opacity: 0.30,
                    child: Transform.rotate(
                      angle: 3.03,
                      child: Container(
                        width: 153,
                        height: 153,
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
                // Top-right small blob
                Positioned(
                  left: 300 + _bgAnims[2].value.dx,
                  top: 40 + _bgAnims[2].value.dy,
                  child: Opacity(
                    opacity: 0.28,
                    child: Transform.rotate(
                      angle: 0.57,
                      child: Container(
                        width: 89,
                        height: 89,
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
                // Mid-left medium blob
                Positioned(
                  left: 100 + _bgAnims[3].value.dx,
                  top: 60 + _bgAnims[3].value.dy,
                  child: Opacity(
                    opacity: 0.25,
                    child: Transform.rotate(
                      angle: 3.03,
                      child: Container(
                        width: 94,
                        height: 94,
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
                // Top-right border ring
                Positioned(
                  left: 320 + _bgAnims[4].value.dx,
                  top: -20 + _bgAnims[4].value.dy,
                  child: Transform.rotate(
                    angle: 0.40,
                    child: Container(
                      width: 167,
                      height: 167,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 30, color: const Color(0xFF10A2EA)),
                      ),
                    ),
                  ),
                ),
              ]);
            },
          ),

          // ── Main content ───────────────────────────────────────────────────
          Column(
            children: [
              // Blue header
              Container(
                color: Colors.transparent,
                width: double.infinity,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Medical Reminder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Tappable month/year dropdown
                        GestureDetector(
                          onTap: _showMonthPicker,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // White bottom sheet
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F8FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0796DE).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Animated day selector ─────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRect(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(7, (i) {
                              final date = weekDays[i];
                              final isSelected = i == _selectedDayIndex;
                              final isToday = date.day == DateTime.now().day &&
                                  date.month == DateTime.now().month &&
                                  date.year == DateTime.now().year;

                              return SlideTransition(
                                position: _daySlideAnims[i],
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedDayIndex = i;
                                    _selectedDate = date;
                                  }),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FadeTransition(
                                        opacity: _dotFadeAnims[i],
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF0796DE)
                                                .withOpacity(
                                                    isSelected || isToday
                                                        ? 1.0
                                                        : 0.35),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? const Color(0xFF0796DE)
                                                  .withOpacity(0.15)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: const Color(0xFF0796DE)
                                                .withOpacity(
                                                    isSelected ? 1.0 : 0.25),
                                            width: isSelected ? 2 : 1.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _dayLetters[i],
                                            style: TextStyle(
                                              color: isSelected
                                                  ? const Color(0xFF0796DE)
                                                  : isToday
                                                      ? const Color(0xFF0796DE)
                                                      : const Color(0xFF9F9EA5),
                                              fontSize: 15,
                                              fontFamily: 'Poppins',
                                              fontWeight: isSelected || isToday
                                                  ? FontWeight.w700
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Reminder list ──────────────────────────────────────
                      Expanded(
                        child: dayReminders.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_none,
                                        size: 60,
                                        color: const Color(0xFF0796DE)
                                            .withOpacity(0.3)),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No reminders for this day',
                                      style: TextStyle(
                                        color: const Color(0xFF0796DE)
                                            .withOpacity(0.5),
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                children: grouped.entries.map((entry) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            entry.key,
                                            style: const TextStyle(
                                              color: Color(0xFF0796DE),
                                              fontSize: 14,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              color: const Color(0xFF0796DE)
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      ...entry.value
                                          .map((r) => _buildReminderCard(r)),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── FAB bottom right with breathing ring ───────────────────────────
          Positioned(
            right: 20,
            bottom: 28,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddMedicineNamePage()),
                ).then((_) => setState(() {}));
              },
              child: AnimatedBuilder(
                animation: _breathAnim,
                builder: (context, child) {
                  return SizedBox(
                    width: 76,
                    height: 76,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0796DE)
                                .withOpacity(_breathAnim.value),
                          ),
                        ),
                        child!,
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0796DE),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x440796DE),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD6EFFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.daysLabel,
                  style: const TextStyle(
                    color: Color(0xFF7CC8E8),
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  r.name,
                  style: const TextStyle(
                    color: Color(0xFF0796DE),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                if (r.description.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0796DE).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      r.description,
                      style: const TextStyle(
                        color: Color(0xFF0796DE),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0796DE).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('O ',
                    style: TextStyle(
                        color: Color(0xFF0796DE),
                        fontSize: 12,
                        fontFamily: 'Poppins')),
                Text('Done',
                    style: TextStyle(
                        color: Color(0xFF0796DE),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
