import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_footsall/features/vendor/presentation/validation/vendor_onboarding_validator.dart';

void main() {
  const SlotPricingDraft morning = SlotPricingDraft(
    id: '1',
    label: 'Morning',
    days: <String>{'Monday'},
    startTime: '05 : 00 AM',
    endTime: '06 : 00 AM',
  );

  String? validate(SlotPricingDraft candidate) =>
      VendorOnboardingValidator.validateSlotTiming(
        candidate,
        const <SlotPricingDraft>[morning],
      );

  test('rejects an exact duplicate on a shared day', () {
    expect(
      validate(
        const SlotPricingDraft(
          id: '',
          label: 'Duplicate',
          days: <String>{'Monday'},
          startTime: '05 : 00 AM',
          endTime: '06 : 00 AM',
        ),
      ),
      contains('already exists'),
    );
  });

  test('rejects partial and contained overlaps', () {
    expect(
      validate(
        const SlotPricingDraft(
          id: '',
          days: <String>{'Monday'},
          startTime: '05 : 30 AM',
          endTime: '06 : 30 AM',
        ),
      ),
      contains('overlaps'),
    );
    expect(
      validate(
        const SlotPricingDraft(
          id: '',
          days: <String>{'Monday'},
          startTime: '05 : 15 AM',
          endTime: '05 : 45 AM',
        ),
      ),
      contains('overlaps'),
    );
  });

  test('allows adjacent times and the same time on a different day', () {
    expect(
      validate(
        const SlotPricingDraft(
          id: '',
          days: <String>{'Monday'},
          startTime: '06 : 00 AM',
          endTime: '07 : 00 AM',
        ),
      ),
      isNull,
    );
    expect(
      validate(
        const SlotPricingDraft(
          id: '',
          days: <String>{'Tuesday'},
          startTime: '05 : 00 AM',
          endTime: '06 : 00 AM',
        ),
      ),
      isNull,
    );
  });

  test('allows editing a slot without treating itself as a duplicate', () {
    expect(
      VendorOnboardingValidator.validateSlotTiming(
        morning,
        const <SlotPricingDraft>[morning],
      ),
      isNull,
    );
  });

  test('rejects equal or reversed ranges', () {
    expect(
      validate(
        const SlotPricingDraft(
          id: '',
          days: <String>{'Tuesday'},
          startTime: '05 : 00 AM',
          endTime: '05 : 00 AM',
        ),
      ),
      contains('cannot be the same'),
    );
    expect(
      validate(
        const SlotPricingDraft(
          id: '',
          days: <String>{'Tuesday'},
          startTime: '06 : 00 AM',
          endTime: '05 : 00 AM',
        ),
      ),
      contains('later than start'),
    );
  });
}
