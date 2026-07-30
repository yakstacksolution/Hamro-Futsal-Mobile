class ManualBookingDetails {
  const ManualBookingDetails({
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.paymentMethod,
    required this.paymentType,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.paymentNote,
  });

  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String paymentMethod;
  final String paymentType;
  final String paymentStatus;
  final String bookingStatus;
  final String paymentNote;
}
