class UploadRef {
  const UploadRef({
    required this.name,
    required this.localPath,
    this.remoteUrl,
  });

  final String name;
  final String localPath;
  final String? remoteUrl;

  UploadRef copyWith({String? name, String? localPath, String? remoteUrl}) {
    return UploadRef(
      name: name ?? this.name,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'localPath': localPath,
      'remoteUrl': remoteUrl,
    };
  }

  factory UploadRef.fromJson(Map<String, dynamic> json) {
    return UploadRef(
      name: json['name'] as String? ?? '',
      localPath: json['localPath'] as String? ?? '',
      remoteUrl: json['remoteUrl'] as String?,
    );
  }
}

class LocationDraft {
  const LocationDraft({
    this.fullAddress = '',
    this.exactLocation = '',
    this.longitude,
    this.latitude,
  });

  final String fullAddress;
  final String exactLocation;
  final double? longitude;
  final double? latitude;

  LocationDraft copyWith({
    String? fullAddress,
    String? exactLocation,
    double? longitude,
    double? latitude,
    bool clearLongitude = false,
    bool clearLatitude = false,
  }) {
    return LocationDraft(
      fullAddress: fullAddress ?? this.fullAddress,
      exactLocation: exactLocation ?? this.exactLocation,
      longitude: clearLongitude ? null : longitude ?? this.longitude,
      latitude: clearLatitude ? null : latitude ?? this.latitude,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullAddress': fullAddress,
      'exactLocation': exactLocation,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  factory LocationDraft.fromJson(Map<String, dynamic> json) {
    return LocationDraft(
      fullAddress: json['fullAddress'] as String? ?? '',
      exactLocation: json['exactLocation'] as String? ?? '',
      longitude: _asDouble(json['longitude']),
      latitude: _asDouble(json['latitude']),
    );
  }
}

class AvailabilityDraft {
  const AvailabilityDraft({
    this.days = const <String>{},
    this.openTime = '',
    this.closeTime = '',
    this.isOpen24Hours = false,
  });

  final Set<String> days;
  final String openTime;
  final String closeTime;
  final bool isOpen24Hours;

  AvailabilityDraft copyWith({
    Set<String>? days,
    String? openTime,
    String? closeTime,
    bool? isOpen24Hours,
  }) {
    return AvailabilityDraft(
      days: days ?? this.days,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen24Hours: isOpen24Hours ?? this.isOpen24Hours,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'days': days.toList(),
      'openTime': openTime,
      'closeTime': closeTime,
      'isOpen24Hours': isOpen24Hours,
    };
  }

  factory AvailabilityDraft.fromJson(Map<String, dynamic> json) {
    return AvailabilityDraft(
      days: _stringSetFromJson(json['days']),
      openTime: json['openTime'] as String? ?? '',
      closeTime: json['closeTime'] as String? ?? '',
      isOpen24Hours: json['isOpen24Hours'] as bool? ?? false,
    );
  }
}

class SlotPricingDraft {
  const SlotPricingDraft({
    required this.id,
    this.label = '',
    this.days = const <String>{},
    this.startTime = '',
    this.endTime = '',
    this.price,
    this.paymentPercent,
  });

  final String id;
  final String label;
  final Set<String> days;
  final String startTime;
  final String endTime;
  final double? price;
  final double? paymentPercent;

  SlotPricingDraft copyWith({
    String? label,
    Set<String>? days,
    String? startTime,
    String? endTime,
    double? price,
    double? paymentPercent,
    bool clearPrice = false,
    bool clearPaymentPercent = false,
  }) {
    return SlotPricingDraft(
      id: id,
      label: label ?? this.label,
      days: days ?? this.days,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: clearPrice ? null : price ?? this.price,
      paymentPercent: clearPaymentPercent
          ? null
          : paymentPercent ?? this.paymentPercent,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'days': days.toList(),
      'startTime': startTime,
      'endTime': endTime,
      'price': price,
      'paymentPercent': paymentPercent,
    };
  }

  factory SlotPricingDraft.fromJson(Map<String, dynamic> json) {
    return SlotPricingDraft(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      days: _stringSetFromJson(json['days']),
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      price: _asDouble(json['price']),
      paymentPercent: _asDouble(json['paymentPercent']),
    );
  }
}

class FutsalDraft {
  const FutsalDraft({
    this.title = '',
    this.description = '',
    this.registrationNumber = '',
    this.phone = '',
    this.email = '',
    this.location = const LocationDraft(),
    this.amenities = const <String>{},
    this.features = const <String>{},
    this.cancellationPolicy = '',
    this.futsalRules = '',
    this.commissionPercent,
    this.coverImage,
    this.gallery = const <UploadRef>[],
    this.companyDocuments = const <UploadRef>[],
  });

  final String title;
  final String description;
  final String registrationNumber;
  final String phone;
  final String email;
  final LocationDraft location;
  final Set<String> amenities;
  final Set<String> features;
  final String cancellationPolicy;
  final String futsalRules;
  final double? commissionPercent;
  final UploadRef? coverImage;
  final List<UploadRef> gallery;
  final List<UploadRef> companyDocuments;

  FutsalDraft copyWith({
    String? title,
    String? description,
    String? registrationNumber,
    String? phone,
    String? email,
    LocationDraft? location,
    Set<String>? amenities,
    Set<String>? features,
    String? cancellationPolicy,
    String? futsalRules,
    double? commissionPercent,
    UploadRef? coverImage,
    List<UploadRef>? gallery,
    List<UploadRef>? companyDocuments,
    bool clearCommissionPercent = false,
    bool clearCoverImage = false,
  }) {
    return FutsalDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      amenities: amenities ?? this.amenities,
      features: features ?? this.features,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      futsalRules: futsalRules ?? this.futsalRules,
      commissionPercent: clearCommissionPercent
          ? null
          : commissionPercent ?? this.commissionPercent,
      coverImage: clearCoverImage ? null : coverImage ?? this.coverImage,
      gallery: gallery ?? this.gallery,
      companyDocuments: companyDocuments ?? this.companyDocuments,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'registrationNumber': registrationNumber,
      'phone': phone,
      'email': email,
      'location': location.toJson(),
      'amenities': amenities.toList(),
      'features': features.toList(),
      'cancellationPolicy': cancellationPolicy,
      'futsalRules': futsalRules,
      'commissionPercent': commissionPercent,
      'coverImage': coverImage?.toJson(),
      'gallery': gallery.map((UploadRef item) => item.toJson()).toList(),
      'companyDocuments': companyDocuments
          .map((UploadRef item) => item.toJson())
          .toList(),
    };
  }

  factory FutsalDraft.fromJson(Map<String, dynamic> json) {
    return FutsalDraft(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      registrationNumber: json['registrationNumber'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      location: LocationDraft.fromJson(
        json['location'] is Map
            ? Map<String, dynamic>.from(json['location'] as Map)
            : const <String, dynamic>{},
      ),
      amenities: _stringSetFromJson(json['amenities']),
      features: _stringSetFromJson(json['features']),
      cancellationPolicy: json['cancellationPolicy'] as String? ?? '',
      futsalRules: json['futsalRules'] as String? ?? '',
      commissionPercent: _asDouble(json['commissionPercent']),
      coverImage: _uploadFromJson(json['coverImage']),
      gallery: _uploadsFromJson(json['gallery']),
      companyDocuments: _uploadsFromJson(json['companyDocuments']),
    );
  }
}

class CourtDraft {
  const CourtDraft({
    required this.id,
    this.name = '',
    this.basePrice,
    this.description = '',
    this.courtType,
    this.availability = const AvailabilityDraft(),
    this.enableOnlineBooking = true,
    this.advancePaymentRequired = false,
    this.paymentPercent,
    this.paymentQr,
    this.amenities = const <String>{},
    this.facilities = const <String>{},
    this.photos = const <UploadRef>[],
    this.memories = const <UploadRef>[],
    this.slotConfigs = const <SlotPricingDraft>[],
  });

  final String id;
  final String name;
  final double? basePrice;
  final String description;
  final String? courtType;
  final AvailabilityDraft availability;
  final bool enableOnlineBooking;
  final bool advancePaymentRequired;
  final double? paymentPercent;
  final UploadRef? paymentQr;
  final Set<String> amenities;
  final Set<String> facilities;
  final List<UploadRef> photos;
  final List<UploadRef> memories;
  final List<SlotPricingDraft> slotConfigs;

  CourtDraft copyWith({
    String? name,
    double? basePrice,
    String? description,
    String? courtType,
    AvailabilityDraft? availability,
    bool? enableOnlineBooking,
    bool? advancePaymentRequired,
    double? paymentPercent,
    UploadRef? paymentQr,
    Set<String>? amenities,
    Set<String>? facilities,
    List<UploadRef>? photos,
    List<UploadRef>? memories,
    List<SlotPricingDraft>? slotConfigs,
    bool clearBasePrice = false,
    bool clearCourtType = false,
    bool clearPaymentPercent = false,
    bool clearPaymentQr = false,
  }) {
    return CourtDraft(
      id: id,
      name: name ?? this.name,
      basePrice: clearBasePrice ? null : basePrice ?? this.basePrice,
      description: description ?? this.description,
      courtType: clearCourtType ? null : courtType ?? this.courtType,
      availability: availability ?? this.availability,
      enableOnlineBooking: enableOnlineBooking ?? this.enableOnlineBooking,
      advancePaymentRequired:
          advancePaymentRequired ?? this.advancePaymentRequired,
      paymentPercent: clearPaymentPercent
          ? null
          : paymentPercent ?? this.paymentPercent,
      paymentQr: clearPaymentQr ? null : paymentQr ?? this.paymentQr,
      amenities: amenities ?? this.amenities,
      facilities: facilities ?? this.facilities,
      photos: photos ?? this.photos,
      memories: memories ?? this.memories,
      slotConfigs: slotConfigs ?? this.slotConfigs,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'description': description,
      'courtType': courtType,
      'availability': availability.toJson(),
      'enableOnlineBooking': enableOnlineBooking,
      'advancePaymentRequired': advancePaymentRequired,
      'paymentPercent': paymentPercent,
      'paymentQr': paymentQr?.toJson(),
      'amenities': amenities.toList(),
      'facilities': facilities.toList(),
      'photos': photos.map((UploadRef item) => item.toJson()).toList(),
      'memories': memories.map((UploadRef item) => item.toJson()).toList(),
      'slotConfigs': slotConfigs
          .map((SlotPricingDraft item) => item.toJson())
          .toList(),
    };
  }

  factory CourtDraft.fromJson(Map<String, dynamic> json) {
    return CourtDraft(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      basePrice: _asDouble(json['basePrice']),
      description: json['description'] as String? ?? '',
      courtType: json['courtType'] as String?,
      availability: AvailabilityDraft.fromJson(
        json['availability'] is Map
            ? Map<String, dynamic>.from(json['availability'] as Map)
            : const <String, dynamic>{},
      ),
      enableOnlineBooking: json['enableOnlineBooking'] as bool? ?? true,
      advancePaymentRequired: json['advancePaymentRequired'] as bool? ?? false,
      paymentPercent: _asDouble(json['paymentPercent']),
      paymentQr: _uploadFromJson(json['paymentQr']),
      amenities: _stringSetFromJson(json['amenities']),
      facilities: _stringSetFromJson(json['facilities']),
      photos: _uploadsFromJson(json['photos']),
      memories: _uploadsFromJson(json['memories']),
      slotConfigs: _slotConfigsFromJson(json['slotConfigs']),
    );
  }
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

Set<String> _stringSetFromJson(Object? value) {
  if (value is! List) return const <String>{};
  return value.whereType<String>().toSet();
}

UploadRef? _uploadFromJson(Object? value) {
  if (value is! Map) return null;
  return UploadRef.fromJson(Map<String, dynamic>.from(value));
}

List<UploadRef> _uploadsFromJson(Object? value) {
  if (value is! List) return const <UploadRef>[];
  return value
      .whereType<Map>()
      .map((Map item) => UploadRef.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<SlotPricingDraft> _slotConfigsFromJson(Object? value) {
  if (value is! List) return const <SlotPricingDraft>[];
  return value
      .whereType<Map>()
      .map(
        (Map item) =>
            SlotPricingDraft.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList();
}
