import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';

abstract class BookingOverviewDataSource {
  Future<Result> fetchBookingOverview({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  });

  Future<Result> exportBookingsOverView({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  });
}

Map<String, dynamic>? bookingOverviewQuery({
  String? dateFilter,
  String? dateFrom,
  String? dateTo,
  List<String>? venueIds,
}) {
  final query = <String, dynamic>{
    if (dateFilter != null && dateFilter.trim().isNotEmpty)
      'date_filter': dateFilter,
    if (dateFrom != null && dateFrom.trim().isNotEmpty) 'date_from': dateFrom,
    if (dateTo != null && dateTo.trim().isNotEmpty) 'date_to': dateTo,
    if (venueIds != null && venueIds.isNotEmpty) 'venue_ids': venueIds,
  };
  return query.isEmpty ? null : query;
}

final class BookingOverviewRemoteDataSourceImpl
    implements BookingOverviewDataSource {
  @override
  Future<Result> fetchBookingOverview({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  }) async {
    return await Client.instance().getAuthManager().getBookingOverview(
      query: bookingOverviewQuery(
        dateFilter: dateFilter,
        dateFrom: dateFrom,
        dateTo: dateTo,
        venueIds: venueIds,
      ),
    );
  }

  @override
  Future<Result> exportBookingsOverView({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  }) async {
    return await Client.instance().getAuthManager().exportBookingsOverView(
      query: bookingOverviewQuery(
        dateFilter: dateFilter,
        dateFrom: dateFrom,
        dateTo: dateTo,
        venueIds: venueIds,
      ),
    );
  }
}
