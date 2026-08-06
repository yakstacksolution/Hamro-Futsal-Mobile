import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_draft.dart';

void main() {
  BookingDraft draft({required String selectedTime, String? endTime}) {
    return BookingDraft(
      courtName: 'Court',
      courtImage: '',
      matchType: '5v5',
      courtType: 'Indoor',
      maxPlayers: 10,
      selectedDate: DateTime(2026, 8, 3),
      selectedTime: selectedTime,
      endTime: endTime,
      isRecurring: false,
      sessions: 1,
      sessionDates: <DateTime>[DateTime(2026, 8, 3)],
      pricePerSession: 1200,
      subtotal: 1200,
    );
  }

  group('BookingDraft.displayTimeRange', () {
    test('appends a separately supplied end time', () {
      expect(
        draft(selectedTime: '6:00 AM', endTime: '7:00 AM').displayTimeRange,
        '6:00 AM – 7:00 AM',
      );
    });

    test(
      'does not duplicate an end time already present in the slot label',
      () {
        expect(
          draft(
            selectedTime: '6:00 AM - 7:00 AM',
            endTime: '7:00 AM',
          ).displayTimeRange,
          '6:00 AM - 7:00 AM',
        );
      },
    );

    test('keeps a start-only label when no end time is supplied', () {
      expect(draft(selectedTime: '6:00 AM').displayTimeRange, '6:00 AM');
    });
  });
}
