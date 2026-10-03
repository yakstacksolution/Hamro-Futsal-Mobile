class CandidateModel {
  const CandidateModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  final int id;
  final String name;
  final String phone;

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: _int(json['id'] ?? json['candidate_id'] ?? json['user_id']),
      name: _string(
        json['name'] ??
            json['full_name'] ??
            json['customer_name'] ??
            json['player_name'],
      ),
      phone: _string(
        json['phone'] ??
            json['phone_number'] ??
            json['mobile'] ??
            json['customer_phone'] ??
            json['player_phone'],
      ),
    );
  }

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static String _string(dynamic value) => value?.toString().trim() ?? '';
}

class CandidatePage {
  const CandidatePage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.hasMorePages,
  });

  final List<CandidateModel> items;
  final int currentPage;
  final int lastPage;
  final bool hasMorePages;

  factory CandidatePage.fromResponse(dynamic response) {
    final Map<String, dynamic> root = _map(response);
    final Map<String, dynamic> data = _map(root['data'] ?? root);
    final Map<String, dynamic> pagination = _map(
      data['pagination'] ?? root['pagination'],
    );
    final List<dynamic> rows = _list(
      data['items'] ??
          data['candidates'] ??
          data['results'] ??
          root['items'] ??
          root['candidates'] ??
          data,
    );
    final int currentPage = _int(pagination['current_page'], 1);
    final int lastPage = _int(pagination['last_page'], currentPage);
    return CandidatePage(
      items: rows
          .whereType<Map>()
          .map(
            (Map item) =>
                CandidateModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .where(
            (CandidateModel item) =>
                item.name.isNotEmpty || item.phone.isNotEmpty,
          )
          .toList(growable: false),
      currentPage: currentPage,
      lastPage: lastPage,
      hasMorePages: _bool(pagination['has_more_pages'], currentPage < lastPage),
    );
  }

  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : const <String, dynamic>{};

  static List<dynamic> _list(dynamic value) =>
      value is List ? value : const <dynamic>[];

  static int _int(dynamic value, int fallback) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

  static bool _bool(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String lower = value.toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    return fallback;
  }
}
