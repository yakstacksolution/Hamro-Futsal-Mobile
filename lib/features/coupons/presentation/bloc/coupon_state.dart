part of 'coupon_bloc.dart';

enum CouponStatus { idle, loading, success, failure }

final class CouponState extends Equatable {
  const CouponState({
    this.status = CouponStatus.idle,
    this.hasActiveCoupon = false,
    this.coupons = const <CouponModel>[],
    this.applied,
    this.isApplying = false,
    this.errorMessage,
    this.applyError,
  });

  /// Status of loading the active-coupons list.
  final CouponStatus status;

  /// Whether the venue currently has any active coupon. May be true even when
  /// [coupons] is empty (the server only returns a flag), in which case manual
  /// code entry is still offered.
  final bool hasActiveCoupon;
  final List<CouponModel> coupons;

  /// The coupon currently applied to the booking (server-confirmed), or null.
  final AppliedCouponModel? applied;

  /// Whether an apply-coupon request is in flight.
  final bool isApplying;

  /// Error from loading the coupons list.
  final String? errorMessage;

  /// Error from the last apply-coupon attempt.
  final String? applyError;

  bool get isLoading => status == CouponStatus.loading;
  bool get hasApplied => applied != null;
  double get discount => applied?.discount ?? 0;
  String? get appliedCode => applied?.code;

  CouponState copyWith({
    CouponStatus? status,
    bool? hasActiveCoupon,
    List<CouponModel>? coupons,
    AppliedCouponModel? applied,
    bool clearApplied = false,
    bool? isApplying,
    String? errorMessage,
    bool clearError = false,
    String? applyError,
    bool clearApplyError = false,
  }) {
    return CouponState(
      status: status ?? this.status,
      hasActiveCoupon: hasActiveCoupon ?? this.hasActiveCoupon,
      coupons: coupons ?? this.coupons,
      applied: clearApplied ? null : (applied ?? this.applied),
      isApplying: isApplying ?? this.isApplying,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      applyError: clearApplyError ? null : (applyError ?? this.applyError),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    hasActiveCoupon,
    coupons,
    applied,
    isApplying,
    errorMessage,
    applyError,
  ];
}
