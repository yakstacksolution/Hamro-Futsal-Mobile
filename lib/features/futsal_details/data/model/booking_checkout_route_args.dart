import 'package:hamro_futsal/features/futsal_details/data/model/booking_draft.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_success_action.dart';

/// Navigation input for the checkout page: what is being booked, and where the
/// flow should land once it has been booked.
class BookingCheckoutRouteArgs {
  const BookingCheckoutRouteArgs({
    required this.draft,
    this.successAction = BookingSuccessAction.openBookingDetails,
  });

  /// Accepts a bare [BookingDraft] too, so a caller that has nothing to say
  /// about the destination can keep passing just the draft.
  static BookingCheckoutRouteArgs? maybeFromExtra(Object? extra) {
    if (extra is BookingCheckoutRouteArgs) return extra;
    if (extra is BookingDraft) return BookingCheckoutRouteArgs(draft: extra);
    return null;
  }

  final BookingDraft draft;
  final BookingSuccessAction successAction;
}
