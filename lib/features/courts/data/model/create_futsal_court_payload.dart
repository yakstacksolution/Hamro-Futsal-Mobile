class CreateFutsalCourtPayload {
  const CreateFutsalCourtPayload({
    required this.owner,
    required this.shopName,
    required this.slug,
    required this.description,
    required this.establishedYear,
    required this.basicPrice,
    required this.phoneNumber,
    required this.emailAddress,
    required this.website,
    required this.city,
    required this.country,
    required this.exactLocation,
    required this.latitude,
    required this.longitude,
    required this.registrationNumber,
    required this.status,
    required this.amenities,
    required this.facilities,
    required this.amenitiesNotes,
    required this.bookingAdvanceDays,
    required this.cancellationWindowHours,
    required this.houseRules,
    required this.allowCancellation,
    required this.requiresAdvancePayment,
    required this.supportsRefunds,
    required this.selectedPackageId,
    required this.selectedPackageTitle,
    required this.shopLogo,
  });

  final String owner;
  final String shopName;
  final String slug;
  final String description;
  final String establishedYear;
  final String basicPrice;
  final String phoneNumber;
  final String emailAddress;
  final String website;
  final String city;
  final String country;
  final String exactLocation;
  final double latitude;
  final double longitude;
  final String registrationNumber;
  final String status;
  final List<String> amenities;
  final List<String> facilities;
  final String amenitiesNotes;
  final String bookingAdvanceDays;
  final String cancellationWindowHours;
  final String houseRules;
  final bool allowCancellation;
  final bool requiresAdvancePayment;
  final bool supportsRefunds;
  final String selectedPackageId;
  final String selectedPackageTitle;
  final String shopLogo;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'owner': owner,
      'shopName': shopName,
      'slug': slug,
      'description': description,
      'establishedYear': establishedYear,
      'basicPrice': basicPrice,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'website': website,
      'city': city,
      'country': country,
      'exactLocation': exactLocation,
      'latitude': latitude,
      'longitude': longitude,
      'registrationNumber': registrationNumber,
      'status': status,
      'amenities': amenities,
      'facilities': facilities,
      'amenitiesNotes': amenitiesNotes,
      'bookingAdvanceDays': bookingAdvanceDays,
      'cancellationWindowHours': cancellationWindowHours,
      'houseRules': houseRules,
      'allowCancellation': allowCancellation,
      'requiresAdvancePayment': requiresAdvancePayment,
      'supportsRefunds': supportsRefunds,
      'selectedPackageId': selectedPackageId,
      'selectedPackageTitle': selectedPackageTitle,
      'shopLogo': shopLogo,
    };
  }
}
