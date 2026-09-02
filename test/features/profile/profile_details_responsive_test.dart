import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hamro_futsal/features/profile/domain/usecase/profile_usecase.dart';
import 'package:hamro_futsal/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_futsal/features/profile/presentation/widgets/profile_details_page.dart';

/// Sizes representing each breakpoint.
const Size _phone = Size(411, 891);
const Size _tabletPortrait = Size(800, 1280);
const Size _desktopWindow = Size(1440, 900);

Future<void> _pumpAt(
  WidgetTester tester,
  Size size, {

  /// The form is read-only until Edit is tapped, so anything asserting on the
  /// inputs or the save action has to unlock it first.
  bool editing = false,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: BlocProvider<ProfileBloc>(
          // No event dispatched: the page renders from the initial state.
          create: (_) => ProfileBloc(ProfileUseCase(ProfileRepositoryImpl())),
          child: const ProfileDetailsPage(),
        ),
      ),
    ),
  );
  await tester.pump();

  if (editing) {
    await tester.tap(find.text(StringConstants.edit));
    await tester.pump();
  }
}

/// Every labelled input on the page, top to bottom.
List<Rect> _fieldRects(WidgetTester tester) {
  final Finder fields = find.byType(CustomTextField);
  return List<Rect>.generate(
    fields.evaluate().length,
    (int i) => tester.getRect(fields.at(i)),
  );
}

void main() {
  group('ProfileDetailsPage', () {
    for (final (String label, Size size) in <(String, Size)>[
      ('phone', _phone),
      ('tablet portrait', _tabletPortrait),
      ('desktop window', _desktopWindow),
    ]) {
      testWidgets('$label lays out without overflow', (
        WidgetTester tester,
      ) async {
        await _pumpAt(tester, size);

        expect(tester.takeException(), isNull);
        expect(find.text(StringConstants.personalDetails), findsOneWidget);
        expect(find.text('Personal information'), findsOneWidget);
        expect(find.text('Contact information'), findsOneWidget);
        // Read-only until Edit is tapped: no save action on arrival.
        expect(find.text(StringConstants.saveChanges), findsNothing);

        await tester.tap(find.text(StringConstants.edit));
        await tester.pump();
        expect(find.text(StringConstants.saveChanges), findsOneWidget);
      });

      testWidgets('$label keeps one form field per row', (
        WidgetTester tester,
      ) async {
        await _pumpAt(tester, size);

        // Fields must never be paired side by side, at any width.
        final List<Rect> rects = _fieldRects(tester);
        expect(rects.length, greaterThan(1));
        for (int i = 1; i < rects.length; i++) {
          expect(
            rects[i].top,
            greaterThanOrEqualTo(rects[i - 1].bottom),
            reason: 'field $i should sit below field ${i - 1} at $label',
          );
        }
      });
    }

    testWidgets('phone stretches the save button edge to edge', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _phone, editing: true);

      final double buttonWidth = tester
          .getSize(find.byType(CustomButton).first)
          .width;
      // Full content width: 411 minus the 20px insets.
      expect(buttonWidth, closeTo(411 - AppDimens.paddingX20 * 2, 1));
    });

    for (final (String label, Size size) in <(String, Size)>[
      ('tablet portrait', _tabletPortrait),
      ('desktop window', _desktopWindow),
    ]) {
      testWidgets('$label caps the save button instead of stretching it', (
        WidgetTester tester,
      ) async {
        await _pumpAt(tester, size, editing: true);

        expect(
          tester.getSize(find.byType(CustomButton).first).width,
          AppDimens.formActionMaxWidth,
        );
      });
    }

    testWidgets('tablet caps and centres the single form column', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _tabletPortrait);

      final List<Rect> rects = _fieldRects(tester);
      // Capped, not spanning the 800px window.
      expect(
        rects.first.width,
        lessThanOrEqualTo(AppDimens.formContentMaxWidth),
      );
      // Centred: equal gutters either side.
      final double leftGutter = rects.first.left;
      final double rightGutter = _tabletPortrait.width - rects.first.right;
      expect(leftGutter, closeTo(rightGutter, 2));
    });

    testWidgets('desktop puts the summary beside the form, not above it', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _desktopWindow);

      final Rect firstField = _fieldRects(tester).first;
      final Rect avatar = tester.getRect(find.byType(ClipOval).first);

      // Summary sits to the left of the form, sharing its vertical space.
      expect(avatar.right, lessThan(firstField.left));
      expect(avatar.top, lessThan(firstField.bottom));
    });
  });
}
