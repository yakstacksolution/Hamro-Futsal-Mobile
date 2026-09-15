import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/data/model/registered_user_page_model.dart';
import 'package:hamro_futsal/features/message/presentation/pages/create_group_conversation_page.dart';
import 'package:hamro_futsal/features/message/presentation/widgets/group_conversation_sheet.dart';
import 'package:hamro_futsal/features/message/presentation/widgets/group_member_widgets.dart';

void main() {
  RegisteredUserPageModel usersPage({
    required int page,
    required List<ParticipantModel> users,
    bool hasMorePages = false,
  }) => RegisteredUserPageModel(
    items: users,
    currentPage: page,
    lastPage: hasMorePages ? page + 1 : page,
    perPage: 15,
    total: users.length,
    hasMorePages: hasMorePages,
  );

  ParticipantModel user(int id, String name) =>
      ParticipantModel(id: id, userId: id, name: name, email: '$name@x.com');

  Future<void> pumpSheet(
    WidgetTester tester, {
    required RegisteredUsersLoader loader,
    Set<int> excluded = const <int>{4},
    List<ParticipantModel> seed = const <ParticipantModel>[],
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddGroupMembersForm(
            candidates: seed,
            excludedUserIds: excluded,
            registeredUsersLoader: loader,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loads registered users the moment it opens', (tester) async {
    final calls = <Map<String, Object>>[];
    await pumpSheet(
      tester,
      loader: ({required page, required perPage, required search}) async {
        calls.add({'page': page, 'perPage': perPage, 'search': search});
        return usersPage(page: page, users: [user(9, 'Ram'), user(10, 'Sita')]);
      },
    );

    expect(calls, [
      {'page': 1, 'perPage': 15, 'search': ''},
    ]);
    expect(find.text('Ram'), findsOneWidget);
    expect(find.text('Sita'), findsOneWidget);
  });

  testWidgets('people already in the group are not offered again', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      excluded: <int>{4, 9},
      loader: ({required page, required perPage, required search}) async =>
          usersPage(page: page, users: [user(9, 'Ram'), user(10, 'Sita')]),
    );

    expect(find.text('Ram'), findsNothing);
    expect(find.text('Sita'), findsOneWidget);
  });

  testWidgets('searching asks the server for a fresh first page', (
    tester,
  ) async {
    final searches = <String>[];
    await pumpSheet(
      tester,
      loader: ({required page, required perPage, required search}) async {
        searches.add(search);
        return usersPage(
          page: page,
          users: search.isEmpty ? [user(9, 'Ram')] : [user(10, 'Sita')],
        );
      },
    );

    await tester.enterText(find.byType(TextFormField).first, 'sit');
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(searches, ['', 'sit']);
    expect(find.text('Ram'), findsNothing);
    expect(find.text('Sita'), findsOneWidget);
  });

  testWidgets('scrolling near the bottom loads the next page', (tester) async {
    final pages = <int>[];
    await pumpSheet(
      tester,
      loader: ({required page, required perPage, required search}) async {
        pages.add(page);
        return usersPage(
          page: page,
          hasMorePages: page < 2,
          users: <ParticipantModel>[
            for (int i = 0; i < 15; i++) user(page * 100 + i, 'User $page-$i'),
          ],
        );
      },
    );

    expect(pages, [1]);
    await tester.drag(find.byType(ListView).first, const Offset(0, -2500));
    await tester.pumpAndSettle();

    expect(pages, [1, 2]);
    expect(find.text('User 2-0'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    int attempts = 0;
    await pumpSheet(
      tester,
      loader: ({required page, required perPage, required search}) async {
        attempts++;
        if (attempts == 1) throw Exception('boom');
        return usersPage(page: page, users: [user(9, 'Ram')]);
      },
    );

    expect(find.byType(GroupMembersErrorCard), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Ram'), findsOneWidget);
  });

  testWidgets('selected people come back as ids', (tester) async {
    List<int>? result;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showAddGroupMembersSheet(
                  context: context,
                  participants: const <ParticipantModel>[],
                  excludedUserIds: <int>{4},
                  registeredUsersLoader:
                      ({
                        required page,
                        required perPage,
                        required search,
                      }) async => usersPage(
                        page: page,
                        users: [user(9, 'Ram'), user(10, 'Sita')],
                      ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sita'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add 1 member'));
    await tester.pumpAndSettle();

    expect(result, [10]);
  });

  testWidgets('the sheet draws one drag handle, not two', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAddGroupMembersSheet(
                context: context,
                participants: const <ParticipantModel>[],
                excludedUserIds: <int>{4},
                registeredUsersLoader:
                    ({
                      required page,
                      required perPage,
                      required search,
                    }) async => usersPage(page: page, users: [user(9, 'Ram')]),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Both handles are 4pt-tall rounded bars; one is the sheet's own.
    final handles = tester.widgetList<Container>(find.byType(Container)).where((
      c,
    ) {
      final constraints = c.constraints;
      return constraints != null &&
          constraints.maxHeight == 4 &&
          constraints.maxWidth < 60;
    });
    expect(handles.length, 1);
  });
}
