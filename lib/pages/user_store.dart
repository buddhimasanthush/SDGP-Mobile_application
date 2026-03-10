/// Simple singleton to share user data across pages.
class UserStore {
  static final UserStore instance = UserStore._();
  UserStore._();

  String profileName = 'User';
  String emoji = '';
}
