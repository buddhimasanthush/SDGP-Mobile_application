// Simple singleton to store user data across pages
class UserStore {
  UserStore._();
  static final UserStore instance = UserStore._();

  String name = 'User';
  String email = '';
  String emoji = '👤';

  // Alias so existing code using profileName still works
  String get profileName => name;
  set profileName(String value) => name = value;
}
