/// Canonical weekday definition used across the court onboarding flow
/// (weekend days, slot scheduling, pricing previews).
///
/// [id] starts at 1 for Sunday and runs through 7 for Saturday, matching the
/// backend ordering. [key] is the lowercase short code persisted in
/// `CourtDraft.weekendDays` and sent to the API (`weekend_days: ['sun', ...]`).
/// [name] is the full detail label.
class WeekdayOption {
  const WeekdayOption({
    required this.id,
    required this.key,
    required this.name,
  });

  /// 1 = Sunday ... 7 = Saturday.
  final int id;

  /// Lowercase short code, e.g. `sun` — the value stored and sent to the API.
  final String key;

  /// Full detail label, e.g. `Sunday`.
  final String name;

  /// Capitalized short label for display, e.g. `Sun`.
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

  /// Resolves a weekday from an id, short key, short label, or full name,
  /// regardless of casing. Returns `null` when nothing matches.
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

  /// The weekday for a given calendar date.
  static WeekdayOption forDate(DateTime date) {
    return values[date.weekday % DateTime.daysPerWeek];
  }
}
