import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Privacy Policy',
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
            _buildSection('1. Introduction',
                'At MediFind, we value your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.'),
            _buildSection('2. Information We Collect',
                'We collect information you provide directly to us, such as when you create an account, upload a prescription, or communicate with support. This may include your name, email, phone number, and medical information extracted from prescriptions.'),
            _buildSection('3. How We Use Your Information',
                'We use the information we collect to provide and improve our services, process your orders, send you reminders, and communicate with you about your account and our services.'),
            _buildSection('4. Data Security',
                'We implement appropriate technical and organizational measures to protect your personal data against unauthorized access, loss, or alteration. Your prescriptions are encrypted and stored securely.'),
            _buildSection('5. Third-Party Services',
                'We may use third-party service providers to help us operate our business. These providers have access to your information only to perform specific tasks on our behalf and are obligated not to disclose or use it for any other purpose.'),
            _buildSection('6. Your Rights',
                'You have the right to access, correct, or delete your personal data. You can manage your profile information within the app or contact us for assistance.'),
            _buildSection('7. Changes to This Policy',
                'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.'),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Last updated: March 2026',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Color(0xFF0796DE),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            height: 1.6,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
