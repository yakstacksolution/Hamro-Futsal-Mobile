import 'package:equatable/equatable.dart';

final class PublicTemplateModel extends Equatable {
  const PublicTemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.raw,
  });

  final String id;
  final String title;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  String get name => title;

  factory PublicTemplateModel.fromJson(Map<String, dynamic> json) {
    return PublicTemplateModel(
      id: (json['id'] ?? json['_id'] ?? json['uuid'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? json['template_name'] ?? '')
          .toString(),
      description:
          (json['description'] ?? json['details'] ?? json['subtitle'] ?? '')
              .toString(),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
      raw: Map<String, dynamic>.from(json),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    description,
    createdAt,
    updatedAt,
    raw,
  ];
}
