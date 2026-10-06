class WeekdayOption {
  const WeekdayOption({
    required this.id,
    required this.key,
    required this.name,
  });

  final int id;

  final String key;

  final String name;

  String get label =>
      key.isEmpty ? key : key[0].toUpperCase() + key.substring(1);

  static const List<WeekdayOption> values = <WeekdayOption>[
    WeekdayOption(id: 1, key: 'sun', name: 'Sunday'),
    WeekdayOption(id: 2, key: 'mon', name: 'Monday'),
    WeekdayOption(id: 3, key: 'tue', name: 'Tuesday'),
    WeekdayOption(id: 4, key: 'wed', name: 'Wednesday'),
    WeekdayOption(id: 5, key: 'thu', name: 'Thursday'),
    WeekdayOption(id: 6, key: 'fri', name: 'Friday'),
    WeekdayOption(id: 7, key: 'sat', name: 'Saturday'),
  ];

  static WeekdayOption? fromAny(Object? raw) {
    if (raw == null) return null;
    if (raw is num) {
      final int id = raw.toInt();
      for (final WeekdayOption option in values) {
        if (option.id == id) return option;
      }
      return null;
    }
    final String value = raw.toString().trim().toLowerCase();
    if (value.isEmpty) return null;
    for (final WeekdayOption option in values) {
      if (option.key == value ||
          option.name.toLowerCase() == value ||
          option.id.toString() == value) {
        return option;
      }
    }
    return null;
  }

  static WeekdayOption forDate(DateTime date) {
    return values[date.weekday % DateTime.daysPerWeek];
  }
}
