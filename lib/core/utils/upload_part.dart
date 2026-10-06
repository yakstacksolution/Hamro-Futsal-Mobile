import 'package:dio/dio.dart';
import 'package:hamro_futsal/core/utils/upload_attachment.dart';

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
