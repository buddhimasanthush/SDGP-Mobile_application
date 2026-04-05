import 'package:flutter/material.dart';
import '../pages/upload_prescription_main_page.dart';
import '../pages/previous_orders_page.dart';
import '../pages/health_profile_page.dart';
import '../pages/pharmacy_registration_page.dart';

class ServicesCarousel extends StatelessWidget {
  const ServicesCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'name': 'Upload\nPrescription',
        'icon': Icons.upload_file_rounded,
        'gradient': [const Color(0xFF0796DE), const Color(0xFF0567A8)],
        'page': const UploadPrescriptionMainPage(),
      },
      {
        'name': 'Past\nOrders',
        'icon': Icons.history_rounded,
        'gradient': [const Color(0xFF0796DE), const Color(0xFF0567A8)],
        'page': const PreviousOrdersPage(),
      },
      {
        'name': 'Register\nPharmacy',
        'icon': Icons.local_pharmacy_rounded,
        'gradient': [const Color(0xFF0796DE), const Color(0xFF0567A8)],
        'page': const PharmacyRegistrationPage(),
      },
      {
        'name': 'My\nAccount',
        'icon': Icons.account_circle_rounded,
        'gradient': [const Color(0xFF0796DE), const Color(0xFF0567A8)],
        'page': const HealthProfilePage(),
      },
    ];

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == services.length - 1 ? 0 : 14,
            ),
            child: _ServiceItem(
              name: service['name'] as String,
              icon: service['icon'] as IconData,
              gradient: service['gradient'] as List<Color>,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => service['page'] as Widget,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.name,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 110,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0796DE).withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -12,
                    right: -12,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.10),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: -10,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(icon, color: Colors.white, size: 38),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
