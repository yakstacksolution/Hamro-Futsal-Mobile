class BookingTypePayload {
  const BookingTypePayload._();

  static const String manual = 'manual';

  static const String regular = 'regular';

  static String of({required bool isManual}) => isManual ? manual : regular;
}
