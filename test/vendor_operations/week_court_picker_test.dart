import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/vendor_operations/data/demo/vendor_ops_demo.dart';
import 'package:hamro_futsal/features/vendor_operations/data/service/vendor_ops_socket_service.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/bloc/vendor_ops_bloc.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_week_table.dart';

/// The demo venues, cut down to [keep] of their courts.
final class _FewCourtsStore extends VendorOpsDemoStore {
  _FewCourtsStore(this.keep);

  final int keep;

  @override
  List<OpsCourt> courts() => super.courts().take(keep).toList();
}

/// The Week table's court strip is a choice between courts, so it shows only
/// when there are courts to choose between.
void main() {
  setUp(() {
    // Saturday 26 Sep 2026, 10:00 in Kathmandu.
    KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 26, 4, 15));
  });
  tearDown(() => KathmanduClock.debugSetUtcNow(null));

  /// The Week table alone, over a bloc the provider owns — disposing the
  /// tree closes it, as on the real page.
  Future<void> openWeek(WidgetTester tester, int courts) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: FutsalTheme.lightTheme,
        home: Scaffold(
          body: BlocProvider<VendorOpsBloc>(
            create: (_) =>
                VendorOpsBloc(
                    repository: DemoVendorOpsRepository(
                      _FewCourtsStore(courts),
                    ),
                    socket: const NoopVendorOpsSocketService(),
                  )
                  ..add(const VendorOpsStarted())
                  ..add(const VendorOpsViewChanged(OpsAvailabilityView.week)),
            child: SingleChildScrollView(
              child: OpsWeekTableView(onBookingTap: (_) {}),
            ),
          ),
        ),
      ),
    );
    for (int i = 0; i < 10; i++) {
      await tester.pump(VendorOpsDemoStore.latency ~/ 2);
    }
  }

  testWidgets('one court: no court strip, the table is that court', (
    tester,
  ) async {
    await openWeek(tester, 1);
    expect(find.text('Court 1 · Peak pricing'), findsNothing);
    expect(find.text('Dhananjay Sports Arena'), findsNothing);
    // The week's own controls lead instead.
    expect(find.text('Sep 20 – 26, 2026'), findsOneWidget);
    expect(find.byKey(const Key('ops-week-start')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('two courts: the strip offers both', (tester) async {
    await openWeek(tester, 2);
    expect(find.text('Court 1 · Peak pricing'), findsOneWidget);
    expect(find.text('Court 2 · 90-min slots'), findsOneWidget);
    expect(find.text('Sep 20 – 26, 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
