import 'package:flutter/material.dart';
import '../widgets/medicine_form_carousel.dart';
import '../widgets/services_carousel.dart';
import '../widgets/pharmacy_card.dart';
import 'cart_page.dart';
import 'location_selector_page.dart';
import 'previous_orders_page.dart';
import 'all_services_page.dart';
import 'pharmacy_list_page.dart';

// This is the standalone HomePage - used when navigating FROM other pages
// It includes the bottom navigation bar
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedLocation = 'My Home';
  int cartItemCount = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with decorative circles
          _buildBackground(),
          
          // Main scrollable content
          _buildMainContent(),
        ],
      ),
      // This bottom nav bar is only shown when coming from other pages
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0796DE),
      child: Stack(
        children: [
          // Top left circle
          Positioned(
            left: 47,
            top: -96,
            child: Container(
              width: 183,
              height: 183,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 30,
                  color: const Color(0xFF10A2EA),
                ),
              ),
            ),
          ),
          // Middle gradient circle
          Positioned(
            left: 140.01,
            top: 200.85,
            child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                angle: 3.03,
                child: Container(
                  width: 153.81,
                  height: 153.81,
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
          // Top right small circle
          Positioned(
            left: 259.55,
            top: 92.25,
            child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                angle: 0.57,
                child: Container(
                  width: 89.35,
                  height: 89.35,
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
          // Top middle circle
          Positioned(
            left: 120.98,
            top: 35.77,
            child: Opacity(
              opacity: 0.30,
              child: Transform.rotate(
                angle: 3.03,
                child: Container(
                  width: 94.08,
                  height: 94.08,
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
          // Top right border circle
          Positioned(
            left: 320.47,
            top: 68.17,
            child: Transform.rotate(
              angle: 0.40,
              child: Container(
                width: 167,
                height: 167,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 30,
                    color: const Color(0xFF10A2EA),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
        children: [
          // Header Section
          _buildHeader(),
          const SizedBox(height: 20),
          
          // White content card
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      _buildSearchBar(),
                      const SizedBox(height: 35),
                      
                      // Recent Purchases Section
                      _buildSectionHeader('Recent perchances', onViewAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PreviousOrdersPage(),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      const MedicineFormCarousel(),
                      const SizedBox(height: 30),
                      
                      // More Services Section
                      _buildSectionHeader('More Services', onViewAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllServicesPage(),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      const ServicesCarousel(),
                      const SizedBox(height: 30),
                      
                      // Pharmacies Near You Section
                      _buildSectionHeader('Phamacies Near You', onViewAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PharmacyListPage(),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      _buildPharmaciesPreview(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Welcome User',
                style: TextStyle(
                  color: Color(0xFFFAFAFA),
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Cart Icon with Badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Color(0xFFFAFAFA),
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 19,
                        height: 19,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEB3636),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$cartItemCount',
                            style: const TextStyle(
                              color: Color(0xFFFAFAFA),
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Location selector
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationSelectorPage(),
                ),
              );
              if (result != null) {
                setState(() {
                  selectedLocation = result;
                });
              }
            },
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFA2E0FF),
                  size: 18,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Send to',
                  style: TextStyle(
                    color: Color(0xFFA2E0FF),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  selectedLocation,
                  style: const TextStyle(
                    color: Color(0xFFDEF4FF),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFDEF4FF),
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Color(0xFF919191),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Color(0xFF919191),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onSubmitted: (value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Searching for: $value')),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'View All',
              style: TextStyle(
                color: Color(0xFF919191),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPharmaciesPreview() {
    return Row(
      children: [
        Expanded(
          child: PharmacyCard(
            name: 'Healthy Clinic ABC',
            distance: '2.5 km',
            rating: 4.5,
            onTap: () {
              // Navigate to pharmacy details
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: PharmacyCard(
            name: 'Fauget Clinic 24',
            distance: '3.8 km',
            rating: 4.7,
            onTap: () {
              // Navigate to pharmacy details
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            isActive: true,
            onTap: () {},
          ),
          _buildNavItem(
            icon: Icons.access_time,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReminderPage(),
                ),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.person,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthProfilePage(),
                ),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.history,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PreviousOrdersPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0796DE) : Colors.transparent,
          borderRadius: BorderRadius.circular(9.20),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : const Color(0xFF919191),
          size: 24,
        ),
      ),
    );
  }
}

import 'reminder_page.dart';
import 'health_profile_page.dart';