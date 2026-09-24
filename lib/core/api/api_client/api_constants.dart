import 'package:hamro_futsal/core/config/app_environment.dart';

const int kVenueListPerPage = 15;

const int kVenueLinkLookupPerPage = 20;

class APIEndpoint {
  static String get baseUrl => AppEnvironment.read('API_URL');

  static String get secureApiToken => AppEnvironment.read('SECURE_API_TOKEN');

  static const String secureApiTokenHeader = 'X-API-TOKEN';
}
