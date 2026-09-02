import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/api/api_client/api_call_wrapper.dart';
import 'package:hamro_futsal/core/api/api_client/api_client.dart';
import 'package:hamro_futsal/core/api/api_client/booking_type_payload.dart';
import 'package:hamro_futsal/core/api/api_client/ihttp.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';

/// Captures what the transport is handed, so the GET body is verified end to
/// end through ApiClient → ApiCallWrapper → IHttp.
final class _RecordingHttp extends IHttp {
  String? url;
  Map<dynamic, dynamic>? query;
  dynamic data;

  @override
  get({String? url, String? token, Map? query, dynamic data}) async {
    this.url = url;
    this.query = query;
    this.data = data;
    return _FakeResponse();
  }
}

final class _FakeResponse {
  final Map<String, dynamic> data = <String, dynamic>{
    'status': 'success',
    'data': <String, dynamic>{},
  };
}

/// In-memory [Preferences] so `AppSettings().tokenModel` (read on every request
/// to attach the bearer token) works without shared_preferences plugins.
final class _MemoryPreferences implements Preferences {
  final Map<String, Object> _values = <String, Object>{};

  @override
  String? getString(String key) => _values[key] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _values[key] as bool?;
  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  double? getDouble(String key) => _values[key] as double?;
  @override
  Future<bool> setDouble(String key, double value) async {
    _values[key] = value;
    return true;
  }

  @override
  List<String> getStringList(String key) =>
      (_values[key] as List<String>?) ?? <String>[];
  @override
  Future<bool> setStringList(String key, List<String> permissions) async {
    _values[key] = permissions;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late _RecordingHttp http;
  late ApiClient client;

  setUpAll(() async {
    await AppSettings().init(_MemoryPreferences());
  });

  setUp(() {
    http = _RecordingHttp();
    client = ApiClient(
      apiCallWrapper: ApiCallWrapper.withHttp(http),
      baseUrl: 'https://example.test/api',
    );
  });

  test('sends booking_type in the body and filters in the query', () async {
    await client.getAvailableCourts(
      venueId: 2,
      selectDate: '2026-07-28',
      bookingType: BookingTypePayload.manual,
    );

    expect(http.url, 'https://example.test/api/available-courts');
    expect(http.query, <String, dynamic>{
      'venue_id': 2,
      'select_date': '2026-07-28',
    });
    expect(http.data, <String, dynamic>{'booking_type': 'manual'});
  });

  test('defaults to regular when the caller does not say', () async {
    await client.getAvailableCourts(venueId: 2, selectDate: '2026-07-28');

    expect(http.data, <String, dynamic>{'booking_type': 'regular'});
  });

  test(
    'keeps sending the optional slot-time filters as query params',
    () async {
      await client.getAvailableCourts(
        venueId: 2,
        selectDate: '2026-07-28',
        slotStartTime: '06:00:00',
        slotEndTime: '07:00:00',
        bookingType: BookingTypePayload.manual,
      );

      expect(http.query, <String, dynamic>{
        'venue_id': 2,
        'select_date': '2026-07-28',
        'slot_start_time': '06:00:00',
        'slot_end_time': '07:00:00',
      });
      expect(http.data, <String, dynamic>{'booking_type': 'manual'});
    },
  );

  test('BookingTypePayload.of maps the flow to the API value', () {
    expect(BookingTypePayload.of(isManual: true), 'manual');
    expect(BookingTypePayload.of(isManual: false), 'regular');
  });
}
