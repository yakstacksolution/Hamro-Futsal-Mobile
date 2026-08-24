import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

bool isHeicFile(String path) {
  final String lower = path.toLowerCase();
  return lower.endsWith('.heic') || lower.endsWith('.heif');
}

Future<String> heicToPngJpg(String path) async {
  if (!isHeicFile(path)) return path;

  final String baseName = path
      .split(Platform.pathSeparator)
      .last
      .replaceAll(RegExp(r'\.(heic|heif)$', caseSensitive: false), '');
  final String targetPath =
      '${Directory.systemTemp.path}/${baseName}_${DateTime.now().microsecondsSinceEpoch}.jpg';

  try {
    final XFile? converted = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      format: CompressFormat.jpeg,
      quality: 90,
      minWidth: 10000,
      minHeight: 10000,
    );
    return converted?.path ?? path;
  } catch (_) {
    return path;
  }
}
