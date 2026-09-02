import 'dart:async';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/courts/data/repositories/venue_court_repository_impl.dart';
import 'package:hamro_futsal/features/courts/domain/usecase/get_venue_court_use_case.dart';
import 'package:hamro_futsal/features/media/utils/stable_media_file.dart';
import 'package:hamro_futsal/features/vendor/data/model/court_onboarding_response_model.dart';
import 'package:hamro_futsal/features/vendor/data/model/vendor_onboarding_response_model.dart';
import 'package:hamro_futsal/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_futsal/features/vendor/data/repositories/vendor_onboarding_repository_impl.dart';
import 'package:hamro_futsal/features/vendor/domain/usecase/vendor_onboarding_usecase.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_api_payload.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_futsal/features/vendor/presentation/validation/vendor_onboarding_validator.dart';
import 'package:image_picker/image_picker.dart';

class VendorOnboardingCubit extends Cubit<VendorOnboardingState> {
  VendorOnboardingCubit(
    this._draftRepository, {
    VendorOnboardingUseCase? onboardingUseCase,
  }) : super(
         VendorOnboardingState.initial().copyWith(
           isRestoringDraft: false,
           saveStatus: DraftSaveStatus.unsaved,
         ),
       ) {
    _onboardingUseCase =
        onboardingUseCase ??
        VendorOnboardingUseCase(VendorOnboardingRepositoryImpl());
  }

  final VendorDraftRepository _draftRepository;
  late final VendorOnboardingUseCase _onboardingUseCase;
  Timer? _saveDebounce;
  int? _courtsFetchedForVenueId;
  final Set<int> _courtDetailsFetched = <int>{};
  final Set<int> _courtDetailsFetching = <int>{};
  Object? _editorFlushOwner;
  void Function()? _editorFlushCallback;
  String _defaultCourtDescription = '';

  final ValueNotifier<String?> focusInvalidFieldRequest =
      ValueNotifier<String?>(null);
  int _focusRequestToken = 0;

  void registerActiveEditorFlush(Object owner, void Function() callback) {
    _editorFlushOwner = owner;
    _editorFlushCallback = callback;
  }

  void unregisterActiveEditorFlush(Object owner) {
    if (!identical(_editorFlushOwner, owner)) return;
    _editorFlushOwner = null;
    _editorFlushCallback = null;
  }

  List<VendorSectionDefinition> get activeSections =>
      sectionsForCategory(state.cursor.category);

  VendorSectionDefinition get activeSectionDefinition =>
      activeSections[state.cursor.sectionIndex];

  List<VendorSubstepDefinition> get activeSubsteps =>
      activeSectionDefinition.substeps;

  int get currentSectionIndex => state.cursor.sectionIndex;

  int get currentSubstepIndex => state.cursor.subsectionIndex;

  bool get canAccessCourtCategory =>
      VendorOnboardingValidator.canUnlockCourts(state.futsal);

  bool get isCourtEditorVisible =>
      !state.isInCourtCategory || state.activeCourt != null;

  bool get canGoPrevious {
    if (!state.isInCourtCategory) {
      return currentSectionIndex > 0 || currentSubstepIndex > 0;
    }
    return true;
  }

  bool get isFinalStep {
    if (!state.isInCourtCategory || state.activeCourt == null) {
      return false;
    }

    final bool isLastSection =
        currentSectionIndex == courtSectionDefinitions.length - 1;
    final bool isLastSubstep = currentSubstepIndex == activeSubsteps.length - 1;
    final bool isLastCourt = _activeCourtIndex == state.courts.length - 1;
    return isLastSection && isLastSubstep && isLastCourt;
  }

  String get nextButtonLabel {
    if (!state.isInCourtCategory) {
      final bool isLastFutsalSection =
          currentSectionIndex == futsalSectionDefinitions.length - 1;
      final bool isLastFutsalSubstep =
          currentSubstepIndex == activeSubsteps.length - 1;
      if (state.remoteFutsalId != null &&
          currentSectionIndex == 0 &&
          currentSubstepIndex == 0) {
        return 'Next';
      }
      return isLastFutsalSection && isLastFutsalSubstep
          ? 'Continue to Courts'
          : 'Next';
    }

    if (state.activeCourt == null) {
      return 'Add First Court';
    }

    return isFinalStep ? 'Review & Publish' : 'Next';
  }

  int get completedSubstepCount {
    int total = 0;
    for (
      int sectionIndex = 0;
      sectionIndex < futsalSectionDefinitions.length;
      sectionIndex++
    ) {
      final int substepCount =
          futsalSectionDefinitions[sectionIndex].substeps.length;
      for (
        int subsectionIndex = 0;
        subsectionIndex < substepCount;
        subsectionIndex++
      ) {
        if (futsalSubstepStatus(sectionIndex, subsectionIndex) ==
            StepStatus.complete) {
          total++;
        }
      }
    }

    for (final CourtDraft court in state.courts) {
      for (
        int sectionIndex = 0;
        sectionIndex < courtSectionDefinitions.length;
        sectionIndex++
      ) {
        final int substepCount =
            courtSectionDefinitions[sectionIndex].substeps.length;
        for (
          int subsectionIndex = 0;
          subsectionIndex < substepCount;
          subsectionIndex++
        ) {
          if (courtSubstepStatus(court.id, sectionIndex, subsectionIndex) ==
              StepStatus.complete) {
            total++;
          }
        }
      }
    }
    return total;
  }

  int get totalSubstepCount {
    int total = 0;
    for (final VendorSectionDefinition section in futsalSectionDefinitions) {
      total += section.substeps.length;
    }
    for (final CourtDraft _ in state.courts) {
      for (final VendorSectionDefinition section in courtSectionDefinitions) {
        total += section.substeps.length;
      }
    }
    return total == 0 ? futsalSectionDefinitions.length : total;
  }

  double get overallCompletion {
    if (totalSubstepCount == 0) return 0;
    return completedSubstepCount / totalSubstepCount;
  }

  Map<String, dynamic> buildCreateFutsalBody({int? mainStep, int? subStep}) {
    return state.toCreateFutsalBody(mainStep: mainStep, subStep: subStep);
  }

  StepStatus futsalSectionStatus(int sectionIndex) {
    final List<StepStatus> substeps = List<StepStatus>.generate(
      futsalSectionDefinitions[sectionIndex].substeps.length,
      (int subsectionIndex) =>
          futsalSubstepStatus(sectionIndex, subsectionIndex),
    );
    return _aggregateStatuses(substeps);
  }

  StepStatus futsalSubstepStatus(int sectionIndex, int subsectionIndex) {
    final String key = VendorOnboardingValidator.futsalSubstepKey(
      sectionIndex,
      subsectionIndex,
    );
    if (state.errorKeys.contains(key)) return StepStatus.error;

    final VendorValidationResult result =
        VendorOnboardingValidator.validateFutsalSubstep(
          state.futsal,
          sectionIndex,
          subsectionIndex,
        );
    if (result.isValid) return StepStatus.complete;
    if (VendorOnboardingValidator.hasFutsalSubstepData(
      state.futsal,
      sectionIndex,
      subsectionIndex,
    )) {
      return StepStatus.inProgress;
    }
    return StepStatus.notStarted;
  }

  StepStatus courtSectionStatus(String courtId, int sectionIndex) {
    final CourtDraft? court = _courtById(courtId);
    if (court == null) return StepStatus.locked;
    final List<StepStatus> substeps = List<StepStatus>.generate(
      courtSectionDefinitions[sectionIndex].substeps.length,
      (int subsectionIndex) =>
          courtSubstepStatus(court.id, sectionIndex, subsectionIndex),
    );
    return _aggregateStatuses(substeps);
  }

  StepStatus courtSubstepStatus(
    String courtId,
    int sectionIndex,
    int subsectionIndex,
  ) {
    final CourtDraft? court = _courtById(courtId);
    if (court == null) return StepStatus.locked;
    final String key = VendorOnboardingValidator.courtSubstepKey(
      courtId,
      sectionIndex,
      subsectionIndex,
    );
    if (state.errorKeys.contains(key)) return StepStatus.error;

    final VendorValidationResult result =
        VendorOnboardingValidator.validateCourtSubstep(
          court,
          sectionIndex,
          subsectionIndex,
        );
    if (result.isValid) return StepStatus.complete;
    if (VendorOnboardingValidator.hasCourtSubstepData(
      court,
      sectionIndex,
      subsectionIndex,
    )) {
      return StepStatus.inProgress;
    }
    return StepStatus.notStarted;
  }

  Future<void> restoreDraft() async {
    emit(state.copyWith(isRestoringDraft: false));
  }

  Future<void> fetchVendorOnboarding(int futsalId) async {
    emit(
      state.copyWith(
        isRestoringDraft: true,
        clearErrorMessage: true,
        errorKeys: const <String>{},
      ),
    );

    final Either<AppException, VendorOnboardingResponseModel> response =
        await _onboardingUseCase.fetchVendorOnboardingFutsal(futsalId);

    response.fold(
      (AppException failure) {
        emit(
          _clearedState().copyWith(
            errorMessage: failure.errorMessage,
            errorOrigin: VendorErrorOrigin.api,
          ),
        );
      },
      (VendorOnboardingResponseModel data) {
        final int sectionIndex = _clamp(
          data.mainStep,
          0,
          futsalSectionDefinitions.length - 1,
        );
        final int subsectionIndex = _clamp(
          data.subStep,
          0,
          futsalSectionDefinitions[sectionIndex].substeps.length - 1,
        );

        emit(
          _normalizeState(
            _clearedState().copyWith(
              futsal: data.toDraft(),
              remoteFutsalId: data.id ?? futsalId,
              futsalPointer: SectionPointer(
                sectionIndex: sectionIndex,
                subsectionIndex: subsectionIndex,
              ),
              cursor: StepCursor(
                category: VendorCategory.futsal,
                sectionIndex: sectionIndex,
                subsectionIndex: subsectionIndex,
              ),
            ),
          ),
        );
      },
    );
  }

  void selectCategory(VendorCategory category) {
    if (category == VendorCategory.futsal) {
      final SectionPointer pointer = state.futsalPointer;
      emit(
        state.copyWith(
          cursor: StepCursor(
            category: VendorCategory.futsal,
            sectionIndex: pointer.sectionIndex,
            subsectionIndex: pointer.subsectionIndex,
          ),
          clearErrorMessage: true,
        ),
      );
      return;
    }

    final bool shouldFetch = _shouldFetchRemoteCourts();

    if (state.courts.isEmpty) {
      emit(
        state.copyWith(
          cursor: const StepCursor(
            category: VendorCategory.court,
            sectionIndex: 0,
            subsectionIndex: 0,
          ),
          clearActiveCourtId: true,
          clearErrorMessage: true,
          isLoadingCourts: shouldFetch,
        ),
      );
    } else {
      final String activeCourtId = state.activeCourtId ?? state.courts.first.id;
      final SectionPointer pointer =
          state.courtPointersById[activeCourtId] ??
          const SectionPointer(sectionIndex: 0, subsectionIndex: 0);
      emit(
        state.copyWith(
          activeCourtId: activeCourtId,
          cursor: StepCursor(
            category: VendorCategory.court,
            sectionIndex: pointer.sectionIndex,
            subsectionIndex: pointer.subsectionIndex,
            courtId: activeCourtId,
          ),
          clearErrorMessage: true,
          isLoadingCourts: shouldFetch,
        ),
      );
    }

    if (shouldFetch) {
      unawaited(_fetchRemoteCourts());
    }
  }

  Future<void> refreshRemoteCourts() async {
    final int? futsalId = state.remoteFutsalId;
    if (futsalId == null || state.isLoadingCourts) return;

    _courtsFetchedForVenueId = null;
    emit(state.copyWith(isLoadingCourts: true, clearErrorMessage: true));
    await _fetchRemoteCourts();
  }

  void selectSection(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= activeSections.length) return;

    if (!state.isInCourtCategory) {
      _moveToFutsal(sectionIndex, 0);
      return;
    }

    if (state.activeCourtId == null) {
      _emitError('Add a court before opening court steps.');
      return;
    }

    _moveToCourt(state.activeCourtId!, sectionIndex, 0);
  }

  void selectSubstep(int subsectionIndex) {
    if (subsectionIndex < 0 || subsectionIndex >= activeSubsteps.length) return;

    if (!state.isInCourtCategory) {
      _moveToFutsal(currentSectionIndex, subsectionIndex);
      return;
    }

    if (state.activeCourtId == null) {
      _emitError('Add a court before opening court substeps.');
      return;
    }

    _moveToCourt(state.activeCourtId!, currentSectionIndex, subsectionIndex);
  }

  Future<String?> next() async {
    if (state.isSubmitting) return null;
    _flushActiveEditors();

    if (state.isInCourtCategory && state.activeCourt == null) {
      addCourt();
      await _saveDraft(showSavingState: false);
      return null;
    }

    final VendorValidationResult validation = validateCurrentSubstep();
    if (!validation.isValid) {
      _registerValidationFailure(validation);
      return validation.message;
    }

    final String? registrationFailure = await _submitProgressIfNeeded();
    if (registrationFailure != null) {
      return registrationFailure;
    }

    await _saveDraft(showSavingState: false);

    final bool isLastSubstep = currentSubstepIndex == activeSubsteps.length - 1;
    final bool isLastSection = currentSectionIndex == activeSections.length - 1;

    if (!isLastSubstep) {
      selectSubstep(currentSubstepIndex + 1);
      await _saveDraft(showSavingState: false);
      return null;
    }

    if (!isLastSection) {
      selectSection(currentSectionIndex + 1);
      await _saveDraft(showSavingState: false);
      return null;
    }

    if (!state.isInCourtCategory) {
      selectCategory(VendorCategory.court);
      await _saveDraft(showSavingState: false);
      return null;
    }

    final String? activeCourtId = state.activeCourtId;
    if (activeCourtId == null) {
      addCourt();
      return null;
    }

    final String? nextCourtId = _nextCourtId(activeCourtId);
    if (nextCourtId != null) {
      selectCourt(nextCourtId);
      _moveToCourt(nextCourtId, 0, 0);
      await _saveDraft(showSavingState: false);
      return null;
    }

    return submit();
  }

  void previous() {
    if (!state.isInCourtCategory) {
      if (currentSubstepIndex > 0) {
        _moveToFutsal(currentSectionIndex, currentSubstepIndex - 1);
        return;
      }
      if (currentSectionIndex > 0) {
        final int previousSectionIndex = currentSectionIndex - 1;
        final int lastSubstep =
            futsalSectionDefinitions[previousSectionIndex].substeps.length - 1;
        _moveToFutsal(previousSectionIndex, lastSubstep);
      }
      return;
    }

    if (state.activeCourt == null) {
      selectCategory(VendorCategory.futsal);
      return;
    }

    if (currentSubstepIndex > 0) {
      _moveToCourt(
        state.activeCourtId!,
        currentSectionIndex,
        currentSubstepIndex - 1,
      );
      return;
    }

    if (currentSectionIndex > 0) {
      final int previousSectionIndex = currentSectionIndex - 1;
      final int lastSubstep =
          courtSectionDefinitions[previousSectionIndex].substeps.length - 1;
      _moveToCourt(state.activeCourtId!, previousSectionIndex, lastSubstep);
      return;
    }

    final String? previousCourtId = _previousCourtId(state.activeCourtId!);
    if (previousCourtId != null) {
      final int lastCourtSection = courtSectionDefinitions.length - 1;
      final int lastCourtSubstep =
          courtSectionDefinitions[lastCourtSection].substeps.length - 1;
      _moveToCourt(previousCourtId, lastCourtSection, lastCourtSubstep);
      return;
    }

    final int lastFutsalSection = futsalSectionDefinitions.length - 1;
    final int lastFutsalSubstep =
        futsalSectionDefinitions[lastFutsalSection].substeps.length - 1;
    _moveToFutsal(lastFutsalSection, lastFutsalSubstep);
  }

  VendorValidationResult validateCurrentSubstep() {
    if (!state.isInCourtCategory) {
      return VendorOnboardingValidator.validateFutsalSubstep(
        state.futsal,
        currentSectionIndex,
        currentSubstepIndex,
      );
    }

    final CourtDraft? court = state.activeCourt;
    if (court == null) {
      return const VendorValidationResult.invalid(
        'court_missing',
        'Add at least one court before continuing.',
      );
    }

    return VendorOnboardingValidator.validateCourtSubstep(
      court,
      currentSectionIndex,
      currentSubstepIndex,
    );
  }

  void updateFutsal(FutsalDraft nextDraft) {
    _emitUpdated(state.copyWith(futsal: nextDraft));
  }

  void addFilesToMediaLibrary(List<UploadRef> files) {
    if (files.isEmpty) return;
    _emitUpdated(
      state.copyWith(
        mediaLibrary: _mergeUniqueUploads(state.mediaLibrary, files),
      ),
    );
  }

  void syncMediaLibrary(List<UploadRef> files) {
    if (files.isEmpty) return;

    final List<UploadRef> merged = _mergeUniqueUploads(
      state.mediaLibrary,
      files,
    );
    if (_haveSameUploadPaths(state.mediaLibrary, merged)) return;

    emit(_normalizeState(state.copyWith(mediaLibrary: merged)));
  }

  void removeMediaLibraryItem(UploadRef file) {
    final UploadRef? stored = state.mediaLibrary
        .where((UploadRef item) => item.storageKey == file.storageKey)
        .firstOrNull;
    if (stored?.verificationStatus.isLocked ??
        file.verificationStatus.isLocked) {
      return;
    }
    _emitUpdated(
      state.copyWith(
        mediaLibrary: state.mediaLibrary
            .where((UploadRef item) => item.storageKey != file.storageKey)
            .toList(),
      ),
    );
  }

  Future<List<UploadRef>> pickFilesForMediaLibrary({
    required List<String> allowedExtensions,
    required bool allowMultiple,
  }) async {
    final List<UploadRef> files = allowMultiple
        ? await _pickMultipleFiles(allowedExtensions: allowedExtensions)
        : <UploadRef>[
            if (await _pickSingleFile(allowedExtensions: allowedExtensions)
                case final UploadRef file)
              file,
          ];
    return files.isEmpty ? const <UploadRef>[] : files;
  }

  Future<UploadRef?> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? captured = await picker.pickImage(source: ImageSource.camera);
    if (captured == null) return null;
    final XFile? photo = await stabilizePickedMedia(captured);
    if (photo == null) return null;
    final UploadRef ref = UploadRef(name: photo.name, remoteUrl: photo.path);
    _emitUpdated(
      state.copyWith(mediaLibrary: <UploadRef>[...state.mediaLibrary, ref]),
    );
    return ref;
  }

  void updateFutsalBasicIdentity(String title) {
    final String nextSlug = _buildFutsalSlug(
      title: title,
      currentSlug: state.futsal.slug,
    );
    updateFutsal(state.futsal.copyWith(title: title, slug: nextSlug));
  }

  void updateFutsalWebsiteOrSocialLink(String value) {
    updateFutsal(state.futsal.copyWith(websiteOrSocialLink: value.trim()));
  }

  void updateActiveCourt(CourtDraft nextDraft) {
    final String? activeCourtId = state.activeCourtId;
    if (activeCourtId == null) return;
    final List<CourtDraft> updated = state.courts
        .map(
          (CourtDraft court) => court.id == activeCourtId ? nextDraft : court,
        )
        .toList();
    _emitUpdated(state.copyWith(courts: updated));
  }

  void replaceCourts(List<CourtDraft> courts) {
    _emitUpdated(state.copyWith(courts: courts));
  }

  void upsertCourt(CourtDraft court) {
    final List<CourtDraft> courts = List<CourtDraft>.from(state.courts);
    final int index = courts.indexWhere((CourtDraft item) {
      final bool sameRemote =
          item.remoteId != null &&
          court.remoteId != null &&
          item.remoteId == court.remoteId;
      return sameRemote || item.id == court.id;
    });
    if (index >= 0) {
      courts[index] = court;
    } else {
      courts.add(court);
    }
    _emitUpdated(state.copyWith(courts: courts));
  }

  void toggleFutsalAmenity(String value) {
    updateFutsal(
      state.futsal.copyWith(
        amenities: _toggleSetValue(state.futsal.amenities, value),
      ),
    );
  }

  void toggleFutsalFeature(String value) {
    updateFutsal(
      state.futsal.copyWith(
        features: _toggleSetValue(state.futsal.features, value),
      ),
    );
  }

  void toggleAvailabilityDay(String day) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(
        availability: court.availability.copyWith(
          days: _toggleSetValue(court.availability.days, day),
        ),
      ),
    );
  }

  void toggleCourtAmenity(int value) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(amenities: _toggleSetValueT<int>(court.amenities, value)),
    );
  }

  void toggleCourtFacility(int value) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(
        facilities: _toggleSetValueT<int>(court.facilities, value),
      ),
    );
  }

  void toggleCourtOnlineBooking(bool value) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(
        enableOnlineBooking: value,
        advancePaymentRequired: value ? court.advancePaymentRequired : false,
      ),
    );
  }

  void toggleCourtAdvancePayment(bool value) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    final AdvancePaymentType resolvedType =
        court.advancePaymentType ?? AdvancePaymentType.percentage;
    updateActiveCourt(
      court.copyWith(
        advancePaymentRequired: true,
        advancePaymentType: resolvedType,
        advancePrice:
            court.advancePrice ??
            _defaultAdvancePrice(resolvedType, court.basePrice),
      ),
    );
  }

  void setCourtAdvancePaymentType(AdvancePaymentType type) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    if (court.advancePaymentType == type) return;
    final double? defaultPrice = _defaultAdvancePrice(type, court.basePrice);
    updateActiveCourt(
      court.copyWith(
        advancePaymentType: type,
        advancePrice: defaultPrice,
        advancePriceUserEdited: false,
        clearAdvancePrice: defaultPrice == null,
      ),
    );
  }

  void setCourtAdvancePrice(double? price) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(
        advancePrice: price,
        advancePriceUserEdited: true,
        clearAdvancePrice: price == null,
      ),
    );
  }

  void setCourtBasePrice(double? basePrice) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    final bool shouldAutoFillAdvance =
        court.advancePaymentRequired &&
        court.advancePaymentType == AdvancePaymentType.flat &&
        !court.advancePriceUserEdited;
    final double? autoAdvance = shouldAutoFillAdvance
        ? _defaultAdvancePrice(AdvancePaymentType.flat, basePrice)
        : null;
    updateActiveCourt(
      court.copyWith(
        basePrice: basePrice,
        clearBasePrice: basePrice == null,
        advancePrice: shouldAutoFillAdvance ? autoAdvance : null,
        clearAdvancePrice: shouldAutoFillAdvance && autoAdvance == null,
      ),
    );
  }

  /// The advance a court starts with: [kMinimumAdvancePercent]% of the price,
  /// which is also the lowest value the vendor may keep.
  double? _defaultAdvancePrice(AdvancePaymentType type, double? basePrice) {
    switch (type) {
      case AdvancePaymentType.flat:
        if (basePrice == null || basePrice <= 0) return null;
        return basePrice * kMinimumAdvancePercent / 100;
      case AdvancePaymentType.percentage:
        return kMinimumAdvancePercent;
    }
  }

  void setDefaultCourtDescription(String? description) {
    final String normalized = description?.trim() ?? '';
    _defaultCourtDescription = normalized;
    if (normalized.isEmpty || state.courts.isEmpty) return;

    bool hasUpdates = false;
    final List<CourtDraft> updated = state.courts.map((CourtDraft court) {
      if (court.description.trim().isNotEmpty) return court;
      hasUpdates = true;
      return court.copyWith(description: normalized);
    }).toList();

    if (hasUpdates) {
      _emitUpdated(state.copyWith(courts: updated));
    }
  }

  void addCourt({String? name}) {
    final String courtId = _newCourtId();
    final CourtDraft court = CourtDraft(
      id: courtId,
      name: name?.trim().isNotEmpty == true
          ? name!.trim()
          : 'Court ${state.courts.length + 1}',
      description: _defaultCourtDescription,
    );

    final Map<String, SectionPointer> pointers =
        Map<String, SectionPointer>.from(state.courtPointersById)
          ..[courtId] = const SectionPointer(
            sectionIndex: 0,
            subsectionIndex: 0,
          );

    _emitUpdated(
      _normalizeState(
        state.copyWith(
          courts: <CourtDraft>[...state.courts, court],
          activeCourtId: courtId,
          courtPointersById: pointers,
          cursor: StepCursor(
            category: VendorCategory.court,
            sectionIndex: 0,
            subsectionIndex: 0,
            courtId: courtId,
          ),
        ),
      ),
    );
  }

  void selectCourt(String courtId) {
    final CourtDraft? court = _courtById(courtId);
    if (court == null) return;
    final String activeCourtId = court.id;
    final SectionPointer pointer =
        state.courtPointersById[activeCourtId] ??
        const SectionPointer(sectionIndex: 0, subsectionIndex: 0);
    emit(
      state.copyWith(
        activeCourtId: activeCourtId,
        cursor: StepCursor(
          category: VendorCategory.court,
          sectionIndex: pointer.sectionIndex,
          subsectionIndex: pointer.subsectionIndex,
          courtId: activeCourtId,
        ),
        clearErrorMessage: true,
      ),
    );
    unawaited(_fetchCourtDetailsForEditing(court));
    _scheduleDraftSave();
  }

  void openCourtForEditing(String courtId) {
    final CourtDraft? court = _courtById(courtId);
    if (court == null) return;
    final String activeCourtId = court.id;

    final int? remoteId = court.remoteId ?? int.tryParse(court.id);
    if (remoteId != null) {
      _courtDetailsFetched.remove(remoteId);
      _courtSlotsFetched.remove(remoteId);
    }

    final SectionPointer pointer =
        state.courtPointersById[activeCourtId] ??
        const SectionPointer(sectionIndex: 0, subsectionIndex: 0);
    emit(
      state.copyWith(
        activeCourtId: activeCourtId,
        cursor: StepCursor(
          category: VendorCategory.court,
          sectionIndex: pointer.sectionIndex,
          subsectionIndex: pointer.subsectionIndex,
          courtId: activeCourtId,
        ),
        clearErrorMessage: true,
      ),
    );
    unawaited(_fetchCourtDetailsForEditing(court, forceRefresh: true));
    _scheduleDraftSave();
  }

  Future<void> _fetchCourtDetailsForEditing(
    CourtDraft court, {
    bool forceRefresh = false,
  }) async {
    final int? courtId = court.remoteId ?? int.tryParse(court.id);
    if (courtId == null || _courtDetailsFetching.contains(courtId)) {
      return;
    }
    if (!forceRefresh && _courtDetailsFetched.contains(courtId)) {
      return;
    }

    _courtDetailsFetching.add(courtId);
    emit(
      state.copyWith(
        isLoadingCourts: true,
        isLoadingCourtDetails: true,
        clearErrorMessage: true,
      ),
    );

    final Either<AppException, CourtDraft> response =
        await GetVenueCourtUseCase(
          VenueCourtRepositoryImpl(),
        ).getCourtDetails(courtId);

    _courtDetailsFetching.remove(courtId);
    if (isClosed) return;

    response.fold(
      (AppException failure) {
        emit(
          state.copyWith(
            isLoadingCourts: false,
            isLoadingCourtDetails: false,
            errorMessage: failure.errorMessage,
            errorOrigin: VendorErrorOrigin.api,
          ),
        );
      },
      (CourtDraft details) {
        _courtDetailsFetched.add(courtId);
        final List<CourtDraft> courts = state.courts
            .map((CourtDraft item) {
              final bool sameCourt =
                  item.id == court.id ||
                  (item.remoteId != null && item.remoteId == courtId) ||
                  item.id == courtId.toString();
              return sameCourt ? details : item;
            })
            .toList(growable: false);

        final String activeCourtId = details.id;
        final Map<String, SectionPointer> pointers =
            Map<String, SectionPointer>.from(state.courtPointersById)
              ..remove(court.id);

        final int sectionIndex = details.isStepCompleted
            ? 0
            : _clamp(
                details.mainStep ?? 0,
                0,
                courtSectionDefinitions.length - 1,
              );
        final int subsectionIndex = details.isStepCompleted
            ? 0
            : _clamp(
                details.subStep ?? 0,
                0,
                courtSectionDefinitions[sectionIndex].substeps.length - 1,
              );
        final SectionPointer pointer = SectionPointer(
          sectionIndex: sectionIndex,
          subsectionIndex: subsectionIndex,
        );
        pointers[activeCourtId] = pointer;

        emit(
          _normalizeState(
            state.copyWith(
              courts: courts,
              activeCourtId: activeCourtId,
              courtPointersById: pointers,
              cursor: StepCursor(
                category: VendorCategory.court,
                sectionIndex: pointer.sectionIndex,
                subsectionIndex: pointer.subsectionIndex,
                courtId: activeCourtId,
              ),
              isLoadingCourts: false,
              isLoadingCourtDetails: false,
              clearErrorMessage: true,
            ),
          ),
        );
      },
    );
  }

  void removeCourt(String courtId) {
    final List<CourtDraft> remaining = state.courts
        .where((CourtDraft court) => court.id != courtId)
        .toList();
    if (remaining.length == state.courts.length) return;

    final Map<String, SectionPointer> pointers =
        Map<String, SectionPointer>.from(state.courtPointersById)
          ..remove(courtId);

    String? nextActiveCourtId;
    if (remaining.isNotEmpty) {
      final int removedIndex = state.courts.indexWhere(
        (CourtDraft court) => court.id == courtId,
      );
      final int safeIndex = removedIndex.clamp(0, remaining.length - 1);
      nextActiveCourtId = remaining[safeIndex].id;
    }

    final StepCursor nextCursor;
    if (nextActiveCourtId == null) {
      nextCursor = const StepCursor(
        category: VendorCategory.court,
        sectionIndex: 0,
        subsectionIndex: 0,
      );
    } else {
      final SectionPointer pointer =
          pointers[nextActiveCourtId] ??
          const SectionPointer(sectionIndex: 0, subsectionIndex: 0);
      nextCursor = StepCursor(
        category: VendorCategory.court,
        sectionIndex: pointer.sectionIndex,
        subsectionIndex: pointer.subsectionIndex,
        courtId: nextActiveCourtId,
      );
    }

    _emitUpdated(
      _normalizeState(
        state.copyWith(
          courts: remaining,
          courtPointersById: pointers,
          activeCourtId: nextActiveCourtId,
          cursor: nextCursor,
          clearActiveCourtId: nextActiveCourtId == null,
        ),
      ),
    );
  }

  void addSlotToActiveCourt() {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(
        slotConfigs: <SlotPricingDraft>[
          ...court.slotConfigs,
          SlotPricingDraft(
            id: _newSlotId(court.id),
            label: 'Slot ${court.slotConfigs.length + 1}',
          ),
        ],
      ),
    );
  }

  Future<String?> saveCourtSlot(SlotPricingDraft slot) async {
    final CourtDraft? court = state.activeCourt;
    final int? courtId = court == null
        ? null
        : (court.remoteId ?? int.tryParse(court.id));
    if (court == null || courtId == null) {
      const String message = 'Save the court before managing slots.';
      emit(
        state.copyWith(
          errorMessage: message,
          errorOrigin: VendorErrorOrigin.api,
        ),
      );
      return message;
    }

    final String? timingError = VendorOnboardingValidator.validateSlotTiming(
      slot,
      court.slotConfigs,
    );
    if (timingError != null) {
      emit(
        state.copyWith(
          errorMessage: timingError,
          errorOrigin: VendorErrorOrigin.validation,
        ),
      );
      return timingError;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));
    final GetVenueCourtUseCase useCase = GetVenueCourtUseCase(
      VenueCourtRepositoryImpl(),
    );
    final Map<String, dynamic> body = courtSlotBody(slot, courtId: courtId);
    final bool isNew = int.tryParse(slot.id) == null;
    Either<AppException, List<SlotPricingDraft>> response = isNew
        ? await useCase.createCourtSlot(body)
        : await useCase.updateCourtSlot(body);
    if (!isNew && _hasInvalidSlotIdFailure(response)) {
      response =
          await _retrySlotMutationWithFreshId(
            slot,
            courtId,
            isPricing: false,
          ) ??
          response;
    }
    return _applySlotMutation(response, courtId, refresh: isNew);
  }

  Future<String?> saveCourtSlotPricing(SlotPricingDraft slot) async {
    final CourtDraft? court = state.activeCourt;
    final int? courtId = court == null
        ? null
        : (court.remoteId ?? int.tryParse(court.id));
    if (court == null || courtId == null || int.tryParse(slot.id) == null) {
      const String message = 'Save the slot before setting prices.';
      emit(
        state.copyWith(
          errorMessage: message,
          errorOrigin: VendorErrorOrigin.api,
        ),
      );
      return message;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));
    Either<AppException, List<SlotPricingDraft>> response =
        await GetVenueCourtUseCase(
          VenueCourtRepositoryImpl(),
        ).updateCourtSlot(courtSlotPricingBody(slot, courtId: courtId));
    if (_hasInvalidSlotIdFailure(response)) {
      response =
          await _retrySlotMutationWithFreshId(slot, courtId, isPricing: true) ??
          response;
    }
    return _applySlotMutation(response, courtId);
  }

  Future<String?> deleteCourtSlot(SlotPricingDraft slot) async {
    final CourtDraft? court = state.activeCourt;
    final int? courtId = court == null
        ? null
        : (court.remoteId ?? int.tryParse(court.id));
    final int? scheduleId = int.tryParse(slot.id);
    if (court == null || courtId == null || scheduleId == null) {
      removeSlot(slot.id);
      return null;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));
    final Either<AppException, List<SlotPricingDraft>> response =
        await GetVenueCourtUseCase(VenueCourtRepositoryImpl()).deleteCourtSlot(
          <String, dynamic>{
            'court_id': courtId,
            'main_step': 3,
            'sub_step': 1,
            'slot_id': scheduleId,
          },
        );
    return _applySlotMutation(response, courtId, removedSlotId: slot.id);
  }

  Future<String?> _applySlotMutation(
    Either<AppException, List<SlotPricingDraft>> response,
    int courtId, {
    String? removedSlotId,
    bool refresh = false,
  }) async {
    if (isClosed) return null;
    String? errorMessage;
    List<SlotPricingDraft> slots = const <SlotPricingDraft>[];
    response.fold(
      (AppException failure) => errorMessage = failure.errorMessage,
      (List<SlotPricingDraft> value) => slots = value,
    );

    if (errorMessage != null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: errorMessage,
          errorOrigin: VendorErrorOrigin.api,
        ),
      );
      return errorMessage;
    }

    emit(state.copyWith(isSubmitting: false, clearErrorMessage: true));
    final CourtDraft? current = state.activeCourt;
    if (current == null) return null;
    _courtSlotsFetched.add(courtId);

    if (removedSlotId != null) {
      updateActiveCourt(
        current.copyWith(
          slotConfigs: current.slotConfigs
              .where((SlotPricingDraft item) => item.id != removedSlotId)
              .toList(),
        ),
      );
      return null;
    }

    if (!refresh && slots.isNotEmpty) {
      updateActiveCourt(
        current.copyWith(slotConfigs: _upsertSlots(current.slotConfigs, slots)),
      );
    } else {
      await fetchActiveCourtSlots(force: true);
    }
    return null;
  }

  List<SlotPricingDraft> _upsertSlots(
    List<SlotPricingDraft> existing,
    List<SlotPricingDraft> updates,
  ) {
    final List<SlotPricingDraft> result = List<SlotPricingDraft>.of(existing);
    for (final SlotPricingDraft update in updates) {
      final int index = result.indexWhere(
        (SlotPricingDraft item) => item.id == update.id,
      );
      if (index >= 0) {
        result[index] = update;
      } else {
        result.add(update);
      }
    }
    return result;
  }

  bool _hasInvalidSlotIdFailure(
    Either<AppException, List<SlotPricingDraft>> response,
  ) {
    return response.fold((AppException failure) {
      final String message = failure.errorMessage.toLowerCase();
      return message.contains('slot') &&
          message.contains('id') &&
          message.contains('invalid');
    }, (_) => false);
  }

  Future<Either<AppException, List<SlotPricingDraft>>?>
  _retrySlotMutationWithFreshId(
    SlotPricingDraft staleSlot,
    int courtId, {
    required bool isPricing,
  }) async {
    await fetchActiveCourtSlots(force: true);
    if (isClosed) return null;

    final CourtDraft? current = state.activeCourt;
    final SlotPricingDraft? freshSlot = _resolveFreshSlot(
      staleSlot,
      current?.slotConfigs ?? const <SlotPricingDraft>[],
    );
    if (freshSlot == null || freshSlot.id == staleSlot.id) return null;

    final SlotPricingDraft retrySlot = _slotWithId(staleSlot, freshSlot.id);
    final GetVenueCourtUseCase useCase = GetVenueCourtUseCase(
      VenueCourtRepositoryImpl(),
    );
    return useCase.updateCourtSlot(
      isPricing
          ? courtSlotPricingBody(retrySlot, courtId: courtId)
          : courtSlotBody(retrySlot, courtId: courtId),
    );
  }

  SlotPricingDraft? _resolveFreshSlot(
    SlotPricingDraft staleSlot,
    List<SlotPricingDraft> freshSlots,
  ) {
    for (final SlotPricingDraft slot in freshSlots) {
      if (slot.id == staleSlot.id) return slot;
    }
    for (final SlotPricingDraft slot in freshSlots) {
      if (_sameSlotSchedule(slot, staleSlot)) return slot;
    }
    return null;
  }

  bool _sameSlotSchedule(SlotPricingDraft a, SlotPricingDraft b) {
    return a.label.trim().toLowerCase() == b.label.trim().toLowerCase() &&
        _normalizedSlotDays(a.days) == _normalizedSlotDays(b.days) &&
        a.startTime.trim() == b.startTime.trim() &&
        a.endTime.trim() == b.endTime.trim();
  }

  String _normalizedSlotDays(Set<String> days) {
    final List<String> normalized =
        days.map((String day) => day.trim().toLowerCase()).toList()..sort();
    return normalized.join(',');
  }

  SlotPricingDraft _slotWithId(SlotPricingDraft slot, String id) {
    return SlotPricingDraft(
      id: id,
      label: slot.label,
      days: slot.days,
      startTime: slot.startTime,
      endTime: slot.endTime,
      price: slot.price,
      weekendPrice: slot.weekendPrice,
      holidayPrice: slot.holidayPrice,
      customDatePrices: slot.customDatePrices,
      discountPrice: slot.discountPrice,
      discountType: slot.discountType,
      paymentPercent: slot.paymentPercent,
    );
  }

  final Set<int> _courtSlotsFetched = <int>{};
  final Set<int> _courtSlotsFetching = <int>{};

  Future<void> fetchActiveCourtSlots({bool force = false}) async {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    final int? courtId = court.remoteId ?? int.tryParse(court.id);
    if (courtId == null) return;
    if (!force &&
        (_courtSlotsFetched.contains(courtId) ||
            _courtSlotsFetching.contains(courtId))) {
      return;
    }

    _courtSlotsFetching.add(courtId);
    emit(state.copyWith(isLoadingCourts: true, clearErrorMessage: true));

    final Either<AppException, List<SlotPricingDraft>> response =
        await GetVenueCourtUseCase(
          VenueCourtRepositoryImpl(),
        ).getCourtSlots(courtId);

    _courtSlotsFetching.remove(courtId);
    if (isClosed) return;

    response.fold(
      (AppException failure) {
        emit(
          state.copyWith(
            isLoadingCourts: false,
            errorMessage: failure.errorMessage,
            errorOrigin: VendorErrorOrigin.api,
          ),
        );
      },
      (List<SlotPricingDraft> slots) {
        _courtSlotsFetched.add(courtId);
        final CourtDraft? current = state.activeCourt;
        if (current != null) {
          updateActiveCourt(current.copyWith(slotConfigs: slots));
        }
        emit(state.copyWith(isLoadingCourts: false, clearErrorMessage: true));
      },
    );
  }

  void updateSlot(String slotId, SlotPricingDraft nextSlot) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(
        slotConfigs: court.slotConfigs
            .map((SlotPricingDraft slot) => slot.id == slotId ? nextSlot : slot)
            .toList(),
      ),
    );
  }

  void toggleSlotDay(String slotId, String day) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    final SlotPricingDraft? slot = _slotById(court, slotId);
    if (slot == null) return;
    updateSlot(slotId, slot.copyWith(days: _toggleSetValue(slot.days, day)));
  }

  void toggleCourtWeekendDay(String day) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(weekendDays: _toggleSetValue(court.weekendDays, day)),
    );
  }

  void addCourtHolidayDate(String isoDate) {
    final CourtDraft? court = state.activeCourt;
    final String normalized = isoDate.trim();
    if (court == null || normalized.isEmpty) return;
    updateActiveCourt(
      court.copyWith(
        holidayDates: <String>{...court.holidayDates, normalized},
        closedDates: court.closedDates.where((ClosedDateDraft item) {
          return item.date != normalized;
        }).toList(),
      ),
    );
  }

  void addCourtHolidayDates(Iterable<String> isoDates) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    final Set<String> normalized = isoDates
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toSet();
    if (normalized.isEmpty) return;
    updateActiveCourt(
      court.copyWith(
        holidayDates: <String>{...court.holidayDates, ...normalized},
        closedDates: court.closedDates.where((ClosedDateDraft item) {
          return !normalized.contains(item.date);
        }).toList(),
      ),
    );
  }

  void removeCourtHolidayDate(String isoDate) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(
        holidayDates: court.holidayDates.where((String item) {
          return item != isoDate;
        }).toSet(),
      ),
    );
  }

  void addCourtClosedDate(ClosedDateDraft closedDate) {
    final CourtDraft? court = state.activeCourt;
    final String normalized = closedDate.date.trim();
    if (court == null || normalized.isEmpty) return;
    updateActiveCourt(
      court.copyWith(
        closedDates: <ClosedDateDraft>[
          ...court.closedDates.where((ClosedDateDraft item) {
            return item.date != normalized;
          }),
          closedDate.copyWith(date: normalized),
        ],
        holidayDates: court.holidayDates.where((String item) {
          return item != normalized;
        }).toSet(),
      ),
    );
  }

  void removeCourtClosedDate(String isoDate) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(
        closedDates: court.closedDates.where((ClosedDateDraft item) {
          return item.date != isoDate;
        }).toList(),
      ),
    );
  }

  void removeSlot(String slotId) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(
        slotConfigs: court.slotConfigs
            .where((SlotPricingDraft slot) => slot.id != slotId)
            .toList(),
      ),
    );
  }

  Future<String?> pickFutsalCoverImage() async {
    final UploadRef? file = await _pickSingleFile(
      allowedExtensions: <String>['png', 'jpg', 'jpeg', 'webp'],
    );
    if (file == null) return null;
    addFilesToMediaLibrary(<UploadRef>[file]);
    setFutsalCoverImage(file);
    return null;
  }

  Future<String?> pickFutsalGalleryImages() async {
    final List<UploadRef> files = await _pickMultipleFiles(
      allowedExtensions: <String>['png', 'jpg', 'jpeg', 'webp'],
    );
    if (files.isEmpty) return null;
    addFilesToMediaLibrary(files);
    addFutsalGalleryImages(files);
    return null;
  }

  Future<String?> pickCompanyDocuments() async {
    final List<UploadRef> files = await _pickMultipleFiles(
      allowedExtensions: <String>['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (files.isEmpty) return null;
    addFilesToMediaLibrary(files);
    addCompanyDocuments(files);
    return null;
  }

  Future<String?> pickCourtPaymentQr() async {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return null;
    final UploadRef? file = await _pickSingleFile(
      allowedExtensions: <String>['png', 'jpg', 'jpeg', 'webp'],
    );
    if (file == null) return null;
    addFilesToMediaLibrary(<UploadRef>[file]);
    setCourtPaymentQr(file);
    return null;
  }

  Future<String?> pickCourtPhotos() async {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return null;
    final List<UploadRef> files = await _pickMultipleFiles(
      allowedExtensions: <String>['png', 'jpg', 'jpeg', 'webp'],
    );
    if (files.isEmpty) return null;
    addFilesToMediaLibrary(files);
    addCourtPhotos(files);
    return null;
  }

  Future<String?> pickCourtMemories() async {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return null;
    final List<UploadRef> files = await _pickMultipleFiles(
      allowedExtensions: <String>['png', 'jpg', 'jpeg', 'webp'],
    );
    if (files.isEmpty) return null;
    addFilesToMediaLibrary(files);
    addCourtMemories(files);
    return null;
  }

  void setFutsalCoverImage(UploadRef file) {
    updateFutsal(
      state.futsal.copyWith(
        coverImage: file,
        selectedCoverImage: SelectedImageRef.fromUploadRef(file),
      ),
    );
  }

  void addFutsalGalleryImages(List<UploadRef> files) {
    if (files.isEmpty) return;
    final List<UploadRef> mergedGallery = _mergeUniqueUploads(
      state.futsal.gallery,
      files,
    );
    final List<SelectedImageRef> mergedSelectedGallery =
        _mergeUniqueSelectedImages(
          state.futsal.selectedGalleryImages,
          files.map(SelectedImageRef.fromUploadRef).toList(),
        );
    updateFutsal(
      state.futsal.copyWith(
        gallery: mergedGallery,
        selectedGalleryImages: mergedSelectedGallery,
      ),
    );
  }

  void addCompanyDocuments(List<UploadRef> files) {
    if (files.isEmpty) return;
    updateFutsal(
      state.futsal.copyWith(
        companyDocuments: _mergeUniqueUploads(
          state.futsal.companyDocuments,
          files,
        ),
      ),
    );
  }

  /// Moves an item within a list, applying the index adjustment
  /// `ReorderableListView` expects when dragging downward.
  List<T> _reorderList<T>(List<T> source, int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= source.length) return source;
    final List<T> list = List<T>.of(source);
    int target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (target < 0) target = 0;
    if (target > list.length - 1) target = list.length - 1;
    final T item = list.removeAt(oldIndex);
    list.insert(target, item);
    return list;
  }

  /// Reorders the futsal gallery (the cover image is the first entry, so the
  /// order users drag into is the order shown on the listing). Keeps the
  /// parallel selected-image list in sync.
  void reorderFutsalGalleryImages(int oldIndex, int newIndex) {
    updateFutsal(
      state.futsal.copyWith(
        gallery: _reorderList(state.futsal.gallery, oldIndex, newIndex),
        selectedGalleryImages: _reorderList(
          state.futsal.selectedGalleryImages,
          oldIndex,
          newIndex,
        ),
      ),
    );
  }

  void reorderCompanyDocuments(int oldIndex, int newIndex) {
    updateFutsal(
      state.futsal.copyWith(
        companyDocuments: _reorderList(
          state.futsal.companyDocuments,
          oldIndex,
          newIndex,
        ),
      ),
    );
  }

  void setCourtPaymentQr(UploadRef file) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(court.copyWith(paymentQr: file));
  }

  void addCourtPhotos(List<UploadRef> files) {
    final CourtDraft? court = state.activeCourt;
    if (court == null || files.isEmpty) return;
    updateActiveCourt(
      court.copyWith(photos: _mergeUniqueUploads(court.photos, files)),
    );
  }

  void addCourtMemories(List<UploadRef> files) {
    final CourtDraft? court = state.activeCourt;
    if (court == null || files.isEmpty) return;
    updateActiveCourt(
      court.copyWith(memories: _mergeUniqueUploads(court.memories, files)),
    );
  }

  void removeFutsalCoverImage() {
    updateFutsal(
      state.futsal.copyWith(
        clearCoverImage: true,
        clearSelectedCoverImage: true,
      ),
    );
  }

  void removeFutsalGalleryImage(UploadRef file) {
    updateFutsal(
      state.futsal.copyWith(
        gallery: state.futsal.gallery
            .where((UploadRef item) => item.remoteUrl != file.remoteUrl)
            .toList(),
        selectedGalleryImages: state.futsal.selectedGalleryImages
            .where(
              (SelectedImageRef item) => item.image.remoteUrl != file.remoteUrl,
            )
            .toList(),
      ),
    );
  }

  void removeCompanyDocument(UploadRef file) {
    final UploadRef? stored = state.futsal.companyDocuments
        .where((UploadRef item) => item.storageKey == file.storageKey)
        .firstOrNull;
    if (stored?.verificationStatus.isLocked ??
        file.verificationStatus.isLocked) {
      return;
    }
    updateFutsal(
      state.futsal.copyWith(
        companyDocuments: state.futsal.companyDocuments
            .where((UploadRef item) => item.storageKey != file.storageKey)
            .toList(),
      ),
    );
  }

  /// Swaps a rejected company document for a freshly picked one. Only
  /// rejected documents can be replaced — pending/approved are locked.
  void replaceCompanyDocument(UploadRef oldFile, UploadRef newFile) {
    final UploadRef? stored = state.futsal.companyDocuments
        .where((UploadRef item) => item.storageKey == oldFile.storageKey)
        .firstOrNull;
    if (stored?.verificationStatus != UploadVerificationStatus.rejected) {
      return;
    }
    updateFutsal(
      state.futsal.copyWith(
        companyDocuments: state.futsal.companyDocuments
            .map(
              (UploadRef item) =>
                  item.storageKey == oldFile.storageKey ? newFile : item,
            )
            .toList(),
      ),
    );
  }

  void removeCourtPaymentQr() {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(court.copyWith(clearPaymentQr: true));
  }

  void removeCourtPhoto(UploadRef file) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(
        photos: court.photos
            .where((UploadRef item) => item.remoteUrl != file.remoteUrl)
            .toList(),
      ),
    );
  }

  void removeCourtMemory(UploadRef file) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(
        memories: court.memories
            .where((UploadRef item) => item.remoteUrl != file.remoteUrl)
            .toList(),
      ),
    );
  }

  Future<void> saveDraftNow() async {
    await _saveDraft(showSavingState: true);
  }

  Future<String?> saveProgressBeforeExit() async {
    if (state.isSubmitting) {
      return 'Please wait for the current save to finish.';
    }
    _flushActiveEditors();
    final String? failure = await _submitProgressIfNeeded();
    if (failure != null) return failure;
    await _saveDraft(showSavingState: false);
    return null;
  }

  Future<String?> submit() async {
    if (state.isSubmitting) return null;
    _flushActiveEditors();

    for (
      int sectionIndex = 0;
      sectionIndex < futsalSectionDefinitions.length;
      sectionIndex++
    ) {
      for (
        int subsectionIndex = 0;
        subsectionIndex <
            futsalSectionDefinitions[sectionIndex].substeps.length;
        subsectionIndex++
      ) {
        final VendorValidationResult result =
            VendorOnboardingValidator.validateFutsalSubstep(
              state.futsal,
              sectionIndex,
              subsectionIndex,
            );
        if (!result.isValid) {
          _moveToFutsal(sectionIndex, subsectionIndex);
          _registerValidationFailure(result);
          return result.message;
        }
      }
    }

    if (state.courts.isEmpty) {
      const VendorValidationResult result = VendorValidationResult.invalid(
        'courts_required',
        'Add at least one court before publishing.',
      );
      emit(
        state.copyWith(
          cursor: const StepCursor(
            category: VendorCategory.court,
            sectionIndex: 0,
            subsectionIndex: 0,
          ),
          clearActiveCourtId: true,
        ),
      );
      _registerValidationFailure(result);
      return result.message;
    }

    for (final CourtDraft court in state.courts) {
      for (
        int sectionIndex = 0;
        sectionIndex < courtSectionDefinitions.length;
        sectionIndex++
      ) {
        for (
          int subsectionIndex = 0;
          subsectionIndex <
              courtSectionDefinitions[sectionIndex].substeps.length;
          subsectionIndex++
        ) {
          final VendorValidationResult result =
              VendorOnboardingValidator.validateCourtSubstep(
                court,
                sectionIndex,
                subsectionIndex,
              );
          if (!result.isValid) {
            _moveToCourt(court.id, sectionIndex, subsectionIndex);
            _registerValidationFailure(result);
            return result.message;
          }
        }
      }
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        clearErrorMessage: true,
        errorKeys: const <String>{},
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await _saveDraft(showSavingState: false);
    emit(state.copyWith(isSubmitting: false, isCompleted: true));
    return null;
  }

  Future<void> resetOnboarding() async {
    _saveDebounce?.cancel();
    _courtsFetchedForVenueId = null;
    await _draftRepository.clear();
    emit(_clearedState());
  }

  void clearOnboardingState() {
    _saveDebounce?.cancel();
    _courtsFetchedForVenueId = null;
    emit(_clearedState());
  }

  void setRemoteFutsalId(int futsalId) {
    emit(state.copyWith(remoteFutsalId: futsalId));
  }

  void prepareCourtForEditing(CourtDraft court) {
    final Map<String, SectionPointer> pointers = <String, SectionPointer>{
      court.id: const SectionPointer(sectionIndex: 0, subsectionIndex: 0),
    };
    emit(
      _normalizeState(
        state.copyWith(
          courts: <CourtDraft>[court],
          activeCourtId: court.id,
          courtPointersById: pointers,
          cursor: StepCursor(
            category: VendorCategory.court,
            sectionIndex: 0,
            subsectionIndex: 0,
            courtId: court.id,
          ),
        ),
      ),
    );
  }

  Future<String?> deleteCourtById(int courtId) async {
    final Either<AppException, void> response = await _onboardingUseCase
        .deleteCourt(courtId);
    return response.fold(
      (AppException failure) => failure.errorMessage,
      (_) => null,
    );
  }

  @override
  Future<void> close() {
    _saveDebounce?.cancel();
    focusInvalidFieldRequest.dispose();
    return super.close();
  }

  bool _shouldFetchRemoteCourts() {
    final int? futsalId = state.remoteFutsalId;
    if (futsalId == null) return false;
    if (_courtsFetchedForVenueId == futsalId) return false;
    if (state.isLoadingCourts) return false;
    return true;
  }

  Future<void> _fetchRemoteCourts() async {
    final int? futsalId = state.remoteFutsalId;
    if (futsalId == null) return;
    _courtsFetchedForVenueId = futsalId;

    final Either<AppException, List<CourtDraft>> response =
        await _onboardingUseCase.fetchCourtsByVenueId(futsalId);

    response.fold(
      (AppException failure) {
        emit(state.copyWith(isLoadingCourts: false));
      },
      (List<CourtDraft> courts) {
        emit(
          _normalizeState(
            state.copyWith(courts: courts, isLoadingCourts: false),
          ),
        );
      },
    );
  }

  void _moveToFutsal(int sectionIndex, int subsectionIndex) {
    final int safeSectionIndex = _clamp(
      sectionIndex,
      0,
      futsalSectionDefinitions.length - 1,
    );
    final int safeSubsectionIndex = _clamp(
      subsectionIndex,
      0,
      futsalSectionDefinitions[safeSectionIndex].substeps.length - 1,
    );
    final SectionPointer pointer = SectionPointer(
      sectionIndex: safeSectionIndex,
      subsectionIndex: safeSubsectionIndex,
    );
    emit(
      state.copyWith(
        futsalPointer: pointer,
        cursor: StepCursor(
          category: VendorCategory.futsal,
          sectionIndex: pointer.sectionIndex,
          subsectionIndex: pointer.subsectionIndex,
        ),
        clearErrorMessage: true,
      ),
    );
  }

  void _moveToCourt(String courtId, int sectionIndex, int subsectionIndex) {
    final int safeSectionIndex = _clamp(
      sectionIndex,
      0,
      courtSectionDefinitions.length - 1,
    );
    final int safeSubsectionIndex = _clamp(
      subsectionIndex,
      0,
      courtSectionDefinitions[safeSectionIndex].substeps.length - 1,
    );
    final Map<String, SectionPointer> pointers =
        Map<String, SectionPointer>.from(state.courtPointersById)
          ..[courtId] = SectionPointer(
            sectionIndex: safeSectionIndex,
            subsectionIndex: safeSubsectionIndex,
          );
    emit(
      state.copyWith(
        activeCourtId: courtId,
        courtPointersById: pointers,
        cursor: StepCursor(
          category: VendorCategory.court,
          sectionIndex: safeSectionIndex,
          subsectionIndex: safeSubsectionIndex,
          courtId: courtId,
        ),
        clearErrorMessage: true,
      ),
    );
  }

  void _emitUpdated(VendorOnboardingState nextState) {
    emit(
      _normalizeState(
        nextState.copyWith(
          isDirty: true,
          isCompleted: false,
          saveStatus: DraftSaveStatus.unsaved,
          clearErrorMessage: true,
          errorKeys: _pruneActiveErrorKeys(nextState.errorKeys),
        ),
      ),
    );
    _scheduleDraftSave();
  }

  void _flushActiveEditors() {
    try {
      _editorFlushCallback?.call();
    } catch (_) {
      // Best-effort flush; never block navigation.
    }
  }

  Future<String?> _submitProgressIfNeeded() async {
    if (state.isInCourtCategory) {
      return _submitCourtProgressIfNeeded();
    }
    return _submitFutsalProgressIfNeeded();
  }

  Future<String?> _submitFutsalProgressIfNeeded() async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final Map<String, dynamic> body = state.toFutsalBody(
        mainStep: currentSectionIndex,
        subStep: currentSubstepIndex,
        futsalId: state.remoteFutsalId,
        currentSubstepOnly: state.remoteFutsalId != null,
      );
      final Either<AppException, VendorOnboardingResponseModel> response =
          state.remoteFutsalId == null
          ? await _onboardingUseCase.submitFutsal(body)
          : await _onboardingUseCase.updateFutsal(body);

      return response.fold(
        (AppException failure) {
          emit(
            state.copyWith(
              isSubmitting: false,
              errorMessage: failure.errorMessage,
              errorOrigin: VendorErrorOrigin.api,
            ),
          );
          return failure.errorMessage;
        },
        (VendorOnboardingResponseModel data) {
          emit(
            state.copyWith(
              isSubmitting: false,
              remoteFutsalId: data.id ?? state.remoteFutsalId,
              clearErrorMessage: true,
            ),
          );
          return null;
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: error.toString(),
          errorOrigin: VendorErrorOrigin.api,
        ),
      );
      return error.toString();
    }
  }

  Future<String?> _submitCourtProgressIfNeeded() async {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return null;

    final int? futsalId = state.remoteFutsalId;
    if (futsalId == null) {
      const String message =
          'Complete and save the futsal venue before adding courts.';
      emit(
        state.copyWith(
          errorMessage: message,
          errorOrigin: VendorErrorOrigin.api,
        ),
      );
      return message;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final bool hasRemoteCourt = court.remoteId != null;
      final Map<String, dynamic> body = state.toCourtBody(
        court: court,
        mainStep: currentSectionIndex,
        subStep: currentSubstepIndex,
        futsalId: futsalId,
        currentSubstepOnly: hasRemoteCourt,
      );
      final Either<AppException, CourtOnboardingResponseModel> response =
          hasRemoteCourt
          ? await _onboardingUseCase.updateCourt(body)
          : await _onboardingUseCase.submitCourt(body);

      return response.fold(
        (AppException failure) {
          emit(
            state.copyWith(
              isSubmitting: false,
              errorMessage: failure.errorMessage,
              errorOrigin: VendorErrorOrigin.api,
            ),
          );
          return failure.errorMessage;
        },
        (CourtOnboardingResponseModel data) {
          final CourtDraft updatedCourt = data.mergeInto(court);
          final List<CourtDraft> nextCourts = state.courts
              .map(
                (CourtDraft item) => item.id == court.id ? updatedCourt : item,
              )
              .toList();
          final Map<String, SectionPointer> nextPointers =
              Map<String, SectionPointer>.from(state.courtPointersById);
          nextPointers[court.id] = SectionPointer(
            sectionIndex: _clamp(
              data.mainStep,
              0,
              courtSectionDefinitions.length - 1,
            ),
            subsectionIndex: _clamp(
              data.subStep,
              0,
              courtSectionDefinitions[_clamp(
                        data.mainStep,
                        0,
                        courtSectionDefinitions.length - 1,
                      )]
                      .substeps
                      .length -
                  1,
            ),
          );
          emit(
            state.copyWith(
              isSubmitting: false,
              courts: nextCourts,
              courtPointersById: nextPointers,
              clearErrorMessage: true,
            ),
          );
          _scheduleDraftSave();
          return null;
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: error.toString(),
          errorOrigin: VendorErrorOrigin.api,
        ),
      );
      return error.toString();
    }
  }

  void _registerValidationFailure(VendorValidationResult result) {
    final Set<String> errorKeys = Set<String>.from(state.errorKeys)
      ..add(result.key);
    if (!state.isInCourtCategory) {
      errorKeys.add(
        VendorOnboardingValidator.futsalSectionKey(currentSectionIndex),
      );
    } else if (state.activeCourtId != null) {
      errorKeys.add(
        VendorOnboardingValidator.courtSectionKey(
          state.activeCourtId!,
          currentSectionIndex,
        ),
      );
    }

    emit(
      state.copyWith(
        errorMessage: result.message,
        errorOrigin: VendorErrorOrigin.validation,
        errorKeys: errorKeys,
      ),
    );

    _focusRequestToken++;
    focusInvalidFieldRequest.value = '${result.key}#$_focusRequestToken';
  }

  Set<String> _pruneActiveErrorKeys(Set<String> existing) {
    final Set<String> next = Set<String>.from(existing);
    if (!state.isInCourtCategory) {
      next.remove(
        VendorOnboardingValidator.futsalSubstepKey(
          currentSectionIndex,
          currentSubstepIndex,
        ),
      );
      next.remove(
        VendorOnboardingValidator.futsalSectionKey(currentSectionIndex),
      );
    } else if (state.activeCourtId != null) {
      next.remove(
        VendorOnboardingValidator.courtSubstepKey(
          state.activeCourtId!,
          currentSectionIndex,
          currentSubstepIndex,
        ),
      );
      next.remove(
        VendorOnboardingValidator.courtSectionKey(
          state.activeCourtId!,
          currentSectionIndex,
        ),
      );
    }
    return next;
  }

  void _emitError(String message) {
    emit(
      state.copyWith(
        errorMessage: message,
        errorOrigin: VendorErrorOrigin.local,
      ),
    );
  }

  StepStatus _aggregateStatuses(List<StepStatus> statuses) {
    if (statuses.isEmpty) return StepStatus.notStarted;
    if (statuses.any((StepStatus status) => status == StepStatus.error)) {
      return StepStatus.error;
    }
    if (statuses.every((StepStatus status) => status == StepStatus.complete)) {
      return StepStatus.complete;
    }
    if (statuses.any(
      (StepStatus status) =>
          status == StepStatus.complete || status == StepStatus.inProgress,
    )) {
      return StepStatus.inProgress;
    }
    if (statuses.every((StepStatus status) => status == StepStatus.locked)) {
      return StepStatus.locked;
    }
    return StepStatus.notStarted;
  }

  Future<void> _saveDraft({required bool showSavingState}) async {
    if (showSavingState) {
      emit(state.copyWith(saveStatus: DraftSaveStatus.unsaved));
    }
  }

  void _scheduleDraftSave() {
    _saveDebounce?.cancel();
  }

  VendorOnboardingState _normalizeState(VendorOnboardingState input) {
    final FutsalDraft normalizedFutsal = _syncFutsalSelectedImages(
      input.futsal.copyWith(
        slug: input.futsal.slug.trim().isEmpty
            ? _buildFutsalSlug(
                title: input.futsal.title,
                currentSlug: input.futsal.slug,
              )
            : input.futsal.slug.trim(),
        websiteOrSocialLink: input.futsal.websiteOrSocialLink.trim(),
      ),
    );
    final List<CourtDraft> courts = List<CourtDraft>.unmodifiable(input.courts);
    final Map<String, SectionPointer> pointers = <String, SectionPointer>{};
    for (final CourtDraft court in courts) {
      final SectionPointer rawPointer =
          input.courtPointersById[court.id] ??
          const SectionPointer(sectionIndex: 0, subsectionIndex: 0);
      pointers[court.id] = SectionPointer(
        sectionIndex: _clamp(
          rawPointer.sectionIndex,
          0,
          courtSectionDefinitions.length - 1,
        ),
        subsectionIndex: _clamp(
          rawPointer.subsectionIndex,
          0,
          courtSectionDefinitions[_clamp(
                    rawPointer.sectionIndex,
                    0,
                    courtSectionDefinitions.length - 1,
                  )]
                  .substeps
                  .length -
              1,
        ),
      );
    }

    final SectionPointer futsalPointer = SectionPointer(
      sectionIndex: _clamp(
        input.futsalPointer.sectionIndex,
        0,
        futsalSectionDefinitions.length - 1,
      ),
      subsectionIndex: _clamp(
        input.futsalPointer.subsectionIndex,
        0,
        futsalSectionDefinitions[_clamp(
                  input.futsalPointer.sectionIndex,
                  0,
                  futsalSectionDefinitions.length - 1,
                )]
                .substeps
                .length -
            1,
      ),
    );

    String? activeCourtId = input.activeCourtId;
    if (activeCourtId != null &&
        !courts.any((CourtDraft court) => court.id == activeCourtId)) {
      activeCourtId = null;
    }
    if (activeCourtId == null && courts.isNotEmpty) {
      activeCourtId = courts.first.id;
    }

    StepCursor cursor = input.cursor;
    if (cursor.category == VendorCategory.futsal) {
      cursor = StepCursor(
        category: VendorCategory.futsal,
        sectionIndex: futsalPointer.sectionIndex,
        subsectionIndex: futsalPointer.subsectionIndex,
      );
    } else if (activeCourtId == null) {
      cursor = const StepCursor(
        category: VendorCategory.court,
        sectionIndex: 0,
        subsectionIndex: 0,
      );
    } else {
      final SectionPointer pointer =
          pointers[activeCourtId] ??
          const SectionPointer(sectionIndex: 0, subsectionIndex: 0);
      cursor = StepCursor(
        category: VendorCategory.court,
        sectionIndex: pointer.sectionIndex,
        subsectionIndex: pointer.subsectionIndex,
        courtId: activeCourtId,
      );
    }

    return input.copyWith(
      futsal: normalizedFutsal,
      courts: courts,
      futsalPointer: futsalPointer,
      courtPointersById: pointers,
      activeCourtId: activeCourtId,
      cursor: cursor,
    );
  }

  VendorOnboardingState _clearedState() {
    return VendorOnboardingState.initial().copyWith(
      isRestoringDraft: false,
      saveStatus: DraftSaveStatus.unsaved,
    );
  }

  CourtDraft? _courtById(String courtId) {
    for (final CourtDraft court in state.courts) {
      if (court.id == courtId || court.remoteId?.toString() == courtId) {
        return court;
      }
    }
    return null;
  }

  SlotPricingDraft? _slotById(CourtDraft court, String slotId) {
    for (final SlotPricingDraft slot in court.slotConfigs) {
      if (slot.id == slotId) return slot;
    }
    return null;
  }

  int get _activeCourtIndex {
    if (state.activeCourtId == null) return -1;
    return state.courts.indexWhere(
      (CourtDraft court) => court.id == state.activeCourtId,
    );
  }

  String? _nextCourtId(String courtId) {
    final int index = state.courts.indexWhere(
      (CourtDraft court) => court.id == courtId,
    );
    if (index == -1 || index == state.courts.length - 1) return null;
    return state.courts[index + 1].id;
  }

  String? _previousCourtId(String courtId) {
    final int index = state.courts.indexWhere(
      (CourtDraft court) => court.id == courtId,
    );
    if (index <= 0) return null;
    return state.courts[index - 1].id;
  }

  Set<String> _toggleSetValue(Set<String> current, String value) {
    final Set<String> next = Set<String>.from(current);
    if (!next.add(value)) {
      next.remove(value);
    }
    return next;
  }

  Set<T> _toggleSetValueT<T>(Set<T> current, T value) {
    final Set<T> next = Set<T>.from(current);
    if (!next.add(value)) {
      next.remove(value);
    }
    return next;
  }

  Future<UploadRef?> _pickSingleFile({
    required List<String> allowedExtensions,
  }) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: allowedExtensions,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return _toUploadRef(result.files.first);
  }

  Future<List<UploadRef>> _pickMultipleFiles({
    required List<String> allowedExtensions,
  }) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: allowedExtensions,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return const <UploadRef>[];
    return result.files.map(_toUploadRef).whereType<UploadRef>().toList();
  }

  UploadRef? _toUploadRef(PlatformFile file) {
    final String path = file.path ?? '';
    if (path.trim().isEmpty) return null;
    return UploadRef(name: file.name, remoteUrl: path);
  }

  String _newCourtId() {
    return 'court_${DateTime.now().microsecondsSinceEpoch}_${state.courts.length + 1}';
  }

  String _newSlotId(String courtId) {
    return '${courtId}_slot_${DateTime.now().microsecondsSinceEpoch}';
  }

  int _clamp(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  List<UploadRef> _mergeUniqueUploads(
    List<UploadRef> current,
    List<UploadRef> additions,
  ) {
    final Map<String, UploadRef> byPath = <String, UploadRef>{
      for (final UploadRef item in current) item.storageKey: item,
    };
    for (final UploadRef item in additions) {
      final String key = item.storageKey;
      final UploadRef? existing = byPath[key];
      // Never let a picker result overwrite server-reviewed metadata.
      if (existing?.verificationStatus.isLocked ?? false) continue;
      byPath[key] = item;
    }
    return byPath.values.toList();
  }

  List<SelectedImageRef> _mergeUniqueSelectedImages(
    List<SelectedImageRef> current,
    List<SelectedImageRef> additions,
  ) {
    final Map<String, SelectedImageRef> byPath = <String, SelectedImageRef>{
      for (final SelectedImageRef item in current)
        item.image.remoteUrl ?? '': item,
    };
    for (final SelectedImageRef item in additions) {
      byPath[item.image.remoteUrl ?? ''] = item;
    }
    return byPath.values.toList();
  }

  FutsalDraft _syncFutsalSelectedImages(FutsalDraft draft) {
    final SelectedImageRef? coverSelection =
        draft.selectedCoverImage ??
        (draft.coverImage == null
            ? null
            : SelectedImageRef.fromUploadRef(draft.coverImage!));
    final List<SelectedImageRef> gallerySelections = _mergeUniqueSelectedImages(
      draft.selectedGalleryImages,
      draft.gallery.map(SelectedImageRef.fromUploadRef).toList(),
    );

    return draft.copyWith(
      selectedCoverImage: coverSelection,
      selectedGalleryImages: gallerySelections,
    );
  }

  bool _haveSameUploadPaths(List<UploadRef> left, List<UploadRef> right) {
    if (identical(left, right)) return true;
    if (left.length != right.length) return false;

    final Set<String> leftPaths = left
        .map((UploadRef item) => item.remoteUrl ?? '')
        .toSet();
    final Set<String> rightPaths = right
        .map((UploadRef item) => item.remoteUrl ?? '')
        .toSet();
    if (leftPaths.length != rightPaths.length) return false;

    for (final String path in leftPaths) {
      if (!rightPaths.contains(path)) return false;
    }
    return true;
  }

  String _buildFutsalSlug({
    required String title,
    required String currentSlug,
  }) {
    final String base = _slugify(title);
    if (base.isEmpty) return currentSlug;

    final String existingSuffix = _extractSlugSuffix(currentSlug, base);
    final String suffix = existingSuffix.isNotEmpty
        ? existingSuffix
        : _generateSlugSuffix();
    return '$base-$suffix';
  }

  String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _extractSlugSuffix(String currentSlug, String base) {
    final String normalized = currentSlug.trim().toLowerCase();
    if (normalized.isEmpty) return '';
    final String prefix = '$base-';
    if (!normalized.startsWith(prefix)) return '';
    return normalized.substring(prefix.length);
  }

  String _generateSlugSuffix() {
    const String alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    return List<String>.generate(
      4,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }
}
