import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/payment_qr_model.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_court_payment_qr_use_case.dart';

part 'payment_qr_event.dart';
part 'payment_qr_state.dart';

class PaymentQrBloc extends Bloc<PaymentQrEvent, PaymentQrState> {
  PaymentQrBloc(this._getCourtPaymentQrUseCase)
    : super(const PaymentQrState()) {
    on<LoadPaymentQrEvent>(_onLoad);
  }

  final GetCourtPaymentQrUseCase _getCourtPaymentQrUseCase;

  Future<void> _onLoad(
    LoadPaymentQrEvent event,
    Emitter<PaymentQrState> emit,
  ) async {
    emit(state.copyWith(status: PaymentQrStatus.loading, clearError: true));

    final Either<AppException, PaymentQrModel> response =
        await _getCourtPaymentQrUseCase(courtId: event.courtId);
    if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: PaymentQrStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (PaymentQrModel qr) => emit(
        state.copyWith(
          status: PaymentQrStatus.success,
          qr: qr,
          clearError: true,
        ),
      ),
    );
  }
}
