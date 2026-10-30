// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutApp => 'About App';

  @override
  String get aboutThisCourt => 'About this court';

  @override
  String get accept => 'Accept';

  @override
  String get acceptBooking => 'Accept booking';

  @override
  String get rejectBooking => 'Reject booking';

  @override
  String get acceptBookingConfirmation =>
      'Confirm the verified payment amount to accept this booking.';

  @override
  String get approvePaymentProofConfirmation =>
      'Confirm the actual received amount and add optional remarks.';

  @override
  String get rejectBookingConfirmation =>
      'Add a reason for rejecting this payment (optional).';

  @override
  String get actualAmount => 'Actual amount';

  @override
  String get verifiedAmount => 'Verified amount';

  @override
  String get verifiedVenue => 'Verified venue';

  @override
  String get paymentNote => 'Payment note';

  @override
  String get rejectionReason => 'Reason';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get bookingConfirmedToCompleted =>
      'Booking status changed from Confirmed to Completed.';

  @override
  String get couldNotCompleteBooking =>
      'Could not complete the booking. Please try again.';

  @override
  String get bookingAcceptedSuccessfully => 'Booking accepted successfully.';

  @override
  String get bookingRejectedSuccessfully => 'Booking rejected successfully.';

  @override
  String get couldNotAcceptBooking => 'Could not accept the booking.';

  @override
  String get couldNotRejectBooking => 'Could not reject the booking.';

  @override
  String get paymentVerifiedSuccessfully => 'Payment verified successfully.';

  @override
  String get paymentRejectedSuccessfully => 'Payment rejected successfully.';

  @override
  String get couldNotVerifyPayment => 'Could not verify the payment.';

  @override
  String get couldNotRejectPayment => 'Could not reject the payment.';

  @override
  String get noPaymentToVerify => 'This booking has no payment to verify.';

  @override
  String get acceptWithin => 'Accept within';

  @override
  String get approvePayment => 'Approve payment';

  @override
  String get createYourTeamFirst => 'Create your team first';

  @override
  String get matchConfirmed => 'Match confirmed';

  @override
  String get rejectPayment => 'Reject payment';

  @override
  String get preferredVenue => 'Preferred venue';

  @override
  String get rejectionReasonHint =>
      'Why is this proof invalid? (e.g. wrong amount)';

  @override
  String get search => 'Search';

  @override
  String get searchVenueToCheckSlots => 'Search venue to check slots';

  @override
  String get totalCourtFeeRs => 'Total court fee (Rs)';

  @override
  String get youNeedATeamToChallengeOpponents =>
      'You need a team before you can challenge opponents. Create your team with its players first.';

  @override
  String get finalPricingConfirmedByServer =>
      'Final pricing is confirmed by the server.';

  @override
  String get requestExpiredMessage =>
      'This request has expired and can no longer be accepted.';

  @override
  String get invitationNoLongerAvailable =>
      'This invitation is no longer available.';

  @override
  String get requestJustAcceptedByAnotherTeam =>
      'This request was just accepted by another team.';

  @override
  String get submitAndAccept => 'Submit & Accept';

  @override
  String get whichTeamWillPlay => 'Which team will play?';

  @override
  String get yourTeamShare => 'Your team\'s share';

  @override
  String get account => 'Account';

  @override
  String get financeAndPayouts => 'Finance & Payouts';

  @override
  String get accountStatement => 'Statement';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get credit => 'Credit';

  @override
  String get debit => 'Debit';

  @override
  String get bookingDate => 'Booking date';

  @override
  String get recorded => 'Recorded';

  @override
  String get reference => 'Reference';

  @override
  String get bookedOn => 'Booked on';

  @override
  String get bookedBy => 'Booked by';

  @override
  String get selectClosureDate => 'Please select a date properly.';

  @override
  String get selectClosureStartAndEnd => 'Select a start and end time.';

  @override
  String get closureEndAfterStart => 'End time must be later than start time.';

  @override
  String get loadingBookings => 'Loading bookings…';

  @override
  String get each => 'each';

  @override
  String get unknownPlayer => 'Unknown player';

  @override
  String get futsalCourt => 'Futsal court';

  @override
  String get customerBooking => 'Customer booking';

  @override
  String get futsalBooking => 'Futsal booking';

  @override
  String get availableBalance => 'Available balance';

  @override
  String get commissionPaid => 'Commission paid';

  @override
  String get couldNotParseAccountFromServer =>
      'Could not read your account from the server.';

  @override
  String get couldNotSubmitSettlementRequest =>
      'Could not submit the settlement request.';

  @override
  String get pendingClearance => 'Pending clearance';

  @override
  String get requestSettlement => 'Request Settlement';

  @override
  String get commissionPayable => 'Commission payable';

  @override
  String get payCommission => 'Pay Commission';

  @override
  String get commissionSettled =>
      'Commission payment sent to Hamro Futsal for verification.';

  @override
  String get noCommissionDue => 'No commission due right now.';

  @override
  String get settlementNoteHint => 'Bank / wallet details, remarks…';

  @override
  String get settlementRequestSubmitted =>
      'Settlement request sent to Hamro Futsal for approval.';

  @override
  String get settlements => 'Settlements';

  @override
  String get settlementAwaitingApproval =>
      'A settlement is already awaiting approval.';

  @override
  String get totalEarned => 'Total earned';

  @override
  String get totalSettled => 'Settled';

  @override
  String get active => 'Active';

  @override
  String get courtStatus => 'Court status';

  @override
  String get inactiveCourtsAreHiddenFromPlayers =>
      'Inactive courts are hidden from players.';

  @override
  String get addANewItemToYourRentalInventory =>
      'Add a new item to your rental inventory.';

  @override
  String get addARemarkInvoiceRefEtc => 'Add a remark, invoice ref, etc.';

  @override
  String get addCourt => 'Add Court';

  @override
  String get addDate => 'Add Date';

  @override
  String get addEquipment => 'Add equipment';

  @override
  String get addFirstCourt => 'Add First Court';

  @override
  String get addFutsalCourt => 'Add Futsal Court';

  @override
  String get addImagesOrFilesToYourLibrary =>
      'Add images or files to your library.';

  @override
  String get addMedia => 'Add Media';

  @override
  String get addMembers => 'Add members';

  @override
  String get addMembersTitle => 'Add Members';

  @override
  String get addNewCourt => 'Add New Court';

  @override
  String get addPlayersWithTheirPositionGoalkeeperDefenderMid3034fc58 =>
      'Add players with their position — goalkeeper, defender, midfielder or forward.';

  @override
  String get addSlot => 'Add Slot';

  @override
  String get addVenueLevelGalleryImagesForYourBusinessProfile =>
      'Add venue-level gallery images for your business profile.';

  @override
  String get addYourFirstCourtAndStartAcceptingBookings =>
      'Add your first court and start accepting bookings.';

  @override
  String get addYourFirstCourtToContinueSetup =>
      'Add your first court to continue setup.';

  @override
  String get addressAndMapCoordinates => 'Address and map coordinates';

  @override
  String get addressExactLocationLongitudeAndLatitude =>
      'Address, exact location, longitude, and latitude.';

  @override
  String get advance => 'Advance';

  @override
  String get advancePayment => 'Advance Payment';

  @override
  String get advancePaymentRequired => 'Advance payment required';

  @override
  String get advancePaymentRequirementsAndQr =>
      'Advance payment requirements and QR.';

  @override
  String get advancePaymentType => 'Advance payment type';

  @override
  String get advanceToPay => 'Advance to pay';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get all => 'All';

  @override
  String get allDay => 'All day';

  @override
  String get allSlots => 'All slots';

  @override
  String get allVenues => 'All venues';

  @override
  String get allowCancellations => 'Allow cancellations';

  @override
  String get alwaysImproving => 'Always Improving';

  @override
  String get am => 'AM';

  @override
  String get amenities => 'Amenities';

  @override
  String get amenitiesAndFacilities => 'Amenities & Facilities';

  @override
  String get amenitiesAndFeatures => 'Amenities & Features';

  @override
  String get analytics => 'Analytics';

  @override
  String get appDisplayLanguage => 'App display language';

  @override
  String get appTheme => 'App Theme';

  @override
  String get calendar => 'Calendar';

  @override
  String get chooseCalendar => 'Choose calendar';

  @override
  String get englishCalendar => 'English Calendar';

  @override
  String get nepaliCalendar => 'Nepali Calendar';

  @override
  String get nepaliDateScript => 'Nepali date script';

  @override
  String get nepaliDateScriptSubtitle =>
      'How Nepali calendar dates are written';

  @override
  String get apply => 'Apply';

  @override
  String get applyFilter => 'Apply filter';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get approved => 'Approved';

  @override
  String get archive => 'Archive';

  @override
  String get areaLandmarkOrStreetName => 'Area, landmark, or street name';

  @override
  String get ascending => 'Ascending';

  @override
  String get attachFiles => 'Attach files';

  @override
  String get autoFilled => 'Auto-filled';

  @override
  String get autoGenerateFromFutsalName => 'Auto generate from futsal name';

  @override
  String get availabilityCheckFailed => 'Availability check failed';

  @override
  String get available => 'Available';

  @override
  String get availableCourts => 'Available Courts';

  @override
  String get availableOffers => 'Available offers';

  @override
  String get avgDay => 'Avg / day';

  @override
  String get back => 'Back';

  @override
  String get backgroundColor => 'Background Color';

  @override
  String get balanceDueLater => 'Balance due later';

  @override
  String get balanceDue => 'Balance due';

  @override
  String get paidAmount => 'Paid amount';

  @override
  String get settlement => 'Settlement';

  @override
  String get requestedAmount => 'Requested';

  @override
  String get stillClearing => 'still clearing';

  @override
  String get requestedOn => 'Requested on';

  @override
  String get paidOn => 'Paid on';

  @override
  String get updatedOn => 'Updated on';

  @override
  String get maximumPayable => 'Maximum payable';

  @override
  String get singleVenue => 'Single venue';

  @override
  String get viewPaymentProof => 'View payment proof';

  @override
  String get viewProof => 'View proof';

  @override
  String get approvedAmount => 'Approved';

  @override
  String get txnShort => 'Txn';

  @override
  String get transactionReferenceCopied => 'Transaction reference copied.';

  @override
  String get balancedPackageForActiveFutsalOperations =>
      'Balanced package for active futsal operations.';

  @override
  String get basePrice => 'Base price';

  @override
  String get basic => 'Basic';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get basicPrice => 'Basic Price';

  @override
  String get bestForASingleVenueGettingOnline =>
      'Best for a single venue getting online.';

  @override
  String get biometricLogin => 'Biometric Login';

  @override
  String get block => 'Block';

  @override
  String get bold => 'Bold';

  @override
  String get bookCourtsManageMatchesAndKeepYourFutsalPlansMov11f51a89 =>
      'Book courts, manage matches, and keep your futsal plans moving without the back-and-forth.';

  @override
  String get bookNow => 'Book Now';

  @override
  String get bookingCompleted => 'Your booking is completed';

  @override
  String get bookingCompletedMessage =>
      'The court is held for your match. Continue to set the cost split.';

  @override
  String get booked => 'Booked';

  @override
  String get bookedVia => 'Booked via';

  @override
  String get booking => 'Booking';

  @override
  String get manualBooking => 'Manual Booking';

  @override
  String get bookingTypeManual => 'Walk-in';

  @override
  String get bookingTypeOnline => 'Online';

  @override
  String get bookingUnitSuffix => ' / booking';

  @override
  String get bookingAlerts => 'Booking Alerts';

  @override
  String get bookingAndCancellationTerms => 'Booking and cancellation terms';

  @override
  String get bookingAndPayment => 'Booking & Payment';

  @override
  String get bookingAndPaymentTitle => 'Booking and Payment';

  @override
  String get bookingDetails => 'Booking Details';

  @override
  String get bookingFee => 'Booking Fee';

  @override
  String get bookingId => 'Booking ID';

  @override
  String get bookingOverview => 'Booking Overview';

  @override
  String get bookingPolicies => 'Booking Policies';

  @override
  String get bookingRequestSent => 'Booking request sent';

  @override
  String get bookings => 'Bookings';

  @override
  String get bookingsRemainOpenAndHolidayPricingCanApply =>
      'Bookings remain open and holiday pricing can apply.';

  @override
  String get branding => 'Branding';

  @override
  String get brandingAndReview => 'Branding & Review';

  @override
  String get bulletList => 'Bullet List';

  @override
  String get business => 'Business';

  @override
  String get businessAndRegistration => 'Business & Registration';

  @override
  String get businessAssets => 'Business Assets';

  @override
  String get calculatingPrice => 'Calculating price…';

  @override
  String get call => 'Call';

  @override
  String get camera => 'Camera';

  @override
  String get canWeRescheduleTonightSBooking =>
      'Can we reschedule tonight’s booking?';

  @override
  String get cancel => 'Cancel';

  @override
  String get okay => 'Okay';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get cancelBookingConfirmation =>
      'Are you sure you want to cancel this booking? This cannot be undone.';

  @override
  String get keepBooking => 'Keep booking';

  @override
  String get bookingCancelledSuccessfully => 'Your booking has been cancelled.';

  @override
  String get couldNotCancelBooking =>
      'Could not cancel the booking. Please try again.';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get decline => 'Decline';

  @override
  String get groupInvitation => 'Group invitation';

  @override
  String get groupInvitationPrompt =>
      'You have been invited to join this group.';

  @override
  String get categories => 'Categories';

  @override
  String get cats => 'cats';

  @override
  String get change => 'Change';

  @override
  String get changeImage => 'Change image';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get changeServicePlan => 'Change service plan?';

  @override
  String get changeServicePlanConfirmation =>
      'Do you want to change your service plan? Your commission rate will be updated to the new plan.';

  @override
  String get charge => 'Charge';

  @override
  String get chargePerUnitPerHour => 'Charge per unit per hour';

  @override
  String get chat => 'Chat';

  @override
  String get chatWithCustomer => 'Chat with customer';

  @override
  String get chatWithHost => 'Chat with host';

  @override
  String get messageHost => 'Message host';

  @override
  String get chatWithVenue => 'Chat with venue';

  @override
  String get cannotChatWithYourself =>
      'You cannot start a conversation with yourself.';

  @override
  String get checkYourConnectionAndTryAgain =>
      'Check your connection and try again.';

  @override
  String get checkYourInboxAndSpamFolder => 'Check your inbox and spam folder.';

  @override
  String get chooseASavedImageOrUploadANewOne =>
      'Choose a saved image or upload a new one.';

  @override
  String get chooseFile => 'Choose File';

  @override
  String get choosePackage => 'Choose Package';

  @override
  String get chooseThePackageThatMatchesYourCurrentStageAndOp2398b90f =>
      'Choose the package that matches your current stage and operational needs.';

  @override
  String get chooseVenue => 'Choose venue';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get clear => 'Clear';

  @override
  String get clearAll => 'Clear All';

  @override
  String get clearFormat => 'Clear Format';

  @override
  String get clearInfoWhenYouNeedIt => 'Clear info when you need it.';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get close => 'Close';

  @override
  String get closeAFullDayOrOnlyASpecificHourRange =>
      'Close a full day or only a specific hour range.';

  @override
  String get closedAcceptWindowExpired => 'Closed — accept window expired';

  @override
  String get closedDate => 'Closed date';

  @override
  String get closedDates => 'Closed dates';

  @override
  String get code => 'Code';

  @override
  String get collectNow => 'Collect now';

  @override
  String get collectPaymentOrDepositBeforeABookingIsConfirmed =>
      'Collect payment or deposit before a booking is confirmed.';

  @override
  String get commissionPackageAndPlatformSupportDetails =>
      'Commission package and platform support details';

  @override
  String get commissions => 'Commissions';

  @override
  String get companyDocs => 'Company Docs';

  @override
  String get companyDocuments => 'Company documents';

  @override
  String get completeCourtDetails => 'Complete court details';

  @override
  String get completeTheRequiredDetails => 'Complete the required details';

  @override
  String get completed => 'Completed';

  @override
  String get configureDateAndTimeSlots => 'Configure date and time slots.';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get connectThisGroupToAVenue => 'Connect this group to a venue';

  @override
  String get connected => 'Connected';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get conversationSettings => 'Conversation settings';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get notProvided => 'Not provided';

  @override
  String get viewProfile => 'View profile';

  @override
  String get couldNotApplyTheCouponPleaseTryAgain =>
      'Could not apply the coupon. Please try again.';

  @override
  String get couldNotCheckAvailabilityPleaseTryAgain =>
      'Could not check availability. Please try again.';

  @override
  String get couldNotGetAppleCredentialsPleaseTryAgain =>
      'Could not get Apple credentials. Please try again.';

  @override
  String get couldNotGetGoogleCredentialsPleaseTryAgain =>
      'Could not get Google credentials. Please try again.';

  @override
  String get couldNotHoldThisSlotPleaseTryAgain =>
      'Could not hold this slot. Please try again.';

  @override
  String get couldNotIdentifyThisCourt => 'Could not identify this court.';

  @override
  String get couldNotLoadBookings => 'Could not load bookings.';

  @override
  String get exportBookings => 'Export bookings';

  @override
  String get exportingBookings => 'Preparing your export…';

  @override
  String get couldNotExportBookings =>
      'Could not export bookings. Please try again.';

  @override
  String get noBookingsToExport =>
      'There are no bookings to export for these filters.';

  @override
  String get exportedBookings => 'Exported Bookings';

  @override
  String get exportDownloadedTitle =>
      'Booking overview downloaded successfully';

  @override
  String get exportReadyToView =>
      'Your export is saved to your device and ready to view.';

  @override
  String get viewExport => 'View';

  @override
  String get exportSavedInDownloads => 'Saved in Downloads';

  @override
  String get exportSavedInFiles => 'Saved in the Files app';

  @override
  String get couldNotOpenExport =>
      'No app found to open this file. Install Excel or Google Sheets to view it.';

  @override
  String get shareFile => 'Share file';

  @override
  String get couldNotLoadCategories => 'Could not load categories.';

  @override
  String get couldNotLoadSavedAuthenticationDetails =>
      'Could not load saved authentication details.';

  @override
  String get couldNotLoadVenues => 'Could not load venues.';

  @override
  String get couldNotParseAmenitiesAndFacilitiesFromServer =>
      'Could not parse amenities and facilities from server.';

  @override
  String get couldNotParseAmenitiesFromServer =>
      'Could not parse amenities from server.';

  @override
  String get couldNotParseAvailableCourtsFromServer =>
      'Could not parse available courts from server.';

  @override
  String get couldNotParseBookingDetailsFromServer =>
      'Could not parse booking details from server.';

  @override
  String get couldNotParseBookingsFromServer =>
      'Could not parse bookings from server.';

  @override
  String get couldNotParseCategoryFiltersFromServer =>
      'Could not parse category filters from server.';

  @override
  String get couldNotParseCouponsFromServer =>
      'Could not parse coupons from server.';

  @override
  String get couldNotParseMobileBannersFromServer =>
      'Could not parse banners from server.';

  @override
  String get couldNotParseNotificationsFromServer =>
      'Could not parse notifications from server.';

  @override
  String get couldNotLoadNotifications => 'Could not load notifications.';

  @override
  String get couldNotParseCourtDetailsFromServer =>
      'Could not parse court details from server.';

  @override
  String get couldNotParseCourtTypesFromServer =>
      'Could not parse court types from server.';

  @override
  String get couldNotParseCreatedMediaItemsFromServer =>
      'Could not parse created media items from server.';

  @override
  String get couldNotParseExpenseCategoriesFromServer =>
      'Could not parse expense categories from server.';

  @override
  String get couldNotParseExpensesFromServer =>
      'Could not parse expenses from server.';

  @override
  String get couldNotParseFacilitiesFromServer =>
      'Could not parse facilities from server.';

  @override
  String get couldNotParseFaqsFromServer => 'Could not parse FAQs from server.';

  @override
  String get couldNotParseFutsalBookingsFromServer =>
      'Could not parse futsal bookings from server.';

  @override
  String get couldNotParseHelpTopicsFromServer =>
      'Could not parse help topics from server.';

  @override
  String get couldNotParseHostDetailsFromServer =>
      'Could not parse host details from server.';

  @override
  String get couldNotParseMatchFormatsFromServer =>
      'Could not parse match formats from server.';

  @override
  String get couldNotParseMediaListFromServer =>
      'Could not parse media list from server.';

  @override
  String get couldNotParseReviewsFromServer =>
      'Could not parse reviews from server.';

  @override
  String get couldNotParsePaymentQrFromServer =>
      'Could not parse payment QR from server.';

  @override
  String get couldNotParsePublicPackagesFromServer =>
      'Could not parse public packages from server.';

  @override
  String get couldNotParsePublicServicesFromServer =>
      'Could not parse public services from server.';

  @override
  String get couldNotParsePublicTemplatesFromServer =>
      'Could not parse public templates from server.';

  @override
  String get couldNotParseVenueCourtsFromServer =>
      'Could not parse venue courts from server.';

  @override
  String get couldNotParseVenueDescriptionFromServer =>
      'Could not parse venue description from server.';

  @override
  String get couldNotParseVenueSlotsFromServer =>
      'Could not parse venue slots from server.';

  @override
  String get couldNotParseVenuesAndCourtsFromServer =>
      'Could not parse venues and courts from server.';

  @override
  String get couldNotParseVenuesFromServer =>
      'Could not parse venues from server.';

  @override
  String get couldNotParseYourWishlistFromServer =>
      'Could not parse your wishlist from server.';

  @override
  String get couldNotSaveTheExpense => 'Could not save the expense.';

  @override
  String get couldNotSendOtpPleaseTryAgain =>
      'Could not send the OTP. Please try again.';

  @override
  String get otpSentSuccessfully => 'OTP sent successfully. Check your email.';

  @override
  String get createNewPassword => 'Create New Password';

  @override
  String get codeVerifiedChooseANewPassword =>
      'Code verified. Choose a new password.';

  @override
  String get court => 'Court';

  @override
  String get couldNotParsePrefix => 'Could not parse ';

  @override
  String get courtActions => 'Court actions';

  @override
  String get courtIdentityDescriptionPhotosAndMemories =>
      'Court identity, description, photos, and memories.';

  @override
  String get courtIdentityPricingTypeAndPlayingFormat =>
      'Court identity, pricing, type, and playing format';

  @override
  String get courtInfo => 'Court Info';

  @override
  String get courtInformation => 'Court Information';

  @override
  String get courtName => 'Court name';

  @override
  String get courtNotFound => 'Court not found.';

  @override
  String get courtPhotos => 'Court photos';

  @override
  String get courtPhotosAndMemories => 'Court photos and memories.';

  @override
  String get courtPhotosAndMemoriesLabel => 'Court photos and memories';

  @override
  String get courtRules => 'Court Rules';

  @override
  String get courtSetup => 'Court Setup';

  @override
  String get courtSpecificAmenitiesAndFacilities =>
      'Court-specific amenities and facilities.';

  @override
  String get courtSpecificAmenitiesForThisCourt =>
      'Court-specific amenities for this court.';

  @override
  String get courtType => 'Court Type';

  @override
  String get courtTypeSentenceCase => 'Court type';

  @override
  String get courts => 'Courts';

  @override
  String get coverImage => 'Cover Image';

  @override
  String get coverImageSentenceCase => 'Cover image';

  @override
  String get coverMediaGalleryAndBusinessDocuments =>
      'Cover media, gallery, and business documents.';

  @override
  String get createGroup => 'Create Group';

  @override
  String get createReusableBookingSlotsWithDaysAndTimes =>
      'Create reusable booking slots with days and times';

  @override
  String get createShopPayload => 'Create Shop Payload';

  @override
  String get createTeam => 'Create Team';

  @override
  String get customDatePrice => 'Custom date price';

  @override
  String get customDatePrices => 'Custom date prices';

  @override
  String get customRange => 'Custom range';

  @override
  String get date => 'Date';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get dateOrder => 'Date order';

  @override
  String get defineBookingRulesPaymentsAndVenueHousePolicies =>
      'Define booking rules, payments, and venue house policies.';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountPrompt => 'Delete your account?';

  @override
  String get deleteAccountWarning =>
      'This cannot be undone. Everything below is removed for good.';

  @override
  String get deleteAccountLosesProfile =>
      'Your profile, login and biometric access';

  @override
  String get deleteAccountLosesBookings => 'Your bookings and payment history';

  @override
  String get deleteAccountLosesTeams => 'Your teams and opponent requests';

  @override
  String get deleteAccountConfirmationWord => 'DELETE';

  @override
  String get deleteAccountSubtitle =>
      'Permanently remove your account and data';

  @override
  String get deleteAccountReason => 'Reason for deletion';

  @override
  String get deleteAccountReasonHint =>
      'Tell us why you are deleting your account';

  @override
  String get deleteAccountReasonRequired =>
      'Please add a reason before deleting your account.';

  @override
  String get accountDeleted => 'Your account has been deleted';

  @override
  String get deletingAccount => 'Deleting account…';

  @override
  String get deleteCourt => 'Delete Court';

  @override
  String get deleteCourtPrompt => 'Delete Court?';

  @override
  String get deleteFile => 'Delete File?';

  @override
  String get deleteFutsal => 'Delete Futsal';

  @override
  String get deleteMessage => 'Delete message?';

  @override
  String get deleteMessageAction => 'Delete message';

  @override
  String get deleteSlot => 'Delete Slot';

  @override
  String get deleteTeam => 'Delete team?';

  @override
  String get deposit => 'Deposit';

  @override
  String get depositRefundable => 'Deposit (refundable)';

  @override
  String get descending => 'Descending';

  @override
  String get describeYourCancellationAndRefundPolicy =>
      'Describe your cancellation and refund policy...';

  @override
  String get describeYourFutsalFacilitiesAndWhatMakesItSpecial =>
      'Describe your futsal, facilities, and what makes it special.';

  @override
  String get description => 'Description';

  @override
  String get descriptionAboutYourCourt => 'Description about your court...';

  @override
  String get descriptionAboutYourFutsal => 'Description about your futsal...';

  @override
  String get designedAroundTheWayLocalPlayersActuallyBook =>
      'Designed around the way local players actually book.';

  @override
  String get digitalProductsForModernSportsBusinesses =>
      'Digital products for modern sports businesses.';

  @override
  String get directions => 'Directions';

  @override
  String get discount => 'Discount';

  @override
  String get discountType => 'Discount type';

  @override
  String get discounts => 'Discounts';

  @override
  String get document => 'Document';

  @override
  String get documentMustBeSmallerThan10Mb =>
      'Document must be smaller than 10 MB.';

  @override
  String get done => 'Done';

  @override
  String get dragToReorderFirstImageIsTheCover =>
      'Drag to reorder. First image is the cover.';

  @override
  String get eGCourtAMainField => 'e.g. Court A, Main Field';

  @override
  String get eGFootballSize5 => 'e.g. Football · size 5';

  @override
  String get eGMorningSlot => 'e.g. Morning Slot';

  @override
  String get eGTurfRepairMonthlyRent => 'e.g. Turf repair, monthly rent';

  @override
  String get eGWeekendFutsalTeam => 'e.g. Weekend Futsal Team';

  @override
  String get edit => 'Edit';

  @override
  String get edited => 'edited · ';

  @override
  String get elite => 'Elite';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get enableUsersToCancelConfirmedBookingsBeforeMatchDay =>
      'Enable users to cancel confirmed bookings before match day.';

  @override
  String get endTime => 'End time';

  @override
  String get enterCouponCode => 'Enter coupon code';

  @override
  String get enterCurrentPassword => 'Enter current password';

  @override
  String get enterFutsalClubName => 'Enter futsal club name';

  @override
  String get enterFutsalRegistrationNumber =>
      'Enter Futsal registration number';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get enterVenueId => 'Enter venue ID';

  @override
  String get enterYourAddress => 'Enter your address';

  @override
  String get enterYourCurrentPasswordAndChooseANewOne =>
      'Enter your current password and choose a new one.';

  @override
  String get enterYourEmailAndWeWillSendYouAnOtpCode =>
      'Enter your email and we will send you an OTP code.';

  @override
  String get enterYourFullName => 'Enter your full name';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get entries => 'Entries';

  @override
  String get establishedYear => 'Established Year';

  @override
  String get evening => 'Evening';

  @override
  String get exactLocation => 'Exact Location';

  @override
  String get exactLocationSentenceCase => 'Exact location';

  @override
  String get exampleNonMarkingShoesOnlyReport15MinutesEarlyNo3d1a39a7 =>
      'Example: non-marking shoes only, report 15 minutes early, no outside food.';

  @override
  String get expenseDate => 'Expense date';

  @override
  String get expenseNotFound => 'Expense not found.';

  @override
  String get expenses => 'Expenses';

  @override
  String get facilities => 'Facilities';

  @override
  String get faqs => 'FAQs';

  @override
  String get fastBooking => 'Fast Booking';

  @override
  String get features => 'Features';

  @override
  String get fetchingYourSavedMediaFromTheServer =>
      'Fetching your saved media from the server.';

  @override
  String get file => 'File';

  @override
  String get filterByDate => 'Filter by date';

  @override
  String get filterLibrary => 'Filter library';

  @override
  String get filtersAndSorting => 'Filters & Sorting';

  @override
  String get flat => 'Flat';

  @override
  String get forPremiumVenuesAndMultiCourtOperators =>
      'For premium venues and multi-court operators.';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get forgotPasswordPrompt => 'Forgot password?';

  @override
  String get fromDate => 'From date';

  @override
  String get fromServerSuffix => ' from server.';

  @override
  String get fullDay => 'Full day';

  @override
  String get futsal => 'Futsal';

  @override
  String get futsalAddress => 'Futsal Address';

  @override
  String get futsalBookingSimplified => 'Futsal booking, simplified.';

  @override
  String get futsalBookings => 'Futsal Bookings';

  @override
  String get futsalClubName => 'Futsal Club Name';

  @override
  String get futsalGmailCom => 'futsal@gmail.com';

  @override
  String get futsalInformation => 'Futsal Information';

  @override
  String get futsalName => 'Futsal Name';

  @override
  String get futsalPortfolio => 'Futsal Portfolio';

  @override
  String get futsalRules => 'Futsal Rules';

  @override
  String get futsalSteps => 'Futsal Steps';

  @override
  String get gallery => 'Gallery';

  @override
  String get general => 'General';

  @override
  String get goBack => 'Go back';

  @override
  String get appleSignInFailedPleaseTryAgain =>
      'Apple sign-in failed. Please try again.';

  @override
  String get appleSignInIsNotAvailableOnThisDevice =>
      'Apple sign-in is not available on this device.';

  @override
  String get googleSignInFailedPleaseTryAgain =>
      'Google sign-in failed. Please try again.';

  @override
  String get googleSignInIsNotConfiguredMissingGoogleServerClientId =>
      'Google sign-in is not configured. Missing GOOGLE_SERVER_CLIENT_ID.';

  @override
  String get group => 'Group';

  @override
  String get growth => 'Growth';

  @override
  String get hamroFutsal => 'Hamro Futsal';

  @override
  String get hamroFutsalIsBuiltToMakeLocalFutsalEasierForPl2dfd0648 =>
      'Hamro Futsal is built to make local futsal easier for players, teams, and venue owners. Discover available courts, compare facilities, and book with confidence.';

  @override
  String get hamroFutsalArena => 'Hamro Futsal Arena';

  @override
  String get hamroFutsalArenaSlugExample => 'hamro-futsal-arena';

  @override
  String get hamroFutsalV100 => 'Hamro Futsal · v1.0.0';

  @override
  String get handOverEquipmentAndStartARentalTimer =>
      'Hand over equipment and start a rental timer.';

  @override
  String get helloHamrofutsalCom => 'hello@hamrofutsal.com';

  @override
  String get helloSirGoodMorning => 'Hello sir, good morning.';

  @override
  String get help => 'Help';

  @override
  String get helpAndFaq => 'Help & FAQ';

  @override
  String get videos => 'Videos';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get helpfulSupport => 'Helpful Support';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackTitle => 'Share your feedback';

  @override
  String get feedbackSubtitle =>
      'Tell us what worked well and where we can improve the platform or services.';

  @override
  String get feedbackType => 'Feedback type';

  @override
  String get feedbackCategory => 'Category';

  @override
  String get feedbackMessage => 'Your feedback';

  @override
  String get feedbackContact => 'Contact number or email (optional)';

  @override
  String get feedbackSuccess =>
      'Thanks for sharing your feedback. We have received it successfully.';

  @override
  String get feedbackPlatform => 'Platform';

  @override
  String get feedbackServices => 'Services';

  @override
  String get feedbackBoth => 'Both';

  @override
  String get feedbackBug => 'Bug / issue';

  @override
  String get feedbackSuggestion => 'Suggestion';

  @override
  String get feedbackPraise => 'Appreciation';

  @override
  String get submitFeedback => 'Submit feedback';

  @override
  String get feedbackHelpNote =>
      'Your response helps us improve the app experience, support flow, and service quality.';

  @override
  String get highlightTheServicesAndOnSiteFacilitiesYourVenueOffers =>
      'Highlight the services and on-site facilities your venue offers.';

  @override
  String get highlightWhatYourFutsalOffers =>
      'Highlight what your futsal offers';

  @override
  String get holidayDates => 'Holiday dates';

  @override
  String get holidayPrice => 'Holiday price';

  @override
  String get home => 'Home';

  @override
  String get hostedBy => 'Hosted By';

  @override
  String get hour => 'Hour';

  @override
  String get hourLowercase => 'hour';

  @override
  String get perHourSuffix => '/ hour';

  @override
  String get hourly => 'Hourly';

  @override
  String get hoursPlayed => 'Hours played';

  @override
  String get houseRulesForPlayersAndBookings =>
      'House rules for players and bookings.';

  @override
  String get howRefundsAndCancellationsAreHandled =>
      'How refunds and cancellations are handled.';

  @override
  String get iAgreeToTheTermsAndPrivacyPolicy =>
      'I agree to the Terms and Privacy Policy.';

  @override
  String get iConfirmTheBookingDetailsAreCorrectAndAcceptTheCabab03b =>
      'I confirm the booking details are correct and accept the cancellation & refund policy.';

  @override
  String get iSawTheFutsalSlotYouPostedYesterday =>
      'I saw the futsal slot you posted yesterday.';

  @override
  String get image => 'IMAGE';

  @override
  String get importantNote => 'Important note';

  @override
  String get inactive => 'Inactive';

  @override
  String get information => 'Information';

  @override
  String get insert => 'Insert';

  @override
  String get insertLink => 'Insert Link';

  @override
  String get invalidAuthenticationResponseFromServer =>
      'Invalid authentication response from server.';

  @override
  String get invalidCreateFutsalResponseFromServer =>
      'Invalid create futsal response from server.';

  @override
  String get invalidProfileResponseFromServer =>
      'Invalid profile response from server.';

  @override
  String get italic => 'Italic';

  @override
  String get jpgPngOrPdfUpTo10Mb => 'JPG, PNG or PDF · up to 10 MB';

  @override
  String get jpgOrPngUpTo10Mb => 'JPG or PNG · up to 10 MB';

  @override
  String get kathmandu => 'Kathmandu';

  @override
  String get keepYourAccountSecure => 'Keep your account secure';

  @override
  String get language => 'Language';

  @override
  String get latitude => 'Latitude';

  @override
  String get legalAndSupportingCompanyDocuments =>
      'Legal and supporting company documents.';

  @override
  String get didntReceiveCode => 'Didn\'t receive code';

  @override
  String get link => 'Link';

  @override
  String get linkCopiedToClipboard => 'Link copied to clipboard.';

  @override
  String get listYourFutsalHouseRulesForPlayers =>
      'List your futsal house rules for players...';

  @override
  String get loadingAvailableCoupons => 'Loading available coupons…';

  @override
  String get loadingCategories => 'Loading categories…';

  @override
  String get loadingMediaLibrary => 'Loading media library...';

  @override
  String get location => 'Location';

  @override
  String get locationDetails => 'Location Details';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get lockedWhileUnderReviewThisSelectionCannotBeChanged =>
      'Locked while under review — this selection cannot be changed.';

  @override
  String get logo => 'Logo';

  @override
  String get logoutFailedPleaseTryAgain => 'Logout failed. Please try again.';

  @override
  String get logoutSuccessful => 'Logout successful';

  @override
  String get passwordUpdatedPleaseLogIn =>
      'Password updated. Please log in again.';

  @override
  String get longitude => 'Longitude';

  @override
  String get lookingForAFriendlyCompetitiveFutsalMatch =>
      'Looking for a friendly competitive futsal match.';

  @override
  String get loserCoversTheLargerShareSettleTheAmountAfterThe2a150fda =>
      'Loser covers the larger share. Settle the amount after the match result.';

  @override
  String get loserPays => 'Loser pays';

  @override
  String get madeForFutsal => 'Made for Futsal';

  @override
  String get manageBookingAndPaymentSettings =>
      'Manage booking and payment settings';

  @override
  String get manageCourt => 'Manage Court';

  @override
  String get manageCourtsInCompactView => 'Manage courts in compact view';

  @override
  String get manageFutsal => 'Manage Futsal';

  @override
  String get margin => 'Margin';

  @override
  String get markReturned => 'Mark returned';

  @override
  String get markWeekendDaysHolidayDatesAndClosedDates =>
      'Mark weekend days, holiday dates, and closed dates.';

  @override
  String get matchDate => 'Match date';

  @override
  String get matchFormat => 'Match format';

  @override
  String get matchTime => 'Match time';

  @override
  String get matchReady => 'Match Ready';

  @override
  String get matchType => 'Match Type';

  @override
  String get matchesTheBackendSchemaYouShared =>
      'Matches the backend schema you shared.';

  @override
  String get maxPlayers => 'Max players';

  @override
  String get members => 'Members';

  @override
  String get memories => 'Memories';

  @override
  String get message => 'Message';

  @override
  String get messages => 'Messages';

  @override
  String get minute => 'Minute';

  @override
  String get morning => 'Morning';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get myTeams => 'My Teams';

  @override
  String get nameBasePriceAndCourtType => 'Name, base price, and court type.';

  @override
  String get nameExampleCom => 'name@example.com';

  @override
  String get nameFutsalCom => 'name@futsal.com';

  @override
  String get nepal => 'Nepal';

  @override
  String get netProfit => 'Net profit';

  @override
  String get netRevenue => 'Net revenue';

  @override
  String get newCourt => 'New Court';

  @override
  String get newExpense => 'New Expense';

  @override
  String get newFutsal => 'New Futsal';

  @override
  String get newRental => 'New rental';

  @override
  String get newRequest => 'New Request';

  @override
  String get completeRequest => 'Complete Request';

  @override
  String get completeSetup => 'Complete';

  @override
  String get newTeam => 'New Team';

  @override
  String get showPlayers => 'Show players';

  @override
  String get hidePlayers => 'Hide players';

  @override
  String get newToday => 'New Today';

  @override
  String get noAmenitiesInThisCategory => 'No amenities in this category.';

  @override
  String get noAmenitiesInformationAvailableYet =>
      'No amenities information available yet.';

  @override
  String get noBookingPolicyAddedYet => 'No booking policy added yet.';

  @override
  String get noClosedDatesAdded => 'No closed dates added.';

  @override
  String get noCourtActivity => 'No court activity.';

  @override
  String get noCourtTypesAvailable => 'No court types available.';

  @override
  String get noCourtsAddedYet => 'No courts added yet';

  @override
  String get noCourtsAvailable => 'No courts available';

  @override
  String get openingVenue => 'Opening venue…';

  @override
  String get couldNotOpenThisLink => 'Could not open this link';

  @override
  String get venueNotAvailable => 'Venue not available';

  @override
  String get thisVenueIsNoLongerListed =>
      'This venue is no longer listed, or the link has changed.';

  @override
  String get browseVenues => 'Browse venues';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get thatLinkDoesNotOpenAnythingInTheApp =>
      'That link does not open anything in the app.';

  @override
  String get allCourtsBookedOrUnavailable => 'All courts booked or unavailable';

  @override
  String get selectedDatesCourtsAreAlreadyBookedOrUnavai0f4a71b2 =>
      'Selected date\'s courts are already booked or unavailable, please choose another date.';

  @override
  String get noCourtsYet => 'No courts yet';

  @override
  String get noCustomerActivity => 'No customer activity.';

  @override
  String get noDescriptionAvailableForThisCourtYet =>
      'No description available for this court yet.';

  @override
  String get noEquipmentYet => 'No equipment yet';

  @override
  String get noExpensesRecordedForThisRange =>
      'No expenses recorded for this range.';

  @override
  String get noFavouritesYet => 'No favourites yet';

  @override
  String get noHolidayDatesAdded => 'No holiday dates added.';

  @override
  String get noMatchingMembers => 'No matching members';

  @override
  String get noMatchFormatsAvailable => 'No match formats available.';

  @override
  String get noMatchingVenues => 'No matching venues';

  @override
  String get noMediaFound => 'No media found';

  @override
  String get noMembersAvailable => 'No members available';

  @override
  String get noMembersFound => 'No members found';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get noRecentBookings => 'No recent bookings';

  @override
  String get noRulesListedYet => 'No rules listed yet.';

  @override
  String get noSlotConfigurationAddedYetAddASlotToDefineTheBo243e88c0 =>
      'No slot configuration added yet. Add a slot to define the booking schedule for this court.';

  @override
  String get noSlotsFound => 'No slots found';

  @override
  String get noTeamsYet => 'No teams yet';

  @override
  String get noTimeSlotsAreAvailableForThisDate =>
      'No time slots are available for this date.';

  @override
  String get noTrendYet => 'No trend yet';

  @override
  String get noUploadsYet => 'No uploads yet';

  @override
  String get noVenueActivity => 'No venue activity.';

  @override
  String get noVenuesFound => 'No venues found';

  @override
  String get note => 'Note';

  @override
  String get notes => 'Notes';

  @override
  String get nothingToBreakDown => 'Nothing to break down';

  @override
  String get notifications => 'Notifications';

  @override
  String get notifyMeWhenSomeoneWantsToPlay =>
      'Notify me when someone wants to play';

  @override
  String get npr => 'NPR';

  @override
  String get numberedList => 'Numbered List';

  @override
  String get occasionalOffersAndUpdatesByEmail =>
      'Occasional offers and updates by email';

  @override
  String get occupancy => 'Occupancy';

  @override
  String get offerRefundsWhenCancellationsMeetYourVenuePolicy =>
      'Offer refunds when cancellations meet your venue policy.';

  @override
  String get ohYesPleaseSendYourBookingDetails =>
      'Oh yes, please send your booking details.';

  @override
  String get onRent => 'On rent';

  @override
  String get documentUploadRequirements =>
      'Only from device files — image (JPG, PNG, WebP), PDF or Word. Max 10 MB. Gallery is not used here.';

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get openstreetmap => '© OpenStreetMap';

  @override
  String get operationalPhotosForThisSpecificCourt =>
      'Operational photos for this specific court.';

  @override
  String get opponentMatch => 'Opponent Match';

  @override
  String get opponentRequests => 'Opponent Requests';

  @override
  String get opponentTeam => 'Opponent team';

  @override
  String get optionalPricesForOneOffDates =>
      'Optional prices for one-off dates.';

  @override
  String get optionalVenue => 'Optional venue';

  @override
  String get optionalVisualIdentityAndFinalConfirmation =>
      'Optional visual identity and final confirmation.';

  @override
  String get or => 'or';

  @override
  String get orProvideADirectImageUrl => 'OR provide a direct image URL';

  @override
  String get organizeGamesWithLessEffort => 'Organize games with less effort.';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String get otpVerificationFailedPleaseTryAgain =>
      'OTP verification failed. Please try again.';

  @override
  String get overview => 'Overview';

  @override
  String get overviewAndImportantDetails => 'Overview and important details';

  @override
  String get package => 'Package';

  @override
  String get paidVia => 'Paid via';

  @override
  String get panLicenseRegistrationEtc => 'PAN, license, registration, etc.';

  @override
  String get participants => 'Participants';

  @override
  String get payNowAdvance => 'Pay now (advance)';

  @override
  String get payableNow => 'Payable now';

  @override
  String get payment => 'Payment';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get paymentProof => 'Payment proof';

  @override
  String get paymentQr => 'Payment QR';

  @override
  String get paymentStatus => 'Payment status';

  @override
  String get pending => 'Pending';

  @override
  String get percentage => 'Percentage';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get photosAndMemories => 'Photos & Memories';

  @override
  String get pickDatesAndSlotsQuickly => 'Pick dates and slots quickly.';

  @override
  String get pickExactLocation => 'Pick Exact Location';

  @override
  String get pickFrom => 'Pick from...';

  @override
  String get pickCorrectedFileToReplacePrefix =>
      'Pick a corrected file to replace ';

  @override
  String get pickTheOperationalPackageThatFitsYourBusiness =>
      'Pick the operational package that fits your business.';

  @override
  String get platformCommissionAndCommercialTerms =>
      'Platform commission and commercial terms.';

  @override
  String get playerFacingFacilitiesForThisCourt =>
      'Player-facing facilities for this court.';

  @override
  String get playerOptions => 'Player options';

  @override
  String get players => 'Players';

  @override
  String get pleaseConfirmTheDetailsBeforeBooking =>
      'Please confirm the details before booking.';

  @override
  String get pleaseShareTheLocationPinOnceAgain =>
      'Please share the location pin once again.';

  @override
  String get pm => 'PM';

  @override
  String get pngJpgJpegWebp => 'PNG, JPG, JPEG, WEBP';

  @override
  String get policies => 'Policies';

  @override
  String get policyAndRules => 'Policy & Rules';

  @override
  String get popular => 'Popular';

  @override
  String get preferences => 'Preferences';

  @override
  String get price => 'Price';

  @override
  String get priceBreakdown => 'Price breakdown';

  @override
  String get priceRange => 'Price Range';

  @override
  String get pricingOperationalDetailsAndRegistrationInformation =>
      'Pricing, operational details, and registration information.';

  @override
  String get primaryBusinessThumbnailForTheFutsalListing =>
      'Primary business thumbnail for the futsal listing.';

  @override
  String get primaryFutsalCoverImage => 'Primary futsal cover image.';

  @override
  String get privacyFirst => 'Privacy First';

  @override
  String get profile => 'Profile';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully.';

  @override
  String get promotionalEmails => 'Promotional Emails';

  @override
  String get proof => 'Proof';

  @override
  String get publicIdentityAndContactDetailsOfYourFutsal =>
      'Public identity and contact details of your futsal.';

  @override
  String get purpose => 'Purpose';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get qrCodeUsedForAdvancePayment => 'QR code used for advance payment.';

  @override
  String get qrUnavailable => 'QR unavailable';

  @override
  String get quote => 'Quote';

  @override
  String get rankings => 'Rankings';

  @override
  String get rating => 'Rating';

  @override
  String get reEnterNewPassword => 'Re-enter new password';

  @override
  String get reEnterYourPassword => 'Re-enter your password';

  @override
  String get receiveUpdatesOnThisDevice => 'Receive updates on this device';

  @override
  String get recentBookings => 'Recent Bookings';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get recommended => 'Recommended';

  @override
  String get records => 'Records';

  @override
  String get recurrence => 'Recurrence';

  @override
  String get recurringBooking => 'Recurring booking';

  @override
  String get repeatOn => 'Repeat on';

  @override
  String get repeatFor => 'Repeat for';

  @override
  String get recurringPriceDetails => 'Recurring price details';

  @override
  String get redo => 'Redo';

  @override
  String get refundCancellationAndCustomerBookingGuidelines =>
      'Refund, cancellation, and customer booking guidelines';

  @override
  String get refundCancellationPolicy => 'Refund / Cancellation Policy';

  @override
  String get refundCancellationPolicyCompact => 'Refund/Cancellation Policy';

  @override
  String get refundCancellationPolicyFutsalRulesAndCommissions =>
      'Refund/cancellation policy, futsal rules, and commissions.';

  @override
  String get refundableSecurityDeposit => 'Refundable security deposit';

  @override
  String get registrationNumberExample => 'REG-2026-00123';

  @override
  String get registrationNumber => 'Registration Number';

  @override
  String get reject => 'Reject';

  @override
  String get rejected => 'Rejected';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get remindersBeforeYourMatchesStart =>
      'Reminders before your matches start';

  @override
  String get remove => 'Remove';

  @override
  String get removeFileConfirmationPrefix => 'Are you sure you want to remove ';

  @override
  String get removeDocument => 'Remove document';

  @override
  String get removeFromMediaLibrary => 'Remove from media library?';

  @override
  String get removePlayer => 'Remove player?';

  @override
  String get removeRequest => 'Remove request?';

  @override
  String get removeRequestAction => 'Remove Request';

  @override
  String get requestDeleted => 'Opponent request deleted.';

  @override
  String get courtFeeNotSetYet => 'Not set yet';

  @override
  String get requestPublished => 'Opponent request published.';

  @override
  String get renameTeam => 'Rename Team';

  @override
  String get rentalServices => 'Rental Services';

  @override
  String get renterName => 'Renter name';

  @override
  String get repeats => 'Repeats';

  @override
  String get replaceDocument => 'Replace document';

  @override
  String get replaceThisRejectedDocument => 'Replace this rejected document';

  @override
  String get reply => 'Reply';

  @override
  String get requests => 'Requests';

  @override
  String get requireAdvancePayment => 'Require advance payment';

  @override
  String get requirementAndCollectionAmount =>
      'Requirement and collection amount';

  @override
  String get requirementAndCollectionPercentage =>
      'Requirement and collection percentage.';

  @override
  String get resendOtpFailedPleaseTryAgain =>
      'Resend OTP failed. Please try again.';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get reset => 'Reset';

  @override
  String get resetOnboarding => 'Reset onboarding';

  @override
  String get resetToDefaultTemplate => 'Reset to default template';

  @override
  String get resolving => 'Resolving...';

  @override
  String get response => 'Response';

  @override
  String get retry => 'Retry';

  @override
  String get revenue => 'Revenue';

  @override
  String get reviewFacilitiesBeforeBooking =>
      'Review facilities before booking.';

  @override
  String get reviewYourBooking => 'Review your booking';

  @override
  String get viewDetails => 'View details';

  @override
  String get reviews => 'Reviews';

  @override
  String get requestEdit => 'Request edit';

  @override
  String get requestDelete => 'Request delete';

  @override
  String get requestEditTitle => 'Request an edit';

  @override
  String get requestDeleteTitle => 'Request a deletion';

  @override
  String get requestEditSubtitle =>
      'Write the wording that should replace it and why. A super admin reviews your request before anything changes.';

  @override
  String get requestDeleteSubtitle =>
      'Tell the super admin why this review should be taken down — abusive or offensive wording, for instance. They approve the removal before it disappears.';

  @override
  String get reason => 'Reason';

  @override
  String get updatedReview => 'Suggested wording';

  @override
  String get updatedReviewHint => 'How should this review read?';

  @override
  String get updatedReviewRequired =>
      'Please write the wording you are suggesting.';

  @override
  String get reasonHint => 'Write your reason...';

  @override
  String get reasonRequired => 'Please enter a reason.';

  @override
  String get submitRequest => 'Submit request';

  @override
  String get reviewRequestSubmitted =>
      'Your request has been sent to the super admin.';

  @override
  String get rs1200 => 'Rs. 1200';

  @override
  String get rulesToFollowAtThisVenue => 'Rules to follow at this venue';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saveEquipment => 'Save equipment';

  @override
  String get savePricing => 'Save Pricing';

  @override
  String get sayHelloAndStartTheConversation =>
      'Say hello and start the conversation.';

  @override
  String get searchByNameOrEmail => 'Search by name or email';

  @override
  String get searchConversations => 'Search conversations';

  @override
  String get searchVenuesCourtsOrLocation =>
      'Search venues, courts or location';

  @override
  String get select => 'Select';

  @override
  String get selectACategory => 'Select a category';

  @override
  String get selectACourt => 'Select a court';

  @override
  String get selectATimeSlotToSeePrices => 'Select a time slot to see prices.';

  @override
  String get selectAVenue => 'Select a venue';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectDateAndTime => 'Select Date & Time';

  @override
  String get selectMatchDateTime => 'Select match date & time';

  @override
  String get selectDateOfBirth => 'Select date of birth';

  @override
  String get selectEquipment => 'Select equipment';

  @override
  String get selectEquipmentType => 'Select equipment type';

  @override
  String get selectGender => 'Select gender';

  @override
  String get selectPlayerOrVendor => 'Select Player or Vendor';

  @override
  String get selectStatus => 'Select status';

  @override
  String get selectTheValueAddedServicesPlayersCanExpectOnBookingDays =>
      'Select the value-added services players can expect on booking days.';

  @override
  String get selectTime => 'Select Time';

  @override
  String get selectYourTeam => 'Select your team';

  @override
  String get selected => 'Selected';

  @override
  String get selectedLocation => 'Selected location';

  @override
  String get sendOpponentRequest => 'Send Opponent Request';

  @override
  String get setDefaultWeekendHolidayAndDiscountPrices =>
      'Set default, weekend, holiday, and discount prices.';

  @override
  String get settings => 'Settings';

  @override
  String get shareCurrentLocation => 'Share current location';

  @override
  String get shareIsNotAvailableForThisVenue =>
      'Share is not available for this venue.';

  @override
  String get signOut => 'Sign Out';

  @override
  String get slotLabel => 'Slot label';

  @override
  String get slotPricing => 'Slot Pricing';

  @override
  String get slotSchedule => 'Slot Schedule';

  @override
  String get slotsAndPayments => 'Slots & Payments';

  @override
  String get slotsUnavailable => 'Slots unavailable';

  @override
  String get slug => 'Slug';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get venueSlugMissing =>
      'This venue cannot be edited yet. Please reopen it from the venue list.';

  @override
  String get specialDaysForPricingAndBookingAvailability =>
      'Special days for pricing and booking availability';

  @override
  String get standard => 'Standard';

  @override
  String get start => 'Start';

  @override
  String get startAConversationFirstThenCreateAGroupFromIt =>
      'Start a conversation first, then create a group from it.';

  @override
  String get startRental => 'Start rental';

  @override
  String get startTime => 'Start time';

  @override
  String get started => 'Started';

  @override
  String get starter => 'Starter';

  @override
  String get status => 'Status';

  @override
  String get statusMix => 'Status mix';

  @override
  String get stepBreakdown => 'Step Breakdown';

  @override
  String get storeSettings => 'Store Settings';

  @override
  String get streetCityArea => 'Street, city, area';

  @override
  String get strikethrough => 'Strikethrough';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get support => 'Support';

  @override
  String get supportRefunds => 'Support refunds';

  @override
  String get chooseHowTheAppLooks => 'Choose how the app looks';

  @override
  String get tapTheHeartOnAVenueToSaveItHereForQuickBooking =>
      'Tap the heart on a venue to save it here for quick booking.';

  @override
  String get tapToPickLocationOnMap => 'Tap to pick location on map';

  @override
  String get tapToPickOnMap => 'Tap to pick on map';

  @override
  String get tapToUploadShopLogo => 'Tap to upload shop logo';

  @override
  String get tax => 'Tax';

  @override
  String get teamOptions => 'Team options';

  @override
  String get tellCustomersAboutThisCourt => 'Tell customers about this court.';

  @override
  String get tellCustomersAboutThisCourtSubtitle =>
      'Tell customers about this court';

  @override
  String get tellCustomersAboutYourFutsal =>
      'Tell customers about your futsal.';

  @override
  String get tellCustomersAboutYourFutsalSubtitle =>
      'Tell customers about your futsal';

  @override
  String get text10Steps => '10% steps';

  @override
  String get text5v5 => '5v5';

  @override
  String get text97798xxxxxxxx => '+977-98XXXXXXXX';

  @override
  String get text98xxxxxxxx => '98XXXXXXXX';

  @override
  String get text9xxXxxxxxx => '9XX-XXXXXXX';

  @override
  String get textColor => 'Text Color';

  @override
  String get thanksIWillConfirmTheTeamShortly =>
      'Thanks, I will confirm the team shortly.';

  @override
  String get thereAreNoFutsalVenuesToShowRightNow =>
      'There are no futsal venues to show right now.';

  @override
  String get thereAreNoNewPeopleAvailableToAddInThisGroup =>
      'There are no new people available to add in this group.';

  @override
  String get thisDocumentIsLockedWhileUnderReviewItCanBeRepla3c137b54 =>
      'This document is locked while under review. It can be replaced only after it is rejected.';

  @override
  String get thisDocumentWasRejectedPleaseRemoveItAndAddANewC30fa5f11 =>
      'This document was rejected. Please remove it and add a new, corrected document.';

  @override
  String get thisMessageWillBePermanentlyRemovedFromTheConversation =>
      'This message will be permanently removed from the conversation.';

  @override
  String get time => 'Time';

  @override
  String get timeSlots => 'Time Slots';

  @override
  String get timeSlotsWithPricingAndPaymentOptions =>
      'Time slots with pricing and payment options.';

  @override
  String get titleContactsLocationAmenitiesAndFeatures =>
      'Title, contacts, location, amenities, and features.';

  @override
  String get titlePhoneAndEmail => 'Title, phone, and email.';

  @override
  String get toDate => 'To date';

  @override
  String get today => 'Today';

  @override
  String get topCategory => 'Top category';

  @override
  String get topVenue => 'Top venue';

  @override
  String get total => 'Total';

  @override
  String get totalBooking => 'Total Booking';

  @override
  String get totalBookings => 'Total bookings';

  @override
  String get totalEarning => 'Total Earning';

  @override
  String get totalExpenses => 'Total expenses';

  @override
  String get totalQuantityInStock => 'Total quantity in stock';

  @override
  String get tournamentsEventsOrPromotionalMoments =>
      'Tournaments, events, or promotional moments.';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get trustedVenues => 'Trusted Venues';

  @override
  String get tryAdjustingOrClearingYourFilters =>
      'Try adjusting or clearing your filters.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get trySearchingWithAnotherNameOrEmail =>
      'Try searching with another name or email.';

  @override
  String get typing => 'typing…';

  @override
  String get unableToLoadVenues => 'Unable to load venues';

  @override
  String get unableToLoadBookings => 'Unable to load bookings';

  @override
  String get unableToLoadWishlist => 'Unable to load wishlist';

  @override
  String get underReview => 'Under review';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get unblock => 'Unblock';

  @override
  String get unmute => 'Unmute';

  @override
  String get underline => 'Underline';

  @override
  String get undo => 'Undo';

  @override
  String get units => 'Units';

  @override
  String get update => 'Update';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get updatePricingForThisSlot => 'Update pricing for this slot';

  @override
  String get offerADiscountOnThisSlot => 'Offer a discount on this slot';

  @override
  String get discountStarts => 'Discount starts';

  @override
  String get discountEnds => 'Discount ends';

  @override
  String get anyTime => 'Any time';

  @override
  String get discountEndMustFollowStart =>
      'The discount must end after it starts.';

  @override
  String get discountNeedsTypeAndValue =>
      'Choose a discount type and enter an amount, or switch the discount off.';

  @override
  String get discountValueMustBePositive =>
      'Enter a discount amount greater than zero.';

  @override
  String get discountPercentTooHigh =>
      'A percentage discount cannot be more than 100%.';

  @override
  String get upgradeToVendor => 'Upgrade to Vendor';

  @override
  String get upload => 'Upload';

  @override
  String get uploadDocument => 'Upload document';

  @override
  String get uploadMedia => 'Upload media?';

  @override
  String get uploadPaymentReceipt => 'Upload payment receipt';

  @override
  String get uploadPhotosAndMemories => 'Upload Photos and Memories';

  @override
  String get uploadRegistrationPanLicenseAndRelatedDocuments =>
      'Upload registration, PAN, license, and related documents.';

  @override
  String get uploadThePrimaryCoverImageForYourFutsalListing =>
      'Upload the primary cover image for your futsal listing.';

  @override
  String get uploadTheQrUsedToCollectAdvancePayment =>
      'Upload the QR used to collect advance payment.';

  @override
  String get uploadTheQrUsedToCollectAdvancePayments =>
      'Upload the QR used to collect advance payments';

  @override
  String get uploadYourFutsalBusinessMediaAndDocuments =>
      'Upload your futsal business media and documents.';

  @override
  String get use8Characters => 'Use 8+ characters';

  @override
  String get passwordMustDifferFromCurrent =>
      'Use at least 8 characters, different from your current password.';

  @override
  String get useFaceIdOrFingerprintToSignIn =>
      'Use Face ID or fingerprint to sign in';

  @override
  String get useSeparateCourtMediaToShowConditionLayoutAndEvec64b5 =>
      'Use separate court media to show condition, layout, and events without mixing it into the futsal-level gallery.';

  @override
  String get vendor => 'Vendor';

  @override
  String get vendorOnboarding => 'Vendor Onboarding';

  @override
  String get venue => 'Venue';

  @override
  String get venueActions => 'Venue actions';

  @override
  String get venueAmenitiesAndKeyFeatures =>
      'Venue amenities and key features.';

  @override
  String get venueIdIsMissingForCourtAvailability =>
      'Venue id is missing for court availability.';

  @override
  String get venueIdIsMissingForSlotAvailability =>
      'Venue id is missing for slot availability.';

  @override
  String get venueIdentityAndContactDetails =>
      'Venue identity and contact details';

  @override
  String get venueLevelPhotosForTheListing =>
      'Venue-level photos for the listing.';

  @override
  String get venueRulesAndPlayerConductDetails =>
      'Venue rules and player conduct details';

  @override
  String get venues => 'Venues';

  @override
  String get view => 'View';

  @override
  String get viewAll => 'View all';

  @override
  String get viewFullScreen => 'View full screen';

  @override
  String get download => 'Download';

  @override
  String get saveQrCode => 'Save QR code';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get playerGuides => 'Player';

  @override
  String get vendorGuides => 'Vendor';

  @override
  String get learnTheBasics => 'Learn the basics';

  @override
  String get runYourVenue => 'Run your venue';

  @override
  String get playerVideosSubtitle =>
      'Short videos on booking courts, paying and finding opponents.';

  @override
  String get vendorVideosSubtitle =>
      'Short videos on setting up your venue, courts and bookings.';

  @override
  String get moreVideos => 'More videos';

  @override
  String get upNext => 'Up next';

  @override
  String get couldNotLoadVideos => 'Could not load videos.';

  @override
  String get couldNotParseVideosFromServer =>
      'Could not read the videos from the server.';

  @override
  String get startHere => 'Start here';

  @override
  String get noVideosYet => 'No videos yet';

  @override
  String get noVideosYetMessage =>
      'Video guides on how to use the app will appear here.';

  @override
  String get swipeForMoreQrs => 'Swipe for more QRs';

  @override
  String get downloadingAttachment => 'Downloading…';

  @override
  String get attachmentSaved => 'Saved to your device.';

  @override
  String get attachmentSavedToGallery => 'Saved to your gallery.';

  @override
  String get attachmentSavedToFiles => 'Saved to your Downloads.';

  @override
  String get attachmentSavePermissionDenied =>
      'Allow photo access to save this file to your device.';

  @override
  String get attachmentDownloadFailed =>
      'Could not download the file. Check your connection and try again.';

  @override
  String get attachmentUnavailable => 'There is no file to download.';

  @override
  String get openAttachment => 'Open file';

  @override
  String get proofIsAFile =>
      'This proof was submitted as a file rather than an image.';

  @override
  String get weKeepRefiningTheAppForSmootherPlayPlanning =>
      'We keep refining the app for smoother play planning.';

  @override
  String get weWillSendAVerificationCodeToThisEmail =>
      'We will send a verification code to this email.';

  @override
  String get website => 'Website';

  @override
  String get websiteOrSocialMediaLink => 'Website or Social Media Link';

  @override
  String get weekendAndClosures => 'Weekend & Closures';

  @override
  String get weekendDays => 'Weekend days';

  @override
  String get weekendHolidayAndDiscountPricing =>
      'Weekend, holiday, and discount pricing';

  @override
  String get weekendHolidaysAndClosures => 'Weekend, Holidays & Closures';

  @override
  String get weekendPrice => 'Weekend price';

  @override
  String get whereDoYouWantToPlay => 'Where do you want to play?';

  @override
  String get winnerPays => 'Winner pays';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get yakStackSolution => 'Yak Stack Solution';

  @override
  String get youBlockedThisUserUnblockThemToSendMessages =>
      'You blocked this user. Unblock them to send messages.';

  @override
  String get youCanUseEitherUploadedFileOrLogoUrlOwnerWillBeA12d1d437 =>
      'You can use either uploaded file or logo URL. Owner will be assigned automatically from logged-in AdminUser.';

  @override
  String get youExampleCom => 'you@example.com';

  @override
  String get yourAccountAndBookingInformationStayProtected =>
      'Your account and booking information stay protected.';

  @override
  String get yourName => 'Your name';

  @override
  String get yourTeam => 'Your team';

  @override
  String get yourVenues => 'Your Venues';

  @override
  String get accountType => 'Account Type';

  @override
  String get address => 'Address';

  @override
  String get amenitiesNotes => 'Amenities Notes';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get basicPriceRequired => 'Basic Price *';

  @override
  String get bookingAdvanceLimitDays => 'Booking Advance Limit (days) *';

  @override
  String get cancellationWindowHours => 'Cancellation Window (hours)';

  @override
  String get category => 'Category';

  @override
  String get city => 'City *';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get contactEmail => 'Contact Email *';

  @override
  String get contactPhone => 'Contact Phone *';

  @override
  String get country => 'Country *';

  @override
  String get couponCode => 'Coupon code';

  @override
  String get courtNameTitleCase => 'Court Name';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get depositNprOptional => 'Deposit (NPR, optional)';

  @override
  String get descriptionRequired => 'Description *';

  @override
  String get displayName => 'Display name';

  @override
  String get emailAddressSentenceCase => 'Email address';

  @override
  String get establishedYearRequired => 'Established Year *';

  @override
  String get exactLocationRequired => 'Exact Location *';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameSentenceCase => 'Full name';

  @override
  String get futsalNameRequired => 'Futsal Name *';

  @override
  String get futsalSlug => 'Futsal Slug *';

  @override
  String get gender => 'Gender';

  @override
  String get groupName => 'Group name';

  @override
  String get hourlyRateNpr => 'Hourly rate (NPR)';

  @override
  String get hours => 'Hours';

  @override
  String get hoursLowercase => 'hours';

  @override
  String get houseRules => 'House Rules *';

  @override
  String get item => 'Item';

  @override
  String get name => 'Name';

  @override
  String get newPassword => 'New Password';

  @override
  String get aNewCodeIsOnItsWay => 'A new code is on its way.';

  @override
  String get enterTheDigitCodeToContinue =>
      'Enter the code sent to your email to continue.';

  @override
  String get reEnterYourNewPassword => 'Re-enter your new password';

  @override
  String get wait => 'Wait';

  @override
  String get password => 'Password';

  @override
  String get passwordIsRequired => 'Password is required';

  @override
  String get passwordMustBeAtLeast8Characters =>
      'Password must be at least 8 characters';

  @override
  String get passwordResetSuccessfully => 'Password reset successfully.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseConfirmYourNewPassword => 'Please confirm your new password';

  @override
  String get phone => 'Phone';

  @override
  String get phoneNumberSentenceCase => 'Phone number';

  @override
  String get quantity => 'Quantity';

  @override
  String get registrationNumberOptional => 'Registration Number (optional)';

  @override
  String get rememberPassword => 'Remember password?';

  @override
  String get searchExactPlace => 'Search exact place';

  @override
  String get searchMembers => 'Search members';

  @override
  String get shopLogoUrl => 'Shop Logo URL';

  @override
  String get totalUnits => 'Total units';

  @override
  String get type => 'Type';

  @override
  String get url => 'URL';

  @override
  String get cloudinaryImageUrlExample =>
      'https://res.cloudinary.com/demo/image/upload/sample.jpg';

  @override
  String get hamroFutsalWebsiteUrl => 'https://hamrofutsal.com';

  @override
  String get hamroFutsalWebsiteUrlWithTrailingSlash =>
      'https://hamrofutsal.com/';

  @override
  String get mute => 'Mute';

  @override
  String get urlExample => 'https://example.com';

  @override
  String get venueId => 'Venue ID';

  @override
  String get websiteOptional => 'Website (optional)';

  @override
  String get bookingConfirmed => 'Booking confirmed';

  @override
  String get bookingConfirmedNotification =>
      'Your 7:00 PM booking at Goal Arena has been confirmed.';

  @override
  String get earlier => 'Earlier';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get markAsUnread => 'Mark as unread';

  @override
  String get justNow => 'Just now';

  @override
  String get matchReminder => 'Match reminder';

  @override
  String get matchReminderNotification =>
      'Your match starts in 2 hours at Riverside Futsal.';

  @override
  String get newMessage => 'New message';

  @override
  String get newMessageNotification =>
      'Suman sent you a message about tomorrow’s match.';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get noUnreadNotifications => 'No unread notifications';

  @override
  String get notificationsWillAppearHere =>
      'Important updates will appear here when they arrive.';

  @override
  String get oneHourAgo => '1 hour ago';

  @override
  String get opponentRequestNotification =>
      'Kathmandu Strikers want to play against your team.';

  @override
  String get opponentRequestReceived => 'Opponent request received';

  @override
  String get paymentReceived => 'Payment received';

  @override
  String get paymentReceivedNotification =>
      'Payment of NPR 1,500 was received successfully.';

  @override
  String get twentyMinutesAgo => '20 min ago';

  @override
  String get twoDaysAgo => '2 days ago';

  @override
  String get twoMinutesAgo => '2 min ago';

  @override
  String get unread => 'Unread';

  @override
  String get weekendOffer => 'Weekend offer';

  @override
  String get weekendOfferNotification =>
      'Book any morning slot this weekend and save 15%.';

  @override
  String get yesChange => 'Yes, change';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get youHaveReadEveryNotification =>
      'You have read every notification. Nice work!';

  @override
  String get bookingPaymentsWillAppearHere =>
      'Payments linked to your bookings will appear here.';

  @override
  String get futsalEarnings => 'Futsal earnings';

  @override
  String get moneyPaidForBookings => 'Money paid for bookings';

  @override
  String get moneyReceivedFromBookings => 'Money received from bookings';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get paid => 'Paid';

  @override
  String get pendingAmount => 'Pending amount';

  @override
  String get playerPayments => 'Player payments';

  @override
  String get refunded => 'Refunded';

  @override
  String get refunds => 'Refunds';

  @override
  String get searchTransactions => 'Search transactions';

  @override
  String get totalEarnings => 'Total earnings';

  @override
  String get totalSpent => 'Total spent';

  @override
  String get couldNotLoadTransactionHistory =>
      'Could not load transaction history';

  @override
  String get totalIn => 'Total in';

  @override
  String get totalOut => 'Total out';

  @override
  String get netAmount => 'Net amount';

  @override
  String get transactions => 'Transactions';

  @override
  String get allTransactions => 'All';

  @override
  String get incoming => 'Money in';

  @override
  String get outgoing => 'Money out';

  @override
  String get commission => 'Commission';

  @override
  String get grossAmount => 'Gross';

  @override
  String get netBalance => 'Net balance';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String get allTime => 'All time';

  @override
  String get dateRange => 'Date range';

  @override
  String get direction => 'Direction';

  @override
  String get filters => 'Filters';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get showTransactions => 'Show transactions';

  @override
  String get pickAStartDateHint => 'Pick a start date to close the range';

  @override
  String get pickAnEndDateHint => 'Pick an end date to close the range';

  @override
  String get transactionsWillAppearHere =>
      'Your payments, refunds and payouts will appear here.';

  @override
  String get vendorRequestSubmitted =>
      'Your vendor upgrade request has been sent to the super admin.';

  @override
  String get vendorRequestAlreadySubmitted =>
      'You have already requested to become a vendor.';

  @override
  String get authBrandTagline => 'Book your court. Gather your squad. Play.';

  @override
  String get authBrandSubline =>
      'Courts, bookings and matches in one place — for players and the venues they play at.';

  @override
  String get authBrandHighlightBook => 'Book nearby courts';

  @override
  String get authBrandDetailBook =>
      'See open slots and prices at venues near you.';

  @override
  String get authBrandDetailManage =>
      'Track, pay for and revisit every booking in one list.';

  @override
  String get authBrandDetailPlay =>
      'Post a match request and find a team to play.';

  @override
  String get authHowItWorks => 'How it works';

  @override
  String get authStepFindCourt => 'Find a court';

  @override
  String get authStepPickSlot => 'Pick a slot';

  @override
  String get authStepPlay => 'Show up & play';

  @override
  String get authStepListVenue => 'List your venue';

  @override
  String get authStepSetSlots => 'Set slots & prices';

  @override
  String get authStepGetBooked => 'Get booked';

  @override
  String get authAlsoInside => 'Also inside';

  @override
  String get authFeatureLiveSlots => 'Live slots';

  @override
  String get authFeatureOpponents => 'Opponent matching';

  @override
  String get authFeatureTeamChat => 'Team chat';

  @override
  String get authFeatureRewards => 'Rewards';

  @override
  String get authFeatureNepaliCalendar => 'Nepali calendar';

  @override
  String get authFeatureWalkIns => 'Walk-in bookings';

  @override
  String get authFeatureExpenses => 'Expenses';

  @override
  String get authFeaturePayouts => 'Payouts';

  @override
  String get authFeatureReports => 'Reports';

  @override
  String get authWorksOn => 'Phone · Tablet · Desktop';

  @override
  String get authBrandHighlightManage => 'Manage your bookings';

  @override
  String get authBrandHighlightPlay => 'Challenge opponents';

  @override
  String get authPlayerHeadline => 'Play more, arrange less';

  @override
  String get authPlayerTagline =>
      'Find a court, rally your squad and get on the pitch — without a single phone call.';

  @override
  String get authPlayerHighlightDiscover =>
      'Browse nearby venues with live prices and open slots';

  @override
  String get authPlayerHighlightBook =>
      'Book and pay in a few taps, then manage it all in one place';

  @override
  String get authPlayerHighlightCompete =>
      'Challenge other teams and keep track of every match';

  @override
  String get authVendorHeadline => 'Fill your courts, effortlessly';

  @override
  String get authVendorTagline =>
      'List your venue, take bookings around the clock and run the whole operation from one dashboard.';

  @override
  String get authVendorHighlightList =>
      'List your courts with photos, pricing and opening hours';

  @override
  String get authVendorHighlightAutomate =>
      'Accept bookings and payments automatically, day or night';

  @override
  String get authVendorHighlightInsights =>
      'Track earnings, occupancy and your best customers at a glance';

  @override
  String get updateAvailable => 'Update available';

  @override
  String get updateRequired => 'Update required';

  @override
  String get whatsNew => 'What\'s new';

  @override
  String get updateNow => 'Update now';

  @override
  String get later => 'Later';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checkingForUpdates => 'Checking for updates…';

  @override
  String get seeIfANewerVersionIsAvailable =>
      'See if a newer version is available';

  @override
  String get youAreOnTheLatestVersion => 'You\'re on the latest version.';

  @override
  String get updateCheckFailed =>
      'Couldn\'t check for updates. Please check your connection and try again.';

  @override
  String get couldNotOpenTheStore =>
      'Couldn\'t open the store. Please update from the store app.';

  @override
  String get updateRequiredToContinue =>
      'This update is required to keep using Hamro Futsal.';

  @override
  String get updateDownloadFailed =>
      'The update download failed. Please try again.';

  @override
  String get updateInstallFailed =>
      'Couldn\'t install the update. Please update from the store instead.';

  @override
  String get downloadingUpdate => 'Downloading update…';

  @override
  String get updateDownloaded => 'Update downloaded';

  @override
  String get restartToInstall => 'Restart to install';

  @override
  String get restartNow => 'Restart now';

  @override
  String get installingUpdate => 'Installing update…';

  @override
  String get updateReadyMessage =>
      'The update is ready. Restart the app to finish installing it.';

  @override
  String get openStore => 'Open store';

  @override
  String get openPlayStore => 'Open Play Store';

  @override
  String get openAppStore => 'Open App Store';

  @override
  String get newVersionAvailableMessage =>
      'A newer version of Hamro Futsal is available. Update to get the latest features and fixes.';

  @override
  String get forcedUpdateMessage =>
      'This version of Hamro Futsal is no longer supported. Update to the latest version to continue booking and managing your courts.';

  @override
  String get installedVersion => 'Installed';

  @override
  String get latestVersion => 'Latest';

  @override
  String get downloadSize => 'Download size';

  @override
  String get updateInBackgroundHint =>
      'The update downloads in the background — you can keep using the app.';

  @override
  String get rewards => 'Rewards';

  @override
  String get myRewards => 'My rewards';

  @override
  String get rewardPoints => 'Reward points';

  @override
  String get availablePoints => 'Available points';

  @override
  String get pointsEarned => 'Earned';

  @override
  String get pointsRedeemed => 'Redeemed';

  @override
  String get rewardTier => 'Tier';

  @override
  String get rewardHistory => 'Reward history';

  @override
  String get viewAllRewardHistory => 'View all activity';

  @override
  String get recentRewardActivity => 'Recent activity';

  @override
  String get generateCoupon => 'Generate coupon';

  @override
  String get generatingCoupon => 'Generating coupon…';

  @override
  String get couponGenerated => 'Coupon generated';

  @override
  String get copyCode => 'Copy code';

  @override
  String get codeCopied => 'Coupon code copied';

  @override
  String get rewardCouponReady =>
      'Your coupon is ready. Apply it at checkout to get your discount.';

  @override
  String get rewardProgrammeNote =>
      'Earn points on every completed booking and convert them into discount coupons.';

  @override
  String get noRewardPointsYet => 'No points yet';

  @override
  String get noRewardPointsYetMessage =>
      'Complete a booking to start earning reward points.';

  @override
  String get noRewardHistory => 'No reward activity';

  @override
  String get noRewardHistoryMessage =>
      'Your points earned and redeemed will show up here.';

  @override
  String get pleaseSelectTimeSlot =>
      'Please select a preferred time slot to continue.';

  @override
  String get couldNotLoadRewards =>
      'Could not load your rewards. Please try again.';

  @override
  String get couldNotLoadRewardHistory =>
      'Could not load your reward history. Please try again.';

  @override
  String get couldNotGenerateRewardCoupon =>
      'Could not generate a coupon right now. Please try again.';

  @override
  String get needMorePointsToRedeem => 'Need more points to redeem';

  @override
  String get rewardPointsExpiring => 'points expiring on';

  @override
  String get pressBackAgainToLeaveRequest =>
      'Press back again to leave this request.';

  @override
  String get checkout => 'Checkout';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get paymentDescriptionHint => 'e.g. 9KX2M7QF1042';

  @override
  String get paymentDescriptionHelp =>
      'The venue matches your payment against this, so enter the transaction ID exactly as it appears on your receipt.';

  @override
  String get paymentDescriptionRequired =>
      'Please provide your transaction ID.';

  @override
  String get amountDueNow => 'Due now';

  @override
  String get paymentAndProof => 'Payment & proof';

  @override
  String get priceSummary => 'Price summary';

  @override
  String get changeGroupName => 'Change group name';

  @override
  String get enterAGroupName => 'Enter a group name.';

  @override
  String get groupNameTooLong => 'Group name must be 255 characters or fewer.';

  @override
  String get offline => 'Offline';

  @override
  String get about => 'About';

  @override
  String get groupPhoto => 'Group photo';

  @override
  String get groupInfo => 'Group Info';

  @override
  String get blocked => 'Blocked';

  @override
  String get moreOptions => 'More options';

  @override
  String get leaveGroup => 'Leave group';

  @override
  String get leaveGroupQuestion => 'Leave this group?';

  @override
  String get leaveGroupMessage =>
      'You will stop receiving messages from this group and it will be removed from your chats.';

  @override
  String get leaving => 'Leaving…';

  @override
  String get you => 'You';

  @override
  String get groupMembersSectionHint => 'Tap a member to see their profile';

  @override
  String get unknownUser => 'Unknown user';

  @override
  String get online => 'Online';

  @override
  String get selectAll => 'Select all';

  @override
  String get groupFull => 'Group is full';

  @override
  String get tapANameToAddOrRemoveThem => 'Tap a name to add or remove them';

  @override
  String get nameTheGroupAndChooseWhoIsInIt =>
      'Name the group and choose who is in it';

  @override
  String get createGroupAction => 'Create group';

  @override
  String get groupMemberLimitReached =>
      'That is the most members a group can hold.';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get goalkeeper => 'Goalkeeper';

  @override
  String get defender => 'Defender';

  @override
  String get midfielder => 'Midfielder';

  @override
  String get forward => 'Forward';

  @override
  String get goalkeeperAbbr => 'GK';

  @override
  String get defenderAbbr => 'DF';

  @override
  String get midfielderAbbr => 'MF';

  @override
  String get forwardAbbr => 'FW';

  @override
  String get draft => 'Draft';

  @override
  String get pendingApproval => 'Pending approval';

  @override
  String get newLabel => 'New';

  @override
  String get invitationSent => 'Invitation sent';

  @override
  String get accepted => 'Accepted';

  @override
  String get sent => 'Sent';

  @override
  String get expired => 'Expired';

  @override
  String get awaitingYourPick => 'Awaiting your pick';

  @override
  String get autoRejected => 'Auto-rejected';

  @override
  String get evenSplit => 'Even';

  @override
  String get customPercent => 'Custom %';

  @override
  String get byTeam => 'By team';

  @override
  String get byResult => 'By result';

  @override
  String get paidInFull => 'Paid in full';

  @override
  String get awaitingPaymentVerification => 'Awaiting payment verification';

  @override
  String get partiallyPaid => 'Partially paid';

  @override
  String get paymentPending => 'Payment pending';

  @override
  String get couldNotParseYourTeams =>
      'Could not parse your teams from server.';

  @override
  String get invalidTeam => 'Invalid team.';

  @override
  String get couldNotParseTeam => 'Could not parse the team from server.';

  @override
  String get couldNotParsePlayerPositions =>
      'Could not parse player positions from server.';

  @override
  String get couldNotParseOpponentLevels =>
      'Could not parse opponent levels from server.';

  @override
  String get couldNotReadMatchDetails => 'Could not read the match details.';

  @override
  String get couldNotParseMatchDetails =>
      'Could not parse the match details from server.';

  @override
  String get couldNotParseOpponentRequests =>
      'Could not parse opponent requests from server.';

  @override
  String get requestCouldNotBeFound => 'That request could not be found.';

  @override
  String get couldNotParseOpponentRequest =>
      'Could not parse that opponent request.';

  @override
  String get teamNameCannotBeEmpty => 'Team name cannot be empty.';

  @override
  String get playerNameCannotBeEmpty => 'Player name cannot be empty.';

  @override
  String get invalidMember => 'Invalid member.';

  @override
  String get couldNotParseInvitations =>
      'Could not parse the invitations from server.';

  @override
  String get couldNotParseAcceptedRequest =>
      'Could not parse the accepted request from server.';

  @override
  String get couldNotReadRequestAfterAccepting =>
      'Could not read the request after accepting.';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get conditional => 'Conditional';

  @override
  String get courtFeeNotSetYetMessage => 'Court fee not set yet';

  @override
  String percentMySide(int percent) {
    return '$percent% my side';
  }

  @override
  String yourShareOfCourtFee(String share, String total, int percent) {
    return 'Your share $share of $total ($percent%)';
  }

  @override
  String loserWinnerShares(
    String loserShare,
    int loserPercent,
    String winnerShare,
  ) {
    return 'Loser $loserShare ($loserPercent%) · Winner $winnerShare';
  }

  @override
  String get matchDetailsNotSavedYet =>
      'The match details have not been saved yet. Go back a step and try again.';

  @override
  String get requestNotOpenedOnServerYet =>
      'This request has not been opened on the server yet. Go back and save the match details first.';

  @override
  String get invitationMissingId =>
      'That invitation is missing its id — refresh and try again.';

  @override
  String get noPlayersYet => 'No players yet';

  @override
  String playerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players',
      one: '$count player',
    );
    return '$_temp0';
  }

  @override
  String get addYourFirstPlayer => 'Add your first player';

  @override
  String get addPlayer => 'Add Player';

  @override
  String get couldNotLoadVenuesRetry => 'Could not load venues. Retry';

  @override
  String noVenuesMatch(String query) {
    return 'No venues match \"$query\".';
  }

  @override
  String get teamsStillLoading =>
      'Your teams are still loading — try again in a moment.';

  @override
  String get findAnOpponent => 'Find an Opponent';

  @override
  String get couldNotLoadOpponentRequests =>
      'Could not load opponent requests.';

  @override
  String get couldNotLoadYourTeams => 'Could not load your teams.';

  @override
  String get closed => 'Closed';

  @override
  String deleteTeamConfirmation(String teamName) {
    return 'This removes \"$teamName\" and its players. This can\'t be undone.';
  }

  @override
  String get thisPlayer => 'this player';

  @override
  String removePlayerConfirmation(String playerName, String teamName) {
    return 'This removes \"$playerName\" from \"$teamName\". This can\'t be undone.';
  }

  @override
  String get createTeamAndAddPlayersHint =>
      'Create a team and add players — you\'ll pick it when sending a match request.';

  @override
  String get teamName => 'Team name';

  @override
  String get editPlayer => 'Edit Player';

  @override
  String get playerNameHint => 'Player name';

  @override
  String get playerEmailHint => 'Player email';

  @override
  String positionInTeam(String teamName) {
    return 'Position in $teamName';
  }

  @override
  String get saveChangesTitle => 'Save Changes';

  @override
  String get selectAnExistingBooking => 'Select an existing booking';

  @override
  String get existingBookingSheetSubtitle =>
      'The court, date, time and fee are taken from the booking you pick.';

  @override
  String get existingBookingSearchHint => 'Venue, court or booking reference';

  @override
  String get couldNotLoadYourBookingsRetry =>
      'Could not load your bookings. Retry';

  @override
  String get noBookingMatchesYourSearch => 'No booking matches your search.';

  @override
  String get noUpcomingBookingsToAttach =>
      'You have no upcoming bookings to attach.\nBook a court first, or enter the venue manually.';

  @override
  String get courtFee => 'Court fee';

  @override
  String get mySidePays => 'My side pays';

  @override
  String get winner => 'Winner';

  @override
  String get opponent => 'Opponent';

  @override
  String get perPlayer => 'Per player';

  @override
  String perPlayerCount(int count) {
    return 'Per player ($count)';
  }

  @override
  String get youPayIfLoser => 'You pay (if loser)';

  @override
  String get youPay => 'You pay';

  @override
  String get matchChatNotOpenYet => 'The match chat is not open yet.';

  @override
  String get matchDetails => 'Match details';

  @override
  String get matchNoLongerAvailable => 'This match is no longer available.';

  @override
  String get kickoff => 'Kickoff';

  @override
  String get slot => 'Slot';

  @override
  String get format => 'Format';

  @override
  String get linkedVenueBooking => 'Linked venue booking';

  @override
  String get notSet => 'Not set';

  @override
  String get venueLinkedToThisMatch => 'Venue linked to this match';

  @override
  String get arrangedOutsideTheApp => 'Arranged outside the app';

  @override
  String get bookingReference => 'Booking reference';

  @override
  String get costSplit => 'Cost split';

  @override
  String get totalCourtFee => 'Total court fee';

  @override
  String get matchChat => 'Match chat';

  @override
  String get openMatchChat => 'Open Match Chat';

  @override
  String get yourShare => 'Your share';

  @override
  String get opponentShare => 'Opponent share';

  @override
  String get decidedByResult => 'Decided by result';

  @override
  String get versusAbbr => 'VS';

  @override
  String get matchCreatedChatRoomOpened => 'Match created · chat room opened';

  @override
  String get waitingOnFinalConfirmation => 'Waiting on final confirmation';

  @override
  String get team => 'Team';

  @override
  String get chatRoomCreatedAutomatically => 'Chat room created automatically';

  @override
  String get chatOpensOnceOpponentConfirmed =>
      'Chat opens once the opponent is confirmed';

  @override
  String get matchChatEnabledDescription =>
      'Coordinate kit, arrival time and the court fee with the other captain.';

  @override
  String get matchChatPendingDescription =>
      'Both captains get access as soon as the match is created.';

  @override
  String percentInParentheses(int percent) {
    return '($percent%)';
  }

  @override
  String playTeamQuestion(String teamName) {
    return 'Play $teamName?';
  }

  @override
  String selectOpponentConfirmSolo(String teamName) {
    return 'The match will be created and the venue linked to this request. A chat room with $teamName opens automatically.';
  }

  @override
  String selectOpponentConfirmWithOthers(String teamName, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others invitations',
      one: '$others invitation',
    );
    return 'The match will be created with $teamName and the venue linked to this request. The other $_temp0 will be rejected automatically.';
  }

  @override
  String get confirmOpponent => 'Confirm opponent';

  @override
  String matchConfirmedWithTeam(String teamName) {
    return 'Match confirmed with $teamName.';
  }

  @override
  String matchConfirmedWithTeamOthersRejected(String teamName, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others invitations',
      one: '$others invitation',
    );
    return 'Match confirmed with $teamName. $_temp0 auto-rejected.';
  }

  @override
  String get waitingForInvitationsMessage =>
      'Your request is visible to all eligible teams. As soon as a team accepts, its invitation appears here.';

  @override
  String get selectOneOpponentMessage =>
      'Message a captain to agree the details, then confirm the team you trust. You can wait for more acceptances first — the remaining invitations are rejected automatically once you confirm one.';

  @override
  String invitationsReceived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitations received',
      one: '$count invitation received',
    );
    return '$_temp0';
  }

  @override
  String totalLoserPaysMore(String total) {
    return '$total total · loser pays more';
  }

  @override
  String totalWithYourShare(String total, String share, int percent) {
    return '$total total · your share $share ($percent%)';
  }

  @override
  String theirShare(String share) {
    return 'Their share $share';
  }

  @override
  String get loserPaysDecidedByResult => 'Loser pays — decided by the result';

  @override
  String ifTheyLose(String amount) {
    return 'If they lose $amount';
  }

  @override
  String playersCount(int count) {
    return '$count players';
  }

  @override
  String answeredAt(String when) {
    return 'answered $when';
  }

  @override
  String acceptedAt(String when) {
    return 'accepted $when';
  }

  @override
  String chatWith(String name) {
    return 'Chat with $name';
  }

  @override
  String get thisTeam => 'this team';

  @override
  String matchConfirmedWith(String opponent) {
    return 'Match confirmed with $opponent';
  }

  @override
  String confirmingRejectsOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitations',
      one: '$count invitation',
    );
    return 'Confirming rejects the other $_temp0 automatically.';
  }

  @override
  String get invitations => 'Invitations';

  @override
  String get requestNoLongerAvailable => 'This request is no longer available.';

  @override
  String get waitingForInvitations => 'Waiting for invitations';

  @override
  String get selectOneOpponent => 'Select one opponent';

  @override
  String get noInvitationsYet => 'No invitations yet';

  @override
  String get loadingInvitations => 'Loading invitations…';

  @override
  String get checkingForNewInvitations => 'Checking for new invitations…';

  @override
  String get waitingForTeamsToAccept => 'Waiting for teams to accept';

  @override
  String get pullDownToRefreshInvitations =>
      'Pull down to refresh. You will be notified as invitations arrive.';

  @override
  String get viewMatchDetails => 'View match details';

  @override
  String get selectThisOpponent => 'Select This Opponent';

  @override
  String teamCreatedSendAcceptance(String teamName) {
    return '$teamName created — you can send your acceptance now.';
  }

  @override
  String get acceptChallengeGuidance =>
      'Choose the team that will play and send your acceptance — you can message the requester from the team section first. They may receive several acceptances and pick one opponent. The court fee is settled at the venue.';

  @override
  String get confirmSquadSizeBeforeCommit =>
      'Confirm the squad size and timing before you commit a team.';

  @override
  String get needTeamToAcceptChallenge =>
      'You need a team to accept this challenge. Name it now and add players later.';

  @override
  String amountCourtFee(String amount) {
    return '$amount court fee';
  }

  @override
  String feeTheLoserPays(String fee) {
    return '$fee · the loser pays';
  }

  @override
  String feeLoseAndYouPay(String fee, String amount) {
    return '$fee · lose and you pay $amount';
  }

  @override
  String feeLoserPaysAmount(String fee, String amount) {
    return '$fee · loser pays $amount';
  }

  @override
  String feeYourShare(String fee, String share, int percent) {
    return '$fee · your share $share ($percent%)';
  }

  @override
  String amountPerPlayer(String amount) {
    return '$amount / player';
  }

  @override
  String get winAndPayNothingSettledAtVenue =>
      'Win and you pay nothing. Settled with the venue on match day.';

  @override
  String rosterTooSmallForFormat(int formatSize) {
    return 'This roster has fewer than $formatSize players for the requested format.';
  }

  @override
  String get acceptanceReachesRequester =>
      'Your acceptance reaches the requester as an invitation.';

  @override
  String get theVenue => 'the venue';

  @override
  String ifTeamPickedMatchCreatedAt(String venue) {
    return 'If your team is picked, the match is created at $venue and a chat room opens for both teams.';
  }

  @override
  String get somethingWentWrongTryAgain =>
      'Something went wrong. Please try again.';

  @override
  String get requesterCannotBeMessagedYet =>
      'This requester cannot be messaged yet.';

  @override
  String get acceptRequest => 'Accept request';

  @override
  String get acceptanceSentRequesterWillConfirm =>
      'Acceptance sent — the requester will confirm the opponent.';

  @override
  String get acceptChallengeNoPaymentNeeded =>
      'Accept this challenge — no payment needed';

  @override
  String get messageToTheRequester => 'Message to the requester';

  @override
  String get anythingOtherCaptainShouldKnow =>
      'Anything the other captain should know…';

  @override
  String get sendAcceptance => 'Send Acceptance';

  @override
  String get requestHasNoContactToMessage =>
      'This request did not carry a contact to message.';

  @override
  String get teamNameExampleHint => 'e.g. Thamel Tigers';

  @override
  String get ifYouLose => 'If you lose';

  @override
  String get settledWithVenueOnMatchDay =>
      'Settled with the venue on match day.';

  @override
  String get whatHappensNext => 'What happens next';

  @override
  String get mayWaitForOtherTeamsThenSelect =>
      'They may wait for other teams, then select one opponent.';

  @override
  String get reviewInvitation => 'Review Invitation';

  @override
  String reviewInvitations(int count) {
    return 'Review $count Invitations';
  }

  @override
  String get matchDetailsLower => 'match details';

  @override
  String get theCostSplit => 'the cost split';

  @override
  String draftNotPublishedFinishStep(String step) {
    return 'Draft — not published yet. Finish $step to send it out.';
  }

  @override
  String removeRequestConfirmation(String teamName) {
    return 'This will remove the request from $teamName. You can\'t undo this.';
  }

  @override
  String courtFeeSplitNotSetYet(String total) {
    return '$total court fee · split not set yet';
  }

  @override
  String loserPaysTotal(String total) {
    return 'Loser pays · $total total';
  }

  @override
  String get decidedByMatchResult => 'Decided by match result';

  @override
  String loserPaysAmount(String amount) {
    return 'Loser pays $amount';
  }

  @override
  String amountTotal(String total) {
    return '$total total';
  }

  @override
  String ifLoserTotal(String share, String total) {
    return '$share if loser · $total total';
  }

  @override
  String sharePercentOfTotal(String share, int percent, String total) {
    return '$share · $percent% of $total';
  }

  @override
  String opponentNamed(String teamName) {
    return 'Opponent: $teamName';
  }

  @override
  String teamsWantToPlayPickOne(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teams want to play — pick one',
      one: '$count team wants to play — pick one',
    );
    return '$_temp0';
  }

  @override
  String get submittedWaitingForApproval =>
      'Submitted — waiting for approval before teams can see it.';

  @override
  String get acceptanceSentWaitingForPick =>
      'Acceptance sent — waiting for the requester to pick an opponent';

  @override
  String get noInvitationsYetMessage =>
      'Requests your team has accepted will appear here until the requester picks an opponent.';

  @override
  String get needOpponent => 'Need Opponent';

  @override
  String get myRequests => 'My Requests';

  @override
  String get couldNotLoadTheseRequests => 'Could not load these requests.';

  @override
  String get awaitingInvitations => 'Awaiting Invitations';

  @override
  String get kickOffTimeNotSetYet => 'Kick-off time not set yet';

  @override
  String get venueNotChosenYet => 'Venue not chosen yet';

  @override
  String get viewMatchDetailsTitle => 'View Match Details';

  @override
  String get acceptRequestTitle => 'Accept Request';

  @override
  String get nothingToActOn => 'Nothing to act on';

  @override
  String get openRequestsWillAppearHere => 'Open requests will appear here.';

  @override
  String get noRequestsSent => 'No requests sent';

  @override
  String get noRequestsSentMessage =>
      'Requests you send to opponents will appear here while they wait for a reply.';

  @override
  String get noSettledRequests => 'No settled requests';

  @override
  String get noSettledRequestsMessage =>
      'Accepted, rejected and closed requests will show here.';

  @override
  String get fillInExternalVenueDetails =>
      'Fill in the venue, its location, the fee and the booked date and time.';

  @override
  String rsAmount(String amount) {
    return 'Rs $amount';
  }

  @override
  String maxPlayersLabel(Object count) {
    return '$count Players';
  }

  @override
  String get whoPlaysGuidance =>
      'Pick the team that will play — its roster size drives the per-player share shown later — then describe the match you want. The match date and time come from the booking you attach next.';

  @override
  String get noTeamsYetCreateRequestMessage =>
      'A request is published in a team\'s name, so create the team that will play this match.';

  @override
  String get venueAlreadyBookedMessage =>
      'A published request always carries a venue, so opponents know exactly where and when they are playing.';

  @override
  String get venueBookingConfirmed => 'Venue booking confirmed';

  @override
  String get configureCostSplitMessage =>
      'Decide how the court fee is divided with the opponent. The accepting team sees this exact rule before it pays.';

  @override
  String get reviewAndPublishMessage =>
      'Once published, every eligible team can see this request and send you an invitation. You pick the opponent you want.';

  @override
  String loserPaysPercent(int percent) {
    return 'Loser pays $percent%';
  }

  @override
  String youPayPercent(int percent) {
    return 'You pay $percent%';
  }

  @override
  String get afterPublishingNote =>
      'After publishing, the request becomes visible to all eligible teams and their invitations arrive under My Requests.';

  @override
  String bookingReferenceLine(String reference) {
    return 'Booking $reference';
  }

  @override
  String get teamAndMatch => 'Team & match';

  @override
  String get publish => 'Publish';

  @override
  String get teamAndMatchSubtitle => 'Your team, format and level';

  @override
  String get attachTheCourtBooking => 'Attach the court booking';

  @override
  String get whoPaysWhat => 'Who pays what';

  @override
  String get reviewAndGoLive => 'Review and go live';

  @override
  String get someMatchDetailsStillLoading =>
      'Some match details are still loading. Please try again.';

  @override
  String get selectTheTeamThatWillPlay => 'Select the team that will play.';

  @override
  String get pickAMatchTypeToContinue => 'Pick a match type to continue.';

  @override
  String get pickVenueThenConfirmSlot =>
      'Pick a venue, then confirm a court slot.';

  @override
  String get selectBookingThatHostsMatch =>
      'Select the booking that hosts this match.';

  @override
  String get endTimeMustBeAfterStartTime =>
      'The end time has to be after the start time.';

  @override
  String get completeThisStepToContinue => 'Complete this step to continue.';

  @override
  String get selectBookableVenueFirst => 'Select a bookable venue first.';

  @override
  String get kickoffAndVenue => 'Kickoff & venue';

  @override
  String get futsalVenue => 'Futsal venue';

  @override
  String get publishRequest => 'Publish Request';

  @override
  String get continueLabel => 'Continue';

  @override
  String get whoPlaysAndWhatMatch => 'Who plays, and what match?';

  @override
  String get selectOrCreateTeam => 'Select / create team';

  @override
  String get couldNotLoadYourTeamsTitle => 'Could not load your teams';

  @override
  String get couldNotLoadMatchTypes => 'Could not load match types.';

  @override
  String get opponentLevel => 'Opponent Level';

  @override
  String get matchPreview => 'Match preview';

  @override
  String get noTeamSelectedYet => 'No team selected yet';

  @override
  String get dateTimeVenueSetOnNextStep =>
      'Date, time and venue are set on the next step';

  @override
  String get venueAlreadyBooked => 'Venue already booked?';

  @override
  String get venueArrangement => 'Venue arrangement';

  @override
  String get yesAlreadyBookedVenue => 'Yes — I already booked a venue';

  @override
  String get yesAlreadyBookedVenueSubtitle =>
      'Attach one of your bookings, or enter an outside booking.';

  @override
  String get noFindAndBookCourtNow => 'No — find and book a court now';

  @override
  String get noFindAndBookCourtNowSubtitle =>
      'Browse venues, pick a court, date and time, then confirm.';

  @override
  String get selectExistingBooking => 'Select existing booking';

  @override
  String get myBookingsLower => 'My bookings';

  @override
  String get bookedElsewhere => 'Booked elsewhere';

  @override
  String get chooseFromYourBookings => 'Choose from your bookings';

  @override
  String get bookingDetailsFilledInForYou =>
      'Court, date, time and fee are filled in for you';

  @override
  String get bookingAttached => 'Booking attached';

  @override
  String get venueName => 'Venue name';

  @override
  String get enterTheBookedVenue => 'Enter the booked venue';

  @override
  String get enterTheVenueName => 'Enter the venue name';

  @override
  String get venueLocation => 'Venue location';

  @override
  String get areaCityOrFullAddress => 'Area, city or full address';

  @override
  String get enterTheVenueLocation => 'Enter the venue location';

  @override
  String get whatYouPaidForTheCourt => 'What you paid for the court';

  @override
  String get enterTheTotalCourtFee => 'Enter the total court fee';

  @override
  String get bookedDateAndTime => 'Booked date & time';

  @override
  String get findAndBookACourtNow => 'Find and book a court now';

  @override
  String get chooseCourtDateAndSlot =>
      'Choose a court, date and available time slot';

  @override
  String get open => 'Open';

  @override
  String get configureTheCostSplitRule => 'Configure the cost split rule';

  @override
  String get reviewAndPublish => 'Review and publish';

  @override
  String get addAMessageOptional => 'Add a message (optional)';

  @override
  String get requestSummary => 'Request summary';

  @override
  String get match => 'Match';

  @override
  String teamCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teams',
      one: '$count team',
    );
    return '$_temp0';
  }

  @override
  String requestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests',
      one: '$count request',
    );
    return '$_temp0';
  }

  @override
  String openCount(int count) {
    return '$count open';
  }

  @override
  String get chatUnavailable => 'Chat unavailable';

  @override
  String get couldNotLoadCourtWeek =>
      'Could not load this court\'s week from the server.';

  @override
  String get couldNotLoadDaySlots =>
      'Could not load the day\'s slots from the server.';

  @override
  String get slotCouldNotBeHeld =>
      'This slot could not be held. It may have just been booked.';

  @override
  String get partlyPaid => 'Partly paid';

  @override
  String venueNumber(Object id) {
    return 'Venue $id';
  }

  @override
  String courtNumber(Object id) {
    return 'Court $id';
  }

  @override
  String get upcoming => 'Upcoming';

  @override
  String get inProgress => 'In progress';

  @override
  String get outstandingPayment => 'Outstanding payment';

  @override
  String get onHold => 'On hold';

  @override
  String get noSlots => 'No slots';

  @override
  String get courtInactive => 'Court inactive';

  @override
  String get closedAllDay => 'Closed all day';

  @override
  String get noScheduleSet => 'No schedule set';

  @override
  String get weekSunToSat => 'Sun – Sat';

  @override
  String get fromToday => 'From today';

  @override
  String noSlotsOn(String day) {
    return 'No slots on $day';
  }

  @override
  String closedOn(String day) {
    return 'Closed on $day';
  }

  @override
  String get past => 'Past';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get liveSlotsDidNotLoad =>
      'Live slots did not load — showing the court\'s schedule.';

  @override
  String get bookingLower => 'booking';

  @override
  String get bookingsLower => 'bookings';

  @override
  String get bookedLower => 'booked';

  @override
  String get freeLower => 'free';

  @override
  String get valueLower => 'value';

  @override
  String get dueLower => 'due';

  @override
  String get paidLower => 'paid';

  @override
  String get tapToShowOnBoard => '. Tap to show on board';

  @override
  String hoursShort(Object hours) {
    return '$hours h';
  }

  @override
  String openCourtHoursBooked(Object booked, Object sellable) {
    return '$booked of $sellable open court-hours booked';
  }

  @override
  String hoursPassedUnbooked(Object hours) {
    return ' · $hours h passed unbooked';
  }

  @override
  String occupancySemantics(int percent, Object booked, Object sellable) {
    return '$percent percent of open court time booked. $booked of $sellable hours.';
  }

  @override
  String get closeBookingDetails => 'Close booking details';

  @override
  String get customer => 'Customer';

  @override
  String get slots => 'Slots';

  @override
  String get paymentsHeader => 'PAYMENTS';

  @override
  String get actionsAndReceipt => 'Actions & receipt';

  @override
  String get actionsAndReceiptNotInDemo => 'Actions & receipt (not in demo)';

  @override
  String get noCourtsMatchFilters => 'No courts match these filters.';

  @override
  String get dateSlotsCouldNotLoad => 'This date\'s slots could not be loaded.';

  @override
  String get full => 'Full';

  @override
  String get weekLink => 'Week ›';

  @override
  String get nextFree => 'Next free';

  @override
  String get noneLeft => 'None left';

  @override
  String get hideEarlier => 'Hide earlier';

  @override
  String get noSlotsLeftOnDay => 'No slots left on this day.';

  @override
  String get onCourtNow => 'On court now';

  @override
  String get nextBooking => 'Next booking';

  @override
  String get none => 'None';

  @override
  String get priceOnConfirmationLower => 'price on confirmation';

  @override
  String get loadingCourtsSlots => 'Loading courts\' slots';

  @override
  String courtsFreeSummary(int count, Object free) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courts · $free free',
      one: '$count court · $free free',
    );
    return '$_temp0';
  }

  @override
  String freeCount(Object count) {
    return '$count free';
  }

  @override
  String slotsDuration(Object duration) {
    return '$duration slots';
  }

  @override
  String showEarlier(int count) {
    return 'Show earlier ($count)';
  }

  @override
  String bookingTill(Object name, Object time) {
    return '$name · till $time';
  }

  @override
  String availableSlotSemantics(String time, String selected, String price) {
    String _temp0 = intl.Intl.selectLogic(selected, {
      'true': '$time, selected, $price. Tap to remove.',
      'other': '$time, available, $price. Tap to add to booking.',
    });
    return '$_temp0';
  }

  @override
  String bookedSlotSemantics(
    String time,
    String phase,
    String customer,
    String payment,
  ) {
    return '$time, $phase, $customer, $payment. Tap for details.';
  }

  @override
  String closedSlotSemantics(String time) {
    return '$time, closed';
  }

  @override
  String pastSlotSemantics(String time) {
    return '$time, past';
  }

  @override
  String percentBooked(int percent) {
    return '$percent% booked';
  }

  @override
  String get there => 'there';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get mondayUpper => 'MONDAY';

  @override
  String get tuesdayUpper => 'TUESDAY';

  @override
  String get wednesdayUpper => 'WEDNESDAY';

  @override
  String get thursdayUpper => 'THURSDAY';

  @override
  String get fridayUpper => 'FRIDAY';

  @override
  String get saturdayUpper => 'SATURDAY';

  @override
  String get sundayUpper => 'SUNDAY';

  @override
  String get showingToday => 'Showing today';

  @override
  String get goToToday => 'Go to today';

  @override
  String get showNormalHome => 'Show normal home';

  @override
  String get showOperationsHome => 'Show operations home';

  @override
  String get operationsHomeSelected => 'Operations home selected';

  @override
  String get normalHomeSelected => 'Normal home selected';

  @override
  String get ops => 'Ops';

  @override
  String get oneVenue => '1 venue';

  @override
  String get allCourts => 'All courts';

  @override
  String get oneCourt => '1 court';

  @override
  String get bookingStatus => 'Booking status';

  @override
  String get anyStatus => 'Any status';

  @override
  String get namePhoneOrReference => 'Name, phone or reference';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get noMatches => 'No matches';

  @override
  String get showAll => 'Show all';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name 👋';
  }

  @override
  String selectedDateChange(String date) {
    return 'Selected date $date. Change date';
  }

  @override
  String venuesCount(int count) {
    return '$count venues';
  }

  @override
  String courtsCount(int count) {
    return '$count courts';
  }

  @override
  String searchIn(String what) {
    return 'Search $what';
  }

  @override
  String allOf(String what) {
    return 'All $what';
  }

  @override
  String applyCount(int count) {
    return 'Apply ($count)';
  }

  @override
  String get noCourtsMatchVenueFilter => 'No courts match the venue filter.';

  @override
  String get fullThisWeek => 'full this week';

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get weekStartsFrom => 'Week starts from';

  @override
  String get weekStartsFromHeader => 'WEEK STARTS FROM';

  @override
  String get sundayInitial => 'S';

  @override
  String get mondayInitial => 'M';

  @override
  String get tuesdayInitial => 'T';

  @override
  String get wednesdayInitial => 'W';

  @override
  String get thursdayInitial => 'T';

  @override
  String get fridayInitial => 'F';

  @override
  String get saturdayInitial => 'S';

  @override
  String get calendarWeek => 'Calendar week';

  @override
  String get startingToday => 'Starting today';

  @override
  String get sundayToSaturday => 'Sunday to Saturday';

  @override
  String get todayAndNextSixDays => 'Today and the next 6 days';

  @override
  String get timeSlot => 'Time slot';

  @override
  String get sameBooking => 'Same booking';

  @override
  String get customerLower => 'customer';

  @override
  String get closedLower => 'closed';

  @override
  String get loadingCourtWeek => 'Loading this court\'s week';

  @override
  String thisWeekRange(String range) {
    return 'This week · $range';
  }

  @override
  String courtClosedAllWeek(String court) {
    return '$court is closed all week.';
  }

  @override
  String courtHasNoSlotsThisWeek(String court) {
    return '$court has no slots set for this week.';
  }

  @override
  String timeRangeSemantics(String start, String end) {
    return '$start to $end';
  }

  @override
  String weekAvailableSlotSemantics(
    String when,
    String selected,
    String price,
  ) {
    String _temp0 = intl.Intl.selectLogic(selected, {
      'true': '$when, selected, $price',
      'other': '$when, available, $price',
    });
    return '$_temp0';
  }

  @override
  String weekBookedSlotSemantics(
    String when,
    String phase,
    String customer,
    String payment,
  ) {
    return '$when, $phase, $customer, $payment';
  }

  @override
  String slotNoteSemantics(String when, String note) {
    return '$when, $note';
  }

  @override
  String noSlotSemantics(String when) {
    return '$when, no slot';
  }

  @override
  String get couldNotLoadYourVenues => 'Could not load your venues';

  @override
  String get checkConnectionAndRetry => 'Check your connection and retry.';

  @override
  String get noVenuesToManageYet => 'No venues to manage yet';

  @override
  String get noVenuesToManageMessage =>
      'Once a venue with courts is approved, today\'s bookings and availability appear here.';

  @override
  String get refresh => 'Refresh';

  @override
  String get bookingsForDateCouldNotLoad =>
      'Bookings for this date could not be loaded.';

  @override
  String get priceOnConfirmation => 'Price on confirmation';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get review => 'Review';

  @override
  String get loadingTodaysOperations => 'Loading today\'s operations';

  @override
  String get availability => 'Availability';

  @override
  String get statusKey => 'STATUS KEY';

  @override
  String get hideStatuses => 'Hide statuses';

  @override
  String get viewStatuses => 'View statuses';

  @override
  String get day => 'Day';

  @override
  String get week => 'Week';

  @override
  String get everyCourtToday => 'Every court today';

  @override
  String get oneCourtWholeWeek => 'One court, whole week';

  @override
  String todayWithDate(String date) {
    return 'Today · $date';
  }

  @override
  String selectionHeadline(int slots, String hours) {
    String _temp0 = intl.Intl.pluralLogic(
      slots,
      locale: localeName,
      other: '$slots slots',
      one: '$slots slot',
    );
    return '$_temp0 · $hours court-h';
  }

  @override
  String estimatedPrice(String amount, String allPriced) {
    String _temp0 = intl.Intl.selectLogic(allPriced, {
      'true': 'Est. $amount',
      'other': 'Est. from $amount',
    });
    return '$_temp0';
  }

  @override
  String courtsPriceDetail(int courts, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      courts,
      locale: localeName,
      other: '$courts courts',
      one: '$courts court',
    );
    return '$_temp0 · $price';
  }

  @override
  String selectedSummarySemantics(String headline, String detail) {
    return 'Selected: $headline, $detail';
  }

  @override
  String get couldNotReadCandidates =>
      'Could not read candidates from the server.';

  @override
  String get cash => 'Cash';

  @override
  String get enterAmountForEveryPayment =>
      'Enter an amount for every payment, or remove it.';

  @override
  String get releaseHeldSlotsTitle => 'Release held slots?';

  @override
  String get releaseOneHeldSlotMessage =>
      'The slot held for this booking goes back on sale. Your selection is kept.';

  @override
  String get keepReviewing => 'Keep reviewing';

  @override
  String get releaseAndClose => 'Release & close';

  @override
  String get removeAll => 'Remove all';

  @override
  String get manualBookingSentence => 'Manual booking';

  @override
  String get customerAndPayment => 'Customer & payment';

  @override
  String get reviewBooking => 'Review booking';

  @override
  String get pickFreeSlotsOnBoard => 'Pick free slots on the board';

  @override
  String get closePanel => 'Close panel';

  @override
  String get bookForToday => 'Book for today';

  @override
  String get customerName => 'Customer name';

  @override
  String get enterCustomerName => 'Enter the customer\'s name';

  @override
  String get enterCustomerPhone => 'Enter the customer\'s phone number';

  @override
  String get enterValidPhoneNumber => 'Enter a valid phone number';

  @override
  String get amountReceivedNpr => 'Amount received (NPR)';

  @override
  String get enterAmountOrRemovePayment =>
      'Enter an amount, or remove this payment';

  @override
  String get addPaymentRemark => 'Add a payment remark';

  @override
  String get subtotalEstimateFrom => 'Subtotal (estimate, from)';

  @override
  String get subtotalEstimate => 'Subtotal (estimate)';

  @override
  String get received => 'Received';

  @override
  String get remaining => 'Remaining';

  @override
  String get finalPricesFromServerFootnote =>
      'Final prices come from the server when the slots are held on the next step.';

  @override
  String nothingWasBookedReason(String message) {
    return '$message Nothing was booked.';
  }

  @override
  String slotConflictNothingBooked(
    String court,
    String start,
    String end,
    String message,
  ) {
    return '$court, $start–$end: $message Nothing was booked.';
  }

  @override
  String receivedMoreThanPayable(String received, String payable) {
    return 'Received ($received) is more than the payable total ($payable).';
  }

  @override
  String nothingBookedSlotsStillHeld(String reason) {
    return 'Nothing was booked: $reason The slots are still held — confirm again to retry.';
  }

  @override
  String get nothingBookedSlotsStillHeldNoReason =>
      'Nothing was booked. The slots are still held — confirm again to retry.';

  @override
  String releaseHeldSlotsMessage(int count) {
    return 'The $count slots held for this booking go back on sale. Your selection is kept.';
  }

  @override
  String removeAllSlotsTitle(int count) {
    return 'Remove all $count slots?';
  }

  @override
  String slotsAndCourtsCount(int slots, int courts) {
    String _temp0 = intl.Intl.pluralLogic(
      slots,
      locale: localeName,
      other: '$slots slots',
      one: '$slots slot',
    );
    String _temp1 = intl.Intl.pluralLogic(
      courts,
      locale: localeName,
      other: '$courts courts',
      one: '$courts court',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String methodReceivedNpr(String method) {
    return '$method received (NPR)';
  }

  @override
  String moreThanTheTotal(String total) {
    return 'More than the total ($total)';
  }

  @override
  String addPaymentMethod(String method) {
    return 'Add $method';
  }

  @override
  String get existingCandidates => 'Existing candidates';

  @override
  String get hideCandidates => 'Hide candidates';

  @override
  String get noMatchingCandidate =>
      'No matching candidate. Continue with these details to create a new customer.';

  @override
  String get loadMoreCandidates => 'Load more candidates';

  @override
  String get unnamedCustomer => 'Unnamed customer';

  @override
  String get reviewedRevisedPrices =>
      'The server priced some slots differently from the board. I have reviewed the revised prices.';

  @override
  String get payable => 'Payable';

  @override
  String get receivedNow => 'Received now';

  @override
  String get remainingBalance => 'Remaining balance';

  @override
  String get manualSourceFootnote =>
      'Source: Manual / Vendor. Discounts and fees are applied by the server where configured.';

  @override
  String paymentMethodLine(String methods) {
    return 'Payment method · $methods';
  }

  @override
  String paymentStatusLine(String status) {
    return 'Payment status · $status';
  }

  @override
  String bookingStatusLine(String status) {
    return 'Booking status · $status';
  }

  @override
  String receivedNowBy(String method) {
    return 'Received now ($method)';
  }

  @override
  String bookedFor(String name) {
    return 'Booked for $name';
  }

  @override
  String bookingsFor(int count, String name) {
    return '$count bookings for $name';
  }

  @override
  String paymentPendingToCollect(String amount) {
    return 'Payment pending · $amount to collect';
  }

  @override
  String paidInFullBy(String methods) {
    return 'Paid in full · $methods';
  }

  @override
  String paidAndToCollect(String paid, String due) {
    return '$paid paid · $due to collect';
  }

  @override
  String get continueText => 'Continue';

  @override
  String get holdSlotsAndReview => 'Hold slots & review';

  @override
  String get confirmBookingSentence => 'Confirm booking';

  @override
  String get newBooking => 'New booking';

  @override
  String get clearAllSentence => 'Clear all';

  @override
  String get tapFreeSlotsOnBoard => 'Tap free slots on the board';

  @override
  String get pickAnyMixOfSlots =>
      'Pick any mix of courts, venues and times. Separate times stay separate — the gap is never booked.';

  @override
  String get pricedOnHold => 'Priced on hold';

  @override
  String get holdExpired =>
      'Hold expired — confirming will recheck availability.';

  @override
  String maybeFromPrice(String amount, String isFrom) {
    String _temp0 = intl.Intl.selectLogic(isFrom, {
      'true': 'from $amount',
      'other': '$amount',
    });
    return '$_temp0';
  }

  @override
  String selectionFooterSummary(int count, String hours, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slots',
      one: '$count slot',
    );
    return '$_temp0 · $hours court-h · $price';
  }

  @override
  String removeSlotAt(String time) {
    return 'Remove $time';
  }

  @override
  String ticketRangeLine(
    String date,
    String start,
    String end,
    String duration,
    int count,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slots',
      one: '$count slot',
    );
    return '$date · $start – $end ($duration, $_temp0)';
  }

  @override
  String bookingNumber(String id) {
    return 'Booking #$id';
  }

  @override
  String wasPrice(String amount) {
    return 'was $amount';
  }

  @override
  String slotsHeldFor(String minutes, String seconds) {
    return 'Slots held for $minutes:$seconds';
  }

  @override
  String slotsCountWithTotal(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slots',
      one: '$count slot',
    );
    return '$_temp0 · $total';
  }

  @override
  String get removeThisPayment => 'Remove this payment';

  @override
  String paidBy(String method) {
    return 'Paid by $method';
  }

  @override
  String stepOfThree(String step, String label) {
    return 'Step $step of 3, $label';
  }

  @override
  String get floodlights => 'Floodlights';

  @override
  String get parking => 'Parking';

  @override
  String get changingRoom => 'Changing Room';

  @override
  String get shower => 'Shower';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get firstAid => 'First Aid';

  @override
  String get liveScoreboard => 'Live Scoreboard';

  @override
  String get warmUpZone => 'Warm-Up Zone';

  @override
  String get cafeteria => 'Cafeteria';

  @override
  String get spectatorSeating => 'Spectator Seating';

  @override
  String get equipmentRental => 'Equipment Rental';

  @override
  String get lockerStorage => 'Locker Storage';

  @override
  String get goalNets => 'Goal Nets';

  @override
  String get scoreboard => 'Scoreboard';

  @override
  String get ballStand => 'Ball Stand';

  @override
  String get benches => 'Benches';

  @override
  String get drinkingWater => 'Drinking Water';

  @override
  String get lighting => 'Lighting';

  @override
  String get indoor => 'Indoor';

  @override
  String get roofed => 'Roofed';

  @override
  String get changingArea => 'Changing Area';

  @override
  String get washroomAccess => 'Washroom Access';

  @override
  String get parkingAccess => 'Parking Access';

  @override
  String get spectatorZone => 'Spectator Zone';

  @override
  String get outdoor => 'Outdoor';

  @override
  String get vendorOnboardingComplete => 'Vendor onboarding is complete.';

  @override
  String get draftSaveFailedTryAgain => 'Draft save failed. Try again.';

  @override
  String get finish => 'Finish';

  @override
  String get selectValidStartAndEndTime => 'Select a valid start and end time.';

  @override
  String get startAndEndTimeCannotBeSame =>
      'Start and end time cannot be the same.';

  @override
  String get anotherSlot => 'another slot';

  @override
  String get timeSlotAlreadyExistsOnSelectedDays =>
      'This time slot already exists on the selected day(s).';

  @override
  String timeOverlapsWithOnSelectedDays(String name) {
    return 'This time overlaps with $name on the selected day(s).';
  }

  @override
  String get provideFutsalName => 'Please provide the name of your futsal.';

  @override
  String get uniqueSlugRequired =>
      'A unique slug is required for your futsal profile.';

  @override
  String get slugInvalidCharacters =>
      'The slug may only contain lowercase letters, numbers, and hyphens.';

  @override
  String get enterValidContactPhone =>
      'Please enter a valid contact phone number.';

  @override
  String get enterValidContactEmail =>
      'Please enter a valid contact email address.';

  @override
  String get provideValidWebsiteOrSocialLink =>
      'Please provide a valid website or social media link (including http/https).';

  @override
  String get provideFutsalDescription =>
      'Please provide a description for your futsal.';

  @override
  String get enterCompleteFutsalAddress =>
      'Please enter the complete address of your futsal.';

  @override
  String get specifyFutsalExactLocation =>
      'Please specify the exact location of your futsal.';

  @override
  String get provideLongitudeAndLatitude =>
      'Please provide both longitude and latitude coordinates.';

  @override
  String get selectAtLeastOneFutsalAmenityOrFeature =>
      'Please select at least one amenity or feature for your futsal.';

  @override
  String get specifyCancellationPolicy =>
      'Please specify your cancellation policy.';

  @override
  String get provideFutsalRules => 'Please provide the rules for your futsal.';

  @override
  String get specifyCommissionPercentage =>
      'Please specify the commission percentage.';

  @override
  String get uploadFutsalCoverImage =>
      'Please upload a cover image for your futsal.';

  @override
  String get uploadAtLeastOneGalleryImage =>
      'Please upload at least one image to the futsal gallery.';

  @override
  String get uploadRequiredCompanyDocuments =>
      'Please upload the required company documents before proceeding.';

  @override
  String get enterCourtName => 'Enter the court name.';

  @override
  String get enterCourtBasePrice => 'Enter the court base price.';

  @override
  String get selectCourtType => 'Select the court type.';

  @override
  String get enterCourtDescription => 'Enter the court description.';

  @override
  String get uploadAtLeastOneCourtPhoto =>
      'Upload at least one photo or memory for the court.';

  @override
  String get selectAdvancePaymentType => 'Select an advance payment type.';

  @override
  String get enterAdvancePaymentAmount => 'Enter the advance payment amount.';

  @override
  String advanceMustBeAtLeastPercent(String percent) {
    return 'The advance must be at least $percent%.';
  }

  @override
  String get percentageCannotExceed100 => 'Percentage cannot exceed 100.';

  @override
  String get flatAmountCannotExceedBasePrice =>
      'Flat amount cannot exceed the base price.';

  @override
  String advanceMustBeAtLeastPercentOfBasePrice(
    String percent,
    String minimum,
  ) {
    return 'The advance must be at least $percent% of the base price ($minimum).';
  }

  @override
  String get uploadAdvancePaymentQr =>
      'Upload the QR used for advance payment.';

  @override
  String get selectAtLeastOneCourtAmenity =>
      'Select at least one court amenity.';

  @override
  String get selectAtLeastOneCourtFacility =>
      'Select at least one court facility.';

  @override
  String get addAtLeastOneSlotForCourt =>
      'Add at least one slot for this court.';

  @override
  String get completeDayAndTimeForAllSlots =>
      'Complete day and time details for all slots.';

  @override
  String get resolveOverlappingSlots =>
      'Resolve overlapping slots before continuing.';

  @override
  String get thisSlot => 'this slot';

  @override
  String saveLabelBeforeContinuing(String label) {
    return 'Save $label before continuing.';
  }

  @override
  String get createFutsalVenueFirst =>
      'Create your futsal venue first — courts are added to a saved venue.';

  @override
  String get finishFutsalStepsBeforeCourts =>
      'Finish every futsal step before setting up courts.';

  @override
  String get next => 'Next';

  @override
  String get continueToCourts => 'Continue to Courts';

  @override
  String get reviewAndPublishTitle => 'Review & Publish';

  @override
  String get addCourtBeforeOpeningCourtSteps =>
      'Add a court before opening court steps.';

  @override
  String get addCourtBeforeOpeningCourtSubsteps =>
      'Add a court before opening court substeps.';

  @override
  String get addAtLeastOneCourtBeforeContinuing =>
      'Add at least one court before continuing.';

  @override
  String defaultCourtName(int number) {
    return 'Court $number';
  }

  @override
  String defaultSlotLabel(int number) {
    return 'Slot $number';
  }

  @override
  String get saveCourtBeforeManagingSlots =>
      'Save the court before managing slots.';

  @override
  String get saveSlotBeforeSettingPrices =>
      'Save the slot before setting prices.';

  @override
  String get waitForCurrentSaveToFinish =>
      'Please wait for the current save to finish.';

  @override
  String get addAtLeastOneCourtBeforePublishing =>
      'Add at least one court before publishing.';

  @override
  String get addAtLeastOneCourtBeforeFinishing =>
      'Add at least one court before finishing.';

  @override
  String get aCourt => 'A court';

  @override
  String courtNotSetUpYet(String name) {
    return '$name is not set up yet. Complete it before finishing.';
  }

  @override
  String get completeAndSaveFutsalBeforeAddingCourts =>
      'Complete and save the futsal venue before adding courts.';

  @override
  String get mediaLibrary => 'Media Library';

  @override
  String get selectSavedMediaOrAddNewFiles =>
      'Select saved media or add new files for this section.';

  @override
  String removeFromSavedCollectionPrompt(String name) {
    return 'Do you want to remove \"$name\" from your saved collection?';
  }

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get useSelectedItems => 'Use Selected Items';

  @override
  String get useSelectedItem => 'Use Selected Item';

  @override
  String get noMediaSelected => 'No media selected';

  @override
  String itemsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items selected',
      one: '$count item selected',
    );
    return '$_temp0';
  }

  @override
  String get images => 'Images';

  @override
  String get files => 'Files';

  @override
  String tapToAttachFilesForSection(String actionLabel) {
    return 'Tap $actionLabel to attach files for this section.';
  }

  @override
  String get locked => 'Locked';

  @override
  String get notStarted => 'Not Started';

  @override
  String get inProgressTitle => 'In Progress';

  @override
  String get needsAttention => 'Needs Attention';

  @override
  String get sessionState => 'Session state';

  @override
  String get readyInSession => 'Ready in session';

  @override
  String get savingDraft => 'Saving draft...';

  @override
  String get draftSaved => 'Draft saved';

  @override
  String savedAt(String time) {
    return 'Saved at $time';
  }

  @override
  String get draftSaveFailed => 'Draft save failed';

  @override
  String get sessionOnly => 'Session only';

  @override
  String get searchLocationHint => 'Search location...';

  @override
  String deleteCourtConfirmation(String courtName) {
    return 'Are you sure you want to delete \"$courtName\"? This action cannot be undone.';
  }

  @override
  String courtDeletedSuccessfully(String courtName) {
    return '\"$courtName\" deleted successfully.';
  }

  @override
  String get unnamedCourt => 'Unnamed Court';

  @override
  String slotCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slots',
      one: '$count slot',
    );
    return '$_temp0';
  }

  @override
  String get saveChangesAndExit => 'Save changes & exit?';

  @override
  String get courtSetupProgressSavedBeforeHome =>
      'Your current court setup progress will be saved before returning home.';

  @override
  String get saveAndGoHome => 'Save & go home';

  @override
  String get stayHere => 'Stay here';

  @override
  String get enterCourtNameHelper =>
      'Enter a name for the court. You can change it later. \nMake sure to use a proper standard name for the court.';

  @override
  String stepNumber(int section, int substep) {
    return 'Step $section.$substep';
  }

  @override
  String get enterFirstCourtNameHelper =>
      'Enter a name for your first court. You can change it later.\nMake sure to use a proper standard name for the court.';

  @override
  String get courtSetupSentenceCase => 'Court setup';

  @override
  String get futsalSetup => 'Futsal setup';

  @override
  String get courtDetailsAndBookingSetup => 'Court details and booking setup';

  @override
  String get businessProfileAndLocation => 'Business profile and location';

  @override
  String futsalStatusLabel(String status) {
    return 'Futsal $status';
  }

  @override
  String courtCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courts',
      one: '$count court',
    );
    return '$_temp0';
  }

  @override
  String get onboardingProgressSavedBeforeHome =>
      'Your current onboarding progress will be saved before returning home.';

  @override
  String get loadingCourtTypes => 'Loading court types...';

  @override
  String get loadingMatchFormats => 'Loading match formats...';

  @override
  String get basicPlanDescriptionHtml =>
      '<ul><li>Basic listing</li><li>Standard visibility</li><li>Email support</li></ul>';

  @override
  String get standardPlanDescriptionHtml =>
      '<ul><li>Priority support</li><li>Featured listing</li><li>Activity logs</li><li>Detailed reports</li></ul>';

  @override
  String planPercentLabel(int percent) {
    return 'Plan $percent%';
  }

  @override
  String get defaultPackageDescriptionHtml =>
      '<p>Platform support based on selected package</p>';

  @override
  String get playerFacingFacilitiesAtCourt =>
      'Player-facing facilities available at this court.';

  @override
  String get courtSpecificServicesAndEquipment =>
      'Court-specific services and equipment.';

  @override
  String get noFacilitiesAvailableRightNow =>
      'No facilities available right now. Please try again later.';

  @override
  String get noAmenitiesAvailableRightNow =>
      'No amenities available right now. Please try again later.';

  @override
  String selectedOfTotal(int selected, int total) {
    return '$selected/$total selected';
  }

  @override
  String get addNew => 'Add new';

  @override
  String get addPaymentQrs => 'Add payment QRs';

  @override
  String get youCanAddOneMoreQr => 'You can add 1 more QR.';

  @override
  String youCanAddUpToMoreQrs(int remaining) {
    return 'You can add up to $remaining more QRs.';
  }

  @override
  String courtQrLimitReached(int max, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining were',
      one: '$remaining was',
    );
    return 'A court can have $max QRs. Only the first $_temp0 added.';
  }

  @override
  String get enterTheAdvanceAmount => 'Enter the advance amount.';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than zero.';

  @override
  String flatAmountCannotExceedBasePriceOf(String base) {
    return 'Flat amount cannot exceed the base price ($base).';
  }

  @override
  String minimumPercentUpTo100(String percent) {
    return 'Minimum $percent%, up to 100%';
  }

  @override
  String get enterFlatAdvanceAmount => 'Enter the flat advance amount';

  @override
  String fromAmountToAmount(String from, String to) {
    return 'From $from to $to';
  }

  @override
  String get enterAdvanceAmount => 'Enter the advance amount';

  @override
  String everyCourtCollectsAdvance(String percent) {
    return 'Every court collects an advance of at least $percent% before a booking is confirmed.';
  }

  @override
  String get advancePercentageLabel => 'Advance percentage (%)';

  @override
  String get advanceAmount => 'Advance amount';

  @override
  String get removeQr => 'Remove QR';

  @override
  String get removePaymentQrPrompt => 'Remove this payment QR from the court?';

  @override
  String get addQrForEachWalletOrBank =>
      'Add a QR for each wallet or bank you accept. Players can pay through any of them.';

  @override
  String qrNumber(int number) {
    return 'QR $number';
  }

  @override
  String tapToViewLabel(String label) {
    return '$label, tap to view';
  }

  @override
  String get uploadQr => 'Upload QR';

  @override
  String get addQr => 'Add QR';

  @override
  String get noBookingDays => 'No booking days';

  @override
  String get enterSlotLabel => 'Enter a slot label.';

  @override
  String get selectAtLeastOneBookingDay => 'Select at least one booking day.';

  @override
  String get selectBothStartAndEndTime => 'Select both start and end time.';

  @override
  String get editSlot => 'Edit Slot';

  @override
  String get bookingDays => 'Booking days';

  @override
  String get updateSlot => 'Update Slot';

  @override
  String get untitledSlot => 'Untitled slot';

  @override
  String get timeNotSet => 'Time not set';

  @override
  String get everyDay => 'Every day';

  @override
  String get addHoliday => 'Add Holiday';

  @override
  String get addClosedDate => 'Add Closed Date';

  @override
  String basePriceLabel(String price) {
    return 'Base $price';
  }

  @override
  String weekendPriceLabel(String price) {
    return 'Weekend $price';
  }

  @override
  String holidayPriceLabel(String price) {
    return 'Holiday $price';
  }

  @override
  String discountPriceLabel(String price) {
    return 'Discount $price';
  }

  @override
  String customDatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count custom dates',
      one: '$count custom date',
    );
    return '$_temp0';
  }

  @override
  String get noSpecialPricingSet => 'No special pricing set';

  @override
  String get discountPercentLabel => 'Discount %';

  @override
  String get discountPrice => 'Discount price';

  @override
  String get closureType => 'Closure type';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodYear => 'Year';

  @override
  String get periodCustom => 'Custom';

  @override
  String get bookingStatuses => 'Booking statuses';

  @override
  String get revenueTrend => 'Revenue trend';

  @override
  String get bookingOverviewTitle => 'Booking overview';

  @override
  String get snapshot => 'Snapshot';

  @override
  String get netEarnings => 'Net earnings';

  @override
  String get performanceByVenue => 'Performance by venue';

  @override
  String get topCourts => 'Top courts';

  @override
  String get topCustomers => 'Top customers';

  @override
  String get bookedHours => 'Booked hours';

  @override
  String get bookedHrs => 'Booked hrs';

  @override
  String get noVenueActivityInPeriod => 'No venue activity in this period.';

  @override
  String get twelveAm => '12 AM';

  @override
  String get elevenPm => '11 PM';

  @override
  String get overheadsAndProcessing => 'Overheads + processing';

  @override
  String get acrossAllPaidSlots => 'Across all paid slots';

  @override
  String get ofAvailableCourtHours => 'Of available court hours';

  @override
  String avgNpr(String amount) {
    return 'Avg NPR $amount';
  }

  @override
  String avgPerBooking(String amount) {
    return 'Avg $amount / booking';
  }

  @override
  String bookingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookings',
      one: '$count booking',
    );
    return '$_temp0';
  }

  @override
  String rowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows',
      one: '$count row',
    );
    return '$_temp0';
  }

  @override
  String daysShort(int days) {
    return '${days}d';
  }

  @override
  String totalBookingsCount(int total) {
    return '$total total bookings';
  }

  @override
  String vsPreviousPeriod(String amount) {
    return 'vs $amount previous period';
  }

  @override
  String paidCount(int count) {
    return '$count paid';
  }

  @override
  String percentOfBookings(String percent) {
    return '$percent% of bookings';
  }

  @override
  String get allDates => 'All dates';

  @override
  String get dateModeDay => 'Day';

  @override
  String get dateModeRange => 'Range';

  @override
  String get noInternetCheckNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get somethingWentWrongLoadingBookings =>
      'Something went wrong while loading bookings. Please try again.';

  @override
  String get couldNotLoadAccountForBookings =>
      'We could not load your account details, so your bookings cannot be shown.';

  @override
  String get accountRoleMissingForBookings =>
      'Your account role is missing, so we cannot tell which bookings to show.';

  @override
  String get searchVenueCourtOrBookingId => 'Search venue, court or booking ID';

  @override
  String get searchCourtPlayerOrBookingId =>
      'Search court, player or booking ID';

  @override
  String get failedToLoadBookings => 'Failed to load bookings.';

  @override
  String get failedToLoadFutsalBookings => 'Failed to load futsal bookings.';

  @override
  String get failedToLoadRecentBookings => 'Failed to load recent bookings.';

  @override
  String get noMatchingBookings => 'No matching bookings';

  @override
  String get noBookingsYet => 'No bookings yet';

  @override
  String get noFutsalBookingsYet => 'No futsal bookings yet';

  @override
  String get upcomingCourtBookingsAppearHere =>
      'Your upcoming court bookings will appear here.';

  @override
  String get venueBookingsAppearHere =>
      'Bookings made at your venues will appear here.';

  @override
  String get tryDifferentSearchOrDateRange =>
      'Try a different search or date range.';

  @override
  String get couldNotLoadMoreRetry => 'Could not load more. Retry';

  @override
  String get loadMoreBookings => 'Load more bookings';

  @override
  String get products => 'Products';

  @override
  String get addProducts => 'Add products';

  @override
  String get recurring => 'Recurring';

  @override
  String get unknown => 'Unknown';

  @override
  String get monthShortJan => 'Jan';

  @override
  String get monthShortFeb => 'Feb';

  @override
  String get monthShortMar => 'Mar';

  @override
  String get monthShortApr => 'Apr';

  @override
  String get monthShortMay => 'May';

  @override
  String get monthShortJun => 'Jun';

  @override
  String get monthShortJul => 'Jul';

  @override
  String get monthShortAug => 'Aug';

  @override
  String get monthShortSep => 'Sep';

  @override
  String get monthShortOct => 'Oct';

  @override
  String get monthShortNov => 'Nov';

  @override
  String get monthShortDec => 'Dec';

  @override
  String get editDateFilter => 'Edit date filter';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get oldestFirst => 'Oldest first';

  @override
  String get everyBookingShownWhateverDate =>
      'Every booking is shown, whatever its date.';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get any => 'Any';

  @override
  String get ratingPoor => 'Poor';

  @override
  String get ratingFair => 'Fair';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingGreat => 'Great';

  @override
  String get ratingExcellent => 'Excellent';

  @override
  String get howWasYourGame => 'How was your game?';

  @override
  String get ratingHelpsOtherPlayers =>
      'Your rating helps other players choose a venue.';

  @override
  String get pickStarRatingFirst => 'Pick a star rating first.';

  @override
  String get yourReview => 'Your review';

  @override
  String get reviewHint => 'Court condition, facilities, how it all went…';

  @override
  String get writeAFewWordsAboutVenue => 'Write a few words about the venue.';

  @override
  String get aLittleMoreDetailPlease => 'A little more detail, please.';

  @override
  String get submitReview => 'Submit review';

  @override
  String get youReviewedThisBooking => 'You reviewed this booking';

  @override
  String get checkingYourReview => 'Checking your review…';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes m';
  }

  @override
  String hoursShortHr(int hours) {
    return '$hours hr';
  }

  @override
  String timeAgo(String value) {
    return '$value ago';
  }

  @override
  String timeIn(String value) {
    return 'in $value';
  }

  @override
  String fromDateLabel(String date) {
    return 'From $date';
  }

  @override
  String untilDateLabel(String date) {
    return 'Until $date';
  }

  @override
  String noStatusBookingsMatch(String status) {
    return 'No $status bookings match your search or date range.';
  }

  @override
  String youHaveNoStatusBookings(String status) {
    return 'You have no $status bookings.';
  }

  @override
  String typedBooking(String type) {
    return '$type booking';
  }

  @override
  String reviewStatus(String status) {
    return 'Review $status';
  }

  @override
  String refNumber(String ref) {
    return 'Ref #$ref';
  }

  @override
  String get paidAtCounter => 'Paid at counter';

  @override
  String get couldNotReadCandidatesFromServer =>
      'Could not read candidates from the server.';

  @override
  String get enterAmountLikeExample => 'Enter an amount like 1200 or 1200.50.';

  @override
  String get enterAmountGreaterThanZero => 'Enter an amount greater than zero.';

  @override
  String get manualBookingAndAdjustments => 'Manual booking & adjustments';

  @override
  String get noVenuesToBookYet => 'No venues to book yet';

  @override
  String get noVenuesToBookYetMessage =>
      'Once a venue with courts is approved, you can take walk-in bookings for it here.';

  @override
  String get chooseWhereBookingWillBeCreated =>
      'Choose where this booking will be created.';

  @override
  String get selectAVenueDot => 'Select a venue.';

  @override
  String get customerDetails => 'Customer details';

  @override
  String get walkInCustomerContactInfo =>
      'Contact information for the walk-in customer.';

  @override
  String get enterCustomerPhoneNumber => 'Enter the customer\'s phone number';

  @override
  String get bookingDetailsSentenceCase => 'Booking details';

  @override
  String get setInitialPaymentAndBookingStatus =>
      'Set the initial payment and booking status.';

  @override
  String get totalAmountNpr => 'Total amount (NPR)';

  @override
  String get leaveBlankToUseSlotPrices => 'Leave blank to use slot prices';

  @override
  String get enterBookingDetails => 'Enter booking details';

  @override
  String get nextSelectDateAndTimeSlot =>
      'Next, select an available date and time slot.';

  @override
  String get noExistingCandidateFound =>
      'No existing candidate found. This booking will use the new customer details.';

  @override
  String get continueToSlotSelection => 'Continue to slot selection';

  @override
  String get dueAmountCollectedSuccessfully =>
      'Due amount collected successfully.';

  @override
  String get couldNotCollectDueAmount => 'Could not collect the due amount.';

  @override
  String get vendorInfoUnavailableForMessaging =>
      'Vendor information is unavailable for messaging.';

  @override
  String get customerInfoUnavailableForMessaging =>
      'Customer information is unavailable for messaging.';

  @override
  String get thanksForReviewingBooking => 'Thanks for reviewing this booking.';

  @override
  String get couldNotLoadLatestBookingDetails =>
      'Could not load the latest booking details.';

  @override
  String get bookingInformation => 'Booking information';

  @override
  String get paymentSummary => 'Payment summary';

  @override
  String get toCollect => 'To collect';

  @override
  String get dueAmount => 'Due amount';

  @override
  String get collectDue => 'Collect due';

  @override
  String get unknownCustomer => 'Unknown customer';

  @override
  String get bookingTotal => 'Booking total';

  @override
  String get grandTotal => 'Grand total';

  @override
  String get includesProductsSold => 'Includes products sold';

  @override
  String get payments => 'Payments';

  @override
  String get submittedPaymentScreenshot => 'Submitted payment screenshot';

  @override
  String get noPaymentScreenshot => 'No payment screenshot';

  @override
  String get screenshotUnavailable => 'Screenshot unavailable';

  @override
  String get noScreenshotWasSubmitted => 'No screenshot was submitted';

  @override
  String discountWithCode(String code) {
    return 'Discount ($code)';
  }

  @override
  String productsItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return 'Products ($_temp0)';
  }

  @override
  String paymentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '$count payment',
    );
    return '$_temp0';
  }

  @override
  String recurrenceSeriesBooking(String recurrence) {
    return '$recurrence · Series booking';
  }

  @override
  String get productsSubtotal => 'Products subtotal';

  @override
  String get product => 'Product';

  @override
  String get addMoreProducts => 'Add more products';

  @override
  String get productsAddedToBooking => 'Products added to the booking.';

  @override
  String get couldNotAddProductsTryAgain =>
      'Could not add products. Please try again.';

  @override
  String get couldNotLoadProducts => 'Could not load products';

  @override
  String get noProductsAvailable => 'No products available';

  @override
  String get venueHasNoActiveProducts =>
      'This venue has no active products to sell yet.';

  @override
  String get sellAddOnsForBooking =>
      'Sell water, drinks & add-ons for this booking.';

  @override
  String get collectedRemainingDueInPerson =>
      'Collected remaining due amount in person';

  @override
  String get collectDueAmount => 'Collect due amount';

  @override
  String get amount => 'Amount';

  @override
  String get enterCollectedAmount => 'Enter collected amount';

  @override
  String get howWasDueAmountCollected => 'How was the due amount collected?';

  @override
  String get completeBooking => 'Complete booking';

  @override
  String get completeBookingDescription =>
      'Review the payment and record how it was collected. This can\'t be undone.';

  @override
  String get discountAmount => 'Discount amount';

  @override
  String get discountAmountHint => 'e.g. 100';

  @override
  String get amountReceivedNowNpr => 'Amount received now (NPR)';

  @override
  String get enterAmountForEachPayment =>
      'Enter an amount for each payment, or remove it.';

  @override
  String get collectingNow => 'Collecting now';

  @override
  String get payableAfterDiscount => 'Payable after discount';

  @override
  String get remainingDue => 'Remaining due';

  @override
  String get bookingPayment => 'Booking payment';

  @override
  String get alreadyPaid => 'Already paid';

  @override
  String get extraItems => 'Extra items';

  @override
  String get noExtraItemsOnBooking => 'No extra items on this booking.';

  @override
  String get extraItemsTotal => 'Extra items total';

  @override
  String get totalToCollect => 'Total to collect';

  @override
  String get add => 'Add';

  @override
  String qtyCount(int quantity) {
    return 'Qty $quantity';
  }

  @override
  String productNumber(Object id) {
    return 'Product #$id';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String addToBookingCount(int count) {
    return 'Add to booking ($count)';
  }

  @override
  String amountCannotExceed(String amount) {
    return 'Amount cannot exceed $amount';
  }

  @override
  String remainsDueForCompletedBooking(String amount) {
    return '$amount remains due for this completed booking.';
  }

  @override
  String collectAmount(String amount) {
    return 'Collect $amount';
  }

  @override
  String typeReceivedNpr(String type) {
    return '$type received (NPR)';
  }

  @override
  String addPaymentType(String type) {
    return 'Add $type';
  }

  @override
  String moreThanAmountDue(String amount) {
    return 'More than the amount due ($amount).';
  }

  @override
  String get aYearAgo => 'a year ago';

  @override
  String yearsAgo(int years) {
    return '$years years ago';
  }

  @override
  String get aMonthAgo => 'a month ago';

  @override
  String monthsAgo(int months) {
    return '$months months ago';
  }

  @override
  String get relativeYesterday => 'yesterday';

  @override
  String get anHourAgo => 'an hour ago';

  @override
  String get relativeJustNow => 'just now';

  @override
  String get twoWeeks => '2 Weeks';

  @override
  String get oneMonth => '1 Month';

  @override
  String get twoMonths => '2 Months';

  @override
  String get threeMonths => '3 Months';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get couldNotLoadVenueCourts =>
      'Could not load venue courts. Please try again.';

  @override
  String get couldNotParseCourtSlotsFromServer =>
      'Could not parse court slots from server.';

  @override
  String get couldNotCreateCourtSlot => 'Could not create the court slot.';

  @override
  String get couldNotSaveCourtSlot => 'Could not save the court slot.';

  @override
  String get couldNotDeleteCourtSlot => 'Could not delete the court slot.';

  @override
  String get notSpecified => 'Not specified';

  @override
  String playersCountTitle(int count) {
    return '$count Players';
  }

  @override
  String checkOutVenueOnHamroFutsal(String name) {
    return 'Check out $name on Hamro Futsal.';
  }

  @override
  String startingFrom(String price) {
    return 'Starting from $price';
  }

  @override
  String distanceInMeters(Object meters) {
    return '$meters m';
  }

  @override
  String distanceInKm(Object km) {
    return '$km km';
  }

  @override
  String get thatIsEveryReview => 'That is every review.';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get playHereAndBeFirstToReview =>
      'Play here and be the first to leave one.';

  @override
  String get choosePreferredTime => 'Choose Preferred Time';

  @override
  String fromPrice(String price) {
    return 'from $price';
  }

  @override
  String sessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String saveAmountSuffix(String amount) {
    return ' · save $amount';
  }

  @override
  String get oneReview => '1 review';

  @override
  String reviewsCount(int count) {
    return '$count reviews';
  }

  @override
  String get anonymous => 'Anonymous';

  @override
  String viewAllCount(int count) {
    return 'View all ($count)';
  }

  @override
  String everyWeekdaysSameTime(String weekdays) {
    return 'Every $weekdays · same time';
  }

  @override
  String get repeatWeeklyOnTheDaysYouChoose =>
      'Repeat weekly on the days you choose';

  @override
  String sessionsDateRange(int count, String first, String last) {
    return '$count sessions · $first → $last';
  }

  @override
  String get someDatesAreUnavailable => 'Some dates are unavailable';

  @override
  String availableUnavailableCount(int available, int unavailable) {
    return '$available available · $unavailable unavailable';
  }

  @override
  String allDatesAvailable(int count) {
    return 'All $count dates available';
  }

  @override
  String totalSessions(int count) {
    return 'Total · $count sessions';
  }

  @override
  String get unavailableDatesNotChargedSkipped =>
      'Unavailable dates are not charged and will be skipped.';

  @override
  String saveAmount(String amount) {
    return 'save $amount';
  }

  @override
  String totalLowercaseSessions(int count) {
    return 'total · $count sessions';
  }

  @override
  String get selectATimeSlotToContinue => 'Select a time slot to continue';

  @override
  String courtEveryWeekdaysAtTime(String court, String weekdays, String time) {
    return '$court · Every $weekdays · $time';
  }

  @override
  String get selectSlot => 'Select Slot';

  @override
  String get hamroFutsalPvtLtd => 'Hamro Futsal Pvt. Ltd.';

  @override
  String get paymentAmountNotReady =>
      'The payment amount is not ready yet. Please try again.';

  @override
  String receiptAcceptedForManualVerification(int score) {
    return 'Receipt accepted for manual verification (score: $score%).';
  }

  @override
  String get pleaseUploadYourPaymentProof =>
      'Please upload your payment proof.';

  @override
  String get pleaseAcceptTheBookingTerms => 'Please accept the booking terms.';

  @override
  String get onlineQrProofAttached => 'Online (QR) · proof attached';

  @override
  String get couldNotCreateBooking =>
      'Could not create booking. Please try again.';

  @override
  String get bookingSummary => 'Booking summary';

  @override
  String get applyCoupon => 'Apply coupon';

  @override
  String get priceDetails => 'Price details';

  @override
  String get confirmedByVenue => 'Confirmed by venue';

  @override
  String totalRsAmount(String amount) {
    return 'Total Rs $amount';
  }

  @override
  String get totalDash => 'Total —';

  @override
  String get confirmingEllipsis => 'Confirming…';

  @override
  String get starts => 'Starts';

  @override
  String upToPlayers(int count) {
    return 'Up to $count';
  }

  @override
  String weeklyRecurrenceSessions(String recurrence, int sessions) {
    return 'Weekly · $recurrence · $sessions sessions';
  }

  @override
  String appliedSavedRs(String amount) {
    return 'applied · saved Rs $amount';
  }

  @override
  String minusRsAmount(String amount) {
    return '- Rs $amount';
  }

  @override
  String get couldNotCalculateThePrice => 'Couldn\'t calculate the price';

  @override
  String get slotCouldNotBeHeldTryAgain =>
      'The slot could not be held. Please try again.';

  @override
  String get estimatedTotal => 'Estimated total';

  @override
  String get venueConfirmsFinalPriceAndAdvance =>
      'The venue confirms the final price and advance with your booking.';

  @override
  String get calculatingFinalPriceAndAdvance =>
      'Calculating the final price and advance…';

  @override
  String get oneSession => '1 session';

  @override
  String get checkingPaymentReceipt => 'Checking payment receipt…';

  @override
  String attachedWithSize(String size) {
    return 'Attached · $size';
  }

  @override
  String get payExactAmountNote =>
      'Please pay the exact amount shown for your booking.';

  @override
  String get uploadClearReceiptScreenshotNote =>
      'After completing the payment, upload a clear screenshot of the payment confirmation receipt.';

  @override
  String get incorrectPaymentMayBeCancelledNote =>
      'Bookings with an incorrect payment amount or unclear/invalid screenshot may be cancelled.';

  @override
  String bookingRequestSentDetails(
    String court,
    String time,
    String advance,
    String balance,
  ) {
    return '$court · $time\nWe will confirm once your advance of Rs $advance is verified. Balance Rs $balance payable later.';
  }

  @override
  String get bookingConfirmedSuccessfully => 'Booking confirmed successfully.';

  @override
  String get couldNotCheckAvailabilityForSelectedDates =>
      'Could not check availability for the selected dates.';

  @override
  String get couldNotLoadSlotsForThisDate =>
      'Could not load slots for this date.';

  @override
  String get forTheSelectedTime => 'For the selected time';

  @override
  String get allCourtsForThisDate => 'All courts for this date';

  @override
  String get noCourtsAvailableForDateAndTime =>
      'No courts are available for this date and time.';

  @override
  String get noCourtsAvailableForDate =>
      'No courts are available for this date.';

  @override
  String get noneOfTheseDatesAreAvailable =>
      'None of these dates are available. Please choose another date or time slot.';

  @override
  String showingNearestAvailability(String hasType, String fallbackType) {
    String _temp0 = intl.Intl.selectLogic(hasType, {
      'true': 'Showing the nearest availability we could find ($fallbackType).',
      'other': 'Showing the nearest availability we could find.',
    });
    return '$_temp0';
  }

  @override
  String get zeroCourts => '0 courts';

  @override
  String availableOfTotal(int available, int total) {
    return '$available of $total available';
  }

  @override
  String get oneOtherPersonViewingThisDate =>
      '1 other person viewing this date';

  @override
  String othersViewingThisDate(int count) {
    return '$count others viewing this date';
  }

  @override
  String get someSessionsAreUnavailable => 'Some sessions are unavailable';

  @override
  String get slotIsAvailable => 'Slot is available';

  @override
  String allSessionsAvailable(int total) {
    return 'All $total sessions available';
  }

  @override
  String get slotIsNotAvailable => 'Slot is not available';

  @override
  String noneOfTheSessionsAvailable(int total) {
    return 'None of the $total sessions are available';
  }

  @override
  String get sessionNoun => 'session';

  @override
  String sessionsUnavailableSummary(String taken, int available, int total) {
    return '$taken unavailable · $available of $total available';
  }

  @override
  String atTimeSuffix(String time) {
    return ' at $time';
  }

  @override
  String scheduleDatesAlreadyTaken(String at) {
    return 'One or more dates in this schedule are already taken$at. Please pick another date or time.';
  }

  @override
  String thisDateIsFree(String at) {
    return 'This date is free$at.';
  }

  @override
  String everyDateInScheduleIsFree(String at) {
    return 'Every date in this schedule is free$at.';
  }

  @override
  String thisSlotIsAlreadyTaken(String at) {
    return 'This slot is already taken$at. Please pick another date or time.';
  }

  @override
  String slotTakenOnEveryScheduleDate(String at) {
    return 'This slot is taken$at on every date in the schedule. Please pick another date or time.';
  }

  @override
  String sessionLabelIs(String label) {
    return '$label is';
  }

  @override
  String datesCountAre(int count) {
    return '$count dates are';
  }

  @override
  String get theOtherSession => 'the other session';

  @override
  String theOtherSessions(int count) {
    return 'the other $count sessions';
  }

  @override
  String get pronounIt => 'it';

  @override
  String get pronounThem => 'them';

  @override
  String alreadyTakenSkipAndBook(
    String which,
    String at,
    String them,
    String rest,
  ) {
    return '$which already taken$at. Skip $them and book $rest, or pick another date or time.';
  }

  @override
  String unavailableWithCount(int count) {
    return 'Unavailable · $count';
  }

  @override
  String availableWithCount(int count) {
    return 'Available · $count';
  }

  @override
  String plusMore(String label) {
    return '+ $label';
  }

  @override
  String get moreAvailableDateNoun => 'more available date';

  @override
  String get pickAnotherDate => 'Pick another date';

  @override
  String skipAndBook(int count) {
    return 'Skip & book $count';
  }

  @override
  String get oneDateIsUnavailable => '1 date is unavailable';

  @override
  String datesAreUnavailable(int count) {
    return '$count dates are unavailable';
  }

  @override
  String get continueWithoutTheseDates =>
      'Continue without these dates, or choose another date and slot.';

  @override
  String get continueWithOneDate => 'Continue with 1 date';

  @override
  String continueWithDates(int count) {
    return 'Continue with $count dates';
  }

  @override
  String get chooseAnotherDateAndSlot => 'Choose another date & slot';

  @override
  String get noLocationsFoundForThatSearch =>
      'No locations found for that search.';

  @override
  String get unableToSearchLocationsRightNow =>
      'Unable to search locations right now.';

  @override
  String searchingExactLocationFor(String lat, String lng) {
    return 'Searching exact location for $lat, $lng';
  }

  @override
  String pinnedLocation(String lat, String lng) {
    return 'Pinned location ($lat, $lng)';
  }

  @override
  String get searchPlaceOrTapMapForExactLocation =>
      'Search a place or tap on the map to capture the exact location.';

  @override
  String get locatingEllipsis => 'Locating...';

  @override
  String get useLocation => 'Use Location';

  @override
  String get selectedPackage => 'Selected package';

  @override
  String get tapToChoosePackage => 'Tap to choose package';

  @override
  String get createShop => 'Create Shop';

  @override
  String stepOfTotal(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String advanceRequiredOnEveryCourt(String percent) {
    return 'Required on every court — at least $percent% is collected before a booking is confirmed.';
  }

  @override
  String get disabled => 'Disabled';

  @override
  String nprAmount(String amount) {
    return 'NPR $amount';
  }

  @override
  String get cityFieldName => 'City';

  @override
  String get countryFieldName => 'Country';

  @override
  String get futsalNameFieldName => 'Futsal name';

  @override
  String get contactPhoneFieldName => 'Contact phone';

  @override
  String get contactEmailFieldName => 'Contact email';

  @override
  String get couldNotLoadMoreVenues => 'Could not load more venues.';

  @override
  String get startByAddingYourFirstVenue => 'Start by adding your first venue';

  @override
  String get everythingYouOwnAtAGlance => 'Everything you own, at a glance';

  @override
  String get live => 'Live';

  @override
  String get from => 'From';

  @override
  String get hide => 'Hide';

  @override
  String get show => 'Show';

  @override
  String get courtIsNowInactive => 'Court is now inactive.';

  @override
  String get courtIsNowActive => 'Court is now active.';

  @override
  String playersCountLowercase(int count) {
    return '$count players';
  }

  @override
  String get perHrSuffix => ' /hr';

  @override
  String get noAdvance => 'No advance';

  @override
  String get makeInactive => 'Make Inactive';

  @override
  String get makeActive => 'Make Active';

  @override
  String get noFutsalVenuesYet => 'No futsal venues yet';

  @override
  String get tryADifferentSearchOrFilter => 'Try a different search or filter.';

  @override
  String get createYourFirstVenueAndAddCourts =>
      'Create your first venue and add courts for online booking.';

  @override
  String get myFutsal => 'My Futsal';

  @override
  String confirmDeleteCourt(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get showerArea => 'Shower Area';

  @override
  String get firstAidDesk => 'First Aid Desk';

  @override
  String get starterPackagePrice => 'NPR 2,500 / month';

  @override
  String get growthPackagePrice => 'NPR 5,500 / month';

  @override
  String get elitePackagePrice => 'NPR 9,500 / month';

  @override
  String get oneVenueProfile => '1 venue profile';

  @override
  String get basicListingVisibility => 'Basic listing visibility';

  @override
  String get manualBookingConfirmation => 'Manual booking confirmation';

  @override
  String get priorityListingPlacement => 'Priority listing placement';

  @override
  String get bookingWorkflowSupport => 'Booking workflow support';

  @override
  String get basicReportingAccess => 'Basic reporting access';

  @override
  String get multiCourtManagement => 'Multi-court management';

  @override
  String get premiumBrandingPlacement => 'Premium branding placement';

  @override
  String get prioritySupportRouting => 'Priority support routing';

  @override
  String get advancePaymentOptional => 'Advance payment optional';

  @override
  String get cancellationAllowed => 'Cancellation allowed';

  @override
  String get cancellationNotAllowed => 'Cancellation not allowed';

  @override
  String get refundsSupported => 'Refunds supported';

  @override
  String get refundsNotSupported => 'Refunds not supported';

  @override
  String fieldIsRequired(String field) {
    return '$field is required';
  }

  @override
  String fieldMustBePositiveNumber(String field) {
    return '$field must be a positive number';
  }

  @override
  String get useLowercaseLettersNumbersHyphensOnly =>
      'Use lowercase letters, numbers, and hyphens only';

  @override
  String get enterAValidEmailAddress => 'Enter a valid email address';

  @override
  String get enterAValidPhoneNumber => 'Enter a valid phone number';

  @override
  String get establishedYearFieldName => 'Established year';

  @override
  String get enterAValidFourDigitYear => 'Enter a valid 4-digit year';

  @override
  String yearMustBeBetween1900And(String currentYear) {
    return 'Year must be between 1900 and $currentYear';
  }

  @override
  String get enterAValidWebsiteUrl => 'Enter a valid website URL';

  @override
  String get basicPriceFieldName => 'Basic price';

  @override
  String get enterAValidPriceAmount => 'Enter a valid price amount';

  @override
  String get bookingAdvanceDaysFieldName => 'Booking advance days';

  @override
  String get cancellationWindowFieldName => 'Cancellation window';

  @override
  String get exactLocationIsRequired => 'Exact location is required';

  @override
  String get selectExactLocationFromMap =>
      'Select the exact location from the map';

  @override
  String get enterAValidUrlHttps => 'Enter a valid URL (https://...)';

  @override
  String get houseRulesFieldName => 'House rules';

  @override
  String get selectAtLeastOneAmenityOrFacility =>
      'Select at least one amenity or facility.';

  @override
  String get chooseAPackageToContinue => 'Choose a package to continue.';

  @override
  String get couldNotReadTheSelectedFile => 'Could not read the selected file.';

  @override
  String get couldNotOpenMapsApplication =>
      'Could not open the maps application.';

  @override
  String get venueHasNotSharedMapCoordinates =>
      'This venue hasn\'t shared map coordinates yet.';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String hostingSince(String since) {
    return 'Hosting since $since';
  }

  @override
  String seeAllCount(String count) {
    return 'See All ($count)';
  }

  @override
  String get contactForHours => 'Contact for hours';

  @override
  String get aboutThisVenue => 'About this venue';

  @override
  String get readLess => 'Read less';

  @override
  String get readMore => 'Read more';

  @override
  String get otherCategory => 'Other';

  @override
  String get amenityCategoryFacility => 'Facility';

  @override
  String get amenityCategoryLighting => 'Lighting';

  @override
  String get amenityCategoryAccess => 'Access';

  @override
  String get amenityCategoryComfort => 'Comfort';

  @override
  String get amenityCategoryFood => 'Food';

  @override
  String get amenityCategorySafety => 'Safety';

  @override
  String get amenityCategoryConnectivity => 'Connectivity';

  @override
  String get couldNotParseFeedbackOptions =>
      'Could not parse feedback options from server.';

  @override
  String get couldNotParseFeedbackList =>
      'Could not parse feedback list from server.';

  @override
  String get couldNotParseFeedbackDetails =>
      'Could not parse feedback details from server.';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get biometricNotAvailableOnDevice =>
      'Face ID or fingerprint is not available on this device.';

  @override
  String get addReasonForDeletingAccount =>
      'Please add a reason for deleting your account.';

  @override
  String get myFeedback => 'My Feedback';

  @override
  String feedbackSubmissionsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count submissions · tap one to see its details and status',
      one: '$count submission · tap one to see its details and status',
    );
    return '$_temp0';
  }

  @override
  String get noFeedbackYet => 'No feedback yet';

  @override
  String get submittedFeedbackWillAppearHere =>
      'Your submitted feedback will appear here once you share it with us.';

  @override
  String get chooseFeedbackTypeAndCategoryFirst =>
      'Please choose a feedback type and category first.';

  @override
  String get rateYourExperienceBeforeSubmitting =>
      'Please rate your experience before submitting.';

  @override
  String get howWasYourExperience => 'How was your experience?';

  @override
  String get feedbackMessageHint =>
      'What worked well? What should we improve? The more detail, the better.';

  @override
  String get addAShortMessage => 'Please add a short message.';

  @override
  String get provideALittleMoreDetail => 'Please provide a little more detail.';

  @override
  String get phoneNumberOrEmail => 'Phone number or email';

  @override
  String get enterAValidContact => 'Please enter a valid contact.';

  @override
  String get loadingOptions => 'Loading options...';

  @override
  String get noFeedbackCategoriesAvailable =>
      'No feedback categories available.';

  @override
  String get noFeedbackTypesAvailable => 'No feedback types available.';

  @override
  String get ratingTerrible => 'Terrible';

  @override
  String get thankYou => 'Thank you!';

  @override
  String get loadingVersion => 'Loading version…';

  @override
  String get madeBy => 'Made by';

  @override
  String get ourMission => 'Our mission';

  @override
  String get whatWeOffer => 'What we offer';

  @override
  String get whyWeBuiltThis => 'Why we built this';

  @override
  String appVersionLabel(String version) {
    return 'Hamro Futsal · v$version';
  }

  @override
  String versionLabel(String version) {
    return 'v$version';
  }

  @override
  String get feedbackDetailsCouldNotBeOpened =>
      'Feedback details could not be opened.';

  @override
  String get feedbackDetails => 'Feedback Details';

  @override
  String get submittedOn => 'Submitted on';

  @override
  String get contactInfo => 'Contact info';

  @override
  String get loggingOut => 'Logging out…';

  @override
  String get logOut => 'Log out';

  @override
  String get loading => 'Loading…';

  @override
  String get profileUnavailable => 'Profile unavailable';

  @override
  String get pullToRefreshYourAccount => 'Pull to refresh your account';

  @override
  String get logOutQuestion => 'Log out?';

  @override
  String get logOutConfirmationMessage =>
      'You will need to sign in again to access your bookings, chats, and profile.';

  @override
  String get vendorAccountActive => 'Vendor account active';

  @override
  String get businessVerifiedReadyForBookings =>
      'Your business is verified and ready to receive bookings.';

  @override
  String get vendorActiveVerificationPending =>
      'Your vendor account is active. Business verification is pending.';

  @override
  String get businessUnderReview => 'Business under review';

  @override
  String get hamroFutsalReviewingBusinessInfo =>
      'Hamro Futsal is reviewing your submitted business information.';

  @override
  String get businessVerificationRejected => 'Business verification rejected';

  @override
  String get reviewBusinessInfoAndResubmit =>
      'Review your business information and submit it again.';

  @override
  String get vendorAccountSuspended => 'Vendor account suspended';

  @override
  String get contactSupportForAssistance =>
      'Contact Hamro Futsal support for assistance.';

  @override
  String get actionRequired => 'Action required';

  @override
  String get updateVendorInfoToContinue =>
      'Update your vendor information to continue.';

  @override
  String get completeVendorSetup => 'Complete vendor setup';

  @override
  String get finishVenueAndBusinessDetails =>
      'Finish your venue and business details to start accepting bookings.';

  @override
  String get startVendorSetup => 'Start vendor setup';

  @override
  String get addBusinessAndVenueDetails =>
      'Add your business and venue details to become a verified vendor.';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get others => 'Others';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get contactInformation => 'Contact information';

  @override
  String get nameNotProvided => 'Name not provided';

  @override
  String get addressNotSet => 'Address not set';

  @override
  String get businessName => 'Business name';

  @override
  String get enterYourBusinessName => 'Enter your business name';

  @override
  String get enterYourPhoneNumber => 'Enter your phone number';

  @override
  String get enterYourBusinessAddress => 'Enter your business address';

  @override
  String get addAnOptionalMessage => 'Add an optional message';

  @override
  String bookingSavedReference(String reference) {
    return 'Booking saved. Reference: $reference';
  }

  @override
  String paymentStatusLabel(String payment) {
    return 'Payment: $payment';
  }

  @override
  String referenceLabel(String reference) {
    return 'Reference: $reference';
  }

  @override
  String get receipt => 'Receipt';

  @override
  String get goodDayVendor => 'Good day, vendor';

  @override
  String get freeSlots => 'Free slots';

  @override
  String get collected => 'Collected';

  @override
  String get due => 'Due';

  @override
  String amountInRupees(String amount) {
    return 'Rs. $amount';
  }

  @override
  String dueRsAmount(String amount) {
    return 'Due Rs. $amount';
  }

  @override
  String get todaySchedule => 'Today schedule';

  @override
  String get tapFreeTimeToAddToBooking =>
      'Tap a free time to add it to a booking.';

  @override
  String get selectFreeTimesFirst => 'Select free times first.';

  @override
  String timesSelected(int count) {
    return '$count time selected';
  }

  @override
  String slotTimeAndPrice(String timeRange, String price) {
    return '$timeRange · Rs. $price';
  }

  @override
  String get customerPhone => 'Customer phone';

  @override
  String get totalAmount => 'Total amount';

  @override
  String get saveBooking => 'Save booking';

  @override
  String get todaysBookings => 'Today\'s bookings';

  @override
  String get searchByNamePhoneOrReference =>
      'Search by name, phone, or reference.';

  @override
  String get searchBooking => 'Search booking';

  @override
  String get noBookingsFound => 'No bookings found.';

  @override
  String get tapAFreeTime => 'Tap a free time';

  @override
  String get selectedTimesWillAppearHere => 'Selected times will appear here.';

  @override
  String get expenseCategoryRent => 'Rent';

  @override
  String get expenseCategoryMaintenance => 'Maintenance';

  @override
  String get expenseCategorySalaries => 'Salaries';

  @override
  String get expenseCategorySupplies => 'Supplies';

  @override
  String get expenseCategoryMarketing => 'Marketing';

  @override
  String get expenseCategoryRefreshments => 'Refreshments';

  @override
  String get expenseCategoryInsurance => 'Insurance';

  @override
  String get expenseCategoryUtilities => 'Utilities';

  @override
  String get expenseCategoryOther => 'Other';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get hourlySpend => 'Hourly spend';

  @override
  String get monthlySpend => 'Monthly spend';

  @override
  String get dailySpend => 'Daily spend';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get couldNotLoadExpenses => 'Could not load expenses.';

  @override
  String expenseAdded(String amount) {
    return 'Expense added · $amount';
  }

  @override
  String expenseDeleted(String amount) {
    return 'Expense deleted · $amount';
  }

  @override
  String expenseUpdated(String amount) {
    return 'Expense updated · $amount';
  }

  @override
  String get editExpense => 'Edit expense';

  @override
  String get newExpenseTitle => 'New expense';

  @override
  String get pickACategory => 'Pick a category';

  @override
  String get details => 'Details';

  @override
  String get updateExpense => 'Update expense';

  @override
  String get saveExpense => 'Save expense';

  @override
  String updateExpenseWithAmount(String amount) {
    return 'Update expense · $amount';
  }

  @override
  String saveExpenseWithAmount(String amount) {
    return 'Save expense · $amount';
  }

  @override
  String todayCommaDate(String date) {
    return 'Today, $date';
  }

  @override
  String fileSizeMb(String size) {
    return '$size MB';
  }

  @override
  String fileSizeKb(String size) {
    return '$size KB';
  }

  @override
  String get totalSpend => 'Total spend';

  @override
  String get trend => 'Trend';

  @override
  String get byCategory => 'By category';

  @override
  String get byCourt => 'By court';

  @override
  String recordsForCategory(String category) {
    return 'Records · $category';
  }

  @override
  String get selectAStartDate => 'Select a start date';

  @override
  String get sevenDays => '7 days';

  @override
  String get thirtyDays => '30 days';

  @override
  String avgAmount(String amount) {
    return 'Avg $amount';
  }

  @override
  String plusMoreCount(int count) {
    return '+ $count more';
  }

  @override
  String get enterAmountGreaterThan0 => 'Enter an amount greater than 0';

  @override
  String get tapToEnterExpenseAmount => 'Tap to enter the expense amount';

  @override
  String avgPerDayWithEntries(String amount, int entries) {
    String _temp0 = intl.Intl.pluralLogic(
      entries,
      locale: localeName,
      other: '$entries entries',
      one: '$entries entry',
    );
    return '≈ $amount / day · $_temp0';
  }

  @override
  String get dailyAverage => 'Daily average';

  @override
  String avgPerEntry(String amount) {
    return 'Avg $amount / entry';
  }

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get noMatchingRecords => 'No matching records';

  @override
  String get noRecordsYet => 'No records yet';

  @override
  String get tryDifferentPeriodVenueOrCategory =>
      'Try a different period, venue or category.';

  @override
  String get expensesYouAddWillShowUpHere =>
      'Expenses you add will show up here.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get addExpense => 'Add expense';

  @override
  String get todayUpper => 'TODAY';

  @override
  String get yesterdayUpper => 'YESTERDAY';

  @override
  String dotEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
    );
    return '· $_temp0';
  }

  @override
  String rangeEntriesSummary(String label, int count, String total) {
    return '$label · $count entries · $total';
  }

  @override
  String customDays(int days) {
    return 'Custom · ${days}d';
  }

  @override
  String get allMethods => 'All methods';

  @override
  String get venueCourt => 'Venue · Court';

  @override
  String get method => 'Method';

  @override
  String get couldNotDownloadChatMedia => 'Could not download chat media.';

  @override
  String tooManyRequestsTryAgainIn(int seconds) {
    return 'Too many requests. Please try again in $seconds seconds.';
  }

  @override
  String get parseTargetConversations => 'conversations';

  @override
  String get parseTargetRegisteredUsers => 'registered users';

  @override
  String get parseTargetConversation => 'the conversation';

  @override
  String get parseTargetGroupConversation => 'the group conversation';

  @override
  String get parseTargetUserPresence => 'user presence';

  @override
  String get parseTargetProfile => 'the profile';

  @override
  String get parseTargetMessages => 'messages';

  @override
  String get parseTargetSentMessage => 'the sent message';

  @override
  String get conversationFilterDirect => 'Direct';

  @override
  String get conversationFilterGroups => 'Groups';

  @override
  String get conversationFilterArchived => 'Archived';

  @override
  String get conversation => 'Conversation';

  @override
  String get noMessagesYetSayHello => 'No messages yet — say hello!';

  @override
  String youPrefixed(String text) {
    return 'You: $text';
  }

  @override
  String get nowLower => 'now';

  @override
  String hoursAgoShort(int hours) {
    return '$hours hr ago';
  }

  @override
  String daysAgoShort(int days) {
    return '$days day ago';
  }

  @override
  String get groupPhotoUpdated => 'Group photo updated.';

  @override
  String get groupUpdated => 'Group updated.';

  @override
  String get youJoinedTheGroup => 'You joined the group.';

  @override
  String get invitationDeclined => 'Invitation declined.';

  @override
  String get youLeftTheGroup => 'You left the group.';

  @override
  String get memberAdded => 'Member added.';

  @override
  String membersAdded(int count) {
    return '$count members added.';
  }

  @override
  String get conversationArchived => 'Conversation archived.';

  @override
  String get conversationUnarchived => 'Conversation unarchived.';

  @override
  String get conversationMuted => 'Conversation muted.';

  @override
  String get conversationUnmuted => 'Conversation unmuted.';

  @override
  String get participantBlocked => 'Participant blocked.';

  @override
  String get participantUnblocked => 'Participant unblocked.';

  @override
  String get messageDeletedSuccess => 'Message deleted.';

  @override
  String get messageMaxFiles => 'A message can contain at most 5 files.';

  @override
  String get locationUnavailableCheckPermission =>
      'Location is unavailable. Check location permission and services.';

  @override
  String get sharedLocation => 'Shared location';

  @override
  String saveFileNamed(String name) {
    return 'Save $name';
  }

  @override
  String get couldNotLoadMessages => 'Could not load messages.';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
    );
    return '$_temp0';
  }

  @override
  String get checkingPresence => 'Checking presence…';

  @override
  String get couldNotLoadUsers => 'Could not load users.';

  @override
  String get selectAtLeastOneMember => 'Select at least one member.';

  @override
  String groupMaxMembers(int max) {
    return 'A group can contain at most $max members.';
  }

  @override
  String tapToAddUpToPeople(int max) {
    return 'Tap to add up to $max people.';
  }

  @override
  String get noUsersFound => 'No users found';

  @override
  String get registeredUsersWillAppearHere =>
      'Registered users will appear here.';

  @override
  String declineInvitationTo(String title) {
    return 'Decline the invitation to \"$title\"?';
  }

  @override
  String get couldNotLoadConversations => 'Could not load conversations.';

  @override
  String get selectAConversation => 'Select a conversation';

  @override
  String get pickAChatToReadAndReply =>
      'Pick a chat from the list to read and reply here.';

  @override
  String get couldNotLoadMoreConversations =>
      'Could not load more conversations.';

  @override
  String conversationsUnreadSummary(int count) {
    return '$count conversations';
  }

  @override
  String conversationsUnreadSummarySuffix(int unread) {
    return ' · $unread unread';
  }

  @override
  String get creatingEllipsis => 'Creating...';

  @override
  String get cannotSendMessagesInConversation =>
      'You cannot send messages in this conversation.';

  @override
  String get typeHere => 'Type here';

  @override
  String get notifyEveryone => 'Notify everyone';

  @override
  String get deletedMessage => 'Deleted message';

  @override
  String replyingTo(String senderName, String body) {
    return 'Replying to $senderName: $body';
  }

  @override
  String get replyingToMessageFallback => 'message';

  @override
  String get attachment => 'Attachment';

  @override
  String get messageDeleted => 'Message deleted';

  @override
  String opensInTheApp(String text) {
    return '$text, opens in the app';
  }

  @override
  String userNumber(int id) {
    return 'User #$id';
  }

  @override
  String get selectAtLeastOneNewMember => 'Select at least one new member.';

  @override
  String get choosePeopleToAddInGroup => 'Choose people to add in this group';

  @override
  String addMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
    );
    return 'Add $_temp0';
  }

  @override
  String get noMatchingConversations => 'No matching conversations';

  @override
  String get tryDifferentFilterOrSearch =>
      'Try a different filter or search term.';

  @override
  String get yourConversationsWillAppearHere =>
      'Your conversations will appear here.';

  @override
  String get greetingFallbackName => 'there';

  @override
  String get checkConnectionAndTryAgain =>
      'Please check your connection and try again.';

  @override
  String get rsPriceUnavailable => 'Rs. --';

  @override
  String rsDotAmount(String amount) {
    return 'Rs. $amount';
  }

  @override
  String distanceKm(String value) {
    return '$value km';
  }

  @override
  String get thisMonthRevenue => 'This month revenue';

  @override
  String get bookedSlotsThisMonth => 'Booked slots this month';

  @override
  String get courtUsageToday => 'Court usage today';

  @override
  String get cancelledReservations => 'Cancelled reservations';

  @override
  String get openNow => 'Open Now';

  @override
  String get closedNow => 'Closed Now';

  @override
  String get merchant => 'Merchant';

  @override
  String get futsalVendor => 'Futsal Vendor';

  @override
  String get management => 'Management';

  @override
  String activeNowAt(String time) {
    return 'Active now · $time';
  }

  @override
  String get markRead => 'Mark read';

  @override
  String get read => 'Read';

  @override
  String get equipment => 'Equipment';

  @override
  String get history => 'History';

  @override
  String get football => 'Football';

  @override
  String get trainingBibs => 'Training bibs';

  @override
  String get goalkeeperGloves => 'Goalkeeper gloves';

  @override
  String get conesSetOf10 => 'Cones (set of 10)';

  @override
  String get shinGuards => 'Shin guards';

  @override
  String get futsalBoots => 'Futsal boots';

  @override
  String get waterBottle => 'Water bottle';

  @override
  String get towel => 'Towel';

  @override
  String get tacticBoard => 'Tactic board';

  @override
  String get bibs => 'Bibs';

  @override
  String get gloves => 'Gloves';

  @override
  String get cones => 'Cones';

  @override
  String get boots => 'Boots';

  @override
  String get bottle => 'Bottle';

  @override
  String get overdue => 'Overdue';

  @override
  String get returned => 'Returned';

  @override
  String equipmentAdded(String name) {
    return 'Equipment added · $name';
  }

  @override
  String get addEquipmentFirst => 'Add equipment first';

  @override
  String rentalStartedFor(String customer) {
    return 'Rental started for $customer';
  }

  @override
  String markedReturned(String customer) {
    return 'Marked returned · $customer';
  }

  @override
  String get addItemsToStartRenting => 'Add items to start renting them out.';

  @override
  String equipmentRateAndDeposit(
    String kind,
    String hourlyRate,
    String deposit,
  ) {
    return '$kind · $hourlyRate/hr · Deposit $deposit';
  }

  @override
  String get outOfStock => 'Out of stock';

  @override
  String availableCount(int count) {
    return '$count available';
  }

  @override
  String percentOfStockRented(int percent) {
    return '$percent% of stock currently rented';
  }

  @override
  String get noActiveRentals => 'No active rentals';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get startNewRentalFromButtonBelow =>
      'Start a new rental from the button below.';

  @override
  String get returnedRentalsWillAppearHere =>
      'Returned rentals will appear here.';

  @override
  String equipmentWithQty(String name, int qty) {
    return '$name · ×$qty';
  }

  @override
  String get overdueBy => 'Overdue by';

  @override
  String get returnsIn => 'Returns in';

  @override
  String returnedAt(String time) {
    return 'Returned · $time';
  }

  @override
  String get itemType => 'Item type';

  @override
  String get pickAType => 'Pick a type';

  @override
  String get pickAnItem => 'Pick an item';

  @override
  String nameWithHourlyRate(String name, String hourlyRate) {
    return '$name · $hourlyRate/hr';
  }

  @override
  String depositPerUnit(String deposit) {
    return 'Deposit $deposit / unit';
  }

  @override
  String get quantityAndDuration => 'Quantity & duration';

  @override
  String onlyUnitsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Only $count units available.',
      one: 'Only $count unit available.',
    );
    return '$_temp0';
  }

  @override
  String get summary => 'Summary';

  @override
  String get rate => 'Rate';

  @override
  String rateBreakdown(String rate, int qty, int hours) {
    return '$rate × $qty × ${hours}h';
  }

  @override
  String get receiptImageDoesNotExist => 'Receipt image does not exist.';

  @override
  String get receiptImageResolutionTooLow =>
      'Receipt image resolution is too low';

  @override
  String get receiptImageFileTooSmall => 'Receipt image file is too small';

  @override
  String get receiptImageAppearsBlank => 'Receipt image appears blank';

  @override
  String get receiptImageAppearsBlurry =>
      'Receipt image appears blurry or unreadable';

  @override
  String get receiptImageQualityNotAcceptable =>
      'Receipt image quality is not acceptable';

  @override
  String get receiptTextNotReadable => 'Receipt text is not readable';

  @override
  String get merchantNameDoesNotMatch => 'Merchant name does not match';

  @override
  String expectedAmountNotFound(String amount) {
    return 'Expected amount $amount not found';
  }

  @override
  String get paymentNotMarkedSuccessful => 'Payment is not marked successful';

  @override
  String get successfulPaymentStatusNotFound =>
      'Successful payment status not found';

  @override
  String get transactionReferenceIdNotFound =>
      'Transaction/reference ID not found';

  @override
  String get transactionDateNotFound => 'Transaction date not found';

  @override
  String get qrCodeNotFound => 'QR code not found';

  @override
  String get transactionIdAlreadySubmitted =>
      'Transaction ID has already been submitted';

  @override
  String receiptValidationScoreBelow(int score) {
    return 'Receipt validation score is below $score%';
  }

  @override
  String get proofAcceptedPendingVerification =>
      'Proof accepted. Pending manual payment verification.';

  @override
  String unableToProcessPaymentReceipt(String error) {
    return 'Unable to process payment receipt: $error';
  }

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get fullNameTooLong => 'Full name cannot exceed 80 characters';

  @override
  String get fullNameLettersOnly =>
      'Full name can contain letters and spaces only';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailTooLong => 'Email address is too long';

  @override
  String get enterValidEmailAddress => 'Enter a valid email address';

  @override
  String get phoneNumberRequired => 'Phone number is required';

  @override
  String get enterValidNepalMobile => 'Enter a valid Nepal mobile number';

  @override
  String get useNepalMobileFormat =>
      'Use a 97/98 mobile number with optional +977 prefix';

  @override
  String get chooseVenueAgainToViewSlots =>
      'Please choose a venue again to view available slots.';

  @override
  String get bookingNoLongerAvailable => 'This booking is no longer available.';

  @override
  String get pickYourSlotAgainToContinue =>
      'Please pick your slot again to continue.';

  @override
  String get biometricSignInReason => 'Authenticate to sign in to Hamro Futsal';

  @override
  String get fileIsEmptyAttachAgain =>
      'That file is empty. Please attach it again.';

  @override
  String get fileCameThroughEmpty =>
      'That file came through empty. Please attach it again.';

  @override
  String get fileCouldNotBeRead =>
      'That file could not be read. Please attach it again.';

  @override
  String get fileNoLongerAvailable =>
      'That file is no longer available. Please attach it again.';

  @override
  String get unsupportedFileTypeAttachSupported =>
      'The selected file type is not supported. Please attach a supported file.';

  @override
  String get theSelectedFile => 'The selected file';

  @override
  String uploadAtMostFiles(int count) {
    return 'You can upload at most $count files at once.';
  }

  @override
  String namedFileIsEmpty(String name) {
    return '$name is empty. Please attach it again.';
  }

  @override
  String namedFileMustBeOrSmaller(String name, String size) {
    return '$name must be $size or smaller.';
  }

  @override
  String uploadExceedsRequestLimit(String size) {
    return 'The upload exceeds the $size request limit.';
  }

  @override
  String selectedFilesExceedRequestLimit(String size) {
    return 'The selected files exceed the $size request limit.';
  }

  @override
  String onlyFileTypesCanBeUploaded(String types) {
    return 'Only $types files can be uploaded.';
  }

  @override
  String fileMustBeOrSmaller(String size) {
    return 'The file must be $size or smaller.';
  }

  @override
  String imageCouldNotBeReducedBelow(String size) {
    return 'The image could not be reduced below $size. Please choose a smaller image.';
  }

  @override
  String imageStillLargerThan(String size) {
    return 'The image is still larger than $size. Please choose a smaller image.';
  }

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get englishAdCalendar => 'English (AD)';

  @override
  String get nepaliBsCalendar => 'Nepali (BS)';

  @override
  String get adShort => 'AD';

  @override
  String get bsShort => 'BS';

  @override
  String get englishLetters => 'English letters';

  @override
  String get nepaliScript => 'नेपाली';

  @override
  String get serverMalformedData =>
      'The server responded with malformed data, please retry again.';

  @override
  String get serverErrorRetry =>
      'The server encountered an error and could not complete your request, please retry again.';

  @override
  String get noInternetConnectionCheckSettings =>
      'No Internet Connection, please check your network settings and try again.';

  @override
  String get networkUnreachable =>
      'Network unreachable, please check your network settings and try again.';

  @override
  String get noContentFound => 'No content found.';

  @override
  String get fileTooLargeForServer =>
      'The selected file is too large for the server. Choose a smaller file and try again.';

  @override
  String get serverCouldNotReadAttachment =>
      'The server could not read the attachment. Reattach a smaller file and try again.';

  @override
  String get sessionEnded => 'Session ended';

  @override
  String get sessionExpiredLogInAgain =>
      'Session expired. Please log in again.';

  @override
  String get uploadSendTimedOut =>
      'The upload timed out while sending the attachment. Check your connection and try again.';

  @override
  String get uploadProcessingTimedOut =>
      'The upload timed out while the server was processing it. Check whether your change was saved before trying again.';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get highImportanceNotificationsChannel =>
      'High Importance Notifications';

  @override
  String get highImportanceNotificationsDescription =>
      'Important updates from Hamro Futsal.';

  @override
  String get youHaveNewNotification => 'You have a new notification.';

  @override
  String get mapPreviewUnavailable => 'Map preview unavailable';

  @override
  String get couldNotLoadThisPage => 'Could not load this page.';

  @override
  String get typePrefix => 'Type ';

  @override
  String get belowToConfirm => ' below to confirm.';

  @override
  String get belowToContinue => ' below to continue.';

  @override
  String get selectBackgroundColor => 'Select Background Color';

  @override
  String get selectTextColor => 'Select Text Color';

  @override
  String pageOfTotal(int page, int total) {
    return '$page of $total';
  }

  @override
  String get selectVenueFirst => 'Select a venue first.';

  @override
  String get deleteProductQuestion => 'Delete product?';

  @override
  String removeProductConfirmation(String name) {
    return 'This will remove $name from your products.';
  }

  @override
  String productsCount(String count) {
    return '$count products';
  }

  @override
  String get manageProductsSubtitle =>
      'Manage product name, price and active status per venue.';

  @override
  String get selectVenue => 'Select venue';

  @override
  String get productList => 'Product list';

  @override
  String get editProduct => 'Edit product';

  @override
  String get deleteProduct => 'Delete product';

  @override
  String get updateProduct => 'Update product';

  @override
  String get createProduct => 'Create product';

  @override
  String get productName => 'Product name';

  @override
  String get productNameHint => 'Water bottle';

  @override
  String get enterProductName => 'Enter product name';

  @override
  String get enterValidPrice => 'Enter valid price';

  @override
  String get activeProduct => 'Active product';

  @override
  String get visibleForSale => 'Visible for sale';

  @override
  String get hiddenFromSale => 'Hidden from sale';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get tapCreateToAddFirstProduct =>
      'Tap Create to add your first product.';

  @override
  String get selectVenueToManageProducts =>
      'Select a venue to manage its products';

  @override
  String itemsYouSellAt(String venueName) {
    return 'Items you sell at $venueName';
  }

  @override
  String get newProduct => 'New product';

  @override
  String get totalProducts => 'Total products';

  @override
  String get averagePrice => 'Average price';

  @override
  String get searchProducts => 'Search products';

  @override
  String get noProductsMatchSearch => 'No products match your search.';

  @override
  String get actionsUpper => 'ACTIONS';

  @override
  String get noVenuesFoundForProducts => 'No venues found for products.';

  @override
  String get productCreatedSuccessfully => 'Product created successfully.';

  @override
  String get productUpdatedSuccessfully => 'Product updated successfully.';

  @override
  String get productDeletedSuccessfully => 'Product deleted successfully.';

  @override
  String get couldNotReadVenuesFromServer =>
      'Could not read venues from the server.';

  @override
  String get couldNotReadProductsFromServer =>
      'Could not read products from the server.';

  @override
  String get venueVendor => 'Venue Vendor';

  @override
  String get yourEmail => 'your email';

  @override
  String get otpResentSuccessfullyCheckEmail =>
      'OTP resent successfully. Check your email.';

  @override
  String get otpVerifiedSuccessfully => 'OTP verified successfully.';

  @override
  String get otpVerifiedSuccessfullyShort => 'OTP verified successfully';

  @override
  String get otpVerifiedPleaseSignIn =>
      'OTP verified successfully. Please sign in to continue.';

  @override
  String enterOtpCodeSentTo(int otpLength, String email) {
    return 'Enter the $otpLength-digit code sent to $email';
  }

  @override
  String enterOtpCodeAndChooseNewPassword(int otpLength, String email) {
    return 'Enter the $otpLength-digit code sent to $email and choose a new password';
  }

  @override
  String chooseNewPasswordFor(String email) {
    return 'Choose a new password for $email';
  }

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get noBiometricAccountSaved =>
      'No biometric account is saved. Sign in with your password first.';

  @override
  String get emailIsRequired => 'Email is required';

  @override
  String get pleaseConfirmYourPassword => 'Please confirm your password';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get createYourAccount => 'Create Your Account';

  @override
  String get signInToBookMatchesOrManageVenue =>
      'Sign in to book matches or manage your venue.';

  @override
  String get joinAsPlayerOrVenueVendor => 'Join as a player or a venue vendor.';

  @override
  String get signInTitle => 'Sign In';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get newToHamroFutsal => 'New to Hamro Futsal?';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get createAccount => 'Create account';

  @override
  String get signIn => 'Sign in';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get signInWithBiometrics => 'Sign in with biometrics';

  @override
  String get loginSuccessful => 'Login successful';

  @override
  String get googleSignInNotConfigured =>
      'Google sign-in is not configured for this app version. Please contact support. (Google 10)';

  @override
  String googleErrorCode(String code) {
    return '(Google $code)';
  }

  @override
  String get registrationSuccessful => 'Registration successful';

  @override
  String get pleaseSelectAccountType => 'Please select an account type';

  @override
  String get youMustAcceptTermsToContinue =>
      'You must accept the terms to continue';

  @override
  String get iAgreeToThe => 'I agree to the ';

  @override
  String get terms => 'Terms';

  @override
  String get andConnector => ' and ';

  @override
  String stepLabel(int step) {
    return 'Step $step';
  }

  @override
  String percentOff(String percent) {
    return '$percent% off';
  }

  @override
  String amountOff(String amount) {
    return '$amount off';
  }

  @override
  String rsAmountOff(String amount) {
    return 'Rs $amount off';
  }

  @override
  String get pointsEarnedTitle => 'Points earned';

  @override
  String get pointsRedeemedTitle => 'Points redeemed';

  @override
  String get pointsExpiredTitle => 'Points expired';

  @override
  String get pointsAdjustedTitle => 'Points adjusted';

  @override
  String get thatsAllYourRewardActivity => 'That’s all your reward activity';

  @override
  String get pointsUsed => 'Points used';

  @override
  String get pointsLeft => 'Points left';

  @override
  String get validTill => 'Valid till';

  @override
  String worthAmount(String amount) {
    return ' worth $amount';
  }

  @override
  String youCanRedeemPointsForCoupon(String points, String worth) {
    return 'You can redeem $points points for a coupon$worth.';
  }

  @override
  String morePointsForNextCoupon(String points) {
    return '$points more points for your next coupon.';
  }

  @override
  String get couponUnlocked => 'Coupon unlocked';

  @override
  String get nextCoupon => 'Next coupon';

  @override
  String pointsProgress(String current, String target) {
    return '$current / $target pts';
  }

  @override
  String get couponsAvailable => 'Coupons available';

  @override
  String couponWithCode(String code) {
    return 'Coupon $code';
  }

  @override
  String refWithValue(String reference) {
    return 'Ref $reference';
  }

  @override
  String balanceWithPoints(String points) {
    return 'Bal $points';
  }

  @override
  String pointsEqualsCoupon(String points, String amount) {
    return '$points points = $amount coupon.';
  }

  @override
  String pointsEqualsDiscountCoupon(String points) {
    return '$points points = 1 discount coupon.';
  }

  @override
  String get applyCouponAtCheckout =>
      'Apply the generated coupon code at checkout to use your discount.';

  @override
  String get enterACouponCode => 'Enter a coupon code.';

  @override
  String get emptyAppStoreLookupResponse => 'Empty App Store lookup response';

  @override
  String get appStoreLookupFailed => 'App Store lookup failed';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully.';

  @override
  String get couldNotChangePassword => 'Could not change the password.';

  @override
  String get morningTimeRange => '06:00 AM - 12:00 PM';

  @override
  String get afternoonTimeRange => '12:00 PM - 06:00 PM';

  @override
  String get eveningTimeRange => '06:00 PM - 12:00 AM';

  @override
  String get setYourHourlyBudget => 'Set your hourly budget';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get courtPreferences => 'Court preferences';

  @override
  String get chooseCourtAndMatchYouPrefer =>
      'Choose the court and match you prefer';

  @override
  String get onlyShowCourtsWithPreferredRating =>
      'Only show courts with your preferred rating';

  @override
  String get anyRating => 'Any rating';

  @override
  String ratingAndUp(String rating) {
    return '$rating & up';
  }

  @override
  String get tapStarToSetMinimumRating =>
      'Tap a star to set the minimum venue rating.';

  @override
  String get selectConvenientPlayTimes =>
      'Select one or more convenient play times';

  @override
  String get yourPreferencesAreReady => 'Your preferences are ready';

  @override
  String get refineYourSearch => 'Refine your search';

  @override
  String get adjustSelectionsToSeeMatchingCourts =>
      'Adjust selections or apply them to see matching courts.';

  @override
  String get chooseBudgetCourtTypeRatingOrPlayTime =>
      'Choose a budget, court type, rating, or play time.';

  @override
  String countSelected(String count) {
    return '$count selected';
  }

  @override
  String get couldNotLoadOptions => 'Could not load options.';

  @override
  String get showingAllCourts => 'Showing all courts';

  @override
  String filtersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filters selected',
      one: '$count filter selected',
    );
    return '$_temp0';
  }

  @override
  String get showCourts => 'Show courts';

  @override
  String get couldNotLoadFaqs => 'Could not load FAQs.';

  @override
  String get noFaqsYet => 'No FAQs yet';

  @override
  String get faqsWillAppearHere =>
      'Frequently asked questions will appear here.';

  @override
  String get couldNotLoadHelpTopics => 'Could not load help topics.';

  @override
  String get noHelpTopicsYet => 'No help topics yet';

  @override
  String get helpGuidesWillAppearHere =>
      'Help and how-to guides will appear here.';

  @override
  String get connectWithUs => 'Connect with us';

  @override
  String get reachOutOnSocialMedia =>
      'Reach out on social media — we usually reply within a few hours.';

  @override
  String get helpGuides => 'Help guides';

  @override
  String get helpCenter => 'Help center';

  @override
  String get helpCenterSubtitle =>
      'Answers, guides and videos for using Hamro Futsal.';

  @override
  String get searchFaqsAndGuides => 'Search FAQs and guides';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get tryDifferentWordOrBrowse =>
      'Try a different word, or browse the other sections.';

  @override
  String get bookingIncome => 'Booking income';

  @override
  String get opponentMatchIncome => 'Opponent match income';

  @override
  String get platformCommission => 'Platform commission';

  @override
  String get settlementPayout => 'Settlement payout';

  @override
  String get refund => 'Refund';

  @override
  String get adjustment => 'Adjustment';

  @override
  String get processing => 'Processing';

  @override
  String get failed => 'Failed';

  @override
  String get enterAValidAmount => 'Enter a valid amount.';

  @override
  String amountCantExceed(String amount) {
    return 'Amount can\'t exceed $amount.';
  }

  @override
  String settleTheFull(String amount) {
    return 'Settle the full $amount.';
  }

  @override
  String uploadReceiptBeforeSubmittingMax(int maxSizeMb) {
    return 'Upload the payment receipt before submitting (max $maxSizeMb MB).';
  }

  @override
  String get allFutsals => 'All futsals';

  @override
  String proofTypesMaxSize(String types, int maxSizeMb) {
    return '$types · Max $maxSizeMb MB';
  }

  @override
  String get scanAndPay => 'Scan and pay';

  @override
  String get sendCommissionUsingQr =>
      'Send the commission to Hamro Futsal using this QR.';

  @override
  String get commissionToPay => 'Commission to pay';

  @override
  String get confirmThePayment => 'Confirm the payment';

  @override
  String get enterWhatYouSentAndAttachReceipt =>
      'Enter what you sent and attach the receipt as proof.';

  @override
  String get commissionAmountNpr => 'Commission amount (NPR)';

  @override
  String get fullCommissionInOneRequest =>
      'The full commission must be paid in one request.';

  @override
  String get transactionReference => 'Transaction reference';

  @override
  String get transactionReferenceHint => 'Bank / eSewa / Khalti transaction ID';

  @override
  String get enterPaymentTransactionReference =>
      'Enter the payment transaction reference.';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get paymentRemark => 'Payment remark';

  @override
  String get submitting => 'Submitting…';

  @override
  String get submitCommissionPayment => 'Submit Commission Payment';

  @override
  String fileSizeBytes(int bytes) {
    return '$bytes B';
  }

  @override
  String get uploadPaymentProof => 'Upload payment proof';

  @override
  String get uploadReceiptBeforeSubmitting =>
      'Upload the payment receipt before submitting.';

  @override
  String get noAccountActivityYet => 'No account activity yet';

  @override
  String get accountActivityWillAppearHere =>
      'Booking income, platform commission and payouts will appear here.';

  @override
  String get manage => 'Manage';

  @override
  String get commissionPaymentNotAvailable =>
      'Commission payment is not available right now.';

  @override
  String get futsalBreakdown => 'Futsal breakdown';

  @override
  String get futsalBreakdownTitle => 'Futsal Breakdown';

  @override
  String futsalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count futsals',
      one: '$count futsal',
    );
    return '$_temp0';
  }

  @override
  String get noSettlementsYet => 'No settlements yet';

  @override
  String settlementsInProgress(int inProgress, int total) {
    return '$inProgress in progress · $total total';
  }

  @override
  String settlementsTotal(int total) {
    return '$total total';
  }

  @override
  String get noFutsalsYet => 'No futsals yet';

  @override
  String get futsalBalancesWillAppearHere =>
      'Balances for each of your futsals will appear here.';

  @override
  String get noCommissionDueForFutsal =>
      'No commission due for this futsal yet.';

  @override
  String get settlementNotAvailableForFutsal =>
      'Settlement is not available for this futsal yet.';

  @override
  String get couldNotLoadFutsalBreakdown =>
      'Could not load the futsal breakdown.';

  @override
  String get requestSettlementEmptyMessage =>
      'Request a settlement and Hamro Futsal will pay your balance out to you.';

  @override
  String get scanAnyQrToPay => 'Scan any QR to pay';

  @override
  String get scanToPay => 'Scan to pay';

  @override
  String get payTo => 'Pay to';

  @override
  String get phoneNumberCopied => 'Phone number copied.';

  @override
  String get chooseAnExistingPhoto => 'Choose an existing photo';

  @override
  String get takeAPhotoNow => 'Take a photo now';

  @override
  String get browseYourDocuments => 'Browse your documents';

  @override
  String get addAFile => 'Add a file';

  @override
  String get cameraDidNotFinishSavingImage =>
      'The camera did not finish saving the image. Please take the photo again.';

  @override
  String get fileCameThroughEmptySelectAgain =>
      'That file came through empty. Please select it again.';

  @override
  String get couldNotOpenThatFile =>
      'Could not open that file. Please try again.';

  @override
  String get mediaLibrarySubtitle =>
      'Select saved media or add new files for this section.';

  @override
  String get uploadWithoutUsableMediaReference =>
      'The upload completed without a usable media reference. Please try again.';

  @override
  String get uploadAtMostFiveFiles => 'You can upload at most 5 files at once.';

  @override
  String get selectedImageIsEmpty =>
      'The selected image is empty. Please select the original image again.';

  @override
  String get couldNotSelectImage => 'Could not select image. Please try again.';

  @override
  String get couldNotOpenCamera => 'Could not open camera. Please try again.';

  @override
  String filesCount(int count) {
    return '$count files';
  }

  @override
  String uploadFileToMediaLibraryQuoted(String file) {
    return 'Do you want to upload \"$file\" to media library?';
  }

  @override
  String uploadFilesToMediaLibrary(String files) {
    return 'Do you want to upload $files to media library?';
  }

  @override
  String get remoteMediaIsReadOnly =>
      'Remote media is read-only in this library.';

  @override
  String removeItemFromSavedCollection(String name) {
    return 'Do you want to remove \"$name\" from your saved collection?';
  }

  @override
  String moreSelected(int count) {
    return '+$count more selected';
  }

  @override
  String get chooseFromYourPhotos => 'Choose from your photos';

  @override
  String get takeANewPhoto => 'Take a new photo';

  @override
  String get browseDocuments => 'Browse documents';

  @override
  String get mediaUploadedSuccessfully => 'Media uploaded successfully.';

  @override
  String hoursAgoPlural(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours ago',
      one: '$hours hour ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgoPlural(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '$days day ago',
    );
    return '$_temp0';
  }

  @override
  String get venuesYouSaveForLater => 'Venues you save for later';

  @override
  String savedVenuesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved venues',
      one: '$count saved venue',
    );
    return '$_temp0';
  }
}
