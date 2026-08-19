/// View-only profile of the other side of a conversation
/// (`GET /message-profile/{user_id}`).
///
/// The sheet renders name, address, gender and image only — nothing here is
/// editable, so the model stays flat and immutable.
class MessageProfileModel {
  const MessageProfileModel({
    required this.id,
    required this.name,
    this.address = '',
    this.gender = '',
    this.imageUrl = '',
  });

  final int id;
  final String name;
  final String address;
  final String gender;
  final String imageUrl;

  /// `Male` from `male` — the API sends lowercase enum values.
  String get genderLabel => gender.isEmpty
      ? ''
      : gender.substring(0, 1).toUpperCase() + gender.substring(1);

  factory MessageProfileModel.fromJson(Map<String, dynamic> json) {
    return MessageProfileModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: (json['name'] ?? json['full_name'] ?? '').toString().trim(),
      address: (json['address'] ?? json['location'] ?? '').toString().trim(),
      gender: (json['gender'] ?? '').toString().trim(),
      imageUrl: _imageUrl(json),
    );
  }

  /// The image arrives as a media object (`{id, name, url}`) — the shape this
  /// endpoint returns — or as a plain url string, under one of several keys
  /// depending on the resource.
  static String _imageUrl(Map<String, dynamic> json) {
    for (final key in const ['image', 'avatar', 'profile_image', 'photo']) {
      final dynamic value = json[key];
      if (value == null) continue;
      if (value is Map) {
        final url = (value['url'] ?? value['path'] ?? '').toString().trim();
        if (url.isNotEmpty) return _normalizeUrl(url);
        continue;
      }
      final url = value.toString().trim();
      if (url.isNotEmpty) return _normalizeUrl(url);
    }
    return '';
  }

  /// The API concatenates its app url with a leading-slash path, so urls come
  /// back as `https://host//storage/...`. Collapse the duplicate slashes in the
  /// path — some hosts 404 on them — while leaving the `https://` scheme alone.
  static String _normalizeUrl(String url) {
    final schemeEnd = url.indexOf('://');
    if (schemeEnd < 0) return url.replaceAll(RegExp(r'/{2,}'), '/');
    final scheme = url.substring(0, schemeEnd + 3);
    final rest = url.substring(schemeEnd + 3).replaceAll(RegExp(r'/{2,}'), '/');
    return '$scheme$rest';
  }
}
