import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// The single, app-wide **Laravel Reverb** (Pusher protocol) websocket
/// connection. Every realtime feature — chat messages, typing/read receipts,
/// and slot availability — multiplexes its channels over this one socket
/// instead of opening a connection per service.
///
/// Backed by `dart_pusher_channels` (pure Dart, so it can target a self-hosted
/// Reverb host/port). Reads the shared `REVERB_*` values from `.env`.
final class ReverbConnection {
  ReverbConnection._();

  static final ReverbConnection instance = ReverbConnection._();

  static String get _appKey => dotenv.env['REVERB_APP_KEY'] ?? '';
  static String get _host => dotenv.env['REVERB_HOST'] ?? '';
  static int get _port => int.tryParse(dotenv.env['REVERB_PORT'] ?? '') ?? 443;
  static String get _scheme =>
      (dotenv.env['REVERB_SCHEME'] ?? 'https').toLowerCase() == 'http'
      ? 'ws'
      : 'wss';

  PusherChannelsClient? _client;
  bool _initialised = false;

  /// Every channel created through this connection, kept so they can all be
  /// (re)subscribed whenever the socket (re)connects.
  final Map<String, Channel> _channels = <String, Channel>{};

  /// The current Pusher/Reverb connection id (used by the presence heartbeat).
  String? get socketId => _client?.socketId;

  /// True when the required env is present; otherwise realtime is disabled and
  /// channel getters return null (callers stay silent).
  bool get isEnabled => _appKey.isNotEmpty && _host.isNotEmpty;

  /// Eagerly opens the shared socket. Safe to call repeatedly — it is a no-op
  /// once the connection has been initialised. Channels registered later (or
  /// already registered) subscribe as soon as the connection is established.
  void connect() => _ensureConnected();

  void _ensureConnected() {
    if (_initialised) return;
    _initialised = true;

    if (!isEnabled) {
      debugPrint(
        'ReverbConnection: REVERB_APP_KEY/REVERB_HOST missing — realtime '
        'disabled. Set them in .env.',
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

    // (Re)subscribe every registered channel on each (re)connect — this also
    // transparently covers automatic reconnects.
    client.onConnectionEstablished.listen((_) {
      for (final channel in _channels.values) {
        channel.subscribeIfNotUnsubscribed();
      }
    });

    client.connect();
  }

  /// Returns the private channel named [name], creating, binding [onEvent] and
  /// subscribing it exactly once. Returns null when realtime is disabled.
  PrivateChannel? privateChannel(
    String name, {
    required EndpointAuthorizableChannelTokenAuthorizationDelegate<
      PrivateChannelAuthorizationData
    >
    authorizationDelegate,
    required void Function(PusherChannelsReadEvent event) onEvent,
  }) {
    _ensureConnected();
    final client = _client;
    if (client == null) return null;

    final existing = _channels[name];
    if (existing is PrivateChannel) return existing;

    final channel = client.privateChannel(
      name,
      authorizationDelegate: authorizationDelegate,
    );
    _channels[name] = channel;
    channel.bindToAll().listen(onEvent);
    channel.subscribeIfNotUnsubscribed();
    return channel;
  }

  /// Returns the public channel named [name], creating, binding [onEvent] and
  /// subscribing it exactly once. Returns null when realtime is disabled.
  PublicChannel? publicChannel(
    String name, {
    required void Function(PusherChannelsReadEvent event) onEvent,
  }) {
    _ensureConnected();
    final client = _client;
    if (client == null) return null;

    final existing = _channels[name];
    if (existing is PublicChannel) return existing;

    final channel = client.publicChannel(name);
    _channels[name] = channel;
    channel.bindToAll().listen(onEvent);
    channel.subscribeIfNotUnsubscribed();
    return channel;
  }
}
