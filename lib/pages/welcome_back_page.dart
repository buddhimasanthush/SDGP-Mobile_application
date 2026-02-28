import 'package:flutter/material.dart';

class WelcomeBackPage extends StatefulWidget {
  const WelcomeBackPage({super.key});

  @override
  State<WelcomeBackPage> createState() => _WelcomeBackPageState();
}

class _WelcomeBackPageState extends State<WelcomeBackPage>
    with TickerProviderStateMixin {
  bool _isSignInSelected = true; // Default to Sign In selected

  // Pill sliding animation
  AnimationController? _slideController;
  Animation<double>? _slideAnimation;

  // Floating animations for circles
  AnimationController? _floatController1;
  AnimationController? _floatController2;
  AnimationController? _floatController3;
  AnimationController? _floatController4;
  AnimationController? _floatController5;
  AnimationController? _floatController6;

  Animation<Offset>? _floatAnimation1;
  Animation<Offset>? _floatAnimation2;
  Animation<Offset>? _floatAnimation3;
  Animation<Offset>? _floatAnimation4;
  Animation<Offset>? _floatAnimation5;
  Animation<Offset>? _floatAnimation6;

  @override
  void initState() {
    super.initState();

    // Sliding pill animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController!, curve: Curves.easeInOut),
    );

    // Floating animations for circles
    _floatController1 = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatController2 = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _floatController3 = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _floatController4 = AnimationController(
      duration: const Duration(seconds: 3, milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _floatController5 = AnimationController(
      duration: const Duration(seconds: 4, milliseconds: 200),
      vsync: this,
    )..repeat(reverse: true);

    _floatController6 = AnimationController(
      duration: const Duration(seconds: 3, milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // Different floating patterns for each circle - INCREASED DISTANCES
    _floatAnimation1 = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(25, -35), // Increased from (15, -20)
    ).animate(
        CurvedAnimation(parent: _floatController1!, curve: Curves.easeInOut));

    _floatAnimation2 = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-20, 30), // Increased from (-10, 15)
    ).animate(
        CurvedAnimation(parent: _floatController2!, curve: Curves.easeInOut));

    _floatAnimation3 = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(35, 20), // Increased from (20, 10)
    ).animate(
        CurvedAnimation(parent: _floatController3!, curve: Curves.easeInOut));

    _floatAnimation4 = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-25, -30), // Increased from (-15, -15)
    ).animate(
        CurvedAnimation(parent: _floatController4!, curve: Curves.easeInOut));

    _floatAnimation5 = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(30, 25), // NEW - circle behind "Welcome Back"
    ).animate(
        CurvedAnimation(parent: _floatController5!, curve: Curves.easeInOut));

    _floatAnimation6 = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-30, 20), // NEW - another visible circle
    ).animate(
        CurvedAnimation(parent: _floatController6!, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _slideController?.dispose();
    _floatController1?.dispose();
    _floatController2?.dispose();
    _floatController3?.dispose();
    _floatController4?.dispose();
    _floatController5?.dispose();
    _floatController6?.dispose();
    super.dispose();
  }

  void _navigateToPage(bool isSignIn) {
    if (_slideController == null) return;

    setState(() {
      _isSignInSelected = isSignIn;
    });

    // Animate the pill
    if (isSignIn) {
      _slideController!.reverse();
    } else {
      _slideController!.forward();
    }

    // Wait for animation, then navigate
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        if (isSignIn) {
          Navigator.pushNamed(context, '/signin').then((_) {
            // Reset to Sign In when coming back
            if (mounted && _slideController != null) {
              setState(() {
                _isSignInSelected = true;
              });
              _slideController!.reset();
            }
          });
        } else {
          Navigator.pushNamed(context, '/signup').then((_) {
            // Stay on Sign Up when coming back
            if (mounted && _slideController != null) {
              setState(() {
                _isSignInSelected = false;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _slideController != null) {
                  _slideController!.value = 1.0;
                }
              });
            }
          });
        }
      }
    });
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
                              color: Colors.white.withOpacity(0.3),
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
                    // Animated sliding white pill - using AnimatedPositioned
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: _isSignInSelected ? -76 : (screenWidth / 2) - 76,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: (screenWidth / 2) + 76,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(63),
                            topRight: Radius.circular(63),
                          ),
                        ),
                      ),
                    ),

                    // Button texts
                    Row(
                      children: [
                        // Sign In button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _navigateToPage(true),
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
                            onTap: () => _navigateToPage(false),
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
        // Circle 1 - Top center (Floating)
        AnimatedBuilder(
          animation: _floatAnimation1 ?? AlwaysStoppedAnimation(Offset.zero),
          builder: (context, child) {
            final offset = _floatAnimation1?.value ?? Offset.zero;
            return Positioned(
              left: 124.48 + offset.dx,
              top: 5.38 + offset.dy,
              child: Transform.rotate(
                angle: 0.53,
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
            );
          },
        ),

        // Circle 2 - Left gradient (Floating)
        AnimatedBuilder(
          animation: _floatAnimation2 ?? AlwaysStoppedAnimation(Offset.zero),
          builder: (context, child) {
            final offset = _floatAnimation2?.value ?? Offset.zero;
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
            );
          },
        ),

        // Circle 3 - Small top left (Floating)
        AnimatedBuilder(
          animation: _floatAnimation5 ?? AlwaysStoppedAnimation(Offset.zero),
          builder: (context, child) {
            final offset = _floatAnimation5?.value ?? Offset.zero;
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
            );
          },
        ),

        // Circle 4 - Small middle left (Floating)
        AnimatedBuilder(
          animation: _floatAnimation6 ?? AlwaysStoppedAnimation(Offset.zero),
          builder: (context, child) {
            final offset = _floatAnimation6?.value ?? Offset.zero;
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
            );
          },
        ),

        // Circle 5 - Top right border (Floating)
        AnimatedBuilder(
          animation: _floatAnimation3 ?? AlwaysStoppedAnimation(Offset.zero),
          builder: (context, child) {
            final offset = _floatAnimation3?.value ?? Offset.zero;
            return Positioned(
              left: 292.47 + offset.dx,
              top: -117 + offset.dy,
              child: Transform.rotate(
                angle: 0.40,
                child: Container(
                  width: 167,
                  height: 167,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(width: 30, color: const Color(0xFF10A2EA)),
                  ),
                ),
              ),
            );
          },
        ),

        // Circle 6 - Middle right gradient (Floating)
        AnimatedBuilder(
          animation: _floatAnimation4 ?? AlwaysStoppedAnimation(Offset.zero),
          builder: (context, child) {
            final offset = _floatAnimation4?.value ?? Offset.zero;
            return Positioned(
              left: 249.59 + offset.dx,
              top: 336.74 + offset.dy,
              child: Opacity(
                opacity: 0.30,
                child: Transform.rotate(
                  angle: 6.17,
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
            );
          },
        ),

        // Circle 7 - Small far right (Static)
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: const Alignment(0.93, 0.35),
                    end: const Alignment(0.06, 0.40),
                    colors: [const Color(0xFFFDEDCA), const Color(0xFF0A9BE2)],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Circle 8 - Bottom left border (Static)
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
