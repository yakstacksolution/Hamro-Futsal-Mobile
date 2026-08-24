import 'package:equatable/equatable.dart';

final class PublicServiceModel extends Equatable {
  const PublicServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.raw,
  });

  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> raw;

  factory PublicServiceModel.fromJson(Map<String, dynamic> json) {
    return PublicServiceModel(
      id: (json['id'] ?? json['_id'] ?? json['uuid'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? json['service_name'] ?? '')
          .toString(),
      description:
          (json['description'] ?? json['details'] ?? json['subtitle'] ?? '')
              .toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }

  @override
  List<Object?> get props => <Object?>[id, name, description, raw];
}
