import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/routers/app_routers.dart';
import 'package:hamro_futsal/core/routers/root_navigator_key.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/data/repositories/message_repository_impl.dart';
import 'package:hamro_futsal/features/message/data/service/reverb_chat_socket_service.dart';
import 'package:hamro_futsal/features/message/domain/usecase/message_usecase.dart';
import 'package:hamro_futsal/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_futsal/features/message/presentation/pages/chat_page.dart';

const int _bookingsTabIndex = 1;
const int _messagesTabIndex = 2;

enum _NotificationKind { chat, booking, opponentMatch, payment }

String? _pendingType;
Map<String, dynamic>? _pendingPayload;
bool _navigationInProgress = false;
String? _lastNotificationSignature;
DateTime? _lastNotificationAt;

bool isSupportedNotificationType(String? type) => _kindOf(type) != null;

_NotificationKind? _kindOf(String? type) {
  switch (type?.trim().toLowerCase()) {
    case 'chat':
    case 'chat_message':
      return _NotificationKind.chat;
    case 'booking':
    case 'booking_created':
    case 'booking_confirmed':
    case 'booking_cancelled':
    case 'booking_reminder':
    case 'booking_update':
      return _NotificationKind.booking;
    case 'opponent_match':
    case 'match_request':
    case 'match':
    case 'opponent_request_accepted':
    case 'opponent_request_declined':
    case 'opponent_payment_verified':
    case 'opponent_payment_rejected':
      return _NotificationKind.opponentMatch;
    case 'payment':
    case 'payment_success':
    case 'payment_received':
    case 'payment_failed':
      return _NotificationKind.payment;
    default:
      return null;
  }
}

void notificationRedirection(
  String type, {
  Map<String, dynamic> payloadData = const <String, dynamic>{},
}) {
  final _NotificationKind? kind = _kindOf(type);
  if (kind == null) {
    debugPrint('Ignoring unsupported notification type: $type');
    return;
  }

  final bool isLoggedIn =
      AppSettings().tokenModel.accessToken?.trim().isNotEmpty ?? false;
  if (!isLoggedIn) return;

  final String signature = _dedupeSignature(kind, payloadData);
  final DateTime now = DateTime.now();
  if (_lastNotificationSignature == signature &&
      _lastNotificationAt != null &&
      now.difference(_lastNotificationAt!) < const Duration(seconds: 3)) {
    return;
  }
  _lastNotificationSignature = signature;
  _lastNotificationAt = now;

  debugPrint('Notification redirect queued: kind=$kind signature=$signature');
  _pendingType = type;
  _pendingPayload = payloadData;
  flushPendingNotificationNavigation();
}

void flushPendingNotificationNavigation() {
  final String? type = _pendingType;
  final Map<String, dynamic>? payload = _pendingPayload;
  final NavigatorState? navigator = RootNavigatorKey.navigator;
  final GoRouter? router = AppRouters.instance;
  final _NotificationKind? kind = _kindOf(type);

  if (type == null ||
      payload == null ||
      kind == null ||
      navigator == null ||
      router == null ||
      _navigationInProgress) {
    return;
  }

  _pendingType = null;
  _pendingPayload = null;
  _navigationInProgress = true;

  Future<dynamic>? navigation;
  switch (kind) {
    case _NotificationKind.chat:
      navigation = _navigateToChat(navigator, payload);
      break;
    case _NotificationKind.booking:
    case _NotificationKind.payment:
      navigation = _navigateToBooking(router, payload);
      break;
    case _NotificationKind.opponentMatch:
      navigation = _navigateToOpponentMatch(router);
      break;
  }

  if (navigation == null) {
    _navigationInProgress = false;
    return;
  }

  navigation.whenComplete(() {
    _navigationInProgress = false;
    if (_pendingType != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => flushPendingNotificationNavigation(),
      );
    }
  });
}

Future<dynamic>? _navigateToChat(
  NavigatorState navigator,
  Map<String, dynamic> payload,
) {
  final ConversationModel? conversation = _conversationFromPayload(payload);
  if (conversation == null || conversation.id <= 0) {
    debugPrint('Chat notification missing a valid conversation.');
    return null;
  }

  DashboardScreen.selectedNavIndex.value = _messagesTabIndex;
  return navigator.push<void>(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: '/chat/${conversation.id}'),
      builder: (_) => BlocProvider<MessageBloc>(
        create: (_) => MessageBloc(
          MessageUseCase(MessageRepositoryImpl()),
          socketService: ReverbChatSocketService.instance,
        ),
        child: ChatPage(conversation: conversation),
      ),
    ),
  );
}

Future<dynamic> _navigateToBooking(
  GoRouter router,
  Map<String, dynamic> payload,
) {
  DashboardScreen.selectedNavIndex.value = _bookingsTabIndex;

  final BookingModel? booking = _bookingFromPayload(payload);
  if (booking != null) {
    return router.pushNamed<void>(
      AppRouterParams.bookingDetails.name,
      queryParameters: <String, String>{
        'futsal': _isFutsalView(payload) ? 'true' : 'false',
      },
      extra: booking,
    );
  }

  debugPrint('Booking notification without a booking model; opening overview.');
  return router.pushNamed<void>(AppRouterParams.bookingOverview.name);
}

Future<dynamic> _navigateToOpponentMatch(GoRouter router) {
  return router.pushNamed<void>(AppRouterParams.opponentMatch.name);
}

String _dedupeSignature(_NotificationKind kind, Map<String, dynamic> payload) {
  final Object? id =
      payload['message_id'] ??
      payload['messageId'] ??
      payload['conversation_id'] ??
      payload['conversationId'] ??
      payload['booking_id'] ??
      payload['request_id'] ??
      payload['requestId'] ??
      payload['id'];
  return '${kind.name}:${id ?? ''}';
}

bool _isFutsalView(Map<String, dynamic> payload) {
  final String value =
      (payload['futsal'] ?? payload['is_futsal_view'] ?? payload['futsalView'])
          ?.toString()
          .trim()
          .toLowerCase() ??
      '';
  return value == 'true' || value == '1';
}

BookingModel? _bookingFromPayload(Map<String, dynamic> payload) {
  dynamic raw =
      payload['booking'] ?? payload['booking_model'] ?? payload['bookingModel'];

  if (raw is String && raw.trim().isNotEmpty) {
    try {
      raw = jsonDecode(raw);
    } catch (error) {
      debugPrint('Invalid FCM booking JSON: $error');
    }
  }

  if (raw is Map) {
    try {
      final map = Map<String, dynamic>.from(raw);
      final nested = map['data'];
      return BookingModel.fromJson(
        nested is Map ? Map<String, dynamic>.from(nested) : map,
      );
    } catch (error) {
      debugPrint('Invalid FCM booking model: $error');
    }
  }

  final int? bookingId = int.tryParse(
    (payload['booking_id'] ?? payload['id'])?.toString() ?? '',
  );
  if (bookingId == null || bookingId <= 0) return null;

  try {
    return BookingModel.fromJson(<String, dynamic>{
      'id': bookingId,
      'booking_ref': payload['booking_ref'] ?? payload['bookingRef'],
      'court_name': payload['court_name'],
      'futsal_name': payload['futsal_name'] ?? payload['venue_name'],
      'date': payload['date'],
      'start_time': payload['start_time'],
      'end_time': payload['end_time'],
      'status': payload['status'],
      'amount': payload['amount'],
      'player_name': payload['player_name'],
      'player_phone': payload['player_phone'],
      'futsal_address': payload['futsal_address'],
    });
  } catch (error) {
    debugPrint('Unable to build booking from payload: $error');
    return null;
  }
}

ConversationModel? _conversationFromPayload(Map<String, dynamic> payload) {
  dynamic raw =
      payload['conversation'] ??
      payload['conversation_model'] ??
      payload['conversationModel'];

  if (raw is String && raw.trim().isNotEmpty) {
    try {
      raw = jsonDecode(raw);
    } catch (error) {
      debugPrint('Invalid FCM conversation JSON: $error');
    }
  }

  if (raw is Map) {
    try {
      final map = Map<String, dynamic>.from(raw);
      final nested = map['data'];
      return ConversationModel.fromJson(
        nested is Map ? Map<String, dynamic>.from(nested) : map,
      );
    } catch (error) {
      debugPrint('Invalid FCM conversation model: $error');
    }
  }

  final conversationId = int.tryParse(
    (payload['conversation_id'] ?? payload['conversationId'] ?? payload['id'])
            ?.toString() ??
        '',
  );
  if (conversationId == null || conversationId <= 0) return null;

  dynamic participants = payload['participants'];
  if (participants is String && participants.trim().isNotEmpty) {
    try {
      participants = jsonDecode(participants);
    } catch (_) {
      participants = const <dynamic>[];
    }
  }

  return ConversationModel.fromJson(<String, dynamic>{
    'id': conversationId,
    'type':
        payload['conversation_type'] ?? payload['conversationType'] ?? 'direct',
    'title':
        payload['conversation_title'] ??
        payload['group_title'] ??
        payload['title'],
    'participants': participants is List ? participants : const <dynamic>[],
    'venue_id': payload['venue_id'],
  });
}
