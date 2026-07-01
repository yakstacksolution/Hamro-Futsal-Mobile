import 'dart:async';
import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hamro_footsall/core/socket/reverb_connection.dart';
import 'package:hamro_footsall/features/futsal_details/data/service/slot_socket_service.dart';

/// Realtime slot availability backed by **Laravel Reverb** (Pusher protocol).
///
/// Slot broadcasts ride a **public** channel per venue —
/// `venue.{venueId}.slots` — so no `/broadcasting/auth` round-trip is needed
/// (availability isn't user-scoped). Channels are multiplexed over the single
/// shared [ReverbConnection] (the same socket chat uses), so this service does
/// not open its own connection. [dispose] is a no-op.
///
/// The channel name is overridable via `REVERB_SLOT_CHANNEL` (use the
/// `{venueId}` placeholder), defaulting to Laravel Echo's `venue.{venueId}.slots`.
final class ReverbSlotSocketService implements SlotSocketService {
  ReverbSlotSocketService._();

  static final ReverbSlotSocketService instance = ReverbSlotSocketService._();

  /// Laravel Echo public channel carrying slot availability for a venue.
  static String _venueSlotsChannel(int venueId) {
    final String? template = dotenv.env['REVERB_SLOT_CHANNEL'];
    if (template != null && template.trim().isNotEmpty) {
      return template.replaceAll('{venueId}', '$venueId');
    }
    return 'venue.$venueId.slots';
  }

  /// Broadcast controllers keyed by venue id.
  final Map<int, StreamController<SlotAvailabilityUpdate>> _controllers =
      <int, StreamController<SlotAvailabilityUpdate>>{};

  /// Venues we've already subscribed a channel for (subscribe once each).
  final Set<int> _subscribed = <int>{};

  void _ensureChannel(int venueId) {
    if (!_subscribed.add(venueId)) return;
    ReverbConnection.instance.publicChannel(
      _venueSlotsChannel(venueId),
      onEvent: (event) => _route(venueId, event),
    );
  }

  void _route(int venueId, PusherChannelsReadEvent event) {
    final String name = event.name;
    if (name.startsWith('pusher:') || name.startsWith('pusher_internal:')) {
      return;
    }

    // Any non-internal event on a venue's dedicated slots channel means its
    // availability moved — surface it and let listeners re-fetch.
    final Map<String, dynamic>? payload = _decode(event.data);
    _controllers[venueId]?.add(
      SlotAvailabilityUpdate(
        venueId: venueId,
        date: _dateFrom(payload),
        raw: payload ?? const <String, dynamic>{},
      ),
    );
  }

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

  Map<String, dynamic>? _decode(dynamic data) {
    try {
      final decoded = data is String ? jsonDecode(data) : data;
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<SlotAvailabilityUpdate> venueSlots(int venueId) {
    final controller = _controllers.putIfAbsent(
      venueId,
      () => StreamController<SlotAvailabilityUpdate>.broadcast(),
    );
    _ensureChannel(venueId);
    return controller.stream;
  }

  /// No-op: the connection is shared app-wide and outlives individual blocs.
  @override
  void dispose() {}
}
