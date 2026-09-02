import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/utils/upload_attachment.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';

abstract class AccountRepository {
  Future<Either<AppException, AccountSummaryModel>> getSettlementAccount();
  Future<Either<AppException, SettlementBreakdownModel>>
  getSettlementBreakdown();

  /// Payment QRs the commission may be sent to.
  Future<Either<AppException, List<SettlementQrCodeModel>>> getQrCodes();

  Future<Either<AppException, SettlementPreviewModel>> getSettlementPreview({
    int? venueId,
  });

  /// One page of the account ledger.
  Future<Either<AppException, AccountActivityPageModel>> getRecentActivity({
    int perPage,
    int page,
  });

  /// One page of the settlement history, with the server's status summary.
  Future<Either<AppException, SettlementPageModel>> getSettlements({
    int perPage = 20,
    int page = 1,
  });
  Future<Either<AppException, SettlementModel>> createSettlement({
    required double amount,
    required String transactionReference,
    required UploadAttachment paymentProof,
    int? venueId,
    String? note,
  });
}
