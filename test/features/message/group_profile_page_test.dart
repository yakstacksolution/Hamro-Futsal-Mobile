import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/domain/repository/message_repository.dart';
import 'package:hamro_futsal/features/message/domain/usecase/message_usecase.dart';
import 'package:hamro_futsal/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_futsal/features/message/presentation/pages/group_profile_page.dart';

void main() {
  const ConversationModel group = ConversationModel(
    id: 7,
    type: 'group',
    title: 'Weekend Team',
    participants: <ParticipantModel>[
      ParticipantModel(id: 1, userId: 4, name: 'Me'),
      ParticipantModel(id: 2, userId: 9, name: 'Ram'),
    ],
  );

  Widget wrap(MessageBloc bloc) => MaterialApp(
    home: BlocProvider<MessageBloc>.value(
      value: bloc,
      child: const GroupProfilePage(conversation: group),
    ),
  );

  // The sections used to be coloured Containers, which made Flutter assert that
  // the ListTiles inside them could paint neither background nor ink splash.
  // Any such assertion fails this test on the plain pump.
  testWidgets('renders the group, its members and its actions', (tester) async {
    final MessageBloc bloc = MessageBloc(MessageUseCase(_StubRepository()));
    addTearDown(bloc.close);

    await tester.pumpWidget(wrap(bloc));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Team'), findsOneWidget);
    expect(find.text('2 members'), findsOneWidget);
    expect(find.text('Ram'), findsOneWidget);
    expect(find.text('Add members'), findsOneWidget);
    expect(find.text('Leave group'), findsOneWidget);
  });

  testWidgets('tapping the name opens the rename sheet', (tester) async {
    final MessageBloc bloc = MessageBloc(MessageUseCase(_StubRepository()));
    addTearDown(bloc.close);

    await tester.pumpWidget(wrap(bloc));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Change group name'), findsOneWidget);
  });
}

/// Only [currentUserId] is read while the page builds; anything else would
/// throw rather than pass silently.
final class _StubRepository extends Fake implements MessageRepository {
  @override
  int get currentUserId => 4;
}
