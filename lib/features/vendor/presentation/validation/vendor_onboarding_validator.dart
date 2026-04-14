import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';

class VendorValidationResult {
  const VendorValidationResult.valid(this.key) : isValid = true, message = null;

  const VendorValidationResult.invalid(this.key, this.message)
    : isValid = false;

  final String key;
  final bool isValid;
  final String? message;
}

class VendorOnboardingValidator {
  const VendorOnboardingValidator._();

  static bool canUnlockCourts(FutsalDraft draft) {
    return validateFutsalSubstep(draft, 0, 0).isValid &&
        validateFutsalSubstep(draft, 0, 2).isValid;
  }

  static VendorValidationResult validateFutsalSubstep(
    FutsalDraft draft,
    int sectionIndex,
    int subsectionIndex,
  ) {
    final String key = futsalSubstepKey(sectionIndex, subsectionIndex);
    switch (sectionIndex) {
      case 0:
        switch (subsectionIndex) {
          case 0:
            if (draft.title.trim().isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Please provide the name of your futsal.',
              );
            }
            if (draft.slug.trim().isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'A unique slug is required for your futsal profile.',
              );
            }
            if (!_isSlugValid(draft.slug)) {
              return VendorValidationResult.invalid(
                key,
                'The slug may only contain lowercase letters, numbers, and hyphens.',
              );
            }
            if (draft.phone.trim().isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Please enter a valid contact phone number.',
              );
            }
            if (draft.email.trim().isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Please enter a valid contact email address.',
              );
            }
            if (!_isOptionalUrlValid(draft.websiteOrSocialLink)) {
              return VendorValidationResult.invalid(
                key,
                'Please provide a valid website or social media link (including http/https).',
              );
            }
            return VendorValidationResult.valid(key);
          case 1:
            if (!_hasMeaningfulRichText(draft.description)) {
              return VendorValidationResult.invalid(
                key,
                'Please provide a description for your futsal.',
              );
            }
            return VendorValidationResult.valid(key);
          case 2:
            if (draft.location.fullAddress.trim().isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Please enter the complete address of your futsal.',
              );
            }
            if (draft.location.exactLocation.trim().isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Please specify the exact location of your futsal.',
              );
            }
            if (draft.location.longitude == null ||
                draft.location.latitude == null) {
              return VendorValidationResult.invalid(
                key,
                'Please provide both longitude and latitude coordinates.',
              );
            }
            return VendorValidationResult.valid(key);
          case 3:
            if (draft.amenities.isEmpty && draft.features.isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Please select at least one amenity or feature for your futsal.',
              );
            }
            return VendorValidationResult.valid(key);
        }
      case 1:
        switch (subsectionIndex) {
          case 0:
            if (draft.cancellationPolicy.trim().isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Please specify your cancellation policy.',
              );
            }
            return VendorValidationResult.valid(key);
          case 1:
            if (draft.futsalRules.trim().isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Please provide the rules for your futsal.',
              );
            }
            return VendorValidationResult.valid(key);
          case 2:
            if (draft.commissionPercent == null) {
              return VendorValidationResult.invalid(
                key,
                'Please specify the commission percentage.',
              );
            }
            return VendorValidationResult.valid(key);
        }
      case 2:
        switch (subsectionIndex) {
          case 0:
            if (draft.coverImage == null) {
              return VendorValidationResult.invalid(
                key,
                'Please upload a cover image for your futsal.',
              );
            }
            return VendorValidationResult.valid(key);
          case 1:
            if (draft.gallery.isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Please upload at least one image to the futsal gallery.',
              );
            }
            return VendorValidationResult.valid(key);
          case 2:
            if (draft.companyDocuments.isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Please upload the required company documents before proceeding.',
              );
            }
            return VendorValidationResult.valid(key);
        }
    }

    return VendorValidationResult.valid(key);
  }

  static VendorValidationResult validateCourtSubstep(
    CourtDraft draft,
    int sectionIndex,
    int subsectionIndex,
  ) {
    final String key = courtSubstepKey(draft.id, sectionIndex, subsectionIndex);
    switch (sectionIndex) {
      case 0:
        switch (subsectionIndex) {
          case 0:
            if (draft.name.trim().isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Enter the court name.',
              );
            }
            if (draft.basePrice == null) {
              return VendorValidationResult.invalid(
                key,
                'Enter the court base price.',
              );
            }
            if ((draft.courtType ?? '').trim().isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Select the court type.',
              );
            }
            return VendorValidationResult.valid(key);
          case 1:
            if (!_hasMeaningfulRichText(draft.description)) {
              return VendorValidationResult.invalid(
                key,
                'Enter the court description.',
              );
            }
            return VendorValidationResult.valid(key);
          case 2:
            if (draft.availability.days.isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Select the court availability days.',
              );
            }
            if (!draft.availability.isOpen24Hours &&
                (draft.availability.openTime.trim().isEmpty ||
                    draft.availability.closeTime.trim().isEmpty)) {
              return VendorValidationResult.invalid(
                key,
                'Enter opening and closing time for the court.',
              );
            }
            return VendorValidationResult.valid(key);
        }
      case 1:
        switch (subsectionIndex) {
          case 0:
            return VendorValidationResult.valid(key);
          case 1:
            return VendorValidationResult.valid(key);
          case 2:
            if (draft.advancePaymentRequired && draft.paymentPercent == null) {
              return VendorValidationResult.invalid(
                key,
                'Enter the advance payment percentage.',
              );
            }
            return VendorValidationResult.valid(key);
          case 3:
            if (draft.advancePaymentRequired && draft.paymentQr == null) {
              return VendorValidationResult.invalid(
                key,
                'Upload the QR used for advance payment.',
              );
            }
            return VendorValidationResult.valid(key);
        }
      case 2:
        if (draft.amenities.isEmpty && draft.facilities.isEmpty) {
          return VendorValidationResult.invalid(
            key,
            'Select at least one court amenity or facility.',
          );
        }
        return VendorValidationResult.valid(key);
      case 3:
        if (draft.photos.isEmpty && draft.memories.isEmpty) {
          return VendorValidationResult.invalid(
            key,
            'Upload at least one photo or memory for the court.',
          );
        }
        return VendorValidationResult.valid(key);
      case 4:
        switch (subsectionIndex) {
          case 0:
            if (draft.slotConfigs.isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Add at least one slot for this court.',
              );
            }
            if (draft.slotConfigs.any(
              (SlotPricingDraft slot) => !_isSlotScheduleValid(slot),
            )) {
              return VendorValidationResult.invalid(
                key,
                'Complete day and time details for all slots.',
              );
            }
            if (_hasSlotOverlap(draft.slotConfigs)) {
              return VendorValidationResult.invalid(
                key,
                'Resolve overlapping slots before continuing.',
              );
            }
            return VendorValidationResult.valid(key);
          case 1:
            if (draft.slotConfigs.isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Add at least one slot before setting pricing.',
              );
            }
            if (draft.slotConfigs.any(
              (SlotPricingDraft slot) => !_isSlotPricingValid(slot),
            )) {
              return VendorValidationResult.invalid(
                key,
                'Complete price details for all configured slots.',
              );
            }
            return VendorValidationResult.valid(key);
        }
    }

    return VendorValidationResult.valid(key);
  }

  static bool hasFutsalSubstepData(
    FutsalDraft draft,
    int sectionIndex,
    int subsectionIndex,
  ) {
    switch (sectionIndex) {
      case 0:
        switch (subsectionIndex) {
          case 0:
            return draft.title.trim().isNotEmpty ||
                draft.slug.trim().isNotEmpty ||
                draft.registrationNumber.trim().isNotEmpty ||
                draft.phone.trim().isNotEmpty ||
                draft.email.trim().isNotEmpty ||
                draft.websiteOrSocialLink.trim().isNotEmpty;
          case 1:
            return _hasMeaningfulRichText(draft.description);
          case 2:
            return draft.location.fullAddress.trim().isNotEmpty ||
                draft.location.exactLocation.trim().isNotEmpty ||
                draft.location.longitude != null ||
                draft.location.latitude != null;
          case 3:
            return draft.amenities.isNotEmpty || draft.features.isNotEmpty;
        }
      case 1:
        switch (subsectionIndex) {
          case 0:
            return draft.cancellationPolicy.trim().isNotEmpty;
          case 1:
            return draft.futsalRules.trim().isNotEmpty;
          case 2:
            return draft.commissionPercent != null;
        }
      case 2:
        switch (subsectionIndex) {
          case 0:
            return draft.coverImage != null;
          case 1:
            return draft.gallery.isNotEmpty;
          case 2:
            return draft.companyDocuments.isNotEmpty;
        }
    }
    return false;
  }

  static bool hasCourtSubstepData(
    CourtDraft draft,
    int sectionIndex,
    int subsectionIndex,
  ) {
    switch (sectionIndex) {
      case 0:
        switch (subsectionIndex) {
          case 0:
            return draft.name.trim().isNotEmpty ||
                draft.basePrice != null ||
                (draft.courtType ?? '').trim().isNotEmpty;
          case 1:
            return _hasMeaningfulRichText(draft.description);
          case 2:
            return draft.availability.days.isNotEmpty ||
                draft.availability.openTime.trim().isNotEmpty ||
                draft.availability.closeTime.trim().isNotEmpty ||
                draft.availability.isOpen24Hours;
        }
      case 1:
        switch (subsectionIndex) {
          case 0:
            return draft.enableOnlineBooking;
          case 1:
            return draft.advancePaymentRequired;
          case 2:
            return draft.paymentPercent != null;
          case 3:
            return draft.paymentQr != null;
        }
      case 2:
        return draft.amenities.isNotEmpty || draft.facilities.isNotEmpty;
      case 3:
        return draft.photos.isNotEmpty || draft.memories.isNotEmpty;
      case 4:
        switch (subsectionIndex) {
          case 0:
            return draft.slotConfigs.isNotEmpty;
          case 1:
            return draft.slotConfigs.any(
              (SlotPricingDraft slot) =>
                  slot.price != null || slot.paymentPercent != null,
            );
        }
    }
    return false;
  }

  static String futsalSectionKey(int sectionIndex) =>
      'futsal_section_$sectionIndex';

  static String futsalSubstepKey(int sectionIndex, int subsectionIndex) =>
      'futsal_${sectionIndex}_$subsectionIndex';

  static String courtSectionKey(String courtId, int sectionIndex) =>
      'court_${courtId}_section_$sectionIndex';

  static String courtSubstepKey(
    String courtId,
    int sectionIndex,
    int subsectionIndex,
  ) => 'court_${courtId}_${sectionIndex}_$subsectionIndex';

  static bool _isSlotScheduleValid(SlotPricingDraft slot) {
    return slot.days.isNotEmpty &&
        slot.startTime.trim().isNotEmpty &&
        slot.endTime.trim().isNotEmpty;
  }

  static bool _isSlotPricingValid(SlotPricingDraft slot) {
    return slot.price != null &&
        (slot.paymentPercent == null ||
            (slot.paymentPercent! >= 0 && slot.paymentPercent! <= 100));
  }

  static bool _isSlugValid(String value) {
    return RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(value.trim());
  }

  static bool _isOptionalUrlValid(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return true;

    final Uri? uri = Uri.tryParse(trimmed);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  static bool _hasMeaningfulRichText(String value) {
    final String normalized = value
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return normalized.isNotEmpty;
  }

  static bool _hasSlotOverlap(List<SlotPricingDraft> slots) {
    for (int i = 0; i < slots.length; i++) {
      for (int j = i + 1; j < slots.length; j++) {
        if (_sharesDay(slots[i], slots[j]) && _overlaps(slots[i], slots[j])) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _sharesDay(SlotPricingDraft a, SlotPricingDraft b) {
    return a.days.any(b.days.contains);
  }

  static bool _overlaps(SlotPricingDraft a, SlotPricingDraft b) {
    final int? aStart = _timeToMinutes(a.startTime);
    final int? aEnd = _timeToMinutes(a.endTime);
    final int? bStart = _timeToMinutes(b.startTime);
    final int? bEnd = _timeToMinutes(b.endTime);
    if (aStart == null || aEnd == null || bStart == null || bEnd == null) {
      return false;
    }
    if (aStart >= aEnd || bStart >= bEnd) return true;
    return aStart < bEnd && bStart < aEnd;
  }

  static int? _timeToMinutes(String input) {
    final List<String> parts = input.trim().split(':');
    if (parts.length != 2) return null;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return (hour * 60) + minute;
  }
}
