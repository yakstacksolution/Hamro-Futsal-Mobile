import 'dart:io';
import 'dart:typed_data';

import 'package:hamro_footsall/core/utils/compress_upload_image.dart';

/// Application-wide limits for multipart uploads.
const int kUploadMaxFileBytes = 10 * 1024 * 1024;
const int kUploadImageTargetBytes = 1536 * 1024;
const int kUploadMaxFilesPerRequest = 5;
const int kUploadMaxRequestBytes = 64 * 1024 * 1024;

const Set<String> kUploadImageExtensions = <String>{
  'jpg',
  'jpeg',
  'png',
  'webp',
  'heic',
  'heif',
};

const Set<String> kUploadDocumentExtensions = <String>{
  ...kUploadImageExtensions,
  'pdf',
  'doc',
  'docx',
};

/// Constraints applied before an attachment is allowed into feature state.
class UploadPolicy {
  const UploadPolicy({
    this.allowedExtensions = kUploadDocumentExtensions,
    this.maxInputBytes = kUploadMaxFileBytes,
    this.maxFiles = kUploadMaxFilesPerRequest,
    this.maxRequestBytes = kUploadMaxRequestBytes,
    this.imageTargetBytes = kUploadImageTargetBytes,
    this.optimizeImages = true,
  });

  final Set<String> allowedExtensions;
  final int maxInputBytes;
  final int maxFiles;
  final int maxRequestBytes;
  final int imageTargetBytes;
  final bool optimizeImages;
}

enum UploadValidationCode {
  empty,
  unreadable,
  unsupportedType,
  fileTooLarge,
  imageOptimizationFailed,
  tooManyFiles,
  requestTooLarge,
}

/// A local validation failure that can be shown directly to the user.
class UploadValidationException implements Exception {
  const UploadValidationException(this.code, this.message);

  final UploadValidationCode code;
  final String message;

  @override
  String toString() => message;
}

/// Immutable upload input captured while the picker result is still readable.
///
/// [sourcePath] exists only for local preview/OCR. Multipart requests must use
/// [bytes], never read the picker-owned path again.
final class UploadAttachment {
  UploadAttachment({
    required String filename,
    required Uint8List bytes,
    int? originalSize,
    this.sourcePath,
    String? mimeType,
  }) : filename = _safeFilename(filename),
       bytes = Uint8List.fromList(bytes).asUnmodifiableView(),
       originalSize = _resolvedOriginalSize(originalSize, bytes.length),
       mimeType = mimeType ?? uploadMimeTypeFor(filename) {
    if (this.bytes.isEmpty) {
      throw const UploadValidationException(
        UploadValidationCode.empty,
        'That file is empty. Please attach it again.',
      );
    }
  }

  final String filename;
  final Uint8List bytes;
  final int originalSize;
  final String? sourcePath;
  final String mimeType;

  int get size => bytes.length;
  String get name => filename;
  String get path => sourcePath ?? '';

  String get extension {
    final int dot = filename.lastIndexOf('.');
    return dot < 0 ? '' : filename.substring(dot + 1).toLowerCase();
  }

  bool get isImage => kUploadImageExtensions.contains(extension);

  String get sizeLabel => formatUploadSize(size);
}

typedef UploadImageOptimizer =
    Future<Uint8List> Function(
      Uint8List bytes, {
      String? filename,
      int targetBytes,
    });

/// Validates and, for large images, optimizes bytes before feature state keeps
/// them. This is the single entrance into every active multipart upload flow.
Future<UploadAttachment> normalizeUploadAttachment({
  required Uint8List bytes,
  required String filename,
  String? sourcePath,
  int? originalSize,
  UploadPolicy policy = const UploadPolicy(),
  UploadImageOptimizer imageOptimizer = compressUploadImage,
}) async {
  if (bytes.isEmpty) {
    throw const UploadValidationException(
      UploadValidationCode.empty,
      'That file came through empty. Please attach it again.',
    );
  }

  final String safeName = _safeFilename(filename);
  final String extension = uploadExtensionOf(safeName);
  final Set<String> allowed = policy.allowedExtensions
      .map((String item) => item.toLowerCase())
      .toSet();
  if (extension.isEmpty || !allowed.contains(extension)) {
    throw UploadValidationException(
      UploadValidationCode.unsupportedType,
      'Only ${allowed.map((String item) => item.toUpperCase()).join(', ')} '
      'files can be uploaded.',
    );
  }

  // Picker metadata is advisory. The captured bytes are the source of truth,
  // especially on platforms that occasionally report a valid file as 0 B.
  final int pickedSize = _resolvedOriginalSize(originalSize, bytes.length);
  if (pickedSize > policy.maxInputBytes) {
    throw UploadValidationException(
      UploadValidationCode.fileTooLarge,
      'The file must be ${formatUploadSize(policy.maxInputBytes)} or smaller.',
    );
  }

  Uint8List uploadBytes = Uint8List.fromList(bytes);
  String uploadName = safeName;
  final bool isImage = kUploadImageExtensions.contains(extension);
  if (policy.optimizeImages &&
      isImage &&
      uploadBytes.length > policy.imageTargetBytes) {
    final Uint8List optimized = await imageOptimizer(
      uploadBytes,
      filename: safeName,
      targetBytes: policy.imageTargetBytes,
    );
    if (optimized.isEmpty || optimized.length > policy.imageTargetBytes) {
      throw UploadValidationException(
        UploadValidationCode.imageOptimizationFailed,
        'The image could not be reduced below '
        '${formatUploadSize(policy.imageTargetBytes)}. Please choose a smaller image.',
      );
    }
    uploadBytes = Uint8List.fromList(optimized);
    uploadName = compressedUploadName(safeName, wasCompressed: true);
  }

  return UploadAttachment(
    filename: uploadName,
    bytes: uploadBytes,
    originalSize: pickedSize,
    sourcePath: sourcePath,
  );
}

/// Reads a picker-owned path once and immediately turns it into durable bytes.
Future<UploadAttachment> loadUploadAttachment({
  required String path,
  required String filename,
  UploadPolicy policy = const UploadPolicy(),
  UploadImageOptimizer imageOptimizer = compressUploadImage,
}) async {
  final String trimmedPath = path.trim();
  if (trimmedPath.isEmpty) {
    throw const UploadValidationException(
      UploadValidationCode.unreadable,
      'That file could not be read. Please attach it again.',
    );
  }

  try {
    final File file = File(trimmedPath);
    if (!await file.exists()) {
      throw const UploadValidationException(
        UploadValidationCode.unreadable,
        'That file is no longer available. Please attach it again.',
      );
    }
    final int size = await file.length();
    if (size <= 0) {
      throw const UploadValidationException(
        UploadValidationCode.empty,
        'That file came through empty. Please attach it again.',
      );
    }
    if (size > policy.maxInputBytes) {
      throw UploadValidationException(
        UploadValidationCode.fileTooLarge,
        'The file must be ${formatUploadSize(policy.maxInputBytes)} or smaller.',
      );
    }
    return normalizeUploadAttachment(
      bytes: await file.readAsBytes(),
      filename: filename,
      sourcePath: trimmedPath,
      originalSize: size,
      policy: policy,
      imageOptimizer: imageOptimizer,
    );
  } on UploadValidationException {
    rethrow;
  } on FileSystemException {
    throw const UploadValidationException(
      UploadValidationCode.unreadable,
      'That file could not be read. Please attach it again.',
    );
  }
}

void validateUploadBatch(
  List<UploadAttachment> attachments, {
  UploadPolicy policy = const UploadPolicy(),
}) {
  if (attachments.length > policy.maxFiles) {
    throw UploadValidationException(
      UploadValidationCode.tooManyFiles,
      'You can upload at most ${policy.maxFiles} files at once.',
    );
  }
  for (final UploadAttachment attachment in attachments) {
    validateUploadAttachment(attachment, policy: policy);
  }
  final int total = attachments.fold<int>(
    0,
    (int sum, UploadAttachment attachment) => sum + attachment.size,
  );
  if (total > policy.maxRequestBytes) {
    throw UploadValidationException(
      UploadValidationCode.requestTooLarge,
      'The selected files exceed the ${formatUploadSize(policy.maxRequestBytes)} request limit.',
    );
  }
}

void validateUploadAttachment(
  UploadAttachment attachment, {
  UploadPolicy policy = const UploadPolicy(),
}) {
  if (attachment.bytes.isEmpty || attachment.size <= 0) {
    throw const UploadValidationException(
      UploadValidationCode.empty,
      'That file is empty. Please attach it again.',
    );
  }

  final Set<String> allowed = policy.allowedExtensions
      .map((String item) => item.toLowerCase())
      .toSet();
  if (!allowed.contains(attachment.extension)) {
    throw UploadValidationException(
      UploadValidationCode.unsupportedType,
      'The selected file type is not supported. Please attach a supported file.',
    );
  }
  if (attachment.originalSize > policy.maxInputBytes ||
      attachment.size > policy.maxInputBytes) {
    throw UploadValidationException(
      UploadValidationCode.fileTooLarge,
      'The file must be ${formatUploadSize(policy.maxInputBytes)} or smaller.',
    );
  }
  if (policy.optimizeImages &&
      attachment.isImage &&
      attachment.size > policy.imageTargetBytes) {
    throw UploadValidationException(
      UploadValidationCode.imageOptimizationFailed,
      'The image is still larger than '
      '${formatUploadSize(policy.imageTargetBytes)}. Please choose a smaller image.',
    );
  }
}

String uploadExtensionOf(String filename) {
  final int dot = filename.lastIndexOf('.');
  return dot < 0 || dot == filename.length - 1
      ? ''
      : filename.substring(dot + 1).toLowerCase();
}

String uploadMimeTypeFor(String filename) {
  return switch (uploadExtensionOf(filename)) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
    'heic' => 'image/heic',
    'heif' => 'image/heif',
    'pdf' => 'application/pdf',
    'doc' => 'application/msword',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    _ => 'application/octet-stream',
  };
}

String formatUploadSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _safeFilename(String filename) {
  final String leaf = filename
      .trim()
      .split(Platform.pathSeparator)
      .last
      .split('/')
      .last;
  return leaf.isEmpty ? 'attachment' : leaf;
}

int _resolvedOriginalSize(int? reportedSize, int capturedSize) {
  if (reportedSize == null || reportedSize < capturedSize) return capturedSize;
  return reportedSize;
}
