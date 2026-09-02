import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/utils/upload_attachment.dart';
import 'package:hamro_futsal/features/account/data/data_source/account_remote_data_source.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/account/domain/repository/account_repository.dart';

final class AccountRepositoryImpl extends AccountRepository {
  AccountRepositoryImpl({AccountRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AccountRemoteDataSourceImpl();

  final AccountRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, AccountSummaryModel>>
  getSettlementAccount() async {
    final response = await _remoteDataSource.getSettlementAccount();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(AccountSummaryModel.fromJson(_unwrap(response.getValue())));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseAccountFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, SettlementBreakdownModel>>
  getSettlementBreakdown() async {
    final response = await _remoteDataSource.getSettlementBreakdown();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final breakdown = SettlementBreakdownModel.fromResponse(
        response.getValue(),
      );
      final entries = breakdown.entries.toList()..sort(_byNewest);
      return right(
        SettlementBreakdownModel(venues: breakdown.venues, entries: entries),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseAccountFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<SettlementQrCodeModel>>> getQrCodes() async {
    final response = await _remoteDataSource.getQrCodes();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(SettlementQrCodeModel.listFromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParsePaymentQrFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, SettlementPreviewModel>> getSettlementPreview({
    int? venueId,
  }) async {
    final response = await _remoteDataSource.getSettlementPreview(
      venueId: venueId,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(SettlementPreviewModel.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseAccountFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, AccountActivityPageModel>> getRecentActivity({
    int perPage = 10,
    int page = 1,
  }) async {
    final response = await _remoteDataSource.getSettlementRecentActivity(
      query: <String, dynamic>{'page': page, 'per_page': perPage},
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(
        AccountActivityPageModel.fromResponse(
          response.getValue(),
          requestedPage: page,
          requestedPerPage: perPage,
        ),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseAccountFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, SettlementPageModel>> getSettlements({
    int perPage = 20,
    int page = 1,
  }) async {
    final response = await _remoteDataSource.getSettlements(
      query: <String, dynamic>{'per_page': perPage, 'page': page},
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(
        SettlementPageModel.fromResponse(
          response.getValue(),
          requestedPage: page,
          requestedPerPage: perPage,
        ),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseAccountFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, SettlementModel>> createSettlement({
    required double amount,
    required String transactionReference,
    required UploadAttachment paymentProof,
    int? venueId,
    String? note,
  }) async {
    final response = await _remoteDataSource.createSettlement(
      buildSettlementFields(
        amount: amount,
        transactionReference: transactionReference,
        paymentProof: paymentProof,
        venueId: venueId,
        note: note,
      ),
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(SettlementModel.fromJson(_unwrap(response.getValue())));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotSubmitSettlementRequest,
          statusCode: 0,
        ),
      );
    }
  }

  int _byNewest(AccountEntryModel a, AccountEntryModel b) =>
      (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0));

  Map<String, dynamic> _unwrap(dynamic payload) {
    if (payload is! Map) return const {};
    for (final key in const ['data', 'account', 'summary', 'settlement']) {
      final child = payload[key];
      if (child is Map) return _unwrap(child);
    }
    return Map<String, dynamic>.from(payload);
  }
}

/// The multipart body for `POST /auth/settlements`.
///
/// Two shapes, one builder — the only difference between them is `venue_id`:
///
/// * **Consolidated** (all futsals): `amount`, `transaction_reference`,
///   `note`, `payment_proof`.
/// * **Per-futsal**: the same, plus `venue_id`.
///
/// Sending `venue_id: null` would be a third, wrong shape, so the key is
/// omitted entirely rather than sent empty. The internal attachment is swapped
/// for the uploaded `payment_proof` part by the data source.
@visibleForTesting
Map<String, dynamic> buildSettlementFields({
  required double amount,
  required String transactionReference,
  required UploadAttachment paymentProof,
  int? venueId,
  String? note,
}) {
  return <String, dynamic>{
    // Sent as a decimal string so paisa survive — `exact_amount_required`
    // makes a rounded figure a rejected request.
    'amount': amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2),
    'transaction_reference': transactionReference.trim(),
    'payment_proof_attachment': paymentProof,
    if (venueId != null) 'venue_id': venueId,
    if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
  };
}
