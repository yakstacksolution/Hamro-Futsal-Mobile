import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/notifications/data/model/notification_model.dart';
import 'package:hamro_futsal/features/notifications/domain/repository/notification_repository.dart';
import 'package:hamro_futsal/features/notifications/presentation/pages/notifications_page.dart';

void main() {
  testWidgets('renders notifications and marks all as read', (
    WidgetTester tester,
  ) async {
    final _FakeNotificationRepository repository =
        _FakeNotificationRepository();

    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Booking confirmed'), findsOneWidget);
    expect(find.byKey(const Key('mark-all-read-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('mark-all-read-button')));
    await tester.pumpAndSettle();

    expect(repository.markAllReadCalls, 1);
    // Once everything is read the mark-all action disappears.
    expect(find.byKey(const Key('mark-all-read-button')), findsNothing);
  });

  testWidgets('marks a read notification as unread from the menu', (
    WidgetTester tester,
  ) async {
    final _FakeNotificationRepository repository =
        _FakeNotificationRepository();

    repository.seedReadNotification();

    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark as unread'), findsNothing);

    await tester.tap(find.byKey(const Key('notification-menu-n1')));
    await tester.pumpAndSettle();

    expect(find.text('Mark as unread'), findsOneWidget);

    await tester.tap(find.text('Mark as unread'));
    await tester.pumpAndSettle();

    expect(repository.markUnreadCalls, 1);
    expect(find.byKey(const Key('mark-all-read-button')), findsOneWidget);
  });
}

final class _FakeNotificationRepository implements NotificationRepository {
  int markAllReadCalls = 0;
  int markUnreadCalls = 0;
  bool _isRead = false;

  final NotificationModel _unread = NotificationModel(
    id: 'n1',
    title: 'Booking confirmed',
    body: 'Your booking is confirmed.',
    type: 'App\\Notifications\\BookingConfirmed',
    createdAt: DateTime(2026, 7, 8, 9),
  );

  void seedReadNotification() {
    _isRead = true;
  }

  @override
  Future<Either<AppException, NotificationPage>> getNotifications({
    required NotificationFilter filter,
    int perPage = 20,
  }) async {
    final NotificationModel model = _isRead
        ? _unread.copyWith(readAt: DateTime(2026, 7, 8, 10))
        : _unread;
    if (filter == NotificationFilter.unread && _isRead) {
      return right(
        const NotificationPage(notifications: <NotificationModel>[]),
      );
    }
    return right(
      NotificationPage(
        notifications: <NotificationModel>[model],
        unreadCount: _isRead ? 0 : 1,
      ),
    );
  }

  @override
  Future<Either<AppException, Unit>> markAllRead() async {
    markAllReadCalls++;
    _isRead = true;
    return right(unit);
  }

  @override
  Future<Either<AppException, Unit>> markRead(String notificationId) async {
    _isRead = true;
    return right(unit);
  }

  @override
  Future<Either<AppException, Unit>> markUnread(String notificationId) async {
    markUnreadCalls++;
    _isRead = false;
    return right(unit);
  }
}
