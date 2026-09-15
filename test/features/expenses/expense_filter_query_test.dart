import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/expenses/data/model/expense_model.dart';
import 'package:hamro_futsal/features/expenses/presentation/models/expense_analytics.dart';
import 'package:hamro_futsal/features/expenses/presentation/models/expense_filter.dart';

void main() {
  test('toQuery sends the selected category as expense_category_id', () {
    const filter = ExpenseFilter(
      period: ExpensePeriod.month,
      categoryId: '7',
      venueId: '3',
      paymentMethod: PaymentMethod.online,
    );

    expect(filter.toQuery(), <String, dynamic>{
      'date_filter': 'month',
      'venue_id': '3',
      'expense_category_id': '7',
      'payment_method': 'online',
    });
  });

  test('toQuery omits the category when nothing is selected', () {
    const filter = ExpenseFilter(period: ExpensePeriod.week);

    expect(filter.toQuery().containsKey('expense_category_id'), isFalse);
  });

  test('clearing the category drops it from the query', () {
    const filter = ExpenseFilter(period: ExpensePeriod.week, categoryId: '7');

    final cleared = filter.copyWith(clearCategory: true);

    expect(cleared.categoryId, isNull);
    expect(cleared.toQuery().containsKey('expense_category_id'), isFalse);
    expect(cleared.hasSecondaryFilters, isFalse);
  });

  test('a category alone counts as a secondary filter', () {
    const filter = ExpenseFilter(period: ExpensePeriod.week, categoryId: '7');

    expect(filter.hasSecondaryFilters, isTrue);
  });
}
