import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/services_carousel.dart';
import '../widgets/pharmacy_card.dart';
import 'cart_page.dart';
import 'location_selector_page.dart';
import 'previous_orders_page.dart';
import 'all_services_page.dart';
import 'pharmacy_list_page.dart';
import 'reminder_page.dart';
import 'health_profile_page.dart';
import 'user_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedLocation = 'My Home';
  int cartItemCount = 6;

  String get _displayName {
    final name = UserStore.instance.profileName.trim();
    if (name.isEmpty) return 'User';
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildMainContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0796DE),
      child: Stack(children: [
        Positioned(
          left: 47,
          top: -96,
          child: Container(
            width: 183,
            height: 183,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 30, color: const Color(0xFF10A2EA))),
          ),
        ),
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
                            ])),
                  ))),
        ),
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
                            ])),
                  ))),
        ),
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
                            ])),
                  ))),
        ),
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
                    border:
                        Border.all(width: 30, color: const Color(0xFF10A2EA))),
              )),
        ),
      ]),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(children: [
        _buildHeader(),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 20),

                    // ── BANNER SLIDER ──────────────────────────────
                    const _BannerCarousel(),
                    const SizedBox(height: 30),

                    _buildSectionHeader('More Services', onViewAll: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AllServicesPage()));
                    }),
                    const SizedBox(height: 20),
                    const ServicesCarousel(),
                    const SizedBox(height: 30),

                    _buildSectionHeader('Pharmacies Near You', onViewAll: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PharmacyListPage()));
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
      ]),
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
              Text(
                'Welcome $_displayName',
                style: const TextStyle(
                    color: Color(0xFFFAFAFA),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500),
              ),
              Stack(children: [
                IconButton(
                    icon: const Icon(Icons.shopping_cart,
                        color: Color(0xFFFAFAFA), size: 28),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartPage()))),
                if (cartItemCount > 0)
                  Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 19,
                        height: 19,
                        decoration: const BoxDecoration(
                            color: Color(0xFFEB3636), shape: BoxShape.circle),
                        child: Center(
                            child: Text('$cartItemCount',
                                style: const TextStyle(
                                    color: Color(0xFFFAFAFA),
                                    fontSize: 10,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600))),
                      )),
              ]),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LocationSelectorPage()));
              if (result != null) setState(() => selectedLocation = result);
            },
            child: Row(children: [
              const Icon(Icons.location_on, color: Color(0xFFA2E0FF), size: 18),
              const SizedBox(width: 5),
              const Text('Send to',
                  style: TextStyle(
                      color: Color(0xFFA2E0FF),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400)),
              const SizedBox(width: 5),
              Text(selectedLocation,
                  style: const TextStyle(
                      color: Color(0xFFDEF4FF),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 5),
              const Icon(Icons.keyboard_arrow_down,
                  color: Color(0xFFDEF4FF), size: 18),
            ]),
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
          borderRadius: BorderRadius.circular(10)),
      child: TextField(
        decoration: const InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(
                color: Color(0xFF919191),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400),
            prefixIcon: Icon(Icons.search, color: Color(0xFF919191)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
        onSubmitted: (value) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Searching for: $value'))),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500)),
        if (onViewAll != null)
          GestureDetector(
              onTap: onViewAll,
              child: const Text('View All',
                  style: TextStyle(
                      color: Color(0xFF919191),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400))),
      ],
    );
  }

  Widget _buildPharmaciesPreview() {
    return Row(children: [
      Expanded(
          child: PharmacyCard(
              name: 'Asiri Hospital',
              distance: '2.5 km',
              rating: 4.5,
              brandColor: const Color(0xFF9B2AA0),
              onTap: () {})),
      const SizedBox(width: 16),
      Expanded(
          child: PharmacyCard(
              name: 'Union Chemists',
              distance: '3.8 km',
              rating: 4.7,
              brandColor: const Color(0xFFD4A017),
              onTap: () {})),
    ]);
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home, isActive: true, onTap: () {}),
          _buildNavItem(
              icon: Icons.access_time,
              isActive: false,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReminderPage()))),
          _buildNavItem(
              icon: Icons.person,
              isActive: false,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HealthProfilePage()))),
          _buildNavItem(
              icon: Icons.history,
              isActive: false,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PreviousOrdersPage()))),
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
            borderRadius: BorderRadius.circular(9.20)),
        child: Icon(icon,
            color: isActive ? Colors.white : const Color(0xFF919191), size: 24),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auto-sliding banner carousel
// ─────────────────────────────────────────────────────────────────────────────
class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  static const _banners = [
    'assets/app banners/banner 01.png',
    'assets/app banners/banner 02.png',
    'assets/app banners/banner 03.png',
    'assets/app banners/banner 04.png',
    'assets/app banners/ramadan banner.png',
  ];

  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final next = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _banners.length,
            itemBuilder: (_, i) => Image.asset(
              _banners[i],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF0796DE), Color(0xFF0567A8)])),
                child: const Center(
                    child: Icon(Icons.local_pharmacy,
                        color: Colors.white, size: 48)),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_banners.length, (i) {
          final active = i == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF0796DE)
                    : const Color(0xFF0796DE).withOpacity(0.3),
                borderRadius: BorderRadius.circular(4)),
          );
        }),
      ),
    ]);
  }
}
