import 'dart:async';
import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/service/chat_socket_service.dart';

/// Realtime chat backed by **Laravel Reverb** (Pusher protocol) via
/// `dart_pusher_channels` — a pure-Dart client that, unlike the native Pusher
/// SDK, can point at a self-hosted host/port (which Reverb needs).
///
/// One connection is shared for the whole app session (singleton); [dispose]
/// is intentionally a no-op so a closing [MessageBloc] doesn't tear the socket
/// down for others. Private channels are signed against Laravel's broadcasting
/// auth endpoint with the signed-in user's bearer token.
///
/// ─────────────────────────────────────────────────────────────────────────
/// BACKEND CONFIG — set in `.env` (from the server's Reverb config). Each value
/// has a Laravel-default fallback; override per environment:
///
///   REVERB_APP_KEY       = your REVERB_APP_KEY              (required)
///   REVERB_HOST          = ws host, e.g. hamrofutsal.com    (required)
///   REVERB_PORT          = 443           (wss port in prod; 8080 for local)
///   REVERB_SCHEME        = https         (https → wss/TLS)
///   REVERB_AUTH_URL      = https://hamrofutsal.com/broadcasting/auth
///   REVERB_MESSAGE_EVENT = message.sent  (event name carrying a message)
///   REVERB_TYPING_EVENT  = typing        (typing-state event)
///
/// Channel naming follows Laravel Echo conventions (see [_conversationChannel]
/// / [_userChannel]); adjust those builders if your backend differs.
/// ─────────────────────────────────────────────────────────────────────────
final class ReverbChatSocketService implements ChatSocketService {
  ReverbChatSocketService._();

  static final ReverbChatSocketService instance = ReverbChatSocketService._();

  // ── Tunable backend conventions (env-overridable) ────────────────────────
  static String get _appKey => dotenv.env['REVERB_APP_KEY'] ?? '';
  static String get _host => dotenv.env['REVERB_HOST'] ?? '';
  static int get _port => int.tryParse(dotenv.env['REVERB_PORT'] ?? '') ?? 443;
  static String get _scheme =>
      (dotenv.env['REVERB_SCHEME'] ?? 'https').toLowerCase() == 'http'
      ? 'ws'
      : 'wss';
  static String get _authUrl =>
      dotenv.env['REVERB_AUTH_URL'] ??
      '${APIEndpoint.baseUrl}/broadcasting/auth';
  static String get _messageEvent =>
      dotenv.env['REVERB_MESSAGE_EVENT'] ?? 'message.sent';
  static String get _typingEvent =>
      dotenv.env['REVERB_TYPING_EVENT'] ?? 'typing';

  /// Laravel Echo private channel for a single conversation.
  static String _conversationChannel(int id) => 'private-conversation.$id';

  /// Per-user "inbox" channel — new messages across all of the signed-in
  /// user's conversations. Laravel notifications default to
  /// `private-App.Models.User.{id}`; adjust if your broadcast uses another.
  static String _userChannel(int userId) => 'private-user.$userId';
  // ──────────────────────────────────────────────────────────────────────────

  PusherChannelsClient? _client;
  bool _initialised = false;

  /// Registered channels (kept so we can (re)subscribe on every (re)connect).
  final Map<String, PrivateChannel> _channels = {};

  /// Broadcast controllers keyed by conversation id / "inbox".
  final Map<int, StreamController<ChatMessageModel>> _messageControllers = {};
  final Map<int, StreamController<bool>> _typingControllers = {};
  StreamController<ChatMessageModel>? _inboxController;

  // ── Connection lifecycle ──────────────────────────────────────────────────

  void _ensureConnected() {
    if (_initialised) return;
    _initialised = true;

    if (_appKey.isEmpty || _host.isEmpty) {
      debugPrint(
        'ReverbChatSocketService: REVERB_APP_KEY/REVERB_HOST missing — '
        'realtime disabled. Set them in .env.',
      );
      return;
    }

    final client = PusherChannelsClient.websocket(
      options: PusherChannelsOptions.fromHost(
        scheme: _scheme,
        host: _host,
        port: _port,
        key: _appKey,
      ),
      connectionErrorHandler: (exception, trace, refresh) {
        debugPrint('Reverb connection error: $exception');
        refresh();
      },
    );
    _client = client;

    // (Re)subscribe every registered channel whenever the connection is
    // (re)established — this also covers automatic reconnects.
    client.onConnectionEstablished.listen((_) {
      for (final channel in _channels.values) {
        channel.subscribeIfNotUnsubscribed();
      }
    });

    client.connect();
  }

  /// HTTP token auth delegate that signs private-channel subscriptions against
  /// Laravel's `/broadcasting/auth`, carrying the current bearer token.
  EndpointAuthorizableChannelTokenAuthorizationDelegate<
    PrivateChannelAuthorizationData
  >
  _authDelegate() {
    final String? token = AppSettings().tokenModel.accessToken;
    return EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
      authorizationEndpoint: Uri.parse(_authUrl),
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Creates (once) the private channel for [name] and wires its message/typing
  /// events into the matching controllers. No-op when realtime is disabled
  /// (missing env) or the channel already exists — callers read the controller
  /// streams regardless, which simply stay silent until events arrive.
  void _ensureChannel(String name, {int? conversationId}) {
    _ensureConnected();
    final client = _client;
    if (client == null || _channels.containsKey(name)) return;

    final channel = client.privateChannel(
      name,
      authorizationDelegate: _authDelegate(),
    );
    _channels[name] = channel;

    // Bind to all events on the channel and route by event name — tolerant of
    // Laravel's optional leading-dot (`.message.sent`) on broadcastAs names.
    channel.bindToAll().listen((event) => _route(event, conversationId));

    // Subscribe now if already connected; otherwise onConnectionEstablished
    // will (it also handles reconnects).
    channel.subscribeIfNotUnsubscribed();
  }

  void _route(PusherChannelsReadEvent event, int? conversationId) {
    final String name = event.name;
    if (name.startsWith('pusher:') || name.startsWith('pusher_internal:')) {
      return;
    }

    final Map<String, dynamic>? payload = _decode(event.data);
    if (payload == null) return;

    if (_matches(name, _messageEvent)) {
      final message = _parseMessage(payload);
      if (message == null) return;
      _inboxController?.add(message);
      _messageControllers[message.conversationId]?.add(message);
    } else if (_matches(name, _typingEvent)) {
      final convId =
          conversationId ??
          int.tryParse(
            (payload['conversation_id'] ?? payload['conversationId'])
                    ?.toString() ??
                '',
          );
      if (convId == null) return;
      final bool isTyping =
          payload['is_typing'] == true ||
          payload['typing'] == true ||
          payload['is_typing']?.toString() == 'true';
      _typingControllers[convId]?.add(isTyping);
    }
  }

  bool _matches(String eventName, String configured) =>
      eventName == configured || eventName == '.$configured';

  Map<String, dynamic>? _decode(dynamic data) {
    try {
      final decoded = data is String ? jsonDecode(data) : data;
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  /// Broadcast payloads wrap the message under `message`/`data`, or send the
  /// MessageResource at the root — tolerate all three.
  ChatMessageModel? _parseMessage(Map<String, dynamic> payload) {
    final dynamic raw = payload['message'] ?? payload['data'] ?? payload;
    if (raw is! Map) return null;
    try {
      return ChatMessageModel.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  // ── ChatSocketService ─────────────────────────────────────────────────────

  @override
  Stream<ChatMessageModel> messages(int conversationId) {
    final controller = _messageControllers.putIfAbsent(
      conversationId,
      () => StreamController<ChatMessageModel>.broadcast(),
    );
    _ensureChannel(
      _conversationChannel(conversationId),
      conversationId: conversationId,
    );
    return controller.stream;
  }

  @override
  Stream<bool> typing(int conversationId) {
    final controller = _typingControllers.putIfAbsent(
      conversationId,
      () => StreamController<bool>.broadcast(),
    );
    _ensureChannel(
      _conversationChannel(conversationId),
      conversationId: conversationId,
    );
    return controller.stream;
  }

  @override
  Stream<ChatMessageModel> inbox() {
    _inboxController ??= StreamController<ChatMessageModel>.broadcast();
    final int userId = _currentUserId();
    if (userId > 0) _ensureChannel(_userChannel(userId));
    return _inboxController!.stream;
  }

  int _currentUserId() {
    // Mirror MessageRepositoryImpl: Laravel puts the user id in the JWT `sub`.
    final token = AppSettings().tokenModel.accessToken;
    if (token == null || token.isEmpty) return 0;
    try {
      final parts = token.split('.');
      if (parts.length < 2) return 0;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return int.tryParse(payload['sub']?.toString() ?? '') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// No-op: the connection is shared app-wide and outlives individual blocs.
  @override
  void dispose() {}
}
