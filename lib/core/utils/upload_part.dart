import 'package:dio/dio.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/utils/upload_attachment.dart';

MultipartFile buildUploadPart(UploadAttachment attachment) {
  if (attachment.bytes.isEmpty || attachment.size <= 0) {
    throw UploadValidationException(
      UploadValidationCode.empty,
      StringConstants.fileIsEmptyAttachAgain,
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
    throw UploadValidationException(
      UploadValidationCode.tooManyFiles,
      StringConstants.uploadAtMostFiles(5),
    );
  }

  for (final MapEntry<String, MultipartFile> entry in form.files) {
    if (entry.value.length <= 0) {
      throw UploadValidationException(
        UploadValidationCode.empty,
        StringConstants.namedFileIsEmpty(
          entry.value.filename ?? StringConstants.theSelectedFile,
        ),
      );
    }
    if (entry.value.length > kUploadMaxFileBytes) {
      throw UploadValidationException(
        UploadValidationCode.fileTooLarge,
        StringConstants.namedFileMustBeOrSmaller(
          entry.value.filename ?? StringConstants.theSelectedFile,
          formatUploadSize(kUploadMaxFileBytes),
        ),
      );
    }
  }

  if (form.length > kUploadMaxRequestBytes) {
    throw UploadValidationException(
      UploadValidationCode.requestTooLarge,
      StringConstants.uploadExceedsRequestLimit(
        formatUploadSize(kUploadMaxRequestBytes),
      ),
    );
  }
}
