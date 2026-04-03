import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Singleton that holds all user data across the app session
class UserStore {
  UserStore._();
  static final UserStore instance = UserStore._();

  // Basic profile
  String name = 'User';
  String email = '';

  // Avatar colour — set directly from sign-up colour picker
  int avatarColorValue = 0xFF0796DE;

  // emoji field kept for compatibility with health_profile_page logout reset
  String emoji = '👤';

  // Health data — filled during first-time onboarding
  String phone = '';
  String dateOfBirth = '';
  String bloodType = '';
  String allergies = '';
  String chronicConditions = '';
  double weight = 0.0;
  int age = 0;

  // Flag so the app only shows onboarding once
  bool hasCompletedOnboarding = false;

  // profileName alias — keeps older pages that use this name working
  String get profileName => name;
  set profileName(String v) => name = v;

  Future<void> saveToRemote() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': uid,
        'full_name': name,
        'email': email,
        'phone': phone,
        'date_of_birth': dateOfBirth,
        'blood_type': bloodType,
        'allergies': allergies,
        'chronic_conditions': chronicConditions,
        'weight': weight,
        'age': age,
        'avatar_color': avatarColorValue,
        'emoji': emoji,
      });
    } catch (e) {
      debugPrint('UserStore.saveToRemote error: $e');
      rethrow;
    }
  }

  Future<void> syncFromRemote() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final row = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (row == null) return;
      name = (row['full_name'] as String?) ?? name;
      email = (row['email'] as String?) ?? email;
      phone = (row['phone'] as String?) ?? phone;
      dateOfBirth = (row['date_of_birth'] as String?) ?? dateOfBirth;
      bloodType = (row['blood_type'] as String?) ?? bloodType;
      allergies = (row['allergies'] as String?) ?? allergies;
      chronicConditions = (row['chronic_conditions'] as String?) ?? chronicConditions;
      weight = (row['weight'] as num?)?.toDouble() ?? weight;
      age = (row['age'] as num?)?.toInt() ?? age;
      if (row['avatar_color'] != null) avatarColorValue = row['avatar_color'] as int;
      emoji = (row['emoji'] as String?) ?? emoji;
    } catch (e) {
      debugPrint('UserStore.syncFromRemote error: $e');
    }
  }
}
