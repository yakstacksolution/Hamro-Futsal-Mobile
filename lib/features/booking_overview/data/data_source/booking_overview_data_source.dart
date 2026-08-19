import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class BookingOverviewDataSource {
  /// Fetches the booking-overview payload. Every filter argument is optional —
  /// pass none to let the server apply its default window.
  Future<Result> fetchBookingOverview({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  });
}

/// API-backed data source hitting `GET /booking-overview`.
final class BookingOverviewRemoteDataSourceImpl
    implements BookingOverviewDataSource {
  @override
  Future<Result> fetchBookingOverview({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  }) async {
    final query = <String, dynamic>{
      if (dateFilter != null && dateFilter.trim().isNotEmpty)
        'date_filter': dateFilter,
      if (dateFrom != null && dateFrom.trim().isNotEmpty) 'date_from': dateFrom,
      if (dateTo != null && dateTo.trim().isNotEmpty) 'date_to': dateTo,
      if (venueIds != null && venueIds.isNotEmpty) 'venue_ids': venueIds,
    };
    return await Client.instance().getAuthManager().getBookingOverview(
      query: query.isEmpty ? null : query,
    );
  }
}
