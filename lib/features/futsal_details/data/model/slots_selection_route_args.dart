import 'package:hamro_futsal/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_futsal/features/bookings/data/model/manual_booking_details.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_success_action.dart';

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

  final String? initialStartTime;

  final ManualBookingDetails? manualBooking;

  final BookingSuccessAction successAction;
}
