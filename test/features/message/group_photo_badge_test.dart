import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/domain/repository/message_repository.dart';
import 'package:hamro_futsal/features/message/domain/usecase/message_usecase.dart';
import 'package:hamro_futsal/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_futsal/features/message/presentation/pages/group_profile_page.dart';

/// The camera badge sits past the edge of the group picture, where the
/// picture's own InkWell does not reach. As a plain Container it looked like
/// the button for changing the photo and did nothing when tapped.
ConversationModel _group() => ConversationModel.fromJson(<String, dynamic>{
  'id': 91,
  'type': 'group',
  'title': 'Neww',
  'participants': <Map<String, dynamic>>[
    <String, dynamic>{'user_id': 1, 'name': 'Dilli'},
    <String, dynamic>{'user_id': 2, 'name': 'Ram'},
  ],
});

Future<void> _pump(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(411, 900);
  addTearDown(tester.view.reset);

  final MessageBloc bloc = MessageBloc(MessageUseCase(_FakeRepository()));
  addTearDown(bloc.close);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: BlocProvider<MessageBloc>.value(
          value: bloc,
          child: GroupProfilePage(conversation: _group()),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// The nearest enabled tap handler above [finder], or null when there is none.
InkWell? _tapHandlerAbove(WidgetTester tester, Finder finder) {
  final Iterable<InkWell> wells = tester.widgetList<InkWell>(
    find.ancestor(of: finder, matching: find.byType(InkWell)),
  );
  for (final InkWell well in wells) {
    if (well.onTap != null) return well;
  }
  return null;
}

void main() {
  testWidgets('the camera badge is tappable', (tester) async {
    await _pump(tester);

    final Finder badge = find.byIcon(Icons.photo_camera_rounded);
    expect(badge, findsOneWidget);
    expect(
      _tapHandlerAbove(tester, badge),
      isNotNull,
      reason: 'the badge has no tap handler of its own',
    );
  });

  testWidgets('its touch target is big enough to hit', (tester) async {
    await _pump(tester);

    final Finder badge = find.byIcon(Icons.photo_camera_rounded);
    final Size target = tester.getSize(
      find.ancestor(of: badge, matching: find.byType(InkWell)).first,
    );
    // 34pt of badge plus the transparent padding around it.
    expect(target.width, greaterThanOrEqualTo(44));
    expect(target.height, greaterThanOrEqualTo(44));
  });

  testWidgets('the whole target sits inside the picture, so taps land', (
    tester,
  ) async {
    await _pump(tester);

    final Finder badge = find.byIcon(Icons.photo_camera_rounded);
    final Rect target = tester.getRect(
      find.ancestor(of: badge, matching: find.byType(InkWell)).first,
    );
    final Rect stack = tester.getRect(
      find.ancestor(of: badge, matching: find.byType(Stack)).first,
    );

    // A child positioned outside its stack paints but cannot be hit.
    expect(target.right, lessThanOrEqualTo(stack.right + 0.5));
    expect(target.bottom, lessThanOrEqualTo(stack.bottom + 0.5));
  });

  testWidgets('a tap on the badge reaches its handler', (tester) async {
    await _pump(tester);

    final Finder badge = find.byIcon(Icons.photo_camera_rounded);
    // The badge's own InkWell is what a tap at its centre lands on. Before the
    // fix the nearest handler was the picture's, which does not cover this
    // point — so this finds nothing to hit.
    final Finder handler = find
        .ancestor(of: badge, matching: find.byType(InkWell))
        .first;
    final Rect target = tester.getRect(handler);

    expect(target.contains(tester.getCenter(badge)), isTrue);
    expect(tester.widget<InkWell>(handler).onTap, isNotNull);
  });
}

final class _FakeRepository extends Fake implements MessageRepository {
  @override
  int get currentUserId => 1;
}
