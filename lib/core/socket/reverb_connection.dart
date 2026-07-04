import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  final Map<String, Channel> _channels = <String, Channel>{};

  final Map<String, List<StreamSubscription<dynamic>>> _eventSubs =
      <String, List<StreamSubscription<dynamic>>>{};

  String? get socketId => _client?.socketId;

  bool get isEnabled => _appKey.isNotEmpty && _host.isNotEmpty;

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
      debugPrint('Reverb: connected (socketId=${client.socketId})');
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
    _eventSubs[name] = <StreamSubscription<dynamic>>[
      channel.bindToAll().listen(onEvent),
      ..._debugWatch(channel),
    ];
    channel.subscribe();
    return channel;
  }

  /// Returns the presence channel named [name], creating, binding [onEvent]
  /// and subscribing it exactly once. Returns null when realtime is disabled.
  ///
  /// Presence channels are typically scoped to what the user is currently
  /// looking at (e.g. one venue + date) — call [unsubscribe] when leaving so
  /// the user drops out of the channel's member roster.
  PresenceChannel? presenceChannel(
    String name, {
    required EndpointAuthorizableChannelTokenAuthorizationDelegate<
      PresenceChannelAuthorizationData
    >
    authorizationDelegate,
    required void Function(PusherChannelsReadEvent event) onEvent,
  }) {
    _ensureConnected();
    final client = _client;
    if (client == null) return null;

    final existing = _channels[name];
    if (existing is PresenceChannel) return existing;

    final channel = client.presenceChannel(
      name,
      authorizationDelegate: authorizationDelegate,
    );
    _channels[name] = channel;
    _eventSubs[name] = <StreamSubscription<dynamic>>[
      channel.bindToAll().listen(onEvent),
      ..._debugWatch(channel),
    ];
    // Plain subscribe (not subscribeIfNotUnsubscribed): re-joining a channel
    // that was intentionally left must clear its `unsubscribed` status.
    channel.subscribe();
    return channel;
  }

  /// Leaves the channel named [name] and stops routing its events. Safe to
  /// call for channels that were never registered.
  void unsubscribe(String name) {
    for (final sub in _eventSubs.remove(name) ?? const []) {
      sub.cancel();
    }
    _channels.remove(name)?.unsubscribe();
    debugPrint('Reverb: left channel $name');
  }

  /// Debug-only visibility into a channel's subscription lifecycle —
  /// authorization failures against `/broadcasting/auth` are otherwise
  /// swallowed silently by the pusher client.
  List<StreamSubscription<dynamic>> _debugWatch(Channel channel) {
    if (!kDebugMode) return const [];
    return <StreamSubscription<dynamic>>[
      channel.whenSubscriptionSucceeded().listen(
        (_) => debugPrint('Reverb: subscribed to ${channel.name}'),
      ),
      channel.onSubscriptionError().listen(
        (event) => debugPrint(
          'Reverb: SUBSCRIPTION ERROR on ${channel.name} — '
          '${event.data} (check /broadcasting/auth + routes/channels.php)',
        ),
      ),
    ];
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
    _eventSubs[name] = <StreamSubscription<dynamic>>[
      channel.bindToAll().listen(onEvent),
      ..._debugWatch(channel),
    ];
    channel.subscribe();
    return channel;
  }
}
