import 'package:hamro_futsal/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_futsal/features/bookings/data/model/manual_booking_details.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_success_action.dart';

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
    this.successAction = BookingSuccessAction.openBookingDetails,
  });

  static SlotsSelectionRouteArgs? maybeFromExtra(Object? extra) {
    if (extra is SlotsSelectionRouteArgs) return extra;
    if (extra is CourtDetailModel) {
      return SlotsSelectionRouteArgs(court: extra);
    }
    return null;
  }

  final CourtDetailModel court;
  final DateTime? initialDate;

  /// Preferred slot start in API format (`HH:mm`).
  final String? initialStartTime;

  /// Customer and payment information supplied by the vendor-only manual
  /// booking flow. Null for the normal customer booking journey.
  final ManualBookingDetails? manualBooking;

  /// Where the flow lands once the booking has been created. Wizards that need
  /// the draft back pass [BookingSuccessAction.returnDraft].
  final BookingSuccessAction successAction;
}
