import 'dart:math' as math;

import 'package:hamro_footsall/features/booking_overview/data/model/booking_overview_model.dart';

abstract class BookingOverviewDataSource {
  Future<List<BookingFutsalModel>> fetchFutsals();
  Future<List<BookingRecordModel>> fetchBookings();
}

/// Local demo data source.
///
/// Generates ~90 days of realistic booking records in memory. Swap this with
/// an API-backed implementation once the backend endpoints are available —
/// the repository and everything above it stay untouched.
final class BookingOverviewLocalDataSourceImpl
    implements BookingOverviewDataSource {
  List<BookingFutsalModel>? _futsals;
  List<BookingRecordModel>? _bookings;

  @override
  Future<List<BookingFutsalModel>> fetchFutsals() async {
    _ensureGenerated();
    return _futsals!;
  }

  @override
  Future<List<BookingRecordModel>> fetchBookings() async {
    _ensureGenerated();
    // Small artificial latency so loading states behave like a real API.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _bookings!;
  }

  void _ensureGenerated() {
    if (_futsals != null && _bookings != null) return;

    const futsals = <BookingFutsalModel>[
      BookingFutsalModel(
        id: 'f1',
        name: 'Green Turf Arena',
        area: 'Kathmandu',
        monthlyOverhead: 95000,
        courts: [
          BookingCourtModel(
            id: 'c1',
            futsalId: 'f1',
            name: 'Court A',
            hourlyRate: 1200,
          ),
          BookingCourtModel(
            id: 'c2',
            futsalId: 'f1',
            name: 'Court B',
            hourlyRate: 1500,
          ),
          BookingCourtModel(
            id: 'c3',
            futsalId: 'f1',
            name: 'Court C',
            hourlyRate: 1800,
          ),
        ],
      ),
      BookingFutsalModel(
        id: 'f2',
        name: 'Capital Futsal',
        area: 'Lalitpur',
        monthlyOverhead: 72000,
        courts: [
          BookingCourtModel(
            id: 'c4',
            futsalId: 'f2',
            name: 'Court 1',
            hourlyRate: 1100,
          ),
          BookingCourtModel(
            id: 'c5',
            futsalId: 'f2',
            name: 'Court 2',
            hourlyRate: 1400,
          ),
        ],
      ),
      BookingFutsalModel(
        id: 'f3',
        name: 'Champions Court',
        area: 'Bhaktapur',
        monthlyOverhead: 58000,
        courts: [
          BookingCourtModel(
            id: 'c6',
            futsalId: 'f3',
            name: 'Pitch 1',
            hourlyRate: 1000,
          ),
          BookingCourtModel(
            id: 'c7',
            futsalId: 'f3',
            name: 'Pitch 2',
            hourlyRate: 1300,
          ),
          BookingCourtModel(
            id: 'c8',
            futsalId: 'f3',
            name: 'Pitch 3',
            hourlyRate: 1300,
          ),
        ],
      ),
    ];

    final allCourts = <BookingCourtModel>[for (final f in futsals) ...f.courts];

    const customers = <String>[
      'Aayush Karki',
      'Niraj Shrestha',
      'Samir Tamang',
      'Rohit Rai',
      'Bishal Maharjan',
      'Sunil Lama',
      'Bibek Thapa',
      'Pradeep Adhikari',
      'Kushal Gurung',
      'Rajan Pun',
      'Anil Khatri',
      'Dipesh Bista',
      'Suman KC',
      'Sandip Magar',
      'Yogesh Joshi',
    ];

    final rng = math.Random(42);
    final today = DateTime.now();
    final from = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 89));

    final bookings = <BookingRecordModel>[];
    int id = 0;

    for (int day = 0; day < 90; day++) {
      final date = from.add(Duration(days: day));
      final isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.friday;
      final slotsToday = isWeekend ? rng.nextInt(8) + 8 : rng.nextInt(6) + 3;

      for (int i = 0; i < slotsToday; i++) {
        final court = allCourts[rng.nextInt(allCourts.length)];
        final hour = 6 + rng.nextInt(16); // 6 AM – 10 PM
        final hours = rng.nextDouble() < 0.75 ? 1 : 2;
        final start = DateTime(date.year, date.month, date.day, hour);

        final roll = rng.nextDouble();
        final BookingStatus status;
        if (start.isAfter(today)) {
          status = roll < 0.6
              ? BookingStatus.confirmed
              : (roll < 0.85 ? BookingStatus.pending : BookingStatus.cancelled);
        } else {
          status = roll < 0.62
              ? BookingStatus.completed
              : roll < 0.78
              ? BookingStatus.confirmed
              : roll < 0.86
              ? BookingStatus.pending
              : BookingStatus.cancelled;
        }

        bookings.add(
          BookingRecordModel(
            id: 'b${id++}',
            futsalId: court.futsalId,
            courtId: court.id,
            start: start,
            hours: hours,
            amount: court.hourlyRate * hours,
            status: status,
            customer: customers[rng.nextInt(customers.length)],
          ),
        );
      }
    }

    _futsals = futsals;
    _bookings = bookings;
  }
}
