import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

extension VendorOnboardingApiPayload on VendorOnboardingState {
  Map<String, dynamic> toFutsalBody({
    int? mainStep,
    int? subStep,
    int? futsalId,
    bool currentSubstepOnly = false,
  }) {
    final int resolvedMainStep = mainStep ?? futsalPointer.sectionIndex;
    final int resolvedSubStep = subStep ?? futsalPointer.subsectionIndex;

    final Map<String, dynamic> body = <String, dynamic>{
      'main_step': resolvedMainStep,
      'sub_step': resolvedSubStep,
    };

    if (currentSubstepOnly) {
      body.addAll(
        _futsalSubstepBody(futsal, resolvedMainStep, resolvedSubStep),
      );
      body['package_id'] = _selectedPackageId(futsal);
    } else {
      body.addAll(_fullFutsalBody(futsal));
    }

    if (futsalId != null) {
      body['venue_id'] = futsalId;
    }

    return body;
  }

  Map<String, dynamic> toCreateFutsalBody({int? mainStep, int? subStep}) =>
      toFutsalBody(mainStep: mainStep, subStep: subStep);

  Map<String, dynamic> toCourtBody({
    required CourtDraft court,
    int? mainStep,
    int? subStep,
    int? futsalId,
    bool currentSubstepOnly = false,
  }) {
    final int resolvedMainStep = mainStep ?? cursor.sectionIndex;
    final int resolvedSubStep = subStep ?? cursor.subsectionIndex;

    final Map<String, dynamic> body = <String, dynamic>{
      'main_step': resolvedMainStep,
      'sub_step': resolvedSubStep,
    };

    if (futsalId != null) {
      body['venue_id'] = futsalId;
    }

    if (court.remoteId != null) {
      body['court_id'] = court.remoteId;
    }

    if (currentSubstepOnly) {
      body.addAll(_courtSubstepBody(court, resolvedMainStep, resolvedSubStep));
    } else {
      body.addAll(_fullCourtBody(court));
    }

    return body;
  }
}

Map<String, dynamic> _futsalSubstepBody(
  FutsalDraft futsal,
  int mainStep,
  int subStep,
) {
  switch (mainStep) {
    case 0:
      switch (subStep) {
        case 0:
          return <String, dynamic>{
            'futsal_name': futsal.title.trim(),
            'registration_number': futsal.registrationNumber.trim(),
            'phone_number': futsal.phone.trim(),
            'email_address': futsal.email.trim(),
            'social_link': futsal.websiteOrSocialLink.trim(),
          };
        case 1:
          return <String, dynamic>{'description': futsal.description.trim()};
        case 2:
          return <String, dynamic>{
            'address': futsal.location.fullAddress.trim(),
            'exact_address': futsal.location.exactLocation.trim(),
            'latitude': _formatCoordinate(futsal.location.latitude),
            'longitude': _formatCoordinate(futsal.location.longitude),
          };
      }
    case 1:
      switch (subStep) {
        case 0:
          return <String, dynamic>{
            'cancellation_policy': futsal.cancellationPolicy.trim(),
          };
        case 1:
          return <String, dynamic>{'futsal_rules': futsal.futsalRules.trim()};
        case 2:
          return <String, dynamic>{'package_id': _selectedPackageId(futsal)};
      }
    case 2:
      switch (subStep) {
        case 0:
          return <String, dynamic>{'cover_image_id': _coverImageId(futsal)};
        case 1:
          return <String, dynamic>{
            'gallery_image_ids': _galleryImageIds(futsal),
          };
        case 2:
          return <String, dynamic>{
            'company_document_ids': _companyDocumentIds(futsal),
          };
      }
  }

  return _fullFutsalBody(futsal);
}

Map<String, dynamic> _fullFutsalBody(FutsalDraft futsal) {
  return <String, dynamic>{
    'futsal_name': futsal.title.trim(),
    'registration_number': futsal.registrationNumber.trim(),
    'phone_number': futsal.phone.trim(),
    'email_address': futsal.email.trim(),
    'social_link': futsal.websiteOrSocialLink.trim(),
    'description': futsal.description.trim(),
    'address': futsal.location.fullAddress.trim(),
    'exact_address': futsal.location.exactLocation.trim(),
    'latitude': _formatCoordinate(futsal.location.latitude),
    'longitude': _formatCoordinate(futsal.location.longitude),
    'cancellation_policy': futsal.cancellationPolicy.trim(),
    'futsal_rules': futsal.futsalRules.trim(),
    'package_id': _selectedPackageId(futsal),
    'cover_image_id': _coverImageId(futsal),
    'gallery_image_ids': _galleryImageIds(futsal),
    'company_document_ids': _companyDocumentIds(futsal),
  };
}

String _formatCoordinate(double? value) {
  if (value == null) return '';
  return value.toStringAsFixed(7);
}

int? _coverImageId(FutsalDraft futsal) {
  return futsal.selectedCoverImage?.id ?? futsal.coverImage?.id;
}

List<int> _galleryImageIds(FutsalDraft futsal) {
  final List<int> selectedIds = futsal.selectedGalleryImages
      .where((SelectedImageRef item) => item.id != null)
      .map((SelectedImageRef item) => item.id!)
      .toList();

  if (selectedIds.isNotEmpty) {
    return selectedIds;
  }

  return futsal.gallery
      .where((UploadRef item) => item.id != null)
      .map((UploadRef item) => item.id!)
      .toList();
}

List<int> _companyDocumentIds(FutsalDraft futsal) {
  return futsal.companyDocuments
      .where((UploadRef item) => item.id != null)
      .map((UploadRef item) => item.id!)
      .toList();
}

Map<String, dynamic> _courtSubstepBody(
  CourtDraft court,
  int mainStep,
  int subStep,
) {
  switch (mainStep) {
    case 0:
      switch (subStep) {
        case 0:
          return <String, dynamic>{
            'court_name': court.name.trim(),
            'base_price': court.basePrice,
            'court_type': _courtTypeId(court),
            'match_format': _matchFormatId(court),
            'max_player': court.maxPlayers,
          };
        case 1:
          return <String, dynamic>{'description': court.description.trim()};
        case 2:
          return <String, dynamic>{
            'court_photo_ids': _uploadIds(court.photos),
            'memory_ids': _uploadIds(court.memories),
          };
      }
    case 1:
      switch (subStep) {
        case 0:
          return <String, dynamic>{
            'advance_payment_required': court.advancePaymentRequired,
            'advance_payment_type': court.advancePaymentType?.apiValue,
            'advance_price': court.advancePrice,
          };
        case 1:
          return <String, dynamic>{'payment_qr_id': court.paymentQr?.id};
      }
    case 2:
      switch (subStep) {
        case 0:
          return <String, dynamic>{'amenity_ids': court.amenities.toList()};
        case 1:
          return <String, dynamic>{'facility_ids': court.facilities.toList()};
      }
      return <String, dynamic>{
        'amenity_ids': court.amenities.toList(),
        'facility_ids': court.facilities.toList(),
      };
    case 3:
      switch (subStep) {
        case 0:
          return <String, dynamic>{
            'weekend_days': court.weekendDays.toList(),
            'holiday_dates': court.holidayDates.toList(),
            'closed_dates': _closedDateBodies(court.closedDates),
          };
        case 1:
          return <String, dynamic>{'slots': _slotBodies(court.slotConfigs)};
        case 2:
          return <String, dynamic>{'slots': _slotBodies(court.slotConfigs)};
      }
  }

  return _fullCourtBody(court);
}

Map<String, dynamic> _fullCourtBody(CourtDraft court) {
  return <String, dynamic>{
    'court_name': court.name.trim(),
    'base_price': court.basePrice,
    'court_type': _courtTypeId(court),
    'match_format': _matchFormatId(court),
    'max_player': court.maxPlayers,
    'description': court.description.trim(),
    'court_photo_ids': _uploadIds(court.photos),
    'memory_ids': _uploadIds(court.memories),
    'advance_payment_required': court.advancePaymentRequired,
    'advance_payment_type': court.advancePaymentType?.apiValue,
    'advance_price': court.advancePrice,
    'payment_qr_id': court.paymentQr?.id,
    'amenity_ids': court.amenities.toList(),
    'facility_ids': court.facilities.toList(),
    'weekend_days': court.weekendDays.toList(),
    'holiday_dates': court.holidayDates.toList(),
    'closed_dates': _closedDateBodies(court.closedDates),
    'slots': _slotBodies(court.slotConfigs),
  };
}

List<int> _uploadIds(List<UploadRef> uploads) {
  return uploads
      .where((UploadRef item) => item.id != null)
      .map((UploadRef item) => item.id!)
      .toList();
}

int? _courtTypeId(CourtDraft court) {
  return court.courtTypeId ?? int.tryParse(court.courtType?.trim() ?? '');
}

int? _matchFormatId(CourtDraft court) {
  return court.matchFormatId ?? int.tryParse(court.matchFormat?.trim() ?? '');
}

List<Map<String, dynamic>> _closedDateBodies(List<ClosedDateDraft> dates) {
  return dates
      .map(
        (ClosedDateDraft item) => <String, dynamic>{
          'date': item.date,
          'is_full_day': item.isFullDay,
          'start_time': item.startTime,
          'end_time': item.endTime,
        },
      )
      .toList();
}

List<Map<String, dynamic>> _slotBodies(List<SlotPricingDraft> slots) {
  return slots
      .map(
        (SlotPricingDraft item) => <String, dynamic>{
          'label': item.label.trim(),
          'days': item.days.toList(),
          'start_time': item.startTime,
          'end_time': item.endTime,
          'price': item.price,
          'weekend_price': item.weekendPrice,
          'holiday_price': item.holidayPrice,
          'custom_date_prices': item.customDatePrices
              .map(
                (SlotCustomDatePriceDraft custom) => <String, dynamic>{
                  'date': custom.date,
                  'price': custom.price,
                },
              )
              .toList(),
          'discount_price': item.discountPrice,
          'discount_type': item.discountType,
          'payment_percent': item.paymentPercent,
        },
      )
      .toList();
}

int? _selectedPackageId(FutsalDraft futsal) {
  return futsal.packageId ??
      _packageIdFromPercent(futsal.commissionPercent) ??
      1;
}

int? _packageIdFromPercent(double? percent) {
  if (percent == null) return null;
  final int rounded = percent.round();
  switch (rounded) {
    case 10:
      return 1;
    case 30:
      return 2;
    default:
      return null;
  }
}
