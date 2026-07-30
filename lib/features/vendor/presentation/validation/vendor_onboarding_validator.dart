import 'package:flutter/material.dart' show TimeOfDay;
import 'package:hamro_footsall/core/widgets/custom_time_field.dart';
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

  /// Validates one slot against the other schedules for the same court.
  ///
  /// Adjacent ranges (05:00–06:00 and 06:00–07:00) are allowed. Exact
  /// duplicates, partial overlaps and ranges contained by another slot are
  /// rejected whenever the schedules share at least one booking day.
  static String? validateSlotTiming(
    SlotPricingDraft candidate,
    Iterable<SlotPricingDraft> courtSlots,
  ) {
    final TimeOfDay? start = timeOfDayFromString(candidate.startTime);
    final TimeOfDay? end = timeOfDayFromString(candidate.endTime);
    if (start == null || end == null) {
      return 'Select a valid start and end time.';
    }

    final int startMinutes = minutesFromTimeOfDay(start);
    final int endMinutes = minutesFromTimeOfDay(end);
    if (startMinutes == endMinutes) {
      return 'Start and end time cannot be the same.';
    }
    if (startMinutes > endMinutes) {
      return 'End time must be later than start time.';
    }

    final Set<String> candidateDays = candidate.days
        .map((String day) => day.trim().toLowerCase())
        .where((String day) => day.isNotEmpty)
        .toSet();
    for (final SlotPricingDraft existing in courtSlots) {
      if (identical(existing, candidate)) continue;
      if (candidate.id.isNotEmpty && existing.id == candidate.id) continue;
      final Set<String> existingDays = existing.days
          .map((String day) => day.trim().toLowerCase())
          .where((String day) => day.isNotEmpty)
          .toSet();
      if (!candidateDays.any(existingDays.contains)) continue;

      final TimeOfDay? existingStart = timeOfDayFromString(existing.startTime);
      final TimeOfDay? existingEnd = timeOfDayFromString(existing.endTime);
      if (existingStart == null || existingEnd == null) continue;
      final int existingStartMinutes = minutesFromTimeOfDay(existingStart);
      final int existingEndMinutes = minutesFromTimeOfDay(existingEnd);
      if (existingStartMinutes >= existingEndMinutes) continue;

      final bool overlaps =
          startMinutes < existingEndMinutes &&
          existingStartMinutes < endMinutes;
      if (!overlaps) continue;

      final bool duplicate =
          startMinutes == existingStartMinutes &&
          endMinutes == existingEndMinutes;
      final String name = existing.label.trim().isEmpty
          ? 'another slot'
          : '"${existing.label.trim()}"';
      return duplicate
          ? 'This time slot already exists on the selected day(s).'
          : 'This time overlaps with $name on the selected day(s).';
    }
    return null;
  }

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
            if (draft.photos.isEmpty && draft.memories.isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Upload at least one photo or memory for the court.',
              );
            }
            return VendorValidationResult.valid(key);
        }
      case 1:
        switch (subsectionIndex) {
          case 0:
            if (draft.advancePaymentRequired) {
              if (draft.advancePaymentType == null) {
                return VendorValidationResult.invalid(
                  key,
                  'Select an advance payment type.',
                );
              }
              final double? price = draft.advancePrice;
              if (price == null || price <= 0) {
                return VendorValidationResult.invalid(
                  key,
                  'Enter the advance payment amount.',
                );
              }
              if (draft.advancePaymentType == AdvancePaymentType.percentage &&
                  price > 100) {
                return VendorValidationResult.invalid(
                  key,
                  'Percentage cannot exceed 100.',
                );
              }
              if (draft.advancePaymentType == AdvancePaymentType.flat) {
                final double? basePrice = draft.basePrice;
                if (basePrice != null && price > basePrice) {
                  return VendorValidationResult.invalid(
                    key,
                    'Flat amount cannot exceed the base price.',
                  );
                }
              }
            }
            return VendorValidationResult.valid(key);
          case 1:
            if (draft.advancePaymentRequired && draft.paymentQr == null) {
              return VendorValidationResult.invalid(
                key,
                'Upload the QR used for advance payment.',
              );
            }
            return VendorValidationResult.valid(key);
        }
      case 2:
        switch (subsectionIndex) {
          case 0:
            if (draft.amenities.isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Select at least one court amenity.',
              );
            }
            return VendorValidationResult.valid(key);
          case 1:
            if (draft.facilities.isEmpty) {
              return VendorValidationResult.invalid(
                key,
                'Select at least one court facility.',
              );
            }
            return VendorValidationResult.valid(key);
        }
        return VendorValidationResult.valid(key);
      case 3:
        switch (subsectionIndex) {
          case 0:
            return VendorValidationResult.valid(key);
          case 1:
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
          case 2:
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
            return draft.photos.isNotEmpty || draft.memories.isNotEmpty;
        }
      case 1:
        switch (subsectionIndex) {
          case 0:
            return draft.advancePaymentRequired ||
                draft.advancePrice != null ||
                draft.advancePaymentType != null;
          case 1:
            return draft.paymentQr != null;
        }
      case 2:
        switch (subsectionIndex) {
          case 0:
            return draft.amenities.isNotEmpty;
          case 1:
            return draft.facilities.isNotEmpty;
        }
        return false;
      case 3:
        switch (subsectionIndex) {
          case 0:
            return draft.weekendDays.isNotEmpty ||
                draft.holidayDates.isNotEmpty ||
                draft.closedDates.isNotEmpty;
          case 1:
            return draft.slotConfigs.isNotEmpty;
          case 2:
            return draft.slotConfigs.any(
              (SlotPricingDraft slot) =>
                  slot.price != null ||
                  slot.weekendPrice != null ||
                  slot.holidayPrice != null ||
                  slot.discountPrice != null ||
                  slot.paymentPercent != null,
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
    for (final SlotPricingDraft slot in slots) {
      if (validateSlotTiming(slot, slots) != null) return true;
    }
    return false;
  }
}
