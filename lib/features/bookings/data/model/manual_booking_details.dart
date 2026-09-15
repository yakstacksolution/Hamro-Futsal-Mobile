class ManualBookingDetails {
  const ManualBookingDetails({
    required this.customerName,
    required this.customerPhone,
    this.totalAmount,
    required this.paymentMethod,
    required this.paymentType,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.paymentNote,
  });

  final String customerName;
  final String customerPhone;

  /// What the booking should cost, when the counter agreed a price the slot
  /// rates do not produce. Null leaves the pricing to the server.
  final double? totalAmount;
  final String paymentMethod;
  final String paymentType;
  final String paymentStatus;
  final String bookingStatus;
  final String paymentNote;
}
