import 'package:flutter/material.dart';

class WelcomeBackPage extends StatefulWidget {
  const WelcomeBackPage({super.key});

  @override
  State<WelcomeBackPage> createState() => _WelcomeBackPageState();
}

class _WelcomeBackPageState extends State<WelcomeBackPage>
    with SingleTickerProviderStateMixin {
  bool _isSignInSelected = true; // Default to Sign In selected
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always reset to Sign In selected when page becomes active
    setState(() {
      _isSignInSelected = true;
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _toggleSelection(bool isSignIn) {
    // Navigate immediately without waiting for animation
    if (mounted) {
      if (isSignIn) {
        Navigator.pushNamed(context, '/signin');
      } else {
        Navigator.pushNamed(context, '/signup');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0796DE),
        ),
        child: Stack(
          children: [
            // Decorative circles (matching Figma exactly)
            _buildDecorativeCircles(),

            // Main content centered
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Logo - centered
                  Image.asset(
                    'assets/images/New logo VERT 1.png',
                    width: 132,
                    height: 74,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.medical_services,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'MediFind',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // Welcome Back text - centered
                  const Text(
                    'Welcome\nBack',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -0.48,
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Bottom buttons with sliding pill - EXACT Figma design
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 100,
                child: Stack(
                  children: [
                    // Sliding white pill with sharp edges on sides
                    AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        // Calculate position: left side when Sign In, right side when Sign Up
                        final leftPosition =
                            _slideAnimation.value * (screenWidth / 2) - 76;

                        return Positioned(
                          left: leftPosition,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: (screenWidth / 2) +
                                76, // Width extends beyond screen
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(63),
                                topRight: Radius.circular(63),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Button texts
                    Row(
                      children: [
                        // Sign In button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleSelection(true),
                            child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  color: _isSignInSelected
                                      ? const Color(0xFF0796DE)
                                      : Colors.white,
                                  fontSize: 32,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.32,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Sign Up button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleSelection(false),
                            child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color: !_isSignInSelected
                                      ? const Color(0xFF0796DE)
                                      : Colors.white,
                                  fontSize: 32,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.32,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          left: 124.48,
          top: 5.38,
          child: Transform.rotate(
            angle: 0.53,
            child: Container(
              width: 183,
              height: 183,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 30, color: const Color(0xFF10A2EA)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 112.01,
          top: 104.44,
          child: Opacity(
            opacity: 0.30,
            child: Transform.rotate(
              angle: 3.03,
              child: Container(
                width: 153.81,
                height: 153.81,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(0.93, 0.35),
                    end: Alignment(0.06, 0.40),
                    colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 14.30,
          top: -19.87,
          child: Opacity(
            opacity: 0.30,
            child: Transform.rotate(
              angle: 0.57,
              child: Container(
                width: 89.35,
                height: 89.35,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(0.93, 0.35),
                    end: Alignment(0.06, 0.40),
                    colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 92.99,
          top: 216.82,
          child: Opacity(
            opacity: 0.30,
            child: Transform.rotate(
              angle: 3.03,
              child: Container(
                width: 94.08,
                height: 94.08,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(0.93, 0.35),
                    end: Alignment(0.06, 0.40),
                    colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 292.47,
          top: -117,
          child: Transform.rotate(
            angle: 0.40,
            child: Container(
              width: 167,
              height: 167,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 30, color: const Color(0xFF10A2EA)),
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(0.93, 0.35),
                    end: Alignment(0.06, 0.40),
                    colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                  ),
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(0.93, 0.35),
                    end: Alignment(0.06, 0.40),
                    colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)],
                  ),
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 30, color: const Color(0xFF10A2EA)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
