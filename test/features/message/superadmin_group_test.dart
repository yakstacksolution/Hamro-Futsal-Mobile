import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/data/model/chat_message_model.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/domain/repository/message_repository.dart';
import 'package:hamro_futsal/features/message/domain/usecase/message_usecase.dart';
import 'package:hamro_futsal/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_futsal/features/message/presentation/pages/group_profile_page.dart';

/// A group someone else set up centrally: the members own neither its name nor
/// its picture, so the screen offers no way to change either.
ConversationModel _group({required bool superadmin}) =>
    ConversationModel.fromJson(<String, dynamic>{
      'id': 105,
      'type': 'group',
      'title': 'Neww',
      'is_superadmin_created_group': superadmin,
      'participants': <Map<String, dynamic>>[
        <String, dynamic>{'user_id': 1, 'name': 'Dilli'},
        <String, dynamic>{'user_id': 2, 'name': 'Ram'},
      ],
    });

Future<void> _pump(WidgetTester tester, ConversationModel group) async {
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
          child: GroupProfilePage(conversation: group),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  test('a message reports the group it belongs to', () {
    final ChatMessageModel message = ChatMessageModel.fromJson(
      <String, dynamic>{
        'id': 379,
        'conversation_id': 105,
        'is_superadmin_created_group': true,
        'sender_id': 19,
        'sender_name': 'Rosnnnnn',
        'type': 'text',
        'body': 'Llll',
        'status': 'sent',
        'metadata': <dynamic>[],
        'created_at': '2026-09-19 21:31:26',
      },
    );

    expect(message.isSuperadminCreatedGroup, isTrue);
    expect(message.body, 'Llll');
  });

  test('a message without the flag leaves the group editable', () {
    final ChatMessageModel message = ChatMessageModel.fromJson(
      <String, dynamic>{'id': 1, 'conversation_id': 2, 'sender_id': 3},
    );

    expect(message.isSuperadminCreatedGroup, isFalse);
  });

  test('a conversation picks the flag up from its latest message', () {
    // The conversation payload does not always carry the flag; the message
    // resource nested in it does.
    final ConversationModel conversation = ConversationModel.fromJson(
      <String, dynamic>{
        'id': 105,
        'type': 'group',
        'last_message': <String, dynamic>{
          'id': 379,
          'conversation_id': 105,
          'is_superadmin_created_group': true,
          'sender_id': 19,
          'body': 'Llll',
        },
      },
    );

    expect(conversation.isSuperadminCreatedGroup, isTrue);
  });

  test('withLatestMessage keeps a flag the conversation already had', () {
    final ConversationModel conversation = _group(superadmin: true);
    final ChatMessageModel plain = ChatMessageModel(
      id: 1,
      conversationId: 105,
      senderId: 2,
      body: 'hi',
      createdAt: DateTime(2026, 9, 19),
    );

    expect(
      conversation.withLatestMessage(plain).isSuperadminCreatedGroup,
      isTrue,
    );
  });

  testWidgets('a superadmin group hides the photo and name editing', (
    tester,
  ) async {
    await _pump(tester, _group(superadmin: true));

    expect(find.byIcon(Icons.photo_camera_rounded), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('a superadmin group offers no per-member overflow menu', (
    tester,
  ) async {
    await _pump(tester, _group(superadmin: true));

    // Nobody may be blocked from a group the members do not own.
    expect(find.byIcon(Icons.more_vert_rounded), findsNothing);
  });

  testWidgets('an ordinary group can still block a member', (tester) async {
    await _pump(tester, _group(superadmin: false));

    // One row per member other than the signed-in user.
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
  });

  testWidgets('an ordinary group keeps both', (tester) async {
    await _pump(tester, _group(superadmin: false));

    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
  });
}

final class _FakeRepository extends Fake implements MessageRepository {
  @override
  int get currentUserId => 1;
}
