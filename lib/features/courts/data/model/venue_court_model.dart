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

  return CourtDraft(
    id: remoteId?.toString() ?? _asString(json['slug']),
    remoteId: remoteId,
    name: _asString(json['name'] ?? json['court_name']),
    basePrice: _asDouble(json['base_price'] ?? json['price']),
    description: _asString(json['description'] ?? json['court_description']),
    courtTypeId: _asInt(json['court_type_id'] ?? courtType),
    courtType: _optionName(courtType) ?? _asString(json['court_type_name']),
    matchFormatId: _asInt(json['match_format_id'] ?? matchFormat),
    matchFormat:
        _optionName(matchFormat) ?? _asString(json['match_format_name']),
    maxPlayers:
        _asInt(json['capacity'] ?? json['max_player'] ?? json['max_players']) ??
        10,
    enableOnlineBooking: _asString(json['status']).toLowerCase() != 'inactive',
    advancePaymentRequired: _asBool(json['advance_payment_required']) ?? false,
    paymentQr: _asInt(json['payment_qr_id']) == null
        ? null
        : UploadRef(name: '', id: _asInt(json['payment_qr_id'])),
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
