import 'package:equatable/equatable.dart';

final class PublicOptionModel extends Equatable {
  const PublicOptionModel({
    required this.id,
    required this.name,
    required this.raw,
  });

  final String id;
  final String name;
  final Map<String, dynamic> raw;

  int? get idAsInt => int.tryParse(id);

  factory PublicOptionModel.fromJson(Map<String, dynamic> json) {
    final String id = (json['id'] ?? json['_id'] ?? json['uuid'] ?? '')
        .toString();
    final String name =
        (json['name'] ??
                json['title'] ??
                json['label'] ??
                json['type'] ??
                json['format'] ??
                json['value'] ??
                '')
            .toString()
            .trim();

    return PublicOptionModel(id: id, name: name, raw: json);
  }

  @override
  List<Object?> get props => <Object?>[id, name, raw];
}
