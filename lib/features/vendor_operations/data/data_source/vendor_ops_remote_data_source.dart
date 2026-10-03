import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';

abstract class VendorOpsRemoteDataSource {
  /// `GET /court-availability-slots?venue_id=&court_id=&start_date=&type=week`.
  /// Week calls also include `end_date`.
  Future<Result> getCourtAvailabilitySlots({
    int? venueId,
    int? courtId,
    required String startDate,
    String? endDate,
    String type = 'week',
  });
}

final class VendorOpsRemoteDataSourceImpl implements VendorOpsRemoteDataSource {
  const VendorOpsRemoteDataSourceImpl();

  @override
  Future<Result> getCourtAvailabilitySlots({
    int? venueId,
    int? courtId,
    required String startDate,
    String? endDate,
    String type = 'week',
  }) async =>
      await Client.instance().getAuthManager().getCourtAvailabilitySlots(
        venueId: venueId,
        courtId: courtId,
        startDate: startDate,
        endDate: endDate,
        type: type,
      );
}
