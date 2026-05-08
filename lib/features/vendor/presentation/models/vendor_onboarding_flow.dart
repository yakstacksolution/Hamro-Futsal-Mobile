import 'package:flutter/material.dart';

enum VendorCategory { futsal, court }

enum StepStatus { locked, notStarted, inProgress, complete, error, pending }

enum DraftSaveStatus { idle, saving, saved, failure, error, unsaved }

enum VendorErrorOrigin { validation, api, local }

enum FutsalSection { information, policyRules, business }

enum FutsalInformationSubstep { basicInfo, location, amenitiesFeatures }

enum FutsalPolicySubstep { cancellationPolicy, futsalRules, commissions }

enum FutsalBusinessSubstep { coverImage, gallery, companyDocuments }

enum CourtSection {
  information,
  bookingPayment,
  amenitiesFacilities,
  slotsPayments,
}

enum CourtInformationSubstep { basicInfo, description, photosMemories }

enum CourtBookingPaymentSubstep { advancePayment, paymentQr }

enum CourtAmenitiesSubstep { details }

enum CourtSlotsSubstep { slotSchedule, weekendHolidays, slotPricing }

class VendorSubstepDefinition {
  const VendorSubstepDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

class VendorSectionDefinition {
  const VendorSectionDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.substeps,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<VendorSubstepDefinition> substeps;
}

class SectionPointer {
  const SectionPointer({
    required this.sectionIndex,
    required this.subsectionIndex,
  });

  final int sectionIndex;
  final int subsectionIndex;

  SectionPointer copyWith({int? sectionIndex, int? subsectionIndex}) {
    return SectionPointer(
      sectionIndex: sectionIndex ?? this.sectionIndex,
      subsectionIndex: subsectionIndex ?? this.subsectionIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sectionIndex': sectionIndex,
      'subsectionIndex': subsectionIndex,
    };
  }

  factory SectionPointer.fromJson(Map<String, dynamic> json) {
    return SectionPointer(
      sectionIndex: json['sectionIndex'] as int? ?? 0,
      subsectionIndex: json['subsectionIndex'] as int? ?? 0,
    );
  }
}

class StepCursor {
  const StepCursor({
    required this.category,
    required this.sectionIndex,
    required this.subsectionIndex,
    this.courtId,
  });

  final VendorCategory category;
  final int sectionIndex;
  final int subsectionIndex;
  final String? courtId;

  StepCursor copyWith({
    VendorCategory? category,
    int? sectionIndex,
    int? subsectionIndex,
    String? courtId,
    bool clearCourtId = false,
  }) {
    return StepCursor(
      category: category ?? this.category,
      sectionIndex: sectionIndex ?? this.sectionIndex,
      subsectionIndex: subsectionIndex ?? this.subsectionIndex,
      courtId: clearCourtId ? null : courtId ?? this.courtId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'category': category.name,
      'sectionIndex': sectionIndex,
      'subsectionIndex': subsectionIndex,
      'courtId': courtId,
    };
  }

  factory StepCursor.fromJson(Map<String, dynamic> json) {
    return StepCursor(
      category: VendorCategory.values.firstWhere(
        (VendorCategory item) => item.name == json['category'],
        orElse: () => VendorCategory.futsal,
      ),
      sectionIndex: json['sectionIndex'] as int? ?? 0,
      subsectionIndex: json['subsectionIndex'] as int? ?? 0,
      courtId: json['courtId'] as String?,
    );
  }
}

const List<VendorSectionDefinition> futsalSectionDefinitions =
    <VendorSectionDefinition>[
      VendorSectionDefinition(
        id: 'futsal_information',
        title: 'Information',
        subtitle: 'Title, contacts, location, amenities, and features.',
        icon: Icons.storefront_rounded,
        substeps: <VendorSubstepDefinition>[
          VendorSubstepDefinition(
            id: 'basic_info',
            title: 'Basic Info',
            subtitle: 'Title, phone, and email.',
          ),
          VendorSubstepDefinition(
            id: 'description',
            title: 'Description',
            subtitle: 'Tell customers about your futsal.',
          ),
          VendorSubstepDefinition(
            id: 'location',
            title: 'Location',
            subtitle: 'Address, exact location, longitude, and latitude.',
          ),
          // VendorSubstepDefinition(
          //   id: 'amenities_features',
          //   title: 'Amenities',
          //   subtitle: 'Venue amenities and key features.',
          // ),
        ],
      ),
      VendorSectionDefinition(
        id: 'futsal_policy_rules',
        title: 'Policy & Rules',
        subtitle: 'Cancellation policy, futsal rules, and commissions.',
        icon: Icons.policy_rounded,
        substeps: <VendorSubstepDefinition>[
          VendorSubstepDefinition(
            id: 'cancellation_policy',
            title: 'Cancellation Policy',
            subtitle: 'How refunds and cancellations are handled.',
          ),
          VendorSubstepDefinition(
            id: 'futsal_rules',
            title: 'Futsal Rules',
            subtitle: 'House rules for players and bookings.',
          ),
          VendorSubstepDefinition(
            id: 'commissions',
            title: 'Commissions',
            subtitle: 'Platform commission and commercial terms.',
          ),
        ],
      ),
      VendorSectionDefinition(
        id: 'futsal_business',
        title: 'Business',
        subtitle: 'Cover media, gallery, and business documents.',
        icon: Icons.business_center_rounded,
        substeps: <VendorSubstepDefinition>[
          VendorSubstepDefinition(
            id: 'cover_image',
            title: 'Cover Image',
            subtitle: 'Primary futsal cover image.',
          ),
          VendorSubstepDefinition(
            id: 'gallery',
            title: 'Gallery',
            subtitle: 'Venue-level photos for the listing.',
          ),
          VendorSubstepDefinition(
            id: 'company_documents',
            title: 'Company Docs',
            subtitle: 'Legal and supporting company documents.',
          ),
        ],
      ),
    ];

const List<VendorSectionDefinition> courtSectionDefinitions =
    <VendorSectionDefinition>[
      VendorSectionDefinition(
        id: 'court_information',
        title: 'Information',
        subtitle: 'Court identity, description, photos, and memories.',
        icon: Icons.stadium_rounded,
        substeps: <VendorSubstepDefinition>[
          VendorSubstepDefinition(
            id: 'court_basic_info',
            title: 'Court Info',
            subtitle: 'Name, base price, and court type.',
          ),
          VendorSubstepDefinition(
            id: 'court_description',
            title: 'Description',
            subtitle: 'Tell customers about this court.',
          ),
          VendorSubstepDefinition(
            id: 'court_photos_memories',
            title: 'Photos & Memories',
            subtitle: 'Court photos and memories.',
          ),
        ],
      ),
      VendorSectionDefinition(
        id: 'court_booking_payment',
        title: 'Booking & Payment',
        subtitle: 'Advance payment requirements and QR.',
        icon: Icons.payments_rounded,
        substeps: <VendorSubstepDefinition>[
          VendorSubstepDefinition(
            id: 'advance_payment',
            title: 'Advance Payment',
            subtitle: 'Requirement and collection percentage.',
          ),
          VendorSubstepDefinition(
            id: 'payment_qr',
            title: 'Payment QR',
            subtitle: 'QR code used for advance payment.',
          ),
        ],
      ),
      VendorSectionDefinition(
        id: 'court_amenities',
        title: 'Amenities',
        subtitle: 'Court-specific amenities and facilities.',
        icon: Icons.weekend_rounded,
        substeps: <VendorSubstepDefinition>[
          VendorSubstepDefinition(
            id: 'court_amenities_form',
            title: 'Amenities',
            subtitle: 'Amenities and facilities for this court.',
          ),
        ],
      ),
      VendorSectionDefinition(
        id: 'court_slots_payments',
        title: 'Slots & Payments',
        subtitle: 'Time slots with pricing and payment options.',
        icon: Icons.schedule_rounded,
        substeps: <VendorSubstepDefinition>[
          VendorSubstepDefinition(
            id: 'weekend_holidays',
            title: 'Weekend & Closures',
            subtitle: 'Mark weekend days, holiday dates, and closed dates.',
          ),
          VendorSubstepDefinition(
            id: 'slot_schedule',
            title: 'Slot Schedule',
            subtitle: 'Configure date and time slots.',
          ),
          VendorSubstepDefinition(
            id: 'slot_pricing',
            title: 'Slot Pricing',
            subtitle: 'Set default, weekend, holiday, and discount prices.',
          ),
        ],
      ),
    ];

List<VendorSectionDefinition> sectionsForCategory(VendorCategory category) {
  return category == VendorCategory.futsal
      ? futsalSectionDefinitions
      : courtSectionDefinitions;
}

const List<String> futsalAmenityOptions = <String>[
  'Floodlights',
  'Parking',
  'Changing Room',
  'Shower',
  'Wi-Fi',
  'First Aid',
];

const Map<String, IconData> futsalAmenityIcons = <String, IconData>{
  'Floodlights': Icons.light_mode_rounded,
  'Parking': Icons.local_parking_rounded,
  'Changing Room': Icons.checkroom_rounded,
  'Shower': Icons.shower_rounded,
  'Wi-Fi': Icons.wifi_rounded,
  'First Aid': Icons.medical_services_rounded,
};

const List<String> futsalFeatureOptions = <String>[
  'Live Scoreboard',
  'Warm-Up Zone',
  'Cafeteria',
  'Spectator Seating',
  'Equipment Rental',
  'Locker Storage',
];

const Map<String, IconData> futsalFeatureIcons = <String, IconData>{
  'Live Scoreboard': Icons.scoreboard_rounded,
  'Warm-Up Zone': Icons.fitness_center_rounded,
  'Cafeteria': Icons.restaurant_rounded,
  'Spectator Seating': Icons.event_seat_rounded,
  'Equipment Rental': Icons.sports_soccer_rounded,
  'Locker Storage': Icons.lock_rounded,
};

const List<String> courtAmenityOptions = <String>[
  'Goal Nets',
  'Scoreboard',
  'Ball Stand',
  'Benches',
  'Drinking Water',
  'Lighting',
];

const Map<String, IconData> courtAmenityIcons = <String, IconData>{
  'Goal Nets': Icons.sports_soccer_rounded,
  'Scoreboard': Icons.scoreboard_rounded,
  'Ball Stand': Icons.sports_baseball_rounded,
  'Benches': Icons.weekend_rounded,
  'Drinking Water': Icons.water_drop_rounded,
  'Lighting': Icons.light_mode_rounded,
};

const List<String> courtFacilityOptions = <String>[
  'Indoor',
  'Roofed',
  'Changing Area',
  'Washroom Access',
  'Parking Access',
  'Spectator Zone',
];

const Map<String, IconData> courtFacilityIcons = <String, IconData>{
  'Indoor': Icons.home_work_rounded,
  'Roofed': Icons.roofing_rounded,
  'Changing Area': Icons.checkroom_rounded,
  'Washroom Access': Icons.wc_rounded,
  'Parking Access': Icons.local_parking_rounded,
  'Spectator Zone': Icons.event_seat_rounded,
};

const List<String> courtTypeOptions = <String>['Indoor', 'Outdoor'];

const List<String> matchFormatOptions = <String>['5v5', '6v6', '7v7'];

const List<String> weekdayOptions = <String>[
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
];
