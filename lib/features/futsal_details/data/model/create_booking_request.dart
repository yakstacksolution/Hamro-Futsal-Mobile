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
    this.paymentProofPath,
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
  final int? repeatWeeks;

  final String? paymentProofPath;
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
