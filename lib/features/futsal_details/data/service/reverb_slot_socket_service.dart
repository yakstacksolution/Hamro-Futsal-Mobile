import 'dart:async';
import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/core/socket/reverb_connection.dart';
import 'package:hamro_footsall/features/futsal_details/data/service/slot_socket_service.dart';

/// Realtime slot availability backed by **Laravel Reverb** (Pusher protocol).
///
/// Two channels feed the slot-selection screen, both multiplexed over the
/// single shared [ReverbConnection] (the same socket chat uses):
///
/// 1. `private-venue.{venueId}.slots` — fires `venue.slots.updated` after a
///    booking is created or cancelled; listeners re-fetch the grid.
/// 2. `presence-venue.{venueId}.booking.{bookingDate}` — fires the six
///    `slot.*` / `booking.*` hold events plus a member roster of everyone
///    currently viewing/booking that venue + date.
///
/// Both are auth-guarded, signed against Laravel's `/broadcasting/auth` with
/// the signed-in user's bearer token (same as chat). Channel names are
/// overridable via `REVERB_SLOT_CHANNEL` / `REVERB_BOOKING_CHANNEL` using the
/// `{venueId}` / `{bookingDate}` placeholders.
///
/// [dispose] is a no-op — the connection is shared app-wide — but the per-date
/// presence channel must be left via [leaveBookingChannel] when the screen is
/// torn down so the user drops out of the roster.
final class ReverbSlotSocketService implements SlotSocketService {
  ReverbSlotSocketService._();

  static final ReverbSlotSocketService instance = ReverbSlotSocketService._();

  static String get _authUrl =>
      dotenv.env['REVERB_AUTH_URL'] ??
      '${APIEndpoint.baseUrl}/broadcasting/auth';

  /// Laravel Echo private channel carrying slot availability for a venue.
  static String _venueSlotsChannel(int venueId) {
    final String? template = dotenv.env['REVERB_SLOT_CHANNEL'];
    if (template != null && template.trim().isNotEmpty) {
      return template.replaceAll('{venueId}', '$venueId');
    }
    return 'private-venue.$venueId.slots';
  }

  /// Presence channel carrying live hold/booking state for one venue + date.
  static String _bookingChannel(int venueId, String bookingDate) {
    final String? template = dotenv.env['REVERB_BOOKING_CHANNEL'];
    if (template != null && template.trim().isNotEmpty) {
      return template
          .replaceAll('{venueId}', '$venueId')
          .replaceAll('{bookingDate}', bookingDate);
    }
    return 'presence-venue.$venueId.booking.$bookingDate';
  }

  /// The six hold/booking events broadcast on the presence channel.
  static const List<String> _holdEvents = <String>[
    BookingSlotEvent.held,
    BookingSlotEvent.released,
    BookingSlotEvent.expired,
    BookingSlotEvent.stepUpdated,
    BookingSlotEvent.confirmed,
    BookingSlotEvent.cancelled,
  ];

  // ── venue.slots.updated (private channel) ─────────────────────────────────

  /// Broadcast controllers keyed by venue id.
  final Map<int, StreamController<SlotAvailabilityUpdate>> _slotControllers =
      <int, StreamController<SlotAvailabilityUpdate>>{};

  /// Venues we've already subscribed a slots channel for (subscribe once each).
  final Set<int> _subscribedVenues = <int>{};

  // ── presence-venue.{id}.booking.{date} ────────────────────────────────────

  /// Per venue+date presence wiring, keyed by [_bookingKey].
  final Map<String, _PresenceBinding> _bookings = <String, _PresenceBinding>{};

  static String _bookingKey(int venueId, String bookingDate) =>
      '$venueId|$bookingDate';

  /// HTTP token auth delegates that sign channel subscriptions against
  /// Laravel's `/broadcasting/auth`, carrying the current bearer token.
  Map<String, String> get _authHeaders {
    final String? token = AppSettings().tokenModel.accessToken;
    return <String, String>{
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  EndpointAuthorizableChannelTokenAuthorizationDelegate<
    PrivateChannelAuthorizationData
  >
  _privateAuthDelegate() =>
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse(_authUrl),
        headers: _authHeaders,
      );

  EndpointAuthorizableChannelTokenAuthorizationDelegate<
    PresenceChannelAuthorizationData
  >
  _presenceAuthDelegate() =>
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPresenceChannel(
        authorizationEndpoint: Uri.parse(_authUrl),
        headers: _authHeaders,
      );

  void _ensureSlotsChannel(int venueId) {
    if (!_subscribedVenues.add(venueId)) return;
    ReverbConnection.instance.privateChannel(
      _venueSlotsChannel(venueId),
      authorizationDelegate: _privateAuthDelegate(),
      onEvent: (event) => _routeSlotsEvent(venueId, event),
    );
  }

  void _routeSlotsEvent(int venueId, PusherChannelsReadEvent event) {
    final String name = event.name;
    if (name.startsWith('pusher:') || name.startsWith('pusher_internal:')) {
      return;
    }

    // Any non-internal event on a venue's dedicated slots channel means its
    // availability moved — surface it and let listeners re-fetch.
    final Map<String, dynamic>? payload = _decode(event.data);
    if (kDebugMode) {
      debugPrint('SlotSocket: [$name] on ${_venueSlotsChannel(venueId)}');
    }
    _slotControllers[venueId]?.add(
      SlotAvailabilityUpdate(
        venueId: venueId,
        date: _dateFrom(payload),
        raw: payload ?? const <String, dynamic>{},
      ),
    );
  }

  void _ensureBookingChannel(int venueId, String bookingDate) {
    final String key = _bookingKey(venueId, bookingDate);
    final _PresenceBinding binding = _bookings.putIfAbsent(
      key,
      () => _PresenceBinding(),
    );
    if (binding.channel != null) return;

    final PresenceChannel? channel = ReverbConnection.instance.presenceChannel(
      _bookingChannel(venueId, bookingDate),
      authorizationDelegate: _presenceAuthDelegate(),
      onEvent: (event) => _routeBookingEvent(venueId, bookingDate, event),
    );
    if (channel == null) return; // Realtime disabled — streams stay silent.

    binding.channel = channel;
    void pushCount(_) {
      final int count = channel.state?.members?.membersCount ?? 0;
      if (kDebugMode) {
        debugPrint('SlotSocket: ${channel.name} roster → $count viewer(s)');
      }
      binding.viewers.add(count);
    }

    binding.rosterSubs.addAll(<StreamSubscription<void>>[
      channel.whenSubscriptionSucceeded().listen(pushCount),
      channel.whenMemberAdded().listen(pushCount),
      channel.whenMemberRemoved().listen(pushCount),
    ]);
  }

  void _routeBookingEvent(
    int venueId,
    String bookingDate,
    PusherChannelsReadEvent event,
  ) {
    final String type = _normalizeHoldEvent(event.name);
    if (type.isEmpty) return;
    if (kDebugMode) {
      debugPrint(
        'SlotSocket: [$type] on ${_bookingChannel(venueId, bookingDate)} — '
        '${event.data}',
      );
    }

    final Map<String, dynamic>? payload = _decode(event.data);
    if (payload == null) return;
    final Map<String, dynamic> data = _eventPayload(payload);

    _bookings[_bookingKey(venueId, bookingDate)]?.events.add(
      BookingSlotEvent(
        type: type,
        venueId: int.tryParse(data['venue_id']?.toString() ?? '') ?? venueId,
        courtId: int.tryParse(data['court_id']?.toString() ?? ''),
        bookingDate: _dateFrom(data) ?? bookingDate,
        startTime: data['start_time']?.toString(),
        endTime: data['end_time']?.toString(),
        status: data['status']?.toString(),
        reason: data['reason']?.toString(),
        step: data['step']?.toString(),
        expiresAt: DateTime.tryParse(data['expires_at']?.toString() ?? ''),
        raw: data,
      ),
    );
  }

  /// Maps a wire event name onto one of the six hold events, tolerating
  /// Laravel's optional leading-dot (`.slot.held`) on broadcastAs names.
  /// Returns '' for anything else (including pusher internals).
  String _normalizeHoldEvent(String name) {
    final String bare = name.startsWith('.') ? name.substring(1) : name;
    return _holdEvents.contains(bare) ? bare : '';
  }

  // ── payload helpers ───────────────────────────────────────────────────────

  /// Best-effort extraction of the affected day as `yyyy-MM-dd`.
  String? _dateFrom(Map<String, dynamic>? payload) {
    if (payload == null) return null;
    final dynamic data = payload['data'];
    final Map<String, dynamic> map = data is Map
        ? <String, dynamic>{...payload, ...Map<String, dynamic>.from(data)}
        : payload;
    final String? raw =
        (map['date'] ??
                map['booking_date'] ??
                map['bookingDate'] ??
                map['slot_date'] ??
                map['select_date'] ??
                map['selectDate'])
            ?.toString()
            .trim();
    if (raw == null || raw.isEmpty) return null;
    return raw.split('T').first.split(' ').first;
  }

  /// Broadcast payloads sometimes nest fields under `data` — flatten them.
  Map<String, dynamic> _eventPayload(Map<String, dynamic> payload) {
    final dynamic data = payload['data'];
    return data is Map
        ? <String, dynamic>{...payload, ...Map<String, dynamic>.from(data)}
        : payload;
  }

  Map<String, dynamic>? _decode(dynamic data) {
    try {
      final decoded = data is String ? jsonDecode(data) : data;
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  // ── SlotSocketService ─────────────────────────────────────────────────────

  @override
  Stream<SlotAvailabilityUpdate> venueSlots(int venueId) {
    final controller = _slotControllers.putIfAbsent(
      venueId,
      () => StreamController<SlotAvailabilityUpdate>.broadcast(),
    );
    _ensureSlotsChannel(venueId);
    return controller.stream;
  }

  @override
  Stream<BookingSlotEvent> bookingEvents(int venueId, String bookingDate) {
    _ensureBookingChannel(venueId, bookingDate);
    return _bookings[_bookingKey(venueId, bookingDate)]!.events.stream;
  }

  @override
  Stream<int> bookingViewers(int venueId, String bookingDate) {
    _ensureBookingChannel(venueId, bookingDate);
    return _bookings[_bookingKey(venueId, bookingDate)]!.viewers.stream;
  }

  @override
  void leaveBookingChannel(int venueId, String bookingDate) {
    final _PresenceBinding? binding = _bookings.remove(
      _bookingKey(venueId, bookingDate),
    );
    if (binding == null) return;
    binding.close();
    ReverbConnection.instance.unsubscribe(
      _bookingChannel(venueId, bookingDate),
    );
  }

  /// No-op: the connection is shared app-wide and outlives individual blocs.
  @override
  void dispose() {}
}

/// Streams + subscriptions backing one venue+date presence channel.
final class _PresenceBinding {
  PresenceChannel? channel;
  final StreamController<BookingSlotEvent> events =
      StreamController<BookingSlotEvent>.broadcast();
  final StreamController<int> viewers = StreamController<int>.broadcast();
  final List<StreamSubscription<void>> rosterSubs =
      <StreamSubscription<void>>[];

  void close() {
    for (final StreamSubscription<void> sub in rosterSubs) {
      sub.cancel();
    }
    rosterSubs.clear();
    events.close();
    viewers.close();
    channel = null;
  }
}
