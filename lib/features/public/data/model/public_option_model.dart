import 'package:equatable/equatable.dart';

final class PublicOptionModel extends Equatable {
  const PublicOptionModel({
    required this.id,
    required this.name,
    required this.raw,
    this.image = '',
  });

  final String id;
  final String name;

  /// Absolute URL of the option icon/image (e.g. facility icon), or empty
  /// when the server did not provide one.
  final String image;
  final Map<String, dynamic> raw;

  int? get idAsInt => int.tryParse(id);

  bool get hasImage => image.isNotEmpty;

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
    final String image = (json['image'] ?? json['icon'] ?? json['logo'] ?? '')
        .toString()
        .trim();

    return PublicOptionModel(id: id, name: name, image: image, raw: json);
  }

  @override
  List<Object?> get props => <Object?>[id, name, image, raw];
}
