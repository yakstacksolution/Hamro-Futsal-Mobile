import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/data/model/registered_user_page_model.dart';
import 'package:hamro_futsal/features/message/presentation/pages/create_group_conversation_page.dart';
import 'package:hamro_futsal/features/message/presentation/widgets/group_member_widgets.dart';

void main() {
  RegisteredUserPageModel usersPage({
    required int page,
    required List<ParticipantModel> users,
    bool hasMorePages = false,
  }) {
    return RegisteredUserPageModel(
      items: users,
      currentPage: page,
      lastPage: hasMorePages ? page + 1 : page,
      perPage: 15,
      total: users.length,
      hasMorePages: hasMorePages,
    );
  }

  final ram = ParticipantModel(
    id: 1,
    userId: 9,
    name: 'Ram',
    email: 'ram@example.com',
  );

  for (final width in [320.0, 1200.0]) {
    testWidgets('form fits at $width with large text and keyboard', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const CreateGroupConversationPage(
            currentUserId: 4,
            participants: [ParticipantModel(id: 1, userId: 9, name: 'Ram')],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final button = tester.getRect(find.text('Create group'));
      expect(button.bottom, lessThanOrEqualTo(520));
      if (width > 640) {
        expect(tester.getSize(find.byType(ListView).first).width, 600);
      }
      await tester.scrollUntilVisible(
        find.text('Ram'),
        100,
        scrollable: find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      // The row can stop half-clipped by the viewport edge, where its centre
      // is not hittable — bring it fully into view before tapping.
      await tester.ensureVisible(find.text('Ram'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ram'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('1/50'),
        -100,
        scrollable: find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('1/50'), findsOneWidget);
    });
  }

  testWidgets('creates a group from the create-group page', (tester) async {
    GroupConversationDraft? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () async {
                  result = await CreateGroupConversationPage.open(
                    context,
                    currentUserId: 4,
                    participants: <ParticipantModel>[],
                    registeredUsersLoader:
                        ({
                          required int page,
                          required int perPage,
                          required String search,
                        }) async => usersPage(page: page, users: [ram]),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Create Group'), findsOneWidget);
    expect(find.text('Add members'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Weekend Team');
    await tester.tap(find.text('Ram'));
    await tester.pumpAndSettle();

    // The member section reports the current selection.
    expect(find.text('1/50'), findsOneWidget);

    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();

    expect(result?.title, 'Weekend Team');
    expect(result?.participantIds, [9]);
  });

  testWidgets('searches registered users through the loader', (tester) async {
    final calls = <String>[];
    final perPages = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: CreateGroupConversationPage(
          currentUserId: 4,
          participants: const <ParticipantModel>[],
          registeredUsersLoader:
              ({
                required int page,
                required int perPage,
                required String search,
              }) async {
                calls.add('$page:$search');
                perPages.add(perPage);
                return usersPage(
                  page: page,
                  users: search.isEmpty
                      ? [ram]
                      : const [
                          ParticipantModel(
                            id: 2,
                            userId: 10,
                            name: 'Sita',
                            email: 'sita@example.com',
                          ),
                        ],
                );
              },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Ram'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'sita');
    // The member search waits 3s after the last keystroke before it calls
    // `/auth/register-user`.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(calls, contains('1:'));
    expect(calls, contains('1:sita'));
    expect(perPages, everyElement(15));
    expect(find.text('Ram'), findsNothing);
    expect(find.text('Sita'), findsOneWidget);
  });

  testWidgets('loads the next registered-user page near the bottom', (
    tester,
  ) async {
    final calls = <int>[];
    final perPages = <int>[];
    final firstPage = List<ParticipantModel>.generate(
      18,
      (index) => ParticipantModel(
        id: index + 1,
        userId: index + 10,
        name: 'User ${index + 1}',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CreateGroupConversationPage(
          currentUserId: 4,
          participants: const <ParticipantModel>[],
          registeredUsersLoader:
              ({
                required int page,
                required int perPage,
                required String search,
              }) async {
                calls.add(page);
                perPages.add(perPage);
                return usersPage(
                  page: page,
                  hasMorePages: page == 1,
                  users: page == 1
                      ? firstPage
                      : const [
                          ParticipantModel(id: 99, userId: 99, name: 'Sita'),
                        ],
                );
              },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('User 18'),
      500,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect(calls, containsAllInOrder([1, 2]));
    expect(perPages, everyElement(15));
    expect(find.text('Sita'), findsOneWidget);
  });

  testWidgets('an incomplete form says what is missing instead of doing '
      'nothing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => CreateGroupConversationPage.open(
                  context,
                  currentUserId: 4,
                  participants: <ParticipantModel>[],
                  registeredUsersLoader:
                      ({
                        required int page,
                        required int perPage,
                        required String search,
                      }) async => usersPage(page: page, users: [ram]),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // No name, nobody selected: the button is live and reports the first
    // thing that is missing.
    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a group name.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Weekend Team');
    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();
    expect(find.text('Select at least one member.'), findsOneWidget);
  });
}
