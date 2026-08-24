part of 'payment_qr_bloc.dart';

sealed class PaymentQrEvent extends Equatable {
  const PaymentQrEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Fetches the payment QR for [courtId] (`GET /courts/{court_id}/payment-qr`).
class LoadPaymentQrEvent extends PaymentQrEvent {
  const LoadPaymentQrEvent(this.courtId);

  final int courtId;

  @override
  List<Object?> get props => <Object?>[courtId];
}
