import 'package:equatable/equatable.dart';

/// A help topic from `GET /helps`.
final class PublicHelpModel extends Equatable {
  const PublicHelpModel({
    required this.id,
    required this.title,
    required this.description,
    required this.raw,
  });

  final String id;
  final String title;
  final String description;
  final Map<String, dynamic> raw;

  factory PublicHelpModel.fromJson(Map<String, dynamic> json) {
    return PublicHelpModel(
      id: (json['id'] ?? json['_id'] ?? json['uuid'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? json['question'] ?? '')
          .toString()
          .trim(),
      description:
          (json['description'] ??
                  json['content'] ??
                  json['body'] ??
                  json['answer'] ??
                  json['details'] ??
                  '')
              .toString()
              .trim(),
      raw: Map<String, dynamic>.from(json),
    );
  }

  @override
  List<Object?> get props => <Object?>[id, title, description, raw];
}
