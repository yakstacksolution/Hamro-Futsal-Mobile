import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/notifications_page.dart';

void main() {
  testWidgets('marks notifications as read and shows the unread empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: NotificationsPage()));

    expect(find.text(StringConstants.bookingConfirmed), findsOneWidget);

    await tester.tap(find.byTooltip(StringConstants.markAllAsRead).first);
    await tester.pumpAndSettle();

    expect(find.byTooltip(StringConstants.markAllAsRead), findsNothing);

    await tester.tap(find.text(StringConstants.unread));
    await tester.pumpAndSettle();

    expect(find.text(StringConstants.noUnreadNotifications), findsOneWidget);
    expect(
      find.text(StringConstants.youHaveReadEveryNotification),
      findsOneWidget,
    );
  });
}
