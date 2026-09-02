import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_api_payload.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_futsal/features/vendor/presentation/validation/vendor_onboarding_validator.dart';

void main() {
  const SlotPricingDraft persisted = SlotPricingDraft(
    id: '42',
    label: 'Morning',
    days: <String>{'Monday'},
    startTime: '06:00 AM',
    endTime: '07:00 AM',
    price: 1200,
  );

  test('existing slot and pricing payloads use slot_id', () {
    expect(courtSlotBody(persisted, courtId: 7)['slot_id'], 42);
    expect(courtSlotPricingBody(persisted, courtId: 7)['slot_id'], 42);
  });

  test('court pricing sends percentage instead of percent', () {
    const SlotPricingDraft percentageDiscount = SlotPricingDraft(
      id: '42',
      label: 'Morning',
      days: <String>{'Monday'},
      startTime: '06:00 AM',
      endTime: '07:00 AM',
      price: 1200,
      discountPrice: 10,
      discountType: 'Percent',
    );

    expect(
      courtSlotPricingBody(percentageDiscount, courtId: 7)['discount_type'],
      'percentage',
    );
  });

  test('slot step blocks a valid but unpersisted slot', () {
    const CourtDraft court = CourtDraft(
      id: '7',
      slotConfigs: <SlotPricingDraft>[
        SlotPricingDraft(
          id: 'local-1',
          label: 'Morning',
          days: <String>{'Monday'},
          startTime: '06:00 AM',
          endTime: '07:00 AM',
          price: 1200,
        ),
      ],
    );

    final VendorValidationResult result =
        VendorOnboardingValidator.validateCourtSubstep(court, 3, 1);
    expect(result.isValid, isFalse);
    expect(result.message, contains('Morning'));
  });

  test('slot step accepts a persisted numeric id', () {
    const CourtDraft court = CourtDraft(
      id: '7',
      slotConfigs: <SlotPricingDraft>[persisted],
    );
    expect(
      VendorOnboardingValidator.validateCourtSubstep(court, 3, 1).isValid,
      isTrue,
    );
  });
}
