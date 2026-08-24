import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Extensions worth recompressing. Anything else (PDF, DOC) is returned as-is:
/// running it through an image codec would corrupt it.
const Set<String> _compressible = <String>{
  'jpg',
  'jpeg',
  'png',
  'webp',
  'heic',
  'heif',
};

/// Target for an attachment that only has to be legible, not archival.
const int _targetBytes = 1536 * 1024; // 1.5 MB
const int _maxEdge = 1600;

bool _isCompressible(String? filename) {
  final String name = filename?.toLowerCase().trim() ?? '';
  final int dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return false;
  return _compressible.contains(name.substring(dot + 1));
}

/// Shrinks an image attachment so it clears the server's upload ceiling.
///
/// A phone screenshot is routinely 3–8 MB, which is above PHP's usual
/// `upload_max_filesize`. PHP does not reject that request outright: it drops
/// the file, keeps the text fields, and hands the app back a part with the
/// original **name** and a **size of 0** — which is what the server reports as
/// "The payment proof failed to upload". No amount of client retrying fixes
/// that, because the bytes never survive the request; the file has to be
/// smaller before it is sent.
///
/// Already-small images and non-images are returned untouched. The caller
/// validates the result and rejects it when no pass reaches the safe target.
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

/// The name to send alongside [compressUploadImage] output. A recompressed
/// PNG is JPEG data, and a mismatched extension is one more way for a strict
/// server-side validator to reject the part.
String compressedUploadName(String? filename, {required bool wasCompressed}) {
  final String name = (filename ?? 'attachment.jpg').trim();
  if (!wasCompressed) return name;
  final int dot = name.lastIndexOf('.');
  final String stem = dot > 0 ? name.substring(0, dot) : name;
  return '$stem.jpg';
}
