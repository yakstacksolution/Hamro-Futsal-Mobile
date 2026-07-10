import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';

/// Navigation input for the slot-selection flow.
///
/// [initialDate] and [initialStartTime] let callers such as opponent-match
/// requests carry their preferred schedule into the booking flow.
class SlotsSelectionRouteArgs {
  const SlotsSelectionRouteArgs({
    required this.court,
    this.initialDate,
    this.initialStartTime,
  });

  final CourtDetailModel court;
  final DateTime? initialDate;

  /// Preferred slot start in API format (`HH:mm`).
  final String? initialStartTime;
}
