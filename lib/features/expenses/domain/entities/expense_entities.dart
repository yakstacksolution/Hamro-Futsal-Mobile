import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';

/// Payload for creating a new expense from the UI.
class CreateExpenseEntity {
  const CreateExpenseEntity({
    required this.date,
    required this.category,
    required this.vendor,
    required this.amount,
    required this.venueId,
    required this.method,
    this.courtId,
    this.note,
  });

  final DateTime date;
  final ExpenseCategory category;
  final String vendor;
  final int amount;
  final String venueId;
  final PaymentMethod method;
  final String? courtId;
  final String? note;

  ExpenseModel toModel(String id) => ExpenseModel(
    id: id,
    date: date,
    category: category,
    vendor: vendor,
    amount: amount,
    venueId: venueId,
    method: method,
    courtId: courtId,
    note: note,
  );

  Map<String, dynamic> toMap() => {
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
