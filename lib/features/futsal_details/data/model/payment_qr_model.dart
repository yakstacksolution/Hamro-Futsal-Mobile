import 'dart:convert';
import 'dart:typed_data';

/// One QR image a court accepts payment on — a court can hold several (e.g.
/// eSewa and a bank), each an entry of `payment_qr_media_list`.
class PaymentQrImage {
  const PaymentQrImage({this.id, this.name, this.url, this.bytes});

  final int? id;
  final String? name;

  /// Network URL of the QR image, when the server returns a link.
  final String? url;

  /// Decoded QR image bytes, when the server returns base64.
  final Uint8List? bytes;

  bool get hasImage =>
      (url != null && url!.isNotEmpty) || (bytes != null && bytes!.isNotEmpty);

  /// Reads a media object (`{ id, name, full_url, status }`) or a plain URL /
  /// base64 string. Returns null when there is no usable image.
  static PaymentQrImage? fromValue(dynamic value) {
    int? id;
    String? name;
    if (value is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(value);
      final String? status = _asString(map['status'])?.toLowerCase();
      if (status != null && status != 'active') return null;
      id = int.tryParse(map['id']?.toString() ?? '');
      name = _asString(map['name'] ?? map['file_name']);
    }
    final PaymentQrImage? image = _imageFromRaw(_mediaUrl(value));
    if (image == null) return null;
    return PaymentQrImage(
      id: id,
      name: name,
      url: image.url,
      bytes: image.bytes,
    );
  }
}

/// The payment QR + payee details for a court, from
/// `GET /courts/{court_id}/payment-qr`.
///
/// The QR image may arrive either as a network URL or as a (data-URI or plain)
/// base64 string; both are supported via [qrImageUrl] / [qrImageBytes]. A court
/// with several QRs lists every one in [images]; [qrImageUrl] / [qrImageBytes]
/// then mirror the first.
class PaymentQrModel {
  const PaymentQrModel({
    this.qrImageUrl,
    this.qrImageBytes,
    List<PaymentQrImage> images = const <PaymentQrImage>[],
    this.payeeName,
    this.accountId,
    this.bankName,
    this.note,
    this.methods = const <String>[],
  }) : _images = images;

  /// Network URL of the QR image, when the server returns a link.
  final String? qrImageUrl;

  /// Decoded QR image bytes, when the server returns base64.
  final Uint8List? qrImageBytes;

  final String? payeeName;

  /// Account number / wallet id / phone shown under the QR.
  final String? accountId;
  final String? bankName;

  /// Optional payment instructions / remarks.
  final String? note;

  /// Accepted payment methods, e.g. ['eSewa', 'Khalti'].
  final List<String> methods;

  final List<PaymentQrImage> _images;

  /// Every QR the payer can choose from, in server order. Falls back to the
  /// single [qrImageUrl] / [qrImageBytes] for payloads without a list.
  List<PaymentQrImage> get images {
    if (_images.isNotEmpty) return _images;
    final PaymentQrImage single = PaymentQrImage(
      url: qrImageUrl,
      bytes: qrImageBytes,
    );
    return single.hasImage
        ? <PaymentQrImage>[single]
        : const <PaymentQrImage>[];
  }

  bool get hasQr =>
      (qrImageUrl != null && qrImageUrl!.isNotEmpty) ||
      (qrImageBytes != null && qrImageBytes!.isNotEmpty);

  factory PaymentQrModel.fromResponse(dynamic payload) {
    final Map<String, dynamic> map = _unwrap(payload);

    // The QR is usually a media object, e.g.
    // `payment_qr_media: { full_url: "https://..." }`. Fall back to a flat
    // string field when the server returns one directly.
    final String? rawQr =
        _mediaUrl(
          map['payment_qr_media'] ??
              map['paymentQrMedia'] ??
              map['qr_media'] ??
              map['qrMedia'] ??
              map['media'],
        ) ??
        _asString(
          map['qr_image'] ??
              map['qr_image_url'] ??
              map['qrImageUrl'] ??
              map['qr_code_image'] ??
              map['qr_code'] ??
              map['qrCode'] ??
              map['payment_qr'] ??
              map['paymentQr'] ??
              map['qr_url'] ??
              map['qr_path'] ??
              map['qr'] ??
              map['image'] ??
              map['image_url'] ??
              map['imageUrl'],
        );

    // Courts that accept more than one QR send them all in
    // `payment_qr_media_list`, with `payment_qr_media` left null.
    final dynamic rawList =
        map['payment_qr_media_list'] ??
        map['paymentQrMediaList'] ??
        map['payment_qrs'] ??
        map['paymentQrs'];
    final List<PaymentQrImage> listed = rawList is List
        ? rawList
              .map(PaymentQrImage.fromValue)
              .whereType<PaymentQrImage>()
              .toList(growable: false)
        : const <PaymentQrImage>[];

    final PaymentQrImage? single = _imageFromRaw(rawQr);
    final List<PaymentQrImage> images = listed.isNotEmpty
        ? listed
        : <PaymentQrImage>[?single];
    final PaymentQrImage? primary = images.isEmpty ? null : images.first;

    return PaymentQrModel(
      qrImageUrl: primary?.url,
      qrImageBytes: primary?.bytes,
      images: images,
      payeeName:
          _asString(
            map['payee_name'] ??
                map['payeeName'] ??
                map['account_name'] ??
                map['accountName'] ??
                map['holder_name'] ??
                map['beneficiary_name'] ??
                map['name'] ??
                map['merchant_name'],
          ) ??
          _nestedName(map['venue']) ??
          _asString(map['court_name'] ?? map['courtName']),
      accountId: _asString(
        map['account_number'] ??
            map['accountNumber'] ??
            map['account_no'] ??
            map['payee_id'] ??
            map['payeeId'] ??
            map['phone'] ??
            map['phone_number'] ??
            map['number'] ??
            map['merchant_code'] ??
            map['qr_id'],
      ),
      bankName: _asString(map['bank_name'] ?? map['bankName'] ?? map['bank']),
      note: _asString(
        map['note'] ??
            map['instructions'] ??
            map['instruction'] ??
            map['description'] ??
            map['remarks'],
      ),
      methods: _methodsFrom(
        map['methods'] ??
            map['payment_methods'] ??
            map['paymentMethods'] ??
            map['supported_methods'],
      ),
    );
  }
}

Map<String, dynamic> _unwrap(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 5 && current is Map; depth++) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final dynamic nested =
        map['data'] ?? map['payment_qr'] ?? map['qr'] ?? map['result'];
    final bool hasQrFields = map.keys.any(
      (String k) => const <String>{
        'qr_image',
        'qr_image_url',
        'qr_code',
        'qr_code_image',
        'qr',
        'payment_qr',
        'image',
        'image_url',
      }.contains(k),
    );
    if (hasQrFields || nested is! Map) return map;
    current = nested;
  }
  return current is Map
      ? Map<String, dynamic>.from(current)
      : <String, dynamic>{};
}

/// Turns a raw QR value — a URL, a relative path or base64 — into an image.
PaymentQrImage? _imageFromRaw(String? rawQr) {
  if (rawQr == null) return null;
  if (rawQr.startsWith('http://') || rawQr.startsWith('https://')) {
    return PaymentQrImage(url: _collapseSlashes(rawQr));
  }
  final Uint8List? bytes = _decodeBase64Image(rawQr);
  if (bytes != null) return PaymentQrImage(bytes: bytes);
  // Fall back to treating it as a relative URL path if it isn't base64.
  if (rawQr.contains('/')) return PaymentQrImage(url: rawQr);
  return null;
}

/// The API joins its base URL and storage path with a doubled slash
/// (`https://host//storage/...`); collapse it so caching keys and downloads
/// see one canonical URL.
String _collapseSlashes(String url) {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null || !uri.hasAuthority) return url;
  return uri
      .replace(path: uri.path.replaceAll(RegExp(r'/{2,}'), '/'))
      .toString();
}

/// Decodes a data-URI (`data:image/png;base64,...`) or a plain base64 string
/// into image bytes. Returns null when the value isn't valid base64.
Uint8List? _decodeBase64Image(String value) {
  String data = value.trim();
  final int comma = data.indexOf(',');
  if (data.startsWith('data:') && comma != -1) {
    data = data.substring(comma + 1);
  }
  data = data.replaceAll(RegExp(r'\s'), '');
  if (data.length < 64) return null;
  try {
    return base64Decode(base64.normalize(data));
  } catch (_) {
    return null;
  }
}

List<String> _methodsFrom(dynamic value) {
  if (value is List) {
    return value.map(_asString).whereType<String>().toList(growable: false);
  }
  final String? single = _asString(value);
  if (single == null) return const <String>[];
  return single
      .split(RegExp(r'[,·|/]'))
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList(growable: false);
}

/// Extracts a usable image URL from a media value — either a media object
/// (`{ full_url: "..." }`) or a plain URL string.
String? _mediaUrl(dynamic value) {
  if (value is String) return _asString(value);
  if (value is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(value);
    return _asString(
      map['full_url'] ??
          map['fullUrl'] ??
          map['url'] ??
          map['image_url'] ??
          map['imageUrl'] ??
          map['path'] ??
          map['src'],
    );
  }
  return null;
}

/// Reads a `name`/`title` from a nested object (e.g. `venue: { name: "..." }`).
String? _nestedName(dynamic value) {
  if (value is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(value);
    return _asString(map['name'] ?? map['title'] ?? map['label']);
  }
  return null;
}

String? _asString(dynamic value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
