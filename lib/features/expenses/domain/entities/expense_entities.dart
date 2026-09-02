import 'package:hamro_futsal/core/utils/upload_attachment.dart';
import 'package:hamro_futsal/features/expenses/data/model/expense_model.dart';

/// Payload for creating a new expense from the UI.
class CreateExpenseEntity {
  const CreateExpenseEntity({
    required this.date,
    required this.category,
    required this.vendor,
    required this.amount,
    required this.venueId,
    required this.method,
    this.categoryDetail,
    this.courtId,
    this.note,
    this.document,
  });

  final DateTime date;
  final ExpenseCategory category;
  final String vendor;
  final int amount;
  final String venueId;
  final PaymentMethod method;

  /// Category picked from `/expense-categories` (id, title, image).
  final ExpenseCategoryModel? categoryDetail;
  final String? courtId;
  final String? note;

  /// Image/PDF/Word document captured as bytes when it was picked.
  final UploadAttachment? document;

  ExpenseModel toModel(String id) => ExpenseModel(
    id: id,
    date: date,
    category: category,
    categoryId: categoryDetail?.id ?? '',
    categoryDetail: categoryDetail,
    vendor: vendor,
    amount: amount,
    venueId: venueId,
    method: method,
    courtId: courtId,
    note: note,
    document: document?.sourcePath,
  );

  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String(),
    'category': category.name,
    'category_id': categoryDetail?.id,
    'vendor': vendor,
    'amount': amount,
    'venue_id': venueId,
    'method': method.name,
    'court_id': courtId,
    'note': note,
  };

  /// Body for `POST /auth/expenses` (the `document` file is attached
  /// separately as multipart by the data source).
  Map<String, dynamic> toApiMap() => {
    'expense_category_id': int.tryParse(categoryDetail?.id ?? ''),
    'venue_id': int.tryParse(venueId),
    'court_id': courtId == null ? null : int.tryParse(courtId!),
    'amount': amount,
    'purpose': vendor,
    'date':
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    'payment_method': method.name, // cash | online
    'note': note,
  };
}
