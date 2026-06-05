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
    required this.vendor,
    required this.amount,
    required this.venueId,
    required this.method,
    this.courtId,
    this.note,
  });

  final String id;
  final DateTime date;
  final ExpenseCategory category;
  final String vendor;
  final int amount;
  final String venueId;
  final PaymentMethod method;
  final String? courtId;
  final String? note;

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
}
