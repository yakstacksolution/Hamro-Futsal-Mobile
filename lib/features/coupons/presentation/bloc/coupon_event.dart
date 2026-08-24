part of 'coupon_bloc.dart';

sealed class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads the list of currently active coupons (`GET /coupons/active`).
class LoadActiveCouponsEvent extends CouponEvent {
  const LoadActiveCouponsEvent();
}

/// Validates and applies [code] for the given booking
/// (`POST /bookings/apply-coupon`).
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

  /// Booking date in `yyyy-MM-dd`.
  final String bookingDate;

  /// Slot start/end in `HH:mm`.
  final String startTime;
  final String? endTime;

  /// Number of weekly repeats for recurring bookings; null for single.
  final int? repeatWeeks;

  /// Active booking-hold token, sent so the server applies the coupon against
  /// the held slot.
  final String? holdToken;

  /// Order subtotal, used only to back-fill amounts the server may omit.
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

/// Clears the currently applied coupon.
class RemoveCouponEvent extends CouponEvent {
  const RemoveCouponEvent();
}
