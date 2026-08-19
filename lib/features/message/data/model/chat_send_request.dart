final class ChatSendRequest {
  const ChatSendRequest({
    this.body = '',
    this.filePaths = const <String>[],
    this.type,
    this.replyToMessageId,
    this.metadata = const <String, dynamic>{},
  });

  final String body;
  final List<String> filePaths;
  final String? type;
  final int? replyToMessageId;
  final Object metadata;

  bool get isValid => body.trim().isNotEmpty || filePaths.isNotEmpty;

  static const int maxFiles = 5;
  static const int maxFileBytes = 10 * 1024 * 1024;
  static const Set<String> allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'doc',
    'docx',
  };

  static String extensionOf(String path) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }

  bool get hasAllowedFiles =>
      filePaths.length <= maxFiles &&
      filePaths.every((path) => allowedExtensions.contains(extensionOf(path)));

  String get resolvedType {
    final explicit = type?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (filePaths.isEmpty) return 'text';
    if (body.trim().isNotEmpty) return 'mixed';
    final imageExtensions = <String>{
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'heic',
    };
    final videoExtensions = <String>{'mp4', 'mov', 'avi', 'mkv', 'webm'};
    final audioExtensions = <String>{'mp3', 'm4a', 'aac', 'wav', 'ogg'};
    if (filePaths.every(
      (path) => imageExtensions.contains(extensionOf(path)),
    )) {
      return 'image';
    }
    if (filePaths.every(
      (path) => videoExtensions.contains(extensionOf(path)),
    )) {
      return 'video';
    }
    if (filePaths.every(
      (path) => audioExtensions.contains(extensionOf(path)),
    )) {
      return 'audio';
    }
    return 'file';
  }
}
