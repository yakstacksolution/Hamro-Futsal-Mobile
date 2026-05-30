import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

final class VenueCourtModel {
  const VenueCourtModel({
    required this.id,
    required this.title,
    required this.address,
    required this.phone,
    required this.status,
    required this.courts,
  });

  final int? id;
  final String title;
  final String address;
  final String phone;
  final String status;
  final List<CourtDraft> courts;

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
  final int? remoteId = _asInt(json['id'] ?? json['court_id']);
  final Object? courtType = json['court_type'];
  final Object? matchFormat = json['match_format'];
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
  final List<CourtTagDetail> facilityDetails = _tagDetailsFromAny(facilitiesRaw);

  final dynamic paymentQrMedia = json['payment_qr_media'] ?? json['payment_qr'];
  final UploadRef? paymentQr = paymentQrMedia is Map
      ? _uploadRefFromMap(Map<String, dynamic>.from(paymentQrMedia))
      : (_asInt(json['payment_qr_id']) == null
            ? null
            : UploadRef(name: '', id: _asInt(json['payment_qr_id'])));

  return CourtDraft(
    id: remoteId?.toString() ?? slug,
    remoteId: remoteId,
    venueId: _asInt(json['venue_id']),
    mainStep: _asInt(json['main_step']),
    subStep: _asInt(json['sub_step']),
    category: _asInt(json['category']),
    slug: slug.isEmpty ? null : slug,
    code: code.isEmpty ? null : code,
    name: _asString(json['name'] ?? json['court_name']),
    basePrice: _asDouble(json['base_price'] ?? json['price']),
    description: _asString(json['description']),
    courtTypeId: _asInt(json['court_type_id'] ?? courtType),
    courtType: _optionName(courtType) ?? _asString(json['court_type_name']),
    matchFormatId: _asInt(json['match_format_id'] ?? matchFormat),
    matchFormat:
        _optionName(matchFormat) ?? _asString(json['match_format_name']),
    maxPlayers:
        _asInt(json['capacity'] ?? json['max_player'] ?? json['max_players']) ??
        10,
    surfaceType: surfaceType.isEmpty ? null : surfaceType,
    slotDuration: _asInt(json['slot_duration']),
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
    weekendDays: _nameSetFromAny(json['weekend_days']).isEmpty
        ? const <String>{'Saturday'}
        : _nameSetFromAny(json['weekend_days']),
    holidayDates: _nameSetFromAny(json['holiday_dates']),
    closedDates: _closedDatesFromAny(json['closed_dates']),
    slotConfigs: _slotConfigsFromAny(
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
          return _asInt(item['id'] ?? item['amenity_id'] ?? item['facility_id']);
        }
        return _asInt(item);
      })
      .whereType<int>()
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
            'isFullDay': item['isFullDay'] ?? item['is_full_day'] ?? true,
            'startTime': item['startTime'] ?? item['start_time'],
            'endTime': item['endTime'] ?? item['end_time'],
          });
        }
        return ClosedDateDraft(date: _asString(item));
      })
      .where((ClosedDateDraft item) => item.date.isNotEmpty)
      .toList(growable: false);
}

List<SlotPricingDraft> _slotConfigsFromAny(dynamic value) {
  return _listFromAny(value)
      .whereType<Map>()
      .map((Map item) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        return SlotPricingDraft.fromJson(<String, dynamic>{
          'id': _asString(map['id'] ?? map['slot_id']),
          'label': map['label'] ?? map['name'] ?? map['title'],
          'days': map['days'] ?? map['available_days'],
          'startTime': map['startTime'] ?? map['start_time'],
          'endTime': map['endTime'] ?? map['end_time'],
          'price': map['price'] ?? map['base_price'],
          'weekendPrice': map['weekendPrice'] ?? map['weekend_price'],
          'holidayPrice': map['holidayPrice'] ?? map['holiday_price'],
          'discountPrice': map['discountPrice'] ?? map['discount_price'],
          'discountType': map['discountType'] ?? map['discount_type'],
          'paymentPercent': map['paymentPercent'] ?? map['payment_percent'],
        });
      })
      .toList(growable: false);
}
