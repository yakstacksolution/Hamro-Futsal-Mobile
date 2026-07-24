import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/weekday_option.dart';

final class CourtOnboardingResponseModel {
  const CourtOnboardingResponseModel({
    this.id,
    this.venueId,
    this.courtTypeId,
    this.matchFormatId,
    this.mainStep = 0,
    this.subStep = 0,
    this.isStepCompleted = false,
    this.name = '',
    this.basePrice,
    this.description = '',
    this.capacity,
    this.advancePaymentRequired,
    this.advancePaymentType,
    this.advancePrice,
    this.paymentQr,
    this.slug,
    this.code,
    this.surfaceType,
    this.slotDuration,
    this.isPaymentRequired,
    this.status,
    this.bookingPolicies,
    this.courtRules,
    this.cancellationPolicy,
    this.amenities = const <int>{},
    this.facilities = const <int>{},
    this.amenityDetails = const <CourtTagDetail>[],
    this.facilityDetails = const <CourtTagDetail>[],
    this.photos = const <UploadRef>[],
    this.memories = const <UploadRef>[],
    this.weekendDays = const <String>{},
    this.holidayDates = const <String>{},
    this.closedDates = const <ClosedDateDraft>[],
    this.slotConfigs = const <SlotPricingDraft>[],
  });

  final int? id;
  final int? venueId;
  final int? courtTypeId;
  final int? matchFormatId;
  final int mainStep;
  final int subStep;
  final bool isStepCompleted;
  final String name;
  final double? basePrice;
  final String description;
  final int? capacity;
  final bool? advancePaymentRequired;
  final AdvancePaymentType? advancePaymentType;
  final double? advancePrice;
  final UploadRef? paymentQr;
  final String? slug;
  final String? code;
  final String? surfaceType;
  final int? slotDuration;
  final bool? isPaymentRequired;
  final String? status;
  final String? bookingPolicies;
  final String? courtRules;
  final String? cancellationPolicy;
  final Set<int> amenities;
  final Set<int> facilities;
  final List<CourtTagDetail> amenityDetails;
  final List<CourtTagDetail> facilityDetails;
  final List<UploadRef> photos;
  final List<UploadRef> memories;
  final Set<String> weekendDays;
  final Set<String> holidayDates;
  final List<ClosedDateDraft> closedDates;

  /// Booking slots parsed from `slot_schedules` (label, days, and times).
  /// Pricing from `slot_pricings` is layered on top during [mergeInto].
  final List<SlotPricingDraft> slotConfigs;

  factory CourtOnboardingResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    // The create/update endpoints sometimes wrap the saved court under a
    // nested key (the same way the detail endpoint does). Unwrap it when the
    // top level has no court id of its own so the `id` is parsed into
    // `remoteId`; otherwise every save would look like a brand-new court and
    // create a duplicate instead of updating the existing one.
    if (data['id'] == null && data['court_id'] == null) {
      final dynamic nested =
          data['court'] ?? data['venue_court'] ?? data['details'];
      if (nested is Map) {
        data = Map<String, dynamic>.from(nested);
      }
    }

    return CourtOnboardingResponseModel(
      id: _asInt(data['id'] ?? data['court_id']),
      venueId: _asInt(data['venue_id']),
      courtTypeId: _asInt(data['court_type_id'] ?? data['court_type']),
      matchFormatId: _asInt(data['match_format_id'] ?? data['match_format']),
      mainStep: _asInt(data['main_step']) ?? 0,
      subStep: _asInt(data['sub_step']) ?? 0,
      isStepCompleted: _asBool(data['is_step_completed']) ?? false,
      name: _asTrimmedString(data['name'] ?? data['court_name']),
      basePrice: _asDouble(data['base_price']),
      description: _asTrimmedString(data['description']),
      capacity: _asInt(data['capacity'] ?? data['max_player']),
      advancePaymentRequired: _asBool(data['advance_payment_required']),
      advancePaymentType: AdvancePaymentType.fromString(
        data['advance_payment_type']?.toString(),
      ),
      advancePrice: _asDouble(data['advance_price']),
      paymentQr: _uploadRefFromAny(
        data['payment_qr_media'] ?? data['payment_qr'],
      ),
      slug: _nonEmptyString(data['slug']),
      code: _nonEmptyString(data['code']),
      surfaceType: _nonEmptyString(data['surface_type']),
      slotDuration: _asInt(data['slot_duration']),
      isPaymentRequired: _asBool(data['is_payment_required']),
      status: _nonEmptyString(data['status']),
      bookingPolicies: _nonEmptyString(data['booking_policies']),
      courtRules: _nonEmptyString(data['court_rules']),
      cancellationPolicy: _nonEmptyString(data['cancellation_policy']),
      amenityDetails: _tagDetailsFromAny(data['amenities']),
      facilityDetails: _tagDetailsFromAny(data['facilities']),
      amenities: _idSetFromAny(data['amenities']),
      facilities: _idSetFromAny(data['facilities']),
      photos: _uploadsFromAny(data['court_photos']),
      memories: _uploadsFromAny(data['court_memories']),
      weekendDays: _weekendKeysFromAny(data['weekend_days']),
      holidayDates: _holidayDatesFromAny(data['holiday_dates']),
      closedDates: _closedDatesFromAny(data['closed_dates']),
      slotConfigs: _slotSchedulesFromAny(
        data['slot_schedules'],
        data['slot_pricings'],
      ),
    );
  }

  CourtDraft mergeInto(CourtDraft draft) {
    return draft.copyWith(
      remoteId: id,
      venueId: venueId,
      mainStep: mainStep,
      subStep: subStep,
      name: name.isEmpty ? draft.name : name,
      basePrice: basePrice,
      description: description.isEmpty ? draft.description : description,
      courtTypeId: courtTypeId,
      matchFormatId: matchFormatId,
      maxPlayers: capacity,
      surfaceType: surfaceType,
      slotDuration: slotDuration,
      isPaymentRequired: isPaymentRequired,
      advancePaymentRequired: advancePaymentRequired,
      advancePaymentType: advancePaymentType,
      advancePrice: advancePrice,
      slug: slug,
      code: code,
      status: status,
      isActive: status == null
          ? null
          : status!.trim().toLowerCase() != 'inactive',
      bookingPolicies: bookingPolicies,
      courtRules: courtRules,
      cancellationPolicy: cancellationPolicy,
      paymentQr: paymentQr ?? draft.paymentQr,
      amenities: amenities.isEmpty ? draft.amenities : amenities,
      facilities: facilities.isEmpty ? draft.facilities : facilities,
      amenityDetails: amenityDetails.isEmpty
          ? draft.amenityDetails
          : amenityDetails,
      facilityDetails: facilityDetails.isEmpty
          ? draft.facilityDetails
          : facilityDetails,
      photos: photos.isEmpty ? draft.photos : photos,
      memories: memories.isEmpty ? draft.memories : memories,
      weekendDays: weekendDays.isEmpty ? draft.weekendDays : weekendDays,
      holidayDates: holidayDates,
      closedDates: closedDates,
      slotConfigs: _mergeSlotConfigs(draft.slotConfigs, slotConfigs),
    );
  }
}

/// Replaces the draft slots with the backend schedules while carrying over any
/// pricing the vendor already entered locally (matched by remote id, then by
/// label). Keeps the existing slots untouched when no schedules are returned.
List<SlotPricingDraft> _mergeSlotConfigs(
  List<SlotPricingDraft> existing,
  List<SlotPricingDraft> schedules,
) {
  if (schedules.isEmpty) return existing;
  return schedules
      .map((SlotPricingDraft schedule) {
        SlotPricingDraft? prior;
        for (final SlotPricingDraft item in existing) {
          final bool sameId = item.id.isNotEmpty && item.id == schedule.id;
          final bool sameLabel =
              item.label.trim().isNotEmpty &&
              item.label.trim().toLowerCase() ==
                  schedule.label.trim().toLowerCase();
          if (sameId || sameLabel) {
            prior = item;
            break;
          }
        }
        if (prior == null) return schedule;
        return SlotPricingDraft(
          id: schedule.id,
          label: schedule.label,
          days: schedule.days,
          startTime: schedule.startTime,
          endTime: schedule.endTime,
          price: prior.price,
          weekendPrice: prior.weekendPrice,
          holidayPrice: prior.holidayPrice,
          customDatePrices: prior.customDatePrices,
          discountPrice: prior.discountPrice,
          discountType: prior.discountType,
          paymentPercent: prior.paymentPercent,
        );
      })
      .toList(growable: false);
}

Set<String> _weekendKeysFromAny(Object? value) {
  if (value is! List) return const <String>{};
  return value
      .map((Object? item) {
        final Object? raw = item is Map
            ? (item['key'] ?? item['id'] ?? item['name'] ?? item['day'])
            : item;
        return WeekdayOption.fromAny(raw)?.key;
      })
      .whereType<String>()
      .toSet();
}

Set<String> _holidayDatesFromAny(Object? value) {
  if (value is! List) return const <String>{};
  return value
      .map((Object? item) {
        if (item is Map) {
          return _asTrimmedString(item['date'] ?? item['name']);
        }
        // The backend may wrap each holiday date in its own list,
        // e.g. `holiday_dates: [[2026-05-31], [2026-06-01]]`.
        if (item is List) {
          return item.isEmpty ? '' : _asTrimmedString(item.first);
        }
        return _asTrimmedString(item);
      })
      .where((String item) => item.isNotEmpty)
      .toSet();
}

List<ClosedDateDraft> _closedDatesFromAny(Object? value) {
  if (value is! List) return const <ClosedDateDraft>[];
  return value
      .whereType<Map>()
      .map((Map item) {
        final Object? closureType = item['closure_type'] ?? item['closer_type'];
        final bool isFullDay = closureType != null
            ? closureType.toString().trim().toLowerCase() != 'hourly'
            : _asBool(item['is_full_day']) ?? true;
        return ClosedDateDraft(
          date: _asTrimmedString(item['date']),
          isFullDay: isFullDay,
          startTime: isFullDay ? '' : _asTrimmedString(item['start_time']),
          endTime: isFullDay ? '' : _asTrimmedString(item['end_time']),
        );
      })
      .where((ClosedDateDraft item) => item.date.isNotEmpty)
      .toList(growable: false);
}

List<CourtTagDetail> _tagDetailsFromAny(Object? value) {
  if (value is! List) return const <CourtTagDetail>[];
  return value
      .whereType<Map>()
      .map(
        (Map item) => CourtTagDetail.fromJson(Map<String, dynamic>.from(item)),
      )
      .where((CourtTagDetail item) => item.id != 0)
      .toList(growable: false);
}

Set<int> _idSetFromAny(Object? value) {
  if (value is! List) return const <int>{};
  return value
      .map((Object? item) {
        if (item is Map) {
          return _asInt(
            item['id'] ?? item['amenity_id'] ?? item['facility_id'],
          );
        }
        return _asInt(item);
      })
      .whereType<int>()
      .toSet();
}

List<UploadRef> _uploadsFromAny(Object? value) {
  if (value is! List) return const <UploadRef>[];
  return value
      .whereType<Map>()
      .map((Map item) => _uploadRefFromAny(item))
      .whereType<UploadRef>()
      .toList(growable: false);
}

UploadRef? _uploadRefFromAny(Object? value) {
  if (value is! Map) return null;
  final Map<String, dynamic> map = Map<String, dynamic>.from(value);
  final int? id = _asInt(map['id'] ?? map['media_id']);
  if (id == null) return null;
  return UploadRef(
    id: id,
    name: _asTrimmedString(map['name'] ?? map['file_name'] ?? map['title']),
    remoteUrl: _nonEmptyString(
      map['full_url'] ?? map['url'] ?? map['path'] ?? map['file_url'],
    ),
  );
}

String? _nonEmptyString(Object? value) {
  final String text = _asTrimmedString(value);
  return text.isEmpty ? null : text;
}

List<SlotPricingDraft> _slotSchedulesFromAny(
  Object? schedules,
  Object? pricings,
) {
  if (schedules is! List) return const <SlotPricingDraft>[];

  // Index pricing rows by slot id so we can attach them to their schedule.
  final Map<String, Map<String, dynamic>> pricingById =
      <String, Map<String, dynamic>>{};
  if (pricings is List) {
    for (final Object? item in pricings) {
      if (item is Map) {
        final String slotId = _asTrimmedString(
          item['slot_schedule_id'] ?? item['slot_id'] ?? item['id'],
        );
        if (slotId.isNotEmpty) {
          pricingById[slotId] = Map<String, dynamic>.from(item);
        }
      }
    }
  }

  return schedules
      .whereType<Map>()
      .map((Map item) {
        final String id = _asTrimmedString(item['id'] ?? item['slot_id']);
        final Map<String, dynamic>? pricing = pricingById[id];
        return SlotPricingDraft(
          id: id,
          label: _asTrimmedString(item['label'] ?? item['name']),
          days: _slotDaysFromAny(item['days']),
          startTime: _timeFromApi(item['start_time']),
          endTime: _timeFromApi(item['end_time']),
          price: _asDouble(pricing?['price'] ?? pricing?['base_price']),
          weekendPrice: _asDouble(pricing?['weekend_price']),
          holidayPrice: _asDouble(pricing?['holiday_price']),
          discountPrice: _asDouble(pricing?['discount_price']),
          paymentPercent: _asDouble(pricing?['payment_percent']),
        );
      })
      .where((SlotPricingDraft item) => item.id.isNotEmpty)
      .toList(growable: false);
}

/// Normalizes backend day codes (lowercase, e.g. `sun`) to the capitalized
/// short labels the slot UI uses (`Sun`).
Set<String> _slotDaysFromAny(Object? value) {
  if (value is! List) return const <String>{};
  return value
      .map((Object? item) => WeekdayOption.fromAny(item)?.label)
      .whereType<String>()
      .toSet();
}

/// Converts a backend time (`HH:mm` or `HH:mm:ss`, 24-hour) into the 12-hour
/// display string the time picker produces (e.g. `23:36:00` -> `11 : 36 PM`),
/// so the field shows it and re-serializes cleanly. Empty when unparseable.
String _timeFromApi(Object? value) {
  final String raw = _asTrimmedString(value);
  if (raw.isEmpty) return '';
  final List<String> parts = raw.split(':');
  if (parts.length < 2) return '';
  final int? hour = int.tryParse(parts[0].trim());
  final int? minute = int.tryParse(parts[1].trim());
  if (hour == null || minute == null) return '';
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return '';
  final int twelveHour = hour % 12 == 0 ? 12 : hour % 12;
  final String meridiem = hour < 12 ? 'AM' : 'PM';
  return '${twelveHour.toString().padLeft(2, '0')} : '
      '${minute.toString().padLeft(2, '0')} $meridiem';
}

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

bool? _asBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return null;
}

String _asTrimmedString(Object? value) {
  if (value == null) return '';
  return value.toString().trim();
}
