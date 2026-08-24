import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';

class FutsalDetailsModel {
  final String name;
  final String location;
  final String address;
  final String price;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final bool isOpen;
  final String distance;
  final List<String> features;
  final String description;
  final String hostedByName;
  final String hostedByAvatar;
  final String hostedSince;
  final int hostedCourts;
  final double responseRate;
  final List<String> policies;
  final List<String> rules;
  final List<ReviewModel> reviews;
  final String openTime;
  final String closeTime;
  final String courtType;
  final String surfaceType;
  final int maxPlayers;

  const FutsalDetailsModel({
    required this.name,
    required this.location,
    required this.address,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.isOpen,
    required this.distance,
    required this.features,
    required this.description,
    required this.hostedByName,
    required this.hostedByAvatar,
    required this.hostedSince,
    required this.hostedCourts,
    required this.responseRate,
    required this.policies,
    required this.rules,
    required this.reviews,
    required this.openTime,
    required this.closeTime,
    required this.courtType,
    required this.surfaceType,
    required this.maxPlayers,
  });
}
