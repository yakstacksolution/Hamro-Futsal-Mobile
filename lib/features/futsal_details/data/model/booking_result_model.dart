/// Result of `POST /bookings`.
class BookingResultModel {
  const BookingResultModel({this.id, this.status, this.message});

  final int? id;
  final String? status;
  final String? message;

  factory BookingResultModel.fromResponse(dynamic payload) {
    final Map<String, dynamic> map = _unwrap(payload);
    return BookingResultModel(
      id: _asInt(map['id'] ?? map['booking_id'] ?? map['bookingId']),
      status: _asString(map['status'] ?? map['booking_status']),
      message: _asString(map['message'] ?? map['msg']),
    );
  }
}

Map<String, dynamic> _unwrap(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 5 && current is Map; depth++) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final dynamic nested = map['data'] ?? map['booking'];
    final bool hasIdentity = map.containsKey('id') ||
        map.containsKey('booking_id') ||
        map.containsKey('bookingId');
    if (hasIdentity || nested is! Map) return map;
    current = nested;
  }
  return current is Map
      ? Map<String, dynamic>.from(current)
      : <String, dynamic>{};
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
