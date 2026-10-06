import 'dart:typed_data';

final class BookingExportFile {
  const BookingExportFile({required this.bytes, required this.fileName});

  final Uint8List bytes;

  final String fileName;
}
