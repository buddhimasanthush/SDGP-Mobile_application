import 'dart:math';
import 'package:flutter/material.dart';
import 'user_store.dart';
import 'sign_in_page.dart';

// ── Orb physics ───────────────────────────────────────────────────────────────
class _OrbState {
  double x, y;
  final double size;
  final double opacity;
  final bool isBorder;
  final double speed;
  double vx, vy;
  double targetX, targetY;

  _OrbState({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.isBorder,
    required this.speed,
    required this.vx,
    required this.vy,
    required this.targetX,
    required this.targetY,
  });
}

class HealthProfilePage extends StatefulWidget {
  const HealthProfilePage({super.key});

  @override
  State<HealthProfilePage> createState() => _HealthProfilePageState();
}

class _HealthProfilePageState extends State<HealthProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  late List<_OrbState> _orbs;
  final _rng = Random();
  bool _orbsInited = false;
  double _screenW = 390;
  double _screenH = 844;
  DateTime? _lastTime;

  static const _orbTemplates = [
    {'size': 183.0, 'op': 1.0, 'border': true, 'speed': 15.0, 'bottom': false},
    {'size': 140.0, 'op': 1.0, 'border': true, 'speed': 12.0, 'bottom': false},
    {'size': 160.0, 'op': 1.0, 'border': true, 'speed': 13.0, 'bottom': true},
    {'size': 120.0, 'op': 1.0, 'border': true, 'speed': 10.0, 'bottom': true},
    {
      'size': 130.0,
      'op': 0.25,
      'border': false,
      'speed': 20.0,
      'bottom': false
    },
    {'size': 90.0, 'op': 0.22, 'border': false, 'speed': 26.0, 'bottom': false},
    {'size': 75.0, 'op': 0.20, 'border': false, 'speed': 24.0, 'bottom': false},
    {'size': 160.0, 'op': 0.22, 'border': false, 'speed': 16.0, 'bottom': true},
    {'size': 110.0, 'op': 0.20, 'border': false, 'speed': 20.0, 'bottom': true},
    {'size': 80.0, 'op': 0.18, 'border': false, 'speed': 22.0, 'bottom': true},
    {'size': 60.0, 'op': 0.18, 'border': false, 'speed': 26.0, 'bottom': true},
  ];

  void _initOrbs() {
    _orbs = _orbTemplates.map((t) {
      final isBottom = t['bottom'] as bool;
      final startX = _rng.nextDouble() * (_screenW + 100) - 50;
      final startY = isBottom
          ? _screenH * 0.55 + _rng.nextDouble() * (_screenH * 0.50)
          : _rng.nextDouble() * (_screenH * 0.50);
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = t['speed'] as double;
      final tX = _rng.nextDouble() * (_screenW + 160) - 80;
      final tY = isBottom
          ? _screenH * 0.50 + _rng.nextDouble() * (_screenH * 0.55)
          : _rng.nextDouble() * (_screenH * 0.60);
      return _OrbState(
        x: startX,
        y: startY,
        size: t['size'] as double,
        opacity: t['op'] as double,
        isBorder: t['border'] as bool,
        speed: speed,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        targetX: tX,
        targetY: tY,
      );
    }).toList();
  }

  void _tick() {
    if (!mounted) return;
    final now = DateTime.now();
    if (_lastTime == null) {
      _lastTime = now;
      return;
    }
    final dt = now.difference(_lastTime!).inMicroseconds / 1e6;
    _lastTime = now;
    if (dt <= 0 || dt > 0.1) return;

    setState(() {
      for (final orb in _orbs) {
        final dx = orb.targetX - orb.x;
        final dy = orb.targetY - orb.y;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < 40) {
          orb.targetX = _rng.nextDouble() * (_screenW + 160) - 80;
          orb.targetY = _rng.nextDouble() * (_screenH + 160) - 80;
        } else {
          const steer = 0.012;
          orb.vx += ((dx / dist) * orb.speed - orb.vx) * steer;
          orb.vy += ((dy / dist) * orb.speed - orb.vy) * steer;
        }
        orb.x += orb.vx * dt;
        orb.y += orb.vy * dt;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _ticker =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _ticker.addListener(_tick);
  }

  @override
  void dispose() {
    _ticker.removeListener(_tick);
    _ticker.dispose();
    super.dispose();
  }

  Widget _buildOrb(_OrbState orb) {
    return Positioned(
      left: orb.x - orb.size / 2,
      top: orb.y - orb.size / 2,
      child: Opacity(
        opacity: orb.opacity,
        child: Container(
          width: orb.size,
          height: orb.size,
          decoration: orb.isBorder
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 26, color: const Color(0xFF10A2EA)))
              : const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(0.93, 0.35),
                    end: Alignment(0.06, 0.40),
                    colors: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)],
                  )),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 36),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Color(0xFFE53935), size: 26),
                ),
                const SizedBox(height: 16),
                const Text('Log Out?',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 8),
                const Text('Are you sure you want to log out\nof your account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        color: Color(0xFF9E9E9E),
                        height: 1.5)),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(14)),
                        child: const Text('Cancel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF555555))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Clear user data
                        UserStore.instance.name = 'User';
                        UserStore.instance.email = '';
                        UserStore.instance.emoji = '👤';
                        UserStore.instance.avatarColorValue = 0xFF0796DE;
                        // Navigate to sign in, clear all routes
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInPage()),
                          (route) => false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(14)),
                        child: const Text('Log Out',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_orbsInited) {
      final size = MediaQuery.of(context).size;
      _screenW = size.width;
      _screenH = size.height;
      _initOrbs();
      _orbsInited = true;
    }

    final name = UserStore.instance.profileName.trim().isEmpty
        ? 'User'
        : UserStore.instance.profileName;
    final avatarColor = Color(UserStore.instance.avatarColorValue);

    return Scaffold(
      backgroundColor: const Color(0xFF0796DE),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0796DE),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            ..._orbs.map(_buildOrb),
            SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: [
                        _NavBtn(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context)),
                        const Expanded(
                          child: Text('My Profile',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600)),
                        ),
                        _NavBtn(icon: Icons.edit_outlined, onTap: () {}),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Avatar — shows emoji if set, else coloured icon
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: UserStore.instance.emoji.isEmpty
                              ? avatarColor
                              : avatarColor.withOpacity(0.15),
                          border: Border.all(color: avatarColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: avatarColor.withOpacity(0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8))
                          ],
                        ),
                        child: Center(
                          child: UserStore.instance.emoji.isEmpty
                              ? const Icon(Icons.person_rounded,
                                  size: 48, color: Colors.white)
                              : Text(UserStore.instance.emoji,
                                  style: const TextStyle(fontSize: 44)),
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: avatarColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF0796DE), width: 2),
                        ),
                        child: const Icon(Icons.edit_rounded,
                            size: 13, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3)),

                  const SizedBox(height: 24),

                  // White scroll card
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFDDDDDD),
                                  borderRadius: BorderRadius.circular(2)),
                            )),

                            const SizedBox(height: 22),

                            // Stats
                            Row(children: [
                              _StatChip(
                                  label: 'Blood Type',
                                  value: UserStore.instance.bloodType.isEmpty
                                      ? '—'
                                      : UserStore.instance.bloodType,
                                  icon: Icons.bloodtype_rounded,
                                  color: const Color(0xFFFF5B5B)),
                              const SizedBox(width: 10),
                              _StatChip(
                                  label: 'Age',
                                  value: '34',
                                  icon: Icons.cake_rounded,
                                  color: const Color(0xFF0796DE)),
                              const SizedBox(width: 10),
                              _StatChip(
                                  label: 'Weight',
                                  value: '70 kg',
                                  icon: Icons.monitor_weight_rounded,
                                  color: const Color(0xFF27AE60)),
                            ]),

                            const SizedBox(height: 26),

                            const _SectionLabel('Personal Information'),
                            const SizedBox(height: 12),
                            _GroupCard(items: [
                              _RowData(
                                  icon: Icons.phone_rounded,
                                  label: 'Phone',
                                  value: UserStore.instance.phone.isEmpty
                                      ? 'Not set'
                                      : UserStore.instance.phone),
                              _RowData(
                                  icon: Icons.cake_rounded,
                                  label: 'Date of Birth',
                                  value: UserStore.instance.dateOfBirth.isEmpty
                                      ? 'Not set'
                                      : UserStore.instance.dateOfBirth),
                              _RowData(
                                  icon: Icons.location_on_rounded,
                                  label: 'Address',
                                  value: 'Colombo, Sri Lanka'),
                            ]),

                            const SizedBox(height: 22),

                            const _SectionLabel('Medical Information'),
                            const SizedBox(height: 12),
                            _GroupCard(items: [
                              _RowData(
                                  icon: Icons.warning_amber_rounded,
                                  label: 'Allergies',
                                  value: UserStore.instance.allergies.isEmpty
                                      ? 'None recorded'
                                      : UserStore.instance.allergies),
                              _RowData(
                                  icon: Icons.medical_services_rounded,
                                  label: 'Chronic Conditions',
                                  value: UserStore
                                          .instance.chronicConditions.isEmpty
                                      ? 'None recorded'
                                      : UserStore.instance.chronicConditions),
                              _RowData(
                                  icon: Icons.medication_rounded,
                                  label: 'Current Medications',
                                  value: 'None recorded'),
                            ]),

                            const SizedBox(height: 22),

                            const _SectionLabel('Settings'),
                            const SizedBox(height: 12),
                            _TapCard(items: [
                              _TapData(
                                  icon: Icons.notifications_rounded,
                                  label: 'Notifications',
                                  onTap: () {}),
                              _TapData(
                                  icon: Icons.security_rounded,
                                  label: 'Privacy & Security',
                                  onTap: () {}),
                              _TapData(
                                  icon: Icons.help_outline_rounded,
                                  label: 'Help & Support',
                                  onTap: () {}),
                            ]),

                            const SizedBox(height: 16),

                            // Logout
                            GestureDetector(
                              onTap: _showLogoutDialog,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEDED),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout_rounded,
                                        color: Color(0xFFE53935), size: 19),
                                    SizedBox(width: 9),
                                    Text('Log Out',
                                        style: TextStyle(
                                            color: Color(0xFFE53935),
                                            fontSize: 15,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
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
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: Colors.white, size: 17)));
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatChip(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]),
          child: Column(children: [
            Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.11), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 17)),
            const SizedBox(height: 7),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E))),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 9.5,
                    fontFamily: 'Poppins',
                    color: Color(0xFF9E9E9E))),
          ]),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 15,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A)));
}

class _RowData {
  final IconData icon;
  final String label, value;
  const _RowData(
      {required this.icon, required this.label, required this.value});
}

class _GroupCard extends StatelessWidget {
  final List<_RowData> items;
  const _GroupCard({required this.items});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
            children: List.generate(
                items.length,
                (i) => Column(children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          child: Row(children: [
                            Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF0796DE)
                                        .withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Icon(items[i].icon,
                                    color: const Color(0xFF0796DE), size: 17)),
                            const SizedBox(width: 13),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(items[i].label,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Poppins',
                                          color: Color(0xFF9E9E9E))),
                                  const SizedBox(height: 2),
                                  Text(items[i].value,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1E1E1E))),
                                ])),
                          ])),
                      if (i < items.length - 1)
                        Divider(
                            height: 1, indent: 56, color: Colors.grey.shade100),
                    ]))),
      );
}

class _TapData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TapData(
      {required this.icon, required this.label, required this.onTap});
}

class _TapCard extends StatelessWidget {
  final List<_TapData> items;
  const _TapCard({required this.items});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
            children: List.generate(
                items.length,
                (i) => Column(children: [
                      GestureDetector(
                          onTap: items[i].onTap,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              child: Row(children: [
                                Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF0796DE)
                                            .withOpacity(0.10),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(items[i].icon,
                                        color: const Color(0xFF0796DE),
                                        size: 17)),
                                const SizedBox(width: 13),
                                Expanded(
                                    child: Text(items[i].label,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1E1E1E)))),
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    size: 13, color: Color(0xFFBDBDBD)),
                              ]))),
                      if (i < items.length - 1)
                        Divider(
                            height: 1, indent: 56, color: Colors.grey.shade100),
                    ]))),
      );
}
