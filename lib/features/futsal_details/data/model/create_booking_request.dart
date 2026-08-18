import 'dart:typed_data';

class CreateBookingRequest {
  const CreateBookingRequest({
    required this.venueId,
    required this.courtId,
    required this.bookingDate,
    required this.startTime,
    this.endTime,
    required this.paymentMethod,
    this.notes,
    this.couponCode,
    this.repeatWeeks,
    this.bookingDates = const <String>[],
    this.paymentProofPath,
    this.paymentProofBytes,
    this.paymentProofName,
    this.paymentNote,
    this.bookingType,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.paymentType,
    this.paymentStatus,
    this.bookingStatus,
  });

  final int? venueId;
  final int? courtId;

  final String bookingDate;

  final String startTime;
  final String? endTime;

  final String paymentMethod;
  final String? notes;
  final String? couponCode;

  /// Weeks between the first and last session, sent only when the recurrence
  /// repeats on a single weekday — the server can derive those dates itself.
  /// Null once several weekdays are booked, which this field cannot express;
  /// [bookingDates] is authoritative in that case.
  final int? repeatWeeks;

  /// Every session date (`yyyy-MM-dd`) the booking should create, including
  /// the first. Empty for a single-session booking.
  final List<String> bookingDates;

  /// Where the proof was picked from. Reference only — the upload uses
  /// [paymentProofBytes], because a picker's cache path can be invalidated
  /// between attaching the file and confirming the booking.
  final String? paymentProofPath;

  /// The proof's contents, read when it was attached. This is what is sent.
  final Uint8List? paymentProofBytes;

  /// Filename to send with [paymentProofBytes].
  final String? paymentProofName;

  final String? paymentNote;
  final String? bookingType;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? paymentType;
  final String? paymentStatus;
  final String? bookingStatus;

  Map<String, dynamic> toFields() => <String, dynamic>{
    'venue_id': venueId,
    'court_id': courtId,
    'booking_date': bookingDate,
    'start_time': startTime,
    'end_time': endTime,
    'payment_method': paymentMethod,
    'notes': notes,
    'coupon_code': couponCode,
    'repeat_weeks': repeatWeeks,
    // `[]` on the key because these fields go out as multipart form data,
    // where a repeated bare key would collapse to its last value server-side.
    if (bookingDates.isNotEmpty) 'booking_dates[]': bookingDates,
    'payment_note': paymentNote,
    'booking_type': bookingType,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'customer_email': customerEmail,
    'payment_type': paymentType,
    'payment_status': paymentStatus,
    'booking_status': bookingStatus,
  };
}
