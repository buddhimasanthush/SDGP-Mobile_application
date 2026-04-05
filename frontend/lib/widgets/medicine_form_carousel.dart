import 'package:flutter/material.dart';
import '../pages/medicine_form_page.dart';

class MedicineFormCarousel extends StatelessWidget {
  const MedicineFormCarousel({super.key});

  static const List<Map<String, dynamic>> forms = [
    {'name': 'Liquid', 'icon': Icons.water_drop_rounded},
    {'name': 'Capsule', 'icon': Icons.medication_rounded},
    {'name': 'Tablet', 'icon': Icons.circle_rounded},
    {'name': 'Syringe', 'icon': Icons.vaccines_rounded},
    {'name': 'Pills', 'icon': Icons.medication_liquid_rounded},
    {'name': 'Suspension', 'icon': Icons.opacity_rounded},
    {'name': 'Drops', 'icon': Icons.water_rounded},
    {'name': 'Infusion', 'icon': Icons.local_hospital_rounded},
    {'name': 'Cream', 'icon': Icons.wash_rounded},
    {'name': 'Ointment', 'icon': Icons.healing_rounded},
    {'name': 'Spray', 'icon': Icons.air_rounded},
    {'name': 'Nebulizer', 'icon': Icons.cloud_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: forms.length,
        itemBuilder: (context, index) {
          final form = forms[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == forms.length - 1 ? 0 : 14,
            ),
            child: _MedicineFormItem(
              name: form['name'] as String,
              icon: form['icon'] as IconData,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicineFormPage(
                      formName: form['name'] as String,
                    ),
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

class _MedicineFormItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const _MedicineFormItem({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE68E2D), Color(0xFFF0A94A)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE68E2D).withOpacity(0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 9),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
