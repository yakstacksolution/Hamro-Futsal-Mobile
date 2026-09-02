import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/payment_qr_model.dart';
import 'package:hamro_futsal/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class GetCourtPaymentQrUseCase {
  const GetCourtPaymentQrUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, PaymentQrModel>> call({
    required int courtId,
  }) async => await repository.getCourtPaymentQr(courtId: courtId);
}
