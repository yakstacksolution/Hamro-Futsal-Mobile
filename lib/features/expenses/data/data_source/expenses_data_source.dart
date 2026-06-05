import 'dart:math' as math;

import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';

abstract class ExpensesDataSource {
  Future<List<VenueModel>> fetchVenues();
  Future<List<CourtModel>> fetchCourts();
  Future<List<ExpenseModel>> fetchExpenses();
}

/// Local demo data source.
///
/// Generates a year of realistic expense records in memory. Swap this with an
/// API-backed implementation (mirroring `AuthenticationDataSourceImpl`) once
/// the backend endpoints are available — the repository and everything above
/// it stay untouched.
final class ExpensesLocalDataSourceImpl implements ExpensesDataSource {
  List<VenueModel>? _venues;
  List<CourtModel>? _courts;
  List<ExpenseModel>? _expenses;

  @override
  Future<List<VenueModel>> fetchVenues() async {
    _ensureGenerated();
    return _venues!;
  }

  @override
  Future<List<CourtModel>> fetchCourts() async {
    _ensureGenerated();
    return _courts!;
  }

  @override
  Future<List<ExpenseModel>> fetchExpenses() async {
    _ensureGenerated();
    // Small artificial latency so loading states behave like a real API.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _expenses!;
  }

  void _ensureGenerated() {
    if (_venues != null && _expenses != null) return;

    const venues = <VenueModel>[
      VenueModel(id: 'f1', name: 'Green Turf Arena'),
      VenueModel(id: 'f2', name: 'Capital Futsal'),
      VenueModel(id: 'f3', name: 'Champions Court'),
    ];

    const courts = <CourtModel>[
      CourtModel(id: 'c1', name: 'Court A', venueId: 'f1'),
      CourtModel(id: 'c2', name: 'Court B', venueId: 'f1'),
      CourtModel(id: 'c3', name: 'Court A', venueId: 'f2'),
      CourtModel(id: 'c4', name: 'Court B', venueId: 'f2'),
      CourtModel(id: 'c5', name: 'Court C', venueId: 'f2'),
      CourtModel(id: 'c6', name: 'Court A', venueId: 'f3'),
    ];

    const vendorsByCat = <ExpenseCategory, List<String>>{
      ExpenseCategory.rent: ['Landlord — Mr. Sharma', 'Property Holdings'],
      ExpenseCategory.maintenance: [
        'Turf Repair Co.',
        'Net & Posts Pvt.',
        'Floodlight Services',
      ],
      ExpenseCategory.salaries: ['Staff Payroll', 'Court Manager', 'Cleaner'],
      ExpenseCategory.supplies: [
        'Sports Hub',
        'Equipment Plus',
        'Cleaning Mart',
      ],
      ExpenseCategory.marketing: [
        'Facebook Ads',
        'Local Print Press',
        'Influencer Promo',
      ],
      ExpenseCategory.refreshments: ['Beverage Co.', 'Snack Supplier'],
      ExpenseCategory.insurance: ['NIC Insurance', 'Premier Insure'],
      ExpenseCategory.utilities: ['NEA — Electricity', 'KUKL — Water'],
      ExpenseCategory.other: ['Miscellaneous', 'Bank Fees'],
    };

    final rng = math.Random(7);
    final now = DateTime.now();
    final start = DateTime(now.year - 1, now.month, now.day);

    final expenses = <ExpenseModel>[];
    int id = 0;
    // Walk every day across the past year and emit 0–3 expenses.
    var day = start;
    while (!day.isAfter(now)) {
      final n = rng.nextInt(4); // 0..3
      for (int k = 0; k < n; k++) {
        final cat =
            ExpenseCategory.values[rng.nextInt(ExpenseCategory.values.length)];
        final vendors = vendorsByCat[cat]!;
        final venue = venues[rng.nextInt(venues.length)];

        // Amount tier by category for realism.
        final amount = switch (cat) {
          ExpenseCategory.rent => 28000 + rng.nextInt(8000),
          ExpenseCategory.salaries => 12000 + rng.nextInt(15000),
          ExpenseCategory.utilities => 3500 + rng.nextInt(6500),
          ExpenseCategory.insurance => 4500 + rng.nextInt(5500),
          ExpenseCategory.marketing => 1500 + rng.nextInt(8500),
          ExpenseCategory.maintenance => 1800 + rng.nextInt(11000),
          ExpenseCategory.supplies => 800 + rng.nextInt(4500),
          ExpenseCategory.refreshments => 350 + rng.nextInt(2200),
          ExpenseCategory.other => 250 + rng.nextInt(3500),
        };

        // Rent and salaries tend to land on day 1 or 28.
        if (cat == ExpenseCategory.rent && day.day != 1) continue;
        if (cat == ExpenseCategory.salaries && day.day != 28) continue;
        final when = DateTime(
          day.year,
          day.month,
          day.day,
          8 + rng.nextInt(12),
          rng.nextInt(60),
        );

        expenses.add(
          ExpenseModel(
            id: 'e${id++}',
            date: when,
            category: cat,
            vendor: vendors[rng.nextInt(vendors.length)],
            amount: amount,
            venueId: venue.id,
            method:
                PaymentMethod.values[rng.nextInt(PaymentMethod.values.length)],
          ),
        );
      }
      day = day.add(const Duration(days: 1));
    }

    // Make sure recurring monthly costs always exist for the current month.
    for (final v in venues) {
      expenses.add(
        ExpenseModel(
          id: 'e${id++}',
          date: DateTime(now.year, now.month, 1, 9, 30),
          category: ExpenseCategory.rent,
          vendor: 'Landlord — Mr. Sharma',
          amount: 32000,
          venueId: v.id,
          method: PaymentMethod.online,
          note: 'Monthly rent',
        ),
      );
    }

    expenses.sort((a, b) => b.date.compareTo(a.date));
    _venues = venues;
    _courts = courts;
    _expenses = expenses;
  }
}
