import 'package:flutter/material.dart';
import 'upload_prescription_main_page.dart';
import 'pharmacy_registration_page.dart';
import 'reminder_page.dart';
import 'previous_orders_page.dart';
import 'health_profile_page.dart';

class AllServicesPage extends StatefulWidget {
  const AllServicesPage({super.key});

  @override
  State<AllServicesPage> createState() => _AllServicesPageState();
}

class _AllServicesPageState extends State<AllServicesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'name': 'Upload Prescription',
        'icon': Icons.upload_file,
        'page': const UploadPrescriptionMainPage(),
      },
      {
        'name': 'Reminder',
        'icon': Icons.alarm,
        'page': const ReminderPage(),
      },
      {
        'name': 'Past Orders',
        'icon': Icons.history,
        'page': const PreviousOrdersPage(),
      },
      {
        'name': 'Register Pharmacy',
        'icon': Icons.local_pharmacy,
        'page': const PharmacyRegistrationPage(),
      },
      {
        'name': 'View Your Account',
        'icon': Icons.account_circle,
        'page': const HealthProfilePage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Services',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF0796DE),
        foregroundColor: Colors.white,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _ServiceListItem(
              name: service['name'] as String,
              icon: service['icon'] as IconData,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => service['page'] as Widget,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ServiceListItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceListItem({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          border: Border.all(
            width: 1,
            color: const Color(0xFFEFEFEF),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF0796DE).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0796DE),
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF919191),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
