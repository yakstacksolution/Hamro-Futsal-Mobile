import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';

abstract class AccountRepository {
  Future<Either<AppException, AccountSummaryModel>> getSettlementAccount();
  Future<Either<AppException, SettlementBreakdownModel>>
  getSettlementBreakdown();
  Future<Either<AppException, SettlementPreviewModel>> getSettlementPreview({
    int? venueId,
  });

  /// One page of the settlement history, with the server's status summary.
  Future<Either<AppException, SettlementPageModel>> getSettlements({
    int perPage = 20,
    int page = 1,
  });
  Future<Either<AppException, SettlementModel>> createSettlement({
    required double amount,
    required String transactionReference,
    required String paymentProofPath,
    int? venueId,
    String? note,
  });
}
