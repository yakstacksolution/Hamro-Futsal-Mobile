/// The API's `booking_type` values, shared by every endpoint that has to tell
/// a vendor-entered walk-in apart from a player's own booking.
class BookingTypePayload {
  const BookingTypePayload._();

  /// A walk-in entered by the vendor from the futsal bookings screen.
  static const String manual = 'manual';

  /// A booking made by a player through the app.
  static const String regular = 'regular';

  static String of({required bool isManual}) => isManual ? manual : regular;
}
