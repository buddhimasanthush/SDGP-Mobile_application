import 'package:flutter/material.dart';
import 'payment_gateway_page.dart';
import 'pharmacy_detail_page.dart';

class PharmacyListPage extends StatefulWidget {
  const PharmacyListPage({super.key});

  @override
  State<PharmacyListPage> createState() => _PharmacyListPageState();
}

class _PharmacyListPageState extends State<PharmacyListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  // Demo pharmacy data
  final List<Map<String, dynamic>> pharmacies = [
    {
      'name': 'Health link Phama',
      'distance': '2.5 km',
      'availability': '6/6 Available',
      'location': 'Narahenp',
      'accepted': 56,
      'cancelled': 4,
      'rating': 4.8,
      'total': 'RS.5,900',
      'notAvailable': '100%+',
    },
    {
      'name': 'Asiri Health',
      'distance': '3.2 km',
      'availability': '6/6 Available',
      'location': 'Narahenpita',
      'accepted': 65,
      'cancelled': 3,
      'rating': 4.9,
      'total': 'RS.6,150',
      'notAvailable': '100%+',
    },
    {
      'name': 'Healthy Clinic ABC',
      'distance': '2.5 km',
      'availability': '5/6 Available',
      'location': 'Colombo 07',
      'accepted': 48,
      'cancelled': 5,
      'rating': 4.5,
      'total': 'RS.5,800',
      'notAvailable': '90%+',
    },
    {
      'name': 'Fauget Clinic 24',
      'distance': '3.8 km',
      'availability': '6/6 Available',
      'location': 'Bambalapitiya',
      'accepted': 72,
      'cancelled': 2,
      'rating': 4.7,
      'total': 'RS.6,200',
      'notAvailable': '100%+',
    },
    {
      'name': 'Medicare Pharmacy',
      'distance': '4.2 km',
      'availability': '5/6 Available',
      'location': 'Wellawatta',
      'accepted': 58,
      'cancelled': 6,
      'rating': 4.4,
      'total': 'RS.5,950',
      'notAvailable': '85%+',
    },
  ];

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
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF0796DE),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Searching nearby',
                              style: TextStyle(
                                color: Color(0xFFFAFAFA),
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Pharmacies',
                              style: TextStyle(
                                color: Color(0xFFFAFAFA),
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.gps_fixed,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 24),
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFA2E0FF),
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Send to ',
                      style: TextStyle(
                        color: Color(0xFFA2E0FF),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Text(
                      'My Home',
                      style: TextStyle(
                        color: Color(0xFFDEF4FF),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Animated pharmacy list
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            '5km Radius',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: pharmacies.length,
                              itemBuilder: (context, index) {
                                return _PharmacyListCard(
                                  pharmacy: pharmacies[index],
                                );
                              },
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
        ],
      ),
    );
  }
}

class _PharmacyListCard extends StatelessWidget {
  final Map<String, dynamic> pharmacy;

  const _PharmacyListCard({required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PharmacyDetailPage(pharmacy: pharmacy),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0796DE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_pharmacy,
                    color: Color(0xFF0796DE),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${pharmacy['availability']}    ${pharmacy['location']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: Color(0xFF919191),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Not Available',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: Color(0xFF919191),
                  ),
                ),
                const Spacer(),
                Text(
                  'Total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: Color(0xFF919191),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  pharmacy['notAvailable'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  pharmacy['total'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0796DE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatBox(
                  label: 'Accepted',
                  value: '${pharmacy['accepted']}%',
                  color: const Color(0xFF4DD0E1),
                ),
                _StatBox(
                  label: 'Cancelled',
                  value: '${pharmacy['cancelled']}%',
                  color: const Color(0xFF4DD0E1),
                ),
                _StatBox(
                  label: 'Rating',
                  value: '${pharmacy['rating']}',
                  color: const Color(0xFF4DD0E1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentGatewayPage(
                        amount: pharmacy['total'] ?? 'RS.0',
                        pharmacyName: pharmacy['name'] ?? 'Pharmacy',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0796DE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'Poppins',
              color: Color(0xFF919191),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
