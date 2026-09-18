import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/api/api_client/api_constants.dart';
import 'package:gal/gal.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// What came back from a download attempt.
enum DownloadOutcome {
  savedToGallery,

  savedToFiles,

  saved,

  dismissed,
  unknown,

  permissionDenied,

  failed,

  nothingToDownload,
}

bool isDownloadSaved(DownloadOutcome outcome) =>
    outcome == DownloadOutcome.savedToGallery ||
    outcome == DownloadOutcome.savedToFiles ||
    outcome == DownloadOutcome.saved;

abstract final class DownloadHelper {
  static Future<DownloadOutcome> download({
    required String? url,
    String? fileName,
    GlobalKey? originKey,
    Dio? client,
  }) async {
    final String raw = url?.trim() ?? '';
    if (raw.isEmpty) return DownloadOutcome.nothingToDownload;
    final Uri? uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return DownloadOutcome.nothingToDownload;
    }

    HapticFeedback.lightImpact();

    final Uint8List bytes;
    final String? contentType;
    try {
      final Response<List<int>> response = await (client ?? Dio()).getUri(
        uri,
        options: Options(
          responseType: ResponseType.bytes,
          headers: _headersFor(uri),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      final List<int>? data = response.data;
      if (data == null || data.isEmpty) return DownloadOutcome.failed;
      bytes = Uint8List.fromList(data);
      contentType = response.headers.value(Headers.contentTypeHeader);
    } catch (_) {
      return DownloadOutcome.failed;
    }

    return _offer(
      bytes: bytes,
      name: resolveFileName(
        uri: uri,
        preferredName: fileName,
        contentType: contentType,
      ),
      originKey: originKey,
    );
  }

  static Future<DownloadOutcome> saveBytes({
    required Uint8List? bytes,
    String? fileName,
    GlobalKey? originKey,
  }) async {
    final Uint8List? data = bytes;
    if (data == null || data.isEmpty) return DownloadOutcome.nothingToDownload;

    HapticFeedback.lightImpact();

    final String preferred = _sanitize(fileName ?? '');
    final String name = _extensionOf(preferred) != null
        ? preferred
        : '${preferred.isEmpty ? 'download_${DateTime.now().millisecondsSinceEpoch}' : preferred}'
              '${_extensionForBytes(data)}';

    return _offer(bytes: data, name: name, originKey: originKey);
  }

  static Future<DownloadOutcome> _offer({
    required Uint8List bytes,
    required String name,
    GlobalKey? originKey,
  }) async {
    if (_isImage(name)) {
      final DownloadOutcome? gallery = await _saveToGallery(bytes, name);
      if (gallery != null) return gallery;
    }

    final Directory? target = await _saveDirectory();
    if (target != null) {
      try {
        final File file = File('${target.path}/${_uniqueIn(target, name)}');
        await file.writeAsBytes(bytes, flush: true);
        return DownloadOutcome.savedToFiles;
      } on FileSystemException {
        if (kDebugMode) {
          print('Failed to save to ${target.path}');
        }
      }
    }

    return _handOff(bytes: bytes, name: name, originKey: originKey);
  }

  static Future<DownloadOutcome?> _saveToGallery(
    Uint8List bytes,
    String name,
  ) async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;
    try {
      if (!await Gal.hasAccess(toAlbum: false)) {
        if (!await Gal.requestAccess(toAlbum: false)) {
          return DownloadOutcome.permissionDenied;
        }
      }
      await Gal.putImageBytes(bytes, name: _stemOf(name));
      return DownloadOutcome.savedToGallery;
    } on GalException catch (error) {
      return error.type == GalExceptionType.accessDenied
          ? DownloadOutcome.permissionDenied
          : null;
    } catch (_) {
      return null;
    }
  }

  static Future<Directory?> _saveDirectory() async {
    try {
      if (Platform.isAndroid) {
        final Directory public = Directory('/storage/emulated/0/Download');
        if (await public.exists() && await _isWritable(public)) return public;
        final Directory? external = await getExternalStorageDirectory();
        if (external != null) {
          final Directory downloads = Directory('${external.path}/Download');
          await downloads.create(recursive: true);
          return downloads;
        }
        return null;
      }
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> _isWritable(Directory directory) async {
    final File probe = File(
      '${directory.path}/.hf_write_probe_'
      '${DateTime.now().microsecondsSinceEpoch}',
    );
    try {
      await probe.writeAsBytes(const <int>[0], flush: true);
      await probe.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _uniqueIn(Directory directory, String name) {
    if (!File('${directory.path}/$name').existsSync()) return name;
    final String stem = _stemOf(name);
    final String? extension = _extensionOf(name);
    final String suffix = extension == null ? '' : '.$extension';
    for (int index = 1; index < 100; index++) {
      final String candidate = '$stem($index)$suffix';
      if (!File('${directory.path}/$candidate').existsSync()) return candidate;
    }
    return '${stem}_${DateTime.now().millisecondsSinceEpoch}$suffix';
  }

  static Future<DownloadOutcome> _handOff({
    required Uint8List bytes,
    required String name,
    GlobalKey? originKey,
  }) async {
    final File file = File('${Directory.systemTemp.path}/$name');
    try {
      await file.writeAsBytes(bytes, flush: true);
    } on FileSystemException {
      return DownloadOutcome.failed;
    }

    try {
      final ShareResult result = await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile(file.path, name: name, mimeType: _mimeTypeOf(name)),
          ],
          fileNameOverrides: <String>[name],
          sharePositionOrigin: _originRect(originKey),
        ),
      );
      switch (result.status) {
        case ShareResultStatus.success:
          return DownloadOutcome.saved;
        case ShareResultStatus.dismissed:
          return DownloadOutcome.dismissed;
        case ShareResultStatus.unavailable:
          return DownloadOutcome.unknown;
      }
    } catch (_) {
      return DownloadOutcome.failed;
    }
  }

  @visibleForTesting
  static String resolveFileName({
    required Uri uri,
    String? preferredName,
    String? contentType,
  }) {
    final String preferred = _sanitize(preferredName ?? '');
    if (preferred.isNotEmpty && _extensionOf(preferred) != null) {
      return preferred;
    }

    final String last = uri.pathSegments.isEmpty
        ? ''
        : _sanitize(uri.pathSegments.last);
    if (last.isNotEmpty && _extensionOf(last) != null) return last;

    final String stem = preferred.isNotEmpty
        ? preferred
        : 'download_${DateTime.now().millisecondsSinceEpoch}';
    return '$stem${_extensionForContentType(contentType)}';
  }

  static Map<String, dynamic>? _headersFor(Uri uri) {
    try {
      final Uri base = Uri.parse(APIEndpoint.baseUrl);
      if (uri.host != base.host) return null;
      final String token = AppSettings().tokenModel.accessToken ?? '';
      if (token.isEmpty) return null;
      return <String, dynamic>{'Authorization': 'Bearer $token'};
    } catch (_) {
      return null;
    }
  }

  static String _sanitize(String name) => name
      .trim()
      .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
      .replaceAll(RegExp(r'^[._]+'), '');

  static String? _extensionOf(String name) {
    final int dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return null;
    final String extension = name.substring(dot + 1).toLowerCase();
    return RegExp(r'^[a-z0-9]{1,5}$').hasMatch(extension) ? extension : null;
  }

  static String _extensionForContentType(String? contentType) {
    final String type = (contentType ?? '').toLowerCase();
    if (type.contains('png')) return '.png';
    if (type.contains('webp')) return '.webp';
    if (type.contains('heic') || type.contains('heif')) return '.heic';
    if (type.contains('pdf')) return '.pdf';
    if (type.contains('jpeg') || type.contains('jpg')) return '.jpg';
    return '.jpg';
  }

  static String _extensionForBytes(Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return '.png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return '.jpg';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return '.webp';
    }
    if (bytes.length >= 5 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      return '.pdf';
    }
    return '.png';
  }

  static bool _isImage(String name) => const <String>[
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'heif',
    'gif',
    'bmp',
  ].contains(_extensionOf(name));

  static String _stemOf(String name) {
    final String? extension = _extensionOf(name);
    return extension == null
        ? name
        : name.substring(0, name.length - extension.length - 1);
  }

  static String? _mimeTypeOf(String name) => switch (_extensionOf(name)) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'heic' || 'heif' => 'image/heic',
    'pdf' => 'application/pdf',
    'jpg' || 'jpeg' => 'image/jpeg',
    _ => null,
  };

  static Rect? _originRect(GlobalKey? key) {
    final RenderObject? renderObject = key?.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }
}
