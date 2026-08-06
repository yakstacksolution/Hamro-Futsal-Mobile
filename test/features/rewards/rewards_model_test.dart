import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/rewards/data/model/rewards_model.dart';

void main() {
  group('RewardsSummaryModel', () {
    test('reads the wallet out of a data envelope', () {
      final RewardsSummaryModel summary = RewardsSummaryModel.fromResponse(
        <String, dynamic>{
          'data': <String, dynamic>{
            'available_points': 1250,
            'total_earned_points': 3000,
            'total_redeemed_points': 1750,
            'points_per_coupon': 500,
            'coupon_value': 200,
            'tier': 'gold',
            'currency': 'NPR',
          },
        },
      );

      expect(summary.availablePoints, 1250);
      expect(summary.totalEarnedPoints, 3000);
      expect(summary.totalRedeemedPoints, 1750);
      expect(summary.pointsPerCoupon, 500);
      expect(summary.couponValue, 200);
      expect(summary.tier, 'gold');
      expect(summary.canRedeem, isTrue);
      expect(summary.redeemableCoupons, 2);
      expect(summary.pointsToNextCoupon, 0);
      expect(summary.progressToNextCoupon, 1);
    });

    test('accepts the alternate key spellings and string numbers', () {
      final RewardsSummaryModel summary = RewardsSummaryModel.fromResponse(
        <String, dynamic>{'points_balance': '120', 'min_points': '500'},
      );

      expect(summary.availablePoints, 120);
      expect(summary.pointsPerCoupon, 500);
      expect(summary.canRedeem, isFalse);
      expect(summary.pointsToNextCoupon, 380);
      expect(summary.progressToNextCoupon, closeTo(0.24, 0.001));
    });

    test('honours an explicit eligibility flag over the threshold maths', () {
      final RewardsSummaryModel summary = RewardsSummaryModel.fromResponse(
        <String, dynamic>{
          'points': 10,
          'points_required': 500,
          'can_generate_coupon': true,
        },
      );

      expect(summary.canRedeem, isTrue);
    });

    test('degrades to an empty wallet on an unexpected payload', () {
      expect(
        RewardsSummaryModel.fromResponse('not a map'),
        RewardsSummaryModel.empty,
      );
    });
  });

  group('RewardHistoryPageModel', () {
    test('parses a Laravel paginator and its meta', () {
      final RewardHistoryPageModel page = RewardHistoryPageModel.fromResponse(
        <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{
              'id': 11,
              'type': 'earned',
              'points': 120,
              'title': 'Booking #A18',
              'created_at': '2026-08-01T10:15:00Z',
              'balance_after': 1250,
            },
            <String, dynamic>{
              'id': 12,
              'type': 'redeemed',
              'points': -500,
              'coupon_code': 'RWD-500',
            },
          ],
          'meta': <String, dynamic>{
            'current_page': 1,
            'per_page': 20,
            'total': 42,
            'last_page': 3,
          },
        },
      );

      expect(page.entries, hasLength(2));
      expect(page.page, 1);
      expect(page.perPage, 20);
      expect(page.total, 42);
      expect(page.hasMore, isTrue);

      final RewardHistoryEntryModel earned = page.entries.first;
      expect(earned.type, RewardEntryType.earned);
      expect(earned.points, 120);
      expect(earned.signedPoints, '+120');
      expect(earned.balanceAfter, 1250);
      expect(earned.createdAt, isNotNull);

      final RewardHistoryEntryModel redeemed = page.entries.last;
      expect(redeemed.type, RewardEntryType.redeemed);
      expect(redeemed.points, 500);
      expect(redeemed.signedPoints, '-500');
      expect(redeemed.couponCode, 'RWD-500');
    });

    test('infers the entry type from the sign when none is sent', () {
      final RewardHistoryPageModel page = RewardHistoryPageModel.fromResponse(
        <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{'id': 1, 'points': -80},
          ],
        },
      );

      expect(page.entries.single.type, RewardEntryType.redeemed);
    });

    test('reports no further pages on the last one', () {
      final RewardHistoryPageModel page = RewardHistoryPageModel.fromResponse(
        <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{'id': 1, 'points': 10},
          ],
          'meta': <String, dynamic>{
            'current_page': 3,
            'per_page': 20,
            'total': 41,
            'last_page': 3,
          },
        },
      );

      expect(page.hasMore, isFalse);
    });
  });

  group('GeneratedRewardCouponModel', () {
    test('parses a nested coupon payload', () {
      final GeneratedRewardCouponModel coupon =
          GeneratedRewardCouponModel.fromResponse(<String, dynamic>{
            'message': 'Coupon generated successfully',
            'data': <String, dynamic>{
              'coupon': <String, dynamic>{
                'code': 'RWD-1A2B',
                'discount_amount': 200,
                'points_used': 500,
                'remaining_points': 750,
                'expires_at': '2026-09-01',
              },
            },
          });

      expect(coupon.code, 'RWD-1A2B');
      expect(coupon.discountAmount, 200);
      expect(coupon.pointsUsed, 500);
      expect(coupon.remainingPoints, 750);
      expect(coupon.expiresAt, isNotNull);
      expect(coupon.message, 'Coupon generated successfully');
      expect(coupon.hasCode, isTrue);
    });

    test('has no code when the server returns nothing usable', () {
      expect(
        GeneratedRewardCouponModel.fromResponse(<String, dynamic>{
          'data': <String, dynamic>{},
        }).hasCode,
        isFalse,
      );
    });
  });
}
