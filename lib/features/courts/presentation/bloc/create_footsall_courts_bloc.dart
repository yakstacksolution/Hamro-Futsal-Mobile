import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hamro_footsall/features/courts/presentation/bloc/create_footsall_courts_state.dart';
import 'package:hamro_footsall/features/courts/presentation/models/create_courts_action_result.dart';
import 'package:hamro_footsall/features/courts/presentation/models/create_courts_package_option.dart';
import 'package:hamro_footsall/features/courts/presentation/models/create_courts_step_definition.dart';
import 'package:hamro_footsall/features/courts/presentation/models/create_footsall_court_payload.dart';
import 'package:hamro_footsall/features/courts/presentation/models/picked_location.dart';

class CreateFootsallCourtsBloc extends ChangeNotifier {
  CreateFootsallCourtsBloc()
    : _state = CreateFootsallCourtsState.initial(
        status: statuses.first,
        totalSteps: totalSteps,
      ) {
    shopNameController.addListener(_syncSlugWithShopName);
  }

  static const List<String> statuses = <String>['active', 'inactive'];
  static const List<CreateCourtsStepDefinition>
  steps = <CreateCourtsStepDefinition>[
    CreateCourtsStepDefinition(
      label: 'Basic',
      title: 'Basic Information',
      subtitle: 'Public identity and contact details of your futsal.',
      icon: Icons.store_rounded,
    ),
    CreateCourtsStepDefinition(
      label: 'Business',
      title: 'Business & Registration',
      subtitle: 'Pricing, operational details, and registration information.',
      icon: Icons.apartment_rounded,
    ),
    CreateCourtsStepDefinition(
      label: 'Amenities',
      title: 'Amenities & Facilities',
      subtitle:
          'Highlight the services and on-site facilities your venue offers.',
      icon: Icons.weekend_rounded,
    ),
    CreateCourtsStepDefinition(
      label: 'Policies',
      title: 'Policies',
      subtitle: 'Define booking rules, payments, and venue house policies.',
      icon: Icons.rule_folder_rounded,
    ),
    CreateCourtsStepDefinition(
      label: 'Package',
      title: 'Choose Package',
      subtitle: 'Pick the operational package that fits your business.',
      icon: Icons.workspace_premium_rounded,
    ),
    CreateCourtsStepDefinition(
      label: 'Branding',
      title: 'Branding & Review',
      subtitle: 'Optional visual identity and final confirmation.',
      icon: Icons.image_rounded,
    ),
  ];
  static int get totalSteps => steps.length;
  static const List<String> amenityOptions = <String>[
    'Floodlights',
    'Drinking Water',
    'Live Scoreboard',
    'Warm-Up Zone',
    'Wi-Fi',
    'Equipment Rental',
  ];
  static const List<String> facilityOptions = <String>[
    'Changing Room',
    'Shower Area',
    'Locker Storage',
    'Parking',
    'Spectator Seating',
    'First Aid Desk',
  ];
  static const List<CreateCourtsPackageOption> packageOptions =
      <CreateCourtsPackageOption>[
        CreateCourtsPackageOption(
          id: 'starter',
          title: 'Starter',
          subtitle: 'Best for a single venue getting online.',
          priceLabel: 'NPR 2,500 / month',
          features: <String>[
            '1 venue profile',
            'Basic listing visibility',
            'Manual booking confirmation',
          ],
        ),
        CreateCourtsPackageOption(
          id: 'growth',
          title: 'Growth',
          subtitle: 'Balanced package for active futsal operations.',
          priceLabel: 'NPR 5,500 / month',
          features: <String>[
            'Priority listing placement',
            'Booking workflow support',
            'Basic reporting access',
          ],
          isRecommended: true,
        ),
        CreateCourtsPackageOption(
          id: 'elite',
          title: 'Elite',
          subtitle: 'For premium venues and multi-court operators.',
          priceLabel: 'NPR 9,500 / month',
          features: <String>[
            'Multi-court management',
            'Premium branding placement',
            'Priority support routing',
          ],
        ),
      ];

  final PageController pageController = PageController();
  final List<GlobalKey<FormState>> formKeys =
      List<GlobalKey<FormState>>.generate(
        totalSteps,
        (_) => GlobalKey<FormState>(),
      );

  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController slugController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController establishedYearController =
      TextEditingController();
  final TextEditingController basicPriceController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController exactLocationController = TextEditingController();
  final TextEditingController registrationController = TextEditingController();
  final TextEditingController amenitiesNotesController =
      TextEditingController();
  final TextEditingController bookingAdvanceDaysController =
      TextEditingController();
  final TextEditingController cancellationWindowController =
      TextEditingController();
  final TextEditingController houseRulesController = TextEditingController();
  final TextEditingController shopLogoController = TextEditingController();

  CreateFootsallCourtsState _state;

  CreateFootsallCourtsState get state => _state;

  GlobalKey<FormState> get currentFormKey => formKeys[_state.currentStep];

  CreateCourtsPackageOption? get selectedPackageOption {
    final String? selectedId = _state.selectedPackageId;
    if (selectedId == null) return null;

    for (final CreateCourtsPackageOption option in packageOptions) {
      if (option.id == selectedId) return option;
    }
    return null;
  }

  String get amenitiesSummary => _joinOptions(_state.selectedAmenities);

  String get facilitiesSummary => _joinOptions(_state.selectedFacilities);

  String get policiesSummary {
    final List<String> rules = <String>[
      _state.requiresAdvancePayment
          ? 'Advance payment required'
          : 'Advance payment optional',
      _state.allowCancellation
          ? 'Cancellation allowed'
          : 'Cancellation not allowed',
      _state.allowCancellation && _state.supportsRefunds
          ? 'Refunds supported'
          : 'Refunds not supported',
    ];
    return rules.join(' • ');
  }

  @override
  void dispose() {
    pageController.dispose();
    shopNameController.removeListener(_syncSlugWithShopName);
    shopNameController.dispose();
    slugController.dispose();
    descriptionController.dispose();
    establishedYearController.dispose();
    basicPriceController.dispose();
    phoneController.dispose();
    emailController.dispose();
    websiteController.dispose();
    cityController.dispose();
    countryController.dispose();
    exactLocationController.dispose();
    registrationController.dispose();
    amenitiesNotesController.dispose();
    bookingAdvanceDaysController.dispose();
    cancellationWindowController.dispose();
    houseRulesController.dispose();
    shopLogoController.dispose();
    super.dispose();
  }

  String slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  String? requiredValidator(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  String? slugValidator(String? value) {
    final String? baseError = requiredValidator(value, fieldName: 'Slug');
    if (baseError != null) return baseError;

    final String slug = value!.trim();
    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(slug)) {
      return 'Use lowercase letters, numbers, and hyphens only';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    ).hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[0-9+()\-\s]{7,20}$').hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? establishedYearValidator(String? value) {
    final String? baseError = requiredValidator(
      value,
      fieldName: 'Established year',
    );
    if (baseError != null) return baseError;

    final String yearText = value!.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(yearText)) {
      return 'Enter a valid 4-digit year';
    }

    final int year = int.parse(yearText);
    final int currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear) {
      return 'Year must be between 1900 and $currentYear';
    }
    return null;
  }

  String? websiteValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final Uri? uri = Uri.tryParse(value.trim());
    if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
      return 'Enter a valid website URL';
    }
    return null;
  }

  String? basicPriceValidator(String? value) {
    final String? baseError = requiredValidator(
      value,
      fieldName: 'Basic price',
    );
    if (baseError != null) return baseError;

    final String normalized = value!.trim().replaceAll(',', '');
    final double? parsed = double.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid price amount';
    }
    return null;
  }

  String? bookingAdvanceDaysValidator(String? value) {
    final String? baseError = requiredValidator(
      value,
      fieldName: 'Booking advance days',
    );
    if (baseError != null) return baseError;
    return _positiveIntegerValidator(value, fieldName: 'Booking advance days');
  }

  String? cancellationWindowValidator(String? value) {
    if (!_state.allowCancellation) return null;

    final String? baseError = requiredValidator(
      value,
      fieldName: 'Cancellation window',
    );
    if (baseError != null) return baseError;
    return _positiveIntegerValidator(value, fieldName: 'Cancellation window');
  }

  String? exactLocationValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Exact location is required';
    }
    if (_state.selectedLatitude == null || _state.selectedLongitude == null) {
      return 'Select the exact location from the map';
    }
    return null;
  }

  String? logoUrlValidator(String? value) {
    if (_state.selectedLogoBytes != null) return null;
    if (value == null || value.trim().isEmpty) return null;
    final Uri? uri = Uri.tryParse(value.trim());
    if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
      return 'Enter a valid URL (https://...)';
    }
    return null;
  }

  String? houseRulesValidator(String? value) {
    return requiredValidator(value, fieldName: 'House rules');
  }

  String? amenitiesSelectionError() {
    if (_state.selectedAmenities.isNotEmpty ||
        _state.selectedFacilities.isNotEmpty) {
      return null;
    }
    return 'Select at least one amenity or facility.';
  }

  String? packageSelectionError() {
    if (_state.selectedPackageId != null) return null;
    return 'Choose a package to continue.';
  }

  void toggleSlugAutomation() {
    final bool shouldAutoGenerate = !_state.isSlugAuto;
    _emit(_state.copyWith(isSlugAuto: shouldAutoGenerate));
    if (shouldAutoGenerate) _syncSlugWithShopName();
  }

  void handleSlugChanged(String _) {
    if (!_state.isSlugAuto) return;
    _emit(_state.copyWith(isSlugAuto: false));
  }

  void updateStatus(String value) {
    if (value == _state.status) return;
    _emit(_state.copyWith(status: value));
  }

  void toggleAmenity(String value) {
    final Set<String> next = Set<String>.from(_state.selectedAmenities);
    if (!next.add(value)) {
      next.remove(value);
    }
    _emit(_state.copyWith(selectedAmenities: next));
  }

  void toggleFacility(String value) {
    final Set<String> next = Set<String>.from(_state.selectedFacilities);
    if (!next.add(value)) {
      next.remove(value);
    }
    _emit(_state.copyWith(selectedFacilities: next));
  }

  void toggleAllowCancellation(bool value) {
    _emit(
      _state.copyWith(
        allowCancellation: value,
        supportsRefunds: value ? _state.supportsRefunds : false,
      ),
    );
    if (!value) {
      cancellationWindowController.clear();
    }
  }

  void toggleRequiresAdvancePayment(bool value) {
    _emit(_state.copyWith(requiresAdvancePayment: value));
  }

  void toggleSupportsRefunds(bool value) {
    _emit(_state.copyWith(supportsRefunds: value));
  }

  void selectPackage(String packageId) {
    _emit(_state.copyWith(selectedPackageId: packageId));
  }

  Future<String?> pickLogoFromDevice() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['png', 'jpg', 'jpeg', 'webp'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final PlatformFile file = result.files.first;
    if (file.bytes == null) {
      return 'Could not read the selected file.';
    }

    if (shopLogoController.text.trim().isEmpty) {
      shopLogoController.text = file.name;
    }

    _emit(
      _state.copyWith(
        selectedLogoBytes: file.bytes,
        selectedLogoName: file.name,
      ),
    );
    return null;
  }

  void removeSelectedLogo() {
    _emit(_state.copyWith(clearSelectedLogo: true));
  }

  void applyPickedLocation(PickedLocation location) {
    exactLocationController.text = location.label;
    _emit(
      _state.copyWith(
        selectedLatitude: location.latitude,
        selectedLongitude: location.longitude,
      ),
    );
  }

  Future<bool> goToPreviousStep() async {
    if (_state.currentStep <= 0) return true;
    await _goToStep(_state.currentStep - 1);
    return false;
  }

  Future<void> resetForm() async {
    for (final GlobalKey<FormState> formKey in formKeys) {
      formKey.currentState?.reset();
    }

    shopNameController.clear();
    slugController.clear();
    descriptionController.clear();
    establishedYearController.clear();
    basicPriceController.clear();
    phoneController.clear();
    emailController.clear();
    websiteController.clear();
    cityController.clear();
    countryController.clear();
    exactLocationController.clear();
    registrationController.clear();
    amenitiesNotesController.clear();
    bookingAdvanceDaysController.clear();
    cancellationWindowController.clear();
    houseRulesController.clear();
    shopLogoController.clear();

    _emit(
      CreateFootsallCourtsState.initial(
        status: statuses.first,
        totalSteps: totalSteps,
      ),
    );
    await _animateToPage(0);
  }

  Future<CreateCourtsActionResult> handlePrimaryAction() async {
    if (!(currentFormKey.currentState?.validate() ?? false)) {
      return const CreateCourtsActionResult();
    }

    final String? currentStepError = _customStepError(_state.currentStep);
    if (currentStepError != null) {
      return CreateCourtsActionResult(errorMessage: currentStepError);
    }

    if (!_state.isLastStep) {
      await _goToStep(_state.currentStep + 1);
      return const CreateCourtsActionResult();
    }

    return submit();
  }

  Future<CreateCourtsActionResult> submit() async {
    for (int index = 0; index < formKeys.length; index++) {
      final bool isValid = formKeys[index].currentState?.validate() ?? false;
      final String? stepError = _customStepError(index);
      if (!isValid || stepError != null) {
        if (_state.currentStep != index) {
          await _goToStep(index);
        }
        return CreateCourtsActionResult(errorMessage: stepError);
      }
    }

    _emit(_state.copyWith(isSubmitting: true));
    final CreateFootsallCourtPayload payload = buildPayload();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _emit(_state.copyWith(isSubmitting: false));
    return CreateCourtsActionResult(payload: payload);
  }

  CreateFootsallCourtPayload buildPayload() {
    final CreateCourtsPackageOption package = selectedPackageOption!;
    return CreateFootsallCourtPayload(
      owner: 'AUTO_FROM_AUTH',
      shopName: shopNameController.text.trim(),
      slug: slugController.text.trim().toLowerCase(),
      description: descriptionController.text.trim(),
      establishedYear: establishedYearController.text.trim(),
      basicPrice: basicPriceController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      emailAddress: emailController.text.trim().toLowerCase(),
      website: websiteController.text.trim(),
      city: cityController.text.trim(),
      country: countryController.text.trim(),
      exactLocation: exactLocationController.text.trim(),
      latitude: _state.selectedLatitude!,
      longitude: _state.selectedLongitude!,
      registrationNumber: registrationController.text.trim(),
      status: _state.status,
      amenities: _state.selectedAmenities.toList()..sort(),
      facilities: _state.selectedFacilities.toList()..sort(),
      amenitiesNotes: amenitiesNotesController.text.trim(),
      bookingAdvanceDays: bookingAdvanceDaysController.text.trim(),
      cancellationWindowHours: _state.allowCancellation
          ? cancellationWindowController.text.trim()
          : '',
      houseRules: houseRulesController.text.trim(),
      allowCancellation: _state.allowCancellation,
      requiresAdvancePayment: _state.requiresAdvancePayment,
      supportsRefunds: _state.allowCancellation && _state.supportsRefunds,
      selectedPackageId: package.id,
      selectedPackageTitle: package.title,
      shopLogo: shopLogoController.text.trim().isNotEmpty
          ? shopLogoController.text.trim()
          : (_state.selectedLogoName ?? ''),
    );
  }

  Future<void> _goToStep(int step) async {
    _emit(_state.copyWith(currentStep: step));
    await _animateToPage(step);
  }

  Future<void> _animateToPage(int step) async {
    if (!pageController.hasClients) return;
    await pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _syncSlugWithShopName() {
    if (!_state.isSlugAuto) return;

    final String generated = slugify(shopNameController.text);
    if (slugController.text == generated) return;

    slugController.value = TextEditingValue(
      text: generated,
      selection: TextSelection.collapsed(offset: generated.length),
    );
  }

  void _emit(CreateFootsallCourtsState newState) {
    _state = newState;
    notifyListeners();
  }

  String? _positiveIntegerValidator(
    String? value, {
    required String fieldName,
  }) {
    final int? parsed = int.tryParse(value!.trim());
    if (parsed == null || parsed <= 0) {
      return '$fieldName must be a positive number';
    }
    return null;
  }

  String? _customStepError(int stepIndex) {
    switch (stepIndex) {
      case 2:
        return amenitiesSelectionError();
      case 4:
        return packageSelectionError();
      default:
        return null;
    }
  }

  String _joinOptions(Set<String> values) {
    if (values.isEmpty) return '';
    final List<String> items = values.toList()..sort();
    return items.join(', ');
  }
}
