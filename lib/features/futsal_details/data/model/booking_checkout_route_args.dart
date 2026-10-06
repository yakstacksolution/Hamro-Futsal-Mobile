import 'package:hamro_futsal/features/futsal_details/data/model/booking_draft.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_success_action.dart';

class BookingCheckoutRouteArgs {
  const BookingCheckoutRouteArgs({
    required this.draft,
    this.successAction = BookingSuccessAction.openBookingDetails,
  });

  static BookingCheckoutRouteArgs? maybeFromExtra(Object? extra) {
    if (extra is BookingCheckoutRouteArgs) return extra;
    if (extra is BookingDraft) return BookingCheckoutRouteArgs(draft: extra);
    return null;
  }

  final BookingDraft draft;
  final BookingSuccessAction successAction;
}
