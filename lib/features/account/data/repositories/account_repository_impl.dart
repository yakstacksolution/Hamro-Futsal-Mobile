import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/account/data/data_source/account_remote_data_source.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';
import 'package:hamro_footsall/features/account/domain/repository/account_repository.dart';

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
    required String paymentProofPath,
    int? venueId,
    String? note,
  }) async {
    final response = await _remoteDataSource.createSettlement({
      // Sent as a decimal string so paisa survive — `exact_amount_required`
      // makes a rounded figure a rejected request.
      'amount': amount == amount.roundToDouble()
          ? amount.toStringAsFixed(0)
          : amount.toStringAsFixed(2),
      'transaction_reference': transactionReference,
      'payment_proof_path': paymentProofPath,
      if (venueId != null) 'venue_id': venueId,
      if (note != null && note.isNotEmpty) 'note': note,
    });
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
