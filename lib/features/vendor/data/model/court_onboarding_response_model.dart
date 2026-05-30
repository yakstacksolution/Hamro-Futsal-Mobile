import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

final class CourtOnboardingResponseModel {
  const CourtOnboardingResponseModel({
    this.id,
    this.venueId,
    this.courtTypeId,
    this.matchFormatId,
    this.mainStep = 0,
    this.subStep = 0,
    this.name = '',
    this.basePrice,
    this.description = '',
    this.capacity,
    this.advancePaymentRequired,
    this.advancePaymentType,
    this.advancePrice,
    this.paymentQrId,
  });

  final int? id;
  final int? venueId;
  final int? courtTypeId;
  final int? matchFormatId;
  final int mainStep;
  final int subStep;
  final String name;
  final double? basePrice;
  final String description;
  final int? capacity;
  final bool? advancePaymentRequired;
  final AdvancePaymentType? advancePaymentType;
  final double? advancePrice;
  final int? paymentQrId;

  factory CourtOnboardingResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    return CourtOnboardingResponseModel(
      id: _asInt(data['id'] ?? data['court_id']),
      venueId: _asInt(data['venue_id']),
      courtTypeId: _asInt(data['court_type_id'] ?? data['court_type']),
      matchFormatId: _asInt(data['match_format_id'] ?? data['match_format']),
      mainStep: _asInt(data['main_step']) ?? 0,
      subStep: _asInt(data['sub_step']) ?? 0,
      name: _asTrimmedString(data['name'] ?? data['court_name']),
      basePrice: _asDouble(data['base_price']),
      description: _asTrimmedString(data['description']),
      capacity: _asInt(data['capacity'] ?? data['max_player']),
      advancePaymentRequired: _asBool(data['advance_payment_required']),
      advancePaymentType: AdvancePaymentType.fromString(
        data['advance_payment_type']?.toString(),
      ),
      advancePrice: _asDouble(data['advance_price']),
      paymentQrId: _asInt(data['payment_qr_id']),
    );
  }

  CourtDraft mergeInto(CourtDraft draft) {
    return draft.copyWith(
      remoteId: id,
      name: name.isEmpty ? draft.name : name,
      basePrice: basePrice,
      description: description.isEmpty ? draft.description : description,
      courtTypeId: courtTypeId,
      matchFormatId: matchFormatId,
      maxPlayers: capacity,
      advancePaymentRequired: advancePaymentRequired,
      advancePaymentType: advancePaymentType,
      advancePrice: advancePrice,
      paymentQr: paymentQrId == null
          ? draft.paymentQr
          : UploadRef(
              id: paymentQrId,
              name: draft.paymentQr?.name ?? '',
              remoteUrl: draft.paymentQr?.remoteUrl,
            ),
    );
  }
}

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

bool? _asBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return null;
}

String _asTrimmedString(Object? value) {
  if (value == null) return '';
  return value.toString().trim();
}
