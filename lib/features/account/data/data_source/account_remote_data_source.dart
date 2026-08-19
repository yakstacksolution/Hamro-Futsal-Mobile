import 'package:dio/dio.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class AccountRemoteDataSource {
  Future<Result> getSettlementAccount();
  Future<Result> getSettlementBreakdown();
  Future<Result> getSettlementPreview({int? venueId});
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
  Future<Result> getSettlementPreview({int? venueId}) async =>
      await Client.instance().getAuthManager().getSettlementPreview(
        venueId: venueId,
      );

  @override
  Future<Result> getSettlements({Map<String, dynamic>? query}) async =>
      await Client.instance().getAuthManager().getSettlements(query: query);

  @override
  Future<Result> createSettlement(Map<String, dynamic> data) async {
    final fields = Map<String, dynamic>.from(data);
    final proofPath = fields.remove('payment_proof_path')?.toString() ?? '';
    if (proofPath.isNotEmpty) {
      fields['payment_proof'] = await MultipartFile.fromFile(
        proofPath,
        filename: proofPath.split('/').last,
      );
    }
    return await Client.instance().getAuthManager().createSettlement(
      FormData.fromMap(fields),
    );
  }
}
