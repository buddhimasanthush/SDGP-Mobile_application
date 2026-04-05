import 'package:flutter/material.dart';
import 'home_page.dart';

class DocVerificationSuccessPage extends StatelessWidget {
  const DocVerificationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0796DE),
        child: Stack(children: [
          _buildBackground(),
          SafeArea(
              child: Column(children: [
            _buildHeader(context),
            const Spacer(),
            _buildCard(context),
            const Spacer(),
          ])),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(children: [
        IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        const Expanded(
            child: Text('Submitted Documents',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFFFAFAFA),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500))),
        const SizedBox(width: 48),
      ]),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 21),
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
      decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(25)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // ── Figma success illustration ──────────────────────────────
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(clipBehavior: Clip.none, children: [
            // Outer circle with border
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5EEF1),
                  border: Border.all(
                      width: 4,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      color: const Color(0xFFBADDE9))),
            ),
            // Document body (light gradient rectangle)
            Positioned(
                left: 21,
                top: -15,
                child: Container(
                  width: 78,
                  height: 117,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFF9FDFF), Color(0x00F9FDFF)]),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x0F4B4B4B),
                            blurRadius: 30,
                            offset: Offset(0, 4))
                      ]),
                )),
            // Document line 1
            Positioned(
                left: 33,
                top: 60,
                child: Container(
                  width: 54,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x234B4B4B),
                            blurRadius: 20,
                            offset: Offset(0, 4))
                      ]),
                )),
            // Document line 2
            Positioned(
                left: 37,
                top: 80,
                child: Container(
                  width: 45,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x234B4B4B),
                            blurRadius: 20,
                            offset: Offset(0, 4))
                      ]),
                )),
            // Main green checkmark circle
            Positioned(
                left: 38,
                top: 8,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF30B94E), Color(0xFF7DF898)]),
                      border: Border.all(
                          width: 3, color: Colors.white.withOpacity(0.50))),
                  child: const Icon(Icons.check, color: Colors.white, size: 22),
                )),
            // Small green dot — right
            Positioned(
                left: 93,
                top: 64,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF30B94E), Color(0xFF7DF898)]),
                      border: Border.all(
                          width: 3, color: Colors.white.withOpacity(0.50))),
                )),
            // Small green dot — left
            Positioned(
                left: 15,
                top: 50,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF30B94E), Color(0xFF7DF898)]),
                      border: Border.all(
                          width: 3, color: Colors.white.withOpacity(0.50))),
                )),
          ]),
        ),

        const SizedBox(height: 32),
        const Text('Your submitted documents have been verified successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 20,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
                height: 1.3)),
        const SizedBox(height: 16),
        const Text(
            'Your pharmacy account is now approved\nand you can start managing orders and inventory.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF495565),
                fontSize: 12,
                fontFamily: 'Arimo',
                height: 1.33)),
        const SizedBox(height: 32),
        SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0796DE),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Continue',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500)),
            )),
      ]),
    );
  }

  Widget _buildBackground() {
    return Stack(children: [
      Positioned(
          left: 37,
          top: -99,
          child: Container(
              width: 183,
              height: 183,
              decoration: const ShapeDecoration(
                  shape: OvalBorder(
                      side: BorderSide(width: 30, color: Color(0xFF10A2EA)))))),
      Positioned(
          left: 130,
          top: 198,
          child: Opacity(
              opacity: 0.30,
              child: Container(
                  width: 154,
                  height: 154,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          begin: Alignment(0.93, 0.35),
                          end: Alignment(0.06, 0.40),
                          colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]))))),
      Positioned(
          left: 32,
          top: 63,
          child: Opacity(
              opacity: 0.30,
              child: Container(
                  width: 89,
                  height: 89,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          begin: Alignment(0.93, 0.35),
                          end: Alignment(0.06, 0.40),
                          colors: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)]))))),
      Positioned(
          left: 111,
          top: 33,
          child: Opacity(
              opacity: 0.30,
              child: Container(
                  width: 94,
                  height: 94,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          begin: Alignment(0.93, 0.35),
                          end: Alignment(0.06, 0.40),
                          colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]))))),
      Positioned(
          left: 310,
          top: 65,
          child: Container(
              width: 167,
              height: 167,
              decoration: const ShapeDecoration(
                  shape: OvalBorder(
                      side: BorderSide(width: 30, color: Color(0xFF10A2EA)))))),
    ]);
  }
}
