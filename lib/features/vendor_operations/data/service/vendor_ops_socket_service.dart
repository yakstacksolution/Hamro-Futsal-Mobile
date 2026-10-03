import 'dart:async';
import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/core/api/api_client/api_constants.dart';
import 'package:hamro_futsal/core/config/app_environment.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/socket/reverb_connection.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';

/// Something changed on a watched vendor channel — a booking made, paid,
/// cancelled, or a slot held or released on the date.
///
/// Like the player's slot screen, the board does not patch itself from the
/// payload: it fetches the day again, so it is right whatever the event's
/// shape.
class VendorOpsLiveEvent {
  const VendorOpsLiveEvent({
    required this.channel,
    required this.name,
    this.data = const <String, dynamic>{},
  });

  final String channel;

  /// The broadcast event's name, as sent.
  final String name;

  /// The decoded payload, flattened out of `data` when nested.
  final Map<String, dynamic> data;
}

/// The vendor operations page's realtime channel names.
abstract final class VendorOpsChannels {
  /// Every booking change on [date], across the vendor's venues — the Day
  /// board: `private-vendor.booking.2026-09-29`.
  static String day(DateTime date) => 'private-vendor.booking.${isoDate(date)}';

  /// Changes to one court's week — the Week table:
  /// `private-vendor.start_date.2026-09-27.end_date.2026-10-03.venue-id.2.court-id.14`.
  static String week({
    required DateTime start,
    required DateTime end,
    required int venueId,
    required int courtId,
  }) =>
      'private-vendor.start_date.${isoDate(start)}'
      '.end_date.${isoDate(end)}'
      '.venue-id.$venueId.court-id.$courtId';
}

/// Realtime updates for the vendor operations page, on the channels
/// [VendorOpsChannels] names for what the page shows.
abstract class VendorOpsSocketService {
  /// Every event on the watched channels.
  Stream<VendorOpsLiveEvent> get events;

  /// Watches exactly [channels] from now on: leaves the ones no longer named
  /// and joins the new ones.
  void watch(List<String> channels);

  /// Leaves every watched channel and closes [events].
  void dispose();
}

/// No realtime (tests, the demo): nothing is ever sent.
final class NoopVendorOpsSocketService implements VendorOpsSocketService {
  const NoopVendorOpsSocketService();

  @override
  Stream<VendorOpsLiveEvent> get events => const Stream.empty();

  @override
  void watch(List<String> channels) {}

  @override
  void dispose() {}
}

/// Backed by **Laravel Reverb** over the app's one shared [ReverbConnection],
/// signed against `/broadcasting/auth` with the signed-in user's token — the
/// same as chat and the slot screen. Silent when realtime is not configured
/// or nobody is signed in.
///
/// One per page: [dispose] leaves this page's channels but keeps the shared
/// connection open.
final class ReverbVendorOpsSocketService implements VendorOpsSocketService {
  ReverbVendorOpsSocketService();

  final StreamController<VendorOpsLiveEvent> _events =
      StreamController<VendorOpsLiveEvent>.broadcast();
  final Set<String> _watching = <String>{};

  static String get _authUrl => AppEnvironment.readOr(
    'REVERB_AUTH_URL',
    '${APIEndpoint.baseUrl}/broadcasting/auth',
  );

  String? get _accessToken {
    if (!AppSettings().isInitialized) return null;
    final String? token = AppSettings().tokenModel.accessToken?.trim();
    return token == null || token.isEmpty ? null : token;
  }

  @override
  Stream<VendorOpsLiveEvent> get events => _events.stream;

  @override
  void watch(List<String> channels) {
    if (_events.isClosed) return;
    final String? token = _accessToken;
    if (token == null || !ReverbConnection.instance.isEnabled) return;

    final Set<String> wanted = <String>{
      for (final String c in channels) _privateName(c),
    };
    for (final String gone in _watching.difference(wanted).toList()) {
      ReverbConnection.instance.unsubscribe(gone);
      _watching.remove(gone);
    }
    for (final String name in wanted.difference(_watching)) {
      final PrivateChannel? channel = ReverbConnection.instance.privateChannel(
        name,
        authorizationDelegate:
            EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
              authorizationEndpoint: Uri.parse(_authUrl),
              headers: <String, String>{
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            ),
        onEvent: (PusherChannelsReadEvent e) => _route(name, e),
      );
      if (channel != null) _watching.add(name);
    }
  }

  /// The server names channels with their `private-` prefix; accept them
  /// without it too.
  static String _privateName(String channel) {
    final String name = channel.trim();
    return name.startsWith('private-') ? name : 'private-$name';
  }

  void _route(String channel, PusherChannelsReadEvent event) {
    final String name = event.name;
    if (name.startsWith('pusher:') || name.startsWith('pusher_internal:')) {
      return;
    }
    if (kDebugMode) {
      debugPrint('VendorOpsSocket: ← [$name] on $channel — ${event.data}');
    }
    if (_events.isClosed) return;
    _events.add(
      VendorOpsLiveEvent(
        channel: channel,
        name: name,
        data: _decode(event.data),
      ),
    );
  }

  static Map<String, dynamic> _decode(dynamic data) {
    try {
      final dynamic decoded = data is String ? jsonDecode(data) : data;
      if (decoded is! Map) return const <String, dynamic>{};
      final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
      final dynamic inner = map['data'];
      return inner is Map
          ? <String, dynamic>{...map, ...Map<String, dynamic>.from(inner)}
          : map;
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  @override
  void dispose() {
    for (final String name in _watching) {
      ReverbConnection.instance.unsubscribe(name);
    }
    _watching.clear();
    _events.close();
  }
}
