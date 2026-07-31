import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/account/data/repositories/account_repository_impl.dart';
import 'package:hamro_footsall/features/account/domain/usecase/account_usecase.dart';
import 'package:hamro_footsall/features/account/presentation/bloc/account_bloc/account_bloc.dart';
import 'package:hamro_footsall/features/account/presentation/pages/account_screen.dart';
import 'package:hamro_footsall/features/account/presentation/widgets/account_widgets.dart';

/// Sizes representing each breakpoint.
const Size _phone = Size(411, 891);
const Size _tabletPortrait = Size(800, 1280);
const Size _desktopWindow = Size(1440, 900);

Future<void> _pumpAccount(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: BlocProvider<AccountBloc>(
          // No event dispatched: the initial state renders the empty summary,
          // which is enough to assert layout.
          create: (_) => AccountBloc(AccountUseCase(AccountRepositoryImpl())),
          child: const AccountView(),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Finance & payouts (AccountView)', () {
    for (final (String label, Size size) in <(String, Size)>[
      ('phone', _phone),
      ('tablet portrait', _tabletPortrait),
      ('desktop window', _desktopWindow),
    ]) {
      testWidgets('$label lays out without overflow', (
        WidgetTester tester,
      ) async {
        await _pumpAccount(tester, size);

        expect(tester.takeException(), isNull);
        expect(find.byType(AccountBalanceCard), findsOneWidget);
        expect(find.byType(AccountStatsRow), findsOneWidget);
        // Shortcuts are present at every width, only placed differently.
        expect(find.byType(AccountNavTile), findsWidgets);
      });
    }

    testWidgets('phone stacks the shortcuts below the stats', (
      WidgetTester tester,
    ) async {
      await _pumpAccount(tester, _phone);

      final Rect stats = tester.getRect(find.byType(AccountStatsRow));
      final Rect shortcut = tester.getRect(find.byType(AccountNavTile).first);
      expect(shortcut.top, greaterThan(stats.bottom));
      // Full width, not a side column.
      expect(shortcut.width, greaterThan(_phone.width / 2));
    });

    testWidgets('tablet keeps the single stacked column', (
      WidgetTester tester,
    ) async {
      await _pumpAccount(tester, _tabletPortrait);

      final Rect stats = tester.getRect(find.byType(AccountStatsRow));
      final Rect shortcut = tester.getRect(find.byType(AccountNavTile).first);
      expect(shortcut.top, greaterThan(stats.bottom));
    });

    testWidgets('desktop moves the shortcuts into a side column', (
      WidgetTester tester,
    ) async {
      await _pumpAccount(tester, _desktopWindow);

      expect(tester.takeException(), isNull);
      final Rect balance = tester.getRect(find.byType(AccountBalanceCard));
      final Rect shortcut = tester.getRect(find.byType(AccountNavTile).first);

      // Beside the main column, not below it.
      expect(shortcut.left, greaterThan(balance.right));
      expect(shortcut.top, lessThan(balance.bottom));
      // And it is the narrow rail, not half the window.
      expect(
        shortcut.width,
        lessThanOrEqualTo(AppDimens.accountShortcutsColumnWidth),
      );
    });

    testWidgets('desktop balance card does not span the whole window', (
      WidgetTester tester,
    ) async {
      await _pumpAccount(tester, _desktopWindow);

      final double balanceWidth = tester
          .getSize(find.byType(AccountBalanceCard))
          .width;
      // Window minus the shortcuts rail, its gap and the page insets.
      expect(
        balanceWidth,
        closeTo(
          _desktopWindow.width -
              AppDimens.accountShortcutsColumnWidth -
              AppDimens.paddingX20 -
              AppDimens.paddingX32 * 2,
          2,
        ),
      );
    });

    testWidgets('the three stat tiles stay on one row at every width', (
      WidgetTester tester,
    ) async {
      for (final Size size in <Size>[_phone, _tabletPortrait, _desktopWindow]) {
        await _pumpAccount(tester, size);
        expect(tester.takeException(), isNull, reason: '$size');

        final Rect row = tester.getRect(find.byType(AccountStatsRow));
        // A wrapped row would be far taller than a single tile.
        expect(row.height, lessThan(200), reason: '$size');
      }
    });
  });
}
