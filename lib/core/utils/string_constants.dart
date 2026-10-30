import 'package:hamro_futsal/core/l10n/app_locale_controller.dart';
import 'package:hamro_futsal/core/l10n/generated/app_localizations.dart';

/// Every piece of user-facing copy in the app.
///
/// The text itself lives in the ARB files under `lib/core/l10n/arb`
/// (`app_en.arb` is the source of truth; `app_ne.arb` and `app_hi.arb` are
/// its translations). Members resolve against the language chosen in
/// Settings → Language, so they are getters, not `const`.
///
/// To add copy: add the key to all three ARB files, run `flutter gen-l10n`,
/// then expose it here.
final class StringConstants {
  StringConstants._();

  static AppLocalizations get _s => AppLocaleController.instance.strings;

  static String get aboutApp => _s.aboutApp;
  static String get aboutThisCourt => _s.aboutThisCourt;
  static String get accept => _s.accept;
  static String get acceptBooking => _s.acceptBooking;
  static String get rejectBooking => _s.rejectBooking;
  static String get acceptBookingConfirmation => _s.acceptBookingConfirmation;
  static String get approvePaymentProofConfirmation =>
      _s.approvePaymentProofConfirmation;
  static String get rejectBookingConfirmation => _s.rejectBookingConfirmation;
  static String get actualAmount => _s.actualAmount;
  static String get verifiedAmount => _s.verifiedAmount;
  static String get verifiedVenue => _s.verifiedVenue;
  static String get paymentNote => _s.paymentNote;
  static String get rejectionReason => _s.rejectionReason;
  static String get enterValidAmount => _s.enterValidAmount;
  static String get bookingConfirmedToCompleted =>
      _s.bookingConfirmedToCompleted;
  static String get couldNotCompleteBooking => _s.couldNotCompleteBooking;
  static String get bookingAcceptedSuccessfully =>
      _s.bookingAcceptedSuccessfully;
  static String get bookingRejectedSuccessfully =>
      _s.bookingRejectedSuccessfully;
  static String get couldNotAcceptBooking => _s.couldNotAcceptBooking;
  static String get couldNotRejectBooking => _s.couldNotRejectBooking;
  static String get paymentVerifiedSuccessfully =>
      _s.paymentVerifiedSuccessfully;
  static String get paymentRejectedSuccessfully =>
      _s.paymentRejectedSuccessfully;
  static String get couldNotVerifyPayment => _s.couldNotVerifyPayment;
  static String get couldNotRejectPayment => _s.couldNotRejectPayment;
  static String get noPaymentToVerify => _s.noPaymentToVerify;
  static String get acceptWithin => _s.acceptWithin;
  static String get approvePayment => _s.approvePayment;
  static String get createYourTeamFirst => _s.createYourTeamFirst;
  static String get matchConfirmed => _s.matchConfirmed;
  static String get rejectPayment => _s.rejectPayment;
  static String get preferredVenue => _s.preferredVenue;
  static String get rejectionReasonHint => _s.rejectionReasonHint;
  static String get search => _s.search;
  static String get searchVenueToCheckSlots => _s.searchVenueToCheckSlots;
  static String get totalCourtFeeRs => _s.totalCourtFeeRs;
  static String get youNeedATeamToChallengeOpponents =>
      _s.youNeedATeamToChallengeOpponents;
  static String get finalPricingConfirmedByServer =>
      _s.finalPricingConfirmedByServer;
  static String get requestExpiredMessage => _s.requestExpiredMessage;
  static String get invitationNoLongerAvailable =>
      _s.invitationNoLongerAvailable;
  static String get requestJustAcceptedByAnotherTeam =>
      _s.requestJustAcceptedByAnotherTeam;
  static String get submitAndAccept => _s.submitAndAccept;
  static String get whichTeamWillPlay => _s.whichTeamWillPlay;
  static String get yourTeamShare => _s.yourTeamShare;
  static String get account => _s.account;
  static String get financeAndPayouts => _s.financeAndPayouts;
  static String get accountStatement => _s.accountStatement;
  static String get recentActivity => _s.recentActivity;

  static String get credit => _s.credit;
  static String get debit => _s.debit;

  static String get bookingDate => _s.bookingDate;
  static String get recorded => _s.recorded;

  static String get reference => _s.reference;
  static String get bookedOn => _s.bookedOn;
  static String get bookedBy => _s.bookedBy;
  static String get selectClosureDate => _s.selectClosureDate;
  static String get selectClosureStartAndEnd => _s.selectClosureStartAndEnd;
  static String get closureEndAfterStart => _s.closureEndAfterStart;
  static String get loadingBookings => _s.loadingBookings;

  static String get each => _s.each;
  static String get unknownPlayer => _s.unknownPlayer;
  static String get futsalCourt => _s.futsalCourt;

  static String get customerBooking => _s.customerBooking;
  static String get futsalBooking => _s.futsalBooking;
  static String get availableBalance => _s.availableBalance;
  static String get commissionPaid => _s.commissionPaid;
  static String get couldNotParseAccountFromServer =>
      _s.couldNotParseAccountFromServer;
  static String get couldNotSubmitSettlementRequest =>
      _s.couldNotSubmitSettlementRequest;
  static String get pendingClearance => _s.pendingClearance;
  static String get requestSettlement => _s.requestSettlement;
  static String get commissionPayable => _s.commissionPayable;
  static String get payCommission => _s.payCommission;
  static String get commissionSettled => _s.commissionSettled;
  static String get noCommissionDue => _s.noCommissionDue;
  static String get settlementNoteHint => _s.settlementNoteHint;
  static String get settlementRequestSubmitted => _s.settlementRequestSubmitted;
  static String get settlements => _s.settlements;
  static String get settlementAwaitingApproval => _s.settlementAwaitingApproval;
  static String get totalEarned => _s.totalEarned;
  static String get totalSettled => _s.totalSettled;
  static String get active => _s.active;
  static String get courtStatus => _s.courtStatus;
  static String get inactiveCourtsAreHiddenFromPlayers =>
      _s.inactiveCourtsAreHiddenFromPlayers;
  static String get addANewItemToYourRentalInventory =>
      _s.addANewItemToYourRentalInventory;
  static String get addARemarkInvoiceRefEtc => _s.addARemarkInvoiceRefEtc;
  static String get addCourt => _s.addCourt;
  static String get addDate => _s.addDate;
  static String get addEquipment => _s.addEquipment;
  static String get addFirstCourt => _s.addFirstCourt;
  static String get addFutsalCourt => _s.addFutsalCourt;
  static String get addImagesOrFilesToYourLibrary =>
      _s.addImagesOrFilesToYourLibrary;
  static String get addMedia => _s.addMedia;
  static String get addMembers => _s.addMembers;
  static String get addMembersTitle => _s.addMembersTitle;
  static String get addNewCourt => _s.addNewCourt;
  static String get addPlayersWithTheirPositionGoalkeeperDefenderMid3034fc58 =>
      _s.addPlayersWithTheirPositionGoalkeeperDefenderMid3034fc58;
  static String get addSlot => _s.addSlot;
  static String get addVenueLevelGalleryImagesForYourBusinessProfile =>
      _s.addVenueLevelGalleryImagesForYourBusinessProfile;
  static String get addYourFirstCourtAndStartAcceptingBookings =>
      _s.addYourFirstCourtAndStartAcceptingBookings;
  static String get addYourFirstCourtToContinueSetup =>
      _s.addYourFirstCourtToContinueSetup;
  static String get addressAndMapCoordinates => _s.addressAndMapCoordinates;
  static String get addressExactLocationLongitudeAndLatitude =>
      _s.addressExactLocationLongitudeAndLatitude;
  static String get advance => _s.advance;
  static String get advancePayment => _s.advancePayment;
  static String get advancePaymentRequired => _s.advancePaymentRequired;
  static String get advancePaymentRequirementsAndQr =>
      _s.advancePaymentRequirementsAndQr;
  static String get advancePaymentType => _s.advancePaymentType;
  static String get advanceToPay => _s.advanceToPay;
  static String get afternoon => _s.afternoon;
  static String get all => _s.all;
  static String get allDay => _s.allDay;
  static String get allSlots => _s.allSlots;
  static String get allVenues => _s.allVenues;
  static String get allowCancellations => _s.allowCancellations;
  static String get alwaysImproving => _s.alwaysImproving;
  static String get am => _s.am;
  static String get amenities => _s.amenities;
  static String get amenitiesAndFacilities => _s.amenitiesAndFacilities;
  static String get amenitiesAndFeatures => _s.amenitiesAndFeatures;
  static String get analytics => _s.analytics;
  static String get appDisplayLanguage => _s.appDisplayLanguage;
  static String get appTheme => _s.appTheme;
  static String get calendar => _s.calendar;
  static String get chooseCalendar => _s.chooseCalendar;
  static String get englishCalendar => _s.englishCalendar;
  static String get nepaliCalendar => _s.nepaliCalendar;
  static String get nepaliDateScript => _s.nepaliDateScript;
  static String get nepaliDateScriptSubtitle => _s.nepaliDateScriptSubtitle;
  static String get apply => _s.apply;
  static String get applyFilter => _s.applyFilter;
  static String get applyFilters => _s.applyFilters;
  static String get approved => _s.approved;
  static String get archive => _s.archive;
  static const String
  areYouSureYouWantToDeleteThisSlotThisActionCannotBeUndone =
      'Are you sure you want to delete this slot? This action cannot be undone.';
  static String get areaLandmarkOrStreetName => _s.areaLandmarkOrStreetName;
  static String get ascending => _s.ascending;
  static String get attachFiles => _s.attachFiles;
  static String get autoFilled => _s.autoFilled;
  static String get autoGenerateFromFutsalName => _s.autoGenerateFromFutsalName;
  static String get availabilityCheckFailed => _s.availabilityCheckFailed;
  static String get available => _s.available;
  static String get availableCourts => _s.availableCourts;
  static String get availableOffers => _s.availableOffers;
  static String get avgDay => _s.avgDay;
  static String get back => _s.back;
  static String get backgroundColor => _s.backgroundColor;
  static String get balanceDueLater => _s.balanceDueLater;
  static String get balanceDue => _s.balanceDue;
  static String get paidAmount => _s.paidAmount;
  static String get settlement => _s.settlement;
  static String get requestedAmount => _s.requestedAmount;
  static String get stillClearing => _s.stillClearing;
  static String get requestedOn => _s.requestedOn;
  static String get paidOn => _s.paidOn;
  static String get updatedOn => _s.updatedOn;
  static String get maximumPayable => _s.maximumPayable;
  static String get singleVenue => _s.singleVenue;
  static String get viewPaymentProof => _s.viewPaymentProof;
  static String get viewProof => _s.viewProof;
  static String get approvedAmount => _s.approvedAmount;
  static String get txnShort => _s.txnShort;
  static String get transactionReferenceCopied => _s.transactionReferenceCopied;
  static String get balancedPackageForActiveFutsalOperations =>
      _s.balancedPackageForActiveFutsalOperations;
  static String get basePrice => _s.basePrice;
  static String get basic => _s.basic;
  static String get basicInfo => _s.basicInfo;
  static String get basicInformation => _s.basicInformation;
  static String get basicPrice => _s.basicPrice;
  static String get bestForASingleVenueGettingOnline =>
      _s.bestForASingleVenueGettingOnline;
  static String get biometricLogin => _s.biometricLogin;
  static String get block => _s.block;
  static String get bold => _s.bold;
  static String get bookCourtsManageMatchesAndKeepYourFutsalPlansMov11f51a89 =>
      _s.bookCourtsManageMatchesAndKeepYourFutsalPlansMov11f51a89;
  static String get bookNow => _s.bookNow;
  static String get bookingCompleted => _s.bookingCompleted;
  static String get bookingCompletedMessage => _s.bookingCompletedMessage;
  static String get booked => _s.booked;
  static String get bookedVia => _s.bookedVia;
  static String get booking => _s.booking;
  static String get manualBooking => _s.manualBooking;
  static String get bookingTypeManual => _s.bookingTypeManual;
  static String get bookingTypeOnline => _s.bookingTypeOnline;
  static String get bookingUnitSuffix => _s.bookingUnitSuffix;
  static String get bookingAlerts => _s.bookingAlerts;
  static String get bookingAndCancellationTerms =>
      _s.bookingAndCancellationTerms;
  static String get bookingAndPayment => _s.bookingAndPayment;
  static String get bookingAndPaymentTitle => _s.bookingAndPaymentTitle;
  static String get bookingDetails => _s.bookingDetails;
  static String get bookingFee => _s.bookingFee;
  static String get bookingId => _s.bookingId;
  static String get bookingOverview => _s.bookingOverview;
  static String get bookingPolicies => _s.bookingPolicies;
  static String get bookingRequestSent => _s.bookingRequestSent;
  static String get bookings => _s.bookings;
  static String get bookingsRemainOpenAndHolidayPricingCanApply =>
      _s.bookingsRemainOpenAndHolidayPricingCanApply;
  static String get branding => _s.branding;
  static String get brandingAndReview => _s.brandingAndReview;
  static String get bulletList => _s.bulletList;
  static String get business => _s.business;
  static String get businessAndRegistration => _s.businessAndRegistration;
  static String get businessAssets => _s.businessAssets;
  static String get calculatingPrice => _s.calculatingPrice;
  static String get call => _s.call;
  static String get camera => _s.camera;
  static String get canWeRescheduleTonightSBooking =>
      _s.canWeRescheduleTonightSBooking;
  static String get cancel => _s.cancel;
  static String get okay => _s.okay;
  static String get cancelBooking => _s.cancelBooking;
  static String get cancelBookingConfirmation => _s.cancelBookingConfirmation;
  static String get keepBooking => _s.keepBooking;
  static String get bookingCancelledSuccessfully =>
      _s.bookingCancelledSuccessfully;
  static String get couldNotCancelBooking => _s.couldNotCancelBooking;
  static String get cancelled => _s.cancelled;
  static String get decline => _s.decline;
  static String get groupInvitation => _s.groupInvitation;
  static String get groupInvitationPrompt => _s.groupInvitationPrompt;

  static String get categories => _s.categories;
  static String get cats => _s.cats;
  static String get change => _s.change;
  static String get changeImage => _s.changeImage;
  static String get changePassword => _s.changePassword;
  static String get changePhoto => _s.changePhoto;
  static String get changeServicePlan => _s.changeServicePlan;
  static String get changeServicePlanConfirmation =>
      _s.changeServicePlanConfirmation;
  static String get charge => _s.charge;
  static String get chargePerUnitPerHour => _s.chargePerUnitPerHour;
  static String get chat => _s.chat;
  static String get chatWithCustomer => _s.chatWithCustomer;
  static String get chatWithHost => _s.chatWithHost;
  static String get messageHost => _s.messageHost;
  static String get chatWithVenue => _s.chatWithVenue;
  static String get cannotChatWithYourself => _s.cannotChatWithYourself;
  static String get checkYourConnectionAndTryAgain =>
      _s.checkYourConnectionAndTryAgain;
  static String get checkYourInboxAndSpamFolder =>
      _s.checkYourInboxAndSpamFolder;
  static String get chooseASavedImageOrUploadANewOne =>
      _s.chooseASavedImageOrUploadANewOne;
  static String get chooseFile => _s.chooseFile;
  static String get choosePackage => _s.choosePackage;
  static String get chooseThePackageThatMatchesYourCurrentStageAndOp2398b90f =>
      _s.chooseThePackageThatMatchesYourCurrentStageAndOp2398b90f;
  static String get chooseVenue => _s.chooseVenue;
  static String get chooseYourPlan => _s.chooseYourPlan;
  static String get clear => _s.clear;
  static String get clearAll => _s.clearAll;
  static String get clearFormat => _s.clearFormat;
  static String get clearInfoWhenYouNeedIt => _s.clearInfoWhenYouNeedIt;
  static String get clearSearch => _s.clearSearch;
  static String get close => _s.close;
  static String get closeAFullDayOrOnlyASpecificHourRange =>
      _s.closeAFullDayOrOnlyASpecificHourRange;
  static String get closedAcceptWindowExpired => _s.closedAcceptWindowExpired;
  static String get closedDate => _s.closedDate;
  static String get closedDates => _s.closedDates;
  static String get code => _s.code;
  static String get collectNow => _s.collectNow;
  static String get collectPaymentOrDepositBeforeABookingIsConfirmed =>
      _s.collectPaymentOrDepositBeforeABookingIsConfirmed;
  static String get commissionPackageAndPlatformSupportDetails =>
      _s.commissionPackageAndPlatformSupportDetails;
  static String get commissions => _s.commissions;
  static String get companyDocs => _s.companyDocs;
  static String get companyDocuments => _s.companyDocuments;
  static String get completeCourtDetails => _s.completeCourtDetails;
  static String get completeTheRequiredDetails => _s.completeTheRequiredDetails;
  static String get completed => _s.completed;
  static String get configureDateAndTimeSlots => _s.configureDateAndTimeSlots;
  static String get confirm => _s.confirm;
  static String get confirmBooking => _s.confirmBooking;
  static String get confirmed => _s.confirmed;
  static String get connectThisGroupToAVenue => _s.connectThisGroupToAVenue;
  static String get connected => _s.connected;
  static String get continueWithApple => _s.continueWithApple;
  static String get continueWithGoogle => _s.continueWithGoogle;
  static String get conversationSettings => _s.conversationSettings;
  static String get coordinates => _s.coordinates;
  static String get notProvided => _s.notProvided;
  static String get viewProfile => _s.viewProfile;
  static String get couldNotApplyTheCouponPleaseTryAgain =>
      _s.couldNotApplyTheCouponPleaseTryAgain;
  static String get couldNotCheckAvailabilityPleaseTryAgain =>
      _s.couldNotCheckAvailabilityPleaseTryAgain;
  static String get couldNotGetAppleCredentialsPleaseTryAgain =>
      _s.couldNotGetAppleCredentialsPleaseTryAgain;
  static String get couldNotGetGoogleCredentialsPleaseTryAgain =>
      _s.couldNotGetGoogleCredentialsPleaseTryAgain;
  static String get couldNotHoldThisSlotPleaseTryAgain =>
      _s.couldNotHoldThisSlotPleaseTryAgain;
  static String get couldNotIdentifyThisCourt => _s.couldNotIdentifyThisCourt;
  static String get couldNotLoadBookings => _s.couldNotLoadBookings;
  static String get exportBookings => _s.exportBookings;
  static String get exportingBookings => _s.exportingBookings;
  static String get couldNotExportBookings => _s.couldNotExportBookings;
  static String get noBookingsToExport => _s.noBookingsToExport;
  static String get exportedBookings => _s.exportedBookings;
  static String get exportDownloadedTitle => _s.exportDownloadedTitle;
  static String get exportReadyToView => _s.exportReadyToView;
  static String get viewExport => _s.viewExport;
  static String get exportSavedInDownloads => _s.exportSavedInDownloads;
  static String get exportSavedInFiles => _s.exportSavedInFiles;
  static String get couldNotOpenExport => _s.couldNotOpenExport;
  static String get shareFile => _s.shareFile;
  static String get couldNotLoadCategories => _s.couldNotLoadCategories;
  static String get couldNotLoadSavedAuthenticationDetails =>
      _s.couldNotLoadSavedAuthenticationDetails;
  static String get couldNotLoadVenues => _s.couldNotLoadVenues;
  static String get couldNotParseAmenitiesAndFacilitiesFromServer =>
      _s.couldNotParseAmenitiesAndFacilitiesFromServer;
  static String get couldNotParseAmenitiesFromServer =>
      _s.couldNotParseAmenitiesFromServer;
  static String get couldNotParseAvailableCourtsFromServer =>
      _s.couldNotParseAvailableCourtsFromServer;
  static String get couldNotParseBookingDetailsFromServer =>
      _s.couldNotParseBookingDetailsFromServer;
  static String get couldNotParseBookingsFromServer =>
      _s.couldNotParseBookingsFromServer;
  static String get couldNotParseCategoryFiltersFromServer =>
      _s.couldNotParseCategoryFiltersFromServer;
  static String get couldNotParseCouponsFromServer =>
      _s.couldNotParseCouponsFromServer;
  static String get couldNotParseMobileBannersFromServer =>
      _s.couldNotParseMobileBannersFromServer;
  static String get couldNotParseNotificationsFromServer =>
      _s.couldNotParseNotificationsFromServer;
  static String get couldNotLoadNotifications => _s.couldNotLoadNotifications;
  static String get couldNotParseCourtDetailsFromServer =>
      _s.couldNotParseCourtDetailsFromServer;
  static String get couldNotParseCourtTypesFromServer =>
      _s.couldNotParseCourtTypesFromServer;
  static String get couldNotParseCreatedMediaItemsFromServer =>
      _s.couldNotParseCreatedMediaItemsFromServer;
  static String get couldNotParseExpenseCategoriesFromServer =>
      _s.couldNotParseExpenseCategoriesFromServer;
  static String get couldNotParseExpensesFromServer =>
      _s.couldNotParseExpensesFromServer;
  static String get couldNotParseFacilitiesFromServer =>
      _s.couldNotParseFacilitiesFromServer;
  static String get couldNotParseFaqsFromServer =>
      _s.couldNotParseFaqsFromServer;
  static String get couldNotParseFutsalBookingsFromServer =>
      _s.couldNotParseFutsalBookingsFromServer;
  static String get couldNotParseHelpTopicsFromServer =>
      _s.couldNotParseHelpTopicsFromServer;
  static String get couldNotParseHostDetailsFromServer =>
      _s.couldNotParseHostDetailsFromServer;
  static String get couldNotParseMatchFormatsFromServer =>
      _s.couldNotParseMatchFormatsFromServer;
  static String get couldNotParseMediaListFromServer =>
      _s.couldNotParseMediaListFromServer;
  static String get couldNotParseReviewsFromServer =>
      _s.couldNotParseReviewsFromServer;
  static String get couldNotParsePaymentQrFromServer =>
      _s.couldNotParsePaymentQrFromServer;
  static String get couldNotParsePublicPackagesFromServer =>
      _s.couldNotParsePublicPackagesFromServer;
  static String get couldNotParsePublicServicesFromServer =>
      _s.couldNotParsePublicServicesFromServer;
  static String get couldNotParsePublicTemplatesFromServer =>
      _s.couldNotParsePublicTemplatesFromServer;
  static String get couldNotParseVenueCourtsFromServer =>
      _s.couldNotParseVenueCourtsFromServer;
  static String get couldNotParseVenueDescriptionFromServer =>
      _s.couldNotParseVenueDescriptionFromServer;
  static String get couldNotParseVenueSlotsFromServer =>
      _s.couldNotParseVenueSlotsFromServer;
  static String get couldNotParseVenuesAndCourtsFromServer =>
      _s.couldNotParseVenuesAndCourtsFromServer;
  static String get couldNotParseVenuesFromServer =>
      _s.couldNotParseVenuesFromServer;
  static String get couldNotParseYourWishlistFromServer =>
      _s.couldNotParseYourWishlistFromServer;
  static String get couldNotSaveTheExpense => _s.couldNotSaveTheExpense;
  static String get couldNotSendOtpPleaseTryAgain =>
      _s.couldNotSendOtpPleaseTryAgain;

  static String get otpSentSuccessfully => _s.otpSentSuccessfully;
  static String get createNewPassword => _s.createNewPassword;
  static String get codeVerifiedChooseANewPassword =>
      _s.codeVerifiedChooseANewPassword;
  static String get court => _s.court;
  static String get couldNotParsePrefix => _s.couldNotParsePrefix;
  static String get courtActions => _s.courtActions;
  static String get courtIdentityDescriptionPhotosAndMemories =>
      _s.courtIdentityDescriptionPhotosAndMemories;
  static String get courtIdentityPricingTypeAndPlayingFormat =>
      _s.courtIdentityPricingTypeAndPlayingFormat;
  static String get courtInfo => _s.courtInfo;
  static String get courtInformation => _s.courtInformation;
  static String get courtName => _s.courtName;
  static String get courtNotFound => _s.courtNotFound;
  static String get courtPhotos => _s.courtPhotos;
  static String get courtPhotosAndMemories => _s.courtPhotosAndMemories;
  static String get courtPhotosAndMemoriesLabel =>
      _s.courtPhotosAndMemoriesLabel;
  static String get courtRules => _s.courtRules;
  static String get courtSetup => _s.courtSetup;
  static String get courtSpecificAmenitiesAndFacilities =>
      _s.courtSpecificAmenitiesAndFacilities;
  static String get courtSpecificAmenitiesForThisCourt =>
      _s.courtSpecificAmenitiesForThisCourt;
  static String get courtType => _s.courtType;
  static String get courtTypeSentenceCase => _s.courtTypeSentenceCase;
  static String get courts => _s.courts;
  static String get coverImage => _s.coverImage;
  static String get coverImageSentenceCase => _s.coverImageSentenceCase;
  static String get coverMediaGalleryAndBusinessDocuments =>
      _s.coverMediaGalleryAndBusinessDocuments;
  static String get createGroup => _s.createGroup;
  static String get createReusableBookingSlotsWithDaysAndTimes =>
      _s.createReusableBookingSlotsWithDaysAndTimes;
  static String get createShopPayload => _s.createShopPayload;
  static String get createTeam => _s.createTeam;
  static String get customDatePrice => _s.customDatePrice;
  static String get customDatePrices => _s.customDatePrices;
  static String get customRange => _s.customRange;
  static String get date => _s.date;
  static String get dateOfBirth => _s.dateOfBirth;
  static String get dateOrder => _s.dateOrder;
  static String get defineBookingRulesPaymentsAndVenueHousePolicies =>
      _s.defineBookingRulesPaymentsAndVenueHousePolicies;
  static String get delete => _s.delete;
  static String get deleteAccount => _s.deleteAccount;
  static String get deleteAccountPrompt => _s.deleteAccountPrompt;
  static String get deleteAccountWarning => _s.deleteAccountWarning;
  static String get deleteAccountLosesProfile => _s.deleteAccountLosesProfile;
  static String get deleteAccountLosesBookings => _s.deleteAccountLosesBookings;
  static String get deleteAccountLosesTeams => _s.deleteAccountLosesTeams;
  static String get deleteAccountConfirmationWord =>
      _s.deleteAccountConfirmationWord;
  static String get deleteAccountSubtitle => _s.deleteAccountSubtitle;
  static String get deleteAccountReason => _s.deleteAccountReason;
  static String get deleteAccountReasonHint => _s.deleteAccountReasonHint;
  static String get deleteAccountReasonRequired =>
      _s.deleteAccountReasonRequired;
  static String get accountDeleted => _s.accountDeleted;
  static String get deletingAccount => _s.deletingAccount;
  static String get deleteCourt => _s.deleteCourt;
  static String get deleteCourtPrompt => _s.deleteCourtPrompt;
  static String get deleteFile => _s.deleteFile;
  static String get deleteFutsal => _s.deleteFutsal;
  static String get deleteMessage => _s.deleteMessage;
  static String get deleteMessageAction => _s.deleteMessageAction;
  static String get deleteSlot => _s.deleteSlot;
  static String get deleteTeam => _s.deleteTeam;
  static String get deposit => _s.deposit;
  static String get depositRefundable => _s.depositRefundable;
  static String get descending => _s.descending;
  static String get describeYourCancellationAndRefundPolicy =>
      _s.describeYourCancellationAndRefundPolicy;
  static String get describeYourFutsalFacilitiesAndWhatMakesItSpecial =>
      _s.describeYourFutsalFacilitiesAndWhatMakesItSpecial;
  static String get description => _s.description;
  static String get descriptionAboutYourCourt => _s.descriptionAboutYourCourt;
  static String get descriptionAboutYourFutsal => _s.descriptionAboutYourFutsal;
  static String get designedAroundTheWayLocalPlayersActuallyBook =>
      _s.designedAroundTheWayLocalPlayersActuallyBook;
  static String get digitalProductsForModernSportsBusinesses =>
      _s.digitalProductsForModernSportsBusinesses;
  static String get directions => _s.directions;
  static String get discount => _s.discount;
  static String get discountType => _s.discountType;
  static String get discounts => _s.discounts;
  static String get document => _s.document;
  static String get documentMustBeSmallerThan10Mb =>
      _s.documentMustBeSmallerThan10Mb;
  static String get done => _s.done;
  static String get dragToReorderFirstImageIsTheCover =>
      _s.dragToReorderFirstImageIsTheCover;
  static String get eGCourtAMainField => _s.eGCourtAMainField;
  static String get eGFootballSize5 => _s.eGFootballSize5;
  static String get eGMorningSlot => _s.eGMorningSlot;
  static String get eGTurfRepairMonthlyRent => _s.eGTurfRepairMonthlyRent;
  static String get eGWeekendFutsalTeam => _s.eGWeekendFutsalTeam;
  static String get edit => _s.edit;
  static String get edited => _s.edited;
  static String get elite => _s.elite;
  static String get emailAddress => _s.emailAddress;
  static String get enableUsersToCancelConfirmedBookingsBeforeMatchDay =>
      _s.enableUsersToCancelConfirmedBookingsBeforeMatchDay;
  static String get endTime => _s.endTime;
  static String get enterCouponCode => _s.enterCouponCode;
  static String get enterCurrentPassword => _s.enterCurrentPassword;
  static String get enterFutsalClubName => _s.enterFutsalClubName;
  static String get enterFutsalRegistrationNumber =>
      _s.enterFutsalRegistrationNumber;
  static String get enterNewPassword => _s.enterNewPassword;
  static String get enterVenueId => _s.enterVenueId;
  static String get enterYourAddress => _s.enterYourAddress;
  static String get enterYourCurrentPasswordAndChooseANewOne =>
      _s.enterYourCurrentPasswordAndChooseANewOne;
  static String get enterYourEmailAndWeWillSendYouAnOtpCode =>
      _s.enterYourEmailAndWeWillSendYouAnOtpCode;
  static String get enterYourFullName => _s.enterYourFullName;
  static String get enterYourPassword => _s.enterYourPassword;
  static String get entries => _s.entries;
  static String get establishedYear => _s.establishedYear;
  static String get evening => _s.evening;
  static String get exactLocation => _s.exactLocation;
  static String get exactLocationSentenceCase => _s.exactLocationSentenceCase;
  static String get exampleNonMarkingShoesOnlyReport15MinutesEarlyNo3d1a39a7 =>
      _s.exampleNonMarkingShoesOnlyReport15MinutesEarlyNo3d1a39a7;
  static String get expenseDate => _s.expenseDate;
  static String get expenseNotFound => _s.expenseNotFound;
  static String get expenses => _s.expenses;
  static String get facilities => _s.facilities;
  static String get faqs => _s.faqs;
  static String get fastBooking => _s.fastBooking;
  static String get features => _s.features;
  static String get fetchingYourSavedMediaFromTheServer =>
      _s.fetchingYourSavedMediaFromTheServer;
  static String get file => _s.file;
  static String get filterByDate => _s.filterByDate;
  static String get filterLibrary => _s.filterLibrary;
  static String get filtersAndSorting => _s.filtersAndSorting;
  static String get flat => _s.flat;
  static String get forPremiumVenuesAndMultiCourtOperators =>
      _s.forPremiumVenuesAndMultiCourtOperators;
  static String get forgotPassword => _s.forgotPassword;
  static String get forgotPasswordPrompt => _s.forgotPasswordPrompt;
  static String get fromDate => _s.fromDate;
  static String get fromServerSuffix => _s.fromServerSuffix;
  static String get fullDay => _s.fullDay;
  static String get futsal => _s.futsal;
  static String get futsalAddress => _s.futsalAddress;
  static String get futsalBookingSimplified => _s.futsalBookingSimplified;
  static String get futsalBookings => _s.futsalBookings;
  static String get futsalClubName => _s.futsalClubName;
  static String get futsalGmailCom => _s.futsalGmailCom;
  static String get futsalInformation => _s.futsalInformation;
  static String get futsalName => _s.futsalName;
  static String get futsalPortfolio => _s.futsalPortfolio;
  static String get futsalRules => _s.futsalRules;
  static String get futsalSteps => _s.futsalSteps;
  static String get gallery => _s.gallery;
  static String get general => _s.general;
  static String get goBack => _s.goBack;
  static String get appleSignInFailedPleaseTryAgain =>
      _s.appleSignInFailedPleaseTryAgain;
  static String get appleSignInIsNotAvailableOnThisDevice =>
      _s.appleSignInIsNotAvailableOnThisDevice;
  static String get googleSignInFailedPleaseTryAgain =>
      _s.googleSignInFailedPleaseTryAgain;
  static String get googleSignInIsNotConfiguredMissingGoogleServerClientId =>
      _s.googleSignInIsNotConfiguredMissingGoogleServerClientId;
  static String get group => _s.group;
  static String get growth => _s.growth;
  static String get hamroFutsal => _s.hamroFutsal;
  static String get hamroFutsalIsBuiltToMakeLocalFutsalEasierForPl2dfd0648 =>
      _s.hamroFutsalIsBuiltToMakeLocalFutsalEasierForPl2dfd0648;
  static String get hamroFutsalArena => _s.hamroFutsalArena;
  static String get hamroFutsalArenaSlugExample =>
      _s.hamroFutsalArenaSlugExample;
  static String get hamroFutsalV100 => _s.hamroFutsalV100;
  static String get handOverEquipmentAndStartARentalTimer =>
      _s.handOverEquipmentAndStartARentalTimer;
  static String get helloHamrofutsalCom => _s.helloHamrofutsalCom;
  static String get helloSirGoodMorning => _s.helloSirGoodMorning;
  static String get help => _s.help;
  static String get helpAndFaq => _s.helpAndFaq;
  static String get videos => _s.videos;
  static String get helpAndSupport => _s.helpAndSupport;
  static String get helpfulSupport => _s.helpfulSupport;
  static String get feedback => _s.feedback;
  static String get feedbackTitle => _s.feedbackTitle;
  static String get feedbackSubtitle => _s.feedbackSubtitle;
  static String get feedbackType => _s.feedbackType;
  static String get feedbackCategory => _s.feedbackCategory;
  static String get feedbackMessage => _s.feedbackMessage;
  static String get feedbackContact => _s.feedbackContact;
  static String get feedbackSuccess => _s.feedbackSuccess;
  static String get feedbackPlatform => _s.feedbackPlatform;
  static String get feedbackServices => _s.feedbackServices;
  static String get feedbackBoth => _s.feedbackBoth;
  static String get feedbackBug => _s.feedbackBug;
  static String get feedbackSuggestion => _s.feedbackSuggestion;
  static String get feedbackPraise => _s.feedbackPraise;
  static String get submitFeedback => _s.submitFeedback;
  static String get feedbackHelpNote => _s.feedbackHelpNote;
  static String get highlightTheServicesAndOnSiteFacilitiesYourVenueOffers =>
      _s.highlightTheServicesAndOnSiteFacilitiesYourVenueOffers;
  static String get highlightWhatYourFutsalOffers =>
      _s.highlightWhatYourFutsalOffers;
  static String get holidayDates => _s.holidayDates;
  static String get holidayPrice => _s.holidayPrice;
  static String get home => _s.home;
  static String get hostedBy => _s.hostedBy;
  static String get hour => _s.hour;
  static String get hourLowercase => _s.hourLowercase;
  static String get perHourSuffix => _s.perHourSuffix;
  static String get hourly => _s.hourly;
  static String get hoursPlayed => _s.hoursPlayed;
  static String get houseRulesForPlayersAndBookings =>
      _s.houseRulesForPlayersAndBookings;
  static String get howRefundsAndCancellationsAreHandled =>
      _s.howRefundsAndCancellationsAreHandled;
  static String get iAgreeToTheTermsAndPrivacyPolicy =>
      _s.iAgreeToTheTermsAndPrivacyPolicy;
  static String get iConfirmTheBookingDetailsAreCorrectAndAcceptTheCabab03b =>
      _s.iConfirmTheBookingDetailsAreCorrectAndAcceptTheCabab03b;
  static String get iSawTheFutsalSlotYouPostedYesterday =>
      _s.iSawTheFutsalSlotYouPostedYesterday;
  static String get image => _s.image;
  static String get importantNote => _s.importantNote;
  static String get inactive => _s.inactive;
  static String get information => _s.information;
  static String get insert => _s.insert;
  static String get insertLink => _s.insertLink;
  static String get invalidAuthenticationResponseFromServer =>
      _s.invalidAuthenticationResponseFromServer;
  static String get invalidCreateFutsalResponseFromServer =>
      _s.invalidCreateFutsalResponseFromServer;
  static String get invalidProfileResponseFromServer =>
      _s.invalidProfileResponseFromServer;
  static String get italic => _s.italic;
  static String get jpgPngOrPdfUpTo10Mb => _s.jpgPngOrPdfUpTo10Mb;
  static String get jpgOrPngUpTo10Mb => _s.jpgOrPngUpTo10Mb;
  static String get kathmandu => _s.kathmandu;
  static String get keepYourAccountSecure => _s.keepYourAccountSecure;
  static String get language => _s.language;
  static String get latitude => _s.latitude;
  static String get legalAndSupportingCompanyDocuments =>
      _s.legalAndSupportingCompanyDocuments;
  static String get didntReceiveCode => _s.didntReceiveCode;
  static String get link => _s.link;
  static String get linkCopiedToClipboard => _s.linkCopiedToClipboard;
  static String get listYourFutsalHouseRulesForPlayers =>
      _s.listYourFutsalHouseRulesForPlayers;
  static String get loadingAvailableCoupons => _s.loadingAvailableCoupons;
  static String get loadingCategories => _s.loadingCategories;
  static String get loadingMediaLibrary => _s.loadingMediaLibrary;
  static String get location => _s.location;
  static String get locationDetails => _s.locationDetails;
  static String get locationUnavailable => _s.locationUnavailable;
  static String get lockedWhileUnderReviewThisSelectionCannotBeChanged =>
      _s.lockedWhileUnderReviewThisSelectionCannotBeChanged;
  static String get logo => _s.logo;
  static String get logoutFailedPleaseTryAgain => _s.logoutFailedPleaseTryAgain;
  static String get logoutSuccessful => _s.logoutSuccessful;
  static String get passwordUpdatedPleaseLogIn => _s.passwordUpdatedPleaseLogIn;
  static String get longitude => _s.longitude;
  static String get lookingForAFriendlyCompetitiveFutsalMatch =>
      _s.lookingForAFriendlyCompetitiveFutsalMatch;
  static String get loserCoversTheLargerShareSettleTheAmountAfterThe2a150fda =>
      _s.loserCoversTheLargerShareSettleTheAmountAfterThe2a150fda;
  static String get loserPays => _s.loserPays;
  static String get madeForFutsal => _s.madeForFutsal;
  static String get manageBookingAndPaymentSettings =>
      _s.manageBookingAndPaymentSettings;
  static String get manageCourt => _s.manageCourt;
  static String get manageCourtsInCompactView => _s.manageCourtsInCompactView;
  static String get manageFutsal => _s.manageFutsal;
  static String get margin => _s.margin;
  static String get markReturned => _s.markReturned;
  static const String
  markThePhysicalVenueFacilitiesAvailableForTeamsAndVisitors =
      'Mark the physical venue facilities available for teams and visitors.';
  static String get markWeekendDaysHolidayDatesAndClosedDates =>
      _s.markWeekendDaysHolidayDatesAndClosedDates;
  static String get matchDate => _s.matchDate;
  static String get matchFormat => _s.matchFormat;
  static String get matchTime => _s.matchTime;
  static String get matchReady => _s.matchReady;
  static String get matchType => _s.matchType;
  static String get matchesTheBackendSchemaYouShared =>
      _s.matchesTheBackendSchemaYouShared;
  static String get maxPlayers => _s.maxPlayers;
  static String get members => _s.members;
  static String get memories => _s.memories;
  static const String
  mentionEquipmentQualitySeatingCapacityOrAnyPremiumServices =
      'Mention equipment quality, seating capacity, or any premium services.';
  static String get message => _s.message;
  static String get messages => _s.messages;
  static String get minute => _s.minute;
  static String get morning => _s.morning;
  static String get myBookings => _s.myBookings;
  static String get myTeams => _s.myTeams;
  static String get nameBasePriceAndCourtType => _s.nameBasePriceAndCourtType;
  static String get nameExampleCom => _s.nameExampleCom;
  static String get nameFutsalCom => _s.nameFutsalCom;
  static String get nepal => _s.nepal;
  static String get netProfit => _s.netProfit;
  static String get netRevenue => _s.netRevenue;
  static String get newCourt => _s.newCourt;
  static String get newExpense => _s.newExpense;
  static String get newFutsal => _s.newFutsal;
  static String get newRental => _s.newRental;
  static String get newRequest => _s.newRequest;

  static String get completeRequest => _s.completeRequest;

  static String get completeSetup => _s.completeSetup;
  static String get newTeam => _s.newTeam;
  static String get showPlayers => _s.showPlayers;
  static String get hidePlayers => _s.hidePlayers;
  static String get newToday => _s.newToday;
  static String get noAmenitiesInThisCategory => _s.noAmenitiesInThisCategory;
  static String get noAmenitiesInformationAvailableYet =>
      _s.noAmenitiesInformationAvailableYet;
  static String get noBookingPolicyAddedYet => _s.noBookingPolicyAddedYet;
  static String get noClosedDatesAdded => _s.noClosedDatesAdded;
  static String get noCourtActivity => _s.noCourtActivity;
  static String get noCourtTypesAvailable => _s.noCourtTypesAvailable;
  static String get noCourtsAddedYet => _s.noCourtsAddedYet;
  static String get noCourtsAvailable => _s.noCourtsAvailable;
  static String get openingVenue => _s.openingVenue;
  static String get couldNotOpenThisLink => _s.couldNotOpenThisLink;
  static String get venueNotAvailable => _s.venueNotAvailable;
  static String get thisVenueIsNoLongerListed => _s.thisVenueIsNoLongerListed;
  static String get browseVenues => _s.browseVenues;
  static String get pageNotFound => _s.pageNotFound;
  static String get thatLinkDoesNotOpenAnythingInTheApp =>
      _s.thatLinkDoesNotOpenAnythingInTheApp;
  static String get allCourtsBookedOrUnavailable =>
      _s.allCourtsBookedOrUnavailable;
  static String get selectedDatesCourtsAreAlreadyBookedOrUnavai0f4a71b2 =>
      _s.selectedDatesCourtsAreAlreadyBookedOrUnavai0f4a71b2;
  static String get noCourtsYet => _s.noCourtsYet;
  static String get noCustomerActivity => _s.noCustomerActivity;
  static String get noDescriptionAvailableForThisCourtYet =>
      _s.noDescriptionAvailableForThisCourtYet;
  static String get noEquipmentYet => _s.noEquipmentYet;
  static String get noExpensesRecordedForThisRange =>
      _s.noExpensesRecordedForThisRange;
  static String get noFavouritesYet => _s.noFavouritesYet;
  static String get noHolidayDatesAdded => _s.noHolidayDatesAdded;
  static String get noMatchingMembers => _s.noMatchingMembers;
  static String get noMatchFormatsAvailable => _s.noMatchFormatsAvailable;
  static String get noMatchingVenues => _s.noMatchingVenues;
  static String get noMediaFound => _s.noMediaFound;
  static String get noMembersAvailable => _s.noMembersAvailable;
  static String get noMembersFound => _s.noMembersFound;
  static String get noMessagesYet => _s.noMessagesYet;
  static String get noRecentBookings => _s.noRecentBookings;
  static String get noRulesListedYet => _s.noRulesListedYet;
  static String get noSlotConfigurationAddedYetAddASlotToDefineTheBo243e88c0 =>
      _s.noSlotConfigurationAddedYetAddASlotToDefineTheBo243e88c0;
  static String get noSlotsFound => _s.noSlotsFound;
  static String get noTeamsYet => _s.noTeamsYet;
  static String get noTimeSlotsAreAvailableForThisDate =>
      _s.noTimeSlotsAreAvailableForThisDate;
  static String get noTrendYet => _s.noTrendYet;
  static String get noUploadsYet => _s.noUploadsYet;
  static String get noVenueActivity => _s.noVenueActivity;
  static String get noVenuesFound => _s.noVenuesFound;
  static String get note => _s.note;
  static String get notes => _s.notes;
  static String get nothingToBreakDown => _s.nothingToBreakDown;
  static String get notifications => _s.notifications;
  static String get notifyMeWhenSomeoneWantsToPlay =>
      _s.notifyMeWhenSomeoneWantsToPlay;
  static String get npr => _s.npr;
  static String get numberedList => _s.numberedList;
  static String get occasionalOffersAndUpdatesByEmail =>
      _s.occasionalOffersAndUpdatesByEmail;
  static String get occupancy => _s.occupancy;
  static String get offerRefundsWhenCancellationsMeetYourVenuePolicy =>
      _s.offerRefundsWhenCancellationsMeetYourVenuePolicy;
  static String get ohYesPleaseSendYourBookingDetails =>
      _s.ohYesPleaseSendYourBookingDetails;
  static String get onRent => _s.onRent;
  static String get documentUploadRequirements => _s.documentUploadRequirements;
  static String get openInMaps => _s.openInMaps;
  static String get openstreetmap => _s.openstreetmap;
  static String get operationalPhotosForThisSpecificCourt =>
      _s.operationalPhotosForThisSpecificCourt;
  static String get opponentMatch => _s.opponentMatch;
  static String get opponentRequests => _s.opponentRequests;
  static String get opponentTeam => _s.opponentTeam;
  static String get optionalPricesForOneOffDates =>
      _s.optionalPricesForOneOffDates;
  static String get optionalVenue => _s.optionalVenue;
  static String get optionalVisualIdentityAndFinalConfirmation =>
      _s.optionalVisualIdentityAndFinalConfirmation;
  static String get or => _s.or;
  static String get orProvideADirectImageUrl => _s.orProvideADirectImageUrl;
  static String get organizeGamesWithLessEffort =>
      _s.organizeGamesWithLessEffort;
  static String get otpVerification => _s.otpVerification;
  static String get otpVerificationFailedPleaseTryAgain =>
      _s.otpVerificationFailedPleaseTryAgain;
  static String get overview => _s.overview;
  static String get overviewAndImportantDetails =>
      _s.overviewAndImportantDetails;
  static String get package => _s.package;
  static String get paidVia => _s.paidVia;
  static String get panLicenseRegistrationEtc => _s.panLicenseRegistrationEtc;
  static String get participants => _s.participants;
  static String get payNowAdvance => _s.payNowAdvance;
  static String get payableNow => _s.payableNow;
  static String get payment => _s.payment;
  static String get paymentMethod => _s.paymentMethod;
  static String get paymentProof => _s.paymentProof;
  static String get paymentQr => _s.paymentQr;
  static String get paymentStatus => _s.paymentStatus;
  static String get pending => _s.pending;
  static String get percentage => _s.percentage;
  static String get personalDetails => _s.personalDetails;
  static String get phoneNumber => _s.phoneNumber;
  static String get photosAndMemories => _s.photosAndMemories;
  static String get pickDatesAndSlotsQuickly => _s.pickDatesAndSlotsQuickly;
  static String get pickExactLocation => _s.pickExactLocation;
  static String get pickFrom => _s.pickFrom;
  static String get pickCorrectedFileToReplacePrefix =>
      _s.pickCorrectedFileToReplacePrefix;
  static String get pickTheOperationalPackageThatFitsYourBusiness =>
      _s.pickTheOperationalPackageThatFitsYourBusiness;
  static String get platformCommissionAndCommercialTerms =>
      _s.platformCommissionAndCommercialTerms;
  static String get playerFacingFacilitiesForThisCourt =>
      _s.playerFacingFacilitiesForThisCourt;
  static String get playerOptions => _s.playerOptions;
  static String get players => _s.players;
  static String get pleaseConfirmTheDetailsBeforeBooking =>
      _s.pleaseConfirmTheDetailsBeforeBooking;
  static String get pleaseShareTheLocationPinOnceAgain =>
      _s.pleaseShareTheLocationPinOnceAgain;
  static String get pm => _s.pm;
  static String get pngJpgJpegWebp => _s.pngJpgJpegWebp;
  static String get policies => _s.policies;
  static String get policyAndRules => _s.policyAndRules;
  static String get popular => _s.popular;
  static String get preferences => _s.preferences;
  static String get price => _s.price;
  static String get priceBreakdown => _s.priceBreakdown;
  static String get priceRange => _s.priceRange;
  static String get pricingOperationalDetailsAndRegistrationInformation =>
      _s.pricingOperationalDetailsAndRegistrationInformation;
  static String get primaryBusinessThumbnailForTheFutsalListing =>
      _s.primaryBusinessThumbnailForTheFutsalListing;
  static String get primaryFutsalCoverImage => _s.primaryFutsalCoverImage;
  static String get privacyFirst => _s.privacyFirst;
  static String get profile => _s.profile;
  static String get profilePhoto => _s.profilePhoto;
  static String get profileUpdatedSuccessfully => _s.profileUpdatedSuccessfully;
  static String get promotionalEmails => _s.promotionalEmails;
  static String get proof => _s.proof;
  static String get publicIdentityAndContactDetailsOfYourFutsal =>
      _s.publicIdentityAndContactDetailsOfYourFutsal;
  static String get purpose => _s.purpose;
  static String get pushNotifications => _s.pushNotifications;
  static String get qrCodeUsedForAdvancePayment =>
      _s.qrCodeUsedForAdvancePayment;
  static String get qrUnavailable => _s.qrUnavailable;
  static String get quote => _s.quote;
  static String get rankings => _s.rankings;
  static String get rating => _s.rating;
  static String get reEnterNewPassword => _s.reEnterNewPassword;
  static String get reEnterYourPassword => _s.reEnterYourPassword;
  static String get receiveUpdatesOnThisDevice => _s.receiveUpdatesOnThisDevice;
  static String get recentBookings => _s.recentBookings;
  static String get recentSearches => _s.recentSearches;
  static String get recommended => _s.recommended;
  static String get records => _s.records;
  static String get recurrence => _s.recurrence;
  static String get recurringBooking => _s.recurringBooking;
  static String get repeatOn => _s.repeatOn;
  static String get repeatFor => _s.repeatFor;
  static String get recurringPriceDetails => _s.recurringPriceDetails;
  static String get redo => _s.redo;
  static String get refundCancellationAndCustomerBookingGuidelines =>
      _s.refundCancellationAndCustomerBookingGuidelines;
  static String get refundCancellationPolicy => _s.refundCancellationPolicy;
  static String get refundCancellationPolicyCompact =>
      _s.refundCancellationPolicyCompact;
  static String get refundCancellationPolicyFutsalRulesAndCommissions =>
      _s.refundCancellationPolicyFutsalRulesAndCommissions;
  static String get refundableSecurityDeposit => _s.refundableSecurityDeposit;
  static String get registrationNumberExample => _s.registrationNumberExample;
  static String get registrationNumber => _s.registrationNumber;
  static String get reject => _s.reject;
  static String get rejected => _s.rejected;
  static String get rememberMe => _s.rememberMe;
  static String get remindersBeforeYourMatchesStart =>
      _s.remindersBeforeYourMatchesStart;
  static String get remove => _s.remove;
  static String get removeFileConfirmationPrefix =>
      _s.removeFileConfirmationPrefix;
  static String get removeDocument => _s.removeDocument;
  static String get removeFromMediaLibrary => _s.removeFromMediaLibrary;
  static String get removePlayer => _s.removePlayer;
  static String get removeRequest => _s.removeRequest;
  static String get removeRequestAction => _s.removeRequestAction;

  static String get requestDeleted => _s.requestDeleted;

  static String get courtFeeNotSetYet => _s.courtFeeNotSetYet;

  static String get requestPublished => _s.requestPublished;
  static String get renameTeam => _s.renameTeam;
  static String get rentalServices => _s.rentalServices;
  static String get renterName => _s.renterName;
  static String get repeats => _s.repeats;
  static String get replaceDocument => _s.replaceDocument;
  static String get replaceThisRejectedDocument =>
      _s.replaceThisRejectedDocument;
  static String get reply => _s.reply;
  static String get requests => _s.requests;
  static String get requireAdvancePayment => _s.requireAdvancePayment;
  static String get requirementAndCollectionAmount =>
      _s.requirementAndCollectionAmount;
  static String get requirementAndCollectionPercentage =>
      _s.requirementAndCollectionPercentage;
  static String get resendOtpFailedPleaseTryAgain =>
      _s.resendOtpFailedPleaseTryAgain;
  static String get resendOtp => _s.resendOtp;
  static String get resetPassword => _s.resetPassword;
  static String get reset => _s.reset;
  static String get resetOnboarding => _s.resetOnboarding;
  static String get resetToDefaultTemplate => _s.resetToDefaultTemplate;
  static String get resolving => _s.resolving;
  static String get response => _s.response;
  static String get retry => _s.retry;
  static String get revenue => _s.revenue;
  static String get reviewFacilitiesBeforeBooking =>
      _s.reviewFacilitiesBeforeBooking;
  static String get reviewYourBooking => _s.reviewYourBooking;
  static String get viewDetails => _s.viewDetails;
  static String get reviews => _s.reviews;
  static String get requestEdit => _s.requestEdit;
  static String get requestDelete => _s.requestDelete;
  static String get requestEditTitle => _s.requestEditTitle;
  static String get requestDeleteTitle => _s.requestDeleteTitle;
  static String get requestEditSubtitle => _s.requestEditSubtitle;
  static String get requestDeleteSubtitle => _s.requestDeleteSubtitle;
  static String get reason => _s.reason;
  static String get updatedReview => _s.updatedReview;
  static String get updatedReviewHint => _s.updatedReviewHint;
  static String get updatedReviewRequired => _s.updatedReviewRequired;
  static String get reasonHint => _s.reasonHint;
  static String get reasonRequired => _s.reasonRequired;
  static String get submitRequest => _s.submitRequest;
  static String get reviewRequestSubmitted => _s.reviewRequestSubmitted;
  static String get rs1200 => _s.rs1200;
  static String get rulesToFollowAtThisVenue => _s.rulesToFollowAtThisVenue;
  static String get save => _s.save;
  static String get saveChanges => _s.saveChanges;
  static String get saveEquipment => _s.saveEquipment;
  static String get savePricing => _s.savePricing;
  static String get sayHelloAndStartTheConversation =>
      _s.sayHelloAndStartTheConversation;
  static const String
  searchAnAddressOrTapDirectlyOnTheMapToPinTheFutsalLocation =
      'Search an address or tap directly on the map to pin the futsal location.';
  static String get searchByNameOrEmail => _s.searchByNameOrEmail;
  static String get searchConversations => _s.searchConversations;
  static String get searchVenuesCourtsOrLocation =>
      _s.searchVenuesCourtsOrLocation;
  static String get select => _s.select;
  static String get selectACategory => _s.selectACategory;
  static String get selectACourt => _s.selectACourt;
  static String get selectATimeSlotToSeePrices => _s.selectATimeSlotToSeePrices;
  static String get selectAVenue => _s.selectAVenue;
  static String get selectDate => _s.selectDate;
  static String get selectDateAndTime => _s.selectDateAndTime;
  static String get selectMatchDateTime => _s.selectMatchDateTime;
  static String get selectDateOfBirth => _s.selectDateOfBirth;
  static String get selectEquipment => _s.selectEquipment;
  static String get selectEquipmentType => _s.selectEquipmentType;
  static String get selectGender => _s.selectGender;
  static String get selectPlayerOrVendor => _s.selectPlayerOrVendor;
  static String get selectStatus => _s.selectStatus;
  static String get selectTheValueAddedServicesPlayersCanExpectOnBookingDays =>
      _s.selectTheValueAddedServicesPlayersCanExpectOnBookingDays;
  static String get selectTime => _s.selectTime;
  static String get selectYourTeam => _s.selectYourTeam;
  static String get selected => _s.selected;
  static String get selectedLocation => _s.selectedLocation;
  static String get sendOpponentRequest => _s.sendOpponentRequest;
  static String get setDefaultWeekendHolidayAndDiscountPrices =>
      _s.setDefaultWeekendHolidayAndDiscountPrices;
  static String get settings => _s.settings;
  static String get shareCurrentLocation => _s.shareCurrentLocation;
  static String get shareIsNotAvailableForThisVenue =>
      _s.shareIsNotAvailableForThisVenue;
  static String get signOut => _s.signOut;
  static String get slotLabel => _s.slotLabel;
  static String get slotPricing => _s.slotPricing;
  static String get slotSchedule => _s.slotSchedule;
  static String get slotsAndPayments => _s.slotsAndPayments;
  static String get slotsUnavailable => _s.slotsUnavailable;
  static String get slug => _s.slug;
  static String get somethingWentWrong => _s.somethingWentWrong;
  static String get venueSlugMissing => _s.venueSlugMissing;
  static String get specialDaysForPricingAndBookingAvailability =>
      _s.specialDaysForPricingAndBookingAvailability;
  static String get standard => _s.standard;
  static String get start => _s.start;
  static String get startAConversationFirstThenCreateAGroupFromIt =>
      _s.startAConversationFirstThenCreateAGroupFromIt;
  static String get startRental => _s.startRental;
  static String get startTime => _s.startTime;
  static String get started => _s.started;
  static String get starter => _s.starter;
  static String get status => _s.status;
  static String get statusMix => _s.statusMix;
  static String get stepBreakdown => _s.stepBreakdown;
  static String get storeSettings => _s.storeSettings;
  static String get streetCityArea => _s.streetCityArea;
  static String get strikethrough => _s.strikethrough;
  static String get subtotal => _s.subtotal;
  static String get support => _s.support;
  static String get supportRefunds => _s.supportRefunds;
  static String get chooseHowTheAppLooks => _s.chooseHowTheAppLooks;
  static String get tapTheHeartOnAVenueToSaveItHereForQuickBooking =>
      _s.tapTheHeartOnAVenueToSaveItHereForQuickBooking;
  static String get tapToPickLocationOnMap => _s.tapToPickLocationOnMap;
  static String get tapToPickOnMap => _s.tapToPickOnMap;
  static String get tapToUploadShopLogo => _s.tapToUploadShopLogo;
  static String get tax => _s.tax;
  static String get teamOptions => _s.teamOptions;
  static String get tellCustomersAboutThisCourt =>
      _s.tellCustomersAboutThisCourt;
  static String get tellCustomersAboutThisCourtSubtitle =>
      _s.tellCustomersAboutThisCourtSubtitle;
  static String get tellCustomersAboutYourFutsal =>
      _s.tellCustomersAboutYourFutsal;
  static String get tellCustomersAboutYourFutsalSubtitle =>
      _s.tellCustomersAboutYourFutsalSubtitle;
  static String get text10Steps => _s.text10Steps;
  static String get text5v5 => _s.text5v5;
  static String get text97798xxxxxxxx => _s.text97798xxxxxxxx;
  static String get text98xxxxxxxx => _s.text98xxxxxxxx;
  static String get text9xxXxxxxxx => _s.text9xxXxxxxxx;
  static String get textColor => _s.textColor;
  static String get thanksIWillConfirmTheTeamShortly =>
      _s.thanksIWillConfirmTheTeamShortly;
  static String get thereAreNoFutsalVenuesToShowRightNow =>
      _s.thereAreNoFutsalVenuesToShowRightNow;
  static String get thereAreNoNewPeopleAvailableToAddInThisGroup =>
      _s.thereAreNoNewPeopleAvailableToAddInThisGroup;
  static String get thisDocumentIsLockedWhileUnderReviewItCanBeRepla3c137b54 =>
      _s.thisDocumentIsLockedWhileUnderReviewItCanBeRepla3c137b54;
  static String get thisDocumentWasRejectedPleaseRemoveItAndAddANewC30fa5f11 =>
      _s.thisDocumentWasRejectedPleaseRemoveItAndAddANewC30fa5f11;
  static String get thisMessageWillBePermanentlyRemovedFromTheConversation =>
      _s.thisMessageWillBePermanentlyRemovedFromTheConversation;
  static String get time => _s.time;
  static String get timeSlots => _s.timeSlots;
  static String get timeSlotsWithPricingAndPaymentOptions =>
      _s.timeSlotsWithPricingAndPaymentOptions;
  static String get titleContactsLocationAmenitiesAndFeatures =>
      _s.titleContactsLocationAmenitiesAndFeatures;
  static String get titlePhoneAndEmail => _s.titlePhoneAndEmail;
  static String get toDate => _s.toDate;
  static String get today => _s.today;
  static String get topCategory => _s.topCategory;
  static String get topVenue => _s.topVenue;
  static String get total => _s.total;
  static String get totalBooking => _s.totalBooking;
  static String get totalBookings => _s.totalBookings;
  static String get totalEarning => _s.totalEarning;
  static String get totalExpenses => _s.totalExpenses;
  static String get totalQuantityInStock => _s.totalQuantityInStock;
  static String get tournamentsEventsOrPromotionalMoments =>
      _s.tournamentsEventsOrPromotionalMoments;
  static String get transactionHistory => _s.transactionHistory;
  static String get trustedVenues => _s.trustedVenues;
  static String get tryAdjustingOrClearingYourFilters =>
      _s.tryAdjustingOrClearingYourFilters;
  static String get tryAgain => _s.tryAgain;
  static String get trySearchingWithAnotherNameOrEmail =>
      _s.trySearchingWithAnotherNameOrEmail;
  static String get typing => _s.typing;
  static String get unableToLoadVenues => _s.unableToLoadVenues;
  static String get unableToLoadBookings => _s.unableToLoadBookings;
  static String get unableToLoadWishlist => _s.unableToLoadWishlist;
  static String get underReview => _s.underReview;
  static String get unarchive => _s.unarchive;
  static String get unblock => _s.unblock;
  static String get unmute => _s.unmute;
  static String get underline => _s.underline;
  static String get undo => _s.undo;
  static String get units => _s.units;
  static String get update => _s.update;
  static String get updatePassword => _s.updatePassword;
  static String get updatePricingForThisSlot => _s.updatePricingForThisSlot;

  static String get offerADiscountOnThisSlot => _s.offerADiscountOnThisSlot;
  static String get discountStarts => _s.discountStarts;
  static String get discountEnds => _s.discountEnds;
  static String get anyTime => _s.anyTime;
  static String get discountEndMustFollowStart => _s.discountEndMustFollowStart;
  static String get discountNeedsTypeAndValue => _s.discountNeedsTypeAndValue;
  static String get discountValueMustBePositive =>
      _s.discountValueMustBePositive;
  static String get discountPercentTooHigh => _s.discountPercentTooHigh;
  static String get upgradeToVendor => _s.upgradeToVendor;
  static String get upload => _s.upload;
  static String get uploadDocument => _s.uploadDocument;
  static String get uploadMedia => _s.uploadMedia;
  static String get uploadPaymentReceipt => _s.uploadPaymentReceipt;
  static String get uploadPhotosAndMemories => _s.uploadPhotosAndMemories;
  static String get uploadRegistrationPanLicenseAndRelatedDocuments =>
      _s.uploadRegistrationPanLicenseAndRelatedDocuments;
  static String get uploadThePrimaryCoverImageForYourFutsalListing =>
      _s.uploadThePrimaryCoverImageForYourFutsalListing;
  static String get uploadTheQrUsedToCollectAdvancePayment =>
      _s.uploadTheQrUsedToCollectAdvancePayment;
  static String get uploadTheQrUsedToCollectAdvancePayments =>
      _s.uploadTheQrUsedToCollectAdvancePayments;
  static String get uploadYourFutsalBusinessMediaAndDocuments =>
      _s.uploadYourFutsalBusinessMediaAndDocuments;
  static String get use8Characters => _s.use8Characters;
  static String get passwordMustDifferFromCurrent =>
      _s.passwordMustDifferFromCurrent;
  static String get useFaceIdOrFingerprintToSignIn =>
      _s.useFaceIdOrFingerprintToSignIn;
  static String get useSeparateCourtMediaToShowConditionLayoutAndEvec64b5 =>
      _s.useSeparateCourtMediaToShowConditionLayoutAndEvec64b5;
  static String get vendor => _s.vendor;
  static String get vendorOnboarding => _s.vendorOnboarding;
  static String get venue => _s.venue;
  static String get venueActions => _s.venueActions;
  static String get venueAmenitiesAndKeyFeatures =>
      _s.venueAmenitiesAndKeyFeatures;
  static String get venueIdIsMissingForCourtAvailability =>
      _s.venueIdIsMissingForCourtAvailability;
  static String get venueIdIsMissingForSlotAvailability =>
      _s.venueIdIsMissingForSlotAvailability;
  static String get venueIdentityAndContactDetails =>
      _s.venueIdentityAndContactDetails;
  static String get venueLevelPhotosForTheListing =>
      _s.venueLevelPhotosForTheListing;
  static String get venueRulesAndPlayerConductDetails =>
      _s.venueRulesAndPlayerConductDetails;
  static String get venues => _s.venues;
  static String get view => _s.view;
  static String get viewAll => _s.viewAll;
  static String get viewFullScreen => _s.viewFullScreen;
  static String get download => _s.download;
  static String get saveQrCode => _s.saveQrCode;
  static String get dontShowAgain => _s.dontShowAgain;
  static String get playerGuides => _s.playerGuides;
  static String get vendorGuides => _s.vendorGuides;
  static String get learnTheBasics => _s.learnTheBasics;
  static String get runYourVenue => _s.runYourVenue;
  static String get playerVideosSubtitle => _s.playerVideosSubtitle;
  static String get vendorVideosSubtitle => _s.vendorVideosSubtitle;
  static String get moreVideos => _s.moreVideos;
  static String get upNext => _s.upNext;
  static String get couldNotLoadVideos => _s.couldNotLoadVideos;
  static String get couldNotParseVideosFromServer =>
      _s.couldNotParseVideosFromServer;
  static String get startHere => _s.startHere;
  static String get noVideosYet => _s.noVideosYet;
  static String get noVideosYetMessage => _s.noVideosYetMessage;
  static String get swipeForMoreQrs => _s.swipeForMoreQrs;
  static String get downloadingAttachment => _s.downloadingAttachment;
  static String get attachmentSaved => _s.attachmentSaved;
  static String get attachmentSavedToGallery => _s.attachmentSavedToGallery;
  static String get attachmentSavedToFiles => _s.attachmentSavedToFiles;
  static String get attachmentSavePermissionDenied =>
      _s.attachmentSavePermissionDenied;
  static String get attachmentDownloadFailed => _s.attachmentDownloadFailed;
  static String get attachmentUnavailable => _s.attachmentUnavailable;
  static String get openAttachment => _s.openAttachment;
  static String get proofIsAFile => _s.proofIsAFile;
  static String get weKeepRefiningTheAppForSmootherPlayPlanning =>
      _s.weKeepRefiningTheAppForSmootherPlayPlanning;
  static String get weWillSendAVerificationCodeToThisEmail =>
      _s.weWillSendAVerificationCodeToThisEmail;
  static String get website => _s.website;
  static String get websiteOrSocialMediaLink => _s.websiteOrSocialMediaLink;
  static String get weekendAndClosures => _s.weekendAndClosures;
  static String get weekendDays => _s.weekendDays;
  static String get weekendHolidayAndDiscountPricing =>
      _s.weekendHolidayAndDiscountPricing;
  static String get weekendHolidaysAndClosures => _s.weekendHolidaysAndClosures;
  static String get weekendPrice => _s.weekendPrice;
  static String get whereDoYouWantToPlay => _s.whereDoYouWantToPlay;
  static String get winnerPays => _s.winnerPays;
  static String get wishlist => _s.wishlist;
  static String get yakStackSolution => _s.yakStackSolution;
  static String get youBlockedThisUserUnblockThemToSendMessages =>
      _s.youBlockedThisUserUnblockThemToSendMessages;
  static String get youCanUseEitherUploadedFileOrLogoUrlOwnerWillBeA12d1d437 =>
      _s.youCanUseEitherUploadedFileOrLogoUrlOwnerWillBeA12d1d437;
  static String get youExampleCom => _s.youExampleCom;
  static String get yourAccountAndBookingInformationStayProtected =>
      _s.yourAccountAndBookingInformationStayProtected;
  static String get yourName => _s.yourName;
  static String get yourTeam => _s.yourTeam;
  static String get yourVenues => _s.yourVenues;
  static String get accountType => _s.accountType;
  static String get address => _s.address;
  static String get amenitiesNotes => _s.amenitiesNotes;
  static String get backToSignIn => _s.backToSignIn;
  static String get basicPriceRequired => _s.basicPriceRequired;
  static String get bookingAdvanceLimitDays => _s.bookingAdvanceLimitDays;
  static String get cancellationWindowHours => _s.cancellationWindowHours;
  static String get category => _s.category;
  static String get city => _s.city;
  static String get confirmNewPassword => _s.confirmNewPassword;
  static String get confirmPassword => _s.confirmPassword;
  static String get contactEmail => _s.contactEmail;
  static String get contactPhone => _s.contactPhone;
  static String get country => _s.country;
  static String get couponCode => _s.couponCode;
  static String get courtNameTitleCase => _s.courtNameTitleCase;
  static String get currentPassword => _s.currentPassword;
  static String get depositNprOptional => _s.depositNprOptional;
  static String get descriptionRequired => _s.descriptionRequired;
  static String get displayName => _s.displayName;
  static String get emailAddressSentenceCase => _s.emailAddressSentenceCase;
  static String get establishedYearRequired => _s.establishedYearRequired;
  static String get exactLocationRequired => _s.exactLocationRequired;
  static String get fullName => _s.fullName;
  static String get fullNameSentenceCase => _s.fullNameSentenceCase;
  static String get futsalNameRequired => _s.futsalNameRequired;
  static String get futsalSlug => _s.futsalSlug;
  static String get gender => _s.gender;
  static String get groupName => _s.groupName;
  static String get hourlyRateNpr => _s.hourlyRateNpr;
  static String get hours => _s.hours;
  static String get hoursLowercase => _s.hoursLowercase;
  static String get houseRules => _s.houseRules;
  static String get item => _s.item;
  static String get name => _s.name;
  static String get newPassword => _s.newPassword;
  static String get aNewCodeIsOnItsWay => _s.aNewCodeIsOnItsWay;
  static String get enterTheDigitCodeToContinue =>
      _s.enterTheDigitCodeToContinue;
  static String get reEnterYourNewPassword => _s.reEnterYourNewPassword;
  static String get wait => _s.wait;
  static String get password => _s.password;
  static String get passwordIsRequired => _s.passwordIsRequired;
  static String get passwordMustBeAtLeast8Characters =>
      _s.passwordMustBeAtLeast8Characters;
  static String get passwordResetSuccessfully => _s.passwordResetSuccessfully;
  static String get passwordsDoNotMatch => _s.passwordsDoNotMatch;
  static String get pleaseConfirmYourNewPassword =>
      _s.pleaseConfirmYourNewPassword;
  static String get phone => _s.phone;
  static String get phoneNumberSentenceCase => _s.phoneNumberSentenceCase;
  static String get quantity => _s.quantity;
  static String get registrationNumberOptional => _s.registrationNumberOptional;
  static String get rememberPassword => _s.rememberPassword;
  static String get searchExactPlace => _s.searchExactPlace;
  static String get searchMembers => _s.searchMembers;
  static String get shopLogoUrl => _s.shopLogoUrl;
  static String get totalUnits => _s.totalUnits;
  static String get type => _s.type;
  static String get url => _s.url;
  static String get cloudinaryImageUrlExample => _s.cloudinaryImageUrlExample;
  static String get hamroFutsalWebsiteUrl => _s.hamroFutsalWebsiteUrl;
  static String get hamroFutsalWebsiteUrlWithTrailingSlash =>
      _s.hamroFutsalWebsiteUrlWithTrailingSlash;
  static String get mute => _s.mute;
  static String get urlExample => _s.urlExample;
  static String get venueId => _s.venueId;
  static String get websiteOptional => _s.websiteOptional;
  static String get bookingConfirmed => _s.bookingConfirmed;
  static String get bookingConfirmedNotification =>
      _s.bookingConfirmedNotification;
  static String get earlier => _s.earlier;
  static String get markAllAsRead => _s.markAllAsRead;
  static String get markAsRead => _s.markAsRead;
  static String get markAsUnread => _s.markAsUnread;
  static String get justNow => _s.justNow;
  static String get matchReminder => _s.matchReminder;
  static String get matchReminderNotification => _s.matchReminderNotification;
  static String get newMessage => _s.newMessage;
  static String get newMessageNotification => _s.newMessageNotification;
  static String get noNotificationsYet => _s.noNotificationsYet;
  static String get noUnreadNotifications => _s.noUnreadNotifications;
  static String get notificationsWillAppearHere =>
      _s.notificationsWillAppearHere;
  static String get oneHourAgo => _s.oneHourAgo;
  static String get opponentRequestNotification =>
      _s.opponentRequestNotification;
  static String get opponentRequestReceived => _s.opponentRequestReceived;
  static String get paymentReceived => _s.paymentReceived;
  static String get paymentReceivedNotification =>
      _s.paymentReceivedNotification;
  static String get twentyMinutesAgo => _s.twentyMinutesAgo;
  static String get twoDaysAgo => _s.twoDaysAgo;
  static String get twoMinutesAgo => _s.twoMinutesAgo;
  static String get unread => _s.unread;
  static String get weekendOffer => _s.weekendOffer;
  static String get weekendOfferNotification => _s.weekendOfferNotification;
  static String get yesChange => _s.yesChange;
  static String get yesterday => _s.yesterday;
  static String get youHaveReadEveryNotification =>
      _s.youHaveReadEveryNotification;
  static String get bookingPaymentsWillAppearHere =>
      _s.bookingPaymentsWillAppearHere;
  static String get futsalEarnings => _s.futsalEarnings;
  static String get moneyPaidForBookings => _s.moneyPaidForBookings;
  static String get moneyReceivedFromBookings => _s.moneyReceivedFromBookings;
  static String get noTransactionsFound => _s.noTransactionsFound;
  static String get noTransactionsYet => _s.noTransactionsYet;
  static String get paid => _s.paid;
  static String get pendingAmount => _s.pendingAmount;
  static String get playerPayments => _s.playerPayments;
  static String get refunded => _s.refunded;
  static String get refunds => _s.refunds;
  static String get searchTransactions => _s.searchTransactions;
  static String get totalEarnings => _s.totalEarnings;
  static String get totalSpent => _s.totalSpent;

  // Transaction history (`GET /auth/transaction-history`).
  static String get couldNotLoadTransactionHistory =>
      _s.couldNotLoadTransactionHistory;
  static String get totalIn => _s.totalIn;
  static String get totalOut => _s.totalOut;
  static String get netAmount => _s.netAmount;
  static String get transactions => _s.transactions;
  static String get allTransactions => _s.allTransactions;
  static String get incoming => _s.incoming;
  static String get outgoing => _s.outgoing;
  static String get commission => _s.commission;
  static String get grossAmount => _s.grossAmount;
  static String get netBalance => _s.netBalance;
  static String get thisWeek => _s.thisWeek;
  static String get thisMonth => _s.thisMonth;
  static String get thisYear => _s.thisYear;
  static String get allTime => _s.allTime;
  static String get dateRange => _s.dateRange;
  static String get direction => _s.direction;
  static String get filters => _s.filters;
  static String get startDate => _s.startDate;
  static String get endDate => _s.endDate;
  static String get showTransactions => _s.showTransactions;
  static String get pickAStartDateHint => _s.pickAStartDateHint;
  static String get pickAnEndDateHint => _s.pickAnEndDateHint;
  static String get transactionsWillAppearHere => _s.transactionsWillAppearHere;
  static String get vendorRequestSubmitted => _s.vendorRequestSubmitted;
  static String get vendorRequestAlreadySubmitted =>
      _s.vendorRequestAlreadySubmitted;

  // Auth brand panel (tablet landscape / desktop layouts only).
  // Generic copy, used on sign-in, forgot-password and OTP where the audience
  // is not yet known.
  static String get authBrandTagline => _s.authBrandTagline;
  static String get authBrandSubline => _s.authBrandSubline;
  static String get authBrandHighlightBook => _s.authBrandHighlightBook;
  static String get authBrandDetailBook => _s.authBrandDetailBook;
  static String get authBrandDetailManage => _s.authBrandDetailManage;
  static String get authBrandDetailPlay => _s.authBrandDetailPlay;
  // Brand panel extras: how it works, feature chips, device strip.
  static String get authHowItWorks => _s.authHowItWorks;
  static String get authStepFindCourt => _s.authStepFindCourt;
  static String get authStepPickSlot => _s.authStepPickSlot;
  static String get authStepPlay => _s.authStepPlay;
  static String get authStepListVenue => _s.authStepListVenue;
  static String get authStepSetSlots => _s.authStepSetSlots;
  static String get authStepGetBooked => _s.authStepGetBooked;
  static String get authAlsoInside => _s.authAlsoInside;
  static String get authFeatureLiveSlots => _s.authFeatureLiveSlots;
  static String get authFeatureOpponents => _s.authFeatureOpponents;
  static String get authFeatureTeamChat => _s.authFeatureTeamChat;
  static String get authFeatureRewards => _s.authFeatureRewards;
  static String get authFeatureNepaliCalendar => _s.authFeatureNepaliCalendar;
  static String get authFeatureWalkIns => _s.authFeatureWalkIns;
  static String get authFeatureExpenses => _s.authFeatureExpenses;
  static String get authFeaturePayouts => _s.authFeaturePayouts;
  static String get authFeatureReports => _s.authFeatureReports;
  static String get authWorksOn => _s.authWorksOn;
  static String get authBrandHighlightManage => _s.authBrandHighlightManage;
  static String get authBrandHighlightPlay => _s.authBrandHighlightPlay;

  // Shown while registering once "Player" is chosen.
  static String get authPlayerHeadline => _s.authPlayerHeadline;
  static String get authPlayerTagline => _s.authPlayerTagline;
  static String get authPlayerHighlightDiscover =>
      _s.authPlayerHighlightDiscover;
  static String get authPlayerHighlightBook => _s.authPlayerHighlightBook;
  static String get authPlayerHighlightCompete => _s.authPlayerHighlightCompete;

  // Shown while registering once "Venue Vendor" is chosen.
  static String get authVendorHeadline => _s.authVendorHeadline;
  static String get authVendorTagline => _s.authVendorTagline;
  static String get authVendorHighlightList => _s.authVendorHighlightList;
  static String get authVendorHighlightAutomate =>
      _s.authVendorHighlightAutomate;
  static String get authVendorHighlightInsights =>
      _s.authVendorHighlightInsights;

  // ── In-app update ──
  static String get updateAvailable => _s.updateAvailable;
  static String get updateRequired => _s.updateRequired;
  static String get whatsNew => _s.whatsNew;
  static String get updateNow => _s.updateNow;
  static String get later => _s.later;
  static String get checkForUpdates => _s.checkForUpdates;
  static String get checkingForUpdates => _s.checkingForUpdates;
  static String get seeIfANewerVersionIsAvailable =>
      _s.seeIfANewerVersionIsAvailable;
  static String get youAreOnTheLatestVersion => _s.youAreOnTheLatestVersion;
  static String get updateCheckFailed => _s.updateCheckFailed;
  static String get couldNotOpenTheStore => _s.couldNotOpenTheStore;
  static String get updateRequiredToContinue => _s.updateRequiredToContinue;
  static String get updateDownloadFailed => _s.updateDownloadFailed;
  static String get updateInstallFailed => _s.updateInstallFailed;
  static String get downloadingUpdate => _s.downloadingUpdate;
  static String get updateDownloaded => _s.updateDownloaded;
  static String get restartToInstall => _s.restartToInstall;
  static String get restartNow => _s.restartNow;
  static String get installingUpdate => _s.installingUpdate;
  static String get updateReadyMessage => _s.updateReadyMessage;
  static String get openStore => _s.openStore;
  static String get openPlayStore => _s.openPlayStore;
  static String get openAppStore => _s.openAppStore;
  static String get newVersionAvailableMessage => _s.newVersionAvailableMessage;
  static String get forcedUpdateMessage => _s.forcedUpdateMessage;
  static String get installedVersion => _s.installedVersion;
  static String get latestVersion => _s.latestVersion;
  static String get downloadSize => _s.downloadSize;
  static String get updateInBackgroundHint => _s.updateInBackgroundHint;

  // Rewards
  static String get rewards => _s.rewards;
  static String get myRewards => _s.myRewards;
  static String get rewardPoints => _s.rewardPoints;
  static String get availablePoints => _s.availablePoints;
  static String get pointsEarned => _s.pointsEarned;
  static String get pointsRedeemed => _s.pointsRedeemed;
  static String get rewardTier => _s.rewardTier;
  static String get rewardHistory => _s.rewardHistory;
  static String get viewAllRewardHistory => _s.viewAllRewardHistory;
  static String get recentRewardActivity => _s.recentRewardActivity;
  static String get generateCoupon => _s.generateCoupon;
  static String get generatingCoupon => _s.generatingCoupon;
  static String get couponGenerated => _s.couponGenerated;
  static String get copyCode => _s.copyCode;
  static String get codeCopied => _s.codeCopied;
  static String get rewardCouponReady => _s.rewardCouponReady;
  static String get rewardProgrammeNote => _s.rewardProgrammeNote;
  static String get noRewardPointsYet => _s.noRewardPointsYet;
  static String get noRewardPointsYetMessage => _s.noRewardPointsYetMessage;
  static String get noRewardHistory => _s.noRewardHistory;
  static String get noRewardHistoryMessage => _s.noRewardHistoryMessage;
  static String get pleaseSelectTimeSlot => _s.pleaseSelectTimeSlot;
  static String get couldNotLoadRewards => _s.couldNotLoadRewards;
  static String get couldNotLoadRewardHistory => _s.couldNotLoadRewardHistory;
  static String get couldNotGenerateRewardCoupon =>
      _s.couldNotGenerateRewardCoupon;
  static String get needMorePointsToRedeem => _s.needMorePointsToRedeem;
  static String get rewardPointsExpiring => _s.rewardPointsExpiring;

  // Create opponent request
  static String get pressBackAgainToLeaveRequest =>
      _s.pressBackAgainToLeaveRequest;

  // Booking checkout
  static String get checkout => _s.checkout;

  static String get transactionId => _s.transactionId;

  static String get paymentDescriptionHint => _s.paymentDescriptionHint;
  static String get paymentDescriptionHelp => _s.paymentDescriptionHelp;
  static String get paymentDescriptionRequired => _s.paymentDescriptionRequired;
  static String get amountDueNow => _s.amountDueNow;
  static String get paymentAndProof => _s.paymentAndProof;
  static String get priceSummary => _s.priceSummary;

  // Group info
  static String get changeGroupName => _s.changeGroupName;
  static String get enterAGroupName => _s.enterAGroupName;
  static String get groupNameTooLong => _s.groupNameTooLong;
  static String get offline => _s.offline;
  static String get about => _s.about;
  static String get groupPhoto => _s.groupPhoto;
  static String get groupInfo => _s.groupInfo;
  static String get blocked => _s.blocked;
  static String get moreOptions => _s.moreOptions;
  static String get leaveGroup => _s.leaveGroup;
  static String get leaveGroupQuestion => _s.leaveGroupQuestion;
  static String get leaveGroupMessage => _s.leaveGroupMessage;
  static String get leaving => _s.leaving;
  static String get you => _s.you;
  static String get groupMembersSectionHint => _s.groupMembersSectionHint;

  // Create group
  static String get unknownUser => _s.unknownUser;
  static String get online => _s.online;
  static String get selectAll => _s.selectAll;
  static String get groupFull => _s.groupFull;
  static String get tapANameToAddOrRemoveThem => _s.tapANameToAddOrRemoveThem;
  static String get nameTheGroupAndChooseWhoIsInIt =>
      _s.nameTheGroupAndChooseWhoIsInIt;
  static String get createGroupAction => _s.createGroupAction;
  static String get groupMemberLimitReached => _s.groupMemberLimitReached;

  // Opponent match
  static String get beginner => _s.beginner;
  static String get intermediate => _s.intermediate;
  static String get advanced => _s.advanced;
  static String get goalkeeper => _s.goalkeeper;
  static String get defender => _s.defender;
  static String get midfielder => _s.midfielder;
  static String get forward => _s.forward;
  static String get goalkeeperAbbr => _s.goalkeeperAbbr;
  static String get defenderAbbr => _s.defenderAbbr;
  static String get midfielderAbbr => _s.midfielderAbbr;
  static String get forwardAbbr => _s.forwardAbbr;
  static String get draft => _s.draft;
  static String get pendingApproval => _s.pendingApproval;
  static String get newLabel => _s.newLabel;
  static String get invitationSent => _s.invitationSent;
  static String get accepted => _s.accepted;
  static String get sent => _s.sent;
  static String get expired => _s.expired;
  static String get awaitingYourPick => _s.awaitingYourPick;
  static String get autoRejected => _s.autoRejected;
  static String get evenSplit => _s.evenSplit;
  static String get customPercent => _s.customPercent;
  static String get byTeam => _s.byTeam;
  static String get byResult => _s.byResult;
  static String get paidInFull => _s.paidInFull;
  static String get awaitingPaymentVerification =>
      _s.awaitingPaymentVerification;
  static String get partiallyPaid => _s.partiallyPaid;
  static String get paymentPending => _s.paymentPending;
  static String get couldNotParseYourTeams => _s.couldNotParseYourTeams;
  static String get invalidTeam => _s.invalidTeam;
  static String get couldNotParseTeam => _s.couldNotParseTeam;
  static String get couldNotParsePlayerPositions =>
      _s.couldNotParsePlayerPositions;
  static String get couldNotParseOpponentLevels =>
      _s.couldNotParseOpponentLevels;
  static String get couldNotReadMatchDetails => _s.couldNotReadMatchDetails;
  static String get couldNotParseMatchDetails => _s.couldNotParseMatchDetails;
  static String get couldNotParseOpponentRequests =>
      _s.couldNotParseOpponentRequests;
  static String get requestCouldNotBeFound => _s.requestCouldNotBeFound;
  static String get couldNotParseOpponentRequest =>
      _s.couldNotParseOpponentRequest;
  static String get teamNameCannotBeEmpty => _s.teamNameCannotBeEmpty;
  static String get playerNameCannotBeEmpty => _s.playerNameCannotBeEmpty;
  static String get invalidMember => _s.invalidMember;
  static String get couldNotParseInvitations => _s.couldNotParseInvitations;
  static String get couldNotParseAcceptedRequest =>
      _s.couldNotParseAcceptedRequest;
  static String get couldNotReadRequestAfterAccepting =>
      _s.couldNotReadRequestAfterAccepting;
  static String get tomorrow => _s.tomorrow;
  static String get conditional => _s.conditional;
  static String get courtFeeNotSetYetMessage => _s.courtFeeNotSetYetMessage;
  static String percentMySide(int percent) => _s.percentMySide(percent);
  static String yourShareOfCourtFee(String share, String total, int percent) =>
      _s.yourShareOfCourtFee(share, total, percent);
  static String loserWinnerShares(
    String loserShare,
    int loserPercent,
    String winnerShare,
  ) => _s.loserWinnerShares(loserShare, loserPercent, winnerShare);
  static String get matchDetailsNotSavedYet => _s.matchDetailsNotSavedYet;
  static String get requestNotOpenedOnServerYet =>
      _s.requestNotOpenedOnServerYet;
  static String get invitationMissingId => _s.invitationMissingId;
  static String get noPlayersYet => _s.noPlayersYet;
  static String playerCount(int count) => _s.playerCount(count);
  static String get addYourFirstPlayer => _s.addYourFirstPlayer;
  static String get addPlayer => _s.addPlayer;
  static String get couldNotLoadVenuesRetry => _s.couldNotLoadVenuesRetry;
  static String noVenuesMatch(String query) => _s.noVenuesMatch(query);
  static String get teamsStillLoading => _s.teamsStillLoading;
  static String get findAnOpponent => _s.findAnOpponent;
  static String get couldNotLoadOpponentRequests =>
      _s.couldNotLoadOpponentRequests;
  static String get couldNotLoadYourTeams => _s.couldNotLoadYourTeams;
  static String get closed => _s.closed;
  static String deleteTeamConfirmation(String teamName) =>
      _s.deleteTeamConfirmation(teamName);
  static String get thisPlayer => _s.thisPlayer;
  static String removePlayerConfirmation(String playerName, String teamName) =>
      _s.removePlayerConfirmation(playerName, teamName);
  static String get createTeamAndAddPlayersHint =>
      _s.createTeamAndAddPlayersHint;
  static String get teamName => _s.teamName;
  static String get editPlayer => _s.editPlayer;
  static String get playerNameHint => _s.playerNameHint;
  static String get playerEmailHint => _s.playerEmailHint;
  static String positionInTeam(String teamName) => _s.positionInTeam(teamName);
  static String get saveChangesTitle => _s.saveChangesTitle;
  static String get selectAnExistingBooking => _s.selectAnExistingBooking;
  static String get existingBookingSheetSubtitle =>
      _s.existingBookingSheetSubtitle;
  static String get existingBookingSearchHint => _s.existingBookingSearchHint;
  static String get couldNotLoadYourBookingsRetry =>
      _s.couldNotLoadYourBookingsRetry;
  static String get noBookingMatchesYourSearch => _s.noBookingMatchesYourSearch;
  static String get noUpcomingBookingsToAttach => _s.noUpcomingBookingsToAttach;
  static String get courtFee => _s.courtFee;
  static String get mySidePays => _s.mySidePays;
  static String get winner => _s.winner;
  static String get opponent => _s.opponent;
  static String get perPlayer => _s.perPlayer;
  static String perPlayerCount(int count) => _s.perPlayerCount(count);
  static String get youPayIfLoser => _s.youPayIfLoser;
  static String get youPay => _s.youPay;
  static String get matchChatNotOpenYet => _s.matchChatNotOpenYet;
  static String get matchDetails => _s.matchDetails;
  static String get matchNoLongerAvailable => _s.matchNoLongerAvailable;
  static String get kickoff => _s.kickoff;
  static String get slot => _s.slot;
  static String get format => _s.format;
  static String get linkedVenueBooking => _s.linkedVenueBooking;
  static String get notSet => _s.notSet;
  static String get venueLinkedToThisMatch => _s.venueLinkedToThisMatch;
  static String get arrangedOutsideTheApp => _s.arrangedOutsideTheApp;
  static String get bookingReference => _s.bookingReference;
  static String get costSplit => _s.costSplit;
  static String get totalCourtFee => _s.totalCourtFee;
  static String get matchChat => _s.matchChat;
  static String get openMatchChat => _s.openMatchChat;
  static String get yourShare => _s.yourShare;
  static String get opponentShare => _s.opponentShare;
  static String get decidedByResult => _s.decidedByResult;
  static String get versusAbbr => _s.versusAbbr;
  static String get matchCreatedChatRoomOpened => _s.matchCreatedChatRoomOpened;
  static String get waitingOnFinalConfirmation => _s.waitingOnFinalConfirmation;
  static String get team => _s.team;
  static String get chatRoomCreatedAutomatically =>
      _s.chatRoomCreatedAutomatically;
  static String get chatOpensOnceOpponentConfirmed =>
      _s.chatOpensOnceOpponentConfirmed;
  static String get matchChatEnabledDescription =>
      _s.matchChatEnabledDescription;
  static String get matchChatPendingDescription =>
      _s.matchChatPendingDescription;
  static String percentInParentheses(int percent) =>
      _s.percentInParentheses(percent);
  static String playTeamQuestion(String teamName) =>
      _s.playTeamQuestion(teamName);
  static String selectOpponentConfirmSolo(String teamName) =>
      _s.selectOpponentConfirmSolo(teamName);
  static String selectOpponentConfirmWithOthers(String teamName, int others) =>
      _s.selectOpponentConfirmWithOthers(teamName, others);
  static String get confirmOpponent => _s.confirmOpponent;
  static String matchConfirmedWithTeam(String teamName) =>
      _s.matchConfirmedWithTeam(teamName);
  static String matchConfirmedWithTeamOthersRejected(
    String teamName,
    int others,
  ) => _s.matchConfirmedWithTeamOthersRejected(teamName, others);
  static String get waitingForInvitationsMessage =>
      _s.waitingForInvitationsMessage;
  static String get selectOneOpponentMessage => _s.selectOneOpponentMessage;
  static String invitationsReceived(int count) => _s.invitationsReceived(count);
  static String totalLoserPaysMore(String total) =>
      _s.totalLoserPaysMore(total);
  static String totalWithYourShare(String total, String share, int percent) =>
      _s.totalWithYourShare(total, share, percent);
  static String theirShare(String share) => _s.theirShare(share);
  static String get loserPaysDecidedByResult => _s.loserPaysDecidedByResult;
  static String ifTheyLose(String amount) => _s.ifTheyLose(amount);
  static String playersCount(int count) => _s.playersCount(count);
  static String answeredAt(String when) => _s.answeredAt(when);
  static String acceptedAt(String when) => _s.acceptedAt(when);
  static String chatWith(String name) => _s.chatWith(name);
  static String get thisTeam => _s.thisTeam;
  static String matchConfirmedWith(String opponent) =>
      _s.matchConfirmedWith(opponent);
  static String confirmingRejectsOthers(int count) =>
      _s.confirmingRejectsOthers(count);
  static String get invitations => _s.invitations;
  static String get requestNoLongerAvailable => _s.requestNoLongerAvailable;
  static String get waitingForInvitations => _s.waitingForInvitations;
  static String get selectOneOpponent => _s.selectOneOpponent;
  static String get noInvitationsYet => _s.noInvitationsYet;
  static String get loadingInvitations => _s.loadingInvitations;
  static String get checkingForNewInvitations => _s.checkingForNewInvitations;
  static String get waitingForTeamsToAccept => _s.waitingForTeamsToAccept;
  static String get pullDownToRefreshInvitations =>
      _s.pullDownToRefreshInvitations;
  static String get viewMatchDetails => _s.viewMatchDetails;
  static String get selectThisOpponent => _s.selectThisOpponent;
  static String teamCreatedSendAcceptance(String teamName) =>
      _s.teamCreatedSendAcceptance(teamName);
  static String get acceptChallengeGuidance => _s.acceptChallengeGuidance;
  static String get confirmSquadSizeBeforeCommit =>
      _s.confirmSquadSizeBeforeCommit;
  static String get needTeamToAcceptChallenge => _s.needTeamToAcceptChallenge;
  static String amountCourtFee(String amount) => _s.amountCourtFee(amount);
  static String feeTheLoserPays(String fee) => _s.feeTheLoserPays(fee);
  static String feeLoseAndYouPay(String fee, String amount) =>
      _s.feeLoseAndYouPay(fee, amount);
  static String feeLoserPaysAmount(String fee, String amount) =>
      _s.feeLoserPaysAmount(fee, amount);
  static String feeYourShare(String fee, String share, int percent) =>
      _s.feeYourShare(fee, share, percent);
  static String amountPerPlayer(String amount) => _s.amountPerPlayer(amount);
  static String get winAndPayNothingSettledAtVenue =>
      _s.winAndPayNothingSettledAtVenue;
  static String rosterTooSmallForFormat(int formatSize) =>
      _s.rosterTooSmallForFormat(formatSize);
  static String get acceptanceReachesRequester => _s.acceptanceReachesRequester;
  static String get theVenue => _s.theVenue;
  static String ifTeamPickedMatchCreatedAt(String venue) =>
      _s.ifTeamPickedMatchCreatedAt(venue);
  static String get somethingWentWrongTryAgain => _s.somethingWentWrongTryAgain;
  static String get requesterCannotBeMessagedYet =>
      _s.requesterCannotBeMessagedYet;
  static String get acceptRequest => _s.acceptRequest;
  static String get acceptanceSentRequesterWillConfirm =>
      _s.acceptanceSentRequesterWillConfirm;
  static String get acceptChallengeNoPaymentNeeded =>
      _s.acceptChallengeNoPaymentNeeded;
  static String get messageToTheRequester => _s.messageToTheRequester;
  static String get anythingOtherCaptainShouldKnow =>
      _s.anythingOtherCaptainShouldKnow;
  static String get sendAcceptance => _s.sendAcceptance;
  static String get requestHasNoContactToMessage =>
      _s.requestHasNoContactToMessage;
  static String get teamNameExampleHint => _s.teamNameExampleHint;
  static String get ifYouLose => _s.ifYouLose;
  static String get settledWithVenueOnMatchDay => _s.settledWithVenueOnMatchDay;
  static String get whatHappensNext => _s.whatHappensNext;
  static String get mayWaitForOtherTeamsThenSelect =>
      _s.mayWaitForOtherTeamsThenSelect;
  static String get reviewInvitation => _s.reviewInvitation;
  static String reviewInvitations(int count) => _s.reviewInvitations(count);
  static String get matchDetailsLower => _s.matchDetailsLower;
  static String get theCostSplit => _s.theCostSplit;
  static String draftNotPublishedFinishStep(String step) =>
      _s.draftNotPublishedFinishStep(step);
  static String removeRequestConfirmation(String teamName) =>
      _s.removeRequestConfirmation(teamName);
  static String courtFeeSplitNotSetYet(String total) =>
      _s.courtFeeSplitNotSetYet(total);
  static String loserPaysTotal(String total) => _s.loserPaysTotal(total);
  static String get decidedByMatchResult => _s.decidedByMatchResult;
  static String loserPaysAmount(String amount) => _s.loserPaysAmount(amount);
  static String amountTotal(String total) => _s.amountTotal(total);
  static String ifLoserTotal(String share, String total) =>
      _s.ifLoserTotal(share, total);
  static String sharePercentOfTotal(String share, int percent, String total) =>
      _s.sharePercentOfTotal(share, percent, total);
  static String opponentNamed(String teamName) => _s.opponentNamed(teamName);
  static String teamsWantToPlayPickOne(int count) =>
      _s.teamsWantToPlayPickOne(count);
  static String get submittedWaitingForApproval =>
      _s.submittedWaitingForApproval;
  static String get acceptanceSentWaitingForPick =>
      _s.acceptanceSentWaitingForPick;
  static String get noInvitationsYetMessage => _s.noInvitationsYetMessage;
  static String get needOpponent => _s.needOpponent;
  static String get myRequests => _s.myRequests;
  static String get couldNotLoadTheseRequests => _s.couldNotLoadTheseRequests;
  static String get awaitingInvitations => _s.awaitingInvitations;
  static String get kickOffTimeNotSetYet => _s.kickOffTimeNotSetYet;
  static String get venueNotChosenYet => _s.venueNotChosenYet;
  static String get viewMatchDetailsTitle => _s.viewMatchDetailsTitle;
  static String get acceptRequestTitle => _s.acceptRequestTitle;
  static String get nothingToActOn => _s.nothingToActOn;
  static String get openRequestsWillAppearHere => _s.openRequestsWillAppearHere;
  static String get noRequestsSent => _s.noRequestsSent;
  static String get noRequestsSentMessage => _s.noRequestsSentMessage;
  static String get noSettledRequests => _s.noSettledRequests;
  static String get noSettledRequestsMessage => _s.noSettledRequestsMessage;
  static String get fillInExternalVenueDetails => _s.fillInExternalVenueDetails;
  static String rsAmount(String amount) => _s.rsAmount(amount);
  static String maxPlayersLabel(Object count) => _s.maxPlayersLabel(count);
  static String get whoPlaysGuidance => _s.whoPlaysGuidance;
  static String get noTeamsYetCreateRequestMessage =>
      _s.noTeamsYetCreateRequestMessage;
  static String get venueAlreadyBookedMessage => _s.venueAlreadyBookedMessage;
  static String get venueBookingConfirmed => _s.venueBookingConfirmed;
  static String get configureCostSplitMessage => _s.configureCostSplitMessage;
  static String get reviewAndPublishMessage => _s.reviewAndPublishMessage;
  static String loserPaysPercent(int percent) => _s.loserPaysPercent(percent);
  static String youPayPercent(int percent) => _s.youPayPercent(percent);
  static String get afterPublishingNote => _s.afterPublishingNote;
  static String bookingReferenceLine(String reference) =>
      _s.bookingReferenceLine(reference);
  static String get teamAndMatch => _s.teamAndMatch;
  static String get publish => _s.publish;
  static String get teamAndMatchSubtitle => _s.teamAndMatchSubtitle;
  static String get attachTheCourtBooking => _s.attachTheCourtBooking;
  static String get whoPaysWhat => _s.whoPaysWhat;
  static String get reviewAndGoLive => _s.reviewAndGoLive;
  static String get someMatchDetailsStillLoading =>
      _s.someMatchDetailsStillLoading;
  static String get selectTheTeamThatWillPlay => _s.selectTheTeamThatWillPlay;
  static String get pickAMatchTypeToContinue => _s.pickAMatchTypeToContinue;
  static String get pickVenueThenConfirmSlot => _s.pickVenueThenConfirmSlot;
  static String get selectBookingThatHostsMatch =>
      _s.selectBookingThatHostsMatch;
  static String get endTimeMustBeAfterStartTime =>
      _s.endTimeMustBeAfterStartTime;
  static String get completeThisStepToContinue => _s.completeThisStepToContinue;
  static String get selectBookableVenueFirst => _s.selectBookableVenueFirst;
  static String get kickoffAndVenue => _s.kickoffAndVenue;
  static String get futsalVenue => _s.futsalVenue;
  static String get publishRequest => _s.publishRequest;
  static String get continueLabel => _s.continueLabel;
  static String get whoPlaysAndWhatMatch => _s.whoPlaysAndWhatMatch;
  static String get selectOrCreateTeam => _s.selectOrCreateTeam;
  static String get couldNotLoadYourTeamsTitle => _s.couldNotLoadYourTeamsTitle;
  static String get couldNotLoadMatchTypes => _s.couldNotLoadMatchTypes;
  static String get opponentLevel => _s.opponentLevel;
  static String get matchPreview => _s.matchPreview;
  static String get noTeamSelectedYet => _s.noTeamSelectedYet;
  static String get dateTimeVenueSetOnNextStep => _s.dateTimeVenueSetOnNextStep;
  static String get venueAlreadyBooked => _s.venueAlreadyBooked;
  static String get venueArrangement => _s.venueArrangement;
  static String get yesAlreadyBookedVenue => _s.yesAlreadyBookedVenue;
  static String get yesAlreadyBookedVenueSubtitle =>
      _s.yesAlreadyBookedVenueSubtitle;
  static String get noFindAndBookCourtNow => _s.noFindAndBookCourtNow;
  static String get noFindAndBookCourtNowSubtitle =>
      _s.noFindAndBookCourtNowSubtitle;
  static String get selectExistingBooking => _s.selectExistingBooking;
  static String get myBookingsLower => _s.myBookingsLower;
  static String get bookedElsewhere => _s.bookedElsewhere;
  static String get chooseFromYourBookings => _s.chooseFromYourBookings;
  static String get bookingDetailsFilledInForYou =>
      _s.bookingDetailsFilledInForYou;
  static String get bookingAttached => _s.bookingAttached;
  static String get venueName => _s.venueName;
  static String get enterTheBookedVenue => _s.enterTheBookedVenue;
  static String get enterTheVenueName => _s.enterTheVenueName;
  static String get venueLocation => _s.venueLocation;
  static String get areaCityOrFullAddress => _s.areaCityOrFullAddress;
  static String get enterTheVenueLocation => _s.enterTheVenueLocation;
  static String get whatYouPaidForTheCourt => _s.whatYouPaidForTheCourt;
  static String get enterTheTotalCourtFee => _s.enterTheTotalCourtFee;
  static String get bookedDateAndTime => _s.bookedDateAndTime;
  static String get findAndBookACourtNow => _s.findAndBookACourtNow;
  static String get chooseCourtDateAndSlot => _s.chooseCourtDateAndSlot;
  static String get open => _s.open;
  static String get configureTheCostSplitRule => _s.configureTheCostSplitRule;
  static String get reviewAndPublish => _s.reviewAndPublish;
  static String get addAMessageOptional => _s.addAMessageOptional;
  static String get requestSummary => _s.requestSummary;
  static String get match => _s.match;
  static String teamCount(int count) => _s.teamCount(count);
  static String requestCount(int count) => _s.requestCount(count);
  static String openCount(int count) => _s.openCount(count);
  static String get chatUnavailable => _s.chatUnavailable;

  // Vendor operations
  static String get couldNotLoadCourtWeek => _s.couldNotLoadCourtWeek;
  static String get couldNotLoadDaySlots => _s.couldNotLoadDaySlots;
  static String get slotCouldNotBeHeld => _s.slotCouldNotBeHeld;
  static String get partlyPaid => _s.partlyPaid;
  static String venueNumber(Object id) => _s.venueNumber(id);
  static String courtNumber(Object id) => _s.courtNumber(id);
  static String get upcoming => _s.upcoming;
  static String get inProgress => _s.inProgress;
  static String get outstandingPayment => _s.outstandingPayment;
  static String get onHold => _s.onHold;
  static String get noSlots => _s.noSlots;
  static String get courtInactive => _s.courtInactive;
  static String get closedAllDay => _s.closedAllDay;
  static String get noScheduleSet => _s.noScheduleSet;
  static String get weekSunToSat => _s.weekSunToSat;
  static String get fromToday => _s.fromToday;
  static String noSlotsOn(Object? day) => _s.noSlotsOn('$day');
  static String closedOn(Object? day) => _s.closedOn('$day');
  static String get past => _s.past;
  static String get unpaid => _s.unpaid;
  static String get liveSlotsDidNotLoad => _s.liveSlotsDidNotLoad;
  static String get bookingLower => _s.bookingLower;
  static String get bookingsLower => _s.bookingsLower;
  static String get bookedLower => _s.bookedLower;
  static String get freeLower => _s.freeLower;
  static String get valueLower => _s.valueLower;
  static String get dueLower => _s.dueLower;
  static String get paidLower => _s.paidLower;
  static String get tapToShowOnBoard => _s.tapToShowOnBoard;
  static String hoursShort(Object hours) => _s.hoursShort(hours);
  static String openCourtHoursBooked(Object booked, Object sellable) =>
      _s.openCourtHoursBooked(booked, sellable);
  static String hoursPassedUnbooked(Object hours) =>
      _s.hoursPassedUnbooked(hours);
  static String occupancySemantics(
    int percent,
    Object booked,
    Object sellable,
  ) => _s.occupancySemantics(percent, booked, sellable);
  static String get closeBookingDetails => _s.closeBookingDetails;
  static String get customer => _s.customer;
  static String get slots => _s.slots;
  static String get paymentsHeader => _s.paymentsHeader;
  static String get actionsAndReceipt => _s.actionsAndReceipt;
  static String get actionsAndReceiptNotInDemo => _s.actionsAndReceiptNotInDemo;
  static String get noCourtsMatchFilters => _s.noCourtsMatchFilters;
  static String get dateSlotsCouldNotLoad => _s.dateSlotsCouldNotLoad;
  static String get full => _s.full;
  static String get weekLink => _s.weekLink;
  static String get nextFree => _s.nextFree;
  static String get noneLeft => _s.noneLeft;
  static String get hideEarlier => _s.hideEarlier;
  static String get noSlotsLeftOnDay => _s.noSlotsLeftOnDay;
  static String get onCourtNow => _s.onCourtNow;
  static String get nextBooking => _s.nextBooking;
  static String get none => _s.none;
  static String get priceOnConfirmationLower => _s.priceOnConfirmationLower;
  static String get loadingCourtsSlots => _s.loadingCourtsSlots;
  static String courtsFreeSummary(int count, Object free) =>
      _s.courtsFreeSummary(count, free);
  static String freeCount(Object count) => _s.freeCount(count);
  static String slotsDuration(Object duration) => _s.slotsDuration(duration);
  static String showEarlier(int count) => _s.showEarlier(count);
  static String bookingTill(Object name, Object time) =>
      _s.bookingTill(name, time);
  static String availableSlotSemantics(
    String time, {
    required bool selected,
    required String price,
  }) => _s.availableSlotSemantics(time, selected ? 'true' : 'false', price);
  static String bookedSlotSemantics(
    String time,
    String phase,
    String customer,
    String payment,
  ) => _s.bookedSlotSemantics(time, phase, customer, payment);
  static String closedSlotSemantics(String time) =>
      _s.closedSlotSemantics(time);
  static String pastSlotSemantics(String time) => _s.pastSlotSemantics(time);
  static String percentBooked(int percent) => _s.percentBooked(percent);
  static String get there => _s.there;
  static String get previousDay => _s.previousDay;
  static String get nextDay => _s.nextDay;
  static String get mondayUpper => _s.mondayUpper;
  static String get tuesdayUpper => _s.tuesdayUpper;
  static String get wednesdayUpper => _s.wednesdayUpper;
  static String get thursdayUpper => _s.thursdayUpper;
  static String get fridayUpper => _s.fridayUpper;
  static String get saturdayUpper => _s.saturdayUpper;
  static String get sundayUpper => _s.sundayUpper;
  static String get showingToday => _s.showingToday;
  static String get goToToday => _s.goToToday;
  static String get showNormalHome => _s.showNormalHome;
  static String get showOperationsHome => _s.showOperationsHome;
  static String get operationsHomeSelected => _s.operationsHomeSelected;
  static String get normalHomeSelected => _s.normalHomeSelected;
  static String get ops => _s.ops;
  static String get oneVenue => _s.oneVenue;
  static String get allCourts => _s.allCourts;
  static String get oneCourt => _s.oneCourt;
  static String get bookingStatus => _s.bookingStatus;
  static String get anyStatus => _s.anyStatus;
  static String get namePhoneOrReference => _s.namePhoneOrReference;
  static String get resetFilters => _s.resetFilters;
  static String get noMatches => _s.noMatches;
  static String get showAll => _s.showAll;
  static String greetingWithName(String greeting, String name) =>
      _s.greetingWithName(greeting, name);
  static String selectedDateChange(String date) => _s.selectedDateChange(date);
  static String venuesCount(int count) => _s.venuesCount(count);
  static String courtsCount(int count) => _s.courtsCount(count);
  static String searchIn(String what) => _s.searchIn(what);
  static String allOf(String what) => _s.allOf(what);
  static String applyCount(int count) => _s.applyCount(count);
  static String get noCourtsMatchVenueFilter => _s.noCourtsMatchVenueFilter;
  static String get fullThisWeek => _s.fullThisWeek;
  static String get previousWeek => _s.previousWeek;
  static String get nextWeek => _s.nextWeek;
  static String get weekStartsFrom => _s.weekStartsFrom;
  static String get weekStartsFromHeader => _s.weekStartsFromHeader;
  static String get sundayInitial => _s.sundayInitial;
  static String get mondayInitial => _s.mondayInitial;
  static String get tuesdayInitial => _s.tuesdayInitial;
  static String get wednesdayInitial => _s.wednesdayInitial;
  static String get thursdayInitial => _s.thursdayInitial;
  static String get fridayInitial => _s.fridayInitial;
  static String get saturdayInitial => _s.saturdayInitial;
  static String get calendarWeek => _s.calendarWeek;
  static String get startingToday => _s.startingToday;
  static String get sundayToSaturday => _s.sundayToSaturday;
  static String get todayAndNextSixDays => _s.todayAndNextSixDays;
  static String get timeSlot => _s.timeSlot;
  static String get sameBooking => _s.sameBooking;
  static String get customerLower => _s.customerLower;
  static String get closedLower => _s.closedLower;
  static String get loadingCourtWeek => _s.loadingCourtWeek;
  static String thisWeekRange(String range) => _s.thisWeekRange(range);
  static String courtClosedAllWeek(String court) =>
      _s.courtClosedAllWeek(court);
  static String courtHasNoSlotsThisWeek(String court) =>
      _s.courtHasNoSlotsThisWeek(court);
  static String timeRangeSemantics(String start, String end) =>
      _s.timeRangeSemantics(start, end);
  static String weekAvailableSlotSemantics(
    String when, {
    required bool selected,
    required String price,
  }) => _s.weekAvailableSlotSemantics(when, selected ? 'true' : 'false', price);
  static String weekBookedSlotSemantics(
    String when,
    String phase,
    String customer,
    String payment,
  ) => _s.weekBookedSlotSemantics(when, phase, customer, payment);
  static String slotNoteSemantics(String when, String note) =>
      _s.slotNoteSemantics(when, note);
  static String noSlotSemantics(String when) => _s.noSlotSemantics(when);
  static String get couldNotLoadYourVenues => _s.couldNotLoadYourVenues;
  static String get checkConnectionAndRetry => _s.checkConnectionAndRetry;
  static String get noVenuesToManageYet => _s.noVenuesToManageYet;
  static String get noVenuesToManageMessage => _s.noVenuesToManageMessage;
  static String get refresh => _s.refresh;
  static String get bookingsForDateCouldNotLoad =>
      _s.bookingsForDateCouldNotLoad;
  static String get priceOnConfirmation => _s.priceOnConfirmation;
  static String get clearSelection => _s.clearSelection;
  static String get review => _s.review;
  static String get loadingTodaysOperations => _s.loadingTodaysOperations;
  static String get availability => _s.availability;
  static String get statusKey => _s.statusKey;
  static String get hideStatuses => _s.hideStatuses;
  static String get viewStatuses => _s.viewStatuses;
  static String get day => _s.day;
  static String get week => _s.week;
  static String get everyCourtToday => _s.everyCourtToday;
  static String get oneCourtWholeWeek => _s.oneCourtWholeWeek;
  static String todayWithDate(String date) => _s.todayWithDate(date);
  static String selectionHeadline(int slots, Object hours) =>
      _s.selectionHeadline(slots, '$hours');
  static String estimatedPrice(String amount, {required bool allPriced}) =>
      _s.estimatedPrice(amount, allPriced ? 'true' : 'false');
  static String courtsPriceDetail(int courts, String price) =>
      _s.courtsPriceDetail(courts, price);
  static String selectedSummarySemantics(String headline, String detail) =>
      _s.selectedSummarySemantics(headline, detail);
  static String get couldNotReadCandidates => _s.couldNotReadCandidates;
  static String get cash => _s.cash;
  static String get enterAmountForEveryPayment => _s.enterAmountForEveryPayment;
  static String get releaseHeldSlotsTitle => _s.releaseHeldSlotsTitle;
  static String get releaseOneHeldSlotMessage => _s.releaseOneHeldSlotMessage;
  static String get keepReviewing => _s.keepReviewing;
  static String get releaseAndClose => _s.releaseAndClose;
  static String get removeAll => _s.removeAll;
  static String get manualBookingSentence => _s.manualBookingSentence;
  static String get customerAndPayment => _s.customerAndPayment;
  static String get reviewBooking => _s.reviewBooking;
  static String get pickFreeSlotsOnBoard => _s.pickFreeSlotsOnBoard;
  static String get closePanel => _s.closePanel;
  static String get bookForToday => _s.bookForToday;
  static String get customerName => _s.customerName;
  static String get enterCustomerName => _s.enterCustomerName;
  static String get enterCustomerPhone => _s.enterCustomerPhone;
  static String get enterValidPhoneNumber => _s.enterValidPhoneNumber;
  static String get amountReceivedNpr => _s.amountReceivedNpr;
  static String get enterAmountOrRemovePayment => _s.enterAmountOrRemovePayment;
  static String get addPaymentRemark => _s.addPaymentRemark;
  static String get subtotalEstimateFrom => _s.subtotalEstimateFrom;
  static String get subtotalEstimate => _s.subtotalEstimate;
  static String get received => _s.received;
  static String get remaining => _s.remaining;
  static String get finalPricesFromServerFootnote =>
      _s.finalPricesFromServerFootnote;
  static String nothingWasBookedReason(Object? message) =>
      _s.nothingWasBookedReason('$message');
  static String slotConflictNothingBooked(
    String court,
    String start,
    String end,
    Object? message,
  ) => _s.slotConflictNothingBooked(court, start, end, '$message');
  static String receivedMoreThanPayable(String received, String payable) =>
      _s.receivedMoreThanPayable(received, payable);
  static String nothingBookedSlotsStillHeld(String? reason) => reason == null
      ? _s.nothingBookedSlotsStillHeldNoReason
      : _s.nothingBookedSlotsStillHeld(reason);
  static String releaseHeldSlotsMessage(int count) =>
      _s.releaseHeldSlotsMessage(count);
  static String removeAllSlotsTitle(int count) => _s.removeAllSlotsTitle(count);
  static String slotsAndCourtsCount(int slots, int courts) =>
      _s.slotsAndCourtsCount(slots, courts);
  static String methodReceivedNpr(String method) =>
      _s.methodReceivedNpr(method);
  static String moreThanTheTotal(String total) => _s.moreThanTheTotal(total);
  static String addPaymentMethod(String method) => _s.addPaymentMethod(method);
  static String get existingCandidates => _s.existingCandidates;
  static String get hideCandidates => _s.hideCandidates;
  static String get noMatchingCandidate => _s.noMatchingCandidate;
  static String get loadMoreCandidates => _s.loadMoreCandidates;
  static String get unnamedCustomer => _s.unnamedCustomer;
  static String get reviewedRevisedPrices => _s.reviewedRevisedPrices;
  static String get payable => _s.payable;
  static String get receivedNow => _s.receivedNow;
  static String get remainingBalance => _s.remainingBalance;
  static String get manualSourceFootnote => _s.manualSourceFootnote;
  static String paymentMethodLine(String methods) =>
      _s.paymentMethodLine(methods);
  static String paymentStatusLine(String status) =>
      _s.paymentStatusLine(status);
  static String bookingStatusLine(String status) =>
      _s.bookingStatusLine(status);
  static String receivedNowBy(String method) => _s.receivedNowBy(method);
  static String bookedFor(String name) => _s.bookedFor(name);
  static String bookingsFor(int count, String name) =>
      _s.bookingsFor(count, name);
  static String paymentPendingToCollect(String amount) =>
      _s.paymentPendingToCollect(amount);
  static String paidInFullBy(String methods) => _s.paidInFullBy(methods);
  static String paidAndToCollect(String paid, String due) =>
      _s.paidAndToCollect(paid, due);
  static String get continueText => _s.continueText;
  static String get holdSlotsAndReview => _s.holdSlotsAndReview;
  static String get confirmBookingSentence => _s.confirmBookingSentence;
  static String get newBooking => _s.newBooking;
  static String get clearAllSentence => _s.clearAllSentence;
  static String get tapFreeSlotsOnBoard => _s.tapFreeSlotsOnBoard;
  static String get pickAnyMixOfSlots => _s.pickAnyMixOfSlots;
  static String get pricedOnHold => _s.pricedOnHold;
  static String get holdExpired => _s.holdExpired;
  static String maybeFromPrice(String amount, {required bool from}) =>
      _s.maybeFromPrice(amount, from ? 'true' : 'false');
  static String selectionFooterSummary(int count, Object hours, String price) =>
      _s.selectionFooterSummary(count, '$hours', price);
  static String removeSlotAt(String time) => _s.removeSlotAt(time);
  static String ticketRangeLine(
    String date,
    String start,
    String end,
    String duration,
    int count,
  ) => _s.ticketRangeLine(date, start, end, duration, count);
  static String bookingNumber(Object? id) => _s.bookingNumber('$id');
  static String wasPrice(String amount) => _s.wasPrice(amount);
  static String slotsHeldFor(int minutes, String seconds) =>
      _s.slotsHeldFor('$minutes', seconds);
  static String slotsCountWithTotal(int count, String total) =>
      _s.slotsCountWithTotal(count, total);
  static String get removeThisPayment => _s.removeThisPayment;
  static String paidBy(String method) => _s.paidBy(method);
  static String stepOfThree(int step, String label) =>
      _s.stepOfThree('$step', label);

  // Vendor onboarding
  static String get floodlights => _s.floodlights;
  static String get parking => _s.parking;
  static String get changingRoom => _s.changingRoom;
  static String get shower => _s.shower;
  static String get wiFi => _s.wiFi;
  static String get firstAid => _s.firstAid;
  static String get liveScoreboard => _s.liveScoreboard;
  static String get warmUpZone => _s.warmUpZone;
  static String get cafeteria => _s.cafeteria;
  static String get spectatorSeating => _s.spectatorSeating;
  static String get equipmentRental => _s.equipmentRental;
  static String get lockerStorage => _s.lockerStorage;
  static String get goalNets => _s.goalNets;
  static String get scoreboard => _s.scoreboard;
  static String get ballStand => _s.ballStand;
  static String get benches => _s.benches;
  static String get drinkingWater => _s.drinkingWater;
  static String get lighting => _s.lighting;
  static String get indoor => _s.indoor;
  static String get roofed => _s.roofed;
  static String get changingArea => _s.changingArea;
  static String get washroomAccess => _s.washroomAccess;
  static String get parkingAccess => _s.parkingAccess;
  static String get spectatorZone => _s.spectatorZone;
  static String get outdoor => _s.outdoor;
  static String get vendorOnboardingComplete => _s.vendorOnboardingComplete;
  static String get draftSaveFailedTryAgain => _s.draftSaveFailedTryAgain;
  static String get finish => _s.finish;
  static String get selectValidStartAndEndTime => _s.selectValidStartAndEndTime;
  static String get startAndEndTimeCannotBeSame =>
      _s.startAndEndTimeCannotBeSame;
  static String get anotherSlot => _s.anotherSlot;
  static String get timeSlotAlreadyExistsOnSelectedDays =>
      _s.timeSlotAlreadyExistsOnSelectedDays;
  static String timeOverlapsWithOnSelectedDays(String name) =>
      _s.timeOverlapsWithOnSelectedDays(name);
  static String get provideFutsalName => _s.provideFutsalName;
  static String get uniqueSlugRequired => _s.uniqueSlugRequired;
  static String get slugInvalidCharacters => _s.slugInvalidCharacters;
  static String get enterValidContactPhone => _s.enterValidContactPhone;
  static String get enterValidContactEmail => _s.enterValidContactEmail;
  static String get provideValidWebsiteOrSocialLink =>
      _s.provideValidWebsiteOrSocialLink;
  static String get provideFutsalDescription => _s.provideFutsalDescription;
  static String get enterCompleteFutsalAddress => _s.enterCompleteFutsalAddress;
  static String get specifyFutsalExactLocation => _s.specifyFutsalExactLocation;
  static String get provideLongitudeAndLatitude =>
      _s.provideLongitudeAndLatitude;
  static String get selectAtLeastOneFutsalAmenityOrFeature =>
      _s.selectAtLeastOneFutsalAmenityOrFeature;
  static String get specifyCancellationPolicy => _s.specifyCancellationPolicy;
  static String get provideFutsalRules => _s.provideFutsalRules;
  static String get specifyCommissionPercentage =>
      _s.specifyCommissionPercentage;
  static String get uploadFutsalCoverImage => _s.uploadFutsalCoverImage;
  static String get uploadAtLeastOneGalleryImage =>
      _s.uploadAtLeastOneGalleryImage;
  static String get uploadRequiredCompanyDocuments =>
      _s.uploadRequiredCompanyDocuments;
  static String get enterCourtName => _s.enterCourtName;
  static String get enterCourtBasePrice => _s.enterCourtBasePrice;
  static String get selectCourtType => _s.selectCourtType;
  static String get enterCourtDescription => _s.enterCourtDescription;
  static String get uploadAtLeastOneCourtPhoto => _s.uploadAtLeastOneCourtPhoto;
  static String get selectAdvancePaymentType => _s.selectAdvancePaymentType;
  static String get enterAdvancePaymentAmount => _s.enterAdvancePaymentAmount;
  static String advanceMustBeAtLeastPercent(String percent) =>
      _s.advanceMustBeAtLeastPercent(percent);
  static String get percentageCannotExceed100 => _s.percentageCannotExceed100;
  static String get flatAmountCannotExceedBasePrice =>
      _s.flatAmountCannotExceedBasePrice;
  static String advanceMustBeAtLeastPercentOfBasePrice(
    String percent,
    String minimum,
  ) => _s.advanceMustBeAtLeastPercentOfBasePrice(percent, minimum);
  static String get uploadAdvancePaymentQr => _s.uploadAdvancePaymentQr;
  static String get selectAtLeastOneCourtAmenity =>
      _s.selectAtLeastOneCourtAmenity;
  static String get selectAtLeastOneCourtFacility =>
      _s.selectAtLeastOneCourtFacility;
  static String get addAtLeastOneSlotForCourt => _s.addAtLeastOneSlotForCourt;
  static String get completeDayAndTimeForAllSlots =>
      _s.completeDayAndTimeForAllSlots;
  static String get resolveOverlappingSlots => _s.resolveOverlappingSlots;
  static String get thisSlot => _s.thisSlot;
  static String saveLabelBeforeContinuing(String label) =>
      _s.saveLabelBeforeContinuing(label);
  static String get createFutsalVenueFirst => _s.createFutsalVenueFirst;
  static String get finishFutsalStepsBeforeCourts =>
      _s.finishFutsalStepsBeforeCourts;
  static String get next => _s.next;
  static String get continueToCourts => _s.continueToCourts;
  static String get reviewAndPublishTitle => _s.reviewAndPublishTitle;
  static String get addCourtBeforeOpeningCourtSteps =>
      _s.addCourtBeforeOpeningCourtSteps;
  static String get addCourtBeforeOpeningCourtSubsteps =>
      _s.addCourtBeforeOpeningCourtSubsteps;
  static String get addAtLeastOneCourtBeforeContinuing =>
      _s.addAtLeastOneCourtBeforeContinuing;
  static String defaultCourtName(int number) => _s.defaultCourtName(number);
  static String defaultSlotLabel(int number) => _s.defaultSlotLabel(number);
  static String get saveCourtBeforeManagingSlots =>
      _s.saveCourtBeforeManagingSlots;
  static String get saveSlotBeforeSettingPrices =>
      _s.saveSlotBeforeSettingPrices;
  static String get waitForCurrentSaveToFinish => _s.waitForCurrentSaveToFinish;
  static String get addAtLeastOneCourtBeforePublishing =>
      _s.addAtLeastOneCourtBeforePublishing;
  static String get addAtLeastOneCourtBeforeFinishing =>
      _s.addAtLeastOneCourtBeforeFinishing;
  static String get aCourt => _s.aCourt;
  static String courtNotSetUpYet(String name) => _s.courtNotSetUpYet(name);
  static String get completeAndSaveFutsalBeforeAddingCourts =>
      _s.completeAndSaveFutsalBeforeAddingCourts;
  static String get mediaLibrary => _s.mediaLibrary;
  static String get selectSavedMediaOrAddNewFiles =>
      _s.selectSavedMediaOrAddNewFiles;
  static String removeFromSavedCollectionPrompt(String name) =>
      _s.removeFromSavedCollectionPrompt(name);
  static String itemsCount(int count) => _s.itemsCount(count);
  static String selectedCount(int count) => _s.selectedCount(count);
  static String get useSelectedItems => _s.useSelectedItems;
  static String get useSelectedItem => _s.useSelectedItem;
  static String get noMediaSelected => _s.noMediaSelected;
  static String itemsSelected(int count) => _s.itemsSelected(count);
  static String get images => _s.images;
  static String get files => _s.files;
  static String tapToAttachFilesForSection(String actionLabel) =>
      _s.tapToAttachFilesForSection(actionLabel);
  static String get locked => _s.locked;
  static String get notStarted => _s.notStarted;
  static String get inProgressTitle => _s.inProgressTitle;
  static String get needsAttention => _s.needsAttention;
  static String get sessionState => _s.sessionState;
  static String get readyInSession => _s.readyInSession;
  static String get savingDraft => _s.savingDraft;
  static String get draftSaved => _s.draftSaved;
  static String savedAt(String time) => _s.savedAt(time);
  static String get draftSaveFailed => _s.draftSaveFailed;
  static String get sessionOnly => _s.sessionOnly;
  static String get searchLocationHint => _s.searchLocationHint;
  static String deleteCourtConfirmation(String courtName) =>
      _s.deleteCourtConfirmation(courtName);
  static String courtDeletedSuccessfully(String courtName) =>
      _s.courtDeletedSuccessfully(courtName);
  static String get unnamedCourt => _s.unnamedCourt;
  static String slotCountLabel(int count) => _s.slotCountLabel(count);
  static String get saveChangesAndExit => _s.saveChangesAndExit;
  static String get courtSetupProgressSavedBeforeHome =>
      _s.courtSetupProgressSavedBeforeHome;
  static String get saveAndGoHome => _s.saveAndGoHome;
  static String get stayHere => _s.stayHere;
  static String get enterCourtNameHelper => _s.enterCourtNameHelper;
  static String stepNumber(int section, int substep) =>
      _s.stepNumber(section, substep);
  static String get enterFirstCourtNameHelper => _s.enterFirstCourtNameHelper;
  static String get courtSetupSentenceCase => _s.courtSetupSentenceCase;
  static String get futsalSetup => _s.futsalSetup;
  static String get courtDetailsAndBookingSetup =>
      _s.courtDetailsAndBookingSetup;
  static String get businessProfileAndLocation => _s.businessProfileAndLocation;
  static String futsalStatusLabel(String status) =>
      _s.futsalStatusLabel(status);
  static String courtCountLabel(int count) => _s.courtCountLabel(count);
  static String get onboardingProgressSavedBeforeHome =>
      _s.onboardingProgressSavedBeforeHome;
  static String get loadingCourtTypes => _s.loadingCourtTypes;
  static String get loadingMatchFormats => _s.loadingMatchFormats;
  static String get basicPlanDescriptionHtml => _s.basicPlanDescriptionHtml;
  static String get standardPlanDescriptionHtml =>
      _s.standardPlanDescriptionHtml;
  static String planPercentLabel(int percent) => _s.planPercentLabel(percent);
  static String get defaultPackageDescriptionHtml =>
      _s.defaultPackageDescriptionHtml;
  static String get playerFacingFacilitiesAtCourt =>
      _s.playerFacingFacilitiesAtCourt;
  static String get courtSpecificServicesAndEquipment =>
      _s.courtSpecificServicesAndEquipment;
  static String get noFacilitiesAvailableRightNow =>
      _s.noFacilitiesAvailableRightNow;
  static String get noAmenitiesAvailableRightNow =>
      _s.noAmenitiesAvailableRightNow;
  static String selectedOfTotal(int selected, int total) =>
      _s.selectedOfTotal(selected, total);
  static String get addNew => _s.addNew;
  static String get addPaymentQrs => _s.addPaymentQrs;
  static String get youCanAddOneMoreQr => _s.youCanAddOneMoreQr;
  static String youCanAddUpToMoreQrs(int remaining) =>
      _s.youCanAddUpToMoreQrs(remaining);
  static String courtQrLimitReached(int max, int remaining) =>
      _s.courtQrLimitReached(max, remaining);
  static String get enterTheAdvanceAmount => _s.enterTheAdvanceAmount;
  static String get amountMustBeGreaterThanZero =>
      _s.amountMustBeGreaterThanZero;
  static String flatAmountCannotExceedBasePriceOf(String base) =>
      _s.flatAmountCannotExceedBasePriceOf(base);
  static String minimumPercentUpTo100(String percent) =>
      _s.minimumPercentUpTo100(percent);
  static String get enterFlatAdvanceAmount => _s.enterFlatAdvanceAmount;
  static String fromAmountToAmount(String from, String to) =>
      _s.fromAmountToAmount(from, to);
  static String get enterAdvanceAmount => _s.enterAdvanceAmount;
  static String everyCourtCollectsAdvance(String percent) =>
      _s.everyCourtCollectsAdvance(percent);
  static String get advancePercentageLabel => _s.advancePercentageLabel;
  static String get advanceAmount => _s.advanceAmount;
  static String get removeQr => _s.removeQr;
  static String get removePaymentQrPrompt => _s.removePaymentQrPrompt;
  static String get addQrForEachWalletOrBank => _s.addQrForEachWalletOrBank;
  static String qrNumber(int number) => _s.qrNumber(number);
  static String tapToViewLabel(String label) => _s.tapToViewLabel(label);
  static String get uploadQr => _s.uploadQr;
  static String get addQr => _s.addQr;
  static String get noBookingDays => _s.noBookingDays;
  static String get enterSlotLabel => _s.enterSlotLabel;
  static String get selectAtLeastOneBookingDay => _s.selectAtLeastOneBookingDay;
  static String get selectBothStartAndEndTime => _s.selectBothStartAndEndTime;
  static String get editSlot => _s.editSlot;
  static String get bookingDays => _s.bookingDays;
  static String get updateSlot => _s.updateSlot;
  static String get untitledSlot => _s.untitledSlot;
  static String get timeNotSet => _s.timeNotSet;
  static String get everyDay => _s.everyDay;
  static String get addHoliday => _s.addHoliday;
  static String get addClosedDate => _s.addClosedDate;
  static String basePriceLabel(String price) => _s.basePriceLabel(price);
  static String weekendPriceLabel(String price) => _s.weekendPriceLabel(price);
  static String holidayPriceLabel(String price) => _s.holidayPriceLabel(price);
  static String discountPriceLabel(String price) =>
      _s.discountPriceLabel(price);
  static String customDatesCount(int count) => _s.customDatesCount(count);
  static String get noSpecialPricingSet => _s.noSpecialPricingSet;
  static String get discountPercentLabel => _s.discountPercentLabel;
  static String get discountPrice => _s.discountPrice;
  static String get closureType => _s.closureType;
  static String get january => _s.january;
  static String get february => _s.february;
  static String get march => _s.march;
  static String get april => _s.april;
  static String get may => _s.may;
  static String get june => _s.june;
  static String get july => _s.july;
  static String get august => _s.august;
  static String get september => _s.september;
  static String get october => _s.october;
  static String get november => _s.november;
  static String get december => _s.december;

  // Booking overview
  static String get periodWeek => _s.periodWeek;
  static String get periodMonth => _s.periodMonth;
  static String get periodYear => _s.periodYear;
  static String get periodCustom => _s.periodCustom;
  static String get bookingStatuses => _s.bookingStatuses;
  static String get revenueTrend => _s.revenueTrend;
  static String get bookingOverviewTitle => _s.bookingOverviewTitle;
  static String get snapshot => _s.snapshot;
  static String get netEarnings => _s.netEarnings;
  static String get performanceByVenue => _s.performanceByVenue;
  static String get topCourts => _s.topCourts;
  static String get topCustomers => _s.topCustomers;
  static String get bookedHours => _s.bookedHours;
  static String get bookedHrs => _s.bookedHrs;
  static String get noVenueActivityInPeriod => _s.noVenueActivityInPeriod;
  static String get twelveAm => _s.twelveAm;
  static String get elevenPm => _s.elevenPm;
  static String get overheadsAndProcessing => _s.overheadsAndProcessing;
  static String get acrossAllPaidSlots => _s.acrossAllPaidSlots;
  static String get ofAvailableCourtHours => _s.ofAvailableCourtHours;
  static String avgNpr(String amount) => _s.avgNpr(amount);
  static String avgPerBooking(String amount) => _s.avgPerBooking(amount);
  static String bookingCount(int count) => _s.bookingCount(count);
  static String rowCount(int count) => _s.rowCount(count);
  static String daysShort(int days) => _s.daysShort(days);
  static String totalBookingsCount(int total) => _s.totalBookingsCount(total);
  static String vsPreviousPeriod(String amount) => _s.vsPreviousPeriod(amount);
  static String paidCount(int count) => _s.paidCount(count);
  static String percentOfBookings(String percent) =>
      _s.percentOfBookings(percent);
  // Bookings
  static String get allDates => _s.allDates;
  static String get dateModeDay => _s.dateModeDay;
  static String get dateModeRange => _s.dateModeRange;
  static String get noInternetCheckNetwork => _s.noInternetCheckNetwork;
  static String get somethingWentWrongLoadingBookings =>
      _s.somethingWentWrongLoadingBookings;
  static String get couldNotLoadAccountForBookings =>
      _s.couldNotLoadAccountForBookings;
  static String get accountRoleMissingForBookings =>
      _s.accountRoleMissingForBookings;
  static String get searchVenueCourtOrBookingId =>
      _s.searchVenueCourtOrBookingId;
  static String get searchCourtPlayerOrBookingId =>
      _s.searchCourtPlayerOrBookingId;
  static String get failedToLoadBookings => _s.failedToLoadBookings;
  static String get failedToLoadFutsalBookings => _s.failedToLoadFutsalBookings;
  static String get failedToLoadRecentBookings => _s.failedToLoadRecentBookings;
  static String get noMatchingBookings => _s.noMatchingBookings;
  static String get noBookingsYet => _s.noBookingsYet;
  static String get noFutsalBookingsYet => _s.noFutsalBookingsYet;
  static String get upcomingCourtBookingsAppearHere =>
      _s.upcomingCourtBookingsAppearHere;
  static String get venueBookingsAppearHere => _s.venueBookingsAppearHere;
  static String get tryDifferentSearchOrDateRange =>
      _s.tryDifferentSearchOrDateRange;
  static String get couldNotLoadMoreRetry => _s.couldNotLoadMoreRetry;
  static String get loadMoreBookings => _s.loadMoreBookings;
  static String get products => _s.products;
  static String get addProducts => _s.addProducts;
  static String get recurring => _s.recurring;
  static String get unknown => _s.unknown;
  static String get monthShortJan => _s.monthShortJan;
  static String get monthShortFeb => _s.monthShortFeb;
  static String get monthShortMar => _s.monthShortMar;
  static String get monthShortApr => _s.monthShortApr;
  static String get monthShortMay => _s.monthShortMay;
  static String get monthShortJun => _s.monthShortJun;
  static String get monthShortJul => _s.monthShortJul;
  static String get monthShortAug => _s.monthShortAug;
  static String get monthShortSep => _s.monthShortSep;
  static String get monthShortOct => _s.monthShortOct;
  static String get monthShortNov => _s.monthShortNov;
  static String get monthShortDec => _s.monthShortDec;
  static String get editDateFilter => _s.editDateFilter;
  static String get newestFirst => _s.newestFirst;
  static String get oldestFirst => _s.oldestFirst;
  static String get everyBookingShownWhateverDate =>
      _s.everyBookingShownWhateverDate;
  static String get last7Days => _s.last7Days;
  static String get last30Days => _s.last30Days;
  static String get any => _s.any;
  static String get ratingPoor => _s.ratingPoor;
  static String get ratingFair => _s.ratingFair;
  static String get ratingGood => _s.ratingGood;
  static String get ratingGreat => _s.ratingGreat;
  static String get ratingExcellent => _s.ratingExcellent;
  static String get howWasYourGame => _s.howWasYourGame;
  static String get ratingHelpsOtherPlayers => _s.ratingHelpsOtherPlayers;
  static String get pickStarRatingFirst => _s.pickStarRatingFirst;
  static String get yourReview => _s.yourReview;
  static String get reviewHint => _s.reviewHint;
  static String get writeAFewWordsAboutVenue => _s.writeAFewWordsAboutVenue;
  static String get aLittleMoreDetailPlease => _s.aLittleMoreDetailPlease;
  static String get submitReview => _s.submitReview;
  static String get youReviewedThisBooking => _s.youReviewedThisBooking;
  static String get checkingYourReview => _s.checkingYourReview;
  static String daysAgo(int days) => _s.daysAgo(days);
  static String hoursAgo(int hours) => _s.hoursAgo(hours);
  static String minutesAgo(int minutes) => _s.minutesAgo(minutes);
  static String minutesShort(int minutes) => _s.minutesShort(minutes);
  static String hoursShortHr(int hours) => _s.hoursShortHr(hours);
  static String timeAgo(String value) => _s.timeAgo(value);
  static String timeIn(String value) => _s.timeIn(value);
  static String fromDateLabel(String date) => _s.fromDateLabel(date);
  static String untilDateLabel(String date) => _s.untilDateLabel(date);
  static String noStatusBookingsMatch(String status) =>
      _s.noStatusBookingsMatch(status);
  static String youHaveNoStatusBookings(String status) =>
      _s.youHaveNoStatusBookings(status);
  static String typedBooking(String type) => _s.typedBooking(type);
  static String reviewStatus(String status) => _s.reviewStatus(status);
  static String refNumber(String ref) => _s.refNumber(ref);
  // Manual booking
  static String get paidAtCounter => _s.paidAtCounter;
  static String get couldNotReadCandidatesFromServer =>
      _s.couldNotReadCandidatesFromServer;
  static String get enterAmountLikeExample => _s.enterAmountLikeExample;
  static String get enterAmountGreaterThanZero => _s.enterAmountGreaterThanZero;
  static String get manualBookingAndAdjustments =>
      _s.manualBookingAndAdjustments;
  static String get noVenuesToBookYet => _s.noVenuesToBookYet;
  static String get noVenuesToBookYetMessage => _s.noVenuesToBookYetMessage;
  static String get chooseWhereBookingWillBeCreated =>
      _s.chooseWhereBookingWillBeCreated;
  static String get selectAVenueDot => _s.selectAVenueDot;
  static String get customerDetails => _s.customerDetails;
  static String get walkInCustomerContactInfo => _s.walkInCustomerContactInfo;
  static String get enterCustomerPhoneNumber => _s.enterCustomerPhoneNumber;
  static String get bookingDetailsSentenceCase => _s.bookingDetailsSentenceCase;
  static String get setInitialPaymentAndBookingStatus =>
      _s.setInitialPaymentAndBookingStatus;
  static String get totalAmountNpr => _s.totalAmountNpr;
  static String get leaveBlankToUseSlotPrices => _s.leaveBlankToUseSlotPrices;
  static String get enterBookingDetails => _s.enterBookingDetails;
  static String get nextSelectDateAndTimeSlot => _s.nextSelectDateAndTimeSlot;
  static String get noExistingCandidateFound => _s.noExistingCandidateFound;
  static String get continueToSlotSelection => _s.continueToSlotSelection;
  // Booking details
  static String get dueAmountCollectedSuccessfully =>
      _s.dueAmountCollectedSuccessfully;
  static String get couldNotCollectDueAmount => _s.couldNotCollectDueAmount;
  static String get vendorInfoUnavailableForMessaging =>
      _s.vendorInfoUnavailableForMessaging;
  static String get customerInfoUnavailableForMessaging =>
      _s.customerInfoUnavailableForMessaging;
  static String get thanksForReviewingBooking => _s.thanksForReviewingBooking;
  static String get couldNotLoadLatestBookingDetails =>
      _s.couldNotLoadLatestBookingDetails;
  static String get bookingInformation => _s.bookingInformation;
  static String get paymentSummary => _s.paymentSummary;
  static String get toCollect => _s.toCollect;
  static String get dueAmount => _s.dueAmount;
  static String get collectDue => _s.collectDue;
  static String get unknownCustomer => _s.unknownCustomer;
  static String get bookingTotal => _s.bookingTotal;
  static String get grandTotal => _s.grandTotal;
  static String get includesProductsSold => _s.includesProductsSold;
  static String get payments => _s.payments;
  static String get submittedPaymentScreenshot => _s.submittedPaymentScreenshot;
  static String get noPaymentScreenshot => _s.noPaymentScreenshot;
  static String get screenshotUnavailable => _s.screenshotUnavailable;
  static String get noScreenshotWasSubmitted => _s.noScreenshotWasSubmitted;
  static String discountWithCode(String code) => _s.discountWithCode(code);
  static String productsItemCount(int count) => _s.productsItemCount(count);
  static String paymentCount(int count) => _s.paymentCount(count);
  static String recurrenceSeriesBooking(String recurrence) =>
      _s.recurrenceSeriesBooking(recurrence);
  static String get productsSubtotal => _s.productsSubtotal;
  static String get product => _s.product;
  static String get addMoreProducts => _s.addMoreProducts;
  static String get productsAddedToBooking => _s.productsAddedToBooking;
  static String get couldNotAddProductsTryAgain =>
      _s.couldNotAddProductsTryAgain;
  static String get couldNotLoadProducts => _s.couldNotLoadProducts;
  static String get noProductsAvailable => _s.noProductsAvailable;
  static String get venueHasNoActiveProducts => _s.venueHasNoActiveProducts;
  static String get sellAddOnsForBooking => _s.sellAddOnsForBooking;
  static String get collectedRemainingDueInPerson =>
      _s.collectedRemainingDueInPerson;
  static String get collectDueAmount => _s.collectDueAmount;
  static String get amount => _s.amount;
  static String get enterCollectedAmount => _s.enterCollectedAmount;
  static String get howWasDueAmountCollected => _s.howWasDueAmountCollected;
  static String get completeBooking => _s.completeBooking;
  static String get completeBookingDescription => _s.completeBookingDescription;
  static String get discountAmount => _s.discountAmount;
  static String get discountAmountHint => _s.discountAmountHint;
  static String get amountReceivedNowNpr => _s.amountReceivedNowNpr;
  static String get enterAmountForEachPayment => _s.enterAmountForEachPayment;
  static String get collectingNow => _s.collectingNow;
  static String get payableAfterDiscount => _s.payableAfterDiscount;
  static String get remainingDue => _s.remainingDue;
  static String get bookingPayment => _s.bookingPayment;
  static String get alreadyPaid => _s.alreadyPaid;
  static String get extraItems => _s.extraItems;
  static String get noExtraItemsOnBooking => _s.noExtraItemsOnBooking;
  static String get extraItemsTotal => _s.extraItemsTotal;
  static String get totalToCollect => _s.totalToCollect;
  static String get add => _s.add;
  static String qtyCount(int quantity) => _s.qtyCount(quantity);
  static String productNumber(Object id) => _s.productNumber(id);
  static String itemCount(int count) => _s.itemCount(count);
  static String addToBookingCount(int count) => _s.addToBookingCount(count);
  static String amountCannotExceed(String amount) =>
      _s.amountCannotExceed(amount);
  static String remainsDueForCompletedBooking(String amount) =>
      _s.remainsDueForCompletedBooking(amount);
  static String collectAmount(String amount) => _s.collectAmount(amount);
  static String typeReceivedNpr(String type) => _s.typeReceivedNpr(type);
  static String addPaymentType(String type) => _s.addPaymentType(type);
  static String moreThanAmountDue(String amount) =>
      _s.moreThanAmountDue(amount);

  // Futsal details & courts
  static String get aYearAgo => _s.aYearAgo;
  static String yearsAgo(int years) => _s.yearsAgo(years);
  static String get aMonthAgo => _s.aMonthAgo;
  static String monthsAgo(int months) => _s.monthsAgo(months);
  static String get relativeYesterday => _s.relativeYesterday;
  static String get anHourAgo => _s.anHourAgo;
  static String get relativeJustNow => _s.relativeJustNow;
  static String get twoWeeks => _s.twoWeeks;
  static String get oneMonth => _s.oneMonth;
  static String get twoMonths => _s.twoMonths;
  static String get threeMonths => _s.threeMonths;
  static String get weekdayMon => _s.weekdayMon;
  static String get weekdayTue => _s.weekdayTue;
  static String get weekdayWed => _s.weekdayWed;
  static String get weekdayThu => _s.weekdayThu;
  static String get weekdayFri => _s.weekdayFri;
  static String get weekdaySat => _s.weekdaySat;
  static String get weekdaySun => _s.weekdaySun;
  static String get monday => _s.monday;
  static String get tuesday => _s.tuesday;
  static String get wednesday => _s.wednesday;
  static String get thursday => _s.thursday;
  static String get friday => _s.friday;
  static String get saturday => _s.saturday;
  static String get sunday => _s.sunday;
  static String get unavailable => _s.unavailable;
  static String get couldNotLoadVenueCourts => _s.couldNotLoadVenueCourts;
  static String get couldNotParseCourtSlotsFromServer =>
      _s.couldNotParseCourtSlotsFromServer;
  static String get couldNotCreateCourtSlot => _s.couldNotCreateCourtSlot;
  static String get couldNotSaveCourtSlot => _s.couldNotSaveCourtSlot;
  static String get couldNotDeleteCourtSlot => _s.couldNotDeleteCourtSlot;
  static String get notSpecified => _s.notSpecified;
  static String playersCountTitle(int count) => _s.playersCountTitle(count);
  static String checkOutVenueOnHamroFutsal(String name) =>
      _s.checkOutVenueOnHamroFutsal(name);
  static String startingFrom(String price) => _s.startingFrom(price);
  static String distanceInMeters(Object meters) => _s.distanceInMeters(meters);
  static String distanceInKm(Object km) => _s.distanceInKm(km);
  static String get thatIsEveryReview => _s.thatIsEveryReview;
  static String get noReviewsYet => _s.noReviewsYet;
  static String get playHereAndBeFirstToReview => _s.playHereAndBeFirstToReview;
  static String get choosePreferredTime => _s.choosePreferredTime;
  static String fromPrice(String price) => _s.fromPrice(price);
  static String sessionsCount(int count) => _s.sessionsCount(count);
  static String saveAmountSuffix(String amount) => _s.saveAmountSuffix(amount);
  static String get oneReview => _s.oneReview;
  static String reviewsCount(int count) => _s.reviewsCount(count);
  static String get anonymous => _s.anonymous;
  static String viewAllCount(int count) => _s.viewAllCount(count);
  static String everyWeekdaysSameTime(String weekdays) =>
      _s.everyWeekdaysSameTime(weekdays);
  static String get repeatWeeklyOnTheDaysYouChoose =>
      _s.repeatWeeklyOnTheDaysYouChoose;
  static String sessionsDateRange(int count, String first, String last) =>
      _s.sessionsDateRange(count, first, last);
  static String get someDatesAreUnavailable => _s.someDatesAreUnavailable;
  static String availableUnavailableCount(int available, int unavailable) =>
      _s.availableUnavailableCount(available, unavailable);
  static String allDatesAvailable(int count) => _s.allDatesAvailable(count);
  static String totalSessions(int count) => _s.totalSessions(count);
  static String get unavailableDatesNotChargedSkipped =>
      _s.unavailableDatesNotChargedSkipped;
  static String saveAmount(String amount) => _s.saveAmount(amount);
  static String totalLowercaseSessions(int count) =>
      _s.totalLowercaseSessions(count);
  static String get selectATimeSlotToContinue => _s.selectATimeSlotToContinue;
  static String courtEveryWeekdaysAtTime(
    String court,
    String weekdays,
    Object? time,
  ) => _s.courtEveryWeekdaysAtTime(court, weekdays, '$time');
  static String get selectSlot => _s.selectSlot;
  static String get hamroFutsalPvtLtd => _s.hamroFutsalPvtLtd;
  static String get paymentAmountNotReady => _s.paymentAmountNotReady;
  static String receiptAcceptedForManualVerification(int score) =>
      _s.receiptAcceptedForManualVerification(score);
  static String get pleaseUploadYourPaymentProof =>
      _s.pleaseUploadYourPaymentProof;
  static String get pleaseAcceptTheBookingTerms =>
      _s.pleaseAcceptTheBookingTerms;
  static String get onlineQrProofAttached => _s.onlineQrProofAttached;
  static String get couldNotCreateBooking => _s.couldNotCreateBooking;
  static String get bookingSummary => _s.bookingSummary;
  static String get applyCoupon => _s.applyCoupon;
  static String get priceDetails => _s.priceDetails;
  static String get confirmedByVenue => _s.confirmedByVenue;
  static String totalRsAmount(String amount) => _s.totalRsAmount(amount);
  static String get totalDash => _s.totalDash;
  static String get confirmingEllipsis => _s.confirmingEllipsis;
  static String get starts => _s.starts;
  static String upToPlayers(int count) => _s.upToPlayers(count);
  static String weeklyRecurrenceSessions(String recurrence, int sessions) =>
      _s.weeklyRecurrenceSessions(recurrence, sessions);
  static String appliedSavedRs(String amount) => _s.appliedSavedRs(amount);
  static String minusRsAmount(String amount) => _s.minusRsAmount(amount);
  static String get couldNotCalculateThePrice => _s.couldNotCalculateThePrice;
  static String get slotCouldNotBeHeldTryAgain => _s.slotCouldNotBeHeldTryAgain;
  static String get estimatedTotal => _s.estimatedTotal;
  static String get venueConfirmsFinalPriceAndAdvance =>
      _s.venueConfirmsFinalPriceAndAdvance;
  static String get calculatingFinalPriceAndAdvance =>
      _s.calculatingFinalPriceAndAdvance;
  static String get oneSession => _s.oneSession;
  static String get checkingPaymentReceipt => _s.checkingPaymentReceipt;
  static String attachedWithSize(String size) => _s.attachedWithSize(size);
  static String get payExactAmountNote => _s.payExactAmountNote;
  static String get uploadClearReceiptScreenshotNote =>
      _s.uploadClearReceiptScreenshotNote;
  static String get incorrectPaymentMayBeCancelledNote =>
      _s.incorrectPaymentMayBeCancelledNote;
  static String bookingRequestSentDetails(
    String court,
    String time,
    String advance,
    String balance,
  ) => _s.bookingRequestSentDetails(court, time, advance, balance);
  static String get bookingConfirmedSuccessfully =>
      _s.bookingConfirmedSuccessfully;
  static String get couldNotCheckAvailabilityForSelectedDates =>
      _s.couldNotCheckAvailabilityForSelectedDates;
  static String get couldNotLoadSlotsForThisDate =>
      _s.couldNotLoadSlotsForThisDate;
  static String get forTheSelectedTime => _s.forTheSelectedTime;
  static String get allCourtsForThisDate => _s.allCourtsForThisDate;
  static String get noCourtsAvailableForDateAndTime =>
      _s.noCourtsAvailableForDateAndTime;
  static String get noCourtsAvailableForDate => _s.noCourtsAvailableForDate;
  static String get noneOfTheseDatesAreAvailable =>
      _s.noneOfTheseDatesAreAvailable;
  static String showingNearestAvailability(String fallbackType) =>
      _s.showingNearestAvailability(
        fallbackType.isEmpty ? 'false' : 'true',
        fallbackType,
      );
  static String get zeroCourts => _s.zeroCourts;
  static String availableOfTotal(int available, int total) =>
      _s.availableOfTotal(available, total);
  static String get oneOtherPersonViewingThisDate =>
      _s.oneOtherPersonViewingThisDate;
  static String othersViewingThisDate(int count) =>
      _s.othersViewingThisDate(count);
  static String get someSessionsAreUnavailable => _s.someSessionsAreUnavailable;
  static String get slotIsAvailable => _s.slotIsAvailable;
  static String allSessionsAvailable(int total) =>
      _s.allSessionsAvailable(total);
  static String get slotIsNotAvailable => _s.slotIsNotAvailable;
  static String noneOfTheSessionsAvailable(int total) =>
      _s.noneOfTheSessionsAvailable(total);
  static String get sessionNoun => _s.sessionNoun;
  static String sessionsUnavailableSummary(
    String taken,
    int available,
    int total,
  ) => _s.sessionsUnavailableSummary(taken, available, total);
  static String atTimeSuffix(String time) => _s.atTimeSuffix(time);
  static String scheduleDatesAlreadyTaken(String at) =>
      _s.scheduleDatesAlreadyTaken(at);
  static String thisDateIsFree(String at) => _s.thisDateIsFree(at);
  static String everyDateInScheduleIsFree(String at) =>
      _s.everyDateInScheduleIsFree(at);
  static String thisSlotIsAlreadyTaken(String at) =>
      _s.thisSlotIsAlreadyTaken(at);
  static String slotTakenOnEveryScheduleDate(String at) =>
      _s.slotTakenOnEveryScheduleDate(at);
  static String sessionLabelIs(String label) => _s.sessionLabelIs(label);
  static String datesCountAre(int count) => _s.datesCountAre(count);
  static String get theOtherSession => _s.theOtherSession;
  static String theOtherSessions(int count) => _s.theOtherSessions(count);
  static String get pronounIt => _s.pronounIt;
  static String get pronounThem => _s.pronounThem;
  static String alreadyTakenSkipAndBook(
    String which,
    String at,
    String them,
    String rest,
  ) => _s.alreadyTakenSkipAndBook(which, at, them, rest);
  static String unavailableWithCount(int count) =>
      _s.unavailableWithCount(count);
  static String availableWithCount(int count) => _s.availableWithCount(count);
  static String plusMore(String label) => _s.plusMore(label);
  static String get moreAvailableDateNoun => _s.moreAvailableDateNoun;
  static String get pickAnotherDate => _s.pickAnotherDate;
  static String skipAndBook(int count) => _s.skipAndBook(count);
  static String get oneDateIsUnavailable => _s.oneDateIsUnavailable;
  static String datesAreUnavailable(int count) => _s.datesAreUnavailable(count);
  static String get continueWithoutTheseDates => _s.continueWithoutTheseDates;
  static String get continueWithOneDate => _s.continueWithOneDate;
  static String continueWithDates(int count) => _s.continueWithDates(count);
  static String get chooseAnotherDateAndSlot => _s.chooseAnotherDateAndSlot;
  static String get noLocationsFoundForThatSearch =>
      _s.noLocationsFoundForThatSearch;
  static String get unableToSearchLocationsRightNow =>
      _s.unableToSearchLocationsRightNow;
  static String searchingExactLocationFor(String lat, String lng) =>
      _s.searchingExactLocationFor(lat, lng);
  static String pinnedLocation(String lat, String lng) =>
      _s.pinnedLocation(lat, lng);
  static String get searchPlaceOrTapMapForExactLocation =>
      _s.searchPlaceOrTapMapForExactLocation;
  static String get locatingEllipsis => _s.locatingEllipsis;
  static String get useLocation => _s.useLocation;
  static String get selectedPackage => _s.selectedPackage;
  static String get tapToChoosePackage => _s.tapToChoosePackage;
  static String get createShop => _s.createShop;
  static String stepOfTotal(int step, int total) => _s.stepOfTotal(step, total);
  static String advanceRequiredOnEveryCourt(String percent) =>
      _s.advanceRequiredOnEveryCourt(percent);
  static String get disabled => _s.disabled;
  static String nprAmount(String amount) => _s.nprAmount(amount);
  static String get cityFieldName => _s.cityFieldName;
  static String get countryFieldName => _s.countryFieldName;
  static String get futsalNameFieldName => _s.futsalNameFieldName;
  static String get contactPhoneFieldName => _s.contactPhoneFieldName;
  static String get contactEmailFieldName => _s.contactEmailFieldName;
  static String get couldNotLoadMoreVenues => _s.couldNotLoadMoreVenues;
  static String get startByAddingYourFirstVenue =>
      _s.startByAddingYourFirstVenue;
  static String get everythingYouOwnAtAGlance => _s.everythingYouOwnAtAGlance;
  static String get live => _s.live;
  static String get from => _s.from;
  static String get hide => _s.hide;
  static String get show => _s.show;
  static String get courtIsNowInactive => _s.courtIsNowInactive;
  static String get courtIsNowActive => _s.courtIsNowActive;
  static String playersCountLowercase(int count) =>
      _s.playersCountLowercase(count);
  static String get perHrSuffix => _s.perHrSuffix;
  static String get noAdvance => _s.noAdvance;
  static String get makeInactive => _s.makeInactive;
  static String get makeActive => _s.makeActive;
  static String get noFutsalVenuesYet => _s.noFutsalVenuesYet;
  static String get tryADifferentSearchOrFilter =>
      _s.tryADifferentSearchOrFilter;
  static String get createYourFirstVenueAndAddCourts =>
      _s.createYourFirstVenueAndAddCourts;
  static String get myFutsal => _s.myFutsal;
  static String confirmDeleteCourt(String name) => _s.confirmDeleteCourt(name);
  static String get showerArea => _s.showerArea;
  static String get firstAidDesk => _s.firstAidDesk;
  static String get starterPackagePrice => _s.starterPackagePrice;
  static String get growthPackagePrice => _s.growthPackagePrice;
  static String get elitePackagePrice => _s.elitePackagePrice;
  static String get oneVenueProfile => _s.oneVenueProfile;
  static String get basicListingVisibility => _s.basicListingVisibility;
  static String get manualBookingConfirmation => _s.manualBookingConfirmation;
  static String get priorityListingPlacement => _s.priorityListingPlacement;
  static String get bookingWorkflowSupport => _s.bookingWorkflowSupport;
  static String get basicReportingAccess => _s.basicReportingAccess;
  static String get multiCourtManagement => _s.multiCourtManagement;
  static String get premiumBrandingPlacement => _s.premiumBrandingPlacement;
  static String get prioritySupportRouting => _s.prioritySupportRouting;
  static String get advancePaymentOptional => _s.advancePaymentOptional;
  static String get cancellationAllowed => _s.cancellationAllowed;
  static String get cancellationNotAllowed => _s.cancellationNotAllowed;
  static String get refundsSupported => _s.refundsSupported;
  static String get refundsNotSupported => _s.refundsNotSupported;
  static String fieldIsRequired(String field) => _s.fieldIsRequired(field);
  static String fieldMustBePositiveNumber(String field) =>
      _s.fieldMustBePositiveNumber(field);
  static String get useLowercaseLettersNumbersHyphensOnly =>
      _s.useLowercaseLettersNumbersHyphensOnly;
  static String get enterAValidEmailAddress => _s.enterAValidEmailAddress;
  static String get enterAValidPhoneNumber => _s.enterAValidPhoneNumber;
  static String get establishedYearFieldName => _s.establishedYearFieldName;
  static String get enterAValidFourDigitYear => _s.enterAValidFourDigitYear;
  static String yearMustBeBetween1900And(int currentYear) =>
      _s.yearMustBeBetween1900And('$currentYear');
  static String get enterAValidWebsiteUrl => _s.enterAValidWebsiteUrl;
  static String get basicPriceFieldName => _s.basicPriceFieldName;
  static String get enterAValidPriceAmount => _s.enterAValidPriceAmount;
  static String get bookingAdvanceDaysFieldName =>
      _s.bookingAdvanceDaysFieldName;
  static String get cancellationWindowFieldName =>
      _s.cancellationWindowFieldName;
  static String get exactLocationIsRequired => _s.exactLocationIsRequired;
  static String get selectExactLocationFromMap => _s.selectExactLocationFromMap;
  static String get enterAValidUrlHttps => _s.enterAValidUrlHttps;
  static String get houseRulesFieldName => _s.houseRulesFieldName;
  static String get selectAtLeastOneAmenityOrFacility =>
      _s.selectAtLeastOneAmenityOrFacility;
  static String get chooseAPackageToContinue => _s.chooseAPackageToContinue;
  static String get couldNotReadTheSelectedFile =>
      _s.couldNotReadTheSelectedFile;

  // Court details
  static String get couldNotOpenMapsApplication =>
      _s.couldNotOpenMapsApplication;
  static String get venueHasNotSharedMapCoordinates =>
      _s.venueHasNotSharedMapCoordinates;
  static String get zoomIn => _s.zoomIn;
  static String get zoomOut => _s.zoomOut;
  static String hostingSince(Object since) => _s.hostingSince('$since');
  static String seeAllCount(Object count) => _s.seeAllCount('$count');
  static String get contactForHours => _s.contactForHours;
  static String get aboutThisVenue => _s.aboutThisVenue;
  static String get readLess => _s.readLess;
  static String get readMore => _s.readMore;
  static String get otherCategory => _s.otherCategory;
  static String get amenityCategoryFacility => _s.amenityCategoryFacility;
  static String get amenityCategoryLighting => _s.amenityCategoryLighting;
  static String get amenityCategoryAccess => _s.amenityCategoryAccess;
  static String get amenityCategoryComfort => _s.amenityCategoryComfort;
  static String get amenityCategoryFood => _s.amenityCategoryFood;
  static String get amenityCategorySafety => _s.amenityCategorySafety;
  static String get amenityCategoryConnectivity =>
      _s.amenityCategoryConnectivity;
  // Profile & feedback
  static String get couldNotParseFeedbackOptions =>
      _s.couldNotParseFeedbackOptions;
  static String get couldNotParseFeedbackList => _s.couldNotParseFeedbackList;
  static String get couldNotParseFeedbackDetails =>
      _s.couldNotParseFeedbackDetails;
  static String get themeLight => _s.themeLight;
  static String get themeDark => _s.themeDark;
  static String get themeSystem => _s.themeSystem;
  static String get biometricNotAvailableOnDevice =>
      _s.biometricNotAvailableOnDevice;
  static String get addReasonForDeletingAccount =>
      _s.addReasonForDeletingAccount;
  static String get myFeedback => _s.myFeedback;
  static String feedbackSubmissionsSummary(int count) =>
      _s.feedbackSubmissionsSummary(count);
  static String get noFeedbackYet => _s.noFeedbackYet;
  static String get submittedFeedbackWillAppearHere =>
      _s.submittedFeedbackWillAppearHere;
  static String get chooseFeedbackTypeAndCategoryFirst =>
      _s.chooseFeedbackTypeAndCategoryFirst;
  static String get rateYourExperienceBeforeSubmitting =>
      _s.rateYourExperienceBeforeSubmitting;
  static String get howWasYourExperience => _s.howWasYourExperience;
  static String get feedbackMessageHint => _s.feedbackMessageHint;
  static String get addAShortMessage => _s.addAShortMessage;
  static String get provideALittleMoreDetail => _s.provideALittleMoreDetail;
  static String get phoneNumberOrEmail => _s.phoneNumberOrEmail;
  static String get enterAValidContact => _s.enterAValidContact;
  static String get loadingOptions => _s.loadingOptions;
  static String get noFeedbackCategoriesAvailable =>
      _s.noFeedbackCategoriesAvailable;
  static String get noFeedbackTypesAvailable => _s.noFeedbackTypesAvailable;
  static String get ratingTerrible => _s.ratingTerrible;
  static String get thankYou => _s.thankYou;
  static String get loadingVersion => _s.loadingVersion;
  static String get madeBy => _s.madeBy;
  static String get ourMission => _s.ourMission;
  static String get whatWeOffer => _s.whatWeOffer;
  static String get whyWeBuiltThis => _s.whyWeBuiltThis;
  static String appVersionLabel(String version) => _s.appVersionLabel(version);
  static String versionLabel(String version) => _s.versionLabel(version);
  static String get feedbackDetailsCouldNotBeOpened =>
      _s.feedbackDetailsCouldNotBeOpened;
  static String get feedbackDetails => _s.feedbackDetails;
  static String get submittedOn => _s.submittedOn;
  static String get contactInfo => _s.contactInfo;
  static String get loggingOut => _s.loggingOut;
  static String get logOut => _s.logOut;
  static String get loading => _s.loading;
  static String get profileUnavailable => _s.profileUnavailable;
  static String get pullToRefreshYourAccount => _s.pullToRefreshYourAccount;
  static String get logOutQuestion => _s.logOutQuestion;
  static String get logOutConfirmationMessage => _s.logOutConfirmationMessage;
  static String get vendorAccountActive => _s.vendorAccountActive;
  static String get businessVerifiedReadyForBookings =>
      _s.businessVerifiedReadyForBookings;
  static String get vendorActiveVerificationPending =>
      _s.vendorActiveVerificationPending;
  static String get businessUnderReview => _s.businessUnderReview;
  static String get hamroFutsalReviewingBusinessInfo =>
      _s.hamroFutsalReviewingBusinessInfo;
  static String get businessVerificationRejected =>
      _s.businessVerificationRejected;
  static String get reviewBusinessInfoAndResubmit =>
      _s.reviewBusinessInfoAndResubmit;
  static String get vendorAccountSuspended => _s.vendorAccountSuspended;
  static String get contactSupportForAssistance =>
      _s.contactSupportForAssistance;
  static String get actionRequired => _s.actionRequired;
  static String get updateVendorInfoToContinue => _s.updateVendorInfoToContinue;
  static String get completeVendorSetup => _s.completeVendorSetup;
  static String get finishVenueAndBusinessDetails =>
      _s.finishVenueAndBusinessDetails;
  static String get startVendorSetup => _s.startVendorSetup;
  static String get addBusinessAndVenueDetails => _s.addBusinessAndVenueDetails;
  static String get male => _s.male;
  static String get female => _s.female;
  static String get others => _s.others;
  static String get personalInformation => _s.personalInformation;
  static String get contactInformation => _s.contactInformation;
  static String get nameNotProvided => _s.nameNotProvided;
  static String get addressNotSet => _s.addressNotSet;
  static String get businessName => _s.businessName;
  static String get enterYourBusinessName => _s.enterYourBusinessName;
  static String get enterYourPhoneNumber => _s.enterYourPhoneNumber;
  static String get enterYourBusinessAddress => _s.enterYourBusinessAddress;
  static String get addAnOptionalMessage => _s.addAnOptionalMessage;
  // Vendor dashboard draft
  static String bookingSavedReference(String reference) =>
      _s.bookingSavedReference(reference);
  static String paymentStatusLabel(String payment) =>
      _s.paymentStatusLabel(payment);
  static String referenceLabel(Object? reference) =>
      _s.referenceLabel('$reference');
  static String get receipt => _s.receipt;
  static String get goodDayVendor => _s.goodDayVendor;
  static String get freeSlots => _s.freeSlots;
  static String get collected => _s.collected;
  static String get due => _s.due;
  static String amountInRupees(Object amount) => _s.amountInRupees('$amount');
  static String dueRsAmount(Object amount) => _s.dueRsAmount('$amount');
  static String get todaySchedule => _s.todaySchedule;
  static String get tapFreeTimeToAddToBooking => _s.tapFreeTimeToAddToBooking;
  static String get selectFreeTimesFirst => _s.selectFreeTimesFirst;
  static String timesSelected(int count) => _s.timesSelected(count);
  static String slotTimeAndPrice(String timeRange, Object price) =>
      _s.slotTimeAndPrice(timeRange, '$price');
  static String get customerPhone => _s.customerPhone;
  static String get totalAmount => _s.totalAmount;
  static String get saveBooking => _s.saveBooking;
  static String get todaysBookings => _s.todaysBookings;
  static String get searchByNamePhoneOrReference =>
      _s.searchByNamePhoneOrReference;
  static String get searchBooking => _s.searchBooking;
  static String get noBookingsFound => _s.noBookingsFound;
  static String get tapAFreeTime => _s.tapAFreeTime;
  static String get selectedTimesWillAppearHere =>
      _s.selectedTimesWillAppearHere;

  // Expenses
  static String get expenseCategoryRent => _s.expenseCategoryRent;
  static String get expenseCategoryMaintenance => _s.expenseCategoryMaintenance;
  static String get expenseCategorySalaries => _s.expenseCategorySalaries;
  static String get expenseCategorySupplies => _s.expenseCategorySupplies;
  static String get expenseCategoryMarketing => _s.expenseCategoryMarketing;
  static String get expenseCategoryRefreshments =>
      _s.expenseCategoryRefreshments;
  static String get expenseCategoryInsurance => _s.expenseCategoryInsurance;
  static String get expenseCategoryUtilities => _s.expenseCategoryUtilities;
  static String get expenseCategoryOther => _s.expenseCategoryOther;
  static String get paymentMethodCash => _s.paymentMethodCash;
  static String get hourlySpend => _s.hourlySpend;
  static String get monthlySpend => _s.monthlySpend;
  static String get dailySpend => _s.dailySpend;
  static String get monthJan => _s.monthJan;
  static String get monthFeb => _s.monthFeb;
  static String get monthMar => _s.monthMar;
  static String get monthApr => _s.monthApr;
  static String get monthMay => _s.monthMay;
  static String get monthJun => _s.monthJun;
  static String get monthJul => _s.monthJul;
  static String get monthAug => _s.monthAug;
  static String get monthSep => _s.monthSep;
  static String get monthOct => _s.monthOct;
  static String get monthNov => _s.monthNov;
  static String get monthDec => _s.monthDec;
  static String get couldNotLoadExpenses => _s.couldNotLoadExpenses;
  static String expenseAdded(String amount) => _s.expenseAdded(amount);
  static String expenseDeleted(String amount) => _s.expenseDeleted(amount);
  static String expenseUpdated(String amount) => _s.expenseUpdated(amount);
  static String get editExpense => _s.editExpense;
  static String get newExpenseTitle => _s.newExpenseTitle;
  static String get pickACategory => _s.pickACategory;
  static String get details => _s.details;
  static String get updateExpense => _s.updateExpense;
  static String get saveExpense => _s.saveExpense;
  static String updateExpenseWithAmount(String amount) =>
      _s.updateExpenseWithAmount(amount);
  static String saveExpenseWithAmount(String amount) =>
      _s.saveExpenseWithAmount(amount);
  static String todayCommaDate(String date) => _s.todayCommaDate(date);
  static String fileSizeMb(String size) => _s.fileSizeMb(size);
  static String fileSizeKb(int size) => _s.fileSizeKb('$size');
  static String get totalSpend => _s.totalSpend;
  static String get trend => _s.trend;
  static String get byCategory => _s.byCategory;
  static String get byCourt => _s.byCourt;
  static String recordsForCategory(String category) =>
      _s.recordsForCategory(category);
  static String get selectAStartDate => _s.selectAStartDate;
  static String get sevenDays => _s.sevenDays;
  static String get thirtyDays => _s.thirtyDays;
  static String avgAmount(String amount) => _s.avgAmount(amount);
  static String plusMoreCount(int count) => _s.plusMoreCount(count);
  static String get enterAmountGreaterThan0 => _s.enterAmountGreaterThan0;
  static String get tapToEnterExpenseAmount => _s.tapToEnterExpenseAmount;
  static String avgPerDayWithEntries(String amount, int entries) =>
      _s.avgPerDayWithEntries(amount, entries);
  static String get dailyAverage => _s.dailyAverage;
  static String avgPerEntry(String amount) => _s.avgPerEntry(amount);
  static String get noExpensesYet => _s.noExpensesYet;
  static String get noMatchingRecords => _s.noMatchingRecords;
  static String get noRecordsYet => _s.noRecordsYet;
  static String get tryDifferentPeriodVenueOrCategory =>
      _s.tryDifferentPeriodVenueOrCategory;
  static String get expensesYouAddWillShowUpHere =>
      _s.expensesYouAddWillShowUpHere;
  static String get clearFilters => _s.clearFilters;
  static String get addExpense => _s.addExpense;
  static String get todayUpper => _s.todayUpper;
  static String get yesterdayUpper => _s.yesterdayUpper;
  static String dotEntryCount(int count) => _s.dotEntryCount(count);
  static String rangeEntriesSummary(String label, int count, String total) =>
      _s.rangeEntriesSummary(label, count, total);
  static String customDays(int days) => _s.customDays(days);
  static String get allMethods => _s.allMethods;
  static String get venueCourt => _s.venueCourt;
  static String get method => _s.method;
  // Messages
  static String get couldNotDownloadChatMedia => _s.couldNotDownloadChatMedia;
  static String tooManyRequestsTryAgainIn(int seconds) =>
      _s.tooManyRequestsTryAgainIn(seconds);
  static String get parseTargetConversations => _s.parseTargetConversations;
  static String get parseTargetRegisteredUsers => _s.parseTargetRegisteredUsers;
  static String get parseTargetConversation => _s.parseTargetConversation;
  static String get parseTargetGroupConversation =>
      _s.parseTargetGroupConversation;
  static String get parseTargetUserPresence => _s.parseTargetUserPresence;
  static String get parseTargetProfile => _s.parseTargetProfile;
  static String get parseTargetMessages => _s.parseTargetMessages;
  static String get parseTargetSentMessage => _s.parseTargetSentMessage;
  static String get conversationFilterDirect => _s.conversationFilterDirect;
  static String get conversationFilterGroups => _s.conversationFilterGroups;
  static String get conversationFilterArchived => _s.conversationFilterArchived;
  static String get conversation => _s.conversation;
  static String get noMessagesYetSayHello => _s.noMessagesYetSayHello;
  static String youPrefixed(String text) => _s.youPrefixed(text);
  static String get nowLower => _s.nowLower;
  static String hoursAgoShort(int hours) => _s.hoursAgoShort(hours);
  static String daysAgoShort(int days) => _s.daysAgoShort(days);
  static String get groupPhotoUpdated => _s.groupPhotoUpdated;
  static String get groupUpdated => _s.groupUpdated;
  static String get youJoinedTheGroup => _s.youJoinedTheGroup;
  static String get invitationDeclined => _s.invitationDeclined;
  static String get youLeftTheGroup => _s.youLeftTheGroup;
  static String get memberAdded => _s.memberAdded;
  static String membersAdded(int count) => _s.membersAdded(count);
  static String get conversationArchived => _s.conversationArchived;
  static String get conversationUnarchived => _s.conversationUnarchived;
  static String get conversationMuted => _s.conversationMuted;
  static String get conversationUnmuted => _s.conversationUnmuted;
  static String get participantBlocked => _s.participantBlocked;
  static String get participantUnblocked => _s.participantUnblocked;
  static String get messageDeletedSuccess => _s.messageDeletedSuccess;
  static String get messageMaxFiles => _s.messageMaxFiles;
  static String get locationUnavailableCheckPermission =>
      _s.locationUnavailableCheckPermission;
  static String get sharedLocation => _s.sharedLocation;
  static String saveFileNamed(String name) => _s.saveFileNamed(name);
  static String get couldNotLoadMessages => _s.couldNotLoadMessages;
  static String memberCount(int count) => _s.memberCount(count);
  static String get checkingPresence => _s.checkingPresence;
  static String get couldNotLoadUsers => _s.couldNotLoadUsers;
  static String get selectAtLeastOneMember => _s.selectAtLeastOneMember;
  static String groupMaxMembers(int max) => _s.groupMaxMembers(max);
  static String tapToAddUpToPeople(int max) => _s.tapToAddUpToPeople(max);
  static String get noUsersFound => _s.noUsersFound;
  static String get registeredUsersWillAppearHere =>
      _s.registeredUsersWillAppearHere;
  static String declineInvitationTo(String title) =>
      _s.declineInvitationTo(title);
  static String get couldNotLoadConversations => _s.couldNotLoadConversations;
  static String get selectAConversation => _s.selectAConversation;
  static String get pickAChatToReadAndReply => _s.pickAChatToReadAndReply;
  static String get couldNotLoadMoreConversations =>
      _s.couldNotLoadMoreConversations;
  static String conversationsUnreadSummary(int count, int unread) =>
      '${_s.conversationsUnreadSummary(count)}${unread > 0 ? _s.conversationsUnreadSummarySuffix(unread) : ''}';
  static String get creatingEllipsis => _s.creatingEllipsis;
  static String get cannotSendMessagesInConversation =>
      _s.cannotSendMessagesInConversation;
  static String get typeHere => _s.typeHere;
  static String get notifyEveryone => _s.notifyEveryone;
  static String get deletedMessage => _s.deletedMessage;
  static String replyingTo(String senderName, String body) => _s.replyingTo(
    senderName.isEmpty ? _s.replyingToMessageFallback : senderName,
    body,
  );
  static String get attachment => _s.attachment;
  static String get messageDeleted => _s.messageDeleted;
  static String opensInTheApp(String text) => _s.opensInTheApp(text);
  static String userNumber(int id) => _s.userNumber(id);
  static String get selectAtLeastOneNewMember => _s.selectAtLeastOneNewMember;
  static String get choosePeopleToAddInGroup => _s.choosePeopleToAddInGroup;
  static String addMemberCount(int count) => _s.addMemberCount(count);
  static String get noMatchingConversations => _s.noMatchingConversations;
  static String get tryDifferentFilterOrSearch => _s.tryDifferentFilterOrSearch;
  static String get yourConversationsWillAppearHere =>
      _s.yourConversationsWillAppearHere;
  // Dashboard
  static String get greetingFallbackName => _s.greetingFallbackName;
  static String get checkConnectionAndTryAgain => _s.checkConnectionAndTryAgain;
  static String get rsPriceUnavailable => _s.rsPriceUnavailable;
  static String rsDotAmount(String amount) => _s.rsDotAmount(amount);
  static String distanceKm(String value) => _s.distanceKm(value);
  static String get thisMonthRevenue => _s.thisMonthRevenue;
  static String get bookedSlotsThisMonth => _s.bookedSlotsThisMonth;
  static String get courtUsageToday => _s.courtUsageToday;
  static String get cancelledReservations => _s.cancelledReservations;
  static String get openNow => _s.openNow;
  static String get closedNow => _s.closedNow;
  static String get merchant => _s.merchant;
  static String get futsalVendor => _s.futsalVendor;
  static String get management => _s.management;
  static String activeNowAt(String time) => _s.activeNowAt(time);
  static String get markRead => _s.markRead;
  static String get read => _s.read;
  // Rental services
  static String get equipment => _s.equipment;
  static String get history => _s.history;
  static String get football => _s.football;
  static String get trainingBibs => _s.trainingBibs;
  static String get goalkeeperGloves => _s.goalkeeperGloves;
  static String get conesSetOf10 => _s.conesSetOf10;
  static String get shinGuards => _s.shinGuards;
  static String get futsalBoots => _s.futsalBoots;
  static String get waterBottle => _s.waterBottle;
  static String get towel => _s.towel;
  static String get tacticBoard => _s.tacticBoard;
  static String get bibs => _s.bibs;
  static String get gloves => _s.gloves;
  static String get cones => _s.cones;
  static String get boots => _s.boots;
  static String get bottle => _s.bottle;
  static String get overdue => _s.overdue;
  static String get returned => _s.returned;
  static String equipmentAdded(String name) => _s.equipmentAdded(name);
  static String get addEquipmentFirst => _s.addEquipmentFirst;
  static String rentalStartedFor(String customer) =>
      _s.rentalStartedFor(customer);
  static String markedReturned(String customer) => _s.markedReturned(customer);
  static String get addItemsToStartRenting => _s.addItemsToStartRenting;
  static String equipmentRateAndDeposit(
    String kind,
    String hourlyRate,
    String deposit,
  ) => _s.equipmentRateAndDeposit(kind, hourlyRate, deposit);
  static String get outOfStock => _s.outOfStock;
  static String availableCount(int count) => _s.availableCount(count);
  static String percentOfStockRented(int percent) =>
      _s.percentOfStockRented(percent);
  static String get noActiveRentals => _s.noActiveRentals;
  static String get noHistoryYet => _s.noHistoryYet;
  static String get startNewRentalFromButtonBelow =>
      _s.startNewRentalFromButtonBelow;
  static String get returnedRentalsWillAppearHere =>
      _s.returnedRentalsWillAppearHere;
  static String equipmentWithQty(String name, int qty) =>
      _s.equipmentWithQty(name, qty);
  static String get overdueBy => _s.overdueBy;
  static String get returnsIn => _s.returnsIn;
  static String returnedAt(String time) => _s.returnedAt(time);
  static String get itemType => _s.itemType;
  static String get pickAType => _s.pickAType;
  static String get pickAnItem => _s.pickAnItem;
  static String nameWithHourlyRate(String name, String hourlyRate) =>
      _s.nameWithHourlyRate(name, hourlyRate);
  static String depositPerUnit(String deposit) => _s.depositPerUnit(deposit);
  static String get quantityAndDuration => _s.quantityAndDuration;
  static String onlyUnitsAvailable(int count) => _s.onlyUnitsAvailable(count);
  static String get summary => _s.summary;
  static String get rate => _s.rate;
  static String rateBreakdown(String rate, int qty, int hours) =>
      _s.rateBreakdown(rate, qty, hours);

  // Receipt validation
  static String get receiptImageDoesNotExist => _s.receiptImageDoesNotExist;
  static String get receiptImageResolutionTooLow =>
      _s.receiptImageResolutionTooLow;
  static String get receiptImageFileTooSmall => _s.receiptImageFileTooSmall;
  static String get receiptImageAppearsBlank => _s.receiptImageAppearsBlank;
  static String get receiptImageAppearsBlurry => _s.receiptImageAppearsBlurry;
  static String get receiptImageQualityNotAcceptable =>
      _s.receiptImageQualityNotAcceptable;
  static String get receiptTextNotReadable => _s.receiptTextNotReadable;
  static String get merchantNameDoesNotMatch => _s.merchantNameDoesNotMatch;
  static String expectedAmountNotFound(String amount) =>
      _s.expectedAmountNotFound(amount);
  static String get paymentNotMarkedSuccessful => _s.paymentNotMarkedSuccessful;
  static String get successfulPaymentStatusNotFound =>
      _s.successfulPaymentStatusNotFound;
  static String get transactionReferenceIdNotFound =>
      _s.transactionReferenceIdNotFound;
  static String get transactionDateNotFound => _s.transactionDateNotFound;
  static String get qrCodeNotFound => _s.qrCodeNotFound;
  static String get transactionIdAlreadySubmitted =>
      _s.transactionIdAlreadySubmitted;
  static String receiptValidationScoreBelow(int score) =>
      _s.receiptValidationScoreBelow(score);
  static String get proofAcceptedPendingVerification =>
      _s.proofAcceptedPendingVerification;
  static String unableToProcessPaymentReceipt(Object error) =>
      _s.unableToProcessPaymentReceipt('$error');
  // Form validators
  static String get fullNameRequired => _s.fullNameRequired;
  static String get fullNameTooLong => _s.fullNameTooLong;
  static String get fullNameLettersOnly => _s.fullNameLettersOnly;
  static String get emailRequired => _s.emailRequired;
  static String get emailTooLong => _s.emailTooLong;
  static String get enterValidEmailAddress => _s.enterValidEmailAddress;
  static String get phoneNumberRequired => _s.phoneNumberRequired;
  static String get enterValidNepalMobile => _s.enterValidNepalMobile;
  static String get useNepalMobileFormat => _s.useNepalMobileFormat;
  // Router fallbacks & security
  static String get chooseVenueAgainToViewSlots =>
      _s.chooseVenueAgainToViewSlots;
  static String get bookingNoLongerAvailable => _s.bookingNoLongerAvailable;
  static String get pickYourSlotAgainToContinue =>
      _s.pickYourSlotAgainToContinue;
  static String get biometricSignInReason => _s.biometricSignInReason;
  // Upload validation
  static String get fileIsEmptyAttachAgain => _s.fileIsEmptyAttachAgain;
  static String get fileCameThroughEmpty => _s.fileCameThroughEmpty;
  static String get fileCouldNotBeRead => _s.fileCouldNotBeRead;
  static String get fileNoLongerAvailable => _s.fileNoLongerAvailable;
  static String get unsupportedFileTypeAttachSupported =>
      _s.unsupportedFileTypeAttachSupported;
  static String get theSelectedFile => _s.theSelectedFile;
  static String uploadAtMostFiles(int count) => _s.uploadAtMostFiles(count);
  static String namedFileIsEmpty(String name) => _s.namedFileIsEmpty(name);
  static String namedFileMustBeOrSmaller(String name, String size) =>
      _s.namedFileMustBeOrSmaller(name, size);
  static String uploadExceedsRequestLimit(String size) =>
      _s.uploadExceedsRequestLimit(size);
  static String selectedFilesExceedRequestLimit(String size) =>
      _s.selectedFilesExceedRequestLimit(size);
  static String onlyFileTypesCanBeUploaded(String types) =>
      _s.onlyFileTypesCanBeUploaded(types);
  static String fileMustBeOrSmaller(String size) =>
      _s.fileMustBeOrSmaller(size);
  static String imageCouldNotBeReducedBelow(String size) =>
      _s.imageCouldNotBeReducedBelow(size);
  static String imageStillLargerThan(String size) =>
      _s.imageStillLargerThan(size);
  // Greetings
  static String get goodMorning => _s.goodMorning;
  static String get goodAfternoon => _s.goodAfternoon;
  static String get goodEvening => _s.goodEvening;
  // Calendar
  static String get englishAdCalendar => _s.englishAdCalendar;
  static String get nepaliBsCalendar => _s.nepaliBsCalendar;
  static String get adShort => _s.adShort;
  static String get bsShort => _s.bsShort;
  static String get englishLetters => _s.englishLetters;
  static String get nepaliScript => _s.nepaliScript;
  // Network & API errors
  static String get serverMalformedData => _s.serverMalformedData;
  static String get serverErrorRetry => _s.serverErrorRetry;
  static String get noInternetConnectionCheckSettings =>
      _s.noInternetConnectionCheckSettings;
  static String get networkUnreachable => _s.networkUnreachable;
  static String get noContentFound => _s.noContentFound;
  static String get fileTooLargeForServer => _s.fileTooLargeForServer;
  static String get serverCouldNotReadAttachment =>
      _s.serverCouldNotReadAttachment;
  static String get sessionEnded => _s.sessionEnded;
  static String get sessionExpiredLogInAgain => _s.sessionExpiredLogInAgain;
  static String get uploadSendTimedOut => _s.uploadSendTimedOut;
  static String get uploadProcessingTimedOut => _s.uploadProcessingTimedOut;
  static String get unexpectedError => _s.unexpectedError;
  // Push notifications
  static String get highImportanceNotificationsChannel =>
      _s.highImportanceNotificationsChannel;
  static String get highImportanceNotificationsDescription =>
      _s.highImportanceNotificationsDescription;
  static String get youHaveNewNotification => _s.youHaveNewNotification;
  // Shared widgets
  static String get mapPreviewUnavailable => _s.mapPreviewUnavailable;
  static String get couldNotLoadThisPage => _s.couldNotLoadThisPage;
  static String get typePrefix => _s.typePrefix;
  static String get belowToConfirm => _s.belowToConfirm;
  static String get belowToContinue => _s.belowToContinue;
  static String get selectBackgroundColor => _s.selectBackgroundColor;
  static String get selectTextColor => _s.selectTextColor;
  static String pageOfTotal(int page, int total) => _s.pageOfTotal(page, total);

  // Products
  static String get selectVenueFirst => _s.selectVenueFirst;
  static String get deleteProductQuestion => _s.deleteProductQuestion;
  static String removeProductConfirmation(String name) =>
      _s.removeProductConfirmation(name);
  static String productsCount(Object count) => _s.productsCount('$count');
  static String get manageProductsSubtitle => _s.manageProductsSubtitle;
  static String get selectVenue => _s.selectVenue;
  static String get productList => _s.productList;
  static String get editProduct => _s.editProduct;
  static String get deleteProduct => _s.deleteProduct;
  static String get updateProduct => _s.updateProduct;
  static String get createProduct => _s.createProduct;
  static String get productName => _s.productName;
  static String get productNameHint => _s.productNameHint;
  static String get enterProductName => _s.enterProductName;
  static String get enterValidPrice => _s.enterValidPrice;
  static String get activeProduct => _s.activeProduct;
  static String get visibleForSale => _s.visibleForSale;
  static String get hiddenFromSale => _s.hiddenFromSale;
  static String get noProductsYet => _s.noProductsYet;
  static String get tapCreateToAddFirstProduct => _s.tapCreateToAddFirstProduct;
  static String get selectVenueToManageProducts =>
      _s.selectVenueToManageProducts;
  static String itemsYouSellAt(String venueName) =>
      _s.itemsYouSellAt(venueName);
  static String get newProduct => _s.newProduct;
  static String get totalProducts => _s.totalProducts;
  static String get averagePrice => _s.averagePrice;
  static String get searchProducts => _s.searchProducts;
  static String get noProductsMatchSearch => _s.noProductsMatchSearch;
  static String get actionsUpper => _s.actionsUpper;
  static String get noVenuesFoundForProducts => _s.noVenuesFoundForProducts;
  static String get productCreatedSuccessfully => _s.productCreatedSuccessfully;
  static String get productUpdatedSuccessfully => _s.productUpdatedSuccessfully;
  static String get productDeletedSuccessfully => _s.productDeletedSuccessfully;
  static String get couldNotReadVenuesFromServer =>
      _s.couldNotReadVenuesFromServer;
  static String get couldNotReadProductsFromServer =>
      _s.couldNotReadProductsFromServer;
  // Auth
  static String get venueVendor => _s.venueVendor;
  static String get yourEmail => _s.yourEmail;
  static String get otpResentSuccessfullyCheckEmail =>
      _s.otpResentSuccessfullyCheckEmail;
  static String get otpVerifiedSuccessfully => _s.otpVerifiedSuccessfully;
  static String get otpVerifiedSuccessfullyShort =>
      _s.otpVerifiedSuccessfullyShort;
  static String get otpVerifiedPleaseSignIn => _s.otpVerifiedPleaseSignIn;
  static String enterOtpCodeSentTo(int otpLength, String email) =>
      _s.enterOtpCodeSentTo(otpLength, email);
  static String enterOtpCodeAndChooseNewPassword(int otpLength, String email) =>
      _s.enterOtpCodeAndChooseNewPassword(otpLength, email);
  static String chooseNewPasswordFor(String email) =>
      _s.chooseNewPasswordFor(email);
  static String get verifyOtp => _s.verifyOtp;
  static String resendCodeIn(int seconds) => _s.resendCodeIn(seconds);
  static String get sendOtp => _s.sendOtp;
  static String get noBiometricAccountSaved => _s.noBiometricAccountSaved;
  static String get emailIsRequired => _s.emailIsRequired;
  static String get pleaseConfirmYourPassword => _s.pleaseConfirmYourPassword;
  static String get welcomeBack => _s.welcomeBack;
  static String get createYourAccount => _s.createYourAccount;
  static String get signInToBookMatchesOrManageVenue =>
      _s.signInToBookMatchesOrManageVenue;
  static String get joinAsPlayerOrVenueVendor => _s.joinAsPlayerOrVenueVendor;
  static String get signInTitle => _s.signInTitle;
  static String get createAccountTitle => _s.createAccountTitle;
  static String get newToHamroFutsal => _s.newToHamroFutsal;
  static String get alreadyHaveAnAccount => _s.alreadyHaveAnAccount;
  static String get createAccount => _s.createAccount;
  static String get signIn => _s.signIn;
  static String get termsAndConditions => _s.termsAndConditions;
  static String get privacyPolicy => _s.privacyPolicy;
  static String get signInWithBiometrics => _s.signInWithBiometrics;
  static String get loginSuccessful => _s.loginSuccessful;
  static String get googleSignInNotConfigured => _s.googleSignInNotConfigured;
  static String googleErrorCode(Object code) => _s.googleErrorCode('$code');
  static String get registrationSuccessful => _s.registrationSuccessful;
  static String get pleaseSelectAccountType => _s.pleaseSelectAccountType;
  static String get youMustAcceptTermsToContinue =>
      _s.youMustAcceptTermsToContinue;
  static String get iAgreeToThe => _s.iAgreeToThe;
  static String get terms => _s.terms;
  static String get andConnector => _s.andConnector;
  static String stepLabel(int step) => _s.stepLabel(step);
  // Rewards & coupons
  static String percentOff(String percent) => _s.percentOff(percent);
  static String amountOff(String amount) => _s.amountOff(amount);
  static String rsAmountOff(String amount) => _s.rsAmountOff(amount);
  static String get pointsEarnedTitle => _s.pointsEarnedTitle;
  static String get pointsRedeemedTitle => _s.pointsRedeemedTitle;
  static String get pointsExpiredTitle => _s.pointsExpiredTitle;
  static String get pointsAdjustedTitle => _s.pointsAdjustedTitle;
  static String get thatsAllYourRewardActivity => _s.thatsAllYourRewardActivity;
  static String get pointsUsed => _s.pointsUsed;
  static String get pointsLeft => _s.pointsLeft;
  static String get validTill => _s.validTill;
  static String worthAmount(String amount) => _s.worthAmount(amount);
  static String youCanRedeemPointsForCoupon(String points, String worth) =>
      _s.youCanRedeemPointsForCoupon(points, worth);
  static String morePointsForNextCoupon(String points) =>
      _s.morePointsForNextCoupon(points);
  static String get couponUnlocked => _s.couponUnlocked;
  static String get nextCoupon => _s.nextCoupon;
  static String pointsProgress(String current, String target) =>
      _s.pointsProgress(current, target);
  static String get couponsAvailable => _s.couponsAvailable;
  static String couponWithCode(String code) => _s.couponWithCode(code);
  static String refWithValue(String reference) => _s.refWithValue(reference);
  static String balanceWithPoints(String points) =>
      _s.balanceWithPoints(points);
  static String pointsEqualsCoupon(String points, String amount) =>
      _s.pointsEqualsCoupon(points, amount);
  static String pointsEqualsDiscountCoupon(String points) =>
      _s.pointsEqualsDiscountCoupon(points);
  static String get applyCouponAtCheckout => _s.applyCouponAtCheckout;
  static String get enterACouponCode => _s.enterACouponCode;
  // App update & change password
  static String get emptyAppStoreLookupResponse =>
      _s.emptyAppStoreLookupResponse;
  static String get appStoreLookupFailed => _s.appStoreLookupFailed;
  static String get noInternetConnection => _s.noInternetConnection;
  static String get passwordUpdatedSuccessfully =>
      _s.passwordUpdatedSuccessfully;
  static String get couldNotChangePassword => _s.couldNotChangePassword;
  // Venue filter & help center
  static String get morningTimeRange => _s.morningTimeRange;
  static String get afternoonTimeRange => _s.afternoonTimeRange;
  static String get eveningTimeRange => _s.eveningTimeRange;
  static String get setYourHourlyBudget => _s.setYourHourlyBudget;
  static String get minimum => _s.minimum;
  static String get maximum => _s.maximum;
  static String get courtPreferences => _s.courtPreferences;
  static String get chooseCourtAndMatchYouPrefer =>
      _s.chooseCourtAndMatchYouPrefer;
  static String get onlyShowCourtsWithPreferredRating =>
      _s.onlyShowCourtsWithPreferredRating;
  static String get anyRating => _s.anyRating;
  static String ratingAndUp(String rating) => _s.ratingAndUp(rating);
  static String get tapStarToSetMinimumRating => _s.tapStarToSetMinimumRating;
  static String get selectConvenientPlayTimes => _s.selectConvenientPlayTimes;
  static String get yourPreferencesAreReady => _s.yourPreferencesAreReady;
  static String get refineYourSearch => _s.refineYourSearch;
  static String get adjustSelectionsToSeeMatchingCourts =>
      _s.adjustSelectionsToSeeMatchingCourts;
  static String get chooseBudgetCourtTypeRatingOrPlayTime =>
      _s.chooseBudgetCourtTypeRatingOrPlayTime;
  static String countSelected(Object count) => _s.countSelected('$count');
  static String get couldNotLoadOptions => _s.couldNotLoadOptions;
  static String get showingAllCourts => _s.showingAllCourts;
  static String filtersSelected(int count) => _s.filtersSelected(count);
  static String get showCourts => _s.showCourts;
  static String get couldNotLoadFaqs => _s.couldNotLoadFaqs;
  static String get noFaqsYet => _s.noFaqsYet;
  static String get faqsWillAppearHere => _s.faqsWillAppearHere;
  static String get couldNotLoadHelpTopics => _s.couldNotLoadHelpTopics;
  static String get noHelpTopicsYet => _s.noHelpTopicsYet;
  static String get helpGuidesWillAppearHere => _s.helpGuidesWillAppearHere;
  static String get connectWithUs => _s.connectWithUs;
  static String get reachOutOnSocialMedia => _s.reachOutOnSocialMedia;
  static String get helpGuides => _s.helpGuides;
  static String get helpCenter => _s.helpCenter;
  static String get helpCenterSubtitle => _s.helpCenterSubtitle;
  static String get searchFaqsAndGuides => _s.searchFaqsAndGuides;
  static String noResultsFor(String query) => _s.noResultsFor(query);
  static String get tryDifferentWordOrBrowse => _s.tryDifferentWordOrBrowse;
  // Account & settlements
  static String get bookingIncome => _s.bookingIncome;
  static String get opponentMatchIncome => _s.opponentMatchIncome;
  static String get platformCommission => _s.platformCommission;
  static String get settlementPayout => _s.settlementPayout;
  static String get refund => _s.refund;
  static String get adjustment => _s.adjustment;
  static String get processing => _s.processing;
  static String get failed => _s.failed;
  static String get enterAValidAmount => _s.enterAValidAmount;
  static String amountCantExceed(String amount) => _s.amountCantExceed(amount);
  static String settleTheFull(String amount) => _s.settleTheFull(amount);
  static String uploadReceiptBeforeSubmittingMax(int maxSizeMb) =>
      _s.uploadReceiptBeforeSubmittingMax(maxSizeMb);
  static String get allFutsals => _s.allFutsals;
  static String proofTypesMaxSize(String types, int maxSizeMb) =>
      _s.proofTypesMaxSize(types, maxSizeMb);
  static String get scanAndPay => _s.scanAndPay;
  static String get sendCommissionUsingQr => _s.sendCommissionUsingQr;
  static String get commissionToPay => _s.commissionToPay;
  static String get confirmThePayment => _s.confirmThePayment;
  static String get enterWhatYouSentAndAttachReceipt =>
      _s.enterWhatYouSentAndAttachReceipt;
  static String get commissionAmountNpr => _s.commissionAmountNpr;
  static String get fullCommissionInOneRequest => _s.fullCommissionInOneRequest;
  static String get transactionReference => _s.transactionReference;
  static String get transactionReferenceHint => _s.transactionReferenceHint;
  static String get enterPaymentTransactionReference =>
      _s.enterPaymentTransactionReference;
  static String get noteOptional => _s.noteOptional;
  static String get paymentRemark => _s.paymentRemark;
  static String get submitting => _s.submitting;
  static String get submitCommissionPayment => _s.submitCommissionPayment;
  static String fileSizeBytes(int bytes) => _s.fileSizeBytes(bytes);
  static String get uploadPaymentProof => _s.uploadPaymentProof;
  static String get uploadReceiptBeforeSubmitting =>
      _s.uploadReceiptBeforeSubmitting;
  static String get noAccountActivityYet => _s.noAccountActivityYet;
  static String get accountActivityWillAppearHere =>
      _s.accountActivityWillAppearHere;
  static String get manage => _s.manage;
  static String get commissionPaymentNotAvailable =>
      _s.commissionPaymentNotAvailable;
  static String get futsalBreakdown => _s.futsalBreakdown;
  static String get futsalBreakdownTitle => _s.futsalBreakdownTitle;
  static String futsalCount(int count) => _s.futsalCount(count);
  static String get noSettlementsYet => _s.noSettlementsYet;
  static String settlementsInProgress(int inProgress, int total) =>
      _s.settlementsInProgress(inProgress, total);
  static String settlementsTotal(int total) => _s.settlementsTotal(total);
  static String get noFutsalsYet => _s.noFutsalsYet;
  static String get futsalBalancesWillAppearHere =>
      _s.futsalBalancesWillAppearHere;
  static String get noCommissionDueForFutsal => _s.noCommissionDueForFutsal;
  static String get settlementNotAvailableForFutsal =>
      _s.settlementNotAvailableForFutsal;
  static String get couldNotLoadFutsalBreakdown =>
      _s.couldNotLoadFutsalBreakdown;
  static String get requestSettlementEmptyMessage =>
      _s.requestSettlementEmptyMessage;
  static String get scanAnyQrToPay => _s.scanAnyQrToPay;
  static String get scanToPay => _s.scanToPay;
  static String get payTo => _s.payTo;
  static String get phoneNumberCopied => _s.phoneNumberCopied;
  static String get chooseAnExistingPhoto => _s.chooseAnExistingPhoto;
  static String get takeAPhotoNow => _s.takeAPhotoNow;
  static String get browseYourDocuments => _s.browseYourDocuments;
  static String get addAFile => _s.addAFile;
  static String get cameraDidNotFinishSavingImage =>
      _s.cameraDidNotFinishSavingImage;
  static String get fileCameThroughEmptySelectAgain =>
      _s.fileCameThroughEmptySelectAgain;
  static String get couldNotOpenThatFile => _s.couldNotOpenThatFile;
  static String get mediaLibrarySubtitle => _s.mediaLibrarySubtitle;
  static String get uploadWithoutUsableMediaReference =>
      _s.uploadWithoutUsableMediaReference;
  static String get uploadAtMostFiveFiles => _s.uploadAtMostFiveFiles;
  static String get selectedImageIsEmpty => _s.selectedImageIsEmpty;
  static String get couldNotSelectImage => _s.couldNotSelectImage;
  static String get couldNotOpenCamera => _s.couldNotOpenCamera;
  static String filesCount(int count) => _s.filesCount(count);
  static String uploadFileToMediaLibraryQuoted(String file) =>
      _s.uploadFileToMediaLibraryQuoted(file);
  static String uploadFilesToMediaLibrary(String files) =>
      _s.uploadFilesToMediaLibrary(files);
  static String get remoteMediaIsReadOnly => _s.remoteMediaIsReadOnly;
  static String removeItemFromSavedCollection(String name) =>
      _s.removeItemFromSavedCollection(name);
  static String moreSelected(int count) => _s.moreSelected(count);
  static String get chooseFromYourPhotos => _s.chooseFromYourPhotos;
  static String get takeANewPhoto => _s.takeANewPhoto;
  static String get browseDocuments => _s.browseDocuments;
  static String get mediaUploadedSuccessfully => _s.mediaUploadedSuccessfully;
  static String hoursAgoPlural(int hours) => _s.hoursAgoPlural(hours);
  static String daysAgoPlural(int days) => _s.daysAgoPlural(days);
  static String get venuesYouSaveForLater => _s.venuesYouSaveForLater;
  static String savedVenuesCount(int count) => _s.savedVenuesCount(count);
}
