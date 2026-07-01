import 'dart:async';
import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/core/socket/reverb_connection.dart';
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
///   REVERB_STOP_TYPING_EVENT = stop-typing
///   REVERB_READ_EVENT    = messages.read (read receipt event)
///
/// Channel naming follows Laravel Echo conventions (see [_conversationChannel]
/// / [_userChannel]); adjust those builders if your backend differs.
/// ─────────────────────────────────────────────────────────────────────────
final class ReverbChatSocketService implements ChatSocketService {
  ReverbChatSocketService._();

  static final ReverbChatSocketService instance = ReverbChatSocketService._();

  static String get _authUrl =>
      dotenv.env['REVERB_AUTH_URL'] ??
      '${APIEndpoint.baseUrl}/broadcasting/auth';
  static String get _messageEvent =>
      dotenv.env['REVERB_MESSAGE_EVENT'] ?? 'message.sent';
  static String get _typingEvent =>
      dotenv.env['REVERB_TYPING_EVENT'] ?? 'typing';
  static String get _stopTypingEvent =>
      dotenv.env['REVERB_STOP_TYPING_EVENT'] ?? 'stop-typing';
  static String get _readEvent =>
      dotenv.env['REVERB_READ_EVENT'] ?? 'messages.read';

  /// Laravel Echo private channel for a single conversation.
  static String _conversationChannel(int id) => 'private-conversation.$id';

  /// Per-user "inbox" channel — new messages across all of the signed-in
  /// user's conversations. Laravel notifications default to
  /// `private-App.Models.User.{id}`; adjust if your broadcast uses another.
  static String _userChannel(int userId) => 'private-user.$userId';
  // ──────────────────────────────────────────────────────────────────────────

  /// Current Pusher/Reverb connection identifier used by presence heartbeat.
  /// Delegates to the shared, app-wide [ReverbConnection].
  String? get socketId => ReverbConnection.instance.socketId;

  /// Broadcast controllers keyed by conversation id / "inbox".
  final Map<int, StreamController<ChatMessageModel>> _messageControllers = {};
  final Map<int, StreamController<bool>> _typingControllers = {};
  final Map<int, StreamController<ChatReadReceipt>> _readControllers = {};
  StreamController<ChatMessageModel>? _inboxController;

  /// A message may be broadcast on both the user and conversation channels.
  /// Keep a bounded set so that fan-out and reconnect replay emit it once.
  final Set<String> _seenMessages = <String>{};
  final List<String> _seenMessageOrder = <String>[];

  // ── Connection lifecycle ──────────────────────────────────────────────────

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

  /// Registers (once) the private channel for [name] on the shared connection
  /// and wires its message/typing events into the matching controllers. No-op
  /// when realtime is disabled (missing env) or the channel already exists —
  /// callers read the controller streams regardless, which simply stay silent
  /// until events arrive. Routing is tolerant of Laravel's optional leading-dot
  /// (`.message.sent`) on broadcastAs names.
  void _ensureChannel(String name, {int? conversationId}) {
    ReverbConnection.instance.privateChannel(
      name,
      authorizationDelegate: _authDelegate(),
      onEvent: (event) => _route(event, conversationId),
    );
  }

  void _route(PusherChannelsReadEvent event, int? conversationId) {
    final String name = event.name;
    if (name.startsWith('pusher:') || name.startsWith('pusher_internal:')) {
      return;
    }

    final Map<String, dynamic>? payload = _decode(event.data);
    if (payload == null) return;

    if (_isMessageEvent(name)) {
      final message = _parseMessage(payload);
      if (message == null) return;
      final key = '${message.conversationId}:${message.id}';
      if (!_seenMessages.add(key)) return;
      _seenMessageOrder.add(key);
      if (_seenMessageOrder.length > 1000) {
        _seenMessages.remove(_seenMessageOrder.removeAt(0));
      }
      _inboxController?.add(message);
      _messageControllers[message.conversationId]?.add(message);
    } else if (_isTypingEvent(name)) {
      final eventPayload = _eventPayload(payload);
      final convId =
          conversationId ??
          int.tryParse(
            (eventPayload['conversation_id'] ?? eventPayload['conversationId'])
                    ?.toString() ??
                '',
          );
      if (convId == null) return;
      final actorId = _actorId(eventPayload);
      if (actorId != 0 && actorId == _currentUserId()) return;
      final dynamic rawTyping =
          eventPayload['is_typing'] ?? eventPayload['typing'];
      final bool isTyping = _isStopTypingEvent(name)
          ? false
          : rawTyping == null
          ? true
          : rawTyping == true || rawTyping.toString().toLowerCase() == 'true';
      _typingControllers[convId]?.add(isTyping);
    } else if (_isReadEvent(name)) {
      final eventPayload = _eventPayload(payload);
      final convId =
          conversationId ??
          int.tryParse(
            (eventPayload['conversation_id'] ?? eventPayload['conversationId'])
                    ?.toString() ??
                '',
          );
      if (convId == null) return;
      final ids = _messageIds(eventPayload);
      _readControllers[convId]?.add(
        ChatReadReceipt(
          conversationId: convId,
          readerId: _actorId(eventPayload),
          messageIds: ids,
        ),
      );
    }
  }

  bool _isMessageEvent(String name) {
    final normalized = _normalizedEvent(name);
    return _matches(name, _messageEvent) ||
        normalized.endsWith('messagesent') ||
        normalized.endsWith('newmessage');
  }

  bool _isTypingEvent(String name) {
    final normalized = _normalizedEvent(name);
    return _matches(name, _typingEvent) ||
        _isStopTypingEvent(name) ||
        normalized.endsWith('typing');
  }

  bool _isStopTypingEvent(String name) {
    final normalized = _normalizedEvent(name);
    return _matches(name, _stopTypingEvent) ||
        normalized.endsWith('stoptyping') ||
        normalized.endsWith('typingstopped');
  }

  bool _isReadEvent(String name) {
    final normalized = _normalizedEvent(name);
    return _matches(name, _readEvent) ||
        normalized.endsWith('messageread') ||
        normalized.endsWith('messagesread') ||
        normalized.endsWith('conversationread') ||
        normalized.endsWith('messagesmarkedread');
  }

  bool _matches(String eventName, String configured) =>
      eventName == configured || eventName == '.$configured';

  String _normalizedEvent(String name) =>
      name.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

  Map<String, dynamic> _eventPayload(Map<String, dynamic> payload) {
    final data = payload['data'];
    return data is Map
        ? <String, dynamic>{...payload, ...Map<String, dynamic>.from(data)}
        : payload;
  }

  int _actorId(Map<String, dynamic> payload) {
    final user = payload['user'];
    final readBy = payload['read_by'];
    final dynamic value =
        payload['user_id'] ??
        payload['userId'] ??
        payload['reader_id'] ??
        payload['readerId'] ??
        payload['sender_id'] ??
        payload['senderId'] ??
        (readBy is Map ? readBy['id'] : readBy) ??
        (user is Map ? user['id'] : null);
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<int> _messageIds(Map<String, dynamic> payload) {
    final dynamic many =
        payload['message_ids'] ?? payload['messageIds'] ?? payload['messages'];
    if (many is List) {
      return many
          .map((item) => item is Map ? item['id'] : item)
          .map((id) => int.tryParse(id?.toString() ?? ''))
          .whereType<int>()
          .toList(growable: false);
    }
    final message = payload['message'];
    final dynamic one =
        payload['message_id'] ??
        payload['messageId'] ??
        (message is Map ? message['id'] : null);
    final id = int.tryParse(one?.toString() ?? '');
    return id == null ? const <int>[] : <int>[id];
  }

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
    dynamic raw = payload;
    for (
      var depth = 0;
      depth < 3 && raw is Map && !raw.containsKey('id');
      depth++
    ) {
      raw = raw['message'] ?? raw['data'];
    }
    if (raw is! Map) return null;
    try {
      final message = ChatMessageModel.fromJson(Map<String, dynamic>.from(raw));
      return message.id > 0 && message.conversationId > 0 ? message : null;
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
  Stream<ChatReadReceipt> readReceipts(int conversationId) {
    final controller = _readControllers.putIfAbsent(
      conversationId,
      () => StreamController<ChatReadReceipt>.broadcast(),
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
