part of 'coupon_bloc.dart';

sealed class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadActiveCouponsEvent extends CouponEvent {
  const LoadActiveCouponsEvent();
}

class ApplyCouponEvent extends CouponEvent {
  const ApplyCouponEvent({
    required this.code,
    required this.venueId,
    required this.courtId,
    required this.bookingDate,
    required this.startTime,
    this.endTime,
    this.repeatWeeks,
    this.holdToken,
    required this.amount,
  });

  final String code;
  final int? venueId;
  final int? courtId;

  final String bookingDate;

  final String startTime;
  final String? endTime;

  final int? repeatWeeks;

  final String? holdToken;

  final double amount;

  @override
  List<Object?> get props => <Object?>[
    code,
    venueId,
    courtId,
    bookingDate,
    startTime,
    endTime,
    repeatWeeks,
    holdToken,
    amount,
  ];
}

class RemoveCouponEvent extends CouponEvent {
  const RemoveCouponEvent();
}
