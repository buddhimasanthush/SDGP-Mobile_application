import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Help & Support',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                color: Color(0xFF0796DE),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'We are here to assist you with any questions or issues you may have.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Color(0xFF4A4A4A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            _buildContactItem(
                icon: Icons.email_outlined,
                title: 'Email us',
                subtitle: 'support@medifind.com',
                onTap: () {}),
            const SizedBox(height: 16),
            _buildContactItem(
                icon: Icons.phone_outlined,
                title: 'Call us',
                subtitle: '+94 11 123 4567',
                onTap: () {}),
            const SizedBox(height: 16),
            _buildContactItem(
                icon: Icons.chat_bubble_outline,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () {}),
            const SizedBox(height: 40),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 20),
            _buildFaqItem('How do I upload a prescription?',
                'To upload a prescription, go to the Home screen and tap "Upload Prescription". You can take a photo or select an image from your gallery.'),
            _buildFaqItem('What should I do if my medicine is not available?',
                'If a medicine is not available in nearby pharmacies, you can search for other alternatives or contact support for help.'),
            _buildFaqItem('How can I track my order?',
                'You can track your order in the "Previous Orders" section of the app. Tap on an order to see its current status.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0796DE).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF0796DE)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: Color(0xFF9E9E9E))),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Color(0xFFBDBDBD)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          Text(answer,
              style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Color(0xFF4A4A4A),
                  height: 1.5)),
        ],
      ),
    );
  }
}
