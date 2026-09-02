import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_review_model.dart';

void main() {
  test('parses a submitted review', () {
    final review = BookingReviewModel.fromResponse(<String, dynamic>{
      'status': 'success',
      'data': <String, dynamic>{
        'id': 7,
        'rating': 5,
        'review': 'Great venue, good court condition.',
        'created_at': '2026-08-18T10:00:00Z',
      },
    });
    expect(review, isNotNull);
    expect(review!.rating, 5);
    expect(review.review, 'Great venue, good court condition.');
    expect(review.createdAt, isNotNull);
  });

  test('reads a bare object without the data envelope', () {
    final review = BookingReviewModel.fromResponse(<String, dynamic>{
      'rating': '4',
      'comment': 'Solid.',
    });
    expect(review!.rating, 4);
    expect(review.review, 'Solid.');
  });

  test('treats every "no review" shape as not reviewed', () {
    expect(BookingReviewModel.fromResponse(null), isNull);
    expect(
      BookingReviewModel.fromResponse(<String, dynamic>{'data': null}),
      isNull,
    );
    expect(
      BookingReviewModel.fromResponse(<String, dynamic>{
        'data': <String, dynamic>{},
      }),
      isNull,
    );
    expect(
      BookingReviewModel.fromResponse(<String, dynamic>{'data': <dynamic>[]}),
      isNull,
    );
    expect(
      BookingReviewModel.fromResponse(<String, dynamic>{
        'data': <String, dynamic>{'id': 3, 'rating': 0, 'review': ''},
      }),
      isNull,
      reason: 'a shell with no rating is not a review',
    );
  });
}
