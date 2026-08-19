import 'package:equatable/equatable.dart';

class FeedbackOptionModel extends Equatable {
  const FeedbackOptionModel({
    required this.id,
    required this.name,
    this.slug = '',
    String? colorHex,
    this.typeId = '',
    this.raw = const <String, dynamic>{},
  }) : _colorHex = colorHex;

  final String id;
  final String name;
  final String slug;
  final String? _colorHex;
  String get colorHex => _colorHex ?? '';

  /// Optional relation back to a feedback type for category filtering.
  final String typeId;
  final Map<String, dynamic> raw;

  bool get hasTypeBinding => typeId.isNotEmpty;

  factory FeedbackOptionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> nestedType = _mapOf(
      json['feedback_type'] ?? json['type'],
    );

    return FeedbackOptionModel(
      id: _text(json['id'] ?? json['_id'] ?? json['uuid']),
      name: _text(
        json['title'] ??
            json['name'] ??
            json['label'] ??
            json['category'] ??
            json['feedback_category'],
      ),
      slug: _text(json['slug']),
      colorHex: _text(json['color']),
      typeId: _text(
        json['feedback_type_id'] ??
            json['type_id'] ??
            nestedType['id'] ??
            nestedType['_id'] ??
            nestedType['uuid'],
      ),
      raw: Map<String, dynamic>.from(json),
    );
  }

  @override
  List<Object?> get props => <Object?>[id, name, slug, colorHex, typeId, raw];
}

class FeedbackCatalog extends Equatable {
  const FeedbackCatalog({required this.types, required this.categories});

  final List<FeedbackOptionModel> types;
  final List<FeedbackOptionModel> categories;

  List<FeedbackOptionModel> categoriesForType(String? typeId) {
    if (typeId == null || typeId.isEmpty) return categories;
    final List<FeedbackOptionModel> scoped = categories
        .where(
          (FeedbackOptionModel category) =>
              !category.hasTypeBinding || category.typeId == typeId,
        )
        .toList(growable: false);
    return scoped.isEmpty ? categories : scoped;
  }

  @override
  List<Object?> get props => <Object?>[types, categories];
}

String _text(Object? value) => value?.toString().trim() ?? '';

Map<String, dynamic> _mapOf(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
