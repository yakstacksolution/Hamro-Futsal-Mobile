import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_footsall/features/vendor/data/repositories/vendor_onboarding_repository_impl.dart';
import 'package:hamro_footsall/features/vendor/domain/usecase/vendor_onboarding_usecase.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_api_payload.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/validation/vendor_onboarding_validator.dart';

class VendorOnboardingCubit extends Cubit<VendorOnboardingState> {
  VendorOnboardingCubit(
    this._draftRepository, {
    VendorOnboardingUseCase? onboardingUseCase,
  }) : super(VendorOnboardingState.initial()) {
    unawaited(restoreDraft());
    _onboardingUseCase =
        onboardingUseCase ??
        VendorOnboardingUseCase(VendorOnboardingRepositoryImpl());
  }

  final VendorDraftRepository _draftRepository;
  late final VendorOnboardingUseCase _onboardingUseCase;
  Timer? _saveDebounce;
  int _revision = 0;
  Object? _editorFlushOwner;
  void Function()? _editorFlushCallback;

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
    if (!_canJumpToFutsalSubstep(sectionIndex, subsectionIndex) &&
        !_isCurrentFutsalSubstep(sectionIndex, subsectionIndex)) {
      return StepStatus.locked;
    }
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
    if (!_canJumpToCourtSubstep(courtId, sectionIndex, subsectionIndex) &&
        !_isCurrentCourtSubstep(courtId, sectionIndex, subsectionIndex)) {
      return StepStatus.locked;
    }
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
    try {
      final VendorOnboardingState? restored = await _draftRepository.load();
      if (restored == null) {
        emit(
          state.copyWith(
            isRestoringDraft: false,
            saveStatus: DraftSaveStatus.idle,
          ),
        );
        return;
      }

      _revision = 0;
      emit(
        _normalizeState(
          restored.copyWith(
            isDirty: false,
            isRestoringDraft: false,
            isSubmitting: false,
            isCompleted: false,
            saveStatus: restored.lastSavedAt != null
                ? DraftSaveStatus.saved
                : DraftSaveStatus.idle,
            clearErrorMessage: true,
            errorKeys: const <String>{},
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isRestoringDraft: false,
          saveStatus: DraftSaveStatus.failure,
          errorMessage: 'Could not restore the saved onboarding draft.',
          errorOrigin: VendorErrorOrigin.local,
        ),
      );
    }
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
      _scheduleDraftSave();
      return;
    }

    if (!canAccessCourtCategory) {
      _emitError(
        'Complete the futsal basic info and location before creating courts.',
      );
      return;
    }

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
        ),
      );
      _scheduleDraftSave();
      return;
    }

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
      ),
    );
    _scheduleDraftSave();
  }

  void selectSection(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= activeSections.length) return;

    if (!state.isInCourtCategory) {
      if (!_canJumpToFutsalSection(sectionIndex)) {
        _emitError('Complete earlier futsal sections before jumping ahead.');
        return;
      }
      _moveToFutsal(sectionIndex, 0);
      return;
    }

    if (state.activeCourtId == null) {
      _emitError('Add a court before opening court steps.');
      return;
    }

    if (!_canJumpToCourtSection(state.activeCourtId!, sectionIndex)) {
      _emitError('Complete earlier court sections before jumping ahead.');
      return;
    }
    _moveToCourt(state.activeCourtId!, sectionIndex, 0);
  }

  void selectSubstep(int subsectionIndex) {
    if (subsectionIndex < 0 || subsectionIndex >= activeSubsteps.length) return;

    if (!state.isInCourtCategory) {
      if (!_canJumpToFutsalSubstep(currentSectionIndex, subsectionIndex)) {
        _emitError('Complete earlier substeps before jumping ahead.');
        return;
      }
      _moveToFutsal(currentSectionIndex, subsectionIndex);
      return;
    }

    if (state.activeCourtId == null) {
      _emitError('Add a court before opening court substeps.');
      return;
    }

    if (!_canJumpToCourtSubstep(
      state.activeCourtId!,
      currentSectionIndex,
      subsectionIndex,
    )) {
      _emitError('Complete earlier substeps before jumping ahead.');
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

    final String? registrationFailure = await _submitFutsalRegistrationIfNeeded(
      mainStep: 0,
      subStep: 2,
    );
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
    _emitUpdated(
      state.copyWith(
        mediaLibrary: state.mediaLibrary
            .where((UploadRef item) => item.localPath != file.localPath)
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

  void toggleCourtAmenity(String value) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(amenities: _toggleSetValue(court.amenities, value)),
    );
  }

  void toggleCourtFacility(String value) {
    final CourtDraft? court = state.activeCourt;
    if (court == null) return;
    updateActiveCourt(
      court.copyWith(facilities: _toggleSetValue(court.facilities, value)),
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
    updateActiveCourt(
      court.copyWith(
        advancePaymentRequired: value,
        clearPaymentPercent: !value,
        clearPaymentQr: !value,
      ),
    );
  }

  void addCourt({String? name}) {
    final String courtId = _newCourtId();
    final CourtDraft court = CourtDraft(
      id: courtId,
      name: name?.trim().isNotEmpty == true
          ? name!.trim()
          : 'Court ${state.courts.length + 1}',
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
    if (_courtById(courtId) == null) return;
    final SectionPointer pointer =
        state.courtPointersById[courtId] ??
        const SectionPointer(sectionIndex: 0, subsectionIndex: 0);
    emit(
      state.copyWith(
        activeCourtId: courtId,
        cursor: StepCursor(
          category: VendorCategory.court,
          sectionIndex: pointer.sectionIndex,
          subsectionIndex: pointer.subsectionIndex,
          courtId: courtId,
        ),
        clearErrorMessage: true,
      ),
    );
    _scheduleDraftSave();
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
    updateFutsal(state.futsal.copyWith(coverImage: file));
  }

  void addFutsalGalleryImages(List<UploadRef> files) {
    if (files.isEmpty) return;
    updateFutsal(
      state.futsal.copyWith(
        gallery: _mergeUniqueUploads(state.futsal.gallery, files),
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
    updateFutsal(state.futsal.copyWith(clearCoverImage: true));
  }

  void removeFutsalGalleryImage(UploadRef file) {
    updateFutsal(
      state.futsal.copyWith(
        gallery: state.futsal.gallery
            .where((UploadRef item) => item.localPath != file.localPath)
            .toList(),
      ),
    );
  }

  void removeCompanyDocument(UploadRef file) {
    updateFutsal(
      state.futsal.copyWith(
        companyDocuments: state.futsal.companyDocuments
            .where((UploadRef item) => item.localPath != file.localPath)
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
            .where((UploadRef item) => item.localPath != file.localPath)
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
            .where((UploadRef item) => item.localPath != file.localPath)
            .toList(),
      ),
    );
  }

  Future<void> saveDraftNow() async {
    await _saveDraft(showSavingState: true);
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
    _revision = 0;
    await _draftRepository.clear();
    emit(VendorOnboardingState.initial().copyWith(isRestoringDraft: false));
  }

  @override
  Future<void> close() {
    _saveDebounce?.cancel();
    return super.close();
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
    _scheduleDraftSave();
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
    _scheduleDraftSave();
  }

  void _emitUpdated(VendorOnboardingState nextState) {
    _revision++;
    emit(
      _normalizeState(
        nextState.copyWith(
          isDirty: true,
          isCompleted: false,
          saveStatus: DraftSaveStatus.idle,
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

  Future<String?> _submitFutsalRegistrationIfNeeded({
    required int mainStep,
    required int subStep,
  }) async {
    if (state.isInCourtCategory) return null;
    if (state.remoteFutsalId != null) return null;
    if (currentSectionIndex != mainStep || currentSubstepIndex != subStep) {
      return null;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final Map<String, dynamic> body = state.toCreateFutsalBody(
        mainStep: mainStep,
        subStep: subStep,
      );
      final Either<AppException, Map<String, dynamic>> response =
          await _onboardingUseCase.submitFutsal(body);

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
        (Map<String, dynamic> data) {
          emit(
            state.copyWith(
              isSubmitting: false,
              remoteFutsalId: _extractRemoteFutsalId(data),
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

  int? _extractRemoteFutsalId(Map<String, dynamic> data) {
    final Object? raw =
        data['id'] ?? data['futsal_id'] ?? data['futsalId'] ?? data['futsalID'];
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
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

  bool _canJumpToFutsalSection(int targetSectionIndex) {
    if (targetSectionIndex <= currentSectionIndex &&
        state.cursor.category == VendorCategory.futsal) {
      return true;
    }
    for (int index = 0; index < targetSectionIndex; index++) {
      if (futsalSectionStatus(index) != StepStatus.complete) {
        return false;
      }
    }
    return true;
  }

  bool _canJumpToFutsalSubstep(int sectionIndex, int subsectionIndex) {
    if (!_canJumpToFutsalSection(sectionIndex)) return false;
    if (sectionIndex < currentSectionIndex ||
        (sectionIndex == currentSectionIndex &&
            subsectionIndex <= currentSubstepIndex &&
            state.cursor.category == VendorCategory.futsal)) {
      return true;
    }
    for (int index = 0; index < subsectionIndex; index++) {
      if (futsalSubstepStatus(sectionIndex, index) != StepStatus.complete) {
        return false;
      }
    }
    return true;
  }

  bool _canJumpToCourtSection(String courtId, int targetSectionIndex) {
    if (_courtById(courtId) == null) return false;
    final bool isCurrentCourt = state.activeCourtId == courtId;
    if (isCurrentCourt &&
        targetSectionIndex <= currentSectionIndex &&
        state.isInCourtCategory) {
      return true;
    }
    for (int index = 0; index < targetSectionIndex; index++) {
      if (courtSectionStatus(courtId, index) != StepStatus.complete) {
        return false;
      }
    }
    return true;
  }

  bool _canJumpToCourtSubstep(
    String courtId,
    int sectionIndex,
    int subsectionIndex,
  ) {
    if (!_canJumpToCourtSection(courtId, sectionIndex)) return false;
    final bool isCurrentCourt = state.activeCourtId == courtId;
    if (isCurrentCourt &&
        state.isInCourtCategory &&
        sectionIndex == currentSectionIndex &&
        subsectionIndex <= currentSubstepIndex) {
      return true;
    }
    for (int index = 0; index < subsectionIndex; index++) {
      if (courtSubstepStatus(courtId, sectionIndex, index) !=
          StepStatus.complete) {
        return false;
      }
    }
    return true;
  }

  bool _isCurrentFutsalSubstep(int sectionIndex, int subsectionIndex) {
    return !state.isInCourtCategory &&
        currentSectionIndex == sectionIndex &&
        currentSubstepIndex == subsectionIndex;
  }

  bool _isCurrentCourtSubstep(
    String courtId,
    int sectionIndex,
    int subsectionIndex,
  ) {
    return state.isInCourtCategory &&
        state.activeCourtId == courtId &&
        currentSectionIndex == sectionIndex &&
        currentSubstepIndex == subsectionIndex;
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
    if (state.isRestoringDraft) return;

    final int snapshotRevision = _revision;
    final VendorOnboardingState snapshot = state;

    if (showSavingState) {
      emit(snapshot.copyWith(saveStatus: DraftSaveStatus.saving));
    }

    try {
      await _draftRepository.save(snapshot);
      if (_revision == snapshotRevision) {
        emit(
          state.copyWith(
            saveStatus: DraftSaveStatus.saved,
            lastSavedAt: DateTime.now(),
            isDirty: false,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          saveStatus: DraftSaveStatus.failure,
          errorMessage: 'Draft save failed. Try again.',
          errorOrigin: VendorErrorOrigin.local,
        ),
      );
    }
  }

  void _scheduleDraftSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(
      const Duration(milliseconds: 700),
      () => unawaited(_saveDraft(showSavingState: false)),
    );
  }

  VendorOnboardingState _normalizeState(VendorOnboardingState input) {
    final FutsalDraft normalizedFutsal = input.futsal.copyWith(
      slug: input.futsal.slug.trim().isEmpty
          ? _buildFutsalSlug(
              title: input.futsal.title,
              currentSlug: input.futsal.slug,
            )
          : input.futsal.slug.trim(),
      websiteOrSocialLink: input.futsal.websiteOrSocialLink.trim(),
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

  CourtDraft? _courtById(String courtId) {
    for (final CourtDraft court in state.courts) {
      if (court.id == courtId) return court;
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
    final String path = file.path ?? file.name;
    if (path.trim().isEmpty) return null;
    return UploadRef(name: file.name, localPath: path);
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
      for (final UploadRef item in current) item.localPath: item,
    };
    for (final UploadRef item in additions) {
      byPath[item.localPath] = item;
    }
    return byPath.values.toList();
  }

  bool _haveSameUploadPaths(List<UploadRef> left, List<UploadRef> right) {
    if (identical(left, right)) return true;
    if (left.length != right.length) return false;

    final Set<String> leftPaths = left
        .map((UploadRef item) => item.localPath)
        .toSet();
    final Set<String> rightPaths = right
        .map((UploadRef item) => item.localPath)
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
