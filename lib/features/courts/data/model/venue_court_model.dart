import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/weekday_option.dart';

final class VenueCourtModel {
  const VenueCourtModel({
    required this.id,
    required this.title,
    required this.address,
    required this.phone,
    required this.status,
    required this.courts,
    this.imageUrl,
  });

  final int? id;
  final String title;
  final String address;
  final String phone;
  final String status;
  final List<CourtDraft> courts;
  final String? imageUrl;

  bool get isActive => status.toLowerCase() == 'active';

  factory VenueCourtModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> courtItems = _listFromAny(
      json['courts'] ?? json['venue_courts'] ?? json['court'],
    );

    return VenueCourtModel(
      id: _asInt(json['id'] ?? json['venue_id'] ?? json['futsal_id']),
      title: _asString(
        json['name'] ??
            json['title'] ??
            json['futsal_name'] ??
            json['venue_name'],
      ),
      address: _asString(
        json['address'] ?? json['location'] ?? json['futsal_address'],
      ),
      phone: _asString(json['phone'] ?? json['phone_number']),
      status: _asString(json['status']),
      imageUrl: _venueImageUrlFromJson(json),
      courts: courtItems
          .whereType<Map>()
          .map((Map item) => _courtFromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }

  static List<CourtDraft> courtsFromResponse(dynamic payload) {
    final dynamic data = payload is Map ? payload['data'] ?? payload : payload;
    final List<dynamic> items = _listFromAny(data);
    if (items.isNotEmpty) {
      return items
          .whereType<Map>()
          .map((Map item) => _courtFromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final dynamic courts =
          map['courts'] ?? map['venue_courts'] ?? map['court'];
      return _listFromAny(courts)
          .whereType<Map>()
          .map((Map item) => _courtFromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }
    return const <CourtDraft>[];
  }

  static CourtDraft courtFromResponse(dynamic payload) {
    final dynamic data = payload is Map ? payload['data'] ?? payload : payload;
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final dynamic nested =
          map['court'] ?? map['venue_court'] ?? map['details'];
      if (nested is Map) {
        return _courtFromJson(Map<String, dynamic>.from(nested));
      }
      return _courtFromJson(map);
    }
    throw const FormatException('Court detail payload is not an object.');
  }

  /// Parses slot responses into editable slots. Accepts:
  /// * a bare list, `{data: [...]}`, or a map with `slots`/`slot_schedules`
  ///   (list endpoints), and
  /// * a single-slot create/update response `{data: {slot: {...}}}` where the
  ///   slot carries nested `slot_pricing`.
  static List<SlotPricingDraft> slotsFromResponse(dynamic payload) {
    final dynamic data = payload is Map ? payload['data'] ?? payload : payload;

    if (data is List) {
      return _slotsFromResponse(data, null);
    }
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      // Single-slot create/update response.
      final dynamic single = map['slot'] ?? map['slot_schedule'];
      if (single is Map) {
        return _slotsFromResponse(<dynamic>[single], map['slot_pricings']);
      }
      return _slotsFromResponse(
        map['slots'] ?? map['slot_schedules'] ?? map['data'],
        map['slot_pricings'],
      );
    }
    return const <SlotPricingDraft>[];
  }

  static List<VenueCourtModel> listFromResponse(dynamic payload) {
    final dynamic data = payload is Map ? payload['data'] ?? payload : payload;

    final List<dynamic> venueItems = _listFromAny(data);
    if (venueItems.isNotEmpty) {
      return venueItems
          .whereType<Map>()
          .map(
            (Map item) =>
                VenueCourtModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    }

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final dynamic venues =
          map['venues'] ?? map['futsals'] ?? map['venue'] ?? map['futsal'];
      final List<dynamic> nestedVenues = _listFromAny(venues);
      if (nestedVenues.isNotEmpty) {
        return nestedVenues
            .whereType<Map>()
            .map(
              (Map item) =>
                  VenueCourtModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false);
      }

      return <VenueCourtModel>[VenueCourtModel.fromJson(map)];
    }

    return const <VenueCourtModel>[];
  }
}

CourtDraft _courtFromJson(Map<String, dynamic> json) {
  // Be liberal in how the court identifier can arrive so the tile always has a
  // stable, non-empty id (needed for navigation, detail fetch, and update).
  final Object? rawId =
      json['id'] ??
      json['court_id'] ??
      json['courtId'] ??
      json['_id'] ??
      json['uuid'];
  final int? remoteId = _asInt(rawId);
  final String rawIdString = rawId?.toString().trim() ?? '';
  final Object? courtType = json['court_type'];
  // The list endpoint sends `match_type` (e.g. "5v5"); detail/other endpoints
  // may use `match_format`. Accept both.
  final Object? matchFormat = json['match_format'] ?? json['match_type'];
  final String slug = _asString(json['slug']);
  final String code = _asString(json['code']);
  final String surfaceType = _asString(json['surface_type']);
  final Map<String, dynamic> availability = <String, dynamic>{
    'days': json['days'] ?? json['available_days'] ?? json['working_days'],
    'openTime':
        json['opening_time'] ??
        json['open_time'] ??
        json['openTime'] ??
        json['start_time'],
    'closeTime':
        json['closing_time'] ??
        json['close_time'] ??
        json['closeTime'] ??
        json['end_time'],
    'isOpen24Hours': json['is_open_24_hours'] ?? json['isOpen24Hours'],
  };

  final dynamic amenitiesRaw = json['amenities'] ?? json['court_amenities'];
  final dynamic facilitiesRaw = json['facilities'] ?? json['court_facilities'];
  final List<CourtTagDetail> amenityDetails = _tagDetailsFromAny(amenitiesRaw);
  final List<CourtTagDetail> facilityDetails = _tagDetailsFromAny(
    facilitiesRaw,
  );

  final dynamic paymentQrMedia = json['payment_qr_media'] ?? json['payment_qr'];
  final UploadRef? paymentQr = paymentQrMedia is Map
      ? _uploadRefFromMap(Map<String, dynamic>.from(paymentQrMedia))
      : (_asInt(json['payment_qr_id']) == null
            ? null
            : UploadRef(name: '', id: _asInt(json['payment_qr_id'])));

  return CourtDraft(
    id: remoteId?.toString() ?? (rawIdString.isNotEmpty ? rawIdString : slug),
    remoteId: remoteId,
    venueId: _asInt(json['venue_id']),
    mainStep: _asInt(json['main_step']),
    subStep: _asInt(json['sub_step']),
    isStepCompleted:
        _asBool(json['is_step_completed'] ?? json['is_completed']) ?? false,
    category: _asInt(json['category']),
    slug: slug.isEmpty ? null : slug,
    code: code.isEmpty ? null : code,
    name: _asString(json['name'] ?? json['court_name']),
    basePrice: _asDouble(json['base_price'] ?? json['price']),
    description: _asString(json['description']),
    courtTypeId: _asInt(json['court_type_id'] ?? courtType),
    courtType: _resolveOptionName(courtType, json['court_type_name']),
    matchFormatId: _asInt(json['match_format_id'] ?? matchFormat),
    matchFormat: _resolveOptionName(matchFormat, json['match_format_name']),
    maxPlayers:
        _asInt(json['capacity'] ?? json['max_player'] ?? json['max_players']) ??
        10,
    surfaceType: surfaceType.isEmpty ? null : surfaceType,
    slotDuration: _asInt(json['slot_duration']),
    slotCount: _asInt(json['slot_count'] ?? json['slotCount']),
    availability: AvailabilityDraft.fromJson(availability),
    enableOnlineBooking:
        _asBool(json['enable_online_booking']) ??
        _asString(json['status']).toLowerCase() != 'inactive',
    isPaymentRequired: _asBool(json['is_payment_required']) ?? true,
    advancePaymentRequired:
        _asBool(
          json['advance_payment_required'] ?? json['is_advance_payment'],
        ) ??
        false,
    advancePaymentType: AdvancePaymentType.fromString(
      json['advance_payment_type']?.toString(),
    ),
    advancePrice: _asDouble(json['advance_price'] ?? json['payment_percent']),
    paymentQr: paymentQr,
    amenities: amenityDetails.isNotEmpty
        ? amenityDetails.map((CourtTagDetail item) => item.id).toSet()
        : _idSetFromAny(amenitiesRaw),
    facilities: facilityDetails.isNotEmpty
        ? facilityDetails.map((CourtTagDetail item) => item.id).toSet()
        : _idSetFromAny(facilitiesRaw),
    amenityDetails: amenityDetails,
    facilityDetails: facilityDetails,
    photos: _uploadsFromAny(
      json['court_photos'] ?? json['photos'] ?? json['images'] ?? json['media'],
    ),
    memories: _uploadsFromAny(json['court_memories'] ?? json['memories']),
    weekendDays: _weekendKeysFromAny(json['weekend_days']).isEmpty
        ? const <String>{'sat'}
        : _weekendKeysFromAny(json['weekend_days']),
    holidayDates: _nameSetFromAny(json['holiday_dates']),
    closedDates: _closedDatesFromAny(json['closed_dates']),
    slotConfigs: _slotsFromResponse(
      json['slot_schedules'],
      json['slot_pricings'] ??
          json['slot_configs'] ??
          json['slotConfigs'] ??
          json['slots'],
    ),
    slotSchedules: _mapListFromAny(json['slot_schedules']),
    bookingPolicies: json['booking_policies'] as String?,
    courtRules: json['court_rules'] as String?,
    cancellationPolicy: json['cancellation_policy'] as String?,
    status: json['status'] as String?,
  );
}

/// Extracts a display image url for the venue. The vendor endpoints send media
/// objects (`cover_image_media`, `gallery_media`); other endpoints may send a
/// direct string (`feature_image`) or a gallery list (`venue_gallery_images`),
/// so check each shape in turn.
String? _venueImageUrlFromJson(Map<String, dynamic> json) {
  final String direct = _imageUrlFromAny(
    json['cover_image_media'] ??
        json['cover_image'] ??
        json['feature_image'] ??
        json['image_url'] ??
        json['image'] ??
        json['logo'],
  );
  if (direct.isNotEmpty) return direct;

  for (final dynamic item in _listFromAny(
    json['gallery_media'] ??
        json['venue_gallery_images'] ??
        json['gallery_images'] ??
        json['venue_photos'] ??
        json['photos'] ??
        json['images'],
  )) {
    final String url = _imageUrlFromAny(item);
    if (url.isNotEmpty) return url;
  }
  return null;
}

/// Resolves an image url from either a plain string or a media object.
String _imageUrlFromAny(dynamic value) {
  if (value is Map) {
    return _asString(
      value['image_url'] ??
          value['full_url'] ??
          value['url'] ??
          value['original_url'] ??
          value['preview_url'] ??
          value['media_url'] ??
          value['file_url'] ??
          value['thumbnail_url'] ??
          value['src'] ??
          value['path'] ??
          value['file_path'],
    );
  }
  return _asString(value);
}

List<dynamic> _listFromAny(dynamic value) {
  if (value is List) return value;
  if (value is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(value);
    final dynamic items =
        map['items'] ?? map['results'] ?? map['data'] ?? map['courts'];
    if (items is List) return items;
  }
  return const <dynamic>[];
}

String? _optionName(Object? value) {
  if (value is Map) {
    return _asString(value['name'] ?? value['title']).trim().isEmpty
        ? null
        : _asString(value['name'] ?? value['title']);
  }
  return null;
}

/// Resolves a display name that the backend may send either as an object
/// (`{id, name}`), as a plain scalar string (`"Hard Court"`, `"5v5"`), or via a
/// separate `*_name` field. Returns an empty string when none are present.
String _resolveOptionName(Object? value, Object? fallbackName) {
  final String? fromOption = _optionName(value);
  if (fromOption != null && fromOption.isNotEmpty) return fromOption;
  if (value is! Map) {
    final String scalar = _asString(value);
    if (scalar.isNotEmpty) return scalar;
  }
  return _asString(fallbackName);
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

String _asString(Object? value) {
  if (value == null) return '';
  return value.toString().trim();
}

Set<int> _idSetFromAny(dynamic value) {
  final List<dynamic> items = _listFromAny(value);
  return items
      .map((dynamic item) {
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

Set<String> _weekendKeysFromAny(dynamic value) {
  return _listFromAny(value)
      .map((dynamic item) {
        final dynamic raw = item is Map
            ? (item['key'] ?? item['id'] ?? item['name'] ?? item['day'])
            : item;
        return WeekdayOption.fromAny(raw)?.key;
      })
      .whereType<String>()
      .toSet();
}

List<CourtTagDetail> _tagDetailsFromAny(dynamic value) {
  return _listFromAny(value)
      .whereType<Map>()
      .map(
        (Map item) => CourtTagDetail.fromJson(Map<String, dynamic>.from(item)),
      )
      .where((CourtTagDetail item) => item.id != 0)
      .toList(growable: false);
}

Set<String> _nameSetFromAny(dynamic value) {
  final List<dynamic> items = _listFromAny(value);
  if (items.isEmpty && value is String && value.trim().isNotEmpty) {
    return value
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toSet();
  }
  return items
      .map((dynamic item) {
        if (item is Map) {
          return _asString(item['name'] ?? item['title'] ?? item['date']);
        }
        // The backend may wrap each holiday date in its own list,
        // e.g. `holiday_dates: [[2026-05-31], [2026-06-01]]`.
        if (item is List) {
          return item.isEmpty ? '' : _asString(item.first);
        }
        return _asString(item);
      })
      .where((String item) => item.isNotEmpty)
      .toSet();
}

List<UploadRef> _uploadsFromAny(dynamic value) {
  return _listFromAny(value)
      .whereType<Map>()
      .map((Map item) => _uploadRefFromMap(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

UploadRef _uploadRefFromMap(Map<String, dynamic> map) {
  return UploadRef(
    name: _asString(map['name'] ?? map['file_name'] ?? map['title']),
    id: _asInt(map['id'] ?? map['media_id']),
    remoteUrl: _asString(
      map['full_url'] ??
          map['remoteUrl'] ??
          map['url'] ??
          map['path'] ??
          map['file_url'],
    ),
  );
}

List<Map<String, dynamic>> _mapListFromAny(dynamic value) {
  return _listFromAny(value)
      .whereType<Map>()
      .map((Map item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

List<ClosedDateDraft> _closedDatesFromAny(dynamic value) {
  return _listFromAny(value)
      .map((dynamic item) {
        if (item is Map) {
          return ClosedDateDraft.fromJson(<String, dynamic>{
            'date': item['date'] ?? item['closed_date'],
            'isFullDay': _isFullDayFromAny(item),
            'startTime': item['startTime'] ?? item['start_time'],
            'endTime': item['endTime'] ?? item['end_time'],
          });
        }
        return ClosedDateDraft(date: _asString(item));
      })
      .where((ClosedDateDraft item) => item.date.isNotEmpty)
      .toList(growable: false);
}

/// Resolves the full-day flag from either the legacy `is_full_day` boolean or
/// the `closure_type` string (`full_day` / `hourly`) the backend now returns.
bool _isFullDayFromAny(Map item) {
  final Object? closureType = item['closure_type'] ?? item['closer_type'];
  if (closureType != null) {
    return closureType.toString().trim().toLowerCase() != 'hourly';
  }
  return _asBool(item['isFullDay'] ?? item['is_full_day']) ?? true;
}

/// Builds the editable slot list from the backend. Newer responses split slot
/// structure (`slot_schedules`: label, days, times) from pricing
/// (`slot_pricings`), so we combine them by id. Older pricing-only shapes still
/// work via the fallback. Days are normalized to the capitalized UI labels and
/// times to the picker's display format so the schedule UI renders the values.
List<SlotPricingDraft> _slotsFromResponse(dynamic schedules, dynamic pricings) {
  final List<dynamic> scheduleList = _listFromAny(schedules);
  final List<dynamic> pricingList = _listFromAny(pricings);

  final Map<String, Map<String, dynamic>> pricingById =
      <String, Map<String, dynamic>>{};
  for (final dynamic item in pricingList) {
    if (item is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(item);
      final String slotId = _asString(
        map['slot_schedule_id'] ?? map['slot_id'] ?? map['id'],
      );
      if (slotId.isNotEmpty) pricingById[slotId] = map;
    }
  }

  if (scheduleList.isNotEmpty) {
    return scheduleList
        .whereType<Map>()
        .map((Map item) {
          final Map<String, dynamic> schedule = Map<String, dynamic>.from(item);
          final String id = _asString(
            schedule['id'] ??
                schedule['slot_id'] ??
                schedule['slot_schedule_id'],
          );
          return _slotFromMaps(
            schedule,
            pricingById[id] ?? const <String, dynamic>{},
          );
        })
        .where((SlotPricingDraft slot) => slot.id.isNotEmpty)
        .toList(growable: false);
  }

  // Legacy / pricing-only shape: structure and pricing live in the same map.
  return pricingList
      .whereType<Map>()
      .map(
        (Map item) => _slotFromMaps(
          const <String, dynamic>{},
          Map<String, dynamic>.from(item),
        ),
      )
      .toList(growable: false);
}

SlotPricingDraft _slotFromMaps(
  Map<String, dynamic> schedule,
  Map<String, dynamic> pricing,
) {
  // Pricing may be nested under the slot (`slot_pricing`) or supplied
  // separately (a matched `slot_pricings` row); prefer the nested object.
  final dynamic nested = schedule['slot_pricing'] ?? schedule['slot_pricings'];
  final Map<String, dynamic> price = nested is Map
      ? Map<String, dynamic>.from(nested)
      : pricing;

  return SlotPricingDraft.fromJson(<String, dynamic>{
    'id': _asString(
      schedule['id'] ??
          schedule['slot_id'] ??
          schedule['slot_schedule_id'] ??
          pricing['id'],
    ),
    'label': schedule['label'] ?? schedule['name'] ?? pricing['label'],
    'days': _slotDayLabelsFromAny(
      schedule['days'] ?? schedule['available_days'] ?? pricing['days'],
    ).toList(),
    'startTime': _slotApiTime(
      schedule['start_time'] ??
          schedule['startTime'] ??
          pricing['start_time'] ??
          pricing['startTime'],
    ),
    'endTime': _slotApiTime(
      schedule['end_time'] ??
          schedule['endTime'] ??
          pricing['end_time'] ??
          pricing['endTime'],
    ),
    'price': price['price'] ?? price['base_price'],
    'weekendPrice': price['weekend_price'],
    'holidayPrice': price['holiday_price'],
    'discountPrice': price['discount_price'],
    'discountType': price['discount_type'],
    'paymentPercent': price['payment_percent'],
    'customDatePrices': _customDatePricesFromAny(
      price['custom_date_prices'] ?? price['customDatePrices'],
    ),
  });
}

/// Normalizes custom date prices (`[{date, price}]`) for [SlotPricingDraft].
List<Map<String, dynamic>> _customDatePricesFromAny(dynamic value) {
  return _listFromAny(value)
      .whereType<Map>()
      .map(
        (Map item) => <String, dynamic>{
          'date': _asString(item['date']),
          'price': _asDouble(item['price']),
        },
      )
      .where((Map<String, dynamic> item) => (item['date'] as String).isNotEmpty)
      .toList(growable: false);
}

/// Normalizes backend day codes (lowercase, e.g. `sun`) to the capitalized
/// short labels the slot UI uses (`Sun`).
Set<String> _slotDayLabelsFromAny(dynamic value) {
  return _listFromAny(value)
      .map((dynamic item) => WeekdayOption.fromAny(item)?.label)
      .whereType<String>()
      .toSet();
}

/// Converts a backend time (`HH:mm` or `HH:mm:ss`, 24-hour) into the 12-hour
/// display string the time picker produces (e.g. `23:36:00` -> `11 : 36 PM`).
String _slotApiTime(Object? value) {
  final String raw = _asString(value);
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
