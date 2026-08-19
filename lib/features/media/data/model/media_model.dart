import 'package:equatable/equatable.dart';

final class MediaModel extends Equatable {
  const MediaModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.filePath,
    required this.url,
    required this.extension,
    required this.size,
    required this.mediaType,
    required this.visibility,
    this.createdAt,
    this.mimeType,
    this.thumbnailUrl,
  });

  final String id;
  final String userId;
  final String name;
  final String filePath;
  final String url;
  final String extension;
  final int size;
  final String mediaType;
  final String visibility;
  final DateTime? createdAt;
  final String? mimeType;
  final String? thumbnailUrl;

  bool get isImage {
    final String source =
        (mediaType.isNotEmpty
                ? mediaType
                : (mimeType?.isNotEmpty ?? false)
                ? mimeType!
                : extension.isNotEmpty
                ? extension
                : url)
            .toLowerCase();
    return source.contains('image/') ||
        source == 'image' ||
        source.endsWith('.png') ||
        source.endsWith('.jpg') ||
        source.endsWith('.jpeg') ||
        source.endsWith('.webp') ||
        source.endsWith('.gif');
  }

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    final String resolvedUrl =
        (json['url'] ??
                json['file_url'] ??
                json['fileUrl'] ??
                json['path'] ??
                json['remote_url'] ??
                '')
            .toString();
    final String resolvedName =
        (json['name'] ?? json['file_name'] ?? json['fileName'] ?? '')
            .toString();
    final String resolvedFilePath =
        (json['file_path'] ?? json['filePath'] ?? json['path'] ?? resolvedUrl)
            .toString();
    final String resolvedExtension =
        (json['extension'] ?? _extensionFromPath(resolvedName, resolvedUrl))
            .toString();

    return MediaModel(
      id: (json['id'] ?? json['_id'] ?? json['uuid'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      name: resolvedName,
      filePath: resolvedFilePath,
      url: resolvedUrl,
      extension: resolvedExtension,
      size: _parseInt(json['size']),
      mediaType: (json['media_type'] ?? json['mediaType'] ?? '').toString(),
      visibility: (json['visibility'] ?? '').toString(),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      mimeType: (json['mime_type'] ?? json['mimeType'])?.toString(),
      thumbnailUrl:
          (json['thumbnail_url'] ?? json['thumbnailUrl'] ?? resolvedUrl)
              .toString(),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    userId,
    name,
    filePath,
    url,
    extension,
    size,
    mediaType,
    visibility,
    createdAt,
    mimeType,
    thumbnailUrl,
  ];
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String _extensionFromPath(String name, String url) {
  final String source = name.isNotEmpty ? name : url;
  final int dotIndex = source.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == source.length - 1) return '';
  return source.substring(dotIndex + 1).toLowerCase();
}
