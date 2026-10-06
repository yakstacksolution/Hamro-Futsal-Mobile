import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

const Set<String> _compressible = <String>{
  'jpg',
  'jpeg',
  'png',
  'webp',
  'heic',
  'heif',
};

const int _targetBytes = 1536 * 1024; // 1.5 MB
const int _maxEdge = 1600;

bool _isCompressible(String? filename) {
  final String name = filename?.toLowerCase().trim() ?? '';
  final int dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return false;
  return _compressible.contains(name.substring(dot + 1));
}

Future<Uint8List> compressUploadImage(
  Uint8List bytes, {
  String? filename,
  int targetBytes = _targetBytes,
}) async {
  if (bytes.length <= targetBytes) return bytes;
  if (!_isCompressible(filename)) return bytes;

  try {
    // Progressively reduce dimensions/quality. Each pass starts from the
    // original so compression artifacts are not compounded.
    const List<(int, int)> passes = <(int, int)>[
      (_maxEdge, 82),
      (1400, 74),
      (1200, 65),
      (960, 56),
    ];
    Uint8List out = bytes;
    for (final (int edge, int quality) in passes) {
      final Uint8List candidate = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: edge,
        minHeight: edge,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (candidate.isNotEmpty && candidate.length < out.length) {
        out = candidate;
      }
      if (out.length <= targetBytes) break;
    }
    // The normalizer rejects an image still above its safe target. Returning
    // the smallest attempt here lets it make that decision consistently.
    if (out.isEmpty || out.length >= bytes.length) return bytes;
    if (kDebugMode) {
      debugPrint(
        'UPLOAD IMAGE compressed ${bytes.length} -> ${out.length} bytes '
        '(${filename ?? 'unnamed'})',
      );
    }
    return out;
  } catch (error) {
    if (kDebugMode) {
      debugPrint('UPLOAD IMAGE compression failed: $error');
    }
    return bytes;
  }
}

String compressedUploadName(String? filename, {required bool wasCompressed}) {
  final String name = (filename ?? 'attachment.jpg').trim();
  if (!wasCompressed) return name;
  final int dot = name.lastIndexOf('.');
  final String stem = dot > 0 ? name.substring(0, dot) : name;
  return '$stem.jpg';
}
