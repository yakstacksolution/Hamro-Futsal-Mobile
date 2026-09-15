class MessageProfileModel {
  const MessageProfileModel({
    this.id,
    this.name,
    this.address,
    this.email,
    this.gender,
    this.imageUrl,
  });

  final int? id;
  final String? name;
  final String? address;
  final String? email;
  final String? gender;
  final String? imageUrl;

  String? get genderLabel {
    final String raw = gender ?? '';
    if (raw.isEmpty) return null;
    final String label = raw
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .split(' ')
        .where((String word) => word.isNotEmpty)
        .map(
          (String word) =>
              word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
    return label.isEmpty ? null : label;
  }

  factory MessageProfileModel.fromJson(Map<String, dynamic> json) {
    return MessageProfileModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      name: _string(json['name'] ?? json['full_name']),
      address: _string(json['address'] ?? json['location']),
      email: _string(json['email'] ?? json['email_address']),
      gender: _string(json['gender']),
      imageUrl: _imageUrl(json),
    );
  }

  static String? _string(dynamic value) {
    if (value == null) return null;
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String? _imageUrl(Map<String, dynamic> json) {
    for (final key in const ['image', 'avatar', 'profile_image', 'photo']) {
      final dynamic value = json[key];
      if (value == null) continue;
      if (value is Map) {
        final String? url = _string(value['url'] ?? value['path']);
        if (url != null) return _normalizeUrl(url);
        continue;
      }
      final String? url = _string(value);
      if (url != null) return _normalizeUrl(url);
    }
    return null;
  }

  static String _normalizeUrl(String url) {
    final schemeEnd = url.indexOf('://');
    if (schemeEnd < 0) return url.replaceAll(RegExp(r'/{2,}'), '/');
    final scheme = url.substring(0, schemeEnd + 3);
    final rest = url.substring(schemeEnd + 3).replaceAll(RegExp(r'/{2,}'), '/');
    return '$scheme$rest';
  }
}
