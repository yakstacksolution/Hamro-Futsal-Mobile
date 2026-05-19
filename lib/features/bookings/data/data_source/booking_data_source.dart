import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class BookingRemoteDataSource {
  Future<Result> getMyBookings();
  Future<Result> getFutsalBookings();
}

final class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  @override
  Future<Result> getMyBookings() async =>
      await Client.instance().getAuthManager().getMyBookings();

  @override
  Future<Result> getFutsalBookings() async =>
      await Client.instance().getAuthManager().getFutsalBookings();
}
