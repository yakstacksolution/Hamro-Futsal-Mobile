import 'package:hamro_futsal/core/utils/upload_attachment.dart';

final class ChatSendRequest {
  const ChatSendRequest({
    this.body = '',
    this.attachments = const <UploadAttachment>[],
    this.type,
    this.replyToMessageId,
    this.metadata = const <String, dynamic>{},
  });

  final String body;
  final List<UploadAttachment> attachments;
  final String? type;
  final int? replyToMessageId;
  final Object metadata;

  bool get isValid => body.trim().isNotEmpty || attachments.isNotEmpty;

  static const int maxFiles = kUploadMaxFilesPerRequest;
  static const int maxFileBytes = kUploadMaxFileBytes;
  static const Set<String> allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'doc',
    'docx',
  };

  static String extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }

  bool get hasAllowedFiles =>
      attachments.length <= maxFiles &&
      attachments.every(
        (attachment) => allowedExtensions.contains(attachment.extension),
      );

  String get resolvedType {
    final explicit = type?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (attachments.isEmpty) return 'text';
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
    if (attachments.every(
      (attachment) => imageExtensions.contains(attachment.extension),
    )) {
      return 'image';
    }
    if (attachments.every(
      (attachment) => videoExtensions.contains(attachment.extension),
    )) {
      return 'video';
    }
    if (attachments.every(
      (attachment) => audioExtensions.contains(attachment.extension),
    )) {
      return 'audio';
    }
    return 'file';
  }
}
