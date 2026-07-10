import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/notifications/data/model/notification_model.dart';
import 'package:hamro_footsall/features/notifications/domain/repository/notification_repository.dart';
import 'package:hamro_footsall/features/notifications/domain/usecase/notification_use_case.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this._useCase) : super(const NotificationState()) {
    on<FetchNotificationsEvent>(_onFetch);
    on<ChangeNotificationFilterEvent>(_onChangeFilter);
    on<MarkAllNotificationsReadEvent>(_onMarkAllRead);
    on<MarkNotificationReadEvent>(_onMarkRead);
    on<MarkNotificationUnreadEvent>(_onMarkUnread);
  }

  final NotificationUseCase _useCase;

  Future<void> _onFetch(
    FetchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (!event.silent) {
      emit(
        state.copyWith(status: NotificationStatus.loading, clearError: true),
      );
    }

    final result = await _useCase.getNotifications(filter: state.filter);
    result.fold(
      (error) => emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: error.errorMessage,
          refreshTick: state.refreshTick + 1,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: NotificationStatus.success,
          notifications: page.notifications,
          unreadCount: page.unreadCount,
          clearError: true,
          refreshTick: state.refreshTick + 1,
        ),
      ),
    );
  }

  Future<void> _onChangeFilter(
    ChangeNotificationFilterEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.filter == state.filter) return;
    emit(state.copyWith(filter: event.filter));
    add(const FetchNotificationsEvent());
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.unreadCount == 0) return;

    // Optimistically flag every visible notification as read.
    final DateTime now = DateTime.now();
    final List<NotificationModel> optimistic = state.notifications
        .map((NotificationModel n) => n.isRead ? n : n.copyWith(readAt: now))
        .toList(growable: false);
    emit(state.copyWith(notifications: optimistic, unreadCount: 0));

    final result = await _useCase.markAllRead();
    result.fold(
      (error) {
        emit(state.copyWith(errorMessage: error.errorMessage));
        add(const FetchNotificationsEvent(silent: true));
      },
      (_) => add(const FetchNotificationsEvent(silent: true)),
    );
  }

  Future<void> _onMarkRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(_applyReadState(event.notificationId, read: true));

    final result = await _useCase.markRead(event.notificationId);
    result.fold(
      (error) {
        emit(state.copyWith(errorMessage: error.errorMessage));
        add(const FetchNotificationsEvent(silent: true));
      },
      (_) {},
    );
  }

  Future<void> _onMarkUnread(
    MarkNotificationUnreadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(_applyReadState(event.notificationId, read: false));

    final result = await _useCase.markUnread(event.notificationId);
    result.fold(
      (error) {
        emit(state.copyWith(errorMessage: error.errorMessage));
        add(const FetchNotificationsEvent(silent: true));
      },
      (_) {},
    );
  }

  /// Optimistically toggles a single notification's read flag and keeps the
  /// unread counter and (when in the unread tab) the visible list in sync.
  NotificationState _applyReadState(String id, {required bool read}) {
    NotificationModel? target;
    for (final NotificationModel n in state.notifications) {
      if (n.id == id) {
        target = n;
        break;
      }
    }
    if (target == null || target.isRead == read) return state;

    final DateTime now = DateTime.now();
    List<NotificationModel> updated = state.notifications
        .map(
          (NotificationModel n) => n.id == id
              ? n.copyWith(readAt: read ? now : null, clearReadAt: !read)
              : n,
        )
        .toList(growable: false);

    // In the unread tab a just-read notification should drop out of the list.
    if (read && state.filter == NotificationFilter.unread) {
      updated = updated
          .where((NotificationModel n) => n.id != id)
          .toList(growable: false);
    }

    final int nextUnread = read
        ? (state.unreadCount - 1).clamp(0, 1 << 30)
        : state.unreadCount + 1;
    return state.copyWith(notifications: updated, unreadCount: nextUnread);
  }
}
