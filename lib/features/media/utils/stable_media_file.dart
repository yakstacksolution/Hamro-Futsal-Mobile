import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Waits for camera providers that return before the captured file is flushed,
/// then snapshots the image into an app-owned temporary file.
Future<XFile?> stabilizePickedMedia(XFile source) async {
  Uint8List bytes = Uint8List(0);

  for (int attempt = 0; attempt < 10; attempt++) {
    try {
      bytes = await source.readAsBytes();
      if (bytes.isNotEmpty) break;
    } on FileSystemException {
      // Some Android camera providers briefly lock the file while finalizing it.
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  if (bytes.isEmpty) return null;

  final String extension = _extensionOf(source.name);
  final String fileName =
      'camera_${DateTime.now().microsecondsSinceEpoch}$extension';
  final File stableFile = File('${Directory.systemTemp.path}/$fileName');
  await stableFile.writeAsBytes(bytes, flush: true);

  return XFile(stableFile.path, name: fileName, length: bytes.length);
}

String _extensionOf(String name) {
  final int dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return '.jpg';
  return name.substring(dot).toLowerCase();
}
