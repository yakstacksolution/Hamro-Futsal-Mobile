import 'package:flutter_dotenv/flutter_dotenv.dart';

const int kVenueListPerPage = 15;

const int kVenueLinkLookupPerPage = 20;

class APIEndpoint {
  static String _read(String key) =>
      dotenv.isInitialized ? (dotenv.maybeGet(key) ?? '') : '';

  static final String _appUrl = _read('API_URL');
  static final String _chatUrl = _read('CHAT_URL');
  static final String _chatXORKey = _read('CHAT_X_ORIGIN');

  static String get baseUrl => _appUrl;

  static String get chatUrl => _chatUrl;

  static String get chatXORKey => _chatXORKey;
}
