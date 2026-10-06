import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/core/config/app_environment.dart';

final class ReverbConnection {
  ReverbConnection._();

  static final ReverbConnection instance = ReverbConnection._();

  static String get _appKey => AppEnvironment.read('REVERB_APP_KEY');
  static String get _host => AppEnvironment.read('REVERB_HOST');
  static int get _port =>
      int.tryParse(AppEnvironment.read('REVERB_PORT')) ?? 443;
  static String get _scheme =>
      AppEnvironment.read('REVERB_SCHEME').toLowerCase() == 'http'
      ? 'ws'
      : 'wss';

  PusherChannelsClient? _client;
  bool _initialised = false;
  StreamSubscription<void>? _connectionSub;

  final Map<String, Channel> _channels = <String, Channel>{};

  final Map<String, List<StreamSubscription<dynamic>>> _eventSubs =
      <String, List<StreamSubscription<dynamic>>>{};

  String? get socketId => _client?.socketId;

  bool get isEnabled => _appKey.isNotEmpty && _host.isNotEmpty;

  bool hasChannel(String name) => _channels.containsKey(name);

  void connect() => _ensureConnected();

  void _ensureConnected() {
    if (_initialised) return;
    _initialised = true;

    if (!isEnabled) {
      debugPrint(
        'ReverbConnection: REVERB_APP_KEY/REVERB_HOST missing — realtime '
        'disabled. Set them in ${AppEnvironment.envFileName}.',
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

    if (kDebugMode) {
      client.lifecycleStream.listen(
        (state) => debugPrint('Reverb: lifecycle → $state'),
      );
    }

    // (Re)subscribe every registered channel on each (re)connect — this also
    // transparently covers automatic reconnects.
    _connectionSub = client.onConnectionEstablished.listen((_) {
      debugPrint(
        'Reverb: connected (socketId=${client.socketId}) — authorizing & '
        'subscribing ${_channels.length} channel(s): ${_channels.keys}',
      );
      for (final channel in _channels.values) {
        channel.subscribeIfNotUnsubscribed();
      }
    });

    client.connect();
  }

  Future<void> reset() async {
    _initialised = false;
    await _connectionSub?.cancel();
    _connectionSub = null;

    for (final subs in _eventSubs.values) {
      for (final sub in subs) {
        await sub.cancel();
      }
    }
    _eventSubs.clear();

    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();

    final client = _client;
    _client = null;
    if (client == null || client.isDisposed) return;
    try {
      client.dispose();
    } on PusherChannelsException catch (exception) {
      debugPrint('Reverb reset ignored disposed client: ${exception.message}');
    }
  }

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
      channel.bindToAll().listen(_logged(name, onEvent)),
      ..._debugWatch(channel),
    ];
    channel.subscribe();
    return channel;
  }

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
      channel.bindToAll().listen(_logged(name, onEvent)),
      ..._debugWatch(channel),
    ];
    // Plain subscribe (not subscribeIfNotUnsubscribed): re-joining a channel
    // that was intentionally left must clear its `unsubscribed` status.
    channel.subscribe();
    return channel;
  }

  void unsubscribe(String name) {
    for (final sub in _eventSubs.remove(name) ?? const []) {
      sub.cancel();
    }
    _channels.remove(name)?.unsubscribe();
    debugPrint('Reverb: left channel $name');
  }

  void Function(PusherChannelsReadEvent) _logged(
    String channelName,
    void Function(PusherChannelsReadEvent event) onEvent,
  ) {
    if (!kDebugMode) return onEvent;
    return (event) {
      debugPrint(
        'Reverb: ← event "${event.name}" on $channelName — data: ${event.data}',
      );
      onEvent(event);
    };
  }

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
      channel.bindToAll().listen(_logged(name, onEvent)),
      ..._debugWatch(channel),
    ];
    channel.subscribe();
    return channel;
  }
}
