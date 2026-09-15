import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/api/api_client/api_call_wrapper.dart';
import 'package:hamro_futsal/core/api/api_client/ihttp.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';

/// Group info edits its name and its picture through one endpoint:
/// `POST /conversations/{id}/update`, with `title` and `image_id`.
///
/// The picture comes from the app's media library, so `image_id` is the id of
/// an image the library already holds — the library owns uploading.
void main() {
  group('the group picture, however the server spells it', () {
    ConversationModel parse(Map<String, dynamic> extra) =>
        ConversationModel.fromJson(<String, dynamic>{
          'id': 91,
          'type': 'group',
          'title': 'Futsal crew',
          ...extra,
        });

    test('a media object', () {
      expect(
        parse(<String, dynamic>{
          'media': <String, dynamic>{'id': 5, 'url': 'https://x.test/g.jpg'},
        }).imageUrl,
        'https://x.test/g.jpg',
      );
    });

    test('a bare url', () {
      expect(
        parse(<String, dynamic>{'media': 'https://x.test/g.jpg'}).imageUrl,
        'https://x.test/g.jpg',
      );
    });

    test('a list of media takes the first', () {
      expect(
        parse(<String, dynamic>{
          'media': <Map<String, dynamic>>[
            <String, dynamic>{'url': 'https://x.test/one.jpg'},
            <String, dynamic>{'url': 'https://x.test/two.jpg'},
          ],
        }).imageUrl,
        'https://x.test/one.jpg',
      );
    });

    test('the other names this API uses for the same thing', () {
      for (final String key in <String>['image', 'avatar', 'image_url']) {
        expect(
          parse(<String, dynamic>{key: 'https://x.test/g.jpg'}).imageUrl,
          'https://x.test/g.jpg',
          reason: key,
        );
      }
    });

    test('a group with no picture reports none', () {
      expect(parse(const <String, dynamic>{}).imageUrl, isEmpty);
      expect(parse(<String, dynamic>{'media': null}).imageUrl, isEmpty);
    });
  });

  group('the request', () {
    test('a name-only edit sends just the title', () async {
      final _RecordingHttp http = _RecordingHttp();
      final ApiCallWrapper wrapper = ApiCallWrapper.withHttp(http);

      await wrapper.makeRequest(
        url: 'https://example.test/conversations/91/update',
        method: HttpVerb.post,
        data: <String, dynamic>{'title': 'Futsal crew'},
      );

      expect(http.lastUrl, endsWith('/conversations/91/update'));
      final Map<String, dynamic> body = http.lastData as Map<String, dynamic>;
      expect(body['title'], 'Futsal crew');
      expect(body.containsKey('image_id'), isFalse);
    });

    test('a picture is sent as its media library id', () async {
      final _RecordingHttp http = _RecordingHttp();
      final ApiCallWrapper wrapper = ApiCallWrapper.withHttp(http);

      await wrapper.makeRequest(
        url: 'https://example.test/conversations/91/update',
        method: HttpVerb.post,
        data: <String, dynamic>{'image_id': 412},
      );

      final Map<String, dynamic> body = http.lastData as Map<String, dynamic>;
      // The library already holds the file; this only points at it.
      expect(body['image_id'], 412);
      expect(body.containsKey('title'), isFalse);
    });

    test('both together', () async {
      final _RecordingHttp http = _RecordingHttp();
      final ApiCallWrapper wrapper = ApiCallWrapper.withHttp(http);

      await wrapper.makeRequest(
        url: 'https://example.test/conversations/91/update',
        method: HttpVerb.post,
        data: <String, dynamic>{'title': 'Futsal crew', 'image_id': 412},
      );

      final Map<String, dynamic> body = http.lastData as Map<String, dynamic>;
      expect(body['title'], 'Futsal crew');
      expect(body['image_id'], 412);
    });
  });

  test('a picked picture shows before the server echoes it', () {
    final ConversationModel group = ConversationModel.fromJson(
      <String, dynamic>{'id': 91, 'type': 'group', 'title': 'Futsal crew'},
    );
    expect(group.imageUrl, isEmpty);

    // What the bloc applies while the request is in flight.
    final ConversationModel patched = group.copyWith(
      imageUrl: 'https://x.test/picked.jpg',
    );
    expect(patched.imageUrl, 'https://x.test/picked.jpg');
    expect(patched.title, 'Futsal crew');
  });
}

final class _RecordingHttp implements IHttp {
  String? lastUrl;
  dynamic lastData;

  Future<dynamic> _record(String? url, dynamic data) async {
    lastUrl = url;
    lastData = data;
    return Response<dynamic>(
      requestOptions: RequestOptions(path: url ?? ''),
      statusCode: 200,
      data: <String, dynamic>{'data': <String, dynamic>{}},
    );
  }

  @override
  Future<dynamic> post({
    String? url,
    String? token,
    dynamic data,
    Map<dynamic, dynamic>? query,
  }) => _record(url, data);

  @override
  Future<dynamic> get({
    String? url,
    String? token,
    Map<dynamic, dynamic>? query,
    dynamic data,
  }) => _record(url, data);

  @override
  Future<dynamic> put({
    String? url,
    String? token,
    dynamic data,
    Map<dynamic, dynamic>? query,
  }) => _record(url, data);

  @override
  Future<dynamic> patch({
    String? url,
    String? token,
    dynamic data,
    Map<dynamic, dynamic>? query,
  }) => _record(url, data);

  @override
  Future<dynamic> delete({String? url, String? token, dynamic data}) =>
      _record(url, data);
}
