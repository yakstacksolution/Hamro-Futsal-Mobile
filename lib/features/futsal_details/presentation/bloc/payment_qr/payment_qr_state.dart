part of 'payment_qr_bloc.dart';

enum PaymentQrStatus { idle, loading, success, failure }

final class PaymentQrState extends Equatable {
  const PaymentQrState({
    this.status = PaymentQrStatus.idle,
    this.qr,
    this.errorMessage,
  });

  final PaymentQrStatus status;
  final PaymentQrModel? qr;
  final String? errorMessage;

  bool get isLoading => status == PaymentQrStatus.loading;
  bool get hasQr => qr?.hasQr ?? false;

  PaymentQrState copyWith({
    PaymentQrStatus? status,
    PaymentQrModel? qr,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentQrState(
      status: status ?? this.status,
      qr: qr ?? this.qr,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, qr, errorMessage];
}
