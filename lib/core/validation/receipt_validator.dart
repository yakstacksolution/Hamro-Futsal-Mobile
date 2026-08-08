import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

typedef DuplicateTransactionChecker =
    Future<bool> Function(String transactionId);

class ReceiptValidationResult {
  final bool accepted;

  /// This must remain true unless you verify against the payment provider API.
  final bool manualVerificationRequired;

  final int score;
  final String reason;

  final bool imageQualityPassed;
  final bool ocrReadable;
  final bool merchantMatched;
  final bool amountMatched;
  final bool successStatusFound;
  final bool transactionIdFound;
  final bool dateFound;
  final bool qrCodeFound;

  final bool duplicateChecked;
  final bool duplicateTransaction;

  final String? transactionId;
  final String? dateText;
  final double? detectedAmount;
  final String? matchedMerchant;
  final double merchantSimilarity;

  final List<String> qrValues;

  /// Be careful storing/logging this in production.
  final String rawText;

  final int imageWidth;
  final int imageHeight;
  final int imageBytes;

  /// Heuristic only.
  final double brightnessStdDev;

  /// Heuristic only.
  final double edgeScore;

  const ReceiptValidationResult({
    required this.accepted,
    required this.manualVerificationRequired,
    required this.score,
    required this.reason,
    required this.imageQualityPassed,
    required this.ocrReadable,
    required this.merchantMatched,
    required this.amountMatched,
    required this.successStatusFound,
    required this.transactionIdFound,
    required this.dateFound,
    required this.qrCodeFound,
    required this.duplicateChecked,
    required this.duplicateTransaction,
    required this.transactionId,
    required this.dateText,
    required this.detectedAmount,
    required this.matchedMerchant,
    required this.merchantSimilarity,
    required this.qrValues,
    required this.rawText,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageBytes,
    required this.brightnessStdDev,
    required this.edgeScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'accepted': accepted,

      // IMPORTANT:
      // accepted = structurally acceptable proof,
      // NOT verified payment.
      'payment_verified': false,
      'manual_verification_required': manualVerificationRequired,
      'status': accepted ? 'pending_manual_verification' : 'proof_rejected',

      'score': score,
      'reason': reason,

      'checks': {
        'image_quality': imageQualityPassed,
        'ocr_readable': ocrReadable,
        'merchant_matched': merchantMatched,
        'amount_matched': amountMatched,
        'success_status_found': successStatusFound,
        'transaction_id_found': transactionIdFound,
        'date_found': dateFound,
        'qr_code_found': qrCodeFound,
        'duplicate_checked': duplicateChecked,
        'duplicate_transaction': duplicateTransaction,
      },

      'extracted': {
        'transaction_id': transactionId,
        'date': dateText,
        'amount': detectedAmount,
        'merchant': matchedMerchant,
        'merchant_similarity': merchantSimilarity,
        'qr_values': qrValues,
      },

      'image': {
        'width': imageWidth,
        'height': imageHeight,
        'bytes': imageBytes,
        'brightness_std_dev': brightnessStdDev,
        'edge_score': edgeScore,
      },
    };
  }

  @override
  String toString() => toJson().toString();
}

class ReceiptValidator {
  ReceiptValidator._();

  /// Main function.
  ///
  /// Example:
  ///
  /// final result = await ReceiptValidator.validate(
  ///   image: File(path),
  ///   expectedAmount: 500,
  ///   merchantNames: [
  ///     'Yak Stack Solution',
  ///     'YAK STACK SOLUTION',
  ///     'YakStack',
  ///   ],
  /// );
  ///
  /// IMPORTANT:
  ///
  /// result.accepted == true means:
  /// "proof looks structurally valid and can enter manual review"
  ///
  /// It DOES NOT mean:
  /// "payment has been verified with bank/eSewa/Khalti/etc."
  static Future<ReceiptValidationResult> validate({
    required File image,
    required double expectedAmount,
    required List<String> merchantNames,

    DuplicateTransactionChecker? duplicateChecker,

    bool requireDate = true,
    bool requireQrCode = false,
    bool requireTransactionId = true,

    /// Minimum total score.
    int minimumScore = 75,

    /// Amount tolerance. For exact payment amount keep around 0.01.
    double amountTolerance = 0.01,

    /// Merchant OCR similarity.
    double merchantSimilarityThreshold = 0.78,

    /// Reject tiny screenshots/images.
    int minimumWidth = 360,
    int minimumHeight = 360,

    /// Very small files are suspicious / unusable.
    int minimumFileBytes = 12 * 1024,

    int minimumOcrCharacters = 20,
  }) async {
    TextRecognizer? textRecognizer;
    BarcodeScanner? barcodeScanner;

    try {
      if (!await image.exists()) {
        return _errorResult('Receipt image does not exist.');
      }

      final imageQuality = await _checkImageQuality(
        image,
        minimumWidth: minimumWidth,
        minimumHeight: minimumHeight,
        minimumFileBytes: minimumFileBytes,
      );

      final inputImage = InputImage.fromFilePath(image.path);

      // -------------------------------------------------------
      // OCR
      // -------------------------------------------------------

      textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final recognizedText = await textRecognizer.processImage(inputImage);

      final rawText = recognizedText.text.trim();

      final lines = recognizedText.blocks
          .expand((block) => block.lines)
          .map((line) => line.text.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      final cleanCharacters = rawText.replaceAll(RegExp(r'\s+'), '').length;

      final ocrReadable =
          cleanCharacters >= minimumOcrCharacters && lines.length >= 2;

      // -------------------------------------------------------
      // QR CODE
      // -------------------------------------------------------

      barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

      List<Barcode> barcodes = [];

      try {
        barcodes = await barcodeScanner.processImage(inputImage);
      } catch (_) {
        // QR detection failure should not crash receipt validation.
      }

      final qrValues = barcodes
          .map((barcode) => barcode.rawValue ?? barcode.displayValue)
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList();

      final qrFound = qrValues.isNotEmpty;

      // -------------------------------------------------------
      // MERCHANT
      // -------------------------------------------------------

      final merchantResult = _matchMerchant(
        rawText: rawText,
        lines: lines,
        aliases: merchantNames,
        threshold: merchantSimilarityThreshold,
      );

      // -------------------------------------------------------
      // AMOUNT
      // -------------------------------------------------------

      final amounts = _extractAmounts(rawText);

      double? matchedAmount;

      for (final amount in amounts) {
        if ((amount - expectedAmount).abs() <= amountTolerance) {
          matchedAmount = amount;
          break;
        }
      }

      final amountMatched = matchedAmount != null;

      // -------------------------------------------------------
      // PAYMENT STATUS
      // -------------------------------------------------------

      final paymentStatus = _checkPaymentStatus(rawText);

      // -------------------------------------------------------
      // TRANSACTION ID
      // -------------------------------------------------------

      final transactionId = _extractTransactionId(rawText);

      final transactionIdFound =
          transactionId != null && transactionId.trim().isNotEmpty;

      // -------------------------------------------------------
      // DATE
      // -------------------------------------------------------

      final dateText = _extractDate(rawText);
      final dateFound = dateText != null;

      // -------------------------------------------------------
      // DUPLICATE TRANSACTION
      // -------------------------------------------------------

      bool duplicateChecked = false;
      bool duplicateTransaction = false;

      if (transactionIdFound && duplicateChecker != null) {
        duplicateChecked = true;

        try {
          duplicateTransaction = await duplicateChecker(transactionId);
        } catch (_) {
          // Fail safely.
          //
          // We don't mark as duplicate when the API fails,
          // but the server MUST perform duplicate checking again
          // before storing/accepting the proof.
          duplicateChecked = false;
        }
      }

      // -------------------------------------------------------
      // BLUR + OCR COMBINED CHECK
      // -------------------------------------------------------

      // Edge detection by itself is only a heuristic.
      // A clean screenshot can have low edge density.
      //
      // Therefore only reject "blurry" when OCR also failed.
      final severelyBlurry = imageQuality.possiblyBlurry && !ocrReadable;

      final imageQualityPassed =
          imageQuality.basicQualityPassed &&
          !imageQuality.probablyBlank &&
          !severelyBlurry;

      // -------------------------------------------------------
      // SCORE
      // -------------------------------------------------------

      int score = 0;

      // 10 points
      if (ocrReadable) {
        score += 10;
      }

      // 20 points
      if (merchantResult.matched) {
        score += 20;
      }

      // 25 points
      if (amountMatched) {
        score += 25;
      }

      // 15 points
      if (paymentStatus.success) {
        score += 15;
      }

      // 15 points
      if (transactionIdFound) {
        score += 15;
      }

      // 5 points
      if (dateFound) {
        score += 5;
      }

      // 5 points
      if (qrFound) {
        score += 5;
      }

      // 5 points
      if (imageQualityPassed) {
        score += 5;
      }

      // -------------------------------------------------------
      // HARD VALIDATION RULES
      // -------------------------------------------------------

      final errors = <String>[];

      if (!imageQualityPassed) {
        if (imageQuality.width < minimumWidth ||
            imageQuality.height < minimumHeight) {
          errors.add('Receipt image resolution is too low');
        } else if (imageQuality.fileBytes < minimumFileBytes) {
          errors.add('Receipt image file is too small');
        } else if (imageQuality.probablyBlank) {
          errors.add('Receipt image appears blank');
        } else if (severelyBlurry) {
          errors.add('Receipt image appears blurry or unreadable');
        } else {
          errors.add('Receipt image quality is not acceptable');
        }
      }

      if (!ocrReadable) {
        errors.add('Receipt text is not readable');
      }

      if (!merchantResult.matched) {
        errors.add('Merchant name does not match');
      }

      if (!amountMatched) {
        errors.add(
          'Expected amount ${expectedAmount.toStringAsFixed(2)} not found',
        );
      }

      if (!paymentStatus.success) {
        if (paymentStatus.negativeStatusFound) {
          errors.add('Payment is not marked successful');
        } else {
          errors.add('Successful payment status not found');
        }
      }

      if (requireTransactionId && !transactionIdFound) {
        errors.add('Transaction/reference ID not found');
      }

      if (requireDate && !dateFound) {
        errors.add('Transaction date not found');
      }

      if (requireQrCode && !qrFound) {
        errors.add('QR code not found');
      }

      if (duplicateTransaction) {
        errors.add('Transaction ID has already been submitted');
      }

      if (score < minimumScore) {
        errors.add('Receipt validation score is below $minimumScore%');
      }

      final accepted = errors.isEmpty;

      return ReceiptValidationResult(
        accepted: accepted,

        // ALWAYS manual verification because we're only examining image proof.
        manualVerificationRequired: true,

        score: score,
        reason: accepted
            ? 'Proof accepted. Pending manual payment verification.'
            : errors.join('. '),

        imageQualityPassed: imageQualityPassed,
        ocrReadable: ocrReadable,
        merchantMatched: merchantResult.matched,
        amountMatched: amountMatched,
        successStatusFound: paymentStatus.success,
        transactionIdFound: transactionIdFound,
        dateFound: dateFound,
        qrCodeFound: qrFound,

        duplicateChecked: duplicateChecked,
        duplicateTransaction: duplicateTransaction,

        transactionId: transactionId,
        dateText: dateText,
        detectedAmount: matchedAmount,

        matchedMerchant: merchantResult.alias,
        merchantSimilarity: merchantResult.similarity,

        qrValues: qrValues,

        rawText: rawText,

        imageWidth: imageQuality.width,
        imageHeight: imageQuality.height,
        imageBytes: imageQuality.fileBytes,

        brightnessStdDev: imageQuality.brightnessStdDev,
        edgeScore: imageQuality.edgeScore,
      );
    } catch (e) {
      return _errorResult('Unable to process payment receipt: $e');
    } finally {
      textRecognizer?.close();
      barcodeScanner?.close();
    }
  }

  // =========================================================
  // PAYMENT STATUS
  // =========================================================

  static _PaymentStatusResult _checkPaymentStatus(String text) {
    final value = text.toLowerCase();

    // Check failure statuses FIRST.
    //
    // Example:
    // "unsuccessful" contains the word "successful".
    final negativePatterns = <RegExp>[
      RegExp(r'\bunsuccessful\b'),
      RegExp(r'\bfailed\b'),
      RegExp(r'\bfailure\b'),
      RegExp(r'\bdeclined\b'),
      RegExp(r'\bcancelled\b'),
      RegExp(r'\bcanceled\b'),
      RegExp(r'\bpending\b'),
      RegExp(r'\bprocessing\b'),
      RegExp(r'\breversed\b'),
      RegExp(r'\brefunded\b'),
      RegExp(r'\bexpired\b'),
    ];

    final negativeFound = negativePatterns.any(
      (pattern) => pattern.hasMatch(value),
    );

    if (negativeFound) {
      return const _PaymentStatusResult(
        success: false,
        negativeStatusFound: true,
      );
    }

    final positivePatterns = <RegExp>[
      RegExp(r'\bpayment\s+successful\b'),
      RegExp(r'\btransaction\s+successful\b'),
      RegExp(r'\bsuccessfully\s+paid\b'),
      RegExp(r'\bsuccessfully\s+transferred\b'),
      RegExp(r'\bsuccessfully\s+sent\b'),
      RegExp(r'\bpayment\s+completed\b'),
      RegExp(r'\btransaction\s+completed\b'),
      RegExp(r'\bpayment\s+complete\b'),
      RegExp(r'\bsuccess\b'),
      RegExp(r'\bsuccessful\b'),
      RegExp(r'\bcompleted\b'),
      RegExp(r'\bpaid\b'),
    ];

    final positiveFound = positivePatterns.any(
      (pattern) => pattern.hasMatch(value),
    );

    return _PaymentStatusResult(
      success: positiveFound,
      negativeStatusFound: false,
    );
  }

  // =========================================================
  // AMOUNT
  // =========================================================

  static List<double> _extractAmounts(String rawText) {
    final text = rawText
        .toLowerCase()
        .replaceAll(',', '')
        .replaceAll('रू', 'rs')
        .replaceAll('रु', 'rs');

    final amounts = <double>[];

    final patterns = <RegExp>[
      // Total Amount: NPR 500.00
      RegExp(
        r'(?:total\s*amount|payment\s*amount|paid\s*amount|'
        r'transaction\s*amount|transferred\s*amount|'
        r'received\s*amount|send\s*amount|sent\s*amount|'
        r'amount\s*paid|total|amount)'
        r'\s*[:=\-]?\s*'
        r'(?:npr|rs\.?)?\s*'
        r'([0-9]+(?:\.[0-9]{1,2})?)',
        caseSensitive: false,
      ),

      // NPR 500
      RegExp(
        r'(?:npr|rs\.?)\s*[:=\-]?\s*'
        r'([0-9]+(?:\.[0-9]{1,2})?)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      for (final match in pattern.allMatches(text)) {
        final value = match.group(1);

        if (value == null) continue;

        final amount = double.tryParse(value);

        if (amount != null && amount >= 0 && amount <= 1000000000) {
          amounts.add(amount);
        }
      }
    }

    return amounts.toSet().toList();
  }

  // =========================================================
  // TRANSACTION ID
  // =========================================================

  static String? _extractTransactionId(String text) {
    final patterns = <RegExp>[
      RegExp(
        r'(?:transaction\s*(?:id|no|number)|'
        r'txn\s*(?:id|no|number)|'
        r'transaction\s*reference)'
        r'\s*[:#=\-]?\s*'
        r'([a-zA-Z0-9][a-zA-Z0-9\-_/]{5,50})',
        caseSensitive: false,
      ),

      RegExp(
        r'(?:reference\s*(?:id|no|number)|'
        r'ref\s*(?:id|no|number)|'
        r'reference\s*number)'
        r'\s*[:#=\-]?\s*'
        r'([a-zA-Z0-9][a-zA-Z0-9\-_/]{5,50})',
        caseSensitive: false,
      ),

      RegExp(
        r'(?:trace\s*(?:id|no|number)|'
        r'trace\s*number)'
        r'\s*[:#=\-]?\s*'
        r'([a-zA-Z0-9][a-zA-Z0-9\-_/]{5,50})',
        caseSensitive: false,
      ),

      RegExp(
        r'(?:payment\s*(?:id|reference)|'
        r'payment\s*reference)'
        r'\s*[:#=\-]?\s*'
        r'([a-zA-Z0-9][a-zA-Z0-9\-_/]{5,50})',
        caseSensitive: false,
      ),

      // Common banking terminology
      RegExp(
        r'(?:bank\s*reference|'
        r'bank\s*ref|'
        r'rrn)'
        r'\s*[:#=\-]?\s*'
        r'([a-zA-Z0-9][a-zA-Z0-9\-_/]{5,50})',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);

      if (match != null) {
        final value = match.group(1)?.trim();

        if (value != null && value.length >= 6) {
          return value;
        }
      }
    }

    return null;
  }

  // =========================================================
  // DATE
  // =========================================================

  static String? _extractDate(String text) {
    final months =
        r'(?:jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|'
        r'may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|'
        r'oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)';

    final patterns = <RegExp>[
      // 2026-08-07
      RegExp(r'\b20\d{2}[-/.]\d{1,2}[-/.]\d{1,2}\b', caseSensitive: false),

      // 07-08-2026
      RegExp(r'\b\d{1,2}[-/.]\d{1,2}[-/.]20\d{2}\b', caseSensitive: false),

      // August 7, 2026
      RegExp(
        '\\b$months\\s+\\d{1,2}(?:st|nd|rd|th)?[,]?\\s+20\\d{2}\\b',
        caseSensitive: false,
      ),

      // 7 August 2026
      RegExp(
        '\\b\\d{1,2}(?:st|nd|rd|th)?\\s+$months[,]?\\s+20\\d{2}\\b',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);

      if (match != null) {
        return match.group(0)?.trim();
      }
    }

    return null;
  }

  // =========================================================
  // MERCHANT MATCHING
  // =========================================================

  static _MerchantResult _matchMerchant({
    required String rawText,
    required List<String> lines,
    required List<String> aliases,
    required double threshold,
  }) {
    if (aliases.isEmpty) {
      return const _MerchantResult(matched: false, similarity: 0, alias: null);
    }

    final normalizedFullText = _normalizeMerchant(rawText);

    double bestSimilarity = 0;
    String? bestAlias;

    for (final alias in aliases) {
      final normalizedAlias = _normalizeMerchant(alias);

      if (normalizedAlias.isEmpty) continue;

      // Exact containment.
      if (normalizedFullText.contains(normalizedAlias)) {
        return _MerchantResult(matched: true, similarity: 1, alias: alias);
      }

      // Check OCR line similarity.
      for (final line in lines) {
        final normalizedLine = _normalizeMerchant(line);

        if (normalizedLine.isEmpty) continue;

        if (normalizedLine.contains(normalizedAlias) ||
            normalizedAlias.contains(normalizedLine)) {
          final similarity =
              math.min(normalizedAlias.length, normalizedLine.length) /
              math.max(normalizedAlias.length, normalizedLine.length);

          if (similarity > bestSimilarity) {
            bestSimilarity = similarity;
            bestAlias = alias;
          }
        }

        final lineSimilarity = _similarity(normalizedAlias, normalizedLine);

        if (lineSimilarity > bestSimilarity) {
          bestSimilarity = lineSimilarity;
          bestAlias = alias;
        }
      }

      // Sliding word comparison handles:
      //
      // Merchant expected:
      // "Yak Stack Solution"
      //
      // OCR:
      // "Paid to Yak Stak Solution Pvt Ltd"
      final receiptWords = normalizedFullText
          .split(' ')
          .where((word) => word.isNotEmpty)
          .toList();

      final aliasWords = normalizedAlias
          .split(' ')
          .where((word) => word.isNotEmpty)
          .toList();

      if (aliasWords.isNotEmpty) {
        final baseLength = aliasWords.length;

        for (final windowSize in {
          math.max(1, baseLength - 1),
          baseLength,
          baseLength + 1,
        }) {
          if (receiptWords.length < windowSize) continue;

          for (int i = 0; i <= receiptWords.length - windowSize; i++) {
            final candidate = receiptWords.sublist(i, i + windowSize).join(' ');

            final similarity = _similarity(normalizedAlias, candidate);

            if (similarity > bestSimilarity) {
              bestSimilarity = similarity;
              bestAlias = alias;
            }
          }
        }
      }
    }

    return _MerchantResult(
      matched: bestSimilarity >= threshold,
      similarity: bestSimilarity,
      alias: bestAlias,
    );
  }

  static String _normalizeMerchant(String value) {
    return value
        .toLowerCase()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // =========================================================
  // STRING SIMILARITY
  // =========================================================

  static double _similarity(String a, String b) {
    if (a == b) return 1;

    if (a.isEmpty || b.isEmpty) return 0;

    final distance = _levenshtein(a, b);

    final maxLength = math.max(a.length, b.length);

    if (maxLength == 0) {
      return 1;
    }

    return 1 - (distance / maxLength);
  }

  static int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var previous = List<int>.generate(b.length + 1, (index) => index);

    for (int i = 0; i < a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0);

      current[0] = i + 1;

      for (int j = 0; j < b.length; j++) {
        final insertion = current[j] + 1;
        final deletion = previous[j + 1] + 1;

        final substitution = previous[j] + (a[i] == b[j] ? 0 : 1);

        current[j + 1] = math.min(math.min(insertion, deletion), substitution);
      }

      previous = current;
    }

    return previous[b.length];
  }

  // =========================================================
  // IMAGE QUALITY
  // =========================================================

  static Future<_ImageQuality> _checkImageQuality(
    File file, {
    required int minimumWidth,
    required int minimumHeight,
    required int minimumFileBytes,
  }) async {
    final bytes = await file.readAsBytes();

    if (bytes.isEmpty) {
      return const _ImageQuality(
        width: 0,
        height: 0,
        fileBytes: 0,
        basicQualityPassed: false,
        probablyBlank: true,
        possiblyBlurry: true,
        brightnessStdDev: 0,
        edgeScore: 0,
      );
    }

    ui.Codec? codec;
    ui.Image? image;

    try {
      codec = await ui.instantiateImageCodec(bytes);

      final frame = await codec.getNextFrame();

      image = frame.image;

      final width = image.width;
      final height = image.height;

      final basicQuality =
          width >= minimumWidth &&
          height >= minimumHeight &&
          bytes.length >= minimumFileBytes;

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) {
        return _ImageQuality(
          width: width,
          height: height,
          fileBytes: bytes.length,
          basicQualityPassed: basicQuality,
          probablyBlank: false,
          possiblyBlurry: false,
          brightnessStdDev: 0,
          edgeScore: 0,
        );
      }

      final pixels = byteData.buffer.asUint8List();

      // Downsample analysis.
      // We don't need to inspect every pixel.
      final longestSide = math.max(width, height);

      final step = math.max(1, longestSide ~/ 250);

      double luminanceSum = 0;
      double luminanceSquareSum = 0;

      double edgeSum = 0;

      int samples = 0;
      int edgeSamples = 0;

      for (int y = 0; y < height; y += step) {
        for (int x = 0; x < width; x += step) {
          final index = ((y * width) + x) * 4;

          if (index + 2 >= pixels.length) {
            continue;
          }

          final luminance = _luminance(
            pixels[index],
            pixels[index + 1],
            pixels[index + 2],
          );

          luminanceSum += luminance;
          luminanceSquareSum += luminance * luminance;

          samples++;

          // Horizontal edge
          if (x + step < width) {
            final nextIndex = ((y * width) + (x + step)) * 4;

            if (nextIndex + 2 < pixels.length) {
              final nextLuminance = _luminance(
                pixels[nextIndex],
                pixels[nextIndex + 1],
                pixels[nextIndex + 2],
              );

              edgeSum += (luminance - nextLuminance).abs();

              edgeSamples++;
            }
          }

          // Vertical edge
          if (y + step < height) {
            final nextIndex = ((((y + step) * width) + x) * 4);

            if (nextIndex + 2 < pixels.length) {
              final nextLuminance = _luminance(
                pixels[nextIndex],
                pixels[nextIndex + 1],
                pixels[nextIndex + 2],
              );

              edgeSum += (luminance - nextLuminance).abs();

              edgeSamples++;
            }
          }
        }
      }

      if (samples == 0) {
        return _ImageQuality(
          width: width,
          height: height,
          fileBytes: bytes.length,
          basicQualityPassed: basicQuality,
          probablyBlank: false,
          possiblyBlurry: false,
          brightnessStdDev: 0,
          edgeScore: 0,
        );
      }

      final mean = luminanceSum / samples;

      final variance = math.max<double>(
        0,
        (luminanceSquareSum / samples) - (mean * mean),
      );

      final stdDev = math.sqrt(variance);

      final double edgeScore = edgeSamples == 0 ? 0 : edgeSum / edgeSamples;

      // Extremely low brightness variation usually means
      // empty / plain / unusable image.
      final probablyBlank = stdDev < 5;

      // Heuristic only.
      //
      // Do NOT use blur result alone because screenshots can have
      // large white areas.
      final possiblyBlurry = edgeScore < 2.0;

      return _ImageQuality(
        width: width,
        height: height,
        fileBytes: bytes.length,
        basicQualityPassed: basicQuality,
        probablyBlank: probablyBlank,
        possiblyBlurry: possiblyBlurry,
        brightnessStdDev: stdDev,
        edgeScore: edgeScore,
      );
    } catch (_) {
      return _ImageQuality(
        width: 0,
        height: 0,
        fileBytes: bytes.length,
        basicQualityPassed: false,
        probablyBlank: false,
        possiblyBlurry: false,
        brightnessStdDev: 0,
        edgeScore: 0,
      );
    } finally {
      image?.dispose();
      codec?.dispose();
    }
  }

  static double _luminance(int r, int g, int b) {
    return (0.299 * r) + (0.587 * g) + (0.114 * b);
  }

  // =========================================================
  // ERROR RESULT
  // =========================================================

  static ReceiptValidationResult _errorResult(String reason) {
    return ReceiptValidationResult(
      accepted: false,
      manualVerificationRequired: true,
      score: 0,
      reason: reason,

      imageQualityPassed: false,
      ocrReadable: false,
      merchantMatched: false,
      amountMatched: false,
      successStatusFound: false,
      transactionIdFound: false,
      dateFound: false,
      qrCodeFound: false,

      duplicateChecked: false,
      duplicateTransaction: false,

      transactionId: null,
      dateText: null,
      detectedAmount: null,
      matchedMerchant: null,
      merchantSimilarity: 0,

      qrValues: const [],

      rawText: '',

      imageWidth: 0,
      imageHeight: 0,
      imageBytes: 0,

      brightnessStdDev: 0,
      edgeScore: 0,
    );
  }
}

// ===========================================================
// INTERNAL MODELS
// ===========================================================

class _MerchantResult {
  final bool matched;
  final double similarity;
  final String? alias;

  const _MerchantResult({
    required this.matched,
    required this.similarity,
    required this.alias,
  });
}

class _PaymentStatusResult {
  final bool success;
  final bool negativeStatusFound;

  const _PaymentStatusResult({
    required this.success,
    required this.negativeStatusFound,
  });
}

class _ImageQuality {
  final int width;
  final int height;
  final int fileBytes;

  final bool basicQualityPassed;
  final bool probablyBlank;
  final bool possiblyBlurry;

  final double brightnessStdDev;
  final double edgeScore;

  const _ImageQuality({
    required this.width,
    required this.height,
    required this.fileBytes,
    required this.basicQualityPassed,
    required this.probablyBlank,
    required this.possiblyBlurry,
    required this.brightnessStdDev,
    required this.edgeScore,
  });
}
