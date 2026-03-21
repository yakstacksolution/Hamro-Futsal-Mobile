import 'dart:typed_data';

class CreateFootsallCourtsState {
  const CreateFootsallCourtsState({
    required this.currentStep,
    required this.totalSteps,
    required this.isSlugAuto,
    required this.isSubmitting,
    required this.status,
    required this.allowCancellation,
    required this.requiresAdvancePayment,
    required this.supportsRefunds,
    this.selectedLogoBytes,
    this.selectedLogoName,
    this.selectedLatitude,
    this.selectedLongitude,
    this.selectedAmenities = const <String>{},
    this.selectedFacilities = const <String>{},
    this.selectedPackageId,
  });

  factory CreateFootsallCourtsState.initial({
    required String status,
    required int totalSteps,
  }) {
    return CreateFootsallCourtsState(
      currentStep: 0,
      totalSteps: totalSteps,
      isSlugAuto: true,
      isSubmitting: false,
      status: status,
      allowCancellation: true,
      requiresAdvancePayment: true,
      supportsRefunds: false,
    );
  }

  final int currentStep;
  final int totalSteps;
  final bool isSlugAuto;
  final bool isSubmitting;
  final String status;
  final bool allowCancellation;
  final bool requiresAdvancePayment;
  final bool supportsRefunds;
  final Uint8List? selectedLogoBytes;
  final String? selectedLogoName;
  final double? selectedLatitude;
  final double? selectedLongitude;
  final Set<String> selectedAmenities;
  final Set<String> selectedFacilities;
  final String? selectedPackageId;

  bool get isLastStep => currentStep == totalSteps - 1;

  CreateFootsallCourtsState copyWith({
    int? currentStep,
    int? totalSteps,
    bool? isSlugAuto,
    bool? isSubmitting,
    String? status,
    bool? allowCancellation,
    bool? requiresAdvancePayment,
    bool? supportsRefunds,
    Uint8List? selectedLogoBytes,
    String? selectedLogoName,
    double? selectedLatitude,
    double? selectedLongitude,
    Set<String>? selectedAmenities,
    Set<String>? selectedFacilities,
    String? selectedPackageId,
    bool clearSelectedLogo = false,
    bool clearSelectedLocation = false,
    bool clearSelectedPackage = false,
  }) {
    return CreateFootsallCourtsState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      isSlugAuto: isSlugAuto ?? this.isSlugAuto,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      status: status ?? this.status,
      allowCancellation: allowCancellation ?? this.allowCancellation,
      requiresAdvancePayment:
          requiresAdvancePayment ?? this.requiresAdvancePayment,
      supportsRefunds: supportsRefunds ?? this.supportsRefunds,
      selectedLogoBytes: clearSelectedLogo
          ? null
          : selectedLogoBytes ?? this.selectedLogoBytes,
      selectedLogoName: clearSelectedLogo
          ? null
          : selectedLogoName ?? this.selectedLogoName,
      selectedLatitude: clearSelectedLocation
          ? null
          : selectedLatitude ?? this.selectedLatitude,
      selectedLongitude: clearSelectedLocation
          ? null
          : selectedLongitude ?? this.selectedLongitude,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      selectedFacilities: selectedFacilities ?? this.selectedFacilities,
      selectedPackageId: clearSelectedPackage
          ? null
          : selectedPackageId ?? this.selectedPackageId,
    );
  }
}
