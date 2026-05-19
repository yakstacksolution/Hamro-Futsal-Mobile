import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  const BookingModel({
    required this.id,
    required this.bookingRef,
    required this.courtName,
    required this.futsalName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.amount,
    this.playerName,
    this.playerPhone,
    this.futsalAddress,
  });

  final int id;
  final String bookingRef;
  final String courtName;
  final String futsalName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final BookingStatus status;
  final double amount;
  final String? playerName;
  final String? playerPhone;
  final String? futsalAddress;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: _asInt(json['id']) ?? 0,
      bookingRef: json['booking_ref']?.toString() ?? '',
      courtName:
          json['court_name']?.toString() ??
          (json['court'] is Map
              ? (json['court'] as Map)['name']?.toString() ?? ''
              : ''),
      futsalName:
          json['futsal_name']?.toString() ??
          (json['venue'] is Map
              ? (json['venue'] as Map)['name']?.toString() ?? ''
              : ''),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      status: BookingStatus.fromString(json['status']?.toString()),
      amount: _asDouble(json['amount']) ?? 0.0,
      playerName:
          json['player_name']?.toString() ??
          (json['user'] is Map
              ? (json['user'] as Map)['name']?.toString()
              : null),
      playerPhone:
          json['player_phone']?.toString() ??
          (json['user'] is Map
              ? (json['user'] as Map)['phone']?.toString()
              : null),
      futsalAddress:
          json['futsal_address']?.toString() ??
          (json['venue'] is Map
              ? (json['venue'] as Map)['address']?.toString()
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_ref': bookingRef,
    'court_name': courtName,
    'futsal_name': futsalName,
    'date': date.toIso8601String(),
    'start_time': startTime,
    'end_time': endTime,
    'status': status.value,
    'amount': amount,
    'player_name': playerName,
    'player_phone': playerPhone,
    'futsal_address': futsalAddress,
  };

  static List<BookingModel> listFromResponse(dynamic payload) {
    final dynamic data = payload is Map
        ? (payload['data'] ?? payload)
        : payload;
    final List<dynamic> items = data is List ? data : <dynamic>[];
    return items
        .whereType<Map>()
        .map((item) => BookingModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  List<Object?> get props => [
    id,
    bookingRef,
    courtName,
    futsalName,
    date,
    startTime,
    endTime,
    status,
    amount,
    playerName,
    playerPhone,
    futsalAddress,
  ];
}

enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  cancelled('cancelled'),
  completed('completed');

  const BookingStatus(this.value);
  final String value;

  static BookingStatus fromString(String? value) {
    return BookingStatus.values.firstWhere(
      (s) => s.value == value?.toLowerCase(),
      orElse: () => BookingStatus.pending,
    );
  }
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
