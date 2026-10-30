import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/l10n/app_language.dart';
import 'package:hamro_futsal/core/l10n/app_locale_controller.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

Map<String, dynamic> _arb(String code) =>
    jsonDecode(File('lib/core/l10n/arb/app_$code.arb').readAsStringSync())
        as Map<String, dynamic>;

Iterable<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((String key) => !key.startsWith('@'));

/// Names used as `{name}` or `{name, plural|select, ...}` in a message.
Set<String> _placeholders(String message) => RegExp(
  r'\{\s*(\w+)\s*[,}]',
).allMatches(message).map((RegExpMatch m) => m.group(1)!).toSet();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Map<String, dynamic> en = _arb('en');

  for (final AppLanguage language in AppLanguage.values) {
    if (language == AppLanguage.english) continue;
    group('${language.nativeName} translations', () {
      final Map<String, dynamic> arb = _arb(language.code);

      test('cover exactly the English keys', () {
        expect(_messageKeys(arb).toSet(), _messageKeys(en).toSet());
      });

      test('only use declared placeholders', () {
        final List<String> problems = <String>[];
        for (final String key in _messageKeys(en)) {
          final Map<String, dynamic>? declared =
              (en['@$key'] as Map<String, dynamic>?)?['placeholders']
                  as Map<String, dynamic>?;
          final Set<String> allowed = declared?.keys.toSet() ?? <String>{};
          final Set<String> used = _placeholders(arb[key] as String);
          if (!allowed.containsAll(used)) problems.add('$key: $used');
        }
        expect(problems, isEmpty);
      });
    });
  }

  test('StringConstants follows the selected language', () {
    final AppLocaleController controller = AppLocaleController.instance;
    final AppLanguage original = controller.value;
    addTearDown(() => controller.value = original);

    controller.value = AppLanguage.english;
    expect(StringConstants.language, en['language']);

    for (final AppLanguage language in <AppLanguage>[
      AppLanguage.nepali,
      AppLanguage.hindi,
    ]) {
      controller.value = language;
      expect(StringConstants.language, _arb(language.code)['language']);
      expect(StringConstants.language, isNot(en['language']));
    }
  });

  testWidgets('switching language rebuilds const widgets in place', (
    WidgetTester tester,
  ) async {
    final AppLocaleController controller = AppLocaleController.instance;
    final AppLanguage original = controller.value;
    addTearDown(() => controller.value = original);
    controller.value = AppLanguage.english;

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: _LanguageLabel())),
    );
    expect(find.text(en['language'] as String), findsOneWidget);

    controller.setLanguage(AppLanguage.nepali);
    await tester.pump();
    expect(find.text(_arb('ne')['language'] as String), findsOneWidget);
  });

  test('older stored language names still resolve', () {
    expect(AppLanguage.fromCode('English'), AppLanguage.english);
    expect(AppLanguage.fromCode('नेपाली'), AppLanguage.nepali);
    expect(AppLanguage.fromCode('हिन्दी'), AppLanguage.hindi);
    expect(AppLanguage.fromCode('hi'), AppLanguage.hindi);
    expect(AppLanguage.fromCode('fr'), isNull);
  });
}

class _LanguageLabel extends StatelessWidget {
  const _LanguageLabel();

  @override
  Widget build(BuildContext context) => Text(StringConstants.language);
}
