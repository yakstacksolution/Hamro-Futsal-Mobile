/// Dates across calendars: the reader's calendar choice (AD / BS), AD↔BS
/// conversion, calendar-aware formatting and pickers.
///
/// Dates stay Gregorian [DateTime]s everywhere in the app and the API; this
/// module only changes how they are shown and picked.
library;

export 'app_calendar.dart';
export 'app_date.dart';
export 'app_date_format.dart';
export 'app_date_picker.dart';
