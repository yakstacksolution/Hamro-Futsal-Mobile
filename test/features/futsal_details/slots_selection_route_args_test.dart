import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/slots_selection_route_args.dart';

void main() {
  group('SlotsSelectionRouteArgs.maybeFromExtra', () {
    test('accepts the structured route args', () {
      final SlotsSelectionRouteArgs args = SlotsSelectionRouteArgs(
        court: _court,
        initialDate: DateTime(2026, 9, 21),
        initialStartTime: '06:00',
      );

      expect(SlotsSelectionRouteArgs.maybeFromExtra(args), same(args));
    });

    test('wraps the legacy bare court extra', () {
      final SlotsSelectionRouteArgs? args =
          SlotsSelectionRouteArgs.maybeFromExtra(_court);

      expect(args?.court, same(_court));
      expect(args?.initialDate, isNull);
      expect(args?.initialStartTime, isNull);
    });

    test('rejects missing or unexpected extras without throwing', () {
      expect(SlotsSelectionRouteArgs.maybeFromExtra(null), isNull);
      expect(SlotsSelectionRouteArgs.maybeFromExtra('bad-extra'), isNull);
    });
  });
}

const CourtDetailModel _court = CourtDetailModel(
  venueId: 1,
  name: 'Test Futsal Arena',
  location: 'Kathmandu',
  address: 'Some street, Kathmandu',
  price: 'Rs. 1500',
  rating: 0,
  reviewCount: 0,
  images: <String>[],
  isOpen: true,
  distance: '1.2 km',
  features: <String>[],
  description: '',
  hostedByName: 'Host',
  hostedByAvatar: '',
  hostedSince: '2024',
  hostedCourts: 2,
  responseRate: 90,
  policies: <String>[],
  rules: <String>[],
  reviews: <ReviewModel>[],
  openTime: '06:00',
  closeTime: '22:00',
  courtType: '5A',
  surfaceType: 'Turf',
  maxPlayers: 10,
);
