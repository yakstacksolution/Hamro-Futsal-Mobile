class UploadRef {
  const UploadRef({required this.name, this.id, this.remoteUrl});

  final String name;
  final int? id;
  final String? remoteUrl;

  UploadRef copyWith({
    String? name,
    String? localPath,
    int? id,
    String? remoteUrl,
    bool clearId = false,
  }) {
    return UploadRef(
      name: name ?? this.name,
      id: clearId ? null : id ?? this.id,
      remoteUrl: remoteUrl ?? this.remoteUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'name': name, 'id': id, 'remoteUrl': remoteUrl};
  }

  factory UploadRef.fromJson(Map<String, dynamic> json) {
    return UploadRef(
      name: json['name'] as String? ?? '',
      id: json['id'] as int?,
      remoteUrl: json['remoteUrl'] as String?,
    );
  }
}

class SelectedImageRef {
  const SelectedImageRef({required this.image, this.id});

  final UploadRef image;
  final int? id;

  factory SelectedImageRef.fromUploadRef(UploadRef upload) {
    return SelectedImageRef(image: upload, id: upload.id);
  }

  SelectedImageRef copyWith({UploadRef? image, int? id, bool clearId = false}) {
    return SelectedImageRef(
      image: image ?? this.image,
      id: clearId ? null : id ?? this.id,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'image': image.toJson(), 'id': id};
  }

  factory SelectedImageRef.fromJson(Map<String, dynamic> json) {
    final UploadRef image = json['image'] is Map
        ? UploadRef.fromJson(Map<String, dynamic>.from(json['image'] as Map))
        : UploadRef(
            name: json['name'] as String? ?? '',
            id: _asInt(json['id']),
            remoteUrl: json['remoteUrl'] as String?,
          );
    return SelectedImageRef(id: _asInt(json['id']) ?? image.id, image: image);
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
    this.weekendPrice,
    this.holidayPrice,
    this.customDatePrices = const <SlotCustomDatePriceDraft>[],
    this.discountPrice,
    this.discountType = 'Flat',
    this.paymentPercent,
  });

  final String id;
  final String label;
  final Set<String> days;
  final String startTime;
  final String endTime;
  final double? price;
  final double? weekendPrice;
  final double? holidayPrice;
  final List<SlotCustomDatePriceDraft> customDatePrices;
  final double? discountPrice;
  final String discountType;
  final double? paymentPercent;

  SlotPricingDraft copyWith({
    String? label,
    Set<String>? days,
    String? startTime,
    String? endTime,
    double? price,
    double? weekendPrice,
    double? holidayPrice,
    List<SlotCustomDatePriceDraft>? customDatePrices,
    double? discountPrice,
    String? discountType,
    double? paymentPercent,
    bool clearPrice = false,
    bool clearWeekendPrice = false,
    bool clearHolidayPrice = false,
    bool clearDiscountPrice = false,
    bool clearPaymentPercent = false,
  }) {
    return SlotPricingDraft(
      id: id,
      label: label ?? this.label,
      days: days ?? this.days,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: clearPrice ? null : price ?? this.price,
      weekendPrice: clearWeekendPrice
          ? null
          : weekendPrice ?? this.weekendPrice,
      holidayPrice: clearHolidayPrice
          ? null
          : holidayPrice ?? this.holidayPrice,
      customDatePrices: customDatePrices ?? this.customDatePrices,
      discountPrice: clearDiscountPrice
          ? null
          : discountPrice ?? this.discountPrice,
      discountType: discountType ?? this.discountType,
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
      'weekendPrice': weekendPrice,
      'holidayPrice': holidayPrice,
      'customDatePrices': customDatePrices
          .map((SlotCustomDatePriceDraft item) => item.toJson())
          .toList(),
      'discountPrice': discountPrice,
      'discountType': discountType,
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
      weekendPrice: _asDouble(json['weekendPrice']),
      holidayPrice: _asDouble(json['holidayPrice']),
      customDatePrices: _slotCustomDatePricesFromJson(json['customDatePrices']),
      discountPrice: _asDouble(json['discountPrice']),
      discountType: _normalizedDiscountType(json['discountType'] as String?),
      paymentPercent: _asDouble(json['paymentPercent']),
    );
  }
}

class SlotCustomDatePriceDraft {
  const SlotCustomDatePriceDraft({required this.date, required this.price});

  final String date;
  final double price;

  SlotCustomDatePriceDraft copyWith({String? date, double? price}) {
    return SlotCustomDatePriceDraft(
      date: date ?? this.date,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'date': date, 'price': price};
  }

  factory SlotCustomDatePriceDraft.fromJson(Map<String, dynamic> json) {
    return SlotCustomDatePriceDraft(
      date: json['date'] as String? ?? '',
      price: _asDouble(json['price']) ?? 0,
    );
  }
}

class FutsalDraft {
  const FutsalDraft({
    this.title = '',
    this.slug = '',
    this.description = '',
    this.registrationNumber = '',
    this.phone = '',
    this.email = '',
    this.websiteOrSocialLink = '',
    this.location = const LocationDraft(),
    this.amenities = const <String>{},
    this.features = const <String>{},
    this.cancellationPolicy = '',
    this.futsalRules = '',
    this.packageId,
    this.commissionPercent,
    this.coverImage,
    this.gallery = const <UploadRef>[],
    this.selectedCoverImage,
    this.selectedGalleryImages = const <SelectedImageRef>[],
    this.companyDocuments = const <UploadRef>[],
  });

  final String title;
  final String slug;
  final String description;
  final String registrationNumber;
  final String phone;
  final String email;
  final String websiteOrSocialLink;
  final LocationDraft location;
  final Set<String> amenities;
  final Set<String> features;
  final String cancellationPolicy;
  final String futsalRules;
  final int? packageId;
  final double? commissionPercent;
  final UploadRef? coverImage;
  final List<UploadRef> gallery;
  final SelectedImageRef? selectedCoverImage;
  final List<SelectedImageRef> selectedGalleryImages;
  final List<UploadRef> companyDocuments;

  FutsalDraft copyWith({
    String? title,
    String? slug,
    String? description,
    String? registrationNumber,
    String? phone,
    String? email,
    String? websiteOrSocialLink,
    LocationDraft? location,
    Set<String>? amenities,
    Set<String>? features,
    String? cancellationPolicy,
    String? futsalRules,
    int? packageId,
    double? commissionPercent,
    UploadRef? coverImage,
    List<UploadRef>? gallery,
    SelectedImageRef? selectedCoverImage,
    List<SelectedImageRef>? selectedGalleryImages,
    List<UploadRef>? companyDocuments,
    bool clearPackageId = false,
    bool clearCommissionPercent = false,
    bool clearCoverImage = false,
    bool clearSelectedCoverImage = false,
  }) {
    return FutsalDraft(
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      websiteOrSocialLink: websiteOrSocialLink ?? this.websiteOrSocialLink,
      location: location ?? this.location,
      amenities: amenities ?? this.amenities,
      features: features ?? this.features,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      futsalRules: futsalRules ?? this.futsalRules,
      packageId: clearPackageId ? null : packageId ?? this.packageId,
      commissionPercent: clearCommissionPercent
          ? null
          : commissionPercent ?? this.commissionPercent,
      coverImage: clearCoverImage ? null : coverImage ?? this.coverImage,
      gallery: gallery ?? this.gallery,
      selectedCoverImage: clearSelectedCoverImage
          ? null
          : selectedCoverImage ?? this.selectedCoverImage,
      selectedGalleryImages:
          selectedGalleryImages ?? this.selectedGalleryImages,
      companyDocuments: companyDocuments ?? this.companyDocuments,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'slug': slug,
      'description': description,
      'registrationNumber': registrationNumber,
      'phone': phone,
      'email': email,
      'websiteOrSocialLink': websiteOrSocialLink,
      'location': location.toJson(),
      'amenities': amenities.toList(),
      'features': features.toList(),
      'cancellationPolicy': cancellationPolicy,
      'futsalRules': futsalRules,
      'packageId': packageId,
      'commissionPercent': commissionPercent,
      'coverImage': coverImage?.toJson(),
      'gallery': gallery.map((UploadRef item) => item.toJson()).toList(),
      'selectedCoverImage': selectedCoverImage?.toJson(),
      'selectedGalleryImages': selectedGalleryImages
          .map((SelectedImageRef item) => item.toJson())
          .toList(),
      'companyDocuments': companyDocuments
          .map((UploadRef item) => item.toJson())
          .toList(),
    };
  }

  factory FutsalDraft.fromJson(Map<String, dynamic> json) {
    final UploadRef? parsedCoverImage = _uploadFromJson(json['coverImage']);
    final List<UploadRef> parsedGallery = _uploadsFromJson(json['gallery']);
    final List<SelectedImageRef> parsedSelectedGallery =
        _selectedImagesFromJson(json['selectedGalleryImages']);
    return FutsalDraft(
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description:
          json['description'] as String? ??
          json['court_description'] as String? ??
          '',
      registrationNumber: json['registrationNumber'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      websiteOrSocialLink: json['websiteOrSocialLink'] as String? ?? '',
      location: LocationDraft.fromJson(
        json['location'] is Map
            ? Map<String, dynamic>.from(json['location'] as Map)
            : const <String, dynamic>{},
      ),
      amenities: _stringSetFromJson(json['amenities']),
      features: _stringSetFromJson(json['features']),
      cancellationPolicy: json['cancellationPolicy'] as String? ?? '',
      futsalRules: json['futsalRules'] as String? ?? '',
      packageId: _asInt(json['packageId']),
      commissionPercent: _asDouble(json['commissionPercent']),
      coverImage: parsedCoverImage,
      gallery: parsedGallery,
      selectedCoverImage:
          _selectedImageFromJson(json['selectedCoverImage']) ??
          (parsedCoverImage == null
              ? null
              : SelectedImageRef.fromUploadRef(parsedCoverImage)),
      selectedGalleryImages: parsedSelectedGallery.isNotEmpty
          ? parsedSelectedGallery
          : parsedGallery.map(SelectedImageRef.fromUploadRef).toList(),
      companyDocuments: _uploadsFromJson(json['companyDocuments']),
    );
  }
}

class CourtDraft {
  const CourtDraft({
    required this.id,
    this.remoteId,
    this.name = '',
    this.basePrice,
    this.description = '',
    this.courtTypeId = 1,
    this.courtType = 'Indoor',
    this.matchFormatId = 1,
    this.matchFormat = '5v5',
    this.maxPlayers = 10,
    this.availability = const AvailabilityDraft(),
    this.enableOnlineBooking = true,
    this.advancePaymentRequired = false,
    this.paymentPercent,
    this.paymentQr,
    this.amenities = const <String>{},
    this.facilities = const <String>{},
    this.photos = const <UploadRef>[],
    this.memories = const <UploadRef>[],
    this.weekendDays = const <String>{'Saturday'},
    this.holidayDates = const <String>{},
    this.closedDates = const <ClosedDateDraft>[],
    this.slotConfigs = const <SlotPricingDraft>[],
  });

  final String id;
  final int? remoteId;
  final String name;
  final double? basePrice;
  final String description;
  final int? courtTypeId;
  final String? courtType;
  final int? matchFormatId;
  final String? matchFormat;
  final int? maxPlayers;
  final AvailabilityDraft availability;
  final bool enableOnlineBooking;
  final bool advancePaymentRequired;
  final double? paymentPercent;
  final UploadRef? paymentQr;
  final Set<String> amenities;
  final Set<String> facilities;
  final List<UploadRef> photos;
  final List<UploadRef> memories;
  final Set<String> weekendDays;
  final Set<String> holidayDates;
  final List<ClosedDateDraft> closedDates;
  final List<SlotPricingDraft> slotConfigs;

  CourtDraft copyWith({
    int? remoteId,
    String? name,
    double? basePrice,
    String? description,
    int? courtTypeId,
    String? courtType,
    int? matchFormatId,
    String? matchFormat,
    int? maxPlayers,
    AvailabilityDraft? availability,
    bool? enableOnlineBooking,
    bool? advancePaymentRequired,
    double? paymentPercent,
    UploadRef? paymentQr,
    Set<String>? amenities,
    Set<String>? facilities,
    List<UploadRef>? photos,
    List<UploadRef>? memories,
    Set<String>? weekendDays,
    Set<String>? holidayDates,
    List<ClosedDateDraft>? closedDates,
    List<SlotPricingDraft>? slotConfigs,
    bool clearBasePrice = false,
    bool clearCourtTypeId = false,
    bool clearCourtType = false,
    bool clearMatchFormatId = false,
    bool clearMatchFormat = false,
    bool clearMaxPlayers = false,
    bool clearPaymentPercent = false,
    bool clearPaymentQr = false,
    bool clearRemoteId = false,
  }) {
    return CourtDraft(
      id: id,
      remoteId: clearRemoteId ? null : remoteId ?? this.remoteId,
      name: name ?? this.name,
      basePrice: clearBasePrice ? null : basePrice ?? this.basePrice,
      description: description ?? this.description,
      courtTypeId: clearCourtTypeId ? null : courtTypeId ?? this.courtTypeId,
      courtType: clearCourtType ? null : courtType ?? this.courtType,
      matchFormatId: clearMatchFormatId
          ? null
          : matchFormatId ?? this.matchFormatId,
      matchFormat: clearMatchFormat ? null : matchFormat ?? this.matchFormat,
      maxPlayers: clearMaxPlayers ? null : maxPlayers ?? this.maxPlayers,
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
      weekendDays: weekendDays ?? this.weekendDays,
      holidayDates: holidayDates ?? this.holidayDates,
      closedDates: closedDates ?? this.closedDates,
      slotConfigs: slotConfigs ?? this.slotConfigs,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'remoteId': remoteId,
      'name': name,
      'basePrice': basePrice,
      'court_description': description,
      'courtTypeId': courtTypeId,
      'courtType': courtType,
      'matchFormatId': matchFormatId,
      'matchFormat': matchFormat,
      'maxPlayers': maxPlayers,
      'availability': availability.toJson(),
      'enableOnlineBooking': enableOnlineBooking,
      'advancePaymentRequired': advancePaymentRequired,
      'paymentPercent': paymentPercent,
      'paymentQr': paymentQr?.toJson(),
      'amenities': amenities.toList(),
      'facilities': facilities.toList(),
      'photos': photos.map((UploadRef item) => item.toJson()).toList(),
      'memories': memories.map((UploadRef item) => item.toJson()).toList(),
      'weekendDays': weekendDays.toList(),
      'holidayDates': holidayDates.toList(),
      'closedDates': closedDates.map((ClosedDateDraft item) {
        return item.toJson();
      }).toList(),
      'slotConfigs': slotConfigs
          .map((SlotPricingDraft item) => item.toJson())
          .toList(),
    };
  }

  factory CourtDraft.fromJson(Map<String, dynamic> json) {
    final Set<String> restoredWeekendDays = _stringSetFromJson(
      json['weekendDays'],
    );
    return CourtDraft(
      id: json['id'] as String? ?? '',
      remoteId: _asInt(
        json['remoteId'] ?? json['remote_id'] ?? json['court_id'],
      ),
      name: (json['name'] ?? json['court_name']) as String? ?? '',
      basePrice: _asDouble(json['basePrice'] ?? json['base_price']),
      description:
          json['description'] as String? ??
          json['court_description'] as String? ??
          '',
      courtTypeId:
          _asInt(json['courtTypeId'] ?? json['court_type_id']) ??
          _knownCourtTypeId(json['courtType'] ?? json['court_type']),
      courtType: _normalizedCourtType(
        json['courtType'] ?? json['court_type_name'] ?? json['court_type'],
      ),
      matchFormatId:
          _asInt(json['matchFormatId'] ?? json['match_format_id']) ??
          _knownMatchFormatId(json['matchFormat'] ?? json['match_format']),
      matchFormat: _normalizedMatchFormat(
        json['matchFormat'] ??
            json['match_format_name'] ??
            json['match_format'],
      ),
      maxPlayers:
          _asInt(
            json['maxPlayers'] ?? json['max_players'] ?? json['max_player'],
          ) ??
          10,
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
      weekendDays: restoredWeekendDays.isEmpty
          ? const <String>{'Saturday'}
          : restoredWeekendDays,
      holidayDates: _stringSetFromJson(json['holidayDates']),
      closedDates: _closedDatesFromJson(json['closedDates']),
      slotConfigs: _slotConfigsFromJson(json['slotConfigs']),
    );
  }
}

class ClosedDateDraft {
  const ClosedDateDraft({
    required this.date,
    this.isFullDay = true,
    this.startTime = '',
    this.endTime = '',
  });

  final String date;
  final bool isFullDay;
  final String startTime;
  final String endTime;

  ClosedDateDraft copyWith({
    String? date,
    bool? isFullDay,
    String? startTime,
    String? endTime,
  }) {
    return ClosedDateDraft(
      date: date ?? this.date,
      isFullDay: isFullDay ?? this.isFullDay,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date,
      'isFullDay': isFullDay,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory ClosedDateDraft.fromJson(Map<String, dynamic> json) {
    final String date = json['date'] as String? ?? '';
    final bool isFullDay = json['isFullDay'] as bool? ?? true;
    return ClosedDateDraft(
      date: date,
      isFullDay: isFullDay,
      startTime: isFullDay ? '' : json['startTime'] as String? ?? '',
      endTime: isFullDay ? '' : json['endTime'] as String? ?? '',
    );
  }
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

String _normalizedCourtType(Object? value) {
  final String normalized = value?.toString().trim() ?? '';
  if (normalized.isEmpty) return 'Indoor';
  return switch (normalized.toLowerCase()) {
    'outdoor' || 'outdoor turf' => 'Outdoor',
    'indoor' => 'Indoor',
    _ => normalized,
  };
}

String _normalizedMatchFormat(Object? value) {
  final String normalized = value?.toString().trim() ?? '';
  if (normalized.isEmpty) return '5v5';
  return switch (normalized.toLowerCase()) {
    '6v6' => '6v6',
    '7v7' => '7v7',
    '5v5' => '5v5',
    _ => normalized,
  };
}

int _knownCourtTypeId(Object? value) {
  return switch (value?.toString().trim().toLowerCase()) {
    '2' || 'outdoor' || 'outdoor turf' => 2,
    _ => 1,
  };
}

int _knownMatchFormatId(Object? value) {
  return switch (value?.toString().trim().toLowerCase()) {
    '2' || '6v6' => 2,
    '3' || '7v7' => 3,
    _ => 1,
  };
}

String _normalizedDiscountType(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'percent' || 'percentage' => 'Percent',
    _ => 'Flat',
  };
}

Set<String> _stringSetFromJson(Object? value) {
  if (value is! List) return const <String>{};
  return value.whereType<String>().toSet();
}

UploadRef? _uploadFromJson(Object? value) {
  if (value is! Map) return null;
  return UploadRef.fromJson(Map<String, dynamic>.from(value));
}

SelectedImageRef? _selectedImageFromJson(Object? value) {
  if (value is! Map) return null;
  return SelectedImageRef.fromJson(Map<String, dynamic>.from(value));
}

List<UploadRef> _uploadsFromJson(Object? value) {
  if (value is! List) return const <UploadRef>[];
  return value
      .whereType<Map>()
      .map((Map item) => UploadRef.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<SelectedImageRef> _selectedImagesFromJson(Object? value) {
  if (value is! List) return const <SelectedImageRef>[];
  return value
      .whereType<Map>()
      .map(
        (Map item) =>
            SelectedImageRef.fromJson(Map<String, dynamic>.from(item)),
      )
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

List<SlotCustomDatePriceDraft> _slotCustomDatePricesFromJson(Object? value) {
  if (value is! List) return const <SlotCustomDatePriceDraft>[];
  return value
      .whereType<Map>()
      .map(
        (Map item) =>
            SlotCustomDatePriceDraft.fromJson(Map<String, dynamic>.from(item)),
      )
      .where((SlotCustomDatePriceDraft item) => item.date.trim().isNotEmpty)
      .toList();
}

List<ClosedDateDraft> _closedDatesFromJson(Object? value) {
  if (value is! List) return const <ClosedDateDraft>[];
  return value
      .map((Object? item) {
        if (item is String) {
          return ClosedDateDraft(date: item);
        }
        if (item is Map) {
          return ClosedDateDraft.fromJson(Map<String, dynamic>.from(item));
        }
        return null;
      })
      .whereType<ClosedDateDraft>()
      .where((ClosedDateDraft item) => item.date.trim().isNotEmpty)
      .toList();
}
