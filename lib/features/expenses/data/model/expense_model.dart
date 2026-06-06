enum ExpenseCategory {
  rent,
  maintenance,
  salaries,
  supplies,
  marketing,
  refreshments,
  insurance,
  utilities,
  other,
}

extension ExpenseCategoryLabel on ExpenseCategory {
  String get label => switch (this) {
    ExpenseCategory.rent => 'Rent',
    ExpenseCategory.maintenance => 'Maintenance',
    ExpenseCategory.salaries => 'Salaries',
    ExpenseCategory.supplies => 'Supplies',
    ExpenseCategory.marketing => 'Marketing',
    ExpenseCategory.refreshments => 'Refreshments',
    ExpenseCategory.insurance => 'Insurance',
    ExpenseCategory.utilities => 'Utilities',
    ExpenseCategory.other => 'Other',
  };
}

/// Category fetched from the `/expense-categories` endpoint.
///
/// Response item shape:
/// `{id: 2, title: Bills, slug: bills, image: https://…/image.svg}`
class ExpenseCategoryModel {
  const ExpenseCategoryModel({
    required this.id,
    required this.name,
    this.slug = '',
    this.image = '',
  });

  final String id;
  final String name;
  final String slug;

  /// Category icon URL (svg or raster); empty when the server sent none.
  final String image;

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) =>
      ExpenseCategoryModel(
        id: (json['id'] ?? json['_id'] ?? json['uuid'] ?? '').toString(),
        name: (json['title'] ?? json['name'] ?? json['label'] ?? '')
            .toString()
            .trim(),
        slug: (json['slug'] ?? '').toString().trim(),
        image: (json['image'] ?? '').toString().trim(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': name,
    'slug': slug,
    'image': image,
  };

  bool get hasImage => image.isNotEmpty;

  bool get isSvgImage => image.toLowerCase().endsWith('.svg');

  /// Maps this category onto the local enum (by slug, then name) so existing
  /// analytics/filter code keeps working; unknown categories land in `other`.
  ExpenseCategory get asEnum => ExpenseCategory.values.firstWhere(
    (c) =>
        c.name == slug.toLowerCase() ||
        c.label.toLowerCase() == name.toLowerCase(),
    orElse: () => ExpenseCategory.other,
  );
}

enum PaymentMethod { cash, online }

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.cash => 'Cash',
    PaymentMethod.online => 'Online',
  };
}

class VenueModel {
  const VenueModel({required this.id, required this.name});

  final String id;
  final String name;

  factory VenueModel.fromJson(Map<String, dynamic> json) => VenueModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

/// Venues together with their courts, as returned by the single
/// venue-court endpoint.
class VenueCourtsModel {
  const VenueCourtsModel({required this.venues, required this.courts});

  final List<VenueModel> venues;
  final List<CourtModel> courts;
}

class CourtModel {
  const CourtModel({
    required this.id,
    required this.name,
    required this.venueId,
  });

  final String id;
  final String name;
  final String venueId;

  factory CourtModel.fromJson(Map<String, dynamic> json) => CourtModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    venueId: json['venue_id']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'venue_id': venueId};
}

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.date,
    required this.category,
    this.categoryId = '',
    this.categoryDetail,
    required this.vendor,
    required this.amount,
    required this.venueId,
    this.venueName,
    required this.method,
    this.courtId,
    this.courtName,
    this.note,
    this.document,
  });

  final String id;
  final DateTime date;

  /// Local enum mapping (slug-based) used for colors/fallback icons.
  final ExpenseCategory category;

  /// Server-side `expense_category_id`.
  final String categoryId;

  /// Nested `category: {id, title, slug, image}` from the API.
  final ExpenseCategoryModel? categoryDetail;
  final String vendor;
  final int amount;
  final String venueId;

  /// Nested `venue.name` from the API; UI falls back to a lookup when null.
  final String? venueName;
  final PaymentMethod method;
  final String? courtId;

  /// Nested `court.name` from the API.
  final String? courtName;
  final String? note;

  /// Attached document — a server URL, or a local file path right after an
  /// optimistic create (until the silent refetch swaps in the server copy).
  final String? document;

  bool get hasImageDocument {
    final d = document?.toLowerCase();
    if (d == null) return false;
    return d.endsWith('.jpg') ||
        d.endsWith('.jpeg') ||
        d.endsWith('.png') ||
        d.endsWith('.webp');
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['id']?.toString() ?? '',
    date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    category:
        ExpenseCategory.values.asNameMap()[json['category']] ??
        ExpenseCategory.other,
    vendor: json['vendor']?.toString() ?? '',
    amount: json['amount'] is int
        ? json['amount'] as int
        : int.tryParse(json['amount']?.toString() ?? '') ?? 0,
    venueId: json['venue_id']?.toString() ?? '',
    method:
        PaymentMethod.values.asNameMap()[json['method']] ?? PaymentMethod.cash,
    courtId: json['court_id']?.toString(),
    note: json['note']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'category': category.name,
    'vendor': vendor,
    'amount': amount,
    'venue_id': venueId,
    'method': method.name,
    'court_id': courtId,
    'note': note,
  };

  /// Parses one item of the `GET /auth/expenses` response:
  /// `{id, amount, purpose, date, payment_method, note, document_url,
  ///   expense_category_id, category: {id,title,slug,image},
  ///   venue_id, venue: {id,name}, court_id, court: {id,name}, created_at}`.
  factory ExpenseModel.fromApiJson(Map<String, dynamic> json) {
    final dynamic rawCategory = json['category'] ?? json['expense_category'];
    final categoryDetail = rawCategory is Map
        ? ExpenseCategoryModel.fromJson(Map<String, dynamic>.from(rawCategory))
        : null;

    final dynamic rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.round()
        : (double.tryParse(rawAmount?.toString() ?? '') ?? 0).round();

    final method = (json['payment_method'] ?? json['method'] ?? '')
        .toString()
        .toLowerCase();

    // `date` is day-only; merge in the creation time so records order
    // naturally within a day.
    final day = DateTime.tryParse(json['date']?.toString() ?? '');
    final created = DateTime.tryParse(json['created_at']?.toString() ?? '');
    final date = day == null
        ? (created ?? DateTime.now())
        : DateTime(
            day.year,
            day.month,
            day.day,
            created?.hour ?? 0,
            created?.minute ?? 0,
          );

    final document = (json['document_url'] ?? json['document'] ?? '')
        .toString()
        .trim();

    final note = json['note']?.toString().trim();

    String? nestedName(String key) {
      final dynamic v = json[key];
      if (v is! Map) return null;
      final name = (v['name'] ?? '').toString().trim();
      return name.isEmpty ? null : name;
    }

    return ExpenseModel(
      id: (json['id'] ?? '').toString(),
      date: date,
      category: categoryDetail?.asEnum ?? ExpenseCategory.other,
      categoryId: (json['expense_category_id'] ?? categoryDetail?.id ?? '')
          .toString(),
      categoryDetail: categoryDetail,
      vendor: (json['purpose'] ?? json['vendor'] ?? '').toString(),
      amount: amount,
      venueId: json['venue_id']?.toString() ?? '',
      venueName: nestedName('venue'),
      method: method == 'online' ? PaymentMethod.online : PaymentMethod.cash,
      courtId: json['court_id']?.toString(),
      courtName: nestedName('court'),
      note: (note == null || note.isEmpty) ? null : note,
      document: document.isEmpty ? null : document,
    );
  }
}
