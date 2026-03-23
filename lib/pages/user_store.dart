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

  // Flag so the app only shows onboarding once
  bool hasCompletedOnboarding = false;

  // profileName alias — keeps older pages that use this name working
  String get profileName => name;
  set profileName(String v) => name = v;
}
