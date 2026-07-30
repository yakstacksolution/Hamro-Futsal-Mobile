import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/bookings/data/model/manual_booking_details.dart';

/// Navigation input for the slot-selection flow.
///
/// [initialDate] and [initialStartTime] let callers such as opponent-match
/// requests carry their preferred schedule into the booking flow.
class SlotsSelectionRouteArgs {
  const SlotsSelectionRouteArgs({
    required this.court,
    this.initialDate,
    this.initialStartTime,
    this.manualBooking,
  });

  final CourtDetailModel court;
  final DateTime? initialDate;

  /// Preferred slot start in API format (`HH:mm`).
  final String? initialStartTime;

  /// Customer and payment information supplied by the vendor-only manual
  /// booking flow. Null for the normal customer booking journey.
  final ManualBookingDetails? manualBooking;
}
