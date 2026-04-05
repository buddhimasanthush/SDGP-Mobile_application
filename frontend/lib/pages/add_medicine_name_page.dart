import 'package:flutter/material.dart';
import 'allow_notifications_page.dart';
import 'reminder_store.dart';

class AddMedicineNamePage extends StatefulWidget {
  const AddMedicineNamePage({super.key});

  @override
  State<AddMedicineNamePage> createState() => _AddMedicineNamePageState();
}

class _AddMedicineNamePageState extends State<AddMedicineNamePage>
    with TickerProviderStateMixin {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showReminderTime = false;
  bool _showFrequency = false;
  final List<String> _selectedTimes = [];

  // Frequency state
  String _selectedFrequency =
      'Days of week'; // Days of week | Interval | Cycle | As needed
  final List<bool> _selectedDays = [
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ]; // S M T W T F S
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  int _selectedHourIndex = 7;
  int _selectedMinuteIndex = 5;
  int _selectedPeriodIndex = 1;

  // Calculates time remaining from now to selected wheel time
  String _getRingsText() {
    final now = DateTime.now();
    final hour = _selectedHourIndex + 1; // wheel is 0-indexed, hour 1–12
    final minute = _selectedMinuteIndex;
    final isPm = _selectedPeriodIndex == 1;
    final hour24 =
        isPm ? (hour == 12 ? 12 : hour + 12) : (hour == 12 ? 0 : hour);

    var selected = DateTime(now.year, now.month, now.day, hour24, minute);
    if (selected.isBefore(now)) {
      selected = selected.add(const Duration(days: 1));
    }

    final diff = selected.difference(now);
    final hrs = diff.inHours;
    final mins = diff.inMinutes % 60;
    return '+ Rings in $hrs hr $mins min';
  }

  // Slide animation for timer section
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Slide animation for frequency section
  late AnimationController _slideController2;
  late Animation<Offset> _slideAnimation2;

  // Floating circle animations
  late AnimationController _floatController1;
  late AnimationController _floatController2;
  late AnimationController _floatController3;
  late AnimationController _floatController4;
  late AnimationController _floatController5;
  late AnimationController _floatController6;
  late AnimationController _floatController7;
  late AnimationController _floatController8;

  late Animation<Offset> _floatAnimation1;
  late Animation<Offset> _floatAnimation2;
  late Animation<Offset> _floatAnimation3;
  late Animation<Offset> _floatAnimation4;
  late Animation<Offset> _floatAnimation5;
  late Animation<Offset> _floatAnimation6;
  late Animation<Offset> _floatAnimation7;
  late Animation<Offset> _floatAnimation8;

  @override
  void initState() {
    super.initState();

    // Initialize wheel to current device time
    final now = DateTime.now();
    final initHour =
        now.hour % 12 == 0 ? 11 : (now.hour % 12) - 1; // 0-indexed (0=1, 11=12)
    final initMinute = now.minute;
    final initPeriod = now.hour < 12 ? 0 : 1;

    _selectedHourIndex = initHour;
    _selectedMinuteIndex = initMinute;
    _selectedPeriodIndex = initPeriod;

    _hourController = FixedExtentScrollController(initialItem: initHour);
    _minuteController = FixedExtentScrollController(initialItem: initMinute);
    _periodController = FixedExtentScrollController(initialItem: initPeriod);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController2 = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation2 = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController2, curve: Curves.easeOut));

    _floatController1 =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat(reverse: true);
    _floatController2 =
        AnimationController(duration: const Duration(seconds: 4), vsync: this)
          ..repeat(reverse: true);
    _floatController3 =
        AnimationController(duration: const Duration(seconds: 5), vsync: this)
          ..repeat(reverse: true);
    _floatController4 = AnimationController(
        duration: const Duration(seconds: 3, milliseconds: 500), vsync: this)
      ..repeat(reverse: true);
    _floatController5 = AnimationController(
        duration: const Duration(seconds: 4, milliseconds: 200), vsync: this)
      ..repeat(reverse: true);
    _floatController6 = AnimationController(
        duration: const Duration(seconds: 5, milliseconds: 500), vsync: this)
      ..repeat(reverse: true);
    _floatController7 = AnimationController(
        duration: const Duration(seconds: 3, milliseconds: 700), vsync: this)
      ..repeat(reverse: true);
    _floatController8 = AnimationController(
        duration: const Duration(seconds: 4, milliseconds: 800), vsync: this)
      ..repeat(reverse: true);

    _floatAnimation1 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(25, -35)).animate(
            CurvedAnimation(
                parent: _floatController1, curve: Curves.easeInOut));
    _floatAnimation2 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-20, 30)).animate(
            CurvedAnimation(
                parent: _floatController2, curve: Curves.easeInOut));
    _floatAnimation3 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(35, 20)).animate(
            CurvedAnimation(
                parent: _floatController3, curve: Curves.easeInOut));
    _floatAnimation4 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-25, -30)).animate(
            CurvedAnimation(
                parent: _floatController4, curve: Curves.easeInOut));
    _floatAnimation5 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(20, 28)).animate(
            CurvedAnimation(
                parent: _floatController5, curve: Curves.easeInOut));
    _floatAnimation6 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-30, -22)).animate(
            CurvedAnimation(
                parent: _floatController6, curve: Curves.easeInOut));
    _floatAnimation7 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(18, -25)).animate(
            CurvedAnimation(
                parent: _floatController7, curve: Curves.easeInOut));
    _floatAnimation8 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-22, 32)).animate(
            CurvedAnimation(
                parent: _floatController8, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    _slideController.dispose();
    _slideController2.dispose();
    _floatController1.dispose();
    _floatController2.dispose();
    _floatController3.dispose();
    _floatController4.dispose();
    _floatController5.dispose();
    _floatController6.dispose();
    _floatController7.dispose();
    _floatController8.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_medicineNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter medicine name'),
          backgroundColor: Color(0xFF0796DE),
        ),
      );
      return;
    }

    if (!_showReminderTime) {
      // Show the timer sliding up from bottom
      setState(() => _showReminderTime = true);
      _slideController.forward();
      Future.delayed(const Duration(milliseconds: 150), () {
        _scrollController.animateTo(
          300,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    } else if (!_showFrequency) {
      // Show frequency section sliding up
      setState(() => _showFrequency = true);
      _slideController2.forward();
      Future.delayed(const Duration(milliseconds: 150), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      });
    } else {
      // Save reminder to store
      ReminderStore.instance.add(ReminderModel(
        name: _medicineNameController.text.trim(),
        description: _descriptionController.text.trim(),
        times: List.from(_selectedTimes),
        days: List.from(_selectedDays),
        frequency: _selectedFrequency,
        startDate: _startDate,
        endDate: _endDate,
      ));
      // Navigate to permissions flow
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AllowNotificationsPage()),
      );
    }
  }

  void _addTime() {
    final hour = _selectedHourIndex + 1;
    final minute = _selectedMinuteIndex;
    final period = _selectedPeriodIndex == 0 ? 'AM' : 'PM';
    final time =
        '${hour.toString().padLeft(2, '0')} : ${minute.toString().padLeft(2, '0')} $period';
    if (!_selectedTimes.contains(time)) {
      setState(() => _selectedTimes.add(time));
    }
  }

  void _removeTime(String time) {
    setState(() => _selectedTimes.remove(time));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Color(0xFF0796DE)),
        child: Stack(
          children: [
            ..._buildDecorativeCircles(),

            SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 260),

                  // Medicine name input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Container(
                      height: 64,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          _buildPillIcon(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _medicineNameController,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Color(0xFF0796DE),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter the name of the medicine',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9F9EA5),
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Container(
                      height: 64,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          _buildLinesIcon(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _descriptionController,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Color(0xFF0796DE),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter the Description',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9F9EA5),
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),

                  // Reminder timer — slides up from bottom after Next
                  if (_showReminderTime)
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          const Text(
                            'Reminder Time',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.32,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Time picker
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Container(
                              height: 173,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Blue selection bar behind text
                                  Container(
                                    height: 40,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF11A2EB),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(13)),
                                    ),
                                  ),
                                  // Wheel columns on top
                                  Row(
                                    children: [
                                      // Hours
                                      Expanded(
                                        child: ListWheelScrollView.useDelegate(
                                          controller: _hourController,
                                          itemExtent: 40,
                                          perspective: 0.005,
                                          diameterRatio: 1.2,
                                          physics:
                                              const FixedExtentScrollPhysics(),
                                          onSelectedItemChanged: (i) =>
                                              setState(
                                                  () => _selectedHourIndex = i),
                                          childDelegate:
                                              ListWheelChildBuilderDelegate(
                                            childCount: 12,
                                            builder: (context, index) {
                                              final isSelected =
                                                  _selectedHourIndex == index;
                                              return Center(
                                                child: Text(
                                                  (index + 1)
                                                      .toString()
                                                      .padLeft(2, '0'),
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF11A2EB),
                                                    fontSize:
                                                        isSelected ? 24 : 18,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w400,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // Minutes
                                      Expanded(
                                        child: ListWheelScrollView.useDelegate(
                                          controller: _minuteController,
                                          itemExtent: 40,
                                          perspective: 0.005,
                                          diameterRatio: 1.2,
                                          physics:
                                              const FixedExtentScrollPhysics(),
                                          onSelectedItemChanged: (i) =>
                                              setState(() =>
                                                  _selectedMinuteIndex = i),
                                          childDelegate:
                                              ListWheelChildBuilderDelegate(
                                            childCount: 60,
                                            builder: (context, index) {
                                              final isSelected =
                                                  _selectedMinuteIndex == index;
                                              return Center(
                                                child: Text(
                                                  index
                                                      .toString()
                                                      .padLeft(2, '0'),
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF11A2EB),
                                                    fontSize:
                                                        isSelected ? 24 : 18,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w400,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // AM / PM
                                      Expanded(
                                        child: ListWheelScrollView(
                                          controller: _periodController,
                                          itemExtent: 40,
                                          perspective: 0.005,
                                          diameterRatio: 1.2,
                                          physics:
                                              const FixedExtentScrollPhysics(),
                                          onSelectedItemChanged: (i) =>
                                              setState(() =>
                                                  _selectedPeriodIndex = i),
                                          children: ['AM', 'PM']
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final isSelected =
                                                _selectedPeriodIndex ==
                                                    entry.key;
                                            return Center(
                                              child: Text(
                                                entry.value,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF11A2EB),
                                                  fontSize:
                                                      isSelected ? 24 : 18,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: isSelected
                                                      ? FontWeight.w700
                                                      : FontWeight.w400,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Add time button
                          GestureDetector(
                            onTap: _addTime,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: ShapeDecoration(
                                color: const Color(0xFF002082),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)),
                              ),
                              child: Center(
                                child: Text(
                                  _getRingsText(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Time badges sit right below the Rings button
                          if (_selectedTimes.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Wrap(
                                spacing: 9,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: _selectedTimes
                                    .map((t) => _buildTimeBadge(t))
                                    .toList(),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Frequency section slides up after Next
                          if (_showFrequency)
                            SlideTransition(
                              position: _slideAnimation2,
                              child: _buildFrequencySection(),
                            ),

                          const SizedBox(height: 300),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 300),
                ],
              ),
            ),

            // Bottom gradient overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 280,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0796DE).withValues(alpha: 0.0),
                        const Color(0xFF0796DE).withValues(alpha: 0.3),
                        const Color(0xFF0564B8).withValues(alpha: 0.7),
                        const Color(0xFF001F81),
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Next button
            Positioned(
              left: 0,
              right: 0,
              bottom: 90,
              child: Center(
                child: GestureDetector(
                  onTap: _handleNext,
                  child: Container(
                    width: 287,
                    height: 64,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(63)),
                    ),
                    child: const Center(
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Color(0xFF0796DE),
                          fontSize: 32,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillIcon() {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 8,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 12,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF11A2EB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 4,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 12,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF11A2EB),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinesIcon() {
    return SizedBox(
      width: 32,
      height: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 22, height: 2, color: const Color(0xFF11A2EB)),
          const SizedBox(height: 3),
          Container(width: 22, height: 2, color: const Color(0xFF11A2EB)),
          const SizedBox(height: 3),
          Container(width: 22, height: 2, color: const Color(0xFF11A2EB)),
          const SizedBox(height: 3),
          Container(width: 11, height: 2, color: const Color(0xFF11A2EB)),
        ],
      ),
    );
  }

  Widget _buildTimeBadge(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(63)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF11A2EB),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeTime(time),
            child: Container(
              width: 16,
              height: 16,
              decoration: const ShapeDecoration(
                color: Color(0xFF11A2EB),
                shape: OvalBorder(),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 10),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'None';
    const months = [
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
    return '${months[date.month - 1]} ${date.day}';
  }

  Future<void> _pickStartDate() async {
    final picked = await _showCustomDatePicker(_startDate);
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await _showCustomDatePicker(_endDate ?? _startDate);
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<DateTime?> _showCustomDatePicker(DateTime initial) async {
    return await showDialog<DateTime>(
      context: context,
      builder: (context) => _CustomCalendarDialog(initialDate: initial),
    );
  }

  Widget _buildFrequencySection() {
    final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final frequencies = [
      {'label': 'Days of week', 'sub': 'Choose days to take'},
      {'label': 'Interval', 'sub': 'Choose days to take'},
      {'label': 'Cycle', 'sub': 'Active period + break period repeat'},
      {'label': 'As needed', 'sub': 'Take when needed, no fixed time'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            'Frequency',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              letterSpacing: -0.32,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Frequency options card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Column(
              children: frequencies.asMap().entries.map((entry) {
                final f = entry.value;
                final isSelected = _selectedFrequency == f['label'];
                final isLast = entry.key == frequencies.length - 1;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFrequency = f['label']!),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF0796DE)
                                          : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? const Color(0xFF0796DE)
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 14)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  f['label']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF0796DE)
                                        : const Color(0xFF1E1E1E),
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 34),
                              child: Text(
                                f['sub']!,
                                style: const TextStyle(
                                  color: Color(0xFF9F9EA5),
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            // Day selector only for "Days of week"
                            if (isSelected && f['label'] == 'Days of week') ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(7, (i) {
                                  final active = _selectedDays[i];
                                  return GestureDetector(
                                    onTap: () => setState(() =>
                                        _selectedDays[i] = !_selectedDays[i]),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: active
                                            ? const Color(0xFF0796DE)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: active
                                              ? const Color(0xFF0796DE)
                                              : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          dayLabels[i],
                                          style: TextStyle(
                                            color: active
                                                ? Colors.white
                                                : Colors.grey.shade500,
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
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                          height: 1,
                          color: Colors.grey.shade200,
                          indent: 16,
                          endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Start / End date row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            children: [
              // Start date
              Expanded(
                child: GestureDetector(
                  onTap: _pickStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.play_arrow,
                                color: Color(0xFF0796DE), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Start date',
                              style: TextStyle(
                                color: Color(0xFF9F9EA5),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(_startDate),
                          style: const TextStyle(
                            color: Color(0xFF0796DE),
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // End date
              Expanded(
                child: GestureDetector(
                  onTap: _pickEndDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.stop,
                                color: Color(0xFF0796DE), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'End date',
                              style: TextStyle(
                                color: Color(0xFF9F9EA5),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(_endDate),
                          style: const TextStyle(
                            color: Color(0xFF0796DE),
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
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

        const SizedBox(height: 20),
      ],
    );
  }

  List<Widget> _buildDecorativeCircles() {
    return [
      AnimatedBuilder(
        animation: _floatAnimation1,
        builder: (context, child) {
          final o = _floatAnimation1.value;
          return Positioned(
            left: 124.48 + o.dx,
            top: 5.38 + o.dy,
            child: Transform.rotate(
              angle: 0.53,
              child: Container(
                width: 183,
                height: 183,
                decoration: const ShapeDecoration(
                  shape: OvalBorder(
                      side: BorderSide(width: 30, color: Color(0xFF10A2EA))),
                ),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation2,
        builder: (context, child) {
          final o = _floatAnimation2.value;
          return Positioned(
            left: 112.01 + o.dx,
            top: 104.44 + o.dy,
            child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                angle: 3.03,
                child: Container(
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
          );
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation3,
        builder: (context, child) {
          final o = _floatAnimation3.value;
          return Positioned(
            left: 14.30 + o.dx,
            top: -19.87 + o.dy,
            child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                angle: 0.57,
                child: Container(
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
          );
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation4,
        builder: (context, child) {
          final o = _floatAnimation4.value;
          return Positioned(
            left: 92.99 + o.dx,
            top: 216.82 + o.dy,
            child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                angle: 3.03,
                child: Container(
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
          );
        },
      ),
      // ── Static-turned-animated lower circles ─────────────────
      AnimatedBuilder(
        animation: _floatAnimation1,
        builder: (context, child) {
          final o = _floatAnimation1.value;
          return Positioned(
              left: 292.47 + o.dx,
              top: -117 + o.dy,
              child: Transform.rotate(
                  angle: 0.40,
                  child: Container(
                      width: 167,
                      height: 167,
                      decoration: const ShapeDecoration(
                          shape: OvalBorder(
                              side: BorderSide(
                                  width: 30, color: Color(0xFF10A2EA)))))));
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation2,
        builder: (context, child) {
          final o = _floatAnimation2.value;
          return Positioned(
              left: 366.60 + o.dx,
              top: 919.60 + o.dy,
              child: Container(
                  width: 183,
                  height: 183,
                  decoration: const ShapeDecoration(
                      shape: OvalBorder(
                          side: BorderSide(
                              width: 30, color: Color(0xFF10A2EA))))));
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation3,
        builder: (context, child) {
          final o = _floatAnimation3.value;
          return Positioned(
              left: 273.59 + o.dx,
              top: 622.74 + o.dy,
              child: Opacity(
                  opacity: 0.30,
                  child: Transform.rotate(
                      angle: 6.17,
                      child: Container(
                          width: 153.81,
                          height: 153.81,
                          decoration: const ShapeDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment(0.93, 0.35),
                                  end: Alignment(0.06, 0.40),
                                  colors: [
                                    Color(0xAFFDEDCA),
                                    Color(0xFF0A9BE2)
                                  ]),
                              shape: OvalBorder())))));
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation4,
        builder: (context, child) {
          final o = _floatAnimation4.value;
          return Positioned(
              left: 371.30 + o.dx,
              top: 757.60 + o.dy,
              child: Opacity(
                  opacity: 0.30,
                  child: Transform.rotate(
                      angle: 3.71,
                      child: Container(
                          width: 89.35,
                          height: 89.35,
                          decoration: const ShapeDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment(0.93, 0.35),
                                  end: Alignment(0.06, 0.40),
                                  colors: [
                                    Color(0xFFFDEDCA),
                                    Color(0xFF0A9BE2)
                                  ]),
                              shape: OvalBorder())))));
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation5,
        builder: (context, child) {
          final o = _floatAnimation5.value;
          return Positioned(
              left: 292.61 + o.dx,
              top: 787.82 + o.dy,
              child: Opacity(
                  opacity: 0.30,
                  child: Transform.rotate(
                      angle: 6.17,
                      child: Container(
                          width: 94.08,
                          height: 94.08,
                          decoration: const ShapeDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment(0.93, 0.35),
                                  end: Alignment(0.06, 0.40),
                                  colors: [
                                    Color(0xAFFDEDCA),
                                    Color(0xFF0A9BE2)
                                  ]),
                              shape: OvalBorder())))));
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation6,
        builder: (context, child) {
          final o = _floatAnimation6.value;
          return Positioned(
              left: 93.13 + o.dx,
              top: 755.42 + o.dy,
              child: Transform.rotate(
                  angle: 3.54,
                  child: Container(
                      width: 167,
                      height: 167,
                      decoration: const ShapeDecoration(
                          shape: OvalBorder(
                              side: BorderSide(
                                  width: 30, color: Color(0xFF10A2EA)))))));
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation7,
        builder: (context, child) {
          final o = _floatAnimation7.value;
          return Positioned(
              left: 249.59 + o.dx,
              top: 336.74 + o.dy,
              child: Opacity(
                  opacity: 0.30,
                  child: Transform.rotate(
                      angle: 6.17,
                      child: Container(
                          width: 153.81,
                          height: 153.81,
                          decoration: const ShapeDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment(0.93, 0.35),
                                  end: Alignment(0.06, 0.40),
                                  colors: [
                                    Color(0xAFFDEDCA),
                                    Color(0xFF0A9BE2)
                                  ]),
                              shape: OvalBorder())))));
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation8,
        builder: (context, child) {
          final o = _floatAnimation8.value;
          return Positioned(
              left: 371.17 + o.dx,
              top: 421.47 + o.dy,
              child: Opacity(
                  opacity: 0.30,
                  child: Transform.rotate(
                      angle: 3.71,
                      child: Container(
                          width: 89.35,
                          height: 89.35,
                          decoration: const ShapeDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment(0.93, 0.35),
                                  end: Alignment(0.06, 0.40),
                                  colors: [
                                    Color(0xFFFDEDCA),
                                    Color(0xFF0A9BE2)
                                  ]),
                              shape: OvalBorder())))));
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation1,
        builder: (context, child) {
          final o = _floatAnimation1.value;
          return Positioned(
              left: 209 + o.dy,
              top: 505.49 - o.dx, // cross-axis for variety
              child: Opacity(
                  opacity: 0.30,
                  child: Transform.rotate(
                      angle: 6.17,
                      child: Container(
                          width: 94.08,
                          height: 94.08,
                          decoration: const ShapeDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment(0.93, 0.35),
                                  end: Alignment(0.06, 0.40),
                                  colors: [
                                    Color(0xAFFDEDCA),
                                    Color(0xFF0A9BE2)
                                  ]),
                              shape: OvalBorder())))));
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation3,
        builder: (context, child) {
          final o = _floatAnimation3.value;
          return Positioned(
              left: 69.13 + o.dx,
              top: 469.42 + o.dy,
              child: Transform.rotate(
                  angle: 3.54,
                  child: Container(
                      width: 167,
                      height: 167,
                      decoration: const ShapeDecoration(
                          shape: OvalBorder(
                              side: BorderSide(
                                  width: 30, color: Color(0xFF10A2EA)))))));
        },
      ),
      AnimatedBuilder(
        animation: _floatAnimation5,
        builder: (context, child) {
          final o = _floatAnimation5.value;
          return Positioned(
              left: 490 + o.dx,
              top: 284 + o.dy,
              child: Transform.rotate(
                  angle: 3.14,
                  child: Container(
                      width: 183,
                      height: 183,
                      decoration: const ShapeDecoration(
                          shape: OvalBorder(
                              side: BorderSide(
                                  width: 30, color: Color(0xFF10A2EA)))))));
        },
      ),
    ];
  }
}

// ─── Custom Calendar Dialog ───────────────────────────────────────────────────

class _CustomCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  const _CustomCalendarDialog({required this.initialDate});

  @override
  State<_CustomCalendarDialog> createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<_CustomCalendarDialog> {
  late DateTime _displayMonth;
  late DateTime _selected;

  static const _months = [
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
  static const _shortDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _dayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _displayMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  void _prevMonth() => setState(() =>
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1));

  void _nextMonth() => setState(() =>
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1));

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sun=0
    final cells = <DateTime?>[];
    for (int i = 0; i < startWeekday; i++) {
      cells.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_displayMonth.year, _displayMonth.month, d));
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildCalendarDays();
    final today = DateTime.now();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected date display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0796DE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${_shortDays[_selected.weekday % 7]}, ${_months[_selected.month - 1].substring(0, 3)} ${_selected.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _prevMonth,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: Color(0xFF0796DE)),
                  ),
                ),
                Text(
                  '${_months[_displayMonth.month - 1]} ${_displayMonth.year}',
                  style: const TextStyle(
                    color: Color(0xFF0796DE),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: _nextMonth,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: Color(0xFF0796DE)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Day headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _dayLetters
                  .map((d) => SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              color: Color(0xFF0796DE),
                              fontSize: 13,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 6),

            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 0,
                childAspectRatio: 1,
              ),
              itemCount: cells.length,
              itemBuilder: (context, index) {
                final date = cells[index];
                if (date == null) return const SizedBox();

                final isSelected = date.year == _selected.year &&
                    date.month == _selected.month &&
                    date.day == _selected.day;
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                return GestureDetector(
                  onTap: () => setState(() => _selected = date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0796DE)
                          : isToday
                              ? const Color(0xFFE8F5FE)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? const Color(0xFF0796DE)
                                  : const Color(0xFF5FB6D7),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: isSelected || isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Cancel / OK buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5FE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF0796DE),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, _selected),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0796DE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
