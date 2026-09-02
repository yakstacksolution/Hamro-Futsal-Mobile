import 'package:hamro_futsal/features/public/data/model/public_template_model.dart';

enum VendorTemplateField {
  futsalDescription,
  courtDescription,
  cancellationPolicy,
  futsalRules,
}

String? templateDefaultFor(
  List<PublicTemplateModel> templates,
  VendorTemplateField field,
) {
  if (templates.isEmpty) return null;

  final _TemplateFieldConfig config = switch (field) {
    VendorTemplateField.futsalDescription => const _TemplateFieldConfig(
      exactKeys: <String>['futsal_description', 'description'],
      preferredTitles: <String>['futsal_description', 'description'],
      primaryKeywords: <String>['futsal', 'description'],
      secondaryKeywords: <String>['about', 'venue'],
    ),
    VendorTemplateField.courtDescription => const _TemplateFieldConfig(
      exactKeys: <String>['description'],
      preferredTitles: <String>['description'],
      primaryKeywords: <String>['court', 'description'],
      secondaryKeywords: <String>['pitch', 'ground'],
    ),
    VendorTemplateField.cancellationPolicy => const _TemplateFieldConfig(
      exactKeys: <String>['cancelation_policy', 'cancellation_policy'],
      preferredTitles: <String>['cancelation_policy', 'cancellation_policy'],
      primaryKeywords: <String>['cancel', 'policy'],
      secondaryKeywords: <String>['refund', 'booking'],
    ),
    VendorTemplateField.futsalRules => const _TemplateFieldConfig(
      exactKeys: <String>['futsal_rules', 'futsalrules'],
      preferredTitles: <String>['futsal_rules', 'futsalrules'],
      primaryKeywords: <String>['futsal', 'rule'],
      secondaryKeywords: <String>['house', 'rules'],
    ),
  };

  for (final PublicTemplateModel template in templates) {
    final String exactContent = _extractExactKeyContent(template, config);
    if (exactContent.isNotEmpty) return exactContent;
  }

  final List<String> normalizedTitles = config.preferredTitles
      .map((String value) => _normalize(value))
      .toList(growable: false);
  for (final PublicTemplateModel template in templates) {
    if (!normalizedTitles.contains(_normalize(template.title))) continue;
    final String content = _extractTemplateContent(template);
    if (content.isNotEmpty) return content;
  }

  final List<_MatchedTemplate> matches =
      templates
          .map(
            (PublicTemplateModel template) => _MatchedTemplate(
              template: template,
              score: _templateScore(template, config),
            ),
          )
          .where((_MatchedTemplate match) => match.score > 0)
          .toList()
        ..sort(
          (_MatchedTemplate a, _MatchedTemplate b) =>
              b.score.compareTo(a.score),
        );

  for (final _MatchedTemplate match in matches) {
    final String content = _extractTemplateContent(match.template);
    if (content.isNotEmpty) return content;
  }

  return null;
}

String _extractExactKeyContent(
  PublicTemplateModel template,
  _TemplateFieldConfig config,
) {
  final List<String> keys = config.exactKeys.map(_normalize).toList();

  for (final String rawKey in <String>[
    _stringValue(template.raw['key']),
    _stringValue(template.raw['slug']),
    _stringValue(template.raw['type']),
    _stringValue(template.raw['category']),
    template.title,
  ]) {
    if (keys.contains(_normalize(rawKey))) {
      final String content = _extractTemplateContent(template);
      if (content.isNotEmpty) return content;
    }
  }

  return '';
}

int _templateScore(PublicTemplateModel template, _TemplateFieldConfig config) {
  final String haystack = <String>[
    template.id,
    template.title,
    template.description,
    _stringValue(template.raw['key']),
    _stringValue(template.raw['type']),
    _stringValue(template.raw['category']),
    _stringValue(template.raw['slug']),
    _stringValue(template.raw['template_name']),
    _stringValue(template.raw['name']),
  ].join(' ').toLowerCase();

  int score = 0;
  for (final String keyword in config.primaryKeywords) {
    if (haystack.contains(keyword.toLowerCase())) {
      score += 3;
    }
  }
  for (final String keyword in config.secondaryKeywords) {
    if (haystack.contains(keyword.toLowerCase())) {
      score += 1;
    }
  }
  return score;
}

String _extractTemplateContent(PublicTemplateModel template) {
  final dynamic content = template.raw['content'];
  if (content is String && content.trim().isNotEmpty) {
    return content.trim();
  }

  if (content is Map) {
    final String nested = _firstNonEmptyString(<dynamic>[
      content['html'],
      content['body'],
      content['text'],
      content['value'],
    ]);
    if (nested.isNotEmpty) return nested;
  }

  return _firstNonEmptyString(<dynamic>[
    template.raw['html'],
    template.raw['body'],
    template.raw['value'],
    template.raw['template'],
    template.raw['text'],
    template.raw['details'],
    template.raw['description'],
    template.description,
  ]);
}

String _firstNonEmptyString(List<dynamic> values) {
  for (final dynamic value in values) {
    final String text = _stringValue(value).trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

String _stringValue(dynamic value) => value?.toString() ?? '';

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(' ', '_');

class _TemplateFieldConfig {
  const _TemplateFieldConfig({
    required this.exactKeys,
    required this.preferredTitles,
    required this.primaryKeywords,
    required this.secondaryKeywords,
  });

  final List<String> exactKeys;
  final List<String> preferredTitles;
  final List<String> primaryKeywords;
  final List<String> secondaryKeywords;
}

class _MatchedTemplate {
  const _MatchedTemplate({required this.template, required this.score});

  final PublicTemplateModel template;
  final int score;
}
