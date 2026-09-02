import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/utils/upload_attachment.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/account/domain/repository/account_repository.dart';

final class AccountUseCase {
  const AccountUseCase(this.repository);

  final AccountRepository repository;

  Future<Either<AppException, AccountSummaryModel>>
  getSettlementAccount() async => await repository.getSettlementAccount();

  Future<Either<AppException, SettlementBreakdownModel>>
  getSettlementBreakdown() async => await repository.getSettlementBreakdown();

  Future<Either<AppException, List<SettlementQrCodeModel>>>
  getQrCodes() async => await repository.getQrCodes();

  Future<Either<AppException, SettlementPreviewModel>> getSettlementPreview({
    int? venueId,
  }) async => await repository.getSettlementPreview(venueId: venueId);

  Future<Either<AppException, AccountActivityPageModel>> getRecentActivity({
    int perPage = 10,
    int page = 1,
  }) async => await repository.getRecentActivity(perPage: perPage, page: page);

  Future<Either<AppException, SettlementPageModel>> getSettlements({
    int perPage = 20,
    int page = 1,
  }) async => await repository.getSettlements(perPage: perPage, page: page);

  Future<Either<AppException, SettlementModel>> createSettlement({
    required double amount,
    required String transactionReference,
    required UploadAttachment paymentProof,
    int? venueId,
    String? note,
  }) async => await repository.createSettlement(
    amount: amount,
    transactionReference: transactionReference,
    paymentProof: paymentProof,
    venueId: venueId,
    note: note,
  );
}
