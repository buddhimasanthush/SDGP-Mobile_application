class ReminderModel {
  final String name;
  final String description;
  final List<String> times;
  final List<bool> days;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;

  ReminderModel({
    required this.name,
    required this.description,
    required this.times,
    required this.days,
    required this.frequency,
    required this.startDate,
    this.endDate,
  });

  String get daysLabel {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return labels
        .asMap()
        .entries
        .where((e) => days[e.key])
        .map((e) => e.value)
        .join(' ');
  }
}

class ReminderStore {
  ReminderStore._();
  static final ReminderStore instance = ReminderStore._();

  final List<ReminderModel> reminders = [];

  void add(ReminderModel r) => reminders.add(r);
  bool get hasReminders => reminders.isNotEmpty;
}
