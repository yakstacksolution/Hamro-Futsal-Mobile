import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/presentation/models/expense_analytics.dart';

/// The server-side query the Expenses screen sends to `GET /auth/expenses`.
///
/// Maps the on-screen filters onto the API's query params:
///   date_filter = today | week | month | year | custom
///   date_from / date_to (custom only, `YYYY-MM-DD`)
///   venue_id
///   payment_method = cash | online
class ExpenseFilter extends Equatable {
  const ExpenseFilter({
    this.period = ExpensePeriod.week,
    this.customRange,
    this.venueId,
    this.paymentMethod,
  });

  final ExpensePeriod period;
  final ({DateTime start, DateTime end})? customRange;
  final String? venueId;
  final PaymentMethod? paymentMethod;

  ExpenseFilter copyWith({
    ExpensePeriod? period,
    ({DateTime start, DateTime end})? customRange,
    bool clearCustomRange = false,
    String? venueId,
    bool clearVenue = false,
    PaymentMethod? paymentMethod,
    bool clearPaymentMethod = false,
  }) {
    return ExpenseFilter(
      period: period ?? this.period,
      customRange: clearCustomRange ? null : (customRange ?? this.customRange),
      venueId: clearVenue ? null : (venueId ?? this.venueId),
      paymentMethod: clearPaymentMethod
          ? null
          : (paymentMethod ?? this.paymentMethod),
    );
  }

  /// `2026-06-09`
  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{'date_filter': period.name};
    if (period == ExpensePeriod.custom && customRange != null) {
      q['date_from'] = _ymd(customRange!.start);
      q['date_to'] = _ymd(customRange!.end);
    }
    if (venueId != null) q['venue_id'] = venueId;
    if (paymentMethod != null) q['payment_method'] = paymentMethod!.name;
    return q;
  }

  bool get hasSecondaryFilters => venueId != null || paymentMethod != null;

  @override
  List<Object?> get props => [
    period,
    customRange?.start,
    customRange?.end,
    venueId,
    paymentMethod,
  ];
}
