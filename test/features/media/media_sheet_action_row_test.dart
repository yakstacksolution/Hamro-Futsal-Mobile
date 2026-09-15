import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/media/data/repositories/media_repository_impl.dart';
import 'package:hamro_futsal/features/media/domain/usecase/media_use_case.dart';
import 'package:hamro_futsal/features/media/presentation/bloc/media_bloc.dart';
import 'package:hamro_futsal/features/media/presentation/widgets/media_library_sheet.dart';
import 'package:hamro_futsal/features/vendor/data/repositories/vendor_onboarding_repository_impl.dart';
import 'package:hamro_futsal/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_futsal/features/vendor/domain/usecase/vendor_onboarding_usecase.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

/// "A RenderFlex overflowed by 1.5 pixels on the right" from the media sheet's
/// Gallery / Camera / File buttons: each shares the row three ways, and their
/// labels were sized to their content — the ellipsis they asked for could
/// never apply because the text was not flexible.
Future<void> _pumpSheet(
  WidgetTester tester, {
  required double width,
  double textScale = 1.0,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 900);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final VendorOnboardingCubit cubit = VendorOnboardingCubit(
    const EphemeralVendorDraftRepository(),
    onboardingUseCase: VendorOnboardingUseCase(
      VendorOnboardingRepositoryImpl(),
    ),
  );
  addTearDown(cubit.close);
  final MediaBloc bloc = MediaBloc(MediaUseCase(MediaRepositoryImpl()));
  addTearDown(bloc.close);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: Scaffold(
          body: BlocProvider<MediaBloc>.value(
            value: bloc,
            // No fetch is dispatched, so the sheet renders its chrome — the
            // action row included — without reaching the network.
            child: MediaLibrarySheet(
              cubit: cubit,
              title: 'Group photo',
              subtitle: 'Choose a saved image or upload a new one.',
              allowedExtensions: const <String>['png', 'jpg', 'jpeg', 'webp'],
              allowMultiple: false,
              initiallySelected: const <UploadRef>[],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('the action row fits a narrow phone', (tester) async {
    await _pumpSheet(tester, width: 360);
    expect(tester.takeException(), isNull);
  });

  testWidgets('it fits the narrowest phone we support', (tester) async {
    await _pumpSheet(tester, width: 320);
    expect(tester.takeException(), isNull);
  });

  testWidgets('it fits at a large text scale', (tester) async {
    // The labels grow with the reader's font size; the buttons do not.
    await _pumpSheet(tester, width: 360, textScale: 1.6);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the labels ellipsise instead of overrunning', (tester) async {
    await _pumpSheet(tester, width: 320, textScale: 2.0);
    expect(tester.takeException(), isNull);
  });
}
