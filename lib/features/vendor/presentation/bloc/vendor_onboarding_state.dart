import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';

class VendorOnboardingState {
  const VendorOnboardingState({
    required this.cursor,
    required this.futsalPointer,
    required this.courtPointersById,
    required this.futsal,
    required this.courts,
    required this.errorKeys,
    required this.saveStatus,
    required this.isDirty,
    required this.isSubmitting,
    required this.isRestoringDraft,
    required this.isCompleted,
    this.activeCourtId,
    this.lastSavedAt,
    this.errorMessage,
  });

  factory VendorOnboardingState.initial() {
    return const VendorOnboardingState(
      cursor: StepCursor(
        category: VendorCategory.futsal,
        sectionIndex: 0,
        subsectionIndex: 0,
      ),
      futsalPointer: SectionPointer(sectionIndex: 0, subsectionIndex: 0),
      courtPointersById: <String, SectionPointer>{},
      futsal: FutsalDraft(),
      courts: <CourtDraft>[],
      errorKeys: <String>{},
      saveStatus: DraftSaveStatus.idle,
      isDirty: false,
      isSubmitting: false,
      isRestoringDraft: true,
      isCompleted: false,
    );
  }

  final StepCursor cursor;
  final SectionPointer futsalPointer;
  final Map<String, SectionPointer> courtPointersById;
  final FutsalDraft futsal;
  final List<CourtDraft> courts;
  final String? activeCourtId;
  final Set<String> errorKeys;
  final DraftSaveStatus saveStatus;
  final DateTime? lastSavedAt;
  final bool isDirty;
  final bool isSubmitting;
  final bool isRestoringDraft;
  final bool isCompleted;
  final String? errorMessage;

  bool get isInCourtCategory => cursor.category == VendorCategory.court;

  CourtDraft? get activeCourt {
    if (activeCourtId == null) return null;
    for (final CourtDraft court in courts) {
      if (court.id == activeCourtId) return court;
    }
    return null;
  }

  SectionPointer? get activeCourtPointer {
    if (activeCourtId == null) return null;
    return courtPointersById[activeCourtId!];
  }

  VendorOnboardingState copyWith({
    StepCursor? cursor,
    SectionPointer? futsalPointer,
    Map<String, SectionPointer>? courtPointersById,
    FutsalDraft? futsal,
    List<CourtDraft>? courts,
    String? activeCourtId,
    Set<String>? errorKeys,
    DraftSaveStatus? saveStatus,
    DateTime? lastSavedAt,
    bool? isDirty,
    bool? isSubmitting,
    bool? isRestoringDraft,
    bool? isCompleted,
    String? errorMessage,
    bool clearActiveCourtId = false,
    bool clearLastSavedAt = false,
    bool clearErrorMessage = false,
  }) {
    return VendorOnboardingState(
      cursor: cursor ?? this.cursor,
      futsalPointer: futsalPointer ?? this.futsalPointer,
      courtPointersById: courtPointersById ?? this.courtPointersById,
      futsal: futsal ?? this.futsal,
      courts: courts ?? this.courts,
      activeCourtId: clearActiveCourtId
          ? null
          : activeCourtId ?? this.activeCourtId,
      errorKeys: errorKeys ?? this.errorKeys,
      saveStatus: saveStatus ?? this.saveStatus,
      lastSavedAt: clearLastSavedAt ? null : lastSavedAt ?? this.lastSavedAt,
      isDirty: isDirty ?? this.isDirty,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isRestoringDraft: isRestoringDraft ?? this.isRestoringDraft,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cursor': cursor.toJson(),
      'futsalPointer': futsalPointer.toJson(),
      'courtPointersById': courtPointersById.map(
        (String key, SectionPointer value) =>
            MapEntry<String, dynamic>(key, value.toJson()),
      ),
      'futsal': futsal.toJson(),
      'courts': courts.map((CourtDraft item) => item.toJson()).toList(),
      'activeCourtId': activeCourtId,
      'lastSavedAt': lastSavedAt?.toIso8601String(),
    };
  }

  factory VendorOnboardingState.fromJson(Map<String, dynamic> json) {
    final Map<String, SectionPointer> courtPointersById =
        <String, SectionPointer>{};
    final Object? pointersObject = json['courtPointersById'];
    if (pointersObject is Map) {
      for (final MapEntry<dynamic, dynamic> entry in pointersObject.entries) {
        final String? key = entry.key?.toString();
        final dynamic rawValue = entry.value;
        if (key != null && rawValue is Map) {
          courtPointersById[key] = SectionPointer.fromJson(
            Map<String, dynamic>.from(rawValue),
          );
        }
      }
    }

    final List<CourtDraft> courts =
        ((json['courts'] as List?) ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(CourtDraft.fromJson)
            .toList();

    return VendorOnboardingState(
      cursor: StepCursor.fromJson(
        json['cursor'] is Map
            ? Map<String, dynamic>.from(json['cursor'] as Map)
            : const <String, dynamic>{},
      ),
      futsalPointer: SectionPointer.fromJson(
        json['futsalPointer'] is Map
            ? Map<String, dynamic>.from(json['futsalPointer'] as Map)
            : const <String, dynamic>{},
      ),
      courtPointersById: courtPointersById,
      futsal: FutsalDraft.fromJson(
        json['futsal'] is Map
            ? Map<String, dynamic>.from(json['futsal'] as Map)
            : const <String, dynamic>{},
      ),
      courts: courts,
      activeCourtId: json['activeCourtId'] as String?,
      errorKeys: const <String>{},
      saveStatus: DraftSaveStatus.idle,
      lastSavedAt: _dateFromString(json['lastSavedAt'] as String?),
      isDirty: false,
      isSubmitting: false,
      isRestoringDraft: false,
      isCompleted: false,
    );
  }
}

DateTime? _dateFromString(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
