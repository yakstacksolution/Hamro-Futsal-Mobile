import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';

@immutable
class BookingDetailsRouteArgs {
  const BookingDetailsRouteArgs({
    required this.booking,
    this.isFutsalView,
    this.onBookingUpdated,
  });

  final BookingModel booking;
  final bool? isFutsalView;
  final ValueChanged<BookingModel>? onBookingUpdated;

  static BookingDetailsRouteArgs fromExtra(Object? extra) {
    if (extra is BookingDetailsRouteArgs) return extra;
    if (extra is BookingModel) return BookingDetailsRouteArgs(booking: extra);
    return BookingDetailsRouteArgs(booking: BookingModel.fromJson(const {}));
  }
}
