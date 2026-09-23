import 'package:hamro_futsal/core/config/app_environment.dart';

const int kVenueListPerPage = 15;

const int kVenueLinkLookupPerPage = 20;

/// Every value here comes from the env file the flavour in `main.dart` selects
/// (`env_staging.env` / `env_production.env`), loaded by
/// [AppEnvironment.load] before `runApp`. Nothing is hard-coded, so no build
/// can silently talk to the wrong backend.
///
/// These are getters rather than `static final` fields on purpose: a field
/// touched before the env file loads would pin an empty value for the rest of
/// the process.
class APIEndpoint {
  static String get baseUrl => AppEnvironment.read('API_URL');

  /// Value for the [secureApiTokenHeader] header. Read it from here everywhere
  /// it is needed — it differs per flavour.
  static String get secureApiToken => AppEnvironment.read('SECURE_API_TOKEN');

  static const String secureApiTokenHeader = 'X-API-TOKEN';
}
