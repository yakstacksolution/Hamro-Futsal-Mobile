import 'package:equatable/equatable.dart';

final class CategoryFilterModel extends Equatable {
  const CategoryFilterModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.status,
    required this.raw,
    this.image,
  });

  final String id;
  final String title;
  final String slug;
  final int status;
  final String? image;
  final Map<String, dynamic> raw;

  bool get isActive => status == 1;

  factory CategoryFilterModel.fromJson(Map<String, dynamic> json) {
    final String id = (json['id'] ?? json['_id'] ?? json['uuid'] ?? '')
        .toString();
    final String title = (json['title'] ?? json['name'] ?? json['label'] ?? '')
        .toString()
        .trim();
    final String slug = (json['slug'] ?? title.toLowerCase()).toString();
    final int status = int.tryParse((json['status'] ?? 0).toString()) ?? 0;
    final String? image = json['image']?.toString();

    return CategoryFilterModel(
      id: id,
      title: title,
      slug: slug,
      status: status,
      image: image,
      raw: json,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, title, slug, status, image, raw];
}
