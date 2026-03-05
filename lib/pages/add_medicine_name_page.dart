import 'package:flutter/material.dart';

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
  List<String> _selectedTimes = [];

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  // Floating animations
  late AnimationController _floatController1;
  late AnimationController _floatController2;
  late AnimationController _floatController3;
  late AnimationController _floatController4;

  late Animation<Offset> _floatAnimation1;
  late Animation<Offset> _floatAnimation2;
  late Animation<Offset> _floatAnimation3;
  late Animation<Offset> _floatAnimation4;

  @override
  void initState() {
    super.initState();

    // Initialize scroll controllers
    _hourController = FixedExtentScrollController(initialItem: 7);
    _minuteController = FixedExtentScrollController(initialItem: 5);
    _periodController = FixedExtentScrollController(initialItem: 1);

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

    _floatAnimation1 =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(25, -35))
            .animate(CurvedAnimation(
                parent: _floatController1, curve: Curves.easeInOut));
    _floatAnimation2 =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-20, 30))
            .animate(CurvedAnimation(
                parent: _floatController2, curve: Curves.easeInOut));
    _floatAnimation3 =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(35, 20))
            .animate(CurvedAnimation(
                parent: _floatController3, curve: Curves.easeInOut));
    _floatAnimation4 =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-25, -30))
            .animate(CurvedAnimation(
                parent: _floatController4, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    _floatController1.dispose();
    _floatController2.dispose();
    _floatController3.dispose();
    _floatController4.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_medicineNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter medicine name')),
      );
      return;
    }

    if (!_showReminderTime) {
      setState(() {
        _showReminderTime = true;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          400,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    } else {
      // Save and exit
      print('Medicine: ${_medicineNameController.text}');
      print('Description: ${_descriptionController.text}');
      print('Times: $_selectedTimes');
      Navigator.pop(context);
    }
  }

  void _addTime() {
    int hour = _hourController.selectedItem % 12 + 1;
    int minute = _minuteController.selectedItem;
    String period = _periodController.selectedItem == 0 ? 'AM' : 'PM';
    String time =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    if (!_selectedTimes.contains(time)) {
      setState(() {
        _selectedTimes.add(time);
      });
    }
  }

  void _removeTime(String time) {
    setState(() {
      _selectedTimes.remove(time);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              physics: _showReminderTime
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: _showReminderTime ? 80 : 280),

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

                  const SizedBox(height: 33),

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

                  if (_showReminderTime) ...[
                    const SizedBox(height: 50),

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
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: _buildWheelPicker(
                                        12, _hourController,
                                        isHour: true)),
                                Expanded(
                                    child: _buildWheelPicker(
                                        60, _minuteController)),
                                Expanded(child: _buildPeriodPicker()),
                              ],
                            ),
                            Center(
                              child: Container(
                                height: 40,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 61),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF11A2EB),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: _addTime,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF002082),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)),
                        ),
                        child: const Center(
                          child: Text(
                            '+ Rings in 0 hr 8 min',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_selectedTimes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Wrap(
                          spacing: 9,
                          runSpacing: 8,
                          children: _selectedTimes
                              .map((time) => _buildTimeBadge(time))
                              .toList(),
                        ),
                      ),

                    const SizedBox(height: 200),
                  ] else
                    const SizedBox(height: 200),
                ],
              ),
            ),

            // Gradient
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 280,
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

  Widget _buildWheelPicker(int count, FixedExtentScrollController controller,
      {bool isHour = false}) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 30,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) => setState(() {}),
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: count,
        builder: (context, index) {
          bool isSelected = controller.selectedItem == index;
          return Center(
            child: Text(
              isHour
                  ? (index + 1).toString().padLeft(2, '0')
                  : index.toString().padLeft(2, '0'),
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF11A2EB),
                fontSize: isSelected ? 24 : 20,
                fontFamily: 'Poppins',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodPicker() {
    return ListWheelScrollView.useDelegate(
      controller: _periodController,
      itemExtent: 30,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) => setState(() {}),
      childDelegate: ListWheelChildListDelegate(
        children: ['AM', 'PM'].asMap().entries.map((entry) {
          bool isSelected = _periodController.selectedItem == entry.key;
          return Center(
            child: Text(
              entry.value,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF11A2EB),
                fontSize: isSelected ? 24 : 20,
                fontFamily: 'Poppins',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        }).toList(),
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
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeTime(time),
            child: Container(
              width: 14,
              height: 14,
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

  List<Widget> _buildDecorativeCircles() {
    return [
      AnimatedBuilder(
        animation: _floatAnimation1,
        builder: (context, child) {
          final offset = _floatAnimation1.value;
          return Positioned(
            left: 124.48 + offset.dx,
            top: 5.38 + offset.dy,
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
          final offset = _floatAnimation2.value;
          return Positioned(
            left: 112.01 + offset.dx,
            top: 104.44 + offset.dy,
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
          final offset = _floatAnimation3.value;
          return Positioned(
            left: 14.30 + offset.dx,
            top: -19.87 + offset.dy,
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
          final offset = _floatAnimation4.value;
          return Positioned(
            left: 92.99 + offset.dx,
            top: 216.82 + offset.dy,
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
      Positioned(
        left: 292.47,
        top: -117,
        child: Transform.rotate(
          angle: 0.40,
          child: Container(
            width: 167,
            height: 167,
            decoration: const ShapeDecoration(
              shape: OvalBorder(
                  side: BorderSide(width: 30, color: Color(0xFF10A2EA))),
            ),
          ),
        ),
      ),
      Positioned(
        left: 366.60,
        top: 919.60,
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
        left: 273.59,
        top: 622.74,
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
                  colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 371.30,
        top: 757.60,
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
                  colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 292.61,
        top: 787.82,
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
                  colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 93.13,
        top: 755.42,
        child: Transform.rotate(
          angle: 3.54,
          child: Container(
            width: 167,
            height: 167,
            decoration: const ShapeDecoration(
              shape: OvalBorder(
                  side: BorderSide(width: 30, color: Color(0xFF10A2EA))),
            ),
          ),
        ),
      ),
      Positioned(
        left: 249.59,
        top: 336.74,
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
                  colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 371.17,
        top: 421.47,
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
                  colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 209,
        top: 505.49,
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
                  colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 69.13,
        top: 469.42,
        child: Transform.rotate(
          angle: 3.54,
          child: Container(
            width: 167,
            height: 167,
            decoration: const ShapeDecoration(
              shape: OvalBorder(
                  side: BorderSide(width: 30, color: Color(0xFF10A2EA))),
            ),
          ),
        ),
      ),
      Positioned(
        left: 490,
        top: 284,
        child: Transform.rotate(
          angle: 3.14,
          child: Container(
            width: 183,
            height: 183,
            decoration: const ShapeDecoration(
              shape: OvalBorder(
                  side: BorderSide(width: 30, color: Color(0xFF10A2EA))),
            ),
          ),
        ),
      ),
    ];
  }
}
