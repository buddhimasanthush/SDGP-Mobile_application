import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _medicineReminders = true;
  bool _orderUpdates = true;
  bool _newOffers = false;
  bool _appUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Notifications',
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
              'Notification Preferences',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                color: Color(0xFF0796DE),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Customize how you want to receive alerts and updates from MediFind.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Color(0xFF9E9E9E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            _buildSwitchItem(
                title: 'Medicine Reminders',
                subtitle: 'Get notified when it\'s time to take your medication.',
                value: _medicineReminders,
                onChanged: (v) => setState(() => _medicineReminders = v)),
            const SizedBox(height: 16),
            _buildSwitchItem(
                title: 'Order Updates',
                subtitle: 'Get real-time tracking updates for your medicine orders.',
                value: _orderUpdates,
                onChanged: (v) => setState(() => _orderUpdates = v)),
            const SizedBox(height: 16),
            _buildSwitchItem(
                title: 'New Offers & Promotions',
                subtitle: 'Stay updated with the latest discounts and pharmacy deals.',
                value: _newOffers,
                onChanged: (v) => setState(() => _newOffers = v)),
            const SizedBox(height: 16),
            _buildSwitchItem(
                title: 'App Updates & News',
                subtitle: 'Important announcements about features and services.',
                value: _appUpdates,
                onChanged: (v) => setState(() => _appUpdates = v)),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                'These settings apply only to this device.',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
      {required String title,
      required String subtitle,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF0796DE).withOpacity(0.5),
            activeColor: const Color(0xFF0796DE),
          ),
        ],
      ),
    );
  }
}
