import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_api_payload.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

SlotPricingDraft _slot({
  bool hasDiscount = false,
  double? discountPrice,
  String discountType = 'Flat',
  DateTime? startsAt,
  DateTime? endsAt,
}) => SlotPricingDraft(
  id: '77',
  startTime: '06:00',
  endTime: '07:00',
  price: 1200,
  hasDiscount: hasDiscount,
  discountPrice: discountPrice,
  discountType: discountType,
  discountStartsAt: startsAt,
  discountEndsAt: endsAt,
);

void main() {
  group('the discount is off by default', () {
    test('a new slot carries no discount', () {
      const SlotPricingDraft slot = SlotPricingDraft(id: '1');
      expect(slot.hasDiscount, isFalse);
      expect(slot.discountPrice, isNull);
      expect(slot.discountStartsAt, isNull);
      expect(slot.discountEndsAt, isNull);
    });

    test('nothing discount-shaped is sent while it is off', () {
      // Even with a price left over from a previous edit: the switch decides.
      final Map<String, dynamic> body = courtSlotPricingBody(
        _slot(discountPrice: 200, startsAt: DateTime(2026, 9, 14)),
        courtId: 41,
      );
      // The flag is sent as false — that is what clears a discount the slot
      // used to have — and nothing else discount-shaped goes with it.
      expect(body['is_discount_available'], isFalse);
      expect(body.containsKey('discount_type'), isFalse);
      expect(body.containsKey('discount_value'), isFalse);
      expect(body.containsKey('discount_start_time'), isFalse);
      expect(body.containsKey('discount_end_time'), isFalse);
      // The rest of the pricing still goes.
      expect(body['price'], 1200);
    });
  });

  group('with the discount on', () {
    test('type and price are sent', () {
      final Map<String, dynamic> body = courtSlotPricingBody(
        _slot(hasDiscount: true, discountPrice: 15, discountType: 'Percent'),
        courtId: 41,
      );
      expect(body['is_discount_available'], isTrue);
      expect(body['discount_type'], 'percentage');
      expect(body['discount_value'], 15);
    });

    test('the window is sent in the API date-time shape', () {
      final Map<String, dynamic> body = courtSlotPricingBody(
        _slot(
          hasDiscount: true,
          discountPrice: 200,
          startsAt: DateTime(2026, 9, 14, 6),
          endsAt: DateTime(2026, 9, 20, 23, 30),
        ),
        courtId: 41,
      );
      expect(body['discount_start_time'], '2026-09-14 06:00:00');
      expect(body['discount_end_time'], '2026-09-20 23:30:00');
    });

    test('an open-ended discount sends no dates', () {
      final Map<String, dynamic> body = courtSlotPricingBody(
        _slot(hasDiscount: true, discountPrice: 200),
        courtId: 41,
      );
      expect(body['discount_value'], 200);
      expect(body.containsKey('discount_start_time'), isFalse);
      expect(body.containsKey('discount_end_time'), isFalse);
    });

    test('one end alone is allowed', () {
      final Map<String, dynamic> body = courtSlotPricingBody(
        _slot(
          hasDiscount: true,
          discountPrice: 200,
          endsAt: DateTime(2026, 9, 20, 12),
        ),
        courtId: 41,
      );
      expect(body.containsKey('discount_start_time'), isFalse);
      expect(body['discount_end_time'], '2026-09-20 12:00:00');
    });

    test('switching it on with no amount yet sends nothing', () {
      final Map<String, dynamic> body = courtSlotPricingBody(
        _slot(hasDiscount: true),
        courtId: 41,
      );
      // The endpoint requires a type and a value alongside a `true`, so a
      // half-filled discount is reported as `false` rather than sent broken.
      // The sheet refuses to submit in this state anyway — see the validation
      // group below.
      expect(body['is_discount_available'], isFalse);
      expect(body.containsKey('discount_type'), isFalse);
      expect(body.containsKey('discount_value'), isFalse);
    });
  });

  group('round-tripping a draft', () {
    test('the switch and the window survive save and reload', () {
      final SlotPricingDraft slot = _slot(
        hasDiscount: true,
        discountPrice: 250,
        startsAt: DateTime(2026, 9, 14, 6),
        endsAt: DateTime(2026, 9, 20, 23, 30),
      );
      final SlotPricingDraft restored = SlotPricingDraft.fromJson(
        slot.toJson(),
      );

      expect(restored.hasDiscount, isTrue);
      expect(restored.discountPrice, 250);
      expect(restored.discountStartsAt, DateTime(2026, 9, 14, 6));
      expect(restored.discountEndsAt, DateTime(2026, 9, 20, 23, 30));
    });

    test('a slot the server already discounts opens with the switch on', () {
      final SlotPricingDraft restored = SlotPricingDraft.fromJson(
        <String, dynamic>{
          'id': '77',
          'hasDiscount': true,
          'discountPrice': 300,
          'discountType': 'flat',
          'discountStartsAt': '2026-09-14 06:00:00',
        },
      );
      expect(restored.hasDiscount, isTrue);
      expect(restored.discountStartsAt, DateTime(2026, 9, 14, 6));
    });

    test('an amount with no flag still counts as discounted', () {
      // A response that predates `is_discount_available`.
      final SlotPricingDraft restored = SlotPricingDraft.fromJson(
        <String, dynamic>{'id': '77', 'discountPrice': 300},
      );
      expect(restored.hasDiscount, isTrue);
    });

    test('the flag wins over a stale amount', () {
      final SlotPricingDraft restored = SlotPricingDraft.fromJson(
        <String, dynamic>{
          'id': '77',
          'hasDiscount': false,
          'discountPrice': 300,
        },
      );
      expect(restored.hasDiscount, isFalse);
    });

    test('a slot with no discount opens with the switch off', () {
      final SlotPricingDraft restored = SlotPricingDraft.fromJson(
        <String, dynamic>{'id': '77', 'price': 1200},
      );
      expect(restored.hasDiscount, isFalse);
    });
  });

  group('reading the endpoint back', () {
    /// A court as the API returns it: the slot's schedule and its pricing
    /// arrive as two lists, matched on the schedule id.
    List<CourtDraft> courtsFrom(Map<String, dynamic> pricing) {
      return VenueCourtModel.courtsFromResponse(<String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 41,
            'name': 'Court 1',
            'slot_schedules': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 77,
                'start_time': '06:00:00',
                'end_time': '07:00:00',
              },
            ],
            'slot_pricings': <Map<String, dynamic>>[
              <String, dynamic>{'slot_schedule_id': 77, ...pricing},
            ],
          },
        ],
      });
    }

    test('the endpoint keys fill the slot in', () {
      final SlotPricingDraft slot = courtsFrom(<String, dynamic>{
        'price': 1200,
        'is_discount_available': true,
        'discount_type': 'percentage',
        'discount_value': 15,
        'discount_start_time': '2026-09-14 06:00:00',
        'discount_end_time': '2026-09-20 23:30:00',
      }).single.slotConfigs.single;

      expect(slot.hasDiscount, isTrue);
      expect(slot.discountType, 'Percent');
      expect(slot.discountPrice, 15);
      expect(slot.discountStartsAt, DateTime(2026, 9, 14, 6));
      expect(slot.discountEndsAt, DateTime(2026, 9, 20, 23, 30));
    });

    test('a slot the endpoint says is not discounted opens switched off', () {
      final SlotPricingDraft slot = courtsFrom(<String, dynamic>{
        'price': 1200,
        'is_discount_available': false,
      }).single.slotConfigs.single;

      expect(slot.hasDiscount, isFalse);
      expect(slot.discountPrice, isNull);
    });

    test('the older key names still parse', () {
      final SlotPricingDraft slot = courtsFrom(<String, dynamic>{
        'price': 1200,
        'discount_type': 'flat',
        'discount_price': 250,
        'discount_start_date': '2026-09-14 06:00:00',
      }).single.slotConfigs.single;

      expect(slot.hasDiscount, isTrue);
      expect(slot.discountPrice, 250);
      expect(slot.discountStartsAt, DateTime(2026, 9, 14, 6));
    });
  });

  group('update validation', () {
    test('a slot with the discount off is always fine', () {
      expect(_slot().discountProblem, isNull);
      // Even carrying a leftover amount, since nothing discount-shaped is sent.
      expect(_slot(discountPrice: 200).discountProblem, isNull);
    });

    test('on with a type and a value is fine', () {
      expect(
        _slot(hasDiscount: true, discountPrice: 200).discountProblem,
        isNull,
      );
    });

    test('on with no value is refused', () {
      final String? problem = _slot(hasDiscount: true).discountProblem;
      expect(problem, isNotNull);
      expect(problem, contains('type'));
      expect(problem, contains('amount'));
    });

    test('on with a zero or negative value is refused', () {
      expect(
        _slot(hasDiscount: true, discountPrice: 0).discountProblem,
        isNotNull,
      );
      expect(
        _slot(hasDiscount: true, discountPrice: -50).discountProblem,
        isNotNull,
      );
    });

    test('a percentage over 100 is refused', () {
      expect(
        _slot(
          hasDiscount: true,
          discountType: 'Percent',
          discountPrice: 120,
        ).discountProblem,
        isNotNull,
      );
      // The same number is fine as a flat amount.
      expect(
        _slot(hasDiscount: true, discountPrice: 120).discountProblem,
        isNull,
      );
      // And 100% exactly is allowed — a free slot.
      expect(
        _slot(
          hasDiscount: true,
          discountType: 'Percent',
          discountPrice: 100,
        ).discountProblem,
        isNull,
      );
    });

    test('a window that ends before it starts is refused', () {
      expect(
        _slot(
          hasDiscount: true,
          discountPrice: 200,
          startsAt: DateTime(2026, 9, 20),
          endsAt: DateTime(2026, 9, 14),
        ).discountProblem,
        isNotNull,
      );
      // Equal ends are refused too: a zero-length window never applies.
      expect(
        _slot(
          hasDiscount: true,
          discountPrice: 200,
          startsAt: DateTime(2026, 9, 20),
          endsAt: DateTime(2026, 9, 20),
        ).discountProblem,
        isNotNull,
      );
    });

    test('one end alone, or neither, is fine', () {
      expect(
        _slot(
          hasDiscount: true,
          discountPrice: 200,
          startsAt: DateTime(2026, 9, 14),
        ).discountProblem,
        isNull,
      );
      expect(
        _slot(
          hasDiscount: true,
          discountPrice: 200,
          endsAt: DateTime(2026, 9, 20),
        ).discountProblem,
        isNull,
      );
    });
  });

  test('clearing the discount clears everything it set', () {
    final SlotPricingDraft on = _slot(
      hasDiscount: true,
      discountPrice: 250,
      startsAt: DateTime(2026, 9, 14, 6),
      endsAt: DateTime(2026, 9, 20),
    );
    final SlotPricingDraft off = on.copyWith(
      hasDiscount: false,
      clearDiscountPrice: true,
      clearDiscountStartsAt: true,
      clearDiscountEndsAt: true,
    );

    expect(off.hasDiscount, isFalse);
    expect(off.discountPrice, isNull);
    expect(off.discountStartsAt, isNull);
    expect(off.discountEndsAt, isNull);
    // The slot's own prices are untouched.
    expect(off.price, 1200);
  });
}
