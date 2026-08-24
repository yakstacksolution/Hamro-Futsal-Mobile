import 'package:dio/dio.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';
import 'package:hamro_footsall/core/utils/upload_part.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class AccountRemoteDataSource {
  Future<Result> getSettlementAccount();
  Future<Result> getSettlementBreakdown();
  Future<Result> getQrCodes();
  Future<Result> getSettlementPreview({int? venueId});
  Future<Result> getSettlementRecentActivity({Map<String, dynamic>? query});
  Future<Result> getSettlements({Map<String, dynamic>? query});
  Future<Result> createSettlement(Map<String, dynamic> data);
}

final class AccountRemoteDataSourceImpl extends AccountRemoteDataSource {
  @override
  Future<Result> getSettlementAccount() async =>
      await Client.instance().getAuthManager().getSettlementAccount();

  @override
  Future<Result> getSettlementBreakdown() async =>
      await Client.instance().getAuthManager().getSettlementBreakdown();

  @override
  Future<Result> getQrCodes() async =>
      await Client.instance().getAuthManager().getQrCodes();

  @override
  Future<Result> getSettlementPreview({int? venueId}) async =>
      await Client.instance().getAuthManager().getSettlementPreview(
        venueId: venueId,
      );

  @override
  Future<Result> getSettlementRecentActivity({
    Map<String, dynamic>? query,
  }) async => await Client.instance()
      .getAuthManager()
      .getSettlementRecentActivity(query: query);

  @override
  Future<Result> getSettlements({Map<String, dynamic>? query}) async =>
      await Client.instance().getAuthManager().getSettlements(query: query);

  @override
  Future<Result> createSettlement(Map<String, dynamic> data) async {
    final fields = Map<String, dynamic>.from(data);
    final UploadAttachment? attachment =
        fields.remove('payment_proof_attachment') as UploadAttachment?;

    try {
      if (attachment != null) {
        fields['payment_proof'] = buildUploadPart(attachment);
      }
    } on UploadValidationException catch (error) {
      return Result.error(DataError(error.message, 0, null));
    }

    return await Client.instance().getAuthManager().createSettlement(
      FormData.fromMap(fields),
    );
  }
}
