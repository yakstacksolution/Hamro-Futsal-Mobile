import 'package:equatable/equatable.dart';

final class PublicOptionModel extends Equatable {
  const PublicOptionModel({
    required this.id,
    required this.name,
    required this.raw,
    this.image = '',
    this.slug = '',
    this.description = '',
    this.isActive = true,
    this.sortOrder,
  });

  final String id;
  final String name;

  final String image;

  final String slug;

  final String description;

  final bool isActive;

  final int? sortOrder;

  final Map<String, dynamic> raw;

  int? get idAsInt => int.tryParse(id);

  bool get hasImage => image.isNotEmpty;

  bool get hasDescription => description.isNotEmpty;

  factory PublicOptionModel.fromJson(Map<String, dynamic> json) {
    final String id = (json['id'] ?? json['_id'] ?? json['uuid'] ?? '')
        .toString();
    final String name = _string(
      json['name'] ??
          json['title'] ??
          json['label'] ??
          json['type'] ??
          json['format'] ??
          json['value'],
    );

    return PublicOptionModel(
      id: id,
      name: name,
      image: _imageFrom(json),
      slug: _string(json['slug']),
      description: _string(json['description'] ?? json['detail']),
      isActive:
          _bool(json['is_active']) ??
          _bool(json['status']) ??
          _bool(json['active']) ??
          true,
      sortOrder: _int(json['sort_order'] ?? json['sortOrder'] ?? json['order']),
      raw: json,
    );
  }

  static String _imageFrom(Map<String, dynamic> json) {
    for (final String key in const <String>[
      'image',
      'icon',
      'logo',
      'image_url',
      'icon_url',
      'thumbnail',
    ]) {
      final String url = _urlFrom(json[key]);
      if (url.isNotEmpty) return url;
    }
    return '';
  }

  static String _urlFrom(dynamic value, {int depth = 0}) {
    if (value == null || depth > 3) return '';

    if (value is String) return _normalizeUrl(value.trim());

    if (value is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(value);
      for (final String key in const <String>[
        'full_url',
        'fullUrl',
        'url',
        'path',
        'original_url',
      ]) {
        final dynamic candidate = map[key];
        if (candidate is String && candidate.trim().isNotEmpty) {
          return _normalizeUrl(candidate.trim());
        }
      }
      return _urlFrom(map['media'], depth: depth + 1);
    }

    return '';
  }

  static String _normalizeUrl(String url) {
    if (url.isEmpty) return url;
    final int schemeEnd = url.indexOf('://');
    if (schemeEnd < 0) return url.replaceAll(RegExp(r'(?<!:)//+'), '/');
    final String scheme = url.substring(0, schemeEnd + 3);
    final String rest = url
        .substring(schemeEnd + 3)
        .replaceAll(RegExp(r'//+'), '/');
    return '$scheme$rest';
  }

  static String _string(dynamic value) => value?.toString().trim() ?? '';

  static bool? _bool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String v = value.trim().toLowerCase();
      if (v == 'true' || v == '1' || v == 'active') return true;
      if (v == 'false' || v == '0' || v == 'inactive') return false;
    }
    return null;
  }

  static int? _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    image,
    slug,
    description,
    isActive,
    sortOrder,
    raw,
  ];
}
