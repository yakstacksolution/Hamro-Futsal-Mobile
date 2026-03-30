import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/profile/data/data_source/profile_data_source.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/domain/repository/profile_repository.dart';

final class ProfileRepositoryImpl extends ProfileRepository {
  ProfileRepositoryImpl({ProfileRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ProfileDataSourceImpl();

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, ProfileModel>> getProfile() async {
    final response = await _remoteDataSource.getProfile();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    final dynamic payload = response.getValue();
    final Map<String, dynamic> data = _extractResponseData(payload);
    return right(ProfileModel.fromJson(data));
  }

  Map<String, dynamic> _extractResponseData(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    if (payload is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
      return map;
    }

    throw DefaultException(
      errorMessage: 'Invalid profile response from server.',
      statusCode: 0,
    );
  }
}
