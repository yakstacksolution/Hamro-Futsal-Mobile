import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/time_slot_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_court_item_model.dart';

final class AvailableCourtsModel {
  const AvailableCourtsModel({
    this.timeSlots = const <TimeSlotModel>[],
    this.courts = const <VenueCourtItemModel>[],
  });

  final List<TimeSlotModel> timeSlots;
  final List<VenueCourtItemModel> courts;

  factory AvailableCourtsModel.fromResponse(dynamic payload) {
    final dynamic data = _unwrapPayload(payload);

    if (data is List) {
      if (data.isEmpty) return const AvailableCourtsModel();
      if (_looksLikeCourt(data.first)) {
        return AvailableCourtsModel(courts: _parseCourts(data));
      }
      if (_looksLikeSlot(data.first)) {
        return AvailableCourtsModel(timeSlots: _parseTimeSlots(data));
      }
      return AvailableCourtsModel(courts: _parseCourts(data));
    }

    if (data is! Map) return const AvailableCourtsModel();

    final Map<String, dynamic> map = Map<String, dynamic>.from(data);
    final dynamic slots = _firstValue(map, const <String>[
      'slots',
      'slot_times',
      'slotTimes',
      'time_slots',
      'timeSlots',
      'available_slots',
      'availableSlots',
      'available_slot_times',
      'availableSlotTimes',
      'venue_slots',
      'venueSlots',
      'slot_schedules',
      'slotSchedules',
      'times',
    ]);
    final dynamic courts = _firstValue(map, const <String>[
      'courts',
      'available_courts',
      'availableCourts',
      'venue_courts',
      'venueCourts',
      'court_list',
      'courtList',
      'available_venue_courts',
      'availableVenueCourts',
    ]);

    return AvailableCourtsModel(
      timeSlots: _parseTimeSlots(slots),
      courts: _parseCourts(courts),
    );
  }
}

dynamic _unwrapPayload(dynamic payload) {
  dynamic current = payload;
  while (current is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    if (_hasAvailabilityKeys(map)) return map;
    final dynamic nested = map['data'];
    if (nested == null || identical(nested, current)) return map;
    current = nested;
  }
  return current;
}

bool _hasAvailabilityKeys(Map<String, dynamic> map) {
  const Set<String> keys = <String>{
    'slots',
    'slot_times',
    'slotTimes',
    'time_slots',
    'timeSlots',
    'available_slots',
    'availableSlots',
    'available_slot_times',
    'availableSlotTimes',
    'venue_slots',
    'venueSlots',
    'slot_schedules',
    'slotSchedules',
    'times',
    'courts',
    'available_courts',
    'availableCourts',
    'venue_courts',
    'venueCourts',
    'court_list',
    'courtList',
    'available_venue_courts',
    'availableVenueCourts',
  };
  return map.keys.any(keys.contains);
}

dynamic _firstValue(Map<String, dynamic> map, List<String> keys) {
  for (final String key in keys) {
    if (map.containsKey(key)) return map[key];
  }
  return null;
}

List<TimeSlotModel> _parseTimeSlots(dynamic value) {
  final List<dynamic> items = _listFromAny(value);
  return items
      .map(_timeSlotFromAny)
      .whereType<TimeSlotModel>()
      .toList(growable: false);
}

TimeSlotModel? _timeSlotFromAny(dynamic value) {
  if (value == null) return null;

  if (value is String || value is num) {
    final String raw = value.toString();
    final String apiTime = _normaliseApiTime(raw);
    return TimeSlotModel(
      time: _displayTime(apiTime, fallback: raw),
      apiTime: apiTime,
    );
  }

  if (value is! Map) return null;

  final Map<String, dynamic> map = Map<String, dynamic>.from(value);
  final dynamic rawStartTime =
      map['slot_time'] ??
      map['slotTime'] ??
      map['time'] ??
      map['start_time'] ??
      map['startTime'] ??
      map['from'] ??
      map['label'];
  if (rawStartTime == null) return null;

  final dynamic rawEndTime =
      map['end_time'] ?? map['endTime'] ?? map['to'] ?? map['until'];
  final String apiTime = _normaliseApiTime(rawStartTime.toString());
  final String? apiEndTime = rawEndTime == null
      ? null
      : _normaliseApiTime(rawEndTime.toString());
  final String startDisplay = _displayTime(
    apiTime,
    fallback: rawStartTime.toString(),
  );
  final String? endDisplay = apiEndTime == null
      ? null
      : _displayTime(apiEndTime, fallback: rawEndTime.toString());
  final int? availableCourts = _asInt(
    map['available_courts'] ?? map['availableCourts'],
  );
  final SlotStatus status = _slotStatusFromMap(map, availableCourts);
  final String displayTime = endDisplay == null || endDisplay == startDisplay
      ? startDisplay
      : '$startDisplay - $endDisplay';

  return TimeSlotModel(
    id: _asInt(map['id'] ?? map['slot_id'] ?? map['slotId']),
    time: displayTime,
    apiTime: apiTime,
    endTime: endDisplay,
    apiEndTime: apiEndTime,
    price: _asString(map['price'] ?? map['amount'] ?? map['rate']),
    totalCourts: _asInt(map['total_courts'] ?? map['totalCourts']),
    availableCourts: availableCourts,
    bookedCourts: _asInt(map['booked_courts'] ?? map['bookedCourts']),
    status: status,
  );
}

/// Resolves a slot's [SlotStatus]. The server's `status` string is
/// authoritative (e.g. a slot can be `available` even with zero available
/// courts); only when it is missing do we fall back to boolean flags and counts.
SlotStatus _slotStatusFromMap(Map<String, dynamic> map, int? availableCourts) {
  final dynamic rawStatus =
      map['status'] ?? map['slot_status'] ?? map['slotStatus'];
  if (rawStatus != null) return SlotStatus.fromApi(rawStatus);

  if (_asBool(map['is_booked'] ?? map['booked']) == true) {
    return SlotStatus.booked;
  }
  if (_asBool(map['is_fully_booked'] ?? map['isFullyBooked']) == true) {
    return SlotStatus.booked;
  }
  if (_asBool(map['is_unavailable'] ?? map['isUnavailable']) == true) {
    return SlotStatus.unavailable;
  }
  final bool? explicit = _asBool(
    map['is_available'] ?? map['isAvailable'] ?? map['available'],
  );
  if (explicit != null) {
    return explicit ? SlotStatus.available : SlotStatus.unavailable;
  }
  if (availableCourts != null) {
    return availableCourts > 0 ? SlotStatus.available : SlotStatus.unavailable;
  }
  return SlotStatus.available;
}

List<VenueCourtItemModel> _parseCourts(dynamic value) {
  final List<dynamic> items = _listFromAny(value);
  return items
      .whereType<Map>()
      .map((Map item) => _courtFromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

VenueCourtItemModel _courtFromJson(Map<String, dynamic> json) {
  final dynamic courtType = json['court_type'] ?? json['courtType'];
  final dynamic matchFormat =
      json['match_format'] ?? json['matchFormat'] ?? json['match_type'];
  final List<CourtPriceRule> priceList = _priceRulesFromJson(json);
  final dynamic matchingSlot = json['matching_slot'] ?? json['matchingSlot'];
  final Map<String, dynamic> matchingSlotMap = matchingSlot is Map
      ? Map<String, dynamic>.from(matchingSlot)
      : const <String, dynamic>{};
  final String? startTime = _displayTimeFromAny(
    json['start_time'] ?? json['startTime'] ?? matchingSlotMap['start_time'],
  );
  final String? endTime = _displayTimeFromAny(
    json['end_time'] ?? json['endTime'] ?? matchingSlotMap['end_time'],
  );
  final SlotStatus status = SlotStatus.fromApi(
    json['availability_status'] ?? json['availabilityStatus'] ?? json['status'],
  );

  return VenueCourtItemModel(
    id: _asInt(json['id'] ?? json['court_id'] ?? json['courtId']),
    venueId: _asInt(json['venue_id'] ?? json['venueId']),
    name:
        _asString(json['name'] ?? json['court_name'] ?? json['title']) ??
        StringConstants.court,
    image: _imageFromJson(json),
    maxPlayers:
        _asInt(json['max_players'] ?? json['max_player'] ?? json['capacity']) ??
        0,
    matchType:
        _optionName(matchFormat, json['match_format_name']) ??
        StringConstants.standard,
    courtType:
        _optionName(courtType, json['court_type_name']) ??
        StringConstants.court,
    weekendSurcharge:
        _asDouble(
          json['weekend_surcharge'] ??
              json['weekendSurcharge'] ??
              json['weekend_extra'],
        ) ??
        0,
    status: status,
    startTime: startTime,
    endTime: endTime,
    priceList: priceList,
  );
}

List<CourtPriceRule> _priceRulesFromJson(Map<String, dynamic> json) {
  final dynamic rawRules =
      json['price_list'] ??
      json['priceList'] ??
      json['prices'] ??
      json['pricing'] ??
      json['price_rules'] ??
      json['priceRules'] ??
      json['slot_pricings'] ??
      json['slotPricing'] ??
      json['slot_prices'] ??
      json['slotPrices'];

  final List<CourtPriceRule> rules = _listFromAny(rawRules)
      .whereType<Map>()
      .map((Map item) => _priceRuleFromJson(Map<String, dynamic>.from(item)))
      .whereType<CourtPriceRule>()
      .toList(growable: false);
  if (rules.isNotEmpty) return rules;

  final double basePrice =
      _asDouble(
        json['slot_price'] ??
            json['slotPrice'] ??
            json['base_price'] ??
            json['basePrice'] ??
            json['hourly_rate'] ??
            json['hourlyRate'] ??
            json['rate'] ??
            json['price'],
      ) ??
      0;
  return <CourtPriceRule>[
    CourtPriceRule(
      label: StringConstants.standard,
      timeRange: StringConstants.allDay,
      startHour: 0,
      endHour: 24,
      price: basePrice,
    ),
  ];
}

CourtPriceRule? _priceRuleFromJson(Map<String, dynamic> json) {
  final double? price = _asDouble(
    json['price'] ??
        json['amount'] ??
        json['rate'] ??
        json['base_price'] ??
        json['slot_price'],
  );
  if (price == null) return null;

  final int startHour =
      _hourFromAny(
        json['start_hour'] ??
            json['startHour'] ??
            json['from_hour'] ??
            json['start_time'] ??
            json['startTime'] ??
            json['from'],
      ) ??
      0;
  int endHour =
      _hourFromAny(
        json['end_hour'] ??
            json['endHour'] ??
            json['to_hour'] ??
            json['end_time'] ??
            json['endTime'] ??
            json['to'],
      ) ??
      24;
  if (endHour <= startHour) {
    endHour = startHour >= 23 ? 24 : startHour + 1;
  }

  final String timeRange =
      _asString(json['time_range'] ?? json['timeRange'] ?? json['range']) ??
      '${_hourLabel(startHour)} - ${_hourLabel(endHour)}';

  return CourtPriceRule(
    label: _asString(json['label'] ?? json['name'] ?? json['title']) ?? 'Slot',
    timeRange: timeRange,
    startHour: startHour,
    endHour: endHour,
    price: price,
  );
}

bool _looksLikeSlot(dynamic value) {
  if (value is String || value is num) return true;
  if (value is! Map) return false;
  final Map<String, dynamic> map = Map<String, dynamic>.from(value);
  return map.containsKey('slot_time') ||
      map.containsKey('slotTime') ||
      map.containsKey('time') ||
      map.containsKey('start_time') ||
      map.containsKey('startTime');
}

bool _looksLikeCourt(dynamic value) {
  if (value is! Map) return false;
  final Map<String, dynamic> map = Map<String, dynamic>.from(value);
  return map.containsKey('court_id') ||
      map.containsKey('courtId') ||
      map.containsKey('court_name') ||
      map.containsKey('courtName') ||
      map.containsKey('venue_court_id') ||
      map.containsKey('venueCourtId') ||
      map.containsKey('match_type') ||
      map.containsKey('match_format') ||
      map.containsKey('max_players') ||
      map.containsKey('max_player') ||
      map.containsKey('court_type');
}

List<dynamic> _listFromAny(dynamic value) {
  if (value == null) return const <dynamic>[];
  if (value is List) return value;
  if (value is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(value);
    for (final String key in const <String>[
      'data',
      'items',
      'list',
      'records',
      'results',
    ]) {
      final dynamic nested = map[key];
      if (nested is List) return nested;
    }
    if (map.values.every((dynamic item) => item is Map)) {
      return map.values.toList(growable: false);
    }
  }
  return const <dynamic>[];
}

String _imageFromJson(Map<String, dynamic> json) {
  final dynamic direct =
      json['image'] ??
      json['image_url'] ??
      json['imageUrl'] ??
      json['feature_image'] ??
      json['featureImage'] ??
      json['thumbnail'] ??
      json['thumbnail_url'] ??
      json['photo'];
  final String? directImage = _imageValue(direct);
  if (directImage != null) return directImage;

  for (final String key in const <String>[
    'court_photos',
    'courtPhotos',
    'photos',
    'images',
    'media',
    'gallery',
  ]) {
    final List<dynamic> items = _listFromAny(json[key]);
    for (final dynamic item in items) {
      final String? image = _imageValue(item);
      if (image != null) return image;
    }
  }
  return '';
}

String? _imageValue(dynamic value) {
  if (value == null) return null;
  if (value is String && value.trim().isNotEmpty) return value.trim();
  if (value is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(value);
    return _asString(
      map['image_url'] ??
          map['imageUrl'] ??
          map['url'] ??
          map['path'] ??
          map['file_url'] ??
          map['fileUrl'],
    );
  }
  return null;
}

String? _optionName(dynamic value, dynamic fallback) {
  if (value is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(value);
    return _asString(map['name'] ?? map['title'] ?? map['label'] ?? fallback);
  }
  return _asString(value ?? fallback);
}

String? _displayTimeFromAny(dynamic value) {
  final String? raw = _asString(value);
  if (raw == null) return null;
  final String apiTime = _normaliseApiTime(raw);
  return _displayTime(apiTime, fallback: raw);
}

String _normaliseApiTime(String value) {
  String text = value.trim();
  if (text.isEmpty) return text;
  text = text.split(RegExp(r'\s*[-–]\s*')).first.trim();
  text = text.split('.').first.trim();

  final RegExp meridiem = RegExp(
    r'^(\d{1,2})(?::(\d{1,2}))?\s*([AP]M)$',
    caseSensitive: false,
  );
  final RegExpMatch? meridiemMatch = meridiem.firstMatch(text);
  if (meridiemMatch != null) {
    int hour = int.tryParse(meridiemMatch.group(1) ?? '') ?? 0;
    final int minute = int.tryParse(meridiemMatch.group(2) ?? '0') ?? 0;
    final String suffix = meridiemMatch.group(3)!.toUpperCase();
    if (suffix == 'PM' && hour != 12) hour += 12;
    if (suffix == 'AM' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  final RegExpMatch? match = RegExp(
    r'(?:^|[T\s])(\d{1,2}):(\d{1,2})',
  ).firstMatch(text);
  if (match == null) {
    final RegExpMatch? hourOnly = RegExp(r'^(\d{1,2})$').firstMatch(text);
    if (hourOnly == null) return text;
    final int hour = int.tryParse(hourOnly.group(1) ?? '') ?? 0;
    return '${hour.clamp(0, 23).toString().padLeft(2, '0')}:00';
  }

  final int hour = int.tryParse(match.group(1) ?? '') ?? 0;
  final int minute = int.tryParse(match.group(2) ?? '0') ?? 0;
  return '${hour.clamp(0, 23).toString().padLeft(2, '0')}:${minute.clamp(0, 59).toString().padLeft(2, '0')}';
}

String _displayTime(String apiTime, {required String fallback}) {
  final RegExpMatch? match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(apiTime);
  if (match == null) return fallback.trim();
  final int hour = int.tryParse(match.group(1) ?? '') ?? 0;
  final int minute = int.tryParse(match.group(2) ?? '') ?? 0;
  final String suffix = hour >= 12 ? 'PM' : 'AM';
  final int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
}

int? _hourFromAny(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt().clamp(0, 24).toInt();
  final String time = _normaliseApiTime(value.toString());
  final int? hour = int.tryParse(time.split(':').first);
  return hour?.clamp(0, 24).toInt();
}

String _hourLabel(int hour) {
  if (hour <= 0) return '12 AM';
  if (hour == 12) return '12 PM';
  if (hour >= 24) return '12 AM';
  if (hour > 12) return '${hour - 12} PM';
  return '$hour AM';
}

String? _asString(dynamic value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble().isFinite ? value.toDouble() : null;

  final String text = value.toString().replaceAll(',', '');
  final double? direct = double.tryParse(text);
  if (direct != null && direct.isFinite) return direct;

  final RegExpMatch? match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
  final double? parsed = match == null
      ? null
      : double.tryParse(match.group(1) ?? '');
  if (parsed == null || !parsed.isFinite) return null;
  return parsed;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;

  final String text = value.toString().trim().toLowerCase();
  if (text.isEmpty) return null;
  if (const <String>{
    'true',
    '1',
    'yes',
    'available',
    'open',
    'active',
  }.contains(text)) {
    return true;
  }
  if (const <String>{
    'false',
    '0',
    'no',
    'unavailable',
    'booked',
    'reserved',
    'blocked',
    'closed',
    'inactive',
  }.contains(text)) {
    return false;
  }
  return null;
}
