import 'package:dio/dio.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';

/// Builds the multipart part for one attachment.
///
/// Picker-owned paths are intentionally ignored here. Every retry therefore
/// gets a fresh stream over the immutable bytes captured at selection time.
MultipartFile buildUploadPart(UploadAttachment attachment) {
  if (attachment.bytes.isEmpty || attachment.size <= 0) {
    throw const UploadValidationException(
      UploadValidationCode.empty,
      'That file is empty. Please attach it again.',
    );
  }
  return MultipartFile.fromBytes(
    attachment.bytes,
    filename: attachment.filename,
    contentType: DioMediaType.parse(attachment.mimeType),
  );
}

/// Last-line validation for every multipart request, including any legacy
/// caller that did not use [buildUploadPart].
///
/// Feature code validates while selecting files; this second check runs at the
/// transport boundary so an empty part can never leave the application.
void validateMultipartFormData(FormData form) {
  if (form.files.length > kUploadMaxFilesPerRequest) {
    throw const UploadValidationException(
      UploadValidationCode.tooManyFiles,
      'You can upload at most 5 files at once.',
    );
  }

  for (final MapEntry<String, MultipartFile> entry in form.files) {
    if (entry.value.length <= 0) {
      throw UploadValidationException(
        UploadValidationCode.empty,
        '${entry.value.filename ?? 'The selected file'} is empty. '
        'Please attach it again.',
      );
    }
    if (entry.value.length > kUploadMaxFileBytes) {
      throw UploadValidationException(
        UploadValidationCode.fileTooLarge,
        '${entry.value.filename ?? 'The selected file'} must be '
        '${formatUploadSize(kUploadMaxFileBytes)} or smaller.',
      );
    }
  }

  if (form.length > kUploadMaxRequestBytes) {
    throw UploadValidationException(
      UploadValidationCode.requestTooLarge,
      'The upload exceeds the '
      '${formatUploadSize(kUploadMaxRequestBytes)} request limit.',
    );
  }
}
