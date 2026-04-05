// Simple in-memory state manager for pharmacy registration status.
// In a real app, this would use SharedPreferences or a backend API.

enum RegistrationStatus { notSubmitted, pending, success, failed }

class RegistrationState {
  static final RegistrationState _instance = RegistrationState._internal();
  factory RegistrationState() => _instance;
  RegistrationState._internal();

  RegistrationStatus status = RegistrationStatus.notSubmitted;

  bool get hasSubmitted => status != RegistrationStatus.notSubmitted;

  void setStatus(RegistrationStatus newStatus) {
    status = newStatus;
  }
}
