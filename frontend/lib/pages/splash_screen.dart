import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'user_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _upperCurveController;
  late AnimationController _lowerCurveController;
  late AnimationController _scaleController;
  late AnimationController _spinController;

  late Animation<Offset> _upperCurveAnimation;
  late Animation<Offset> _lowerCurveAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _spinAnimation;

  bool _showCombinedLogo = false;
  bool _showScalingLogo = false;
  bool _showSpinningLogo = false;

  @override
  void initState() {
    super.initState();

    // Upper curve animation (from straight top)
    _upperCurveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _upperCurveAnimation = Tween<Offset>(
      begin: const Offset(0, -2.0), // Straight down from top
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _upperCurveController,
      curve: Curves.easeOutCubic,
    ));

    // Lower curve animation (from straight bottom)
    _lowerCurveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _lowerCurveAnimation = Tween<Offset>(
      begin: const Offset(0, 2.0), // Straight up from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _lowerCurveController,
      curve: Curves.easeOutCubic,
    ));

    // Scale down animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.15, // Scale down to 15% of original size
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Spin animation
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _spinAnimation = Tween<double>(
      begin: 0,
      end: 2, // 2 full rotations
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeInOut,
    ));

    // Start animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Wait 500ms to show blue screen
    await Future.delayed(const Duration(milliseconds: 500));

    // Start both curves animating in from top and bottom
    _upperCurveController.forward();
    _lowerCurveController.forward();

    // Wait for curves to finish merging
    await Future.delayed(const Duration(milliseconds: 800));

    // Show combined logo
    setState(() {
      _showCombinedLogo = true;
    });

    // Small delay before scaling
    await Future.delayed(const Duration(milliseconds: 200));

    // Start scaling down
    setState(() {
      _showScalingLogo = true;
    });
    _scaleController.forward();

    // Wait for scale to finish
    await Future.delayed(const Duration(milliseconds: 600));

    // Start spinning
    setState(() {
      _showSpinningLogo = true;
    });
    _spinController.forward();

    // Wait for spin to finish
    await Future.delayed(const Duration(milliseconds: 1500));

    final isLoggedIn = await _restoreStartupSession();

    if (mounted) {
      if (isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/terms');
      }
    }
  }

  Future<bool> _restoreStartupSession() async {
    try {
      await UserStore.instance.loadFromLocal();
      final prefs = await SharedPreferences.getInstance();

      if (AuthService.currentSession != null) {
        await UserStore.instance.syncFromRemote();
        return true;
      }

      final isLoggedInViaSmtp = prefs.getBool('is_logged_in_via_smtp') == true;
      final savedEmail = prefs.getString('smtp_logged_in_email')?.trim();

      if (isLoggedInViaSmtp && savedEmail != null && savedEmail.isNotEmpty) {
        try {
          await AuthService.signInByEmail(savedEmail);
          await UserStore.instance.syncFromRemote();
          return AuthService.currentSession != null;
        } catch (_) {
          await prefs.remove('is_logged_in_via_smtp');
          await prefs.remove('smtp_logged_in_email');
          await UserStore.instance.clearLocal();
          return false;
        }
      }

      if (isLoggedInViaSmtp) {
        await prefs.remove('is_logged_in_via_smtp');
        await prefs.remove('smtp_logged_in_email');
      }

      await UserStore.instance.clearLocal();
    } catch (_) {
      return false;
    }

    return false;
  }

  @override
  void dispose() {
    _upperCurveController.dispose();
    _lowerCurveController.dispose();
    _scaleController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0796DE), // Your app blue
              Color(0xFF0A9BE2),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles (optional, matching your design)
            _buildDecorativeCircles(),

            // Logo animation - larger container for big curves
            Center(
              child: SizedBox(
                width: 600, // Much larger to accommodate big curves
                height: 600,
                child: _showCombinedLogo
                    ? Center(
                        child: _buildCombinedLogo()) // Center the small logo
                    : _buildSeparateCurves(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparateCurves() {
    return Stack(
      children: [
        // Upper curve (dark blue) from top-left - MUCH LARGER
        SlideTransition(
          position: _upperCurveAnimation,
          child: Image.asset(
            'assets/images/logo upper layer 1.png',
            width: 522, // Much larger to match Figma
            height: 449,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 522,
                height: 449,
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
              );
            },
          ),
        ),

        // Lower curve (light blue) from bottom-right - MUCH LARGER
        SlideTransition(
          position: _lowerCurveAnimation,
          child: Image.asset(
            'assets/images/logo lower layer 1.png',
            width: 594, // Much larger to match Figma
            height: 609,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 594,
                height: 609,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(100),
                    bottomLeft: Radius.circular(100),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedLogo() {
    Widget logoWidget = Image.asset(
      'assets/images/New logo without text 2.png',
      width: 600, // Full size initially
      height: 600,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.medical_services,
          size: 300,
          color: Colors.white,
        );
      },
    );

    // Apply scale animation if scaling
    if (_showScalingLogo) {
      logoWidget = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: logoWidget,
      );
    }

    // Apply spin animation if spinning
    if (_showSpinningLogo) {
      logoWidget = AnimatedBuilder(
        animation: _spinAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _spinAnimation.value * 2 * 3.14159,
            child: child,
          );
        },
        child: SizedBox(
          width: 80,
          height: 80,
          child: Image.asset(
            'assets/images/New logo without text 2.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.medical_services,
                size: 40,
                color: Colors.white,
              );
            },
          ),
        ),
      );
    }

    return logoWidget;
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        // Top-left circles
        Positioned(
          left: 12,
          top: 90.6,
          child: Container(
            width: 183,
            height: 183,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 30, color: const Color(0xFF10A2EA)),
            ),
          ),
        ),
        Positioned(
          left: 105.01,
          top: 112.44,
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
          left: 7.30,
          top: -11.87,
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
          left: 85.98,
          top: 224.82,
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
          left: 285.47,
          top: -109,
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

        // Bottom-right circles
        Positioned(
          left: 362.60,
          top: 839.60,
          child: Container(
            width: 183,
            height: 183,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 30, color: const Color(0xFF10A2EA)),
            ),
          ),
        ),
        Positioned(
          left: 269.59,
          top: 542.74,
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
          left: 367.30,
          top: 677.60,
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
          left: 288.61,
          top: 707.82,
          child: Opacity(
            opacity: 0.30,
            child: Transform.rotate(
              angle: 6.17,
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
          left: 89.13,
          top: 675.42,
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
