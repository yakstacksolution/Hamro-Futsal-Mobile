import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/notifications/data/model/notification_model.dart';
import 'package:hamro_footsall/features/notifications/domain/repository/notification_repository.dart';
import 'package:hamro_footsall/features/notifications/presentation/pages/notifications_page.dart';

void main() {
  testWidgets('renders notifications and marks all as read', (
    WidgetTester tester,
  ) async {
    final _FakeNotificationRepository repository = _FakeNotificationRepository();

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
}

final class _FakeNotificationRepository implements NotificationRepository {
  int markAllReadCalls = 0;

  final NotificationModel _unread = NotificationModel(
    id: 'n1',
    title: 'Booking confirmed',
    body: 'Your booking is confirmed.',
    type: 'App\\Notifications\\BookingConfirmed',
    createdAt: DateTime(2026, 7, 8, 9),
  );

  @override
  Future<Either<AppException, NotificationPage>> getNotifications({
    required NotificationFilter filter,
    int perPage = 20,
  }) async {
    final bool allRead = markAllReadCalls > 0;
    final NotificationModel model = allRead
        ? _unread.copyWith(readAt: DateTime(2026, 7, 8, 10))
        : _unread;
    if (filter == NotificationFilter.unread && allRead) {
      return right(
        const NotificationPage(notifications: <NotificationModel>[]),
      );
    }
    return right(
      NotificationPage(
        notifications: <NotificationModel>[model],
        unreadCount: allRead ? 0 : 1,
      ),
    );
  }

  @override
  Future<Either<AppException, Unit>> markAllRead() async {
    markAllReadCalls++;
    return right(unit);
  }

  @override
  Future<Either<AppException, Unit>> markRead(String notificationId) async =>
      right(unit);

  @override
  Future<Either<AppException, Unit>> markUnread(String notificationId) async =>
      right(unit);
}
