import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/features/auth/data/repositories/authentication_repository_impl.dart';
import 'package:hamro_futsal/features/auth/domain/usecase/authentication_usecase.dart';
import 'package:hamro_futsal/features/auth/presentation/authentication_bloc/authentication_bloc.dart';
import 'package:hamro_futsal/features/auth/presentation/create_new_password_screen.dart';
import 'package:hamro_futsal/features/auth/presentation/forgot_password_screen.dart';
import 'package:hamro_futsal/features/auth/presentation/otp_verification_screen.dart';
import 'package:hamro_futsal/features/auth/presentation/widgets/auth_screen_frame.dart';
import 'package:hamro_futsal/features/auth/presentation/widgets/otp_digit_field.dart';
import 'package:hamro_futsal/features/auth/presentation/widgets/register_form.dart';

/// Sizes representing each breakpoint we support.
const Size _phone = Size(411, 891);
const Size _tabletPortrait = Size(800, 1280);
const Size _tabletLandscape = Size(1280, 800);
const Size _desktopWindow = Size(1440, 900);

Future<void> _pumpAt(
  WidgetTester tester,
  Size size,
  Widget child, {
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? _) {
        return MaterialApp(home: child);
      },
    ),
  );
  // Screens with a repeating resend timer never settle.
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

AuthScreenFrame _frame({AuthAudience audience = AuthAudience.general}) {
  return AuthScreenFrame(
    audience: audience,
    title: 'Welcome back',
    subtitle: 'Sign in to continue',
    primaryButtonLabel: 'Sign in',
    onPrimaryTap: () {},
    secondaryPrefixText: 'New here',
    secondaryActionText: 'Create account',
    onSecondaryTap: () {},
    formFields: <Widget>[
      const TextField(key: Key('email')),
      const SizedBox(height: AppDimens.sizeX18),
      const TextField(key: Key('password')),
    ],
  );
}

void main() {
  group('AuthScreenFrame renders at every breakpoint', () {
    for (final (String label, Size size) in <(String, Size)>[
      ('phone', _phone),
      ('tablet portrait', _tabletPortrait),
      ('tablet landscape', _tabletLandscape),
      ('desktop window', _desktopWindow),
    ]) {
      testWidgets('$label lays out without overflow', (
        WidgetTester tester,
      ) async {
        await _pumpAt(tester, size, _frame());

        expect(tester.takeException(), isNull);
        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.text('Sign in'), findsOneWidget);
        expect(find.byKey(const Key('email')), findsOneWidget);
      });
    }

    testWidgets('phone layout shows no brand panel', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _phone, _frame());
      expect(find.text(StringConstants.authBrandTagline), findsNothing);
    });

    testWidgets('tablet portrait shows no brand panel', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _tabletPortrait, _frame());
      expect(find.text(StringConstants.authBrandTagline), findsNothing);
    });

    testWidgets('wide layouts show the two-pane brand panel', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _tabletLandscape, _frame());
      expect(find.text(StringConstants.authBrandTagline), findsOneWidget);
      expect(find.text(StringConstants.authBrandHighlightBook), findsOneWidget);
    });

    for (final (String label, Size size) in <(String, Size)>[
      ('tablet landscape', _tabletLandscape),
      ('desktop window', _desktopWindow),
    ]) {
      testWidgets('$label brand panel fits without scrolling', (
        WidgetTester tester,
      ) async {
        await _pumpAt(tester, size, _frame());

        // Every brand-panel item is fully on screen -- nothing clipped and no
        // scrolling needed to reach the last highlight.
        for (final String text in <String>[
          StringConstants.hamroFutsal,
          StringConstants.authBrandTagline,
          StringConstants.authBrandHighlightBook,
          StringConstants.authBrandHighlightPlay,
        ]) {
          final Rect rect = tester.getRect(find.text(text));
          expect(rect.top, greaterThanOrEqualTo(0.0), reason: text);
          expect(rect.bottom, lessThanOrEqualTo(size.height), reason: text);
        }

        // Panes split the width evenly, and the panel content stays left of
        // the divide.
        final double half = size.width / 2;
        expect(
          tester.getRect(find.text(StringConstants.hamroFutsal)).right,
          lessThan(half),
        );
      });
    }

    testWidgets('brand panel fills the full height of the window', (
      WidgetTester tester,
    ) async {
      // A shared SafeArea around the Row would stop the panel's colour short
      // of the status and navigation bars.
      tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
      addTearDown(() => tester.view.resetPadding());

      await _pumpAt(tester, _desktopWindow, _frame());

      // The panel is the box painted in the app colour.
      final Rect panel = tester.getRect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is DecoratedBox &&
              w.decoration ==
                  const BoxDecoration(color: LightColor.secondaryColor),
        ),
      );
      expect(panel.top, 0);
      expect(panel.bottom, _desktopWindow.height);
      expect(panel.left, 0);
      // Left half of the window.
      expect(panel.width, closeTo(_desktopWindow.width / 2, 1));
    });

    testWidgets('general audience shows the neutral pitch', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _desktopWindow, _frame());

      expect(find.text(StringConstants.hamroFutsal), findsOneWidget);
      expect(find.text(StringConstants.authBrandTagline), findsOneWidget);
      expect(find.text(StringConstants.authBrandHighlightBook), findsOneWidget);
      // No audience-specific copy leaks in.
      expect(find.text(StringConstants.authPlayerTagline), findsNothing);
      expect(find.text(StringConstants.authVendorTagline), findsNothing);
    });

    testWidgets('player audience shows the player pitch', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _desktopWindow,
        _frame(audience: AuthAudience.player),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(StringConstants.authPlayerHeadline), findsOneWidget);
      expect(find.text(StringConstants.authPlayerTagline), findsOneWidget);
      for (final String h in <String>[
        StringConstants.authPlayerHighlightDiscover,
        StringConstants.authPlayerHighlightBook,
        StringConstants.authPlayerHighlightCompete,
      ]) {
        expect(find.text(h), findsOneWidget, reason: h);
      }
      expect(find.text(StringConstants.authVendorTagline), findsNothing);
    });

    testWidgets('vendor audience shows the vendor pitch', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _desktopWindow,
        _frame(audience: AuthAudience.vendor),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(StringConstants.authVendorHeadline), findsOneWidget);
      expect(find.text(StringConstants.authVendorTagline), findsOneWidget);
      for (final String h in <String>[
        StringConstants.authVendorHighlightList,
        StringConstants.authVendorHighlightAutomate,
        StringConstants.authVendorHighlightInsights,
      ]) {
        expect(find.text(h), findsOneWidget, reason: h);
      }
      expect(find.text(StringConstants.authPlayerTagline), findsNothing);
    });

    testWidgets('audience copy still fits the panel without clipping', (
      WidgetTester tester,
    ) async {
      // The vendor copy is the longest, so it is the one that could overflow.
      for (final (String label, Size size) in <(String, Size)>[
        ('tablet landscape', _tabletLandscape),
        ('desktop window', _desktopWindow),
      ]) {
        await _pumpAt(tester, size, _frame(audience: AuthAudience.vendor));
        expect(tester.takeException(), isNull, reason: label);

        for (final String text in <String>[
          StringConstants.authVendorHeadline,
          StringConstants.authVendorTagline,
          StringConstants.authVendorHighlightInsights,
        ]) {
          final Rect r = tester.getRect(find.text(text));
          expect(r.top, greaterThanOrEqualTo(0.0), reason: '$label $text');
          expect(r.bottom, lessThanOrEqualTo(size.height), reason: label);
          expect(r.right, lessThan(size.width / 2), reason: label);
        }
      }
    });

    testWidgets('phone shows no audience copy at all', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _phone, _frame(audience: AuthAudience.vendor));
      expect(find.text(StringConstants.authVendorTagline), findsNothing);
      expect(find.text(StringConstants.authBrandTagline), findsNothing);
    });

    testWidgets('phone card width is unchanged at 520', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _phone, _frame());
      final ConstrainedBox box = tester.widget<ConstrainedBox>(
        find
            .descendant(
              of: find.byType(SingleChildScrollView),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(box.constraints.maxWidth, AppDimens.authCardMaxWidth);
    });
  });

  group('Forgot password screen', () {
    Widget forgotPasswordScreen() {
      return BlocProvider<AuthenticationBloc>(
        create: (_) =>
            AuthenticationBloc(AuthUseCase(AuthenticationRepositoryImpl())),
        child: const ForgotPasswordScreen(),
      );
    }

    for (final (String label, Size size) in <(String, Size)>[
      ('phone', _phone),
      ('tablet portrait', _tabletPortrait),
      ('tablet landscape', _tabletLandscape),
    ]) {
      testWidgets('$label lays out without overflow', (
        WidgetTester tester,
      ) async {
        await _pumpAt(tester, size, forgotPasswordScreen());

        expect(tester.takeException(), isNull);
        expect(find.text(StringConstants.forgotPassword), findsOneWidget);
        expect(find.text('Send OTP'), findsOneWidget);
      });
    }
  });

  group('OTP verification screen', () {
    Widget otpScreen() {
      return BlocProvider<AuthenticationBloc>(
        create: (_) =>
            AuthenticationBloc(AuthUseCase(AuthenticationRepositoryImpl())),
        child: const OtpVerificationScreen(email: 'player@example.com'),
      );
    }

    for (final (String label, Size size) in <(String, Size)>[
      ('phone', _phone),
      ('tablet portrait', _tabletPortrait),
      ('tablet landscape', _tabletLandscape),
      ('desktop window', _desktopWindow),
    ]) {
      testWidgets('$label lays out 6 digit fields without overflow', (
        WidgetTester tester,
      ) async {
        await _pumpAt(tester, size, otpScreen(), settle: false);

        expect(tester.takeException(), isNull);
        expect(find.text(StringConstants.otpVerification), findsOneWidget);
        // 6 OTP boxes; the frame itself adds no other TextFields.
        expect(find.byType(TextField), findsNWidgets(6));
      });
    }

    testWidgets('pasting a full code fills all digit fields', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _phone, otpScreen(), settle: false);

      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.pump();

      for (int i = 0; i < 6; i++) {
        final TextField field = tester.widget<TextField>(
          find.byType(TextField).at(i),
        );
        expect(field.controller?.text, '${i + 1}');
      }
    });
  });

  group('Register form', () {
    Widget registerForm() {
      return Scaffold(
        body: SingleChildScrollView(
          child: RegisterForm(
            formKey: GlobalKey<FormState>(),
            autovalidateMode: AutovalidateMode.disabled,
            obscurePassword: true,
            obscureConfirmPassword: true,
            selectedAccountType: null,
            acceptedTerms: false,
            accountTypes: const <String>['Player', 'Vendor'],
            onTogglePassword: () {},
            onToggleConfirmPassword: () {},
            onAccountTypeChanged: (_) {},
            onTermsChanged: (_) {},
            onTermsTap: () {},
            onPrivacyPolicyTap: () {},
            nameController: TextEditingController(),
            emailController: TextEditingController(),
            passwordController: TextEditingController(),
            confirmPasswordController: TextEditingController(),
            nameFocus: FocusNode(),
            accountTypeFocus: FocusNode(),
            emailFocus: FocusNode(),
            passwordFocus: FocusNode(),
            confirmPasswordFocus: FocusNode(),
            nameValidator: (_) => null,
            emailValidator: (_) => null,
            passwordValidator: (_) => null,
            confirmPasswordValidator: (_) => null,
          ),
        ),
      );
    }

    // Every width keeps a single column -- fields are never paired side by
    // side, including on tablet and desktop.
    for (final (String label, Size size) in <(String, Size)>[
      ('phone', _phone),
      ('tablet portrait', _tabletPortrait),
      ('tablet landscape', _tabletLandscape),
      ('desktop window', _desktopWindow),
    ]) {
      testWidgets('$label stacks every field in one column', (
        WidgetTester tester,
      ) async {
        await _pumpAt(tester, size, registerForm());

        expect(tester.takeException(), isNull);

        // Each field label sits strictly below the previous one.
        final List<double> tops =
            <String>[
                  StringConstants.fullName,
                  StringConstants.accountType,
                  StringConstants.emailAddress,
                  StringConstants.password,
                  StringConstants.confirmPassword,
                ]
                .map((String label) => tester.getTopLeft(find.text(label)).dy)
                .toList();

        for (int i = 1; i < tops.length; i++) {
          expect(
            tops[i],
            greaterThan(tops[i - 1]),
            reason: 'field $i should be below field ${i - 1}',
          );
        }
      });
    }
  });

  group('Create new password screen', () {
    Widget createNewPasswordScreen() {
      return BlocProvider<AuthenticationBloc>(
        create: (_) =>
            AuthenticationBloc(AuthUseCase(AuthenticationRepositoryImpl())),
        child: const CreateNewPasswordScreen(email: 'player@example.com'),
      );
    }

    for (final (String label, Size size) in <(String, Size)>[
      ('phone', _phone),
      ('tablet portrait', _tabletPortrait),
      ('tablet landscape', _tabletLandscape),
    ]) {
      testWidgets('$label lays out the code and both password fields', (
        WidgetTester tester,
      ) async {
        await _pumpAt(tester, size, createNewPasswordScreen(), settle: false);

        expect(tester.takeException(), isNull);
        expect(find.text(StringConstants.createNewPassword), findsOneWidget);
        expect(find.text(StringConstants.newPassword), findsOneWidget);
        expect(find.text(StringConstants.confirmPassword), findsOneWidget);
        // Six code boxes, and the address is masked rather than shown whole.
        expect(find.byType(OtpDigitField), findsNWidgets(6));
        expect(find.textContaining('pl***@example.com'), findsOneWidget);
      });
    }

    testWidgets('hides the code row when the code is already verified', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _phone,
        BlocProvider<AuthenticationBloc>(
          create: (_) =>
              AuthenticationBloc(AuthUseCase(AuthenticationRepositoryImpl())),
          child: const CreateNewPasswordScreen(
            email: 'player@example.com',
            otp: '123456',
          ),
        ),
        settle: false,
      );

      expect(tester.takeException(), isNull);
      // The OTP screen already proved the code, so it is not asked for again.
      expect(find.byType(OtpDigitField), findsNothing);
      expect(find.text(StringConstants.newPassword), findsOneWidget);
      // ...and the reset can be submitted as soon as the passwords are valid.
      expect(
        tester
            .widget<CustomButton>(
              find.widgetWithText(CustomButton, StringConstants.resetPassword),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('will not submit until the code is complete', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _phone, createNewPasswordScreen(), settle: false);

      final Finder button = find.widgetWithText(
        CustomButton,
        StringConstants.resetPassword,
      );
      expect(button, findsOneWidget);
      // Disabled is expressed as a null onPressed by AuthScreenFrame.
      expect(tester.widget<CustomButton>(button).onPressed, isNull);

      for (int i = 0; i < 6; i++) {
        await tester.enterText(find.byType(OtpDigitField).at(i), '1');
        await tester.pump();
      }

      expect(tester.widget<CustomButton>(button).onPressed, isNotNull);
    });

    testWidgets('reports a password mismatch instead of submitting', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _phone, createNewPasswordScreen(), settle: false);

      for (int i = 0; i < 6; i++) {
        await tester.enterText(find.byType(OtpDigitField).at(i), '1');
        await tester.pump();
      }
      await tester.enterText(
        find.widgetWithText(TextFormField, StringConstants.newPassword),
        'newpassword123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, StringConstants.confirmPassword),
        'newpassword124',
      );
      await tester.tap(
        find.widgetWithText(CustomButton, StringConstants.resetPassword),
      );
      await tester.pump();

      expect(find.text(StringConstants.passwordsDoNotMatch), findsOneWidget);
    });
  });
}
