import 'package:equatable/equatable.dart';

/// A promotional banner shown in a full-screen dialog when the app opens.
class MobileBannerModel extends Equatable {
  const MobileBannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.link,
  });

  final String id;
  final String imageUrl;
  final String? title;

  /// Where tapping the image leads, if anywhere.
  final String? link;

  factory MobileBannerModel.fromJson(Map<String, dynamic> json) {
    return MobileBannerModel(
      id: _asString(json['id']) ?? '',
      imageUrl:
          _asString(
            json['image_url'] ??
                json['image'] ??
                json['mobile_image_url'] ??
                json['image_path'] ??
                json['url'],
          ) ??
          '',
      title: _asString(json['title'] ?? json['name']),
      link: _asString(
        json['link'] ??
            json['link_url'] ??
            json['action_url'] ??
            json['redirect_url'] ??
            json['target_url'],
      ),
    );
  }

  /// Parses the list out of the response envelope (`{data: [...]}` or a bare
  /// list), dropping entries that have nothing to show or dismiss.
  static List<MobileBannerModel> listFromResponse(dynamic payload) {
    dynamic current = payload;
    for (int depth = 0; depth < 4 && current is Map; depth++) {
      current = current['data'] ?? current['banners'] ?? current['items'];
    }
    if (current is! List) return const <MobileBannerModel>[];

    return current
        .whereType<Map>()
        .map(
          (dynamic item) =>
              MobileBannerModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where(
          (MobileBannerModel b) => b.id.isNotEmpty && b.imageUrl.isNotEmpty,
        )
        .toList(growable: false);
  }

  @override
  List<Object?> get props => <Object?>[id, imageUrl, title, link];
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final String text = value.toString().trim();
  return text.isEmpty ? null : text;
}
