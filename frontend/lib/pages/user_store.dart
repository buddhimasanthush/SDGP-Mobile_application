import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

// Singleton that holds all user data across the app session.
class UserStore {
  UserStore._();
  static final UserStore instance = UserStore._();

  static const String _defaultName = 'User';
  static const int _defaultAvatarColor = 0xFF0796DE;
  static const String _defaultEmoji = '👤';

  static const String _keyName = 'user_store.name';
  static const String _keyEmail = 'user_store.email';
  static const String _keyAvatarColor = 'user_store.avatar_color';
  static const String _keyEmoji = 'user_store.emoji';
  static const String _keyPhone = 'user_store.phone';
  static const String _keyDateOfBirth = 'user_store.date_of_birth';
  static const String _keyAge = 'user_store.age';
  static const String _keyWeight = 'user_store.weight';
  static const String _keyBloodType = 'user_store.blood_type';
  static const String _keyAllergies = 'user_store.allergies';
  static const String _keyChronicConditions = 'user_store.chronic_conditions';
  static const String _keyHasCompletedOnboarding =
      'user_store.has_completed_onboarding';

  bool _hasLoadedLocalState = false;

  // Basic profile
  String name = _defaultName;
  String email = '';

  // Avatar color set directly from sign-up color picker.
  int avatarColorValue = _defaultAvatarColor;

  // Emoji field kept for compatibility with health_profile_page logout reset.
  String emoji = _defaultEmoji;

  // Health data filled during first-time onboarding.
  String phone = '';
  String dateOfBirth = '';
  int age = 0;
  double weight = 0.0;
  String bloodType = '';
  String allergies = '';
  String chronicConditions = '';

  // Flag so the app only shows onboarding once.
  bool hasCompletedOnboarding = false;

  // profileName alias keeps older pages that use this name working.
  String get profileName => name;
  set profileName(String value) => name = value;

  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();

    name = _readRequiredString(prefs, _keyName, fallback: _defaultName);
    email = prefs.getString(_keyEmail)?.trim() ?? '';
    avatarColorValue = prefs.getInt(_keyAvatarColor) ?? _defaultAvatarColor;
    emoji = prefs.containsKey(_keyEmoji)
        ? (prefs.getString(_keyEmoji) ?? '')
        : _defaultEmoji;
    phone = prefs.getString(_keyPhone)?.trim() ?? '';
    dateOfBirth = prefs.getString(_keyDateOfBirth)?.trim() ?? '';
    age = prefs.getInt(_keyAge) ?? 0;
    weight = prefs.getDouble(_keyWeight) ?? 0.0;
    bloodType = prefs.getString(_keyBloodType)?.trim() ?? '';
    allergies = prefs.getString(_keyAllergies)?.trim() ?? '';
    chronicConditions = prefs.getString(_keyChronicConditions)?.trim() ?? '';
    hasCompletedOnboarding = prefs.getBool(_keyHasCompletedOnboarding) ?? false;

    _hasLoadedLocalState = true;
  }

  Future<void> syncFromRemote() async {
    if (!_hasLoadedLocalState) {
      await loadFromLocal();
    }

    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      await saveToLocal();
      return;
    }

    final authEmail = _normalizeEmail(currentUser.email);
    if (authEmail != null) {
      email = authEmail;
    }

    Map<String, dynamic>? profile;
    try {
      profile = await AuthService.getProfile(currentUser.id);
    } catch (_) {}

    String? username;
    try {
      username = await AuthService.getUsernameForUser(
        uid: currentUser.id,
        email: authEmail ?? email,
      );
    } catch (_) {}

    final resolvedName = _firstMeaningfulString([
      _asString(profile?['full_name']),
      _asString(currentUser.userMetadata?['full_name']),
      _humanizeDisplayName(username),
      _asMeaningfulName(name),
      _humanizeDisplayName(_emailLocalPart(authEmail ?? email)),
    ]);
    if (resolvedName != null) {
      name = resolvedName;
    }

    final resolvedEmail = _firstNonEmptyString([
      _normalizeEmail(profile?['email']?.toString()),
      authEmail,
      _normalizeEmail(email),
    ]);
    if (resolvedEmail != null) {
      email = resolvedEmail;
    }

    final remoteAvatarColor = _asInt(profile?['avatar_color']);
    if (remoteAvatarColor != null) {
      avatarColorValue = remoteAvatarColor;
    }

    final remoteEmoji = _asString(profile?['emoji']);
    if (remoteEmoji != null) {
      emoji = remoteEmoji;
    }

    phone = _firstNonEmptyString([
          _asString(profile?['phone']),
          phone,
        ]) ??
        phone;
    dateOfBirth = _firstNonEmptyString([
          _asString(profile?['date_of_birth']),
          _asString(profile?['dob']),
          dateOfBirth,
        ]) ??
        dateOfBirth;
    age = _asInt(profile?['age']) ?? age;
    weight = _asDouble(profile?['weight']) ?? weight;
    bloodType = _firstNonEmptyString([
          _asString(profile?['blood_type']),
          bloodType,
        ]) ??
        bloodType;
    allergies = _firstNonEmptyString([
          _asString(profile?['allergies']),
          allergies,
        ]) ??
        allergies;
    chronicConditions = _firstNonEmptyString([
          _asString(profile?['chronic_conditions']),
          chronicConditions,
        ]) ??
        chronicConditions;
    hasCompletedOnboarding =
        _asBool(profile?['has_completed_onboarding']) ?? hasCompletedOnboarding;

    await saveToLocal();
  }

  Future<void> saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyName, name.trim().isEmpty ? _defaultName : name);
    await prefs.setString(_keyEmail, email.trim());
    await prefs.setInt(_keyAvatarColor, avatarColorValue);
    await prefs.setString(_keyEmoji, emoji);
    await prefs.setString(_keyPhone, phone.trim());
    await prefs.setString(_keyDateOfBirth, dateOfBirth.trim());
    await prefs.setInt(_keyAge, age);
    await prefs.setDouble(_keyWeight, weight);
    await prefs.setString(_keyBloodType, bloodType.trim());
    await prefs.setString(_keyAllergies, allergies.trim());
    await prefs.setString(_keyChronicConditions, chronicConditions.trim());
    await prefs.setBool(
      _keyHasCompletedOnboarding,
      hasCompletedOnboarding,
    );

    _hasLoadedLocalState = true;
  }

  Future<void> saveToRemote() async {
    await saveToLocal();

    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    final payload = <String, dynamic>{
      'id': currentUser.id,
      'full_name': name.trim().isEmpty ? _defaultName : name.trim(),
      'email': _normalizeEmail(email) ?? _normalizeEmail(currentUser.email),
      'avatar_color': avatarColorValue,
      'emoji': emoji,
    }..removeWhere((key, value) => value == null);

    try {
      await AuthService.upsertProfile(payload);
    } catch (_) {}
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in const [
      _keyName,
      _keyEmail,
      _keyAvatarColor,
      _keyEmoji,
      _keyPhone,
      _keyDateOfBirth,
      _keyAge,
      _keyWeight,
      _keyBloodType,
      _keyAllergies,
      _keyChronicConditions,
      _keyHasCompletedOnboarding,
    ]) {
      await prefs.remove(key);
    }

    _resetInMemory();
    _hasLoadedLocalState = true;
  }

  void updateEmail(String newEmail) {
    email = newEmail;
  }

  void _resetInMemory() {
    name = _defaultName;
    email = '';
    avatarColorValue = _defaultAvatarColor;
    emoji = _defaultEmoji;
    phone = '';
    dateOfBirth = '';
    age = 0;
    weight = 0.0;
    bloodType = '';
    allergies = '';
    chronicConditions = '';
    hasCompletedOnboarding = false;
  }

  String _readRequiredString(
    SharedPreferences prefs,
    String key, {
    required String fallback,
  }) {
    final value = prefs.getString(key)?.trim();
    return value == null || value.isEmpty ? fallback : value;
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String? _normalizeEmail(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    return normalized.isEmpty ? null : normalized;
  }

  String? _emailLocalPart(String value) {
    final normalized = _normalizeEmail(value);
    if (normalized == null || !normalized.contains('@')) return null;
    return normalized.split('@').first;
  }

  String? _asMeaningfulName(String? value) {
    final text = _asString(value);
    if (text == null) return null;
    return text.toLowerCase() == _defaultName.toLowerCase() ? null : text;
  }

  String? _firstMeaningfulString(List<String?> values) {
    for (final value in values) {
      final text = _asMeaningfulName(value);
      if (text != null) return text;
    }
    return null;
  }

  String? _firstNonEmptyString(List<String?> values) {
    for (final value in values) {
      final text = _asString(value);
      if (text != null) return text;
    }
    return null;
  }

  String? _humanizeDisplayName(String? value) {
    final raw = _asString(value);
    if (raw == null) return null;

    final normalized = raw
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) return null;

    return normalized.split(' ').map((word) {
      if (word.length <= 1) return word.toUpperCase();
      final hasInternalUppercase = word.substring(1).contains(
            RegExp(r'[A-Z]'),
          );
      if (hasInternalUppercase) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return null;
  }
}
