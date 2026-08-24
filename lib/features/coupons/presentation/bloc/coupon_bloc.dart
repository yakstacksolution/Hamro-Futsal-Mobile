import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/coupons/data/model/active_coupons_model.dart';
import 'package:hamro_footsall/features/coupons/data/model/applied_coupon_model.dart';
import 'package:hamro_footsall/features/coupons/data/model/coupon_model.dart';
import 'package:hamro_footsall/features/coupons/domain/usecase/apply_coupon_use_case.dart';
import 'package:hamro_footsall/features/coupons/domain/usecase/get_active_coupons_use_case.dart';

part 'coupon_event.dart';
part 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  CouponBloc(this._getActiveCouponsUseCase, this._applyCouponUseCase)
    : super(const CouponState()) {
    on<LoadActiveCouponsEvent>(_onLoad);
    on<ApplyCouponEvent>(_onApply);
    on<RemoveCouponEvent>(_onRemove);
  }

  final GetActiveCouponsUseCase _getActiveCouponsUseCase;
  final ApplyCouponUseCase _applyCouponUseCase;

  Future<void> _onLoad(
    LoadActiveCouponsEvent event,
    Emitter<CouponState> emit,
  ) async {
    emit(state.copyWith(status: CouponStatus.loading, clearError: true));

    final Either<AppException, ActiveCouponsModel> response =
        await _getActiveCouponsUseCase.getActiveCoupons();
    // if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: CouponStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (ActiveCouponsModel result) => emit(
        state.copyWith(
          status: CouponStatus.success,
          hasActiveCoupon: result.hasActiveCoupon,
          coupons: result.coupons,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onApply(
    ApplyCouponEvent event,
    Emitter<CouponState> emit,
  ) async {
    final String code = event.code.trim();
    if (code.isEmpty) {
      emit(state.copyWith(applyError: 'Enter a coupon code.'));
      return;
    }

    emit(state.copyWith(isApplying: true, clearApplyError: true));

    final Either<AppException, AppliedCouponModel> response =
        await _applyCouponUseCase.applyCoupon(
          couponCode: code,
          venueId: event.venueId,
          courtId: event.courtId,
          bookingDate: event.bookingDate,
          startTime: event.startTime,
          endTime: event.endTime,
          repeatWeeks: event.repeatWeeks,
          holdToken: event.holdToken,
          amount: event.amount,
        );
    if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          isApplying: false,
          applyError: failure.errorMessage,
          clearApplied: true,
        ),
      ),
      (AppliedCouponModel applied) => emit(
        state.copyWith(
          isApplying: false,
          applied: applied,
          clearApplyError: true,
        ),
      ),
    );
  }

  void _onRemove(RemoveCouponEvent event, Emitter<CouponState> emit) {
    emit(state.copyWith(clearApplied: true, clearApplyError: true));
  }
}
