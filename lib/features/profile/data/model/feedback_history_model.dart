import 'package:equatable/equatable.dart';

class FeedbackListItem extends Equatable {
  const FeedbackListItem({
    required this.id,
    required this.categoryName,
    required this.typeName,
    required this.rating,
    required this.message,
    this.contactInfo,
    this.createdAt,
    this.typeColorHex = '',
    this.status = '',
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String categoryName;
  final String typeName;
  final int rating;
  final String message;
  final String? contactInfo;
  final DateTime? createdAt;
  final String typeColorHex;
  final String status;
  final Map<String, dynamic> raw;

  factory FeedbackListItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> category = _mapOf(
      json['feedback_category'] ?? json['category'],
    );
    final Map<String, dynamic> type = _mapOf(
      json['feedback_type'] ?? json['type'],
    );

    return FeedbackListItem(
      id: _text(json['id'] ?? json['_id'] ?? json['uuid']),
      categoryName: _text(
        category['name'] ??
            json['feedback_category_name'] ??
            json['category_name'] ??
            json['category'],
      ),
      typeName: _text(
        type['name'] ??
            json['feedback_type_name'] ??
            json['type_name'] ??
            json['type'],
      ),
      rating: _asInt(json['rating']) ?? 0,
      message: _text(json['message'] ?? json['feedback']),
      contactInfo: _nullableText(
        json['contact_info'] ?? json['contact'] ?? json['email'],
      ),
      createdAt: _asDate(json['created_at'] ?? json['date']),
      typeColorHex: _text(type['color'] ?? json['type_color'] ?? json['color']),
      status: _text(json['status']),
      raw: Map<String, dynamic>.from(json),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    categoryName,
    typeName,
    rating,
    message,
    contactInfo,
    createdAt,
    typeColorHex,
    status,
    raw,
  ];
}

class FeedbackListPage extends Equatable {
  const FeedbackListPage({required this.items, this.total = 0});

  final List<FeedbackListItem> items;
  final int total;

  factory FeedbackListPage.fromResponse(dynamic payload) {
    final List<dynamic> rawItems = _extractList(payload);
    final List<FeedbackListItem> items = rawItems
        .whereType<Map>()
        .map(
          (dynamic item) =>
              FeedbackListItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return FeedbackListPage(
      items: items,
      total: _extractTotal(payload) ?? items.length,
    );
  }

  @override
  List<Object?> get props => <Object?>[items, total];
}

class FeedbackDetailsModel extends Equatable {
  const FeedbackDetailsModel({required this.item});

  final FeedbackListItem item;

  factory FeedbackDetailsModel.fromResponse(dynamic payload) {
    final Map<String, dynamic> data = _extractMap(payload);
    return FeedbackDetailsModel(item: FeedbackListItem.fromJson(data));
  }

  @override
  List<Object?> get props => <Object?>[item];
}

List<dynamic> _extractList(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 8; depth++) {
    if (current is List) return current;
    if (current is! Map) return const <dynamic>[];

    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final dynamic next =
        map['feedbacks'] ??
        map['data'] ??
        map['items'] ??
        map['results'] ??
        map['records'];
    if (next == null) return const <dynamic>[];
    current = next;
  }
  return const <dynamic>[];
}

Map<String, dynamic> _extractMap(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 8; depth++) {
    if (current is Map<String, dynamic>) {
      final dynamic nested = current['feedback'] ?? current['data'];
      if (nested is Map<String, dynamic>) {
        current = nested;
        continue;
      }
      return current;
    }
    if (current is Map) {
      current = Map<String, dynamic>.from(current);
      continue;
    }
    break;
  }
  return const <String, dynamic>{};
}

int? _extractTotal(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 8; depth++) {
    if (current is! Map) return null;
    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final int? total = _asInt(map['total'] ?? map['count']);
    if (total != null) return total;
    current = map['data'];
  }
  return null;
}

Map<String, dynamic> _mapOf(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

String _text(Object? value) => value?.toString().trim() ?? '';

String? _nullableText(Object? value) {
  final String text = _text(value);
  return text.isEmpty ? null : text;
}

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

DateTime? _asDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString().trim())?.toLocal();
}
