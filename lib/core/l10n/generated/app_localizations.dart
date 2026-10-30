import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ne'),
  ];

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutThisCourt.
  ///
  /// In en, this message translates to:
  /// **'About this court'**
  String get aboutThisCourt;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @acceptBooking.
  ///
  /// In en, this message translates to:
  /// **'Accept booking'**
  String get acceptBooking;

  /// No description provided for @rejectBooking.
  ///
  /// In en, this message translates to:
  /// **'Reject booking'**
  String get rejectBooking;

  /// No description provided for @acceptBookingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm the verified payment amount to accept this booking.'**
  String get acceptBookingConfirmation;

  /// No description provided for @approvePaymentProofConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm the actual received amount and add optional remarks.'**
  String get approvePaymentProofConfirmation;

  /// No description provided for @rejectBookingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Add a reason for rejecting this payment (optional).'**
  String get rejectBookingConfirmation;

  /// No description provided for @actualAmount.
  ///
  /// In en, this message translates to:
  /// **'Actual amount'**
  String get actualAmount;

  /// No description provided for @verifiedAmount.
  ///
  /// In en, this message translates to:
  /// **'Verified amount'**
  String get verifiedAmount;

  /// No description provided for @verifiedVenue.
  ///
  /// In en, this message translates to:
  /// **'Verified venue'**
  String get verifiedVenue;

  /// No description provided for @paymentNote.
  ///
  /// In en, this message translates to:
  /// **'Payment note'**
  String get paymentNote;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get rejectionReason;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @bookingConfirmedToCompleted.
  ///
  /// In en, this message translates to:
  /// **'Booking status changed from Confirmed to Completed.'**
  String get bookingConfirmedToCompleted;

  /// No description provided for @couldNotCompleteBooking.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the booking. Please try again.'**
  String get couldNotCompleteBooking;

  /// No description provided for @bookingAcceptedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Booking accepted successfully.'**
  String get bookingAcceptedSuccessfully;

  /// No description provided for @bookingRejectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Booking rejected successfully.'**
  String get bookingRejectedSuccessfully;

  /// No description provided for @couldNotAcceptBooking.
  ///
  /// In en, this message translates to:
  /// **'Could not accept the booking.'**
  String get couldNotAcceptBooking;

  /// No description provided for @couldNotRejectBooking.
  ///
  /// In en, this message translates to:
  /// **'Could not reject the booking.'**
  String get couldNotRejectBooking;

  /// No description provided for @paymentVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment verified successfully.'**
  String get paymentVerifiedSuccessfully;

  /// No description provided for @paymentRejectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment rejected successfully.'**
  String get paymentRejectedSuccessfully;

  /// No description provided for @couldNotVerifyPayment.
  ///
  /// In en, this message translates to:
  /// **'Could not verify the payment.'**
  String get couldNotVerifyPayment;

  /// No description provided for @couldNotRejectPayment.
  ///
  /// In en, this message translates to:
  /// **'Could not reject the payment.'**
  String get couldNotRejectPayment;

  /// No description provided for @noPaymentToVerify.
  ///
  /// In en, this message translates to:
  /// **'This booking has no payment to verify.'**
  String get noPaymentToVerify;

  /// No description provided for @acceptWithin.
  ///
  /// In en, this message translates to:
  /// **'Accept within'**
  String get acceptWithin;

  /// No description provided for @approvePayment.
  ///
  /// In en, this message translates to:
  /// **'Approve payment'**
  String get approvePayment;

  /// No description provided for @createYourTeamFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your team first'**
  String get createYourTeamFirst;

  /// No description provided for @matchConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Match confirmed'**
  String get matchConfirmed;

  /// No description provided for @rejectPayment.
  ///
  /// In en, this message translates to:
  /// **'Reject payment'**
  String get rejectPayment;

  /// No description provided for @preferredVenue.
  ///
  /// In en, this message translates to:
  /// **'Preferred venue'**
  String get preferredVenue;

  /// No description provided for @rejectionReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Why is this proof invalid? (e.g. wrong amount)'**
  String get rejectionReasonHint;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchVenueToCheckSlots.
  ///
  /// In en, this message translates to:
  /// **'Search venue to check slots'**
  String get searchVenueToCheckSlots;

  /// No description provided for @totalCourtFeeRs.
  ///
  /// In en, this message translates to:
  /// **'Total court fee (Rs)'**
  String get totalCourtFeeRs;

  /// No description provided for @youNeedATeamToChallengeOpponents.
  ///
  /// In en, this message translates to:
  /// **'You need a team before you can challenge opponents. Create your team with its players first.'**
  String get youNeedATeamToChallengeOpponents;

  /// No description provided for @finalPricingConfirmedByServer.
  ///
  /// In en, this message translates to:
  /// **'Final pricing is confirmed by the server.'**
  String get finalPricingConfirmedByServer;

  /// No description provided for @requestExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This request has expired and can no longer be accepted.'**
  String get requestExpiredMessage;

  /// No description provided for @invitationNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This invitation is no longer available.'**
  String get invitationNoLongerAvailable;

  /// No description provided for @requestJustAcceptedByAnotherTeam.
  ///
  /// In en, this message translates to:
  /// **'This request was just accepted by another team.'**
  String get requestJustAcceptedByAnotherTeam;

  /// No description provided for @submitAndAccept.
  ///
  /// In en, this message translates to:
  /// **'Submit & Accept'**
  String get submitAndAccept;

  /// No description provided for @whichTeamWillPlay.
  ///
  /// In en, this message translates to:
  /// **'Which team will play?'**
  String get whichTeamWillPlay;

  /// No description provided for @yourTeamShare.
  ///
  /// In en, this message translates to:
  /// **'Your team\'s share'**
  String get yourTeamShare;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @financeAndPayouts.
  ///
  /// In en, this message translates to:
  /// **'Finance & Payouts'**
  String get financeAndPayouts;

  /// No description provided for @accountStatement.
  ///
  /// In en, this message translates to:
  /// **'Statement'**
  String get accountStatement;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @debit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get debit;

  /// No description provided for @bookingDate.
  ///
  /// In en, this message translates to:
  /// **'Booking date'**
  String get bookingDate;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recorded;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @bookedOn.
  ///
  /// In en, this message translates to:
  /// **'Booked on'**
  String get bookedOn;

  /// No description provided for @bookedBy.
  ///
  /// In en, this message translates to:
  /// **'Booked by'**
  String get bookedBy;

  /// No description provided for @selectClosureDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date properly.'**
  String get selectClosureDate;

  /// No description provided for @selectClosureStartAndEnd.
  ///
  /// In en, this message translates to:
  /// **'Select a start and end time.'**
  String get selectClosureStartAndEnd;

  /// No description provided for @closureEndAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be later than start time.'**
  String get closureEndAfterStart;

  /// No description provided for @loadingBookings.
  ///
  /// In en, this message translates to:
  /// **'Loading bookings…'**
  String get loadingBookings;

  /// No description provided for @each.
  ///
  /// In en, this message translates to:
  /// **'each'**
  String get each;

  /// No description provided for @unknownPlayer.
  ///
  /// In en, this message translates to:
  /// **'Unknown player'**
  String get unknownPlayer;

  /// No description provided for @futsalCourt.
  ///
  /// In en, this message translates to:
  /// **'Futsal court'**
  String get futsalCourt;

  /// No description provided for @customerBooking.
  ///
  /// In en, this message translates to:
  /// **'Customer booking'**
  String get customerBooking;

  /// No description provided for @futsalBooking.
  ///
  /// In en, this message translates to:
  /// **'Futsal booking'**
  String get futsalBooking;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalance;

  /// No description provided for @commissionPaid.
  ///
  /// In en, this message translates to:
  /// **'Commission paid'**
  String get commissionPaid;

  /// No description provided for @couldNotParseAccountFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not read your account from the server.'**
  String get couldNotParseAccountFromServer;

  /// No description provided for @couldNotSubmitSettlementRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not submit the settlement request.'**
  String get couldNotSubmitSettlementRequest;

  /// No description provided for @pendingClearance.
  ///
  /// In en, this message translates to:
  /// **'Pending clearance'**
  String get pendingClearance;

  /// No description provided for @requestSettlement.
  ///
  /// In en, this message translates to:
  /// **'Request Settlement'**
  String get requestSettlement;

  /// No description provided for @commissionPayable.
  ///
  /// In en, this message translates to:
  /// **'Commission payable'**
  String get commissionPayable;

  /// No description provided for @payCommission.
  ///
  /// In en, this message translates to:
  /// **'Pay Commission'**
  String get payCommission;

  /// No description provided for @commissionSettled.
  ///
  /// In en, this message translates to:
  /// **'Commission payment sent to Hamro Futsal for verification.'**
  String get commissionSettled;

  /// No description provided for @noCommissionDue.
  ///
  /// In en, this message translates to:
  /// **'No commission due right now.'**
  String get noCommissionDue;

  /// No description provided for @settlementNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Bank / wallet details, remarks…'**
  String get settlementNoteHint;

  /// No description provided for @settlementRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Settlement request sent to Hamro Futsal for approval.'**
  String get settlementRequestSubmitted;

  /// No description provided for @settlements.
  ///
  /// In en, this message translates to:
  /// **'Settlements'**
  String get settlements;

  /// No description provided for @settlementAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'A settlement is already awaiting approval.'**
  String get settlementAwaitingApproval;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get totalEarned;

  /// No description provided for @totalSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get totalSettled;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @courtStatus.
  ///
  /// In en, this message translates to:
  /// **'Court status'**
  String get courtStatus;

  /// No description provided for @inactiveCourtsAreHiddenFromPlayers.
  ///
  /// In en, this message translates to:
  /// **'Inactive courts are hidden from players.'**
  String get inactiveCourtsAreHiddenFromPlayers;

  /// No description provided for @addANewItemToYourRentalInventory.
  ///
  /// In en, this message translates to:
  /// **'Add a new item to your rental inventory.'**
  String get addANewItemToYourRentalInventory;

  /// No description provided for @addARemarkInvoiceRefEtc.
  ///
  /// In en, this message translates to:
  /// **'Add a remark, invoice ref, etc.'**
  String get addARemarkInvoiceRefEtc;

  /// No description provided for @addCourt.
  ///
  /// In en, this message translates to:
  /// **'Add Court'**
  String get addCourt;

  /// No description provided for @addDate.
  ///
  /// In en, this message translates to:
  /// **'Add Date'**
  String get addDate;

  /// No description provided for @addEquipment.
  ///
  /// In en, this message translates to:
  /// **'Add equipment'**
  String get addEquipment;

  /// No description provided for @addFirstCourt.
  ///
  /// In en, this message translates to:
  /// **'Add First Court'**
  String get addFirstCourt;

  /// No description provided for @addFutsalCourt.
  ///
  /// In en, this message translates to:
  /// **'Add Futsal Court'**
  String get addFutsalCourt;

  /// No description provided for @addImagesOrFilesToYourLibrary.
  ///
  /// In en, this message translates to:
  /// **'Add images or files to your library.'**
  String get addImagesOrFilesToYourLibrary;

  /// No description provided for @addMedia.
  ///
  /// In en, this message translates to:
  /// **'Add Media'**
  String get addMedia;

  /// No description provided for @addMembers.
  ///
  /// In en, this message translates to:
  /// **'Add members'**
  String get addMembers;

  /// No description provided for @addMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Members'**
  String get addMembersTitle;

  /// No description provided for @addNewCourt.
  ///
  /// In en, this message translates to:
  /// **'Add New Court'**
  String get addNewCourt;

  /// No description provided for @addPlayersWithTheirPositionGoalkeeperDefenderMid3034fc58.
  ///
  /// In en, this message translates to:
  /// **'Add players with their position — goalkeeper, defender, midfielder or forward.'**
  String get addPlayersWithTheirPositionGoalkeeperDefenderMid3034fc58;

  /// No description provided for @addSlot.
  ///
  /// In en, this message translates to:
  /// **'Add Slot'**
  String get addSlot;

  /// No description provided for @addVenueLevelGalleryImagesForYourBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'Add venue-level gallery images for your business profile.'**
  String get addVenueLevelGalleryImagesForYourBusinessProfile;

  /// No description provided for @addYourFirstCourtAndStartAcceptingBookings.
  ///
  /// In en, this message translates to:
  /// **'Add your first court and start accepting bookings.'**
  String get addYourFirstCourtAndStartAcceptingBookings;

  /// No description provided for @addYourFirstCourtToContinueSetup.
  ///
  /// In en, this message translates to:
  /// **'Add your first court to continue setup.'**
  String get addYourFirstCourtToContinueSetup;

  /// No description provided for @addressAndMapCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Address and map coordinates'**
  String get addressAndMapCoordinates;

  /// No description provided for @addressExactLocationLongitudeAndLatitude.
  ///
  /// In en, this message translates to:
  /// **'Address, exact location, longitude, and latitude.'**
  String get addressExactLocationLongitudeAndLatitude;

  /// No description provided for @advance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advance;

  /// No description provided for @advancePayment.
  ///
  /// In en, this message translates to:
  /// **'Advance Payment'**
  String get advancePayment;

  /// No description provided for @advancePaymentRequired.
  ///
  /// In en, this message translates to:
  /// **'Advance payment required'**
  String get advancePaymentRequired;

  /// No description provided for @advancePaymentRequirementsAndQr.
  ///
  /// In en, this message translates to:
  /// **'Advance payment requirements and QR.'**
  String get advancePaymentRequirementsAndQr;

  /// No description provided for @advancePaymentType.
  ///
  /// In en, this message translates to:
  /// **'Advance payment type'**
  String get advancePaymentType;

  /// No description provided for @advanceToPay.
  ///
  /// In en, this message translates to:
  /// **'Advance to pay'**
  String get advanceToPay;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @allSlots.
  ///
  /// In en, this message translates to:
  /// **'All slots'**
  String get allSlots;

  /// No description provided for @allVenues.
  ///
  /// In en, this message translates to:
  /// **'All venues'**
  String get allVenues;

  /// No description provided for @allowCancellations.
  ///
  /// In en, this message translates to:
  /// **'Allow cancellations'**
  String get allowCancellations;

  /// No description provided for @alwaysImproving.
  ///
  /// In en, this message translates to:
  /// **'Always Improving'**
  String get alwaysImproving;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @amenitiesAndFacilities.
  ///
  /// In en, this message translates to:
  /// **'Amenities & Facilities'**
  String get amenitiesAndFacilities;

  /// No description provided for @amenitiesAndFeatures.
  ///
  /// In en, this message translates to:
  /// **'Amenities & Features'**
  String get amenitiesAndFeatures;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @appDisplayLanguage.
  ///
  /// In en, this message translates to:
  /// **'App display language'**
  String get appDisplayLanguage;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @chooseCalendar.
  ///
  /// In en, this message translates to:
  /// **'Choose calendar'**
  String get chooseCalendar;

  /// No description provided for @englishCalendar.
  ///
  /// In en, this message translates to:
  /// **'English Calendar'**
  String get englishCalendar;

  /// No description provided for @nepaliCalendar.
  ///
  /// In en, this message translates to:
  /// **'Nepali Calendar'**
  String get nepaliCalendar;

  /// No description provided for @nepaliDateScript.
  ///
  /// In en, this message translates to:
  /// **'Nepali date script'**
  String get nepaliDateScript;

  /// No description provided for @nepaliDateScriptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How Nepali calendar dates are written'**
  String get nepaliDateScriptSubtitle;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply filter'**
  String get applyFilter;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @areaLandmarkOrStreetName.
  ///
  /// In en, this message translates to:
  /// **'Area, landmark, or street name'**
  String get areaLandmarkOrStreetName;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @attachFiles.
  ///
  /// In en, this message translates to:
  /// **'Attach files'**
  String get attachFiles;

  /// No description provided for @autoFilled.
  ///
  /// In en, this message translates to:
  /// **'Auto-filled'**
  String get autoFilled;

  /// No description provided for @autoGenerateFromFutsalName.
  ///
  /// In en, this message translates to:
  /// **'Auto generate from futsal name'**
  String get autoGenerateFromFutsalName;

  /// No description provided for @availabilityCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Availability check failed'**
  String get availabilityCheckFailed;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @availableCourts.
  ///
  /// In en, this message translates to:
  /// **'Available Courts'**
  String get availableCourts;

  /// No description provided for @availableOffers.
  ///
  /// In en, this message translates to:
  /// **'Available offers'**
  String get availableOffers;

  /// No description provided for @avgDay.
  ///
  /// In en, this message translates to:
  /// **'Avg / day'**
  String get avgDay;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get backgroundColor;

  /// No description provided for @balanceDueLater.
  ///
  /// In en, this message translates to:
  /// **'Balance due later'**
  String get balanceDueLater;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance due'**
  String get balanceDue;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid amount'**
  String get paidAmount;

  /// No description provided for @settlement.
  ///
  /// In en, this message translates to:
  /// **'Settlement'**
  String get settlement;

  /// No description provided for @requestedAmount.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requestedAmount;

  /// No description provided for @stillClearing.
  ///
  /// In en, this message translates to:
  /// **'still clearing'**
  String get stillClearing;

  /// No description provided for @requestedOn.
  ///
  /// In en, this message translates to:
  /// **'Requested on'**
  String get requestedOn;

  /// No description provided for @paidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get paidOn;

  /// No description provided for @updatedOn.
  ///
  /// In en, this message translates to:
  /// **'Updated on'**
  String get updatedOn;

  /// No description provided for @maximumPayable.
  ///
  /// In en, this message translates to:
  /// **'Maximum payable'**
  String get maximumPayable;

  /// No description provided for @singleVenue.
  ///
  /// In en, this message translates to:
  /// **'Single venue'**
  String get singleVenue;

  /// No description provided for @viewPaymentProof.
  ///
  /// In en, this message translates to:
  /// **'View payment proof'**
  String get viewPaymentProof;

  /// No description provided for @viewProof.
  ///
  /// In en, this message translates to:
  /// **'View proof'**
  String get viewProof;

  /// No description provided for @approvedAmount.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approvedAmount;

  /// No description provided for @txnShort.
  ///
  /// In en, this message translates to:
  /// **'Txn'**
  String get txnShort;

  /// No description provided for @transactionReferenceCopied.
  ///
  /// In en, this message translates to:
  /// **'Transaction reference copied.'**
  String get transactionReferenceCopied;

  /// No description provided for @balancedPackageForActiveFutsalOperations.
  ///
  /// In en, this message translates to:
  /// **'Balanced package for active futsal operations.'**
  String get balancedPackageForActiveFutsalOperations;

  /// No description provided for @basePrice.
  ///
  /// In en, this message translates to:
  /// **'Base price'**
  String get basePrice;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @basicPrice.
  ///
  /// In en, this message translates to:
  /// **'Basic Price'**
  String get basicPrice;

  /// No description provided for @bestForASingleVenueGettingOnline.
  ///
  /// In en, this message translates to:
  /// **'Best for a single venue getting online.'**
  String get bestForASingleVenueGettingOnline;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @bookCourtsManageMatchesAndKeepYourFutsalPlansMov11f51a89.
  ///
  /// In en, this message translates to:
  /// **'Book courts, manage matches, and keep your futsal plans moving without the back-and-forth.'**
  String get bookCourtsManageMatchesAndKeepYourFutsalPlansMov11f51a89;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @bookingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Your booking is completed'**
  String get bookingCompleted;

  /// No description provided for @bookingCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'The court is held for your match. Continue to set the cost split.'**
  String get bookingCompletedMessage;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @bookedVia.
  ///
  /// In en, this message translates to:
  /// **'Booked via'**
  String get bookedVia;

  /// No description provided for @booking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// No description provided for @manualBooking.
  ///
  /// In en, this message translates to:
  /// **'Manual Booking'**
  String get manualBooking;

  /// No description provided for @bookingTypeManual.
  ///
  /// In en, this message translates to:
  /// **'Walk-in'**
  String get bookingTypeManual;

  /// No description provided for @bookingTypeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get bookingTypeOnline;

  /// No description provided for @bookingUnitSuffix.
  ///
  /// In en, this message translates to:
  /// **' / booking'**
  String get bookingUnitSuffix;

  /// No description provided for @bookingAlerts.
  ///
  /// In en, this message translates to:
  /// **'Booking Alerts'**
  String get bookingAlerts;

  /// No description provided for @bookingAndCancellationTerms.
  ///
  /// In en, this message translates to:
  /// **'Booking and cancellation terms'**
  String get bookingAndCancellationTerms;

  /// No description provided for @bookingAndPayment.
  ///
  /// In en, this message translates to:
  /// **'Booking & Payment'**
  String get bookingAndPayment;

  /// No description provided for @bookingAndPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking and Payment'**
  String get bookingAndPaymentTitle;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// No description provided for @bookingFee.
  ///
  /// In en, this message translates to:
  /// **'Booking Fee'**
  String get bookingFee;

  /// No description provided for @bookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get bookingId;

  /// No description provided for @bookingOverview.
  ///
  /// In en, this message translates to:
  /// **'Booking Overview'**
  String get bookingOverview;

  /// No description provided for @bookingPolicies.
  ///
  /// In en, this message translates to:
  /// **'Booking Policies'**
  String get bookingPolicies;

  /// No description provided for @bookingRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Booking request sent'**
  String get bookingRequestSent;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @bookingsRemainOpenAndHolidayPricingCanApply.
  ///
  /// In en, this message translates to:
  /// **'Bookings remain open and holiday pricing can apply.'**
  String get bookingsRemainOpenAndHolidayPricingCanApply;

  /// No description provided for @branding.
  ///
  /// In en, this message translates to:
  /// **'Branding'**
  String get branding;

  /// No description provided for @brandingAndReview.
  ///
  /// In en, this message translates to:
  /// **'Branding & Review'**
  String get brandingAndReview;

  /// No description provided for @bulletList.
  ///
  /// In en, this message translates to:
  /// **'Bullet List'**
  String get bulletList;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @businessAndRegistration.
  ///
  /// In en, this message translates to:
  /// **'Business & Registration'**
  String get businessAndRegistration;

  /// No description provided for @businessAssets.
  ///
  /// In en, this message translates to:
  /// **'Business Assets'**
  String get businessAssets;

  /// No description provided for @calculatingPrice.
  ///
  /// In en, this message translates to:
  /// **'Calculating price…'**
  String get calculatingPrice;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @canWeRescheduleTonightSBooking.
  ///
  /// In en, this message translates to:
  /// **'Can we reschedule tonight’s booking?'**
  String get canWeRescheduleTonightSBooking;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBooking;

  /// No description provided for @cancelBookingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking? This cannot be undone.'**
  String get cancelBookingConfirmation;

  /// No description provided for @keepBooking.
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get keepBooking;

  /// No description provided for @bookingCancelledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your booking has been cancelled.'**
  String get bookingCancelledSuccessfully;

  /// No description provided for @couldNotCancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel the booking. Please try again.'**
  String get couldNotCancelBooking;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @groupInvitation.
  ///
  /// In en, this message translates to:
  /// **'Group invitation'**
  String get groupInvitation;

  /// No description provided for @groupInvitationPrompt.
  ///
  /// In en, this message translates to:
  /// **'You have been invited to join this group.'**
  String get groupInvitationPrompt;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @cats.
  ///
  /// In en, this message translates to:
  /// **'cats'**
  String get cats;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get changeImage;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @changeServicePlan.
  ///
  /// In en, this message translates to:
  /// **'Change service plan?'**
  String get changeServicePlan;

  /// No description provided for @changeServicePlanConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to change your service plan? Your commission rate will be updated to the new plan.'**
  String get changeServicePlanConfirmation;

  /// No description provided for @charge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get charge;

  /// No description provided for @chargePerUnitPerHour.
  ///
  /// In en, this message translates to:
  /// **'Charge per unit per hour'**
  String get chargePerUnitPerHour;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @chatWithCustomer.
  ///
  /// In en, this message translates to:
  /// **'Chat with customer'**
  String get chatWithCustomer;

  /// No description provided for @chatWithHost.
  ///
  /// In en, this message translates to:
  /// **'Chat with host'**
  String get chatWithHost;

  /// No description provided for @messageHost.
  ///
  /// In en, this message translates to:
  /// **'Message host'**
  String get messageHost;

  /// No description provided for @chatWithVenue.
  ///
  /// In en, this message translates to:
  /// **'Chat with venue'**
  String get chatWithVenue;

  /// No description provided for @cannotChatWithYourself.
  ///
  /// In en, this message translates to:
  /// **'You cannot start a conversation with yourself.'**
  String get cannotChatWithYourself;

  /// No description provided for @checkYourConnectionAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get checkYourConnectionAndTryAgain;

  /// No description provided for @checkYourInboxAndSpamFolder.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox and spam folder.'**
  String get checkYourInboxAndSpamFolder;

  /// No description provided for @chooseASavedImageOrUploadANewOne.
  ///
  /// In en, this message translates to:
  /// **'Choose a saved image or upload a new one.'**
  String get chooseASavedImageOrUploadANewOne;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get chooseFile;

  /// No description provided for @choosePackage.
  ///
  /// In en, this message translates to:
  /// **'Choose Package'**
  String get choosePackage;

  /// No description provided for @chooseThePackageThatMatchesYourCurrentStageAndOp2398b90f.
  ///
  /// In en, this message translates to:
  /// **'Choose the package that matches your current stage and operational needs.'**
  String get chooseThePackageThatMatchesYourCurrentStageAndOp2398b90f;

  /// No description provided for @chooseVenue.
  ///
  /// In en, this message translates to:
  /// **'Choose venue'**
  String get chooseVenue;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @clearFormat.
  ///
  /// In en, this message translates to:
  /// **'Clear Format'**
  String get clearFormat;

  /// No description provided for @clearInfoWhenYouNeedIt.
  ///
  /// In en, this message translates to:
  /// **'Clear info when you need it.'**
  String get clearInfoWhenYouNeedIt;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @closeAFullDayOrOnlyASpecificHourRange.
  ///
  /// In en, this message translates to:
  /// **'Close a full day or only a specific hour range.'**
  String get closeAFullDayOrOnlyASpecificHourRange;

  /// No description provided for @closedAcceptWindowExpired.
  ///
  /// In en, this message translates to:
  /// **'Closed — accept window expired'**
  String get closedAcceptWindowExpired;

  /// No description provided for @closedDate.
  ///
  /// In en, this message translates to:
  /// **'Closed date'**
  String get closedDate;

  /// No description provided for @closedDates.
  ///
  /// In en, this message translates to:
  /// **'Closed dates'**
  String get closedDates;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @collectNow.
  ///
  /// In en, this message translates to:
  /// **'Collect now'**
  String get collectNow;

  /// No description provided for @collectPaymentOrDepositBeforeABookingIsConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Collect payment or deposit before a booking is confirmed.'**
  String get collectPaymentOrDepositBeforeABookingIsConfirmed;

  /// No description provided for @commissionPackageAndPlatformSupportDetails.
  ///
  /// In en, this message translates to:
  /// **'Commission package and platform support details'**
  String get commissionPackageAndPlatformSupportDetails;

  /// No description provided for @commissions.
  ///
  /// In en, this message translates to:
  /// **'Commissions'**
  String get commissions;

  /// No description provided for @companyDocs.
  ///
  /// In en, this message translates to:
  /// **'Company Docs'**
  String get companyDocs;

  /// No description provided for @companyDocuments.
  ///
  /// In en, this message translates to:
  /// **'Company documents'**
  String get companyDocuments;

  /// No description provided for @completeCourtDetails.
  ///
  /// In en, this message translates to:
  /// **'Complete court details'**
  String get completeCourtDetails;

  /// No description provided for @completeTheRequiredDetails.
  ///
  /// In en, this message translates to:
  /// **'Complete the required details'**
  String get completeTheRequiredDetails;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @configureDateAndTimeSlots.
  ///
  /// In en, this message translates to:
  /// **'Configure date and time slots.'**
  String get configureDateAndTimeSlots;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @connectThisGroupToAVenue.
  ///
  /// In en, this message translates to:
  /// **'Connect this group to a venue'**
  String get connectThisGroupToAVenue;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @conversationSettings.
  ///
  /// In en, this message translates to:
  /// **'Conversation settings'**
  String get conversationSettings;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @couldNotApplyTheCouponPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not apply the coupon. Please try again.'**
  String get couldNotApplyTheCouponPleaseTryAgain;

  /// No description provided for @couldNotCheckAvailabilityPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not check availability. Please try again.'**
  String get couldNotCheckAvailabilityPleaseTryAgain;

  /// No description provided for @couldNotGetAppleCredentialsPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not get Apple credentials. Please try again.'**
  String get couldNotGetAppleCredentialsPleaseTryAgain;

  /// No description provided for @couldNotGetGoogleCredentialsPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not get Google credentials. Please try again.'**
  String get couldNotGetGoogleCredentialsPleaseTryAgain;

  /// No description provided for @couldNotHoldThisSlotPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not hold this slot. Please try again.'**
  String get couldNotHoldThisSlotPleaseTryAgain;

  /// No description provided for @couldNotIdentifyThisCourt.
  ///
  /// In en, this message translates to:
  /// **'Could not identify this court.'**
  String get couldNotIdentifyThisCourt;

  /// No description provided for @couldNotLoadBookings.
  ///
  /// In en, this message translates to:
  /// **'Could not load bookings.'**
  String get couldNotLoadBookings;

  /// No description provided for @exportBookings.
  ///
  /// In en, this message translates to:
  /// **'Export bookings'**
  String get exportBookings;

  /// No description provided for @exportingBookings.
  ///
  /// In en, this message translates to:
  /// **'Preparing your export…'**
  String get exportingBookings;

  /// No description provided for @couldNotExportBookings.
  ///
  /// In en, this message translates to:
  /// **'Could not export bookings. Please try again.'**
  String get couldNotExportBookings;

  /// No description provided for @noBookingsToExport.
  ///
  /// In en, this message translates to:
  /// **'There are no bookings to export for these filters.'**
  String get noBookingsToExport;

  /// No description provided for @exportedBookings.
  ///
  /// In en, this message translates to:
  /// **'Exported Bookings'**
  String get exportedBookings;

  /// No description provided for @exportDownloadedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking overview downloaded successfully'**
  String get exportDownloadedTitle;

  /// No description provided for @exportReadyToView.
  ///
  /// In en, this message translates to:
  /// **'Your export is saved to your device and ready to view.'**
  String get exportReadyToView;

  /// No description provided for @viewExport.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewExport;

  /// No description provided for @exportSavedInDownloads.
  ///
  /// In en, this message translates to:
  /// **'Saved in Downloads'**
  String get exportSavedInDownloads;

  /// No description provided for @exportSavedInFiles.
  ///
  /// In en, this message translates to:
  /// **'Saved in the Files app'**
  String get exportSavedInFiles;

  /// No description provided for @couldNotOpenExport.
  ///
  /// In en, this message translates to:
  /// **'No app found to open this file. Install Excel or Google Sheets to view it.'**
  String get couldNotOpenExport;

  /// No description provided for @shareFile.
  ///
  /// In en, this message translates to:
  /// **'Share file'**
  String get shareFile;

  /// No description provided for @couldNotLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Could not load categories.'**
  String get couldNotLoadCategories;

  /// No description provided for @couldNotLoadSavedAuthenticationDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not load saved authentication details.'**
  String get couldNotLoadSavedAuthenticationDetails;

  /// No description provided for @couldNotLoadVenues.
  ///
  /// In en, this message translates to:
  /// **'Could not load venues.'**
  String get couldNotLoadVenues;

  /// No description provided for @couldNotParseAmenitiesAndFacilitiesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse amenities and facilities from server.'**
  String get couldNotParseAmenitiesAndFacilitiesFromServer;

  /// No description provided for @couldNotParseAmenitiesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse amenities from server.'**
  String get couldNotParseAmenitiesFromServer;

  /// No description provided for @couldNotParseAvailableCourtsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse available courts from server.'**
  String get couldNotParseAvailableCourtsFromServer;

  /// No description provided for @couldNotParseBookingDetailsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse booking details from server.'**
  String get couldNotParseBookingDetailsFromServer;

  /// No description provided for @couldNotParseBookingsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse bookings from server.'**
  String get couldNotParseBookingsFromServer;

  /// No description provided for @couldNotParseCategoryFiltersFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse category filters from server.'**
  String get couldNotParseCategoryFiltersFromServer;

  /// No description provided for @couldNotParseCouponsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse coupons from server.'**
  String get couldNotParseCouponsFromServer;

  /// No description provided for @couldNotParseMobileBannersFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse banners from server.'**
  String get couldNotParseMobileBannersFromServer;

  /// No description provided for @couldNotParseNotificationsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse notifications from server.'**
  String get couldNotParseNotificationsFromServer;

  /// No description provided for @couldNotLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications.'**
  String get couldNotLoadNotifications;

  /// No description provided for @couldNotParseCourtDetailsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse court details from server.'**
  String get couldNotParseCourtDetailsFromServer;

  /// No description provided for @couldNotParseCourtTypesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse court types from server.'**
  String get couldNotParseCourtTypesFromServer;

  /// No description provided for @couldNotParseCreatedMediaItemsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse created media items from server.'**
  String get couldNotParseCreatedMediaItemsFromServer;

  /// No description provided for @couldNotParseExpenseCategoriesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse expense categories from server.'**
  String get couldNotParseExpenseCategoriesFromServer;

  /// No description provided for @couldNotParseExpensesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse expenses from server.'**
  String get couldNotParseExpensesFromServer;

  /// No description provided for @couldNotParseFacilitiesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse facilities from server.'**
  String get couldNotParseFacilitiesFromServer;

  /// No description provided for @couldNotParseFaqsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse FAQs from server.'**
  String get couldNotParseFaqsFromServer;

  /// No description provided for @couldNotParseFutsalBookingsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse futsal bookings from server.'**
  String get couldNotParseFutsalBookingsFromServer;

  /// No description provided for @couldNotParseHelpTopicsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse help topics from server.'**
  String get couldNotParseHelpTopicsFromServer;

  /// No description provided for @couldNotParseHostDetailsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse host details from server.'**
  String get couldNotParseHostDetailsFromServer;

  /// No description provided for @couldNotParseMatchFormatsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse match formats from server.'**
  String get couldNotParseMatchFormatsFromServer;

  /// No description provided for @couldNotParseMediaListFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse media list from server.'**
  String get couldNotParseMediaListFromServer;

  /// No description provided for @couldNotParseReviewsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse reviews from server.'**
  String get couldNotParseReviewsFromServer;

  /// No description provided for @couldNotParsePaymentQrFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse payment QR from server.'**
  String get couldNotParsePaymentQrFromServer;

  /// No description provided for @couldNotParsePublicPackagesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse public packages from server.'**
  String get couldNotParsePublicPackagesFromServer;

  /// No description provided for @couldNotParsePublicServicesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse public services from server.'**
  String get couldNotParsePublicServicesFromServer;

  /// No description provided for @couldNotParsePublicTemplatesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse public templates from server.'**
  String get couldNotParsePublicTemplatesFromServer;

  /// No description provided for @couldNotParseVenueCourtsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse venue courts from server.'**
  String get couldNotParseVenueCourtsFromServer;

  /// No description provided for @couldNotParseVenueDescriptionFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse venue description from server.'**
  String get couldNotParseVenueDescriptionFromServer;

  /// No description provided for @couldNotParseVenueSlotsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse venue slots from server.'**
  String get couldNotParseVenueSlotsFromServer;

  /// No description provided for @couldNotParseVenuesAndCourtsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse venues and courts from server.'**
  String get couldNotParseVenuesAndCourtsFromServer;

  /// No description provided for @couldNotParseVenuesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse venues from server.'**
  String get couldNotParseVenuesFromServer;

  /// No description provided for @couldNotParseYourWishlistFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse your wishlist from server.'**
  String get couldNotParseYourWishlistFromServer;

  /// No description provided for @couldNotSaveTheExpense.
  ///
  /// In en, this message translates to:
  /// **'Could not save the expense.'**
  String get couldNotSaveTheExpense;

  /// No description provided for @couldNotSendOtpPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not send the OTP. Please try again.'**
  String get couldNotSendOtpPleaseTryAgain;

  /// No description provided for @otpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully. Check your email.'**
  String get otpSentSuccessfully;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @codeVerifiedChooseANewPassword.
  ///
  /// In en, this message translates to:
  /// **'Code verified. Choose a new password.'**
  String get codeVerifiedChooseANewPassword;

  /// No description provided for @court.
  ///
  /// In en, this message translates to:
  /// **'Court'**
  String get court;

  /// No description provided for @couldNotParsePrefix.
  ///
  /// In en, this message translates to:
  /// **'Could not parse '**
  String get couldNotParsePrefix;

  /// No description provided for @courtActions.
  ///
  /// In en, this message translates to:
  /// **'Court actions'**
  String get courtActions;

  /// No description provided for @courtIdentityDescriptionPhotosAndMemories.
  ///
  /// In en, this message translates to:
  /// **'Court identity, description, photos, and memories.'**
  String get courtIdentityDescriptionPhotosAndMemories;

  /// No description provided for @courtIdentityPricingTypeAndPlayingFormat.
  ///
  /// In en, this message translates to:
  /// **'Court identity, pricing, type, and playing format'**
  String get courtIdentityPricingTypeAndPlayingFormat;

  /// No description provided for @courtInfo.
  ///
  /// In en, this message translates to:
  /// **'Court Info'**
  String get courtInfo;

  /// No description provided for @courtInformation.
  ///
  /// In en, this message translates to:
  /// **'Court Information'**
  String get courtInformation;

  /// No description provided for @courtName.
  ///
  /// In en, this message translates to:
  /// **'Court name'**
  String get courtName;

  /// No description provided for @courtNotFound.
  ///
  /// In en, this message translates to:
  /// **'Court not found.'**
  String get courtNotFound;

  /// No description provided for @courtPhotos.
  ///
  /// In en, this message translates to:
  /// **'Court photos'**
  String get courtPhotos;

  /// No description provided for @courtPhotosAndMemories.
  ///
  /// In en, this message translates to:
  /// **'Court photos and memories.'**
  String get courtPhotosAndMemories;

  /// No description provided for @courtPhotosAndMemoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Court photos and memories'**
  String get courtPhotosAndMemoriesLabel;

  /// No description provided for @courtRules.
  ///
  /// In en, this message translates to:
  /// **'Court Rules'**
  String get courtRules;

  /// No description provided for @courtSetup.
  ///
  /// In en, this message translates to:
  /// **'Court Setup'**
  String get courtSetup;

  /// No description provided for @courtSpecificAmenitiesAndFacilities.
  ///
  /// In en, this message translates to:
  /// **'Court-specific amenities and facilities.'**
  String get courtSpecificAmenitiesAndFacilities;

  /// No description provided for @courtSpecificAmenitiesForThisCourt.
  ///
  /// In en, this message translates to:
  /// **'Court-specific amenities for this court.'**
  String get courtSpecificAmenitiesForThisCourt;

  /// No description provided for @courtType.
  ///
  /// In en, this message translates to:
  /// **'Court Type'**
  String get courtType;

  /// No description provided for @courtTypeSentenceCase.
  ///
  /// In en, this message translates to:
  /// **'Court type'**
  String get courtTypeSentenceCase;

  /// No description provided for @courts.
  ///
  /// In en, this message translates to:
  /// **'Courts'**
  String get courts;

  /// No description provided for @coverImage.
  ///
  /// In en, this message translates to:
  /// **'Cover Image'**
  String get coverImage;

  /// No description provided for @coverImageSentenceCase.
  ///
  /// In en, this message translates to:
  /// **'Cover image'**
  String get coverImageSentenceCase;

  /// No description provided for @coverMediaGalleryAndBusinessDocuments.
  ///
  /// In en, this message translates to:
  /// **'Cover media, gallery, and business documents.'**
  String get coverMediaGalleryAndBusinessDocuments;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @createReusableBookingSlotsWithDaysAndTimes.
  ///
  /// In en, this message translates to:
  /// **'Create reusable booking slots with days and times'**
  String get createReusableBookingSlotsWithDaysAndTimes;

  /// No description provided for @createShopPayload.
  ///
  /// In en, this message translates to:
  /// **'Create Shop Payload'**
  String get createShopPayload;

  /// No description provided for @createTeam.
  ///
  /// In en, this message translates to:
  /// **'Create Team'**
  String get createTeam;

  /// No description provided for @customDatePrice.
  ///
  /// In en, this message translates to:
  /// **'Custom date price'**
  String get customDatePrice;

  /// No description provided for @customDatePrices.
  ///
  /// In en, this message translates to:
  /// **'Custom date prices'**
  String get customDatePrices;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get customRange;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @dateOrder.
  ///
  /// In en, this message translates to:
  /// **'Date order'**
  String get dateOrder;

  /// No description provided for @defineBookingRulesPaymentsAndVenueHousePolicies.
  ///
  /// In en, this message translates to:
  /// **'Define booking rules, payments, and venue house policies.'**
  String get defineBookingRulesPaymentsAndVenueHousePolicies;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountPrompt;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Everything below is removed for good.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountLosesProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile, login and biometric access'**
  String get deleteAccountLosesProfile;

  /// No description provided for @deleteAccountLosesBookings.
  ///
  /// In en, this message translates to:
  /// **'Your bookings and payment history'**
  String get deleteAccountLosesBookings;

  /// No description provided for @deleteAccountLosesTeams.
  ///
  /// In en, this message translates to:
  /// **'Your teams and opponent requests'**
  String get deleteAccountLosesTeams;

  /// No description provided for @deleteAccountConfirmationWord.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteAccountConfirmationWord;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and data'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for deletion'**
  String get deleteAccountReason;

  /// No description provided for @deleteAccountReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us why you are deleting your account'**
  String get deleteAccountReasonHint;

  /// No description provided for @deleteAccountReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add a reason before deleting your account.'**
  String get deleteAccountReasonRequired;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted'**
  String get accountDeleted;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account…'**
  String get deletingAccount;

  /// No description provided for @deleteCourt.
  ///
  /// In en, this message translates to:
  /// **'Delete Court'**
  String get deleteCourt;

  /// No description provided for @deleteCourtPrompt.
  ///
  /// In en, this message translates to:
  /// **'Delete Court?'**
  String get deleteCourtPrompt;

  /// No description provided for @deleteFile.
  ///
  /// In en, this message translates to:
  /// **'Delete File?'**
  String get deleteFile;

  /// No description provided for @deleteFutsal.
  ///
  /// In en, this message translates to:
  /// **'Delete Futsal'**
  String get deleteFutsal;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete message?'**
  String get deleteMessage;

  /// No description provided for @deleteMessageAction.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get deleteMessageAction;

  /// No description provided for @deleteSlot.
  ///
  /// In en, this message translates to:
  /// **'Delete Slot'**
  String get deleteSlot;

  /// No description provided for @deleteTeam.
  ///
  /// In en, this message translates to:
  /// **'Delete team?'**
  String get deleteTeam;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @depositRefundable.
  ///
  /// In en, this message translates to:
  /// **'Deposit (refundable)'**
  String get depositRefundable;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @describeYourCancellationAndRefundPolicy.
  ///
  /// In en, this message translates to:
  /// **'Describe your cancellation and refund policy...'**
  String get describeYourCancellationAndRefundPolicy;

  /// No description provided for @describeYourFutsalFacilitiesAndWhatMakesItSpecial.
  ///
  /// In en, this message translates to:
  /// **'Describe your futsal, facilities, and what makes it special.'**
  String get describeYourFutsalFacilitiesAndWhatMakesItSpecial;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionAboutYourCourt.
  ///
  /// In en, this message translates to:
  /// **'Description about your court...'**
  String get descriptionAboutYourCourt;

  /// No description provided for @descriptionAboutYourFutsal.
  ///
  /// In en, this message translates to:
  /// **'Description about your futsal...'**
  String get descriptionAboutYourFutsal;

  /// No description provided for @designedAroundTheWayLocalPlayersActuallyBook.
  ///
  /// In en, this message translates to:
  /// **'Designed around the way local players actually book.'**
  String get designedAroundTheWayLocalPlayersActuallyBook;

  /// No description provided for @digitalProductsForModernSportsBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Digital products for modern sports businesses.'**
  String get digitalProductsForModernSportsBusinesses;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @discountType.
  ///
  /// In en, this message translates to:
  /// **'Discount type'**
  String get discountType;

  /// No description provided for @discounts.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get discounts;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @documentMustBeSmallerThan10Mb.
  ///
  /// In en, this message translates to:
  /// **'Document must be smaller than 10 MB.'**
  String get documentMustBeSmallerThan10Mb;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @dragToReorderFirstImageIsTheCover.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. First image is the cover.'**
  String get dragToReorderFirstImageIsTheCover;

  /// No description provided for @eGCourtAMainField.
  ///
  /// In en, this message translates to:
  /// **'e.g. Court A, Main Field'**
  String get eGCourtAMainField;

  /// No description provided for @eGFootballSize5.
  ///
  /// In en, this message translates to:
  /// **'e.g. Football · size 5'**
  String get eGFootballSize5;

  /// No description provided for @eGMorningSlot.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning Slot'**
  String get eGMorningSlot;

  /// No description provided for @eGTurfRepairMonthlyRent.
  ///
  /// In en, this message translates to:
  /// **'e.g. Turf repair, monthly rent'**
  String get eGTurfRepairMonthlyRent;

  /// No description provided for @eGWeekendFutsalTeam.
  ///
  /// In en, this message translates to:
  /// **'e.g. Weekend Futsal Team'**
  String get eGWeekendFutsalTeam;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'edited · '**
  String get edited;

  /// No description provided for @elite.
  ///
  /// In en, this message translates to:
  /// **'Elite'**
  String get elite;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enableUsersToCancelConfirmedBookingsBeforeMatchDay.
  ///
  /// In en, this message translates to:
  /// **'Enable users to cancel confirmed bookings before match day.'**
  String get enableUsersToCancelConfirmedBookingsBeforeMatchDay;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTime;

  /// No description provided for @enterCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get enterCouponCode;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get enterCurrentPassword;

  /// No description provided for @enterFutsalClubName.
  ///
  /// In en, this message translates to:
  /// **'Enter futsal club name'**
  String get enterFutsalClubName;

  /// No description provided for @enterFutsalRegistrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Futsal registration number'**
  String get enterFutsalRegistrationNumber;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @enterVenueId.
  ///
  /// In en, this message translates to:
  /// **'Enter venue ID'**
  String get enterVenueId;

  /// No description provided for @enterYourAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get enterYourAddress;

  /// No description provided for @enterYourCurrentPasswordAndChooseANewOne.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and choose a new one.'**
  String get enterYourCurrentPasswordAndChooseANewOne;

  /// No description provided for @enterYourEmailAndWeWillSendYouAnOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you an OTP code.'**
  String get enterYourEmailAndWeWillSendYouAnOtpCode;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @entries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get entries;

  /// No description provided for @establishedYear.
  ///
  /// In en, this message translates to:
  /// **'Established Year'**
  String get establishedYear;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @exactLocation.
  ///
  /// In en, this message translates to:
  /// **'Exact Location'**
  String get exactLocation;

  /// No description provided for @exactLocationSentenceCase.
  ///
  /// In en, this message translates to:
  /// **'Exact location'**
  String get exactLocationSentenceCase;

  /// No description provided for @exampleNonMarkingShoesOnlyReport15MinutesEarlyNo3d1a39a7.
  ///
  /// In en, this message translates to:
  /// **'Example: non-marking shoes only, report 15 minutes early, no outside food.'**
  String get exampleNonMarkingShoesOnlyReport15MinutesEarlyNo3d1a39a7;

  /// No description provided for @expenseDate.
  ///
  /// In en, this message translates to:
  /// **'Expense date'**
  String get expenseDate;

  /// No description provided for @expenseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Expense not found.'**
  String get expenseNotFound;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @facilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilities;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @fastBooking.
  ///
  /// In en, this message translates to:
  /// **'Fast Booking'**
  String get fastBooking;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @fetchingYourSavedMediaFromTheServer.
  ///
  /// In en, this message translates to:
  /// **'Fetching your saved media from the server.'**
  String get fetchingYourSavedMediaFromTheServer;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDate;

  /// No description provided for @filterLibrary.
  ///
  /// In en, this message translates to:
  /// **'Filter library'**
  String get filterLibrary;

  /// No description provided for @filtersAndSorting.
  ///
  /// In en, this message translates to:
  /// **'Filters & Sorting'**
  String get filtersAndSorting;

  /// No description provided for @flat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get flat;

  /// No description provided for @forPremiumVenuesAndMultiCourtOperators.
  ///
  /// In en, this message translates to:
  /// **'For premium venues and multi-court operators.'**
  String get forPremiumVenuesAndMultiCourtOperators;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordPrompt;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get fromDate;

  /// No description provided for @fromServerSuffix.
  ///
  /// In en, this message translates to:
  /// **' from server.'**
  String get fromServerSuffix;

  /// No description provided for @fullDay.
  ///
  /// In en, this message translates to:
  /// **'Full day'**
  String get fullDay;

  /// No description provided for @futsal.
  ///
  /// In en, this message translates to:
  /// **'Futsal'**
  String get futsal;

  /// No description provided for @futsalAddress.
  ///
  /// In en, this message translates to:
  /// **'Futsal Address'**
  String get futsalAddress;

  /// No description provided for @futsalBookingSimplified.
  ///
  /// In en, this message translates to:
  /// **'Futsal booking, simplified.'**
  String get futsalBookingSimplified;

  /// No description provided for @futsalBookings.
  ///
  /// In en, this message translates to:
  /// **'Futsal Bookings'**
  String get futsalBookings;

  /// No description provided for @futsalClubName.
  ///
  /// In en, this message translates to:
  /// **'Futsal Club Name'**
  String get futsalClubName;

  /// No description provided for @futsalGmailCom.
  ///
  /// In en, this message translates to:
  /// **'futsal@gmail.com'**
  String get futsalGmailCom;

  /// No description provided for @futsalInformation.
  ///
  /// In en, this message translates to:
  /// **'Futsal Information'**
  String get futsalInformation;

  /// No description provided for @futsalName.
  ///
  /// In en, this message translates to:
  /// **'Futsal Name'**
  String get futsalName;

  /// No description provided for @futsalPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Futsal Portfolio'**
  String get futsalPortfolio;

  /// No description provided for @futsalRules.
  ///
  /// In en, this message translates to:
  /// **'Futsal Rules'**
  String get futsalRules;

  /// No description provided for @futsalSteps.
  ///
  /// In en, this message translates to:
  /// **'Futsal Steps'**
  String get futsalSteps;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @appleSignInFailedPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed. Please try again.'**
  String get appleSignInFailedPleaseTryAgain;

  /// No description provided for @appleSignInIsNotAvailableOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in is not available on this device.'**
  String get appleSignInIsNotAvailableOnThisDevice;

  /// No description provided for @googleSignInFailedPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get googleSignInFailedPleaseTryAgain;

  /// No description provided for @googleSignInIsNotConfiguredMissingGoogleServerClientId.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not configured. Missing GOOGLE_SERVER_CLIENT_ID.'**
  String get googleSignInIsNotConfiguredMissingGoogleServerClientId;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @hamroFutsal.
  ///
  /// In en, this message translates to:
  /// **'Hamro Futsal'**
  String get hamroFutsal;

  /// No description provided for @hamroFutsalIsBuiltToMakeLocalFutsalEasierForPl2dfd0648.
  ///
  /// In en, this message translates to:
  /// **'Hamro Futsal is built to make local futsal easier for players, teams, and venue owners. Discover available courts, compare facilities, and book with confidence.'**
  String get hamroFutsalIsBuiltToMakeLocalFutsalEasierForPl2dfd0648;

  /// No description provided for @hamroFutsalArena.
  ///
  /// In en, this message translates to:
  /// **'Hamro Futsal Arena'**
  String get hamroFutsalArena;

  /// No description provided for @hamroFutsalArenaSlugExample.
  ///
  /// In en, this message translates to:
  /// **'hamro-futsal-arena'**
  String get hamroFutsalArenaSlugExample;

  /// No description provided for @hamroFutsalV100.
  ///
  /// In en, this message translates to:
  /// **'Hamro Futsal · v1.0.0'**
  String get hamroFutsalV100;

  /// No description provided for @handOverEquipmentAndStartARentalTimer.
  ///
  /// In en, this message translates to:
  /// **'Hand over equipment and start a rental timer.'**
  String get handOverEquipmentAndStartARentalTimer;

  /// No description provided for @helloHamrofutsalCom.
  ///
  /// In en, this message translates to:
  /// **'hello@hamrofutsal.com'**
  String get helloHamrofutsalCom;

  /// No description provided for @helloSirGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Hello sir, good morning.'**
  String get helloSirGoodMorning;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpAndFaq.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpAndFaq;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @helpfulSupport.
  ///
  /// In en, this message translates to:
  /// **'Helpful Support'**
  String get helpfulSupport;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what worked well and where we can improve the platform or services.'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackType.
  ///
  /// In en, this message translates to:
  /// **'Feedback type'**
  String get feedbackType;

  /// No description provided for @feedbackCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get feedbackCategory;

  /// No description provided for @feedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Your feedback'**
  String get feedbackMessage;

  /// No description provided for @feedbackContact.
  ///
  /// In en, this message translates to:
  /// **'Contact number or email (optional)'**
  String get feedbackContact;

  /// No description provided for @feedbackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thanks for sharing your feedback. We have received it successfully.'**
  String get feedbackSuccess;

  /// No description provided for @feedbackPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get feedbackPlatform;

  /// No description provided for @feedbackServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get feedbackServices;

  /// No description provided for @feedbackBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get feedbackBoth;

  /// No description provided for @feedbackBug.
  ///
  /// In en, this message translates to:
  /// **'Bug / issue'**
  String get feedbackBug;

  /// No description provided for @feedbackSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get feedbackSuggestion;

  /// No description provided for @feedbackPraise.
  ///
  /// In en, this message translates to:
  /// **'Appreciation'**
  String get feedbackPraise;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit feedback'**
  String get submitFeedback;

  /// No description provided for @feedbackHelpNote.
  ///
  /// In en, this message translates to:
  /// **'Your response helps us improve the app experience, support flow, and service quality.'**
  String get feedbackHelpNote;

  /// No description provided for @highlightTheServicesAndOnSiteFacilitiesYourVenueOffers.
  ///
  /// In en, this message translates to:
  /// **'Highlight the services and on-site facilities your venue offers.'**
  String get highlightTheServicesAndOnSiteFacilitiesYourVenueOffers;

  /// No description provided for @highlightWhatYourFutsalOffers.
  ///
  /// In en, this message translates to:
  /// **'Highlight what your futsal offers'**
  String get highlightWhatYourFutsalOffers;

  /// No description provided for @holidayDates.
  ///
  /// In en, this message translates to:
  /// **'Holiday dates'**
  String get holidayDates;

  /// No description provided for @holidayPrice.
  ///
  /// In en, this message translates to:
  /// **'Holiday price'**
  String get holidayPrice;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @hostedBy.
  ///
  /// In en, this message translates to:
  /// **'Hosted By'**
  String get hostedBy;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @hourLowercase.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hourLowercase;

  /// No description provided for @perHourSuffix.
  ///
  /// In en, this message translates to:
  /// **'/ hour'**
  String get perHourSuffix;

  /// No description provided for @hourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourly;

  /// No description provided for @hoursPlayed.
  ///
  /// In en, this message translates to:
  /// **'Hours played'**
  String get hoursPlayed;

  /// No description provided for @houseRulesForPlayersAndBookings.
  ///
  /// In en, this message translates to:
  /// **'House rules for players and bookings.'**
  String get houseRulesForPlayersAndBookings;

  /// No description provided for @howRefundsAndCancellationsAreHandled.
  ///
  /// In en, this message translates to:
  /// **'How refunds and cancellations are handled.'**
  String get howRefundsAndCancellationsAreHandled;

  /// No description provided for @iAgreeToTheTermsAndPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Privacy Policy.'**
  String get iAgreeToTheTermsAndPrivacyPolicy;

  /// No description provided for @iConfirmTheBookingDetailsAreCorrectAndAcceptTheCabab03b.
  ///
  /// In en, this message translates to:
  /// **'I confirm the booking details are correct and accept the cancellation & refund policy.'**
  String get iConfirmTheBookingDetailsAreCorrectAndAcceptTheCabab03b;

  /// No description provided for @iSawTheFutsalSlotYouPostedYesterday.
  ///
  /// In en, this message translates to:
  /// **'I saw the futsal slot you posted yesterday.'**
  String get iSawTheFutsalSlotYouPostedYesterday;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'IMAGE'**
  String get image;

  /// No description provided for @importantNote.
  ///
  /// In en, this message translates to:
  /// **'Important note'**
  String get importantNote;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @insert.
  ///
  /// In en, this message translates to:
  /// **'Insert'**
  String get insert;

  /// No description provided for @insertLink.
  ///
  /// In en, this message translates to:
  /// **'Insert Link'**
  String get insertLink;

  /// No description provided for @invalidAuthenticationResponseFromServer.
  ///
  /// In en, this message translates to:
  /// **'Invalid authentication response from server.'**
  String get invalidAuthenticationResponseFromServer;

  /// No description provided for @invalidCreateFutsalResponseFromServer.
  ///
  /// In en, this message translates to:
  /// **'Invalid create futsal response from server.'**
  String get invalidCreateFutsalResponseFromServer;

  /// No description provided for @invalidProfileResponseFromServer.
  ///
  /// In en, this message translates to:
  /// **'Invalid profile response from server.'**
  String get invalidProfileResponseFromServer;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @jpgPngOrPdfUpTo10Mb.
  ///
  /// In en, this message translates to:
  /// **'JPG, PNG or PDF · up to 10 MB'**
  String get jpgPngOrPdfUpTo10Mb;

  /// No description provided for @jpgOrPngUpTo10Mb.
  ///
  /// In en, this message translates to:
  /// **'JPG or PNG · up to 10 MB'**
  String get jpgOrPngUpTo10Mb;

  /// No description provided for @kathmandu.
  ///
  /// In en, this message translates to:
  /// **'Kathmandu'**
  String get kathmandu;

  /// No description provided for @keepYourAccountSecure.
  ///
  /// In en, this message translates to:
  /// **'Keep your account secure'**
  String get keepYourAccountSecure;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @legalAndSupportingCompanyDocuments.
  ///
  /// In en, this message translates to:
  /// **'Legal and supporting company documents.'**
  String get legalAndSupportingCompanyDocuments;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code'**
  String get didntReceiveCode;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @linkCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard.'**
  String get linkCopiedToClipboard;

  /// No description provided for @listYourFutsalHouseRulesForPlayers.
  ///
  /// In en, this message translates to:
  /// **'List your futsal house rules for players...'**
  String get listYourFutsalHouseRulesForPlayers;

  /// No description provided for @loadingAvailableCoupons.
  ///
  /// In en, this message translates to:
  /// **'Loading available coupons…'**
  String get loadingAvailableCoupons;

  /// No description provided for @loadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Loading categories…'**
  String get loadingCategories;

  /// No description provided for @loadingMediaLibrary.
  ///
  /// In en, this message translates to:
  /// **'Loading media library...'**
  String get loadingMediaLibrary;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationDetails;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @lockedWhileUnderReviewThisSelectionCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Locked while under review — this selection cannot be changed.'**
  String get lockedWhileUnderReviewThisSelectionCannotBeChanged;

  /// No description provided for @logo.
  ///
  /// In en, this message translates to:
  /// **'Logo'**
  String get logo;

  /// No description provided for @logoutFailedPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Logout failed. Please try again.'**
  String get logoutFailedPleaseTryAgain;

  /// No description provided for @logoutSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Logout successful'**
  String get logoutSuccessful;

  /// No description provided for @passwordUpdatedPleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Please log in again.'**
  String get passwordUpdatedPleaseLogIn;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @lookingForAFriendlyCompetitiveFutsalMatch.
  ///
  /// In en, this message translates to:
  /// **'Looking for a friendly competitive futsal match.'**
  String get lookingForAFriendlyCompetitiveFutsalMatch;

  /// No description provided for @loserCoversTheLargerShareSettleTheAmountAfterThe2a150fda.
  ///
  /// In en, this message translates to:
  /// **'Loser covers the larger share. Settle the amount after the match result.'**
  String get loserCoversTheLargerShareSettleTheAmountAfterThe2a150fda;

  /// No description provided for @loserPays.
  ///
  /// In en, this message translates to:
  /// **'Loser pays'**
  String get loserPays;

  /// No description provided for @madeForFutsal.
  ///
  /// In en, this message translates to:
  /// **'Made for Futsal'**
  String get madeForFutsal;

  /// No description provided for @manageBookingAndPaymentSettings.
  ///
  /// In en, this message translates to:
  /// **'Manage booking and payment settings'**
  String get manageBookingAndPaymentSettings;

  /// No description provided for @manageCourt.
  ///
  /// In en, this message translates to:
  /// **'Manage Court'**
  String get manageCourt;

  /// No description provided for @manageCourtsInCompactView.
  ///
  /// In en, this message translates to:
  /// **'Manage courts in compact view'**
  String get manageCourtsInCompactView;

  /// No description provided for @manageFutsal.
  ///
  /// In en, this message translates to:
  /// **'Manage Futsal'**
  String get manageFutsal;

  /// No description provided for @margin.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get margin;

  /// No description provided for @markReturned.
  ///
  /// In en, this message translates to:
  /// **'Mark returned'**
  String get markReturned;

  /// No description provided for @markWeekendDaysHolidayDatesAndClosedDates.
  ///
  /// In en, this message translates to:
  /// **'Mark weekend days, holiday dates, and closed dates.'**
  String get markWeekendDaysHolidayDatesAndClosedDates;

  /// No description provided for @matchDate.
  ///
  /// In en, this message translates to:
  /// **'Match date'**
  String get matchDate;

  /// No description provided for @matchFormat.
  ///
  /// In en, this message translates to:
  /// **'Match format'**
  String get matchFormat;

  /// No description provided for @matchTime.
  ///
  /// In en, this message translates to:
  /// **'Match time'**
  String get matchTime;

  /// No description provided for @matchReady.
  ///
  /// In en, this message translates to:
  /// **'Match Ready'**
  String get matchReady;

  /// No description provided for @matchType.
  ///
  /// In en, this message translates to:
  /// **'Match Type'**
  String get matchType;

  /// No description provided for @matchesTheBackendSchemaYouShared.
  ///
  /// In en, this message translates to:
  /// **'Matches the backend schema you shared.'**
  String get matchesTheBackendSchemaYouShared;

  /// No description provided for @maxPlayers.
  ///
  /// In en, this message translates to:
  /// **'Max players'**
  String get maxPlayers;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @memories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memories;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minute;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @myTeams.
  ///
  /// In en, this message translates to:
  /// **'My Teams'**
  String get myTeams;

  /// No description provided for @nameBasePriceAndCourtType.
  ///
  /// In en, this message translates to:
  /// **'Name, base price, and court type.'**
  String get nameBasePriceAndCourtType;

  /// No description provided for @nameExampleCom.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get nameExampleCom;

  /// No description provided for @nameFutsalCom.
  ///
  /// In en, this message translates to:
  /// **'name@futsal.com'**
  String get nameFutsalCom;

  /// No description provided for @nepal.
  ///
  /// In en, this message translates to:
  /// **'Nepal'**
  String get nepal;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get netProfit;

  /// No description provided for @netRevenue.
  ///
  /// In en, this message translates to:
  /// **'Net revenue'**
  String get netRevenue;

  /// No description provided for @newCourt.
  ///
  /// In en, this message translates to:
  /// **'New Court'**
  String get newCourt;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get newExpense;

  /// No description provided for @newFutsal.
  ///
  /// In en, this message translates to:
  /// **'New Futsal'**
  String get newFutsal;

  /// No description provided for @newRental.
  ///
  /// In en, this message translates to:
  /// **'New rental'**
  String get newRental;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequest;

  /// No description provided for @completeRequest.
  ///
  /// In en, this message translates to:
  /// **'Complete Request'**
  String get completeRequest;

  /// No description provided for @completeSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeSetup;

  /// No description provided for @newTeam.
  ///
  /// In en, this message translates to:
  /// **'New Team'**
  String get newTeam;

  /// No description provided for @showPlayers.
  ///
  /// In en, this message translates to:
  /// **'Show players'**
  String get showPlayers;

  /// No description provided for @hidePlayers.
  ///
  /// In en, this message translates to:
  /// **'Hide players'**
  String get hidePlayers;

  /// No description provided for @newToday.
  ///
  /// In en, this message translates to:
  /// **'New Today'**
  String get newToday;

  /// No description provided for @noAmenitiesInThisCategory.
  ///
  /// In en, this message translates to:
  /// **'No amenities in this category.'**
  String get noAmenitiesInThisCategory;

  /// No description provided for @noAmenitiesInformationAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'No amenities information available yet.'**
  String get noAmenitiesInformationAvailableYet;

  /// No description provided for @noBookingPolicyAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No booking policy added yet.'**
  String get noBookingPolicyAddedYet;

  /// No description provided for @noClosedDatesAdded.
  ///
  /// In en, this message translates to:
  /// **'No closed dates added.'**
  String get noClosedDatesAdded;

  /// No description provided for @noCourtActivity.
  ///
  /// In en, this message translates to:
  /// **'No court activity.'**
  String get noCourtActivity;

  /// No description provided for @noCourtTypesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No court types available.'**
  String get noCourtTypesAvailable;

  /// No description provided for @noCourtsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No courts added yet'**
  String get noCourtsAddedYet;

  /// No description provided for @noCourtsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No courts available'**
  String get noCourtsAvailable;

  /// No description provided for @openingVenue.
  ///
  /// In en, this message translates to:
  /// **'Opening venue…'**
  String get openingVenue;

  /// No description provided for @couldNotOpenThisLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link'**
  String get couldNotOpenThisLink;

  /// No description provided for @venueNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Venue not available'**
  String get venueNotAvailable;

  /// No description provided for @thisVenueIsNoLongerListed.
  ///
  /// In en, this message translates to:
  /// **'This venue is no longer listed, or the link has changed.'**
  String get thisVenueIsNoLongerListed;

  /// No description provided for @browseVenues.
  ///
  /// In en, this message translates to:
  /// **'Browse venues'**
  String get browseVenues;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @thatLinkDoesNotOpenAnythingInTheApp.
  ///
  /// In en, this message translates to:
  /// **'That link does not open anything in the app.'**
  String get thatLinkDoesNotOpenAnythingInTheApp;

  /// No description provided for @allCourtsBookedOrUnavailable.
  ///
  /// In en, this message translates to:
  /// **'All courts booked or unavailable'**
  String get allCourtsBookedOrUnavailable;

  /// No description provided for @selectedDatesCourtsAreAlreadyBookedOrUnavai0f4a71b2.
  ///
  /// In en, this message translates to:
  /// **'Selected date\'s courts are already booked or unavailable, please choose another date.'**
  String get selectedDatesCourtsAreAlreadyBookedOrUnavai0f4a71b2;

  /// No description provided for @noCourtsYet.
  ///
  /// In en, this message translates to:
  /// **'No courts yet'**
  String get noCourtsYet;

  /// No description provided for @noCustomerActivity.
  ///
  /// In en, this message translates to:
  /// **'No customer activity.'**
  String get noCustomerActivity;

  /// No description provided for @noDescriptionAvailableForThisCourtYet.
  ///
  /// In en, this message translates to:
  /// **'No description available for this court yet.'**
  String get noDescriptionAvailableForThisCourtYet;

  /// No description provided for @noEquipmentYet.
  ///
  /// In en, this message translates to:
  /// **'No equipment yet'**
  String get noEquipmentYet;

  /// No description provided for @noExpensesRecordedForThisRange.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded for this range.'**
  String get noExpensesRecordedForThisRange;

  /// No description provided for @noFavouritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get noFavouritesYet;

  /// No description provided for @noHolidayDatesAdded.
  ///
  /// In en, this message translates to:
  /// **'No holiday dates added.'**
  String get noHolidayDatesAdded;

  /// No description provided for @noMatchingMembers.
  ///
  /// In en, this message translates to:
  /// **'No matching members'**
  String get noMatchingMembers;

  /// No description provided for @noMatchFormatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No match formats available.'**
  String get noMatchFormatsAvailable;

  /// No description provided for @noMatchingVenues.
  ///
  /// In en, this message translates to:
  /// **'No matching venues'**
  String get noMatchingVenues;

  /// No description provided for @noMediaFound.
  ///
  /// In en, this message translates to:
  /// **'No media found'**
  String get noMediaFound;

  /// No description provided for @noMembersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No members available'**
  String get noMembersAvailable;

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found'**
  String get noMembersFound;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @noRecentBookings.
  ///
  /// In en, this message translates to:
  /// **'No recent bookings'**
  String get noRecentBookings;

  /// No description provided for @noRulesListedYet.
  ///
  /// In en, this message translates to:
  /// **'No rules listed yet.'**
  String get noRulesListedYet;

  /// No description provided for @noSlotConfigurationAddedYetAddASlotToDefineTheBo243e88c0.
  ///
  /// In en, this message translates to:
  /// **'No slot configuration added yet. Add a slot to define the booking schedule for this court.'**
  String get noSlotConfigurationAddedYetAddASlotToDefineTheBo243e88c0;

  /// No description provided for @noSlotsFound.
  ///
  /// In en, this message translates to:
  /// **'No slots found'**
  String get noSlotsFound;

  /// No description provided for @noTeamsYet.
  ///
  /// In en, this message translates to:
  /// **'No teams yet'**
  String get noTeamsYet;

  /// No description provided for @noTimeSlotsAreAvailableForThisDate.
  ///
  /// In en, this message translates to:
  /// **'No time slots are available for this date.'**
  String get noTimeSlotsAreAvailableForThisDate;

  /// No description provided for @noTrendYet.
  ///
  /// In en, this message translates to:
  /// **'No trend yet'**
  String get noTrendYet;

  /// No description provided for @noUploadsYet.
  ///
  /// In en, this message translates to:
  /// **'No uploads yet'**
  String get noUploadsYet;

  /// No description provided for @noVenueActivity.
  ///
  /// In en, this message translates to:
  /// **'No venue activity.'**
  String get noVenueActivity;

  /// No description provided for @noVenuesFound.
  ///
  /// In en, this message translates to:
  /// **'No venues found'**
  String get noVenuesFound;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @nothingToBreakDown.
  ///
  /// In en, this message translates to:
  /// **'Nothing to break down'**
  String get nothingToBreakDown;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notifyMeWhenSomeoneWantsToPlay.
  ///
  /// In en, this message translates to:
  /// **'Notify me when someone wants to play'**
  String get notifyMeWhenSomeoneWantsToPlay;

  /// No description provided for @npr.
  ///
  /// In en, this message translates to:
  /// **'NPR'**
  String get npr;

  /// No description provided for @numberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered List'**
  String get numberedList;

  /// No description provided for @occasionalOffersAndUpdatesByEmail.
  ///
  /// In en, this message translates to:
  /// **'Occasional offers and updates by email'**
  String get occasionalOffersAndUpdatesByEmail;

  /// No description provided for @occupancy.
  ///
  /// In en, this message translates to:
  /// **'Occupancy'**
  String get occupancy;

  /// No description provided for @offerRefundsWhenCancellationsMeetYourVenuePolicy.
  ///
  /// In en, this message translates to:
  /// **'Offer refunds when cancellations meet your venue policy.'**
  String get offerRefundsWhenCancellationsMeetYourVenuePolicy;

  /// No description provided for @ohYesPleaseSendYourBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Oh yes, please send your booking details.'**
  String get ohYesPleaseSendYourBookingDetails;

  /// No description provided for @onRent.
  ///
  /// In en, this message translates to:
  /// **'On rent'**
  String get onRent;

  /// No description provided for @documentUploadRequirements.
  ///
  /// In en, this message translates to:
  /// **'Only from device files — image (JPG, PNG, WebP), PDF or Word. Max 10 MB. Gallery is not used here.'**
  String get documentUploadRequirements;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @openstreetmap.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap'**
  String get openstreetmap;

  /// No description provided for @operationalPhotosForThisSpecificCourt.
  ///
  /// In en, this message translates to:
  /// **'Operational photos for this specific court.'**
  String get operationalPhotosForThisSpecificCourt;

  /// No description provided for @opponentMatch.
  ///
  /// In en, this message translates to:
  /// **'Opponent Match'**
  String get opponentMatch;

  /// No description provided for @opponentRequests.
  ///
  /// In en, this message translates to:
  /// **'Opponent Requests'**
  String get opponentRequests;

  /// No description provided for @opponentTeam.
  ///
  /// In en, this message translates to:
  /// **'Opponent team'**
  String get opponentTeam;

  /// No description provided for @optionalPricesForOneOffDates.
  ///
  /// In en, this message translates to:
  /// **'Optional prices for one-off dates.'**
  String get optionalPricesForOneOffDates;

  /// No description provided for @optionalVenue.
  ///
  /// In en, this message translates to:
  /// **'Optional venue'**
  String get optionalVenue;

  /// No description provided for @optionalVisualIdentityAndFinalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Optional visual identity and final confirmation.'**
  String get optionalVisualIdentityAndFinalConfirmation;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @orProvideADirectImageUrl.
  ///
  /// In en, this message translates to:
  /// **'OR provide a direct image URL'**
  String get orProvideADirectImageUrl;

  /// No description provided for @organizeGamesWithLessEffort.
  ///
  /// In en, this message translates to:
  /// **'Organize games with less effort.'**
  String get organizeGamesWithLessEffort;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @otpVerificationFailedPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'OTP verification failed. Please try again.'**
  String get otpVerificationFailedPleaseTryAgain;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @overviewAndImportantDetails.
  ///
  /// In en, this message translates to:
  /// **'Overview and important details'**
  String get overviewAndImportantDetails;

  /// No description provided for @package.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get package;

  /// No description provided for @paidVia.
  ///
  /// In en, this message translates to:
  /// **'Paid via'**
  String get paidVia;

  /// No description provided for @panLicenseRegistrationEtc.
  ///
  /// In en, this message translates to:
  /// **'PAN, license, registration, etc.'**
  String get panLicenseRegistrationEtc;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @payNowAdvance.
  ///
  /// In en, this message translates to:
  /// **'Pay now (advance)'**
  String get payNowAdvance;

  /// No description provided for @payableNow.
  ///
  /// In en, this message translates to:
  /// **'Payable now'**
  String get payableNow;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @paymentProof.
  ///
  /// In en, this message translates to:
  /// **'Payment proof'**
  String get paymentProof;

  /// No description provided for @paymentQr.
  ///
  /// In en, this message translates to:
  /// **'Payment QR'**
  String get paymentQr;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get paymentStatus;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @photosAndMemories.
  ///
  /// In en, this message translates to:
  /// **'Photos & Memories'**
  String get photosAndMemories;

  /// No description provided for @pickDatesAndSlotsQuickly.
  ///
  /// In en, this message translates to:
  /// **'Pick dates and slots quickly.'**
  String get pickDatesAndSlotsQuickly;

  /// No description provided for @pickExactLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick Exact Location'**
  String get pickExactLocation;

  /// No description provided for @pickFrom.
  ///
  /// In en, this message translates to:
  /// **'Pick from...'**
  String get pickFrom;

  /// No description provided for @pickCorrectedFileToReplacePrefix.
  ///
  /// In en, this message translates to:
  /// **'Pick a corrected file to replace '**
  String get pickCorrectedFileToReplacePrefix;

  /// No description provided for @pickTheOperationalPackageThatFitsYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Pick the operational package that fits your business.'**
  String get pickTheOperationalPackageThatFitsYourBusiness;

  /// No description provided for @platformCommissionAndCommercialTerms.
  ///
  /// In en, this message translates to:
  /// **'Platform commission and commercial terms.'**
  String get platformCommissionAndCommercialTerms;

  /// No description provided for @playerFacingFacilitiesForThisCourt.
  ///
  /// In en, this message translates to:
  /// **'Player-facing facilities for this court.'**
  String get playerFacingFacilitiesForThisCourt;

  /// No description provided for @playerOptions.
  ///
  /// In en, this message translates to:
  /// **'Player options'**
  String get playerOptions;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @pleaseConfirmTheDetailsBeforeBooking.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the details before booking.'**
  String get pleaseConfirmTheDetailsBeforeBooking;

  /// No description provided for @pleaseShareTheLocationPinOnceAgain.
  ///
  /// In en, this message translates to:
  /// **'Please share the location pin once again.'**
  String get pleaseShareTheLocationPinOnceAgain;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @pngJpgJpegWebp.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPG, JPEG, WEBP'**
  String get pngJpgJpegWebp;

  /// No description provided for @policies.
  ///
  /// In en, this message translates to:
  /// **'Policies'**
  String get policies;

  /// No description provided for @policyAndRules.
  ///
  /// In en, this message translates to:
  /// **'Policy & Rules'**
  String get policyAndRules;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @priceBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Price breakdown'**
  String get priceBreakdown;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @pricingOperationalDetailsAndRegistrationInformation.
  ///
  /// In en, this message translates to:
  /// **'Pricing, operational details, and registration information.'**
  String get pricingOperationalDetailsAndRegistrationInformation;

  /// No description provided for @primaryBusinessThumbnailForTheFutsalListing.
  ///
  /// In en, this message translates to:
  /// **'Primary business thumbnail for the futsal listing.'**
  String get primaryBusinessThumbnailForTheFutsalListing;

  /// No description provided for @primaryFutsalCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Primary futsal cover image.'**
  String get primaryFutsalCoverImage;

  /// No description provided for @privacyFirst.
  ///
  /// In en, this message translates to:
  /// **'Privacy First'**
  String get privacyFirst;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @promotionalEmails.
  ///
  /// In en, this message translates to:
  /// **'Promotional Emails'**
  String get promotionalEmails;

  /// No description provided for @proof.
  ///
  /// In en, this message translates to:
  /// **'Proof'**
  String get proof;

  /// No description provided for @publicIdentityAndContactDetailsOfYourFutsal.
  ///
  /// In en, this message translates to:
  /// **'Public identity and contact details of your futsal.'**
  String get publicIdentityAndContactDetailsOfYourFutsal;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @qrCodeUsedForAdvancePayment.
  ///
  /// In en, this message translates to:
  /// **'QR code used for advance payment.'**
  String get qrCodeUsedForAdvancePayment;

  /// No description provided for @qrUnavailable.
  ///
  /// In en, this message translates to:
  /// **'QR unavailable'**
  String get qrUnavailable;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quote;

  /// No description provided for @rankings.
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get rankings;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @reEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get reEnterNewPassword;

  /// No description provided for @reEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reEnterYourPassword;

  /// No description provided for @receiveUpdatesOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Receive updates on this device'**
  String get receiveUpdatesOnThisDevice;

  /// No description provided for @recentBookings.
  ///
  /// In en, this message translates to:
  /// **'Recent Bookings'**
  String get recentBookings;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @recurrence.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get recurrence;

  /// No description provided for @recurringBooking.
  ///
  /// In en, this message translates to:
  /// **'Recurring booking'**
  String get recurringBooking;

  /// No description provided for @repeatOn.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get repeatOn;

  /// No description provided for @repeatFor.
  ///
  /// In en, this message translates to:
  /// **'Repeat for'**
  String get repeatFor;

  /// No description provided for @recurringPriceDetails.
  ///
  /// In en, this message translates to:
  /// **'Recurring price details'**
  String get recurringPriceDetails;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @refundCancellationAndCustomerBookingGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Refund, cancellation, and customer booking guidelines'**
  String get refundCancellationAndCustomerBookingGuidelines;

  /// No description provided for @refundCancellationPolicy.
  ///
  /// In en, this message translates to:
  /// **'Refund / Cancellation Policy'**
  String get refundCancellationPolicy;

  /// No description provided for @refundCancellationPolicyCompact.
  ///
  /// In en, this message translates to:
  /// **'Refund/Cancellation Policy'**
  String get refundCancellationPolicyCompact;

  /// No description provided for @refundCancellationPolicyFutsalRulesAndCommissions.
  ///
  /// In en, this message translates to:
  /// **'Refund/cancellation policy, futsal rules, and commissions.'**
  String get refundCancellationPolicyFutsalRulesAndCommissions;

  /// No description provided for @refundableSecurityDeposit.
  ///
  /// In en, this message translates to:
  /// **'Refundable security deposit'**
  String get refundableSecurityDeposit;

  /// No description provided for @registrationNumberExample.
  ///
  /// In en, this message translates to:
  /// **'REG-2026-00123'**
  String get registrationNumberExample;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @remindersBeforeYourMatchesStart.
  ///
  /// In en, this message translates to:
  /// **'Reminders before your matches start'**
  String get remindersBeforeYourMatchesStart;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeFileConfirmationPrefix.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove '**
  String get removeFileConfirmationPrefix;

  /// No description provided for @removeDocument.
  ///
  /// In en, this message translates to:
  /// **'Remove document'**
  String get removeDocument;

  /// No description provided for @removeFromMediaLibrary.
  ///
  /// In en, this message translates to:
  /// **'Remove from media library?'**
  String get removeFromMediaLibrary;

  /// No description provided for @removePlayer.
  ///
  /// In en, this message translates to:
  /// **'Remove player?'**
  String get removePlayer;

  /// No description provided for @removeRequest.
  ///
  /// In en, this message translates to:
  /// **'Remove request?'**
  String get removeRequest;

  /// No description provided for @removeRequestAction.
  ///
  /// In en, this message translates to:
  /// **'Remove Request'**
  String get removeRequestAction;

  /// No description provided for @requestDeleted.
  ///
  /// In en, this message translates to:
  /// **'Opponent request deleted.'**
  String get requestDeleted;

  /// No description provided for @courtFeeNotSetYet.
  ///
  /// In en, this message translates to:
  /// **'Not set yet'**
  String get courtFeeNotSetYet;

  /// No description provided for @requestPublished.
  ///
  /// In en, this message translates to:
  /// **'Opponent request published.'**
  String get requestPublished;

  /// No description provided for @renameTeam.
  ///
  /// In en, this message translates to:
  /// **'Rename Team'**
  String get renameTeam;

  /// No description provided for @rentalServices.
  ///
  /// In en, this message translates to:
  /// **'Rental Services'**
  String get rentalServices;

  /// No description provided for @renterName.
  ///
  /// In en, this message translates to:
  /// **'Renter name'**
  String get renterName;

  /// No description provided for @repeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeats;

  /// No description provided for @replaceDocument.
  ///
  /// In en, this message translates to:
  /// **'Replace document'**
  String get replaceDocument;

  /// No description provided for @replaceThisRejectedDocument.
  ///
  /// In en, this message translates to:
  /// **'Replace this rejected document'**
  String get replaceThisRejectedDocument;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @requireAdvancePayment.
  ///
  /// In en, this message translates to:
  /// **'Require advance payment'**
  String get requireAdvancePayment;

  /// No description provided for @requirementAndCollectionAmount.
  ///
  /// In en, this message translates to:
  /// **'Requirement and collection amount'**
  String get requirementAndCollectionAmount;

  /// No description provided for @requirementAndCollectionPercentage.
  ///
  /// In en, this message translates to:
  /// **'Requirement and collection percentage.'**
  String get requirementAndCollectionPercentage;

  /// No description provided for @resendOtpFailedPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP failed. Please try again.'**
  String get resendOtpFailedPleaseTryAgain;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Reset onboarding'**
  String get resetOnboarding;

  /// No description provided for @resetToDefaultTemplate.
  ///
  /// In en, this message translates to:
  /// **'Reset to default template'**
  String get resetToDefaultTemplate;

  /// No description provided for @resolving.
  ///
  /// In en, this message translates to:
  /// **'Resolving...'**
  String get resolving;

  /// No description provided for @response.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get response;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @reviewFacilitiesBeforeBooking.
  ///
  /// In en, this message translates to:
  /// **'Review facilities before booking.'**
  String get reviewFacilitiesBeforeBooking;

  /// No description provided for @reviewYourBooking.
  ///
  /// In en, this message translates to:
  /// **'Review your booking'**
  String get reviewYourBooking;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @requestEdit.
  ///
  /// In en, this message translates to:
  /// **'Request edit'**
  String get requestEdit;

  /// No description provided for @requestDelete.
  ///
  /// In en, this message translates to:
  /// **'Request delete'**
  String get requestDelete;

  /// No description provided for @requestEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Request an edit'**
  String get requestEditTitle;

  /// No description provided for @requestDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Request a deletion'**
  String get requestDeleteTitle;

  /// No description provided for @requestEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write the wording that should replace it and why. A super admin reviews your request before anything changes.'**
  String get requestEditSubtitle;

  /// No description provided for @requestDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell the super admin why this review should be taken down — abusive or offensive wording, for instance. They approve the removal before it disappears.'**
  String get requestDeleteSubtitle;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @updatedReview.
  ///
  /// In en, this message translates to:
  /// **'Suggested wording'**
  String get updatedReview;

  /// No description provided for @updatedReviewHint.
  ///
  /// In en, this message translates to:
  /// **'How should this review read?'**
  String get updatedReviewHint;

  /// No description provided for @updatedReviewRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write the wording you are suggesting.'**
  String get updatedReviewRequired;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'Write your reason...'**
  String get reasonHint;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason.'**
  String get reasonRequired;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get submitRequest;

  /// No description provided for @reviewRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent to the super admin.'**
  String get reviewRequestSubmitted;

  /// No description provided for @rs1200.
  ///
  /// In en, this message translates to:
  /// **'Rs. 1200'**
  String get rs1200;

  /// No description provided for @rulesToFollowAtThisVenue.
  ///
  /// In en, this message translates to:
  /// **'Rules to follow at this venue'**
  String get rulesToFollowAtThisVenue;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveEquipment.
  ///
  /// In en, this message translates to:
  /// **'Save equipment'**
  String get saveEquipment;

  /// No description provided for @savePricing.
  ///
  /// In en, this message translates to:
  /// **'Save Pricing'**
  String get savePricing;

  /// No description provided for @sayHelloAndStartTheConversation.
  ///
  /// In en, this message translates to:
  /// **'Say hello and start the conversation.'**
  String get sayHelloAndStartTheConversation;

  /// No description provided for @searchByNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email'**
  String get searchByNameOrEmail;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get searchConversations;

  /// No description provided for @searchVenuesCourtsOrLocation.
  ///
  /// In en, this message translates to:
  /// **'Search venues, courts or location'**
  String get searchVenuesCourtsOrLocation;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectACategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectACategory;

  /// No description provided for @selectACourt.
  ///
  /// In en, this message translates to:
  /// **'Select a court'**
  String get selectACourt;

  /// No description provided for @selectATimeSlotToSeePrices.
  ///
  /// In en, this message translates to:
  /// **'Select a time slot to see prices.'**
  String get selectATimeSlotToSeePrices;

  /// No description provided for @selectAVenue.
  ///
  /// In en, this message translates to:
  /// **'Select a venue'**
  String get selectAVenue;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Select Date & Time'**
  String get selectDateAndTime;

  /// No description provided for @selectMatchDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select match date & time'**
  String get selectMatchDateTime;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @selectEquipment.
  ///
  /// In en, this message translates to:
  /// **'Select equipment'**
  String get selectEquipment;

  /// No description provided for @selectEquipmentType.
  ///
  /// In en, this message translates to:
  /// **'Select equipment type'**
  String get selectEquipmentType;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// No description provided for @selectPlayerOrVendor.
  ///
  /// In en, this message translates to:
  /// **'Select Player or Vendor'**
  String get selectPlayerOrVendor;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select status'**
  String get selectStatus;

  /// No description provided for @selectTheValueAddedServicesPlayersCanExpectOnBookingDays.
  ///
  /// In en, this message translates to:
  /// **'Select the value-added services players can expect on booking days.'**
  String get selectTheValueAddedServicesPlayersCanExpectOnBookingDays;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @selectYourTeam.
  ///
  /// In en, this message translates to:
  /// **'Select your team'**
  String get selectYourTeam;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected location'**
  String get selectedLocation;

  /// No description provided for @sendOpponentRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Opponent Request'**
  String get sendOpponentRequest;

  /// No description provided for @setDefaultWeekendHolidayAndDiscountPrices.
  ///
  /// In en, this message translates to:
  /// **'Set default, weekend, holiday, and discount prices.'**
  String get setDefaultWeekendHolidayAndDiscountPrices;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shareCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Share current location'**
  String get shareCurrentLocation;

  /// No description provided for @shareIsNotAvailableForThisVenue.
  ///
  /// In en, this message translates to:
  /// **'Share is not available for this venue.'**
  String get shareIsNotAvailableForThisVenue;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @slotLabel.
  ///
  /// In en, this message translates to:
  /// **'Slot label'**
  String get slotLabel;

  /// No description provided for @slotPricing.
  ///
  /// In en, this message translates to:
  /// **'Slot Pricing'**
  String get slotPricing;

  /// No description provided for @slotSchedule.
  ///
  /// In en, this message translates to:
  /// **'Slot Schedule'**
  String get slotSchedule;

  /// No description provided for @slotsAndPayments.
  ///
  /// In en, this message translates to:
  /// **'Slots & Payments'**
  String get slotsAndPayments;

  /// No description provided for @slotsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Slots unavailable'**
  String get slotsUnavailable;

  /// No description provided for @slug.
  ///
  /// In en, this message translates to:
  /// **'Slug'**
  String get slug;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @venueSlugMissing.
  ///
  /// In en, this message translates to:
  /// **'This venue cannot be edited yet. Please reopen it from the venue list.'**
  String get venueSlugMissing;

  /// No description provided for @specialDaysForPricingAndBookingAvailability.
  ///
  /// In en, this message translates to:
  /// **'Special days for pricing and booking availability'**
  String get specialDaysForPricingAndBookingAvailability;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @startAConversationFirstThenCreateAGroupFromIt.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation first, then create a group from it.'**
  String get startAConversationFirstThenCreateAGroupFromIt;

  /// No description provided for @startRental.
  ///
  /// In en, this message translates to:
  /// **'Start rental'**
  String get startRental;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @starter.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get starter;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusMix.
  ///
  /// In en, this message translates to:
  /// **'Status mix'**
  String get statusMix;

  /// No description provided for @stepBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Step Breakdown'**
  String get stepBreakdown;

  /// No description provided for @storeSettings.
  ///
  /// In en, this message translates to:
  /// **'Store Settings'**
  String get storeSettings;

  /// No description provided for @streetCityArea.
  ///
  /// In en, this message translates to:
  /// **'Street, city, area'**
  String get streetCityArea;

  /// No description provided for @strikethrough.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get strikethrough;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportRefunds.
  ///
  /// In en, this message translates to:
  /// **'Support refunds'**
  String get supportRefunds;

  /// No description provided for @chooseHowTheAppLooks.
  ///
  /// In en, this message translates to:
  /// **'Choose how the app looks'**
  String get chooseHowTheAppLooks;

  /// No description provided for @tapTheHeartOnAVenueToSaveItHereForQuickBooking.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a venue to save it here for quick booking.'**
  String get tapTheHeartOnAVenueToSaveItHereForQuickBooking;

  /// No description provided for @tapToPickLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick location on map'**
  String get tapToPickLocationOnMap;

  /// No description provided for @tapToPickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick on map'**
  String get tapToPickOnMap;

  /// No description provided for @tapToUploadShopLogo.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload shop logo'**
  String get tapToUploadShopLogo;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @teamOptions.
  ///
  /// In en, this message translates to:
  /// **'Team options'**
  String get teamOptions;

  /// No description provided for @tellCustomersAboutThisCourt.
  ///
  /// In en, this message translates to:
  /// **'Tell customers about this court.'**
  String get tellCustomersAboutThisCourt;

  /// No description provided for @tellCustomersAboutThisCourtSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell customers about this court'**
  String get tellCustomersAboutThisCourtSubtitle;

  /// No description provided for @tellCustomersAboutYourFutsal.
  ///
  /// In en, this message translates to:
  /// **'Tell customers about your futsal.'**
  String get tellCustomersAboutYourFutsal;

  /// No description provided for @tellCustomersAboutYourFutsalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell customers about your futsal'**
  String get tellCustomersAboutYourFutsalSubtitle;

  /// No description provided for @text10Steps.
  ///
  /// In en, this message translates to:
  /// **'10% steps'**
  String get text10Steps;

  /// No description provided for @text5v5.
  ///
  /// In en, this message translates to:
  /// **'5v5'**
  String get text5v5;

  /// No description provided for @text97798xxxxxxxx.
  ///
  /// In en, this message translates to:
  /// **'+977-98XXXXXXXX'**
  String get text97798xxxxxxxx;

  /// No description provided for @text98xxxxxxxx.
  ///
  /// In en, this message translates to:
  /// **'98XXXXXXXX'**
  String get text98xxxxxxxx;

  /// No description provided for @text9xxXxxxxxx.
  ///
  /// In en, this message translates to:
  /// **'9XX-XXXXXXX'**
  String get text9xxXxxxxxx;

  /// No description provided for @textColor.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get textColor;

  /// No description provided for @thanksIWillConfirmTheTeamShortly.
  ///
  /// In en, this message translates to:
  /// **'Thanks, I will confirm the team shortly.'**
  String get thanksIWillConfirmTheTeamShortly;

  /// No description provided for @thereAreNoFutsalVenuesToShowRightNow.
  ///
  /// In en, this message translates to:
  /// **'There are no futsal venues to show right now.'**
  String get thereAreNoFutsalVenuesToShowRightNow;

  /// No description provided for @thereAreNoNewPeopleAvailableToAddInThisGroup.
  ///
  /// In en, this message translates to:
  /// **'There are no new people available to add in this group.'**
  String get thereAreNoNewPeopleAvailableToAddInThisGroup;

  /// No description provided for @thisDocumentIsLockedWhileUnderReviewItCanBeRepla3c137b54.
  ///
  /// In en, this message translates to:
  /// **'This document is locked while under review. It can be replaced only after it is rejected.'**
  String get thisDocumentIsLockedWhileUnderReviewItCanBeRepla3c137b54;

  /// No description provided for @thisDocumentWasRejectedPleaseRemoveItAndAddANewC30fa5f11.
  ///
  /// In en, this message translates to:
  /// **'This document was rejected. Please remove it and add a new, corrected document.'**
  String get thisDocumentWasRejectedPleaseRemoveItAndAddANewC30fa5f11;

  /// No description provided for @thisMessageWillBePermanentlyRemovedFromTheConversation.
  ///
  /// In en, this message translates to:
  /// **'This message will be permanently removed from the conversation.'**
  String get thisMessageWillBePermanentlyRemovedFromTheConversation;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @timeSlots.
  ///
  /// In en, this message translates to:
  /// **'Time Slots'**
  String get timeSlots;

  /// No description provided for @timeSlotsWithPricingAndPaymentOptions.
  ///
  /// In en, this message translates to:
  /// **'Time slots with pricing and payment options.'**
  String get timeSlotsWithPricingAndPaymentOptions;

  /// No description provided for @titleContactsLocationAmenitiesAndFeatures.
  ///
  /// In en, this message translates to:
  /// **'Title, contacts, location, amenities, and features.'**
  String get titleContactsLocationAmenitiesAndFeatures;

  /// No description provided for @titlePhoneAndEmail.
  ///
  /// In en, this message translates to:
  /// **'Title, phone, and email.'**
  String get titlePhoneAndEmail;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get toDate;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get topCategory;

  /// No description provided for @topVenue.
  ///
  /// In en, this message translates to:
  /// **'Top venue'**
  String get topVenue;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @totalBooking.
  ///
  /// In en, this message translates to:
  /// **'Total Booking'**
  String get totalBooking;

  /// No description provided for @totalBookings.
  ///
  /// In en, this message translates to:
  /// **'Total bookings'**
  String get totalBookings;

  /// No description provided for @totalEarning.
  ///
  /// In en, this message translates to:
  /// **'Total Earning'**
  String get totalEarning;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get totalExpenses;

  /// No description provided for @totalQuantityInStock.
  ///
  /// In en, this message translates to:
  /// **'Total quantity in stock'**
  String get totalQuantityInStock;

  /// No description provided for @tournamentsEventsOrPromotionalMoments.
  ///
  /// In en, this message translates to:
  /// **'Tournaments, events, or promotional moments.'**
  String get tournamentsEventsOrPromotionalMoments;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @trustedVenues.
  ///
  /// In en, this message translates to:
  /// **'Trusted Venues'**
  String get trustedVenues;

  /// No description provided for @tryAdjustingOrClearingYourFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting or clearing your filters.'**
  String get tryAdjustingOrClearingYourFilters;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @trySearchingWithAnotherNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Try searching with another name or email.'**
  String get trySearchingWithAnotherNameOrEmail;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'typing…'**
  String get typing;

  /// No description provided for @unableToLoadVenues.
  ///
  /// In en, this message translates to:
  /// **'Unable to load venues'**
  String get unableToLoadVenues;

  /// No description provided for @unableToLoadBookings.
  ///
  /// In en, this message translates to:
  /// **'Unable to load bookings'**
  String get unableToLoadBookings;

  /// No description provided for @unableToLoadWishlist.
  ///
  /// In en, this message translates to:
  /// **'Unable to load wishlist'**
  String get unableToLoadWishlist;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get underReview;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @underline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get underline;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @updatePricingForThisSlot.
  ///
  /// In en, this message translates to:
  /// **'Update pricing for this slot'**
  String get updatePricingForThisSlot;

  /// No description provided for @offerADiscountOnThisSlot.
  ///
  /// In en, this message translates to:
  /// **'Offer a discount on this slot'**
  String get offerADiscountOnThisSlot;

  /// No description provided for @discountStarts.
  ///
  /// In en, this message translates to:
  /// **'Discount starts'**
  String get discountStarts;

  /// No description provided for @discountEnds.
  ///
  /// In en, this message translates to:
  /// **'Discount ends'**
  String get discountEnds;

  /// No description provided for @anyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get anyTime;

  /// No description provided for @discountEndMustFollowStart.
  ///
  /// In en, this message translates to:
  /// **'The discount must end after it starts.'**
  String get discountEndMustFollowStart;

  /// No description provided for @discountNeedsTypeAndValue.
  ///
  /// In en, this message translates to:
  /// **'Choose a discount type and enter an amount, or switch the discount off.'**
  String get discountNeedsTypeAndValue;

  /// No description provided for @discountValueMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Enter a discount amount greater than zero.'**
  String get discountValueMustBePositive;

  /// No description provided for @discountPercentTooHigh.
  ///
  /// In en, this message translates to:
  /// **'A percentage discount cannot be more than 100%.'**
  String get discountPercentTooHigh;

  /// No description provided for @upgradeToVendor.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Vendor'**
  String get upgradeToVendor;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload document'**
  String get uploadDocument;

  /// No description provided for @uploadMedia.
  ///
  /// In en, this message translates to:
  /// **'Upload media?'**
  String get uploadMedia;

  /// No description provided for @uploadPaymentReceipt.
  ///
  /// In en, this message translates to:
  /// **'Upload payment receipt'**
  String get uploadPaymentReceipt;

  /// No description provided for @uploadPhotosAndMemories.
  ///
  /// In en, this message translates to:
  /// **'Upload Photos and Memories'**
  String get uploadPhotosAndMemories;

  /// No description provided for @uploadRegistrationPanLicenseAndRelatedDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload registration, PAN, license, and related documents.'**
  String get uploadRegistrationPanLicenseAndRelatedDocuments;

  /// No description provided for @uploadThePrimaryCoverImageForYourFutsalListing.
  ///
  /// In en, this message translates to:
  /// **'Upload the primary cover image for your futsal listing.'**
  String get uploadThePrimaryCoverImageForYourFutsalListing;

  /// No description provided for @uploadTheQrUsedToCollectAdvancePayment.
  ///
  /// In en, this message translates to:
  /// **'Upload the QR used to collect advance payment.'**
  String get uploadTheQrUsedToCollectAdvancePayment;

  /// No description provided for @uploadTheQrUsedToCollectAdvancePayments.
  ///
  /// In en, this message translates to:
  /// **'Upload the QR used to collect advance payments'**
  String get uploadTheQrUsedToCollectAdvancePayments;

  /// No description provided for @uploadYourFutsalBusinessMediaAndDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload your futsal business media and documents.'**
  String get uploadYourFutsalBusinessMediaAndDocuments;

  /// No description provided for @use8Characters.
  ///
  /// In en, this message translates to:
  /// **'Use 8+ characters'**
  String get use8Characters;

  /// No description provided for @passwordMustDifferFromCurrent.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters, different from your current password.'**
  String get passwordMustDifferFromCurrent;

  /// No description provided for @useFaceIdOrFingerprintToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or fingerprint to sign in'**
  String get useFaceIdOrFingerprintToSignIn;

  /// No description provided for @useSeparateCourtMediaToShowConditionLayoutAndEvec64b5.
  ///
  /// In en, this message translates to:
  /// **'Use separate court media to show condition, layout, and events without mixing it into the futsal-level gallery.'**
  String get useSeparateCourtMediaToShowConditionLayoutAndEvec64b5;

  /// No description provided for @vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendor;

  /// No description provided for @vendorOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Vendor Onboarding'**
  String get vendorOnboarding;

  /// No description provided for @venue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venue;

  /// No description provided for @venueActions.
  ///
  /// In en, this message translates to:
  /// **'Venue actions'**
  String get venueActions;

  /// No description provided for @venueAmenitiesAndKeyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Venue amenities and key features.'**
  String get venueAmenitiesAndKeyFeatures;

  /// No description provided for @venueIdIsMissingForCourtAvailability.
  ///
  /// In en, this message translates to:
  /// **'Venue id is missing for court availability.'**
  String get venueIdIsMissingForCourtAvailability;

  /// No description provided for @venueIdIsMissingForSlotAvailability.
  ///
  /// In en, this message translates to:
  /// **'Venue id is missing for slot availability.'**
  String get venueIdIsMissingForSlotAvailability;

  /// No description provided for @venueIdentityAndContactDetails.
  ///
  /// In en, this message translates to:
  /// **'Venue identity and contact details'**
  String get venueIdentityAndContactDetails;

  /// No description provided for @venueLevelPhotosForTheListing.
  ///
  /// In en, this message translates to:
  /// **'Venue-level photos for the listing.'**
  String get venueLevelPhotosForTheListing;

  /// No description provided for @venueRulesAndPlayerConductDetails.
  ///
  /// In en, this message translates to:
  /// **'Venue rules and player conduct details'**
  String get venueRulesAndPlayerConductDetails;

  /// No description provided for @venues.
  ///
  /// In en, this message translates to:
  /// **'Venues'**
  String get venues;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @viewFullScreen.
  ///
  /// In en, this message translates to:
  /// **'View full screen'**
  String get viewFullScreen;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @saveQrCode.
  ///
  /// In en, this message translates to:
  /// **'Save QR code'**
  String get saveQrCode;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// No description provided for @playerGuides.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get playerGuides;

  /// No description provided for @vendorGuides.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendorGuides;

  /// No description provided for @learnTheBasics.
  ///
  /// In en, this message translates to:
  /// **'Learn the basics'**
  String get learnTheBasics;

  /// No description provided for @runYourVenue.
  ///
  /// In en, this message translates to:
  /// **'Run your venue'**
  String get runYourVenue;

  /// No description provided for @playerVideosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Short videos on booking courts, paying and finding opponents.'**
  String get playerVideosSubtitle;

  /// No description provided for @vendorVideosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Short videos on setting up your venue, courts and bookings.'**
  String get vendorVideosSubtitle;

  /// No description provided for @moreVideos.
  ///
  /// In en, this message translates to:
  /// **'More videos'**
  String get moreVideos;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get upNext;

  /// No description provided for @couldNotLoadVideos.
  ///
  /// In en, this message translates to:
  /// **'Could not load videos.'**
  String get couldNotLoadVideos;

  /// No description provided for @couldNotParseVideosFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not read the videos from the server.'**
  String get couldNotParseVideosFromServer;

  /// No description provided for @startHere.
  ///
  /// In en, this message translates to:
  /// **'Start here'**
  String get startHere;

  /// No description provided for @noVideosYet.
  ///
  /// In en, this message translates to:
  /// **'No videos yet'**
  String get noVideosYet;

  /// No description provided for @noVideosYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Video guides on how to use the app will appear here.'**
  String get noVideosYetMessage;

  /// No description provided for @swipeForMoreQrs.
  ///
  /// In en, this message translates to:
  /// **'Swipe for more QRs'**
  String get swipeForMoreQrs;

  /// No description provided for @downloadingAttachment.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get downloadingAttachment;

  /// No description provided for @attachmentSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your device.'**
  String get attachmentSaved;

  /// No description provided for @attachmentSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saved to your gallery.'**
  String get attachmentSavedToGallery;

  /// No description provided for @attachmentSavedToFiles.
  ///
  /// In en, this message translates to:
  /// **'Saved to your Downloads.'**
  String get attachmentSavedToFiles;

  /// No description provided for @attachmentSavePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow photo access to save this file to your device.'**
  String get attachmentSavePermissionDenied;

  /// No description provided for @attachmentDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not download the file. Check your connection and try again.'**
  String get attachmentDownloadFailed;

  /// No description provided for @attachmentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'There is no file to download.'**
  String get attachmentUnavailable;

  /// No description provided for @openAttachment.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get openAttachment;

  /// No description provided for @proofIsAFile.
  ///
  /// In en, this message translates to:
  /// **'This proof was submitted as a file rather than an image.'**
  String get proofIsAFile;

  /// No description provided for @weKeepRefiningTheAppForSmootherPlayPlanning.
  ///
  /// In en, this message translates to:
  /// **'We keep refining the app for smoother play planning.'**
  String get weKeepRefiningTheAppForSmootherPlayPlanning;

  /// No description provided for @weWillSendAVerificationCodeToThisEmail.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification code to this email.'**
  String get weWillSendAVerificationCodeToThisEmail;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @websiteOrSocialMediaLink.
  ///
  /// In en, this message translates to:
  /// **'Website or Social Media Link'**
  String get websiteOrSocialMediaLink;

  /// No description provided for @weekendAndClosures.
  ///
  /// In en, this message translates to:
  /// **'Weekend & Closures'**
  String get weekendAndClosures;

  /// No description provided for @weekendDays.
  ///
  /// In en, this message translates to:
  /// **'Weekend days'**
  String get weekendDays;

  /// No description provided for @weekendHolidayAndDiscountPricing.
  ///
  /// In en, this message translates to:
  /// **'Weekend, holiday, and discount pricing'**
  String get weekendHolidayAndDiscountPricing;

  /// No description provided for @weekendHolidaysAndClosures.
  ///
  /// In en, this message translates to:
  /// **'Weekend, Holidays & Closures'**
  String get weekendHolidaysAndClosures;

  /// No description provided for @weekendPrice.
  ///
  /// In en, this message translates to:
  /// **'Weekend price'**
  String get weekendPrice;

  /// No description provided for @whereDoYouWantToPlay.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to play?'**
  String get whereDoYouWantToPlay;

  /// No description provided for @winnerPays.
  ///
  /// In en, this message translates to:
  /// **'Winner pays'**
  String get winnerPays;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @yakStackSolution.
  ///
  /// In en, this message translates to:
  /// **'Yak Stack Solution'**
  String get yakStackSolution;

  /// No description provided for @youBlockedThisUserUnblockThemToSendMessages.
  ///
  /// In en, this message translates to:
  /// **'You blocked this user. Unblock them to send messages.'**
  String get youBlockedThisUserUnblockThemToSendMessages;

  /// No description provided for @youCanUseEitherUploadedFileOrLogoUrlOwnerWillBeA12d1d437.
  ///
  /// In en, this message translates to:
  /// **'You can use either uploaded file or logo URL. Owner will be assigned automatically from logged-in AdminUser.'**
  String get youCanUseEitherUploadedFileOrLogoUrlOwnerWillBeA12d1d437;

  /// No description provided for @youExampleCom.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get youExampleCom;

  /// No description provided for @yourAccountAndBookingInformationStayProtected.
  ///
  /// In en, this message translates to:
  /// **'Your account and booking information stay protected.'**
  String get yourAccountAndBookingInformationStayProtected;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @yourTeam.
  ///
  /// In en, this message translates to:
  /// **'Your team'**
  String get yourTeam;

  /// No description provided for @yourVenues.
  ///
  /// In en, this message translates to:
  /// **'Your Venues'**
  String get yourVenues;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @amenitiesNotes.
  ///
  /// In en, this message translates to:
  /// **'Amenities Notes'**
  String get amenitiesNotes;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @basicPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Basic Price *'**
  String get basicPriceRequired;

  /// No description provided for @bookingAdvanceLimitDays.
  ///
  /// In en, this message translates to:
  /// **'Booking Advance Limit (days) *'**
  String get bookingAdvanceLimitDays;

  /// No description provided for @cancellationWindowHours.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Window (hours)'**
  String get cancellationWindowHours;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get city;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact Email *'**
  String get contactEmail;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone *'**
  String get contactPhone;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country *'**
  String get country;

  /// No description provided for @couponCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon code'**
  String get couponCode;

  /// No description provided for @courtNameTitleCase.
  ///
  /// In en, this message translates to:
  /// **'Court Name'**
  String get courtNameTitleCase;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @depositNprOptional.
  ///
  /// In en, this message translates to:
  /// **'Deposit (NPR, optional)'**
  String get depositNprOptional;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get descriptionRequired;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @emailAddressSentenceCase.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressSentenceCase;

  /// No description provided for @establishedYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Established Year *'**
  String get establishedYearRequired;

  /// No description provided for @exactLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Exact Location *'**
  String get exactLocationRequired;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameSentenceCase.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameSentenceCase;

  /// No description provided for @futsalNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Futsal Name *'**
  String get futsalNameRequired;

  /// No description provided for @futsalSlug.
  ///
  /// In en, this message translates to:
  /// **'Futsal Slug *'**
  String get futsalSlug;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @hourlyRateNpr.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate (NPR)'**
  String get hourlyRateNpr;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @hoursLowercase.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hoursLowercase;

  /// No description provided for @houseRules.
  ///
  /// In en, this message translates to:
  /// **'House Rules *'**
  String get houseRules;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @aNewCodeIsOnItsWay.
  ///
  /// In en, this message translates to:
  /// **'A new code is on its way.'**
  String get aNewCodeIsOnItsWay;

  /// No description provided for @enterTheDigitCodeToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your email to continue.'**
  String get enterTheDigitCodeToContinue;

  /// No description provided for @reEnterYourNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password'**
  String get reEnterYourNewPassword;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get wait;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// No description provided for @passwordMustBeAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMustBeAtLeast8Characters;

  /// No description provided for @passwordResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully.'**
  String get passwordResetSuccessfully;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @pleaseConfirmYourNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmYourNewPassword;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneNumberSentenceCase.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberSentenceCase;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @registrationNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Registration Number (optional)'**
  String get registrationNumberOptional;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember password?'**
  String get rememberPassword;

  /// No description provided for @searchExactPlace.
  ///
  /// In en, this message translates to:
  /// **'Search exact place'**
  String get searchExactPlace;

  /// No description provided for @searchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search members'**
  String get searchMembers;

  /// No description provided for @shopLogoUrl.
  ///
  /// In en, this message translates to:
  /// **'Shop Logo URL'**
  String get shopLogoUrl;

  /// No description provided for @totalUnits.
  ///
  /// In en, this message translates to:
  /// **'Total units'**
  String get totalUnits;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @cloudinaryImageUrlExample.
  ///
  /// In en, this message translates to:
  /// **'https://res.cloudinary.com/demo/image/upload/sample.jpg'**
  String get cloudinaryImageUrlExample;

  /// No description provided for @hamroFutsalWebsiteUrl.
  ///
  /// In en, this message translates to:
  /// **'https://hamrofutsal.com'**
  String get hamroFutsalWebsiteUrl;

  /// No description provided for @hamroFutsalWebsiteUrlWithTrailingSlash.
  ///
  /// In en, this message translates to:
  /// **'https://hamrofutsal.com/'**
  String get hamroFutsalWebsiteUrlWithTrailingSlash;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @urlExample.
  ///
  /// In en, this message translates to:
  /// **'https://example.com'**
  String get urlExample;

  /// No description provided for @venueId.
  ///
  /// In en, this message translates to:
  /// **'Venue ID'**
  String get venueId;

  /// No description provided for @websiteOptional.
  ///
  /// In en, this message translates to:
  /// **'Website (optional)'**
  String get websiteOptional;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get bookingConfirmed;

  /// No description provided for @bookingConfirmedNotification.
  ///
  /// In en, this message translates to:
  /// **'Your 7:00 PM booking at Goal Arena has been confirmed.'**
  String get bookingConfirmedNotification;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @markAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markAsUnread;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @matchReminder.
  ///
  /// In en, this message translates to:
  /// **'Match reminder'**
  String get matchReminder;

  /// No description provided for @matchReminderNotification.
  ///
  /// In en, this message translates to:
  /// **'Your match starts in 2 hours at Riverside Futsal.'**
  String get matchReminderNotification;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @newMessageNotification.
  ///
  /// In en, this message translates to:
  /// **'Suman sent you a message about tomorrow’s match.'**
  String get newMessageNotification;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noUnreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'No unread notifications'**
  String get noUnreadNotifications;

  /// No description provided for @notificationsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Important updates will appear here when they arrive.'**
  String get notificationsWillAppearHere;

  /// No description provided for @oneHourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get oneHourAgo;

  /// No description provided for @opponentRequestNotification.
  ///
  /// In en, this message translates to:
  /// **'Kathmandu Strikers want to play against your team.'**
  String get opponentRequestNotification;

  /// No description provided for @opponentRequestReceived.
  ///
  /// In en, this message translates to:
  /// **'Opponent request received'**
  String get opponentRequestReceived;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get paymentReceived;

  /// No description provided for @paymentReceivedNotification.
  ///
  /// In en, this message translates to:
  /// **'Payment of NPR 1,500 was received successfully.'**
  String get paymentReceivedNotification;

  /// No description provided for @twentyMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'20 min ago'**
  String get twentyMinutesAgo;

  /// No description provided for @twoDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'2 days ago'**
  String get twoDaysAgo;

  /// No description provided for @twoMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'2 min ago'**
  String get twoMinutesAgo;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @weekendOffer.
  ///
  /// In en, this message translates to:
  /// **'Weekend offer'**
  String get weekendOffer;

  /// No description provided for @weekendOfferNotification.
  ///
  /// In en, this message translates to:
  /// **'Book any morning slot this weekend and save 15%.'**
  String get weekendOfferNotification;

  /// No description provided for @yesChange.
  ///
  /// In en, this message translates to:
  /// **'Yes, change'**
  String get yesChange;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @youHaveReadEveryNotification.
  ///
  /// In en, this message translates to:
  /// **'You have read every notification. Nice work!'**
  String get youHaveReadEveryNotification;

  /// No description provided for @bookingPaymentsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Payments linked to your bookings will appear here.'**
  String get bookingPaymentsWillAppearHere;

  /// No description provided for @futsalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Futsal earnings'**
  String get futsalEarnings;

  /// No description provided for @moneyPaidForBookings.
  ///
  /// In en, this message translates to:
  /// **'Money paid for bookings'**
  String get moneyPaidForBookings;

  /// No description provided for @moneyReceivedFromBookings.
  ///
  /// In en, this message translates to:
  /// **'Money received from bookings'**
  String get moneyReceivedFromBookings;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @pendingAmount.
  ///
  /// In en, this message translates to:
  /// **'Pending amount'**
  String get pendingAmount;

  /// No description provided for @playerPayments.
  ///
  /// In en, this message translates to:
  /// **'Player payments'**
  String get playerPayments;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refunded;

  /// No description provided for @refunds.
  ///
  /// In en, this message translates to:
  /// **'Refunds'**
  String get refunds;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get searchTransactions;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total earnings'**
  String get totalEarnings;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// No description provided for @couldNotLoadTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load transaction history'**
  String get couldNotLoadTransactionHistory;

  /// No description provided for @totalIn.
  ///
  /// In en, this message translates to:
  /// **'Total in'**
  String get totalIn;

  /// No description provided for @totalOut.
  ///
  /// In en, this message translates to:
  /// **'Total out'**
  String get totalOut;

  /// No description provided for @netAmount.
  ///
  /// In en, this message translates to:
  /// **'Net amount'**
  String get netAmount;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTransactions;

  /// No description provided for @incoming.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get incoming;

  /// No description provided for @outgoing.
  ///
  /// In en, this message translates to:
  /// **'Money out'**
  String get outgoing;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// No description provided for @grossAmount.
  ///
  /// In en, this message translates to:
  /// **'Gross'**
  String get grossAmount;

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'Net balance'**
  String get netBalance;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @showTransactions.
  ///
  /// In en, this message translates to:
  /// **'Show transactions'**
  String get showTransactions;

  /// No description provided for @pickAStartDateHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a start date to close the range'**
  String get pickAStartDateHint;

  /// No description provided for @pickAnEndDateHint.
  ///
  /// In en, this message translates to:
  /// **'Pick an end date to close the range'**
  String get pickAnEndDateHint;

  /// No description provided for @transactionsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your payments, refunds and payouts will appear here.'**
  String get transactionsWillAppearHere;

  /// No description provided for @vendorRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your vendor upgrade request has been sent to the super admin.'**
  String get vendorRequestSubmitted;

  /// No description provided for @vendorRequestAlreadySubmitted.
  ///
  /// In en, this message translates to:
  /// **'You have already requested to become a vendor.'**
  String get vendorRequestAlreadySubmitted;

  /// No description provided for @authBrandTagline.
  ///
  /// In en, this message translates to:
  /// **'Book your court. Gather your squad. Play.'**
  String get authBrandTagline;

  /// No description provided for @authBrandSubline.
  ///
  /// In en, this message translates to:
  /// **'Courts, bookings and matches in one place — for players and the venues they play at.'**
  String get authBrandSubline;

  /// No description provided for @authBrandHighlightBook.
  ///
  /// In en, this message translates to:
  /// **'Book nearby courts'**
  String get authBrandHighlightBook;

  /// No description provided for @authBrandDetailBook.
  ///
  /// In en, this message translates to:
  /// **'See open slots and prices at venues near you.'**
  String get authBrandDetailBook;

  /// No description provided for @authBrandDetailManage.
  ///
  /// In en, this message translates to:
  /// **'Track, pay for and revisit every booking in one list.'**
  String get authBrandDetailManage;

  /// No description provided for @authBrandDetailPlay.
  ///
  /// In en, this message translates to:
  /// **'Post a match request and find a team to play.'**
  String get authBrandDetailPlay;

  /// No description provided for @authHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get authHowItWorks;

  /// No description provided for @authStepFindCourt.
  ///
  /// In en, this message translates to:
  /// **'Find a court'**
  String get authStepFindCourt;

  /// No description provided for @authStepPickSlot.
  ///
  /// In en, this message translates to:
  /// **'Pick a slot'**
  String get authStepPickSlot;

  /// No description provided for @authStepPlay.
  ///
  /// In en, this message translates to:
  /// **'Show up & play'**
  String get authStepPlay;

  /// No description provided for @authStepListVenue.
  ///
  /// In en, this message translates to:
  /// **'List your venue'**
  String get authStepListVenue;

  /// No description provided for @authStepSetSlots.
  ///
  /// In en, this message translates to:
  /// **'Set slots & prices'**
  String get authStepSetSlots;

  /// No description provided for @authStepGetBooked.
  ///
  /// In en, this message translates to:
  /// **'Get booked'**
  String get authStepGetBooked;

  /// No description provided for @authAlsoInside.
  ///
  /// In en, this message translates to:
  /// **'Also inside'**
  String get authAlsoInside;

  /// No description provided for @authFeatureLiveSlots.
  ///
  /// In en, this message translates to:
  /// **'Live slots'**
  String get authFeatureLiveSlots;

  /// No description provided for @authFeatureOpponents.
  ///
  /// In en, this message translates to:
  /// **'Opponent matching'**
  String get authFeatureOpponents;

  /// No description provided for @authFeatureTeamChat.
  ///
  /// In en, this message translates to:
  /// **'Team chat'**
  String get authFeatureTeamChat;

  /// No description provided for @authFeatureRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get authFeatureRewards;

  /// No description provided for @authFeatureNepaliCalendar.
  ///
  /// In en, this message translates to:
  /// **'Nepali calendar'**
  String get authFeatureNepaliCalendar;

  /// No description provided for @authFeatureWalkIns.
  ///
  /// In en, this message translates to:
  /// **'Walk-in bookings'**
  String get authFeatureWalkIns;

  /// No description provided for @authFeatureExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get authFeatureExpenses;

  /// No description provided for @authFeaturePayouts.
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get authFeaturePayouts;

  /// No description provided for @authFeatureReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get authFeatureReports;

  /// No description provided for @authWorksOn.
  ///
  /// In en, this message translates to:
  /// **'Phone · Tablet · Desktop'**
  String get authWorksOn;

  /// No description provided for @authBrandHighlightManage.
  ///
  /// In en, this message translates to:
  /// **'Manage your bookings'**
  String get authBrandHighlightManage;

  /// No description provided for @authBrandHighlightPlay.
  ///
  /// In en, this message translates to:
  /// **'Challenge opponents'**
  String get authBrandHighlightPlay;

  /// No description provided for @authPlayerHeadline.
  ///
  /// In en, this message translates to:
  /// **'Play more, arrange less'**
  String get authPlayerHeadline;

  /// No description provided for @authPlayerTagline.
  ///
  /// In en, this message translates to:
  /// **'Find a court, rally your squad and get on the pitch — without a single phone call.'**
  String get authPlayerTagline;

  /// No description provided for @authPlayerHighlightDiscover.
  ///
  /// In en, this message translates to:
  /// **'Browse nearby venues with live prices and open slots'**
  String get authPlayerHighlightDiscover;

  /// No description provided for @authPlayerHighlightBook.
  ///
  /// In en, this message translates to:
  /// **'Book and pay in a few taps, then manage it all in one place'**
  String get authPlayerHighlightBook;

  /// No description provided for @authPlayerHighlightCompete.
  ///
  /// In en, this message translates to:
  /// **'Challenge other teams and keep track of every match'**
  String get authPlayerHighlightCompete;

  /// No description provided for @authVendorHeadline.
  ///
  /// In en, this message translates to:
  /// **'Fill your courts, effortlessly'**
  String get authVendorHeadline;

  /// No description provided for @authVendorTagline.
  ///
  /// In en, this message translates to:
  /// **'List your venue, take bookings around the clock and run the whole operation from one dashboard.'**
  String get authVendorTagline;

  /// No description provided for @authVendorHighlightList.
  ///
  /// In en, this message translates to:
  /// **'List your courts with photos, pricing and opening hours'**
  String get authVendorHighlightList;

  /// No description provided for @authVendorHighlightAutomate.
  ///
  /// In en, this message translates to:
  /// **'Accept bookings and payments automatically, day or night'**
  String get authVendorHighlightAutomate;

  /// No description provided for @authVendorHighlightInsights.
  ///
  /// In en, this message translates to:
  /// **'Track earnings, occupancy and your best customers at a glance'**
  String get authVendorHighlightInsights;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequired;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get whatsNew;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get checkingForUpdates;

  /// No description provided for @seeIfANewerVersionIsAvailable.
  ///
  /// In en, this message translates to:
  /// **'See if a newer version is available'**
  String get seeIfANewerVersionIsAvailable;

  /// No description provided for @youAreOnTheLatestVersion.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the latest version.'**
  String get youAreOnTheLatestVersion;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check for updates. Please check your connection and try again.'**
  String get updateCheckFailed;

  /// No description provided for @couldNotOpenTheStore.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the store. Please update from the store app.'**
  String get couldNotOpenTheStore;

  /// No description provided for @updateRequiredToContinue.
  ///
  /// In en, this message translates to:
  /// **'This update is required to keep using Hamro Futsal.'**
  String get updateRequiredToContinue;

  /// No description provided for @updateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'The update download failed. Please try again.'**
  String get updateDownloadFailed;

  /// No description provided for @updateInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t install the update. Please update from the store instead.'**
  String get updateInstallFailed;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading update…'**
  String get downloadingUpdate;

  /// No description provided for @updateDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Update downloaded'**
  String get updateDownloaded;

  /// No description provided for @restartToInstall.
  ///
  /// In en, this message translates to:
  /// **'Restart to install'**
  String get restartToInstall;

  /// No description provided for @restartNow.
  ///
  /// In en, this message translates to:
  /// **'Restart now'**
  String get restartNow;

  /// No description provided for @installingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Installing update…'**
  String get installingUpdate;

  /// No description provided for @updateReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'The update is ready. Restart the app to finish installing it.'**
  String get updateReadyMessage;

  /// No description provided for @openStore.
  ///
  /// In en, this message translates to:
  /// **'Open store'**
  String get openStore;

  /// No description provided for @openPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Open Play Store'**
  String get openPlayStore;

  /// No description provided for @openAppStore.
  ///
  /// In en, this message translates to:
  /// **'Open App Store'**
  String get openAppStore;

  /// No description provided for @newVersionAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'A newer version of Hamro Futsal is available. Update to get the latest features and fixes.'**
  String get newVersionAvailableMessage;

  /// No description provided for @forcedUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'This version of Hamro Futsal is no longer supported. Update to the latest version to continue booking and managing your courts.'**
  String get forcedUpdateMessage;

  /// No description provided for @installedVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installedVersion;

  /// No description provided for @latestVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latestVersion;

  /// No description provided for @downloadSize.
  ///
  /// In en, this message translates to:
  /// **'Download size'**
  String get downloadSize;

  /// No description provided for @updateInBackgroundHint.
  ///
  /// In en, this message translates to:
  /// **'The update downloads in the background — you can keep using the app.'**
  String get updateInBackgroundHint;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @myRewards.
  ///
  /// In en, this message translates to:
  /// **'My rewards'**
  String get myRewards;

  /// No description provided for @rewardPoints.
  ///
  /// In en, this message translates to:
  /// **'Reward points'**
  String get rewardPoints;

  /// No description provided for @availablePoints.
  ///
  /// In en, this message translates to:
  /// **'Available points'**
  String get availablePoints;

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get pointsEarned;

  /// No description provided for @pointsRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get pointsRedeemed;

  /// No description provided for @rewardTier.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get rewardTier;

  /// No description provided for @rewardHistory.
  ///
  /// In en, this message translates to:
  /// **'Reward history'**
  String get rewardHistory;

  /// No description provided for @viewAllRewardHistory.
  ///
  /// In en, this message translates to:
  /// **'View all activity'**
  String get viewAllRewardHistory;

  /// No description provided for @recentRewardActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentRewardActivity;

  /// No description provided for @generateCoupon.
  ///
  /// In en, this message translates to:
  /// **'Generate coupon'**
  String get generateCoupon;

  /// No description provided for @generatingCoupon.
  ///
  /// In en, this message translates to:
  /// **'Generating coupon…'**
  String get generatingCoupon;

  /// No description provided for @couponGenerated.
  ///
  /// In en, this message translates to:
  /// **'Coupon generated'**
  String get couponGenerated;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Coupon code copied'**
  String get codeCopied;

  /// No description provided for @rewardCouponReady.
  ///
  /// In en, this message translates to:
  /// **'Your coupon is ready. Apply it at checkout to get your discount.'**
  String get rewardCouponReady;

  /// No description provided for @rewardProgrammeNote.
  ///
  /// In en, this message translates to:
  /// **'Earn points on every completed booking and convert them into discount coupons.'**
  String get rewardProgrammeNote;

  /// No description provided for @noRewardPointsYet.
  ///
  /// In en, this message translates to:
  /// **'No points yet'**
  String get noRewardPointsYet;

  /// No description provided for @noRewardPointsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete a booking to start earning reward points.'**
  String get noRewardPointsYetMessage;

  /// No description provided for @noRewardHistory.
  ///
  /// In en, this message translates to:
  /// **'No reward activity'**
  String get noRewardHistory;

  /// No description provided for @noRewardHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Your points earned and redeemed will show up here.'**
  String get noRewardHistoryMessage;

  /// No description provided for @pleaseSelectTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Please select a preferred time slot to continue.'**
  String get pleaseSelectTimeSlot;

  /// No description provided for @couldNotLoadRewards.
  ///
  /// In en, this message translates to:
  /// **'Could not load your rewards. Please try again.'**
  String get couldNotLoadRewards;

  /// No description provided for @couldNotLoadRewardHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load your reward history. Please try again.'**
  String get couldNotLoadRewardHistory;

  /// No description provided for @couldNotGenerateRewardCoupon.
  ///
  /// In en, this message translates to:
  /// **'Could not generate a coupon right now. Please try again.'**
  String get couldNotGenerateRewardCoupon;

  /// No description provided for @needMorePointsToRedeem.
  ///
  /// In en, this message translates to:
  /// **'Need more points to redeem'**
  String get needMorePointsToRedeem;

  /// No description provided for @rewardPointsExpiring.
  ///
  /// In en, this message translates to:
  /// **'points expiring on'**
  String get rewardPointsExpiring;

  /// No description provided for @pressBackAgainToLeaveRequest.
  ///
  /// In en, this message translates to:
  /// **'Press back again to leave this request.'**
  String get pressBackAgainToLeaveRequest;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @paymentDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 9KX2M7QF1042'**
  String get paymentDescriptionHint;

  /// No description provided for @paymentDescriptionHelp.
  ///
  /// In en, this message translates to:
  /// **'The venue matches your payment against this, so enter the transaction ID exactly as it appears on your receipt.'**
  String get paymentDescriptionHelp;

  /// No description provided for @paymentDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please provide your transaction ID.'**
  String get paymentDescriptionRequired;

  /// No description provided for @amountDueNow.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get amountDueNow;

  /// No description provided for @paymentAndProof.
  ///
  /// In en, this message translates to:
  /// **'Payment & proof'**
  String get paymentAndProof;

  /// No description provided for @priceSummary.
  ///
  /// In en, this message translates to:
  /// **'Price summary'**
  String get priceSummary;

  /// No description provided for @changeGroupName.
  ///
  /// In en, this message translates to:
  /// **'Change group name'**
  String get changeGroupName;

  /// No description provided for @enterAGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name.'**
  String get enterAGroupName;

  /// No description provided for @groupNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Group name must be 255 characters or fewer.'**
  String get groupNameTooLong;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @groupPhoto.
  ///
  /// In en, this message translates to:
  /// **'Group photo'**
  String get groupPhoto;

  /// No description provided for @groupInfo.
  ///
  /// In en, this message translates to:
  /// **'Group Info'**
  String get groupInfo;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveGroup;

  /// No description provided for @leaveGroupQuestion.
  ///
  /// In en, this message translates to:
  /// **'Leave this group?'**
  String get leaveGroupQuestion;

  /// No description provided for @leaveGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'You will stop receiving messages from this group and it will be removed from your chats.'**
  String get leaveGroupMessage;

  /// No description provided for @leaving.
  ///
  /// In en, this message translates to:
  /// **'Leaving…'**
  String get leaving;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @groupMembersSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a member to see their profile'**
  String get groupMembersSectionHint;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get unknownUser;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @groupFull.
  ///
  /// In en, this message translates to:
  /// **'Group is full'**
  String get groupFull;

  /// No description provided for @tapANameToAddOrRemoveThem.
  ///
  /// In en, this message translates to:
  /// **'Tap a name to add or remove them'**
  String get tapANameToAddOrRemoveThem;

  /// No description provided for @nameTheGroupAndChooseWhoIsInIt.
  ///
  /// In en, this message translates to:
  /// **'Name the group and choose who is in it'**
  String get nameTheGroupAndChooseWhoIsInIt;

  /// No description provided for @createGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroupAction;

  /// No description provided for @groupMemberLimitReached.
  ///
  /// In en, this message translates to:
  /// **'That is the most members a group can hold.'**
  String get groupMemberLimitReached;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @goalkeeper.
  ///
  /// In en, this message translates to:
  /// **'Goalkeeper'**
  String get goalkeeper;

  /// No description provided for @defender.
  ///
  /// In en, this message translates to:
  /// **'Defender'**
  String get defender;

  /// No description provided for @midfielder.
  ///
  /// In en, this message translates to:
  /// **'Midfielder'**
  String get midfielder;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// No description provided for @goalkeeperAbbr.
  ///
  /// In en, this message translates to:
  /// **'GK'**
  String get goalkeeperAbbr;

  /// No description provided for @defenderAbbr.
  ///
  /// In en, this message translates to:
  /// **'DF'**
  String get defenderAbbr;

  /// No description provided for @midfielderAbbr.
  ///
  /// In en, this message translates to:
  /// **'MF'**
  String get midfielderAbbr;

  /// No description provided for @forwardAbbr.
  ///
  /// In en, this message translates to:
  /// **'FW'**
  String get forwardAbbr;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get pendingApproval;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get invitationSent;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @awaitingYourPick.
  ///
  /// In en, this message translates to:
  /// **'Awaiting your pick'**
  String get awaitingYourPick;

  /// No description provided for @autoRejected.
  ///
  /// In en, this message translates to:
  /// **'Auto-rejected'**
  String get autoRejected;

  /// No description provided for @evenSplit.
  ///
  /// In en, this message translates to:
  /// **'Even'**
  String get evenSplit;

  /// No description provided for @customPercent.
  ///
  /// In en, this message translates to:
  /// **'Custom %'**
  String get customPercent;

  /// No description provided for @byTeam.
  ///
  /// In en, this message translates to:
  /// **'By team'**
  String get byTeam;

  /// No description provided for @byResult.
  ///
  /// In en, this message translates to:
  /// **'By result'**
  String get byResult;

  /// No description provided for @paidInFull.
  ///
  /// In en, this message translates to:
  /// **'Paid in full'**
  String get paidInFull;

  /// No description provided for @awaitingPaymentVerification.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment verification'**
  String get awaitingPaymentVerification;

  /// No description provided for @partiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially paid'**
  String get partiallyPaid;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment pending'**
  String get paymentPending;

  /// No description provided for @couldNotParseYourTeams.
  ///
  /// In en, this message translates to:
  /// **'Could not parse your teams from server.'**
  String get couldNotParseYourTeams;

  /// No description provided for @invalidTeam.
  ///
  /// In en, this message translates to:
  /// **'Invalid team.'**
  String get invalidTeam;

  /// No description provided for @couldNotParseTeam.
  ///
  /// In en, this message translates to:
  /// **'Could not parse the team from server.'**
  String get couldNotParseTeam;

  /// No description provided for @couldNotParsePlayerPositions.
  ///
  /// In en, this message translates to:
  /// **'Could not parse player positions from server.'**
  String get couldNotParsePlayerPositions;

  /// No description provided for @couldNotParseOpponentLevels.
  ///
  /// In en, this message translates to:
  /// **'Could not parse opponent levels from server.'**
  String get couldNotParseOpponentLevels;

  /// No description provided for @couldNotReadMatchDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not read the match details.'**
  String get couldNotReadMatchDetails;

  /// No description provided for @couldNotParseMatchDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not parse the match details from server.'**
  String get couldNotParseMatchDetails;

  /// No description provided for @couldNotParseOpponentRequests.
  ///
  /// In en, this message translates to:
  /// **'Could not parse opponent requests from server.'**
  String get couldNotParseOpponentRequests;

  /// No description provided for @requestCouldNotBeFound.
  ///
  /// In en, this message translates to:
  /// **'That request could not be found.'**
  String get requestCouldNotBeFound;

  /// No description provided for @couldNotParseOpponentRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not parse that opponent request.'**
  String get couldNotParseOpponentRequest;

  /// No description provided for @teamNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Team name cannot be empty.'**
  String get teamNameCannotBeEmpty;

  /// No description provided for @playerNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Player name cannot be empty.'**
  String get playerNameCannotBeEmpty;

  /// No description provided for @invalidMember.
  ///
  /// In en, this message translates to:
  /// **'Invalid member.'**
  String get invalidMember;

  /// No description provided for @couldNotParseInvitations.
  ///
  /// In en, this message translates to:
  /// **'Could not parse the invitations from server.'**
  String get couldNotParseInvitations;

  /// No description provided for @couldNotParseAcceptedRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not parse the accepted request from server.'**
  String get couldNotParseAcceptedRequest;

  /// No description provided for @couldNotReadRequestAfterAccepting.
  ///
  /// In en, this message translates to:
  /// **'Could not read the request after accepting.'**
  String get couldNotReadRequestAfterAccepting;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @conditional.
  ///
  /// In en, this message translates to:
  /// **'Conditional'**
  String get conditional;

  /// No description provided for @courtFeeNotSetYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Court fee not set yet'**
  String get courtFeeNotSetYetMessage;

  /// No description provided for @percentMySide.
  ///
  /// In en, this message translates to:
  /// **'{percent}% my side'**
  String percentMySide(int percent);

  /// No description provided for @yourShareOfCourtFee.
  ///
  /// In en, this message translates to:
  /// **'Your share {share} of {total} ({percent}%)'**
  String yourShareOfCourtFee(String share, String total, int percent);

  /// No description provided for @loserWinnerShares.
  ///
  /// In en, this message translates to:
  /// **'Loser {loserShare} ({loserPercent}%) · Winner {winnerShare}'**
  String loserWinnerShares(
    String loserShare,
    int loserPercent,
    String winnerShare,
  );

  /// No description provided for @matchDetailsNotSavedYet.
  ///
  /// In en, this message translates to:
  /// **'The match details have not been saved yet. Go back a step and try again.'**
  String get matchDetailsNotSavedYet;

  /// No description provided for @requestNotOpenedOnServerYet.
  ///
  /// In en, this message translates to:
  /// **'This request has not been opened on the server yet. Go back and save the match details first.'**
  String get requestNotOpenedOnServerYet;

  /// No description provided for @invitationMissingId.
  ///
  /// In en, this message translates to:
  /// **'That invitation is missing its id — refresh and try again.'**
  String get invitationMissingId;

  /// No description provided for @noPlayersYet.
  ///
  /// In en, this message translates to:
  /// **'No players yet'**
  String get noPlayersYet;

  /// No description provided for @playerCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} player} other{{count} players}}'**
  String playerCount(int count);

  /// No description provided for @addYourFirstPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add your first player'**
  String get addYourFirstPlayer;

  /// No description provided for @addPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add Player'**
  String get addPlayer;

  /// No description provided for @couldNotLoadVenuesRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not load venues. Retry'**
  String get couldNotLoadVenuesRetry;

  /// No description provided for @noVenuesMatch.
  ///
  /// In en, this message translates to:
  /// **'No venues match \"{query}\".'**
  String noVenuesMatch(String query);

  /// No description provided for @teamsStillLoading.
  ///
  /// In en, this message translates to:
  /// **'Your teams are still loading — try again in a moment.'**
  String get teamsStillLoading;

  /// No description provided for @findAnOpponent.
  ///
  /// In en, this message translates to:
  /// **'Find an Opponent'**
  String get findAnOpponent;

  /// No description provided for @couldNotLoadOpponentRequests.
  ///
  /// In en, this message translates to:
  /// **'Could not load opponent requests.'**
  String get couldNotLoadOpponentRequests;

  /// No description provided for @couldNotLoadYourTeams.
  ///
  /// In en, this message translates to:
  /// **'Could not load your teams.'**
  String get couldNotLoadYourTeams;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @deleteTeamConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This removes \"{teamName}\" and its players. This can\'t be undone.'**
  String deleteTeamConfirmation(String teamName);

  /// No description provided for @thisPlayer.
  ///
  /// In en, this message translates to:
  /// **'this player'**
  String get thisPlayer;

  /// No description provided for @removePlayerConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This removes \"{playerName}\" from \"{teamName}\". This can\'t be undone.'**
  String removePlayerConfirmation(String playerName, String teamName);

  /// No description provided for @createTeamAndAddPlayersHint.
  ///
  /// In en, this message translates to:
  /// **'Create a team and add players — you\'ll pick it when sending a match request.'**
  String get createTeamAndAddPlayersHint;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team name'**
  String get teamName;

  /// No description provided for @editPlayer.
  ///
  /// In en, this message translates to:
  /// **'Edit Player'**
  String get editPlayer;

  /// No description provided for @playerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get playerNameHint;

  /// No description provided for @playerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Player email'**
  String get playerEmailHint;

  /// No description provided for @positionInTeam.
  ///
  /// In en, this message translates to:
  /// **'Position in {teamName}'**
  String positionInTeam(String teamName);

  /// No description provided for @saveChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesTitle;

  /// No description provided for @selectAnExistingBooking.
  ///
  /// In en, this message translates to:
  /// **'Select an existing booking'**
  String get selectAnExistingBooking;

  /// No description provided for @existingBookingSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The court, date, time and fee are taken from the booking you pick.'**
  String get existingBookingSheetSubtitle;

  /// No description provided for @existingBookingSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Venue, court or booking reference'**
  String get existingBookingSearchHint;

  /// No description provided for @couldNotLoadYourBookingsRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not load your bookings. Retry'**
  String get couldNotLoadYourBookingsRetry;

  /// No description provided for @noBookingMatchesYourSearch.
  ///
  /// In en, this message translates to:
  /// **'No booking matches your search.'**
  String get noBookingMatchesYourSearch;

  /// No description provided for @noUpcomingBookingsToAttach.
  ///
  /// In en, this message translates to:
  /// **'You have no upcoming bookings to attach.\nBook a court first, or enter the venue manually.'**
  String get noUpcomingBookingsToAttach;

  /// No description provided for @courtFee.
  ///
  /// In en, this message translates to:
  /// **'Court fee'**
  String get courtFee;

  /// No description provided for @mySidePays.
  ///
  /// In en, this message translates to:
  /// **'My side pays'**
  String get mySidePays;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// No description provided for @opponent.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get opponent;

  /// No description provided for @perPlayer.
  ///
  /// In en, this message translates to:
  /// **'Per player'**
  String get perPlayer;

  /// No description provided for @perPlayerCount.
  ///
  /// In en, this message translates to:
  /// **'Per player ({count})'**
  String perPlayerCount(int count);

  /// No description provided for @youPayIfLoser.
  ///
  /// In en, this message translates to:
  /// **'You pay (if loser)'**
  String get youPayIfLoser;

  /// No description provided for @youPay.
  ///
  /// In en, this message translates to:
  /// **'You pay'**
  String get youPay;

  /// No description provided for @matchChatNotOpenYet.
  ///
  /// In en, this message translates to:
  /// **'The match chat is not open yet.'**
  String get matchChatNotOpenYet;

  /// No description provided for @matchDetails.
  ///
  /// In en, this message translates to:
  /// **'Match details'**
  String get matchDetails;

  /// No description provided for @matchNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This match is no longer available.'**
  String get matchNoLongerAvailable;

  /// No description provided for @kickoff.
  ///
  /// In en, this message translates to:
  /// **'Kickoff'**
  String get kickoff;

  /// No description provided for @slot.
  ///
  /// In en, this message translates to:
  /// **'Slot'**
  String get slot;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @linkedVenueBooking.
  ///
  /// In en, this message translates to:
  /// **'Linked venue booking'**
  String get linkedVenueBooking;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @venueLinkedToThisMatch.
  ///
  /// In en, this message translates to:
  /// **'Venue linked to this match'**
  String get venueLinkedToThisMatch;

  /// No description provided for @arrangedOutsideTheApp.
  ///
  /// In en, this message translates to:
  /// **'Arranged outside the app'**
  String get arrangedOutsideTheApp;

  /// No description provided for @bookingReference.
  ///
  /// In en, this message translates to:
  /// **'Booking reference'**
  String get bookingReference;

  /// No description provided for @costSplit.
  ///
  /// In en, this message translates to:
  /// **'Cost split'**
  String get costSplit;

  /// No description provided for @totalCourtFee.
  ///
  /// In en, this message translates to:
  /// **'Total court fee'**
  String get totalCourtFee;

  /// No description provided for @matchChat.
  ///
  /// In en, this message translates to:
  /// **'Match chat'**
  String get matchChat;

  /// No description provided for @openMatchChat.
  ///
  /// In en, this message translates to:
  /// **'Open Match Chat'**
  String get openMatchChat;

  /// No description provided for @yourShare.
  ///
  /// In en, this message translates to:
  /// **'Your share'**
  String get yourShare;

  /// No description provided for @opponentShare.
  ///
  /// In en, this message translates to:
  /// **'Opponent share'**
  String get opponentShare;

  /// No description provided for @decidedByResult.
  ///
  /// In en, this message translates to:
  /// **'Decided by result'**
  String get decidedByResult;

  /// No description provided for @versusAbbr.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get versusAbbr;

  /// No description provided for @matchCreatedChatRoomOpened.
  ///
  /// In en, this message translates to:
  /// **'Match created · chat room opened'**
  String get matchCreatedChatRoomOpened;

  /// No description provided for @waitingOnFinalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting on final confirmation'**
  String get waitingOnFinalConfirmation;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @chatRoomCreatedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Chat room created automatically'**
  String get chatRoomCreatedAutomatically;

  /// No description provided for @chatOpensOnceOpponentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Chat opens once the opponent is confirmed'**
  String get chatOpensOnceOpponentConfirmed;

  /// No description provided for @matchChatEnabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Coordinate kit, arrival time and the court fee with the other captain.'**
  String get matchChatEnabledDescription;

  /// No description provided for @matchChatPendingDescription.
  ///
  /// In en, this message translates to:
  /// **'Both captains get access as soon as the match is created.'**
  String get matchChatPendingDescription;

  /// No description provided for @percentInParentheses.
  ///
  /// In en, this message translates to:
  /// **'({percent}%)'**
  String percentInParentheses(int percent);

  /// No description provided for @playTeamQuestion.
  ///
  /// In en, this message translates to:
  /// **'Play {teamName}?'**
  String playTeamQuestion(String teamName);

  /// No description provided for @selectOpponentConfirmSolo.
  ///
  /// In en, this message translates to:
  /// **'The match will be created and the venue linked to this request. A chat room with {teamName} opens automatically.'**
  String selectOpponentConfirmSolo(String teamName);

  /// No description provided for @selectOpponentConfirmWithOthers.
  ///
  /// In en, this message translates to:
  /// **'The match will be created with {teamName} and the venue linked to this request. The other {others, plural, =1{{others} invitation} other{{others} invitations}} will be rejected automatically.'**
  String selectOpponentConfirmWithOthers(String teamName, int others);

  /// No description provided for @confirmOpponent.
  ///
  /// In en, this message translates to:
  /// **'Confirm opponent'**
  String get confirmOpponent;

  /// No description provided for @matchConfirmedWithTeam.
  ///
  /// In en, this message translates to:
  /// **'Match confirmed with {teamName}.'**
  String matchConfirmedWithTeam(String teamName);

  /// No description provided for @matchConfirmedWithTeamOthersRejected.
  ///
  /// In en, this message translates to:
  /// **'Match confirmed with {teamName}. {others, plural, =1{{others} invitation} other{{others} invitations}} auto-rejected.'**
  String matchConfirmedWithTeamOthersRejected(String teamName, int others);

  /// No description provided for @waitingForInvitationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Your request is visible to all eligible teams. As soon as a team accepts, its invitation appears here.'**
  String get waitingForInvitationsMessage;

  /// No description provided for @selectOneOpponentMessage.
  ///
  /// In en, this message translates to:
  /// **'Message a captain to agree the details, then confirm the team you trust. You can wait for more acceptances first — the remaining invitations are rejected automatically once you confirm one.'**
  String get selectOneOpponentMessage;

  /// No description provided for @invitationsReceived.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} invitation received} other{{count} invitations received}}'**
  String invitationsReceived(int count);

  /// No description provided for @totalLoserPaysMore.
  ///
  /// In en, this message translates to:
  /// **'{total} total · loser pays more'**
  String totalLoserPaysMore(String total);

  /// No description provided for @totalWithYourShare.
  ///
  /// In en, this message translates to:
  /// **'{total} total · your share {share} ({percent}%)'**
  String totalWithYourShare(String total, String share, int percent);

  /// No description provided for @theirShare.
  ///
  /// In en, this message translates to:
  /// **'Their share {share}'**
  String theirShare(String share);

  /// No description provided for @loserPaysDecidedByResult.
  ///
  /// In en, this message translates to:
  /// **'Loser pays — decided by the result'**
  String get loserPaysDecidedByResult;

  /// No description provided for @ifTheyLose.
  ///
  /// In en, this message translates to:
  /// **'If they lose {amount}'**
  String ifTheyLose(String amount);

  /// No description provided for @playersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} players'**
  String playersCount(int count);

  /// No description provided for @answeredAt.
  ///
  /// In en, this message translates to:
  /// **'answered {when}'**
  String answeredAt(String when);

  /// No description provided for @acceptedAt.
  ///
  /// In en, this message translates to:
  /// **'accepted {when}'**
  String acceptedAt(String when);

  /// No description provided for @chatWith.
  ///
  /// In en, this message translates to:
  /// **'Chat with {name}'**
  String chatWith(String name);

  /// No description provided for @thisTeam.
  ///
  /// In en, this message translates to:
  /// **'this team'**
  String get thisTeam;

  /// No description provided for @matchConfirmedWith.
  ///
  /// In en, this message translates to:
  /// **'Match confirmed with {opponent}'**
  String matchConfirmedWith(String opponent);

  /// No description provided for @confirmingRejectsOthers.
  ///
  /// In en, this message translates to:
  /// **'Confirming rejects the other {count, plural, =1{{count} invitation} other{{count} invitations}} automatically.'**
  String confirmingRejectsOthers(int count);

  /// No description provided for @invitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get invitations;

  /// No description provided for @requestNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This request is no longer available.'**
  String get requestNoLongerAvailable;

  /// No description provided for @waitingForInvitations.
  ///
  /// In en, this message translates to:
  /// **'Waiting for invitations'**
  String get waitingForInvitations;

  /// No description provided for @selectOneOpponent.
  ///
  /// In en, this message translates to:
  /// **'Select one opponent'**
  String get selectOneOpponent;

  /// No description provided for @noInvitationsYet.
  ///
  /// In en, this message translates to:
  /// **'No invitations yet'**
  String get noInvitationsYet;

  /// No description provided for @loadingInvitations.
  ///
  /// In en, this message translates to:
  /// **'Loading invitations…'**
  String get loadingInvitations;

  /// No description provided for @checkingForNewInvitations.
  ///
  /// In en, this message translates to:
  /// **'Checking for new invitations…'**
  String get checkingForNewInvitations;

  /// No description provided for @waitingForTeamsToAccept.
  ///
  /// In en, this message translates to:
  /// **'Waiting for teams to accept'**
  String get waitingForTeamsToAccept;

  /// No description provided for @pullDownToRefreshInvitations.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh. You will be notified as invitations arrive.'**
  String get pullDownToRefreshInvitations;

  /// No description provided for @viewMatchDetails.
  ///
  /// In en, this message translates to:
  /// **'View match details'**
  String get viewMatchDetails;

  /// No description provided for @selectThisOpponent.
  ///
  /// In en, this message translates to:
  /// **'Select This Opponent'**
  String get selectThisOpponent;

  /// No description provided for @teamCreatedSendAcceptance.
  ///
  /// In en, this message translates to:
  /// **'{teamName} created — you can send your acceptance now.'**
  String teamCreatedSendAcceptance(String teamName);

  /// No description provided for @acceptChallengeGuidance.
  ///
  /// In en, this message translates to:
  /// **'Choose the team that will play and send your acceptance — you can message the requester from the team section first. They may receive several acceptances and pick one opponent. The court fee is settled at the venue.'**
  String get acceptChallengeGuidance;

  /// No description provided for @confirmSquadSizeBeforeCommit.
  ///
  /// In en, this message translates to:
  /// **'Confirm the squad size and timing before you commit a team.'**
  String get confirmSquadSizeBeforeCommit;

  /// No description provided for @needTeamToAcceptChallenge.
  ///
  /// In en, this message translates to:
  /// **'You need a team to accept this challenge. Name it now and add players later.'**
  String get needTeamToAcceptChallenge;

  /// No description provided for @amountCourtFee.
  ///
  /// In en, this message translates to:
  /// **'{amount} court fee'**
  String amountCourtFee(String amount);

  /// No description provided for @feeTheLoserPays.
  ///
  /// In en, this message translates to:
  /// **'{fee} · the loser pays'**
  String feeTheLoserPays(String fee);

  /// No description provided for @feeLoseAndYouPay.
  ///
  /// In en, this message translates to:
  /// **'{fee} · lose and you pay {amount}'**
  String feeLoseAndYouPay(String fee, String amount);

  /// No description provided for @feeLoserPaysAmount.
  ///
  /// In en, this message translates to:
  /// **'{fee} · loser pays {amount}'**
  String feeLoserPaysAmount(String fee, String amount);

  /// No description provided for @feeYourShare.
  ///
  /// In en, this message translates to:
  /// **'{fee} · your share {share} ({percent}%)'**
  String feeYourShare(String fee, String share, int percent);

  /// No description provided for @amountPerPlayer.
  ///
  /// In en, this message translates to:
  /// **'{amount} / player'**
  String amountPerPlayer(String amount);

  /// No description provided for @winAndPayNothingSettledAtVenue.
  ///
  /// In en, this message translates to:
  /// **'Win and you pay nothing. Settled with the venue on match day.'**
  String get winAndPayNothingSettledAtVenue;

  /// No description provided for @rosterTooSmallForFormat.
  ///
  /// In en, this message translates to:
  /// **'This roster has fewer than {formatSize} players for the requested format.'**
  String rosterTooSmallForFormat(int formatSize);

  /// No description provided for @acceptanceReachesRequester.
  ///
  /// In en, this message translates to:
  /// **'Your acceptance reaches the requester as an invitation.'**
  String get acceptanceReachesRequester;

  /// No description provided for @theVenue.
  ///
  /// In en, this message translates to:
  /// **'the venue'**
  String get theVenue;

  /// No description provided for @ifTeamPickedMatchCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'If your team is picked, the match is created at {venue} and a chat room opens for both teams.'**
  String ifTeamPickedMatchCreatedAt(String venue);

  /// No description provided for @somethingWentWrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrongTryAgain;

  /// No description provided for @requesterCannotBeMessagedYet.
  ///
  /// In en, this message translates to:
  /// **'This requester cannot be messaged yet.'**
  String get requesterCannotBeMessagedYet;

  /// No description provided for @acceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Accept request'**
  String get acceptRequest;

  /// No description provided for @acceptanceSentRequesterWillConfirm.
  ///
  /// In en, this message translates to:
  /// **'Acceptance sent — the requester will confirm the opponent.'**
  String get acceptanceSentRequesterWillConfirm;

  /// No description provided for @acceptChallengeNoPaymentNeeded.
  ///
  /// In en, this message translates to:
  /// **'Accept this challenge — no payment needed'**
  String get acceptChallengeNoPaymentNeeded;

  /// No description provided for @messageToTheRequester.
  ///
  /// In en, this message translates to:
  /// **'Message to the requester'**
  String get messageToTheRequester;

  /// No description provided for @anythingOtherCaptainShouldKnow.
  ///
  /// In en, this message translates to:
  /// **'Anything the other captain should know…'**
  String get anythingOtherCaptainShouldKnow;

  /// No description provided for @sendAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Send Acceptance'**
  String get sendAcceptance;

  /// No description provided for @requestHasNoContactToMessage.
  ///
  /// In en, this message translates to:
  /// **'This request did not carry a contact to message.'**
  String get requestHasNoContactToMessage;

  /// No description provided for @teamNameExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Thamel Tigers'**
  String get teamNameExampleHint;

  /// No description provided for @ifYouLose.
  ///
  /// In en, this message translates to:
  /// **'If you lose'**
  String get ifYouLose;

  /// No description provided for @settledWithVenueOnMatchDay.
  ///
  /// In en, this message translates to:
  /// **'Settled with the venue on match day.'**
  String get settledWithVenueOnMatchDay;

  /// No description provided for @whatHappensNext.
  ///
  /// In en, this message translates to:
  /// **'What happens next'**
  String get whatHappensNext;

  /// No description provided for @mayWaitForOtherTeamsThenSelect.
  ///
  /// In en, this message translates to:
  /// **'They may wait for other teams, then select one opponent.'**
  String get mayWaitForOtherTeamsThenSelect;

  /// No description provided for @reviewInvitation.
  ///
  /// In en, this message translates to:
  /// **'Review Invitation'**
  String get reviewInvitation;

  /// No description provided for @reviewInvitations.
  ///
  /// In en, this message translates to:
  /// **'Review {count} Invitations'**
  String reviewInvitations(int count);

  /// No description provided for @matchDetailsLower.
  ///
  /// In en, this message translates to:
  /// **'match details'**
  String get matchDetailsLower;

  /// No description provided for @theCostSplit.
  ///
  /// In en, this message translates to:
  /// **'the cost split'**
  String get theCostSplit;

  /// No description provided for @draftNotPublishedFinishStep.
  ///
  /// In en, this message translates to:
  /// **'Draft — not published yet. Finish {step} to send it out.'**
  String draftNotPublishedFinishStep(String step);

  /// No description provided for @removeRequestConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will remove the request from {teamName}. You can\'t undo this.'**
  String removeRequestConfirmation(String teamName);

  /// No description provided for @courtFeeSplitNotSetYet.
  ///
  /// In en, this message translates to:
  /// **'{total} court fee · split not set yet'**
  String courtFeeSplitNotSetYet(String total);

  /// No description provided for @loserPaysTotal.
  ///
  /// In en, this message translates to:
  /// **'Loser pays · {total} total'**
  String loserPaysTotal(String total);

  /// No description provided for @decidedByMatchResult.
  ///
  /// In en, this message translates to:
  /// **'Decided by match result'**
  String get decidedByMatchResult;

  /// No description provided for @loserPaysAmount.
  ///
  /// In en, this message translates to:
  /// **'Loser pays {amount}'**
  String loserPaysAmount(String amount);

  /// No description provided for @amountTotal.
  ///
  /// In en, this message translates to:
  /// **'{total} total'**
  String amountTotal(String total);

  /// No description provided for @ifLoserTotal.
  ///
  /// In en, this message translates to:
  /// **'{share} if loser · {total} total'**
  String ifLoserTotal(String share, String total);

  /// No description provided for @sharePercentOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{share} · {percent}% of {total}'**
  String sharePercentOfTotal(String share, int percent, String total);

  /// No description provided for @opponentNamed.
  ///
  /// In en, this message translates to:
  /// **'Opponent: {teamName}'**
  String opponentNamed(String teamName);

  /// No description provided for @teamsWantToPlayPickOne.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} team wants to play — pick one} other{{count} teams want to play — pick one}}'**
  String teamsWantToPlayPickOne(int count);

  /// No description provided for @submittedWaitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Submitted — waiting for approval before teams can see it.'**
  String get submittedWaitingForApproval;

  /// No description provided for @acceptanceSentWaitingForPick.
  ///
  /// In en, this message translates to:
  /// **'Acceptance sent — waiting for the requester to pick an opponent'**
  String get acceptanceSentWaitingForPick;

  /// No description provided for @noInvitationsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Requests your team has accepted will appear here until the requester picks an opponent.'**
  String get noInvitationsYetMessage;

  /// No description provided for @needOpponent.
  ///
  /// In en, this message translates to:
  /// **'Need Opponent'**
  String get needOpponent;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @couldNotLoadTheseRequests.
  ///
  /// In en, this message translates to:
  /// **'Could not load these requests.'**
  String get couldNotLoadTheseRequests;

  /// No description provided for @awaitingInvitations.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Invitations'**
  String get awaitingInvitations;

  /// No description provided for @kickOffTimeNotSetYet.
  ///
  /// In en, this message translates to:
  /// **'Kick-off time not set yet'**
  String get kickOffTimeNotSetYet;

  /// No description provided for @venueNotChosenYet.
  ///
  /// In en, this message translates to:
  /// **'Venue not chosen yet'**
  String get venueNotChosenYet;

  /// No description provided for @viewMatchDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'View Match Details'**
  String get viewMatchDetailsTitle;

  /// No description provided for @acceptRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get acceptRequestTitle;

  /// No description provided for @nothingToActOn.
  ///
  /// In en, this message translates to:
  /// **'Nothing to act on'**
  String get nothingToActOn;

  /// No description provided for @openRequestsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Open requests will appear here.'**
  String get openRequestsWillAppearHere;

  /// No description provided for @noRequestsSent.
  ///
  /// In en, this message translates to:
  /// **'No requests sent'**
  String get noRequestsSent;

  /// No description provided for @noRequestsSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Requests you send to opponents will appear here while they wait for a reply.'**
  String get noRequestsSentMessage;

  /// No description provided for @noSettledRequests.
  ///
  /// In en, this message translates to:
  /// **'No settled requests'**
  String get noSettledRequests;

  /// No description provided for @noSettledRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'Accepted, rejected and closed requests will show here.'**
  String get noSettledRequestsMessage;

  /// No description provided for @fillInExternalVenueDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill in the venue, its location, the fee and the booked date and time.'**
  String get fillInExternalVenueDetails;

  /// No description provided for @rsAmount.
  ///
  /// In en, this message translates to:
  /// **'Rs {amount}'**
  String rsAmount(String amount);

  /// No description provided for @maxPlayersLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Players'**
  String maxPlayersLabel(Object count);

  /// No description provided for @whoPlaysGuidance.
  ///
  /// In en, this message translates to:
  /// **'Pick the team that will play — its roster size drives the per-player share shown later — then describe the match you want. The match date and time come from the booking you attach next.'**
  String get whoPlaysGuidance;

  /// No description provided for @noTeamsYetCreateRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'A request is published in a team\'s name, so create the team that will play this match.'**
  String get noTeamsYetCreateRequestMessage;

  /// No description provided for @venueAlreadyBookedMessage.
  ///
  /// In en, this message translates to:
  /// **'A published request always carries a venue, so opponents know exactly where and when they are playing.'**
  String get venueAlreadyBookedMessage;

  /// No description provided for @venueBookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Venue booking confirmed'**
  String get venueBookingConfirmed;

  /// No description provided for @configureCostSplitMessage.
  ///
  /// In en, this message translates to:
  /// **'Decide how the court fee is divided with the opponent. The accepting team sees this exact rule before it pays.'**
  String get configureCostSplitMessage;

  /// No description provided for @reviewAndPublishMessage.
  ///
  /// In en, this message translates to:
  /// **'Once published, every eligible team can see this request and send you an invitation. You pick the opponent you want.'**
  String get reviewAndPublishMessage;

  /// No description provided for @loserPaysPercent.
  ///
  /// In en, this message translates to:
  /// **'Loser pays {percent}%'**
  String loserPaysPercent(int percent);

  /// No description provided for @youPayPercent.
  ///
  /// In en, this message translates to:
  /// **'You pay {percent}%'**
  String youPayPercent(int percent);

  /// No description provided for @afterPublishingNote.
  ///
  /// In en, this message translates to:
  /// **'After publishing, the request becomes visible to all eligible teams and their invitations arrive under My Requests.'**
  String get afterPublishingNote;

  /// No description provided for @bookingReferenceLine.
  ///
  /// In en, this message translates to:
  /// **'Booking {reference}'**
  String bookingReferenceLine(String reference);

  /// No description provided for @teamAndMatch.
  ///
  /// In en, this message translates to:
  /// **'Team & match'**
  String get teamAndMatch;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @teamAndMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your team, format and level'**
  String get teamAndMatchSubtitle;

  /// No description provided for @attachTheCourtBooking.
  ///
  /// In en, this message translates to:
  /// **'Attach the court booking'**
  String get attachTheCourtBooking;

  /// No description provided for @whoPaysWhat.
  ///
  /// In en, this message translates to:
  /// **'Who pays what'**
  String get whoPaysWhat;

  /// No description provided for @reviewAndGoLive.
  ///
  /// In en, this message translates to:
  /// **'Review and go live'**
  String get reviewAndGoLive;

  /// No description provided for @someMatchDetailsStillLoading.
  ///
  /// In en, this message translates to:
  /// **'Some match details are still loading. Please try again.'**
  String get someMatchDetailsStillLoading;

  /// No description provided for @selectTheTeamThatWillPlay.
  ///
  /// In en, this message translates to:
  /// **'Select the team that will play.'**
  String get selectTheTeamThatWillPlay;

  /// No description provided for @pickAMatchTypeToContinue.
  ///
  /// In en, this message translates to:
  /// **'Pick a match type to continue.'**
  String get pickAMatchTypeToContinue;

  /// No description provided for @pickVenueThenConfirmSlot.
  ///
  /// In en, this message translates to:
  /// **'Pick a venue, then confirm a court slot.'**
  String get pickVenueThenConfirmSlot;

  /// No description provided for @selectBookingThatHostsMatch.
  ///
  /// In en, this message translates to:
  /// **'Select the booking that hosts this match.'**
  String get selectBookingThatHostsMatch;

  /// No description provided for @endTimeMustBeAfterStartTime.
  ///
  /// In en, this message translates to:
  /// **'The end time has to be after the start time.'**
  String get endTimeMustBeAfterStartTime;

  /// No description provided for @completeThisStepToContinue.
  ///
  /// In en, this message translates to:
  /// **'Complete this step to continue.'**
  String get completeThisStepToContinue;

  /// No description provided for @selectBookableVenueFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a bookable venue first.'**
  String get selectBookableVenueFirst;

  /// No description provided for @kickoffAndVenue.
  ///
  /// In en, this message translates to:
  /// **'Kickoff & venue'**
  String get kickoffAndVenue;

  /// No description provided for @futsalVenue.
  ///
  /// In en, this message translates to:
  /// **'Futsal venue'**
  String get futsalVenue;

  /// No description provided for @publishRequest.
  ///
  /// In en, this message translates to:
  /// **'Publish Request'**
  String get publishRequest;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @whoPlaysAndWhatMatch.
  ///
  /// In en, this message translates to:
  /// **'Who plays, and what match?'**
  String get whoPlaysAndWhatMatch;

  /// No description provided for @selectOrCreateTeam.
  ///
  /// In en, this message translates to:
  /// **'Select / create team'**
  String get selectOrCreateTeam;

  /// No description provided for @couldNotLoadYourTeamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load your teams'**
  String get couldNotLoadYourTeamsTitle;

  /// No description provided for @couldNotLoadMatchTypes.
  ///
  /// In en, this message translates to:
  /// **'Could not load match types.'**
  String get couldNotLoadMatchTypes;

  /// No description provided for @opponentLevel.
  ///
  /// In en, this message translates to:
  /// **'Opponent Level'**
  String get opponentLevel;

  /// No description provided for @matchPreview.
  ///
  /// In en, this message translates to:
  /// **'Match preview'**
  String get matchPreview;

  /// No description provided for @noTeamSelectedYet.
  ///
  /// In en, this message translates to:
  /// **'No team selected yet'**
  String get noTeamSelectedYet;

  /// No description provided for @dateTimeVenueSetOnNextStep.
  ///
  /// In en, this message translates to:
  /// **'Date, time and venue are set on the next step'**
  String get dateTimeVenueSetOnNextStep;

  /// No description provided for @venueAlreadyBooked.
  ///
  /// In en, this message translates to:
  /// **'Venue already booked?'**
  String get venueAlreadyBooked;

  /// No description provided for @venueArrangement.
  ///
  /// In en, this message translates to:
  /// **'Venue arrangement'**
  String get venueArrangement;

  /// No description provided for @yesAlreadyBookedVenue.
  ///
  /// In en, this message translates to:
  /// **'Yes — I already booked a venue'**
  String get yesAlreadyBookedVenue;

  /// No description provided for @yesAlreadyBookedVenueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Attach one of your bookings, or enter an outside booking.'**
  String get yesAlreadyBookedVenueSubtitle;

  /// No description provided for @noFindAndBookCourtNow.
  ///
  /// In en, this message translates to:
  /// **'No — find and book a court now'**
  String get noFindAndBookCourtNow;

  /// No description provided for @noFindAndBookCourtNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse venues, pick a court, date and time, then confirm.'**
  String get noFindAndBookCourtNowSubtitle;

  /// No description provided for @selectExistingBooking.
  ///
  /// In en, this message translates to:
  /// **'Select existing booking'**
  String get selectExistingBooking;

  /// No description provided for @myBookingsLower.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get myBookingsLower;

  /// No description provided for @bookedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'Booked elsewhere'**
  String get bookedElsewhere;

  /// No description provided for @chooseFromYourBookings.
  ///
  /// In en, this message translates to:
  /// **'Choose from your bookings'**
  String get chooseFromYourBookings;

  /// No description provided for @bookingDetailsFilledInForYou.
  ///
  /// In en, this message translates to:
  /// **'Court, date, time and fee are filled in for you'**
  String get bookingDetailsFilledInForYou;

  /// No description provided for @bookingAttached.
  ///
  /// In en, this message translates to:
  /// **'Booking attached'**
  String get bookingAttached;

  /// No description provided for @venueName.
  ///
  /// In en, this message translates to:
  /// **'Venue name'**
  String get venueName;

  /// No description provided for @enterTheBookedVenue.
  ///
  /// In en, this message translates to:
  /// **'Enter the booked venue'**
  String get enterTheBookedVenue;

  /// No description provided for @enterTheVenueName.
  ///
  /// In en, this message translates to:
  /// **'Enter the venue name'**
  String get enterTheVenueName;

  /// No description provided for @venueLocation.
  ///
  /// In en, this message translates to:
  /// **'Venue location'**
  String get venueLocation;

  /// No description provided for @areaCityOrFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Area, city or full address'**
  String get areaCityOrFullAddress;

  /// No description provided for @enterTheVenueLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter the venue location'**
  String get enterTheVenueLocation;

  /// No description provided for @whatYouPaidForTheCourt.
  ///
  /// In en, this message translates to:
  /// **'What you paid for the court'**
  String get whatYouPaidForTheCourt;

  /// No description provided for @enterTheTotalCourtFee.
  ///
  /// In en, this message translates to:
  /// **'Enter the total court fee'**
  String get enterTheTotalCourtFee;

  /// No description provided for @bookedDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Booked date & time'**
  String get bookedDateAndTime;

  /// No description provided for @findAndBookACourtNow.
  ///
  /// In en, this message translates to:
  /// **'Find and book a court now'**
  String get findAndBookACourtNow;

  /// No description provided for @chooseCourtDateAndSlot.
  ///
  /// In en, this message translates to:
  /// **'Choose a court, date and available time slot'**
  String get chooseCourtDateAndSlot;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @configureTheCostSplitRule.
  ///
  /// In en, this message translates to:
  /// **'Configure the cost split rule'**
  String get configureTheCostSplitRule;

  /// No description provided for @reviewAndPublish.
  ///
  /// In en, this message translates to:
  /// **'Review and publish'**
  String get reviewAndPublish;

  /// No description provided for @addAMessageOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a message (optional)'**
  String get addAMessageOptional;

  /// No description provided for @requestSummary.
  ///
  /// In en, this message translates to:
  /// **'Request summary'**
  String get requestSummary;

  /// No description provided for @match.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get match;

  /// No description provided for @teamCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} team} other{{count} teams}}'**
  String teamCount(int count);

  /// No description provided for @requestCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} request} other{{count} requests}}'**
  String requestCount(int count);

  /// No description provided for @openCount.
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String openCount(int count);

  /// No description provided for @chatUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Chat unavailable'**
  String get chatUnavailable;

  /// No description provided for @couldNotLoadCourtWeek.
  ///
  /// In en, this message translates to:
  /// **'Could not load this court\'s week from the server.'**
  String get couldNotLoadCourtWeek;

  /// No description provided for @couldNotLoadDaySlots.
  ///
  /// In en, this message translates to:
  /// **'Could not load the day\'s slots from the server.'**
  String get couldNotLoadDaySlots;

  /// No description provided for @slotCouldNotBeHeld.
  ///
  /// In en, this message translates to:
  /// **'This slot could not be held. It may have just been booked.'**
  String get slotCouldNotBeHeld;

  /// No description provided for @partlyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partly paid'**
  String get partlyPaid;

  /// No description provided for @venueNumber.
  ///
  /// In en, this message translates to:
  /// **'Venue {id}'**
  String venueNumber(Object id);

  /// No description provided for @courtNumber.
  ///
  /// In en, this message translates to:
  /// **'Court {id}'**
  String courtNumber(Object id);

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @outstandingPayment.
  ///
  /// In en, this message translates to:
  /// **'Outstanding payment'**
  String get outstandingPayment;

  /// No description provided for @onHold.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get onHold;

  /// No description provided for @noSlots.
  ///
  /// In en, this message translates to:
  /// **'No slots'**
  String get noSlots;

  /// No description provided for @courtInactive.
  ///
  /// In en, this message translates to:
  /// **'Court inactive'**
  String get courtInactive;

  /// No description provided for @closedAllDay.
  ///
  /// In en, this message translates to:
  /// **'Closed all day'**
  String get closedAllDay;

  /// No description provided for @noScheduleSet.
  ///
  /// In en, this message translates to:
  /// **'No schedule set'**
  String get noScheduleSet;

  /// No description provided for @weekSunToSat.
  ///
  /// In en, this message translates to:
  /// **'Sun – Sat'**
  String get weekSunToSat;

  /// No description provided for @fromToday.
  ///
  /// In en, this message translates to:
  /// **'From today'**
  String get fromToday;

  /// No description provided for @noSlotsOn.
  ///
  /// In en, this message translates to:
  /// **'No slots on {day}'**
  String noSlotsOn(String day);

  /// No description provided for @closedOn.
  ///
  /// In en, this message translates to:
  /// **'Closed on {day}'**
  String closedOn(String day);

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @liveSlotsDidNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Live slots did not load — showing the court\'s schedule.'**
  String get liveSlotsDidNotLoad;

  /// No description provided for @bookingLower.
  ///
  /// In en, this message translates to:
  /// **'booking'**
  String get bookingLower;

  /// No description provided for @bookingsLower.
  ///
  /// In en, this message translates to:
  /// **'bookings'**
  String get bookingsLower;

  /// No description provided for @bookedLower.
  ///
  /// In en, this message translates to:
  /// **'booked'**
  String get bookedLower;

  /// No description provided for @freeLower.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get freeLower;

  /// No description provided for @valueLower.
  ///
  /// In en, this message translates to:
  /// **'value'**
  String get valueLower;

  /// No description provided for @dueLower.
  ///
  /// In en, this message translates to:
  /// **'due'**
  String get dueLower;

  /// No description provided for @paidLower.
  ///
  /// In en, this message translates to:
  /// **'paid'**
  String get paidLower;

  /// No description provided for @tapToShowOnBoard.
  ///
  /// In en, this message translates to:
  /// **'. Tap to show on board'**
  String get tapToShowOnBoard;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String hoursShort(Object hours);

  /// No description provided for @openCourtHoursBooked.
  ///
  /// In en, this message translates to:
  /// **'{booked} of {sellable} open court-hours booked'**
  String openCourtHoursBooked(Object booked, Object sellable);

  /// No description provided for @hoursPassedUnbooked.
  ///
  /// In en, this message translates to:
  /// **' · {hours} h passed unbooked'**
  String hoursPassedUnbooked(Object hours);

  /// No description provided for @occupancySemantics.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent of open court time booked. {booked} of {sellable} hours.'**
  String occupancySemantics(int percent, Object booked, Object sellable);

  /// No description provided for @closeBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Close booking details'**
  String get closeBookingDetails;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @slots.
  ///
  /// In en, this message translates to:
  /// **'Slots'**
  String get slots;

  /// No description provided for @paymentsHeader.
  ///
  /// In en, this message translates to:
  /// **'PAYMENTS'**
  String get paymentsHeader;

  /// No description provided for @actionsAndReceipt.
  ///
  /// In en, this message translates to:
  /// **'Actions & receipt'**
  String get actionsAndReceipt;

  /// No description provided for @actionsAndReceiptNotInDemo.
  ///
  /// In en, this message translates to:
  /// **'Actions & receipt (not in demo)'**
  String get actionsAndReceiptNotInDemo;

  /// No description provided for @noCourtsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No courts match these filters.'**
  String get noCourtsMatchFilters;

  /// No description provided for @dateSlotsCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'This date\'s slots could not be loaded.'**
  String get dateSlotsCouldNotLoad;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @weekLink.
  ///
  /// In en, this message translates to:
  /// **'Week ›'**
  String get weekLink;

  /// No description provided for @nextFree.
  ///
  /// In en, this message translates to:
  /// **'Next free'**
  String get nextFree;

  /// No description provided for @noneLeft.
  ///
  /// In en, this message translates to:
  /// **'None left'**
  String get noneLeft;

  /// No description provided for @hideEarlier.
  ///
  /// In en, this message translates to:
  /// **'Hide earlier'**
  String get hideEarlier;

  /// No description provided for @noSlotsLeftOnDay.
  ///
  /// In en, this message translates to:
  /// **'No slots left on this day.'**
  String get noSlotsLeftOnDay;

  /// No description provided for @onCourtNow.
  ///
  /// In en, this message translates to:
  /// **'On court now'**
  String get onCourtNow;

  /// No description provided for @nextBooking.
  ///
  /// In en, this message translates to:
  /// **'Next booking'**
  String get nextBooking;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @priceOnConfirmationLower.
  ///
  /// In en, this message translates to:
  /// **'price on confirmation'**
  String get priceOnConfirmationLower;

  /// No description provided for @loadingCourtsSlots.
  ///
  /// In en, this message translates to:
  /// **'Loading courts\' slots'**
  String get loadingCourtsSlots;

  /// No description provided for @courtsFreeSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} court · {free} free} other{{count} courts · {free} free}}'**
  String courtsFreeSummary(int count, Object free);

  /// No description provided for @freeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} free'**
  String freeCount(Object count);

  /// No description provided for @slotsDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration} slots'**
  String slotsDuration(Object duration);

  /// No description provided for @showEarlier.
  ///
  /// In en, this message translates to:
  /// **'Show earlier ({count})'**
  String showEarlier(int count);

  /// No description provided for @bookingTill.
  ///
  /// In en, this message translates to:
  /// **'{name} · till {time}'**
  String bookingTill(Object name, Object time);

  /// No description provided for @availableSlotSemantics.
  ///
  /// In en, this message translates to:
  /// **'{selected, select, true{{time}, selected, {price}. Tap to remove.} other{{time}, available, {price}. Tap to add to booking.}}'**
  String availableSlotSemantics(String time, String selected, String price);

  /// No description provided for @bookedSlotSemantics.
  ///
  /// In en, this message translates to:
  /// **'{time}, {phase}, {customer}, {payment}. Tap for details.'**
  String bookedSlotSemantics(
    String time,
    String phase,
    String customer,
    String payment,
  );

  /// No description provided for @closedSlotSemantics.
  ///
  /// In en, this message translates to:
  /// **'{time}, closed'**
  String closedSlotSemantics(String time);

  /// No description provided for @pastSlotSemantics.
  ///
  /// In en, this message translates to:
  /// **'{time}, past'**
  String pastSlotSemantics(String time);

  /// No description provided for @percentBooked.
  ///
  /// In en, this message translates to:
  /// **'{percent}% booked'**
  String percentBooked(int percent);

  /// No description provided for @there.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get there;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @mondayUpper.
  ///
  /// In en, this message translates to:
  /// **'MONDAY'**
  String get mondayUpper;

  /// No description provided for @tuesdayUpper.
  ///
  /// In en, this message translates to:
  /// **'TUESDAY'**
  String get tuesdayUpper;

  /// No description provided for @wednesdayUpper.
  ///
  /// In en, this message translates to:
  /// **'WEDNESDAY'**
  String get wednesdayUpper;

  /// No description provided for @thursdayUpper.
  ///
  /// In en, this message translates to:
  /// **'THURSDAY'**
  String get thursdayUpper;

  /// No description provided for @fridayUpper.
  ///
  /// In en, this message translates to:
  /// **'FRIDAY'**
  String get fridayUpper;

  /// No description provided for @saturdayUpper.
  ///
  /// In en, this message translates to:
  /// **'SATURDAY'**
  String get saturdayUpper;

  /// No description provided for @sundayUpper.
  ///
  /// In en, this message translates to:
  /// **'SUNDAY'**
  String get sundayUpper;

  /// No description provided for @showingToday.
  ///
  /// In en, this message translates to:
  /// **'Showing today'**
  String get showingToday;

  /// No description provided for @goToToday.
  ///
  /// In en, this message translates to:
  /// **'Go to today'**
  String get goToToday;

  /// No description provided for @showNormalHome.
  ///
  /// In en, this message translates to:
  /// **'Show normal home'**
  String get showNormalHome;

  /// No description provided for @showOperationsHome.
  ///
  /// In en, this message translates to:
  /// **'Show operations home'**
  String get showOperationsHome;

  /// No description provided for @operationsHomeSelected.
  ///
  /// In en, this message translates to:
  /// **'Operations home selected'**
  String get operationsHomeSelected;

  /// No description provided for @normalHomeSelected.
  ///
  /// In en, this message translates to:
  /// **'Normal home selected'**
  String get normalHomeSelected;

  /// No description provided for @ops.
  ///
  /// In en, this message translates to:
  /// **'Ops'**
  String get ops;

  /// No description provided for @oneVenue.
  ///
  /// In en, this message translates to:
  /// **'1 venue'**
  String get oneVenue;

  /// No description provided for @allCourts.
  ///
  /// In en, this message translates to:
  /// **'All courts'**
  String get allCourts;

  /// No description provided for @oneCourt.
  ///
  /// In en, this message translates to:
  /// **'1 court'**
  String get oneCourt;

  /// No description provided for @bookingStatus.
  ///
  /// In en, this message translates to:
  /// **'Booking status'**
  String get bookingStatus;

  /// No description provided for @anyStatus.
  ///
  /// In en, this message translates to:
  /// **'Any status'**
  String get anyStatus;

  /// No description provided for @namePhoneOrReference.
  ///
  /// In en, this message translates to:
  /// **'Name, phone or reference'**
  String get namePhoneOrReference;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFilters;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatches;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @greetingWithName.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name} 👋'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @selectedDateChange.
  ///
  /// In en, this message translates to:
  /// **'Selected date {date}. Change date'**
  String selectedDateChange(String date);

  /// No description provided for @venuesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} venues'**
  String venuesCount(int count);

  /// No description provided for @courtsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} courts'**
  String courtsCount(int count);

  /// No description provided for @searchIn.
  ///
  /// In en, this message translates to:
  /// **'Search {what}'**
  String searchIn(String what);

  /// No description provided for @allOf.
  ///
  /// In en, this message translates to:
  /// **'All {what}'**
  String allOf(String what);

  /// No description provided for @applyCount.
  ///
  /// In en, this message translates to:
  /// **'Apply ({count})'**
  String applyCount(int count);

  /// No description provided for @noCourtsMatchVenueFilter.
  ///
  /// In en, this message translates to:
  /// **'No courts match the venue filter.'**
  String get noCourtsMatchVenueFilter;

  /// No description provided for @fullThisWeek.
  ///
  /// In en, this message translates to:
  /// **'full this week'**
  String get fullThisWeek;

  /// No description provided for @previousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// No description provided for @weekStartsFrom.
  ///
  /// In en, this message translates to:
  /// **'Week starts from'**
  String get weekStartsFrom;

  /// No description provided for @weekStartsFromHeader.
  ///
  /// In en, this message translates to:
  /// **'WEEK STARTS FROM'**
  String get weekStartsFromHeader;

  /// No description provided for @sundayInitial.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sundayInitial;

  /// No description provided for @mondayInitial.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get mondayInitial;

  /// No description provided for @tuesdayInitial.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get tuesdayInitial;

  /// No description provided for @wednesdayInitial.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wednesdayInitial;

  /// No description provided for @thursdayInitial.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get thursdayInitial;

  /// No description provided for @fridayInitial.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fridayInitial;

  /// No description provided for @saturdayInitial.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get saturdayInitial;

  /// No description provided for @calendarWeek.
  ///
  /// In en, this message translates to:
  /// **'Calendar week'**
  String get calendarWeek;

  /// No description provided for @startingToday.
  ///
  /// In en, this message translates to:
  /// **'Starting today'**
  String get startingToday;

  /// No description provided for @sundayToSaturday.
  ///
  /// In en, this message translates to:
  /// **'Sunday to Saturday'**
  String get sundayToSaturday;

  /// No description provided for @todayAndNextSixDays.
  ///
  /// In en, this message translates to:
  /// **'Today and the next 6 days'**
  String get todayAndNextSixDays;

  /// No description provided for @timeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time slot'**
  String get timeSlot;

  /// No description provided for @sameBooking.
  ///
  /// In en, this message translates to:
  /// **'Same booking'**
  String get sameBooking;

  /// No description provided for @customerLower.
  ///
  /// In en, this message translates to:
  /// **'customer'**
  String get customerLower;

  /// No description provided for @closedLower.
  ///
  /// In en, this message translates to:
  /// **'closed'**
  String get closedLower;

  /// No description provided for @loadingCourtWeek.
  ///
  /// In en, this message translates to:
  /// **'Loading this court\'s week'**
  String get loadingCourtWeek;

  /// No description provided for @thisWeekRange.
  ///
  /// In en, this message translates to:
  /// **'This week · {range}'**
  String thisWeekRange(String range);

  /// No description provided for @courtClosedAllWeek.
  ///
  /// In en, this message translates to:
  /// **'{court} is closed all week.'**
  String courtClosedAllWeek(String court);

  /// No description provided for @courtHasNoSlotsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'{court} has no slots set for this week.'**
  String courtHasNoSlotsThisWeek(String court);

  /// No description provided for @timeRangeSemantics.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String timeRangeSemantics(String start, String end);

  /// No description provided for @weekAvailableSlotSemantics.
  ///
  /// In en, this message translates to:
  /// **'{selected, select, true{{when}, selected, {price}} other{{when}, available, {price}}}'**
  String weekAvailableSlotSemantics(String when, String selected, String price);

  /// No description provided for @weekBookedSlotSemantics.
  ///
  /// In en, this message translates to:
  /// **'{when}, {phase}, {customer}, {payment}'**
  String weekBookedSlotSemantics(
    String when,
    String phase,
    String customer,
    String payment,
  );

  /// No description provided for @slotNoteSemantics.
  ///
  /// In en, this message translates to:
  /// **'{when}, {note}'**
  String slotNoteSemantics(String when, String note);

  /// No description provided for @noSlotSemantics.
  ///
  /// In en, this message translates to:
  /// **'{when}, no slot'**
  String noSlotSemantics(String when);

  /// No description provided for @couldNotLoadYourVenues.
  ///
  /// In en, this message translates to:
  /// **'Could not load your venues'**
  String get couldNotLoadYourVenues;

  /// No description provided for @checkConnectionAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and retry.'**
  String get checkConnectionAndRetry;

  /// No description provided for @noVenuesToManageYet.
  ///
  /// In en, this message translates to:
  /// **'No venues to manage yet'**
  String get noVenuesToManageYet;

  /// No description provided for @noVenuesToManageMessage.
  ///
  /// In en, this message translates to:
  /// **'Once a venue with courts is approved, today\'s bookings and availability appear here.'**
  String get noVenuesToManageMessage;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @bookingsForDateCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Bookings for this date could not be loaded.'**
  String get bookingsForDateCouldNotLoad;

  /// No description provided for @priceOnConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Price on confirmation'**
  String get priceOnConfirmation;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @loadingTodaysOperations.
  ///
  /// In en, this message translates to:
  /// **'Loading today\'s operations'**
  String get loadingTodaysOperations;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @statusKey.
  ///
  /// In en, this message translates to:
  /// **'STATUS KEY'**
  String get statusKey;

  /// No description provided for @hideStatuses.
  ///
  /// In en, this message translates to:
  /// **'Hide statuses'**
  String get hideStatuses;

  /// No description provided for @viewStatuses.
  ///
  /// In en, this message translates to:
  /// **'View statuses'**
  String get viewStatuses;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @everyCourtToday.
  ///
  /// In en, this message translates to:
  /// **'Every court today'**
  String get everyCourtToday;

  /// No description provided for @oneCourtWholeWeek.
  ///
  /// In en, this message translates to:
  /// **'One court, whole week'**
  String get oneCourtWholeWeek;

  /// No description provided for @todayWithDate.
  ///
  /// In en, this message translates to:
  /// **'Today · {date}'**
  String todayWithDate(String date);

  /// No description provided for @selectionHeadline.
  ///
  /// In en, this message translates to:
  /// **'{slots, plural, =1{{slots} slot} other{{slots} slots}} · {hours} court-h'**
  String selectionHeadline(int slots, String hours);

  /// No description provided for @estimatedPrice.
  ///
  /// In en, this message translates to:
  /// **'{allPriced, select, true{Est. {amount}} other{Est. from {amount}}}'**
  String estimatedPrice(String amount, String allPriced);

  /// No description provided for @courtsPriceDetail.
  ///
  /// In en, this message translates to:
  /// **'{courts, plural, =1{{courts} court} other{{courts} courts}} · {price}'**
  String courtsPriceDetail(int courts, String price);

  /// No description provided for @selectedSummarySemantics.
  ///
  /// In en, this message translates to:
  /// **'Selected: {headline}, {detail}'**
  String selectedSummarySemantics(String headline, String detail);

  /// No description provided for @couldNotReadCandidates.
  ///
  /// In en, this message translates to:
  /// **'Could not read candidates from the server.'**
  String get couldNotReadCandidates;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @enterAmountForEveryPayment.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount for every payment, or remove it.'**
  String get enterAmountForEveryPayment;

  /// No description provided for @releaseHeldSlotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Release held slots?'**
  String get releaseHeldSlotsTitle;

  /// No description provided for @releaseOneHeldSlotMessage.
  ///
  /// In en, this message translates to:
  /// **'The slot held for this booking goes back on sale. Your selection is kept.'**
  String get releaseOneHeldSlotMessage;

  /// No description provided for @keepReviewing.
  ///
  /// In en, this message translates to:
  /// **'Keep reviewing'**
  String get keepReviewing;

  /// No description provided for @releaseAndClose.
  ///
  /// In en, this message translates to:
  /// **'Release & close'**
  String get releaseAndClose;

  /// No description provided for @removeAll.
  ///
  /// In en, this message translates to:
  /// **'Remove all'**
  String get removeAll;

  /// No description provided for @manualBookingSentence.
  ///
  /// In en, this message translates to:
  /// **'Manual booking'**
  String get manualBookingSentence;

  /// No description provided for @customerAndPayment.
  ///
  /// In en, this message translates to:
  /// **'Customer & payment'**
  String get customerAndPayment;

  /// No description provided for @reviewBooking.
  ///
  /// In en, this message translates to:
  /// **'Review booking'**
  String get reviewBooking;

  /// No description provided for @pickFreeSlotsOnBoard.
  ///
  /// In en, this message translates to:
  /// **'Pick free slots on the board'**
  String get pickFreeSlotsOnBoard;

  /// No description provided for @closePanel.
  ///
  /// In en, this message translates to:
  /// **'Close panel'**
  String get closePanel;

  /// No description provided for @bookForToday.
  ///
  /// In en, this message translates to:
  /// **'Book for today'**
  String get bookForToday;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get customerName;

  /// No description provided for @enterCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Enter the customer\'s name'**
  String get enterCustomerName;

  /// No description provided for @enterCustomerPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter the customer\'s phone number'**
  String get enterCustomerPhone;

  /// No description provided for @enterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterValidPhoneNumber;

  /// No description provided for @amountReceivedNpr.
  ///
  /// In en, this message translates to:
  /// **'Amount received (NPR)'**
  String get amountReceivedNpr;

  /// No description provided for @enterAmountOrRemovePayment.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount, or remove this payment'**
  String get enterAmountOrRemovePayment;

  /// No description provided for @addPaymentRemark.
  ///
  /// In en, this message translates to:
  /// **'Add a payment remark'**
  String get addPaymentRemark;

  /// No description provided for @subtotalEstimateFrom.
  ///
  /// In en, this message translates to:
  /// **'Subtotal (estimate, from)'**
  String get subtotalEstimateFrom;

  /// No description provided for @subtotalEstimate.
  ///
  /// In en, this message translates to:
  /// **'Subtotal (estimate)'**
  String get subtotalEstimate;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @finalPricesFromServerFootnote.
  ///
  /// In en, this message translates to:
  /// **'Final prices come from the server when the slots are held on the next step.'**
  String get finalPricesFromServerFootnote;

  /// No description provided for @nothingWasBookedReason.
  ///
  /// In en, this message translates to:
  /// **'{message} Nothing was booked.'**
  String nothingWasBookedReason(String message);

  /// No description provided for @slotConflictNothingBooked.
  ///
  /// In en, this message translates to:
  /// **'{court}, {start}–{end}: {message} Nothing was booked.'**
  String slotConflictNothingBooked(
    String court,
    String start,
    String end,
    String message,
  );

  /// No description provided for @receivedMoreThanPayable.
  ///
  /// In en, this message translates to:
  /// **'Received ({received}) is more than the payable total ({payable}).'**
  String receivedMoreThanPayable(String received, String payable);

  /// No description provided for @nothingBookedSlotsStillHeld.
  ///
  /// In en, this message translates to:
  /// **'Nothing was booked: {reason} The slots are still held — confirm again to retry.'**
  String nothingBookedSlotsStillHeld(String reason);

  /// No description provided for @nothingBookedSlotsStillHeldNoReason.
  ///
  /// In en, this message translates to:
  /// **'Nothing was booked. The slots are still held — confirm again to retry.'**
  String get nothingBookedSlotsStillHeldNoReason;

  /// No description provided for @releaseHeldSlotsMessage.
  ///
  /// In en, this message translates to:
  /// **'The {count} slots held for this booking go back on sale. Your selection is kept.'**
  String releaseHeldSlotsMessage(int count);

  /// No description provided for @removeAllSlotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all {count} slots?'**
  String removeAllSlotsTitle(int count);

  /// No description provided for @slotsAndCourtsCount.
  ///
  /// In en, this message translates to:
  /// **'{slots, plural, =1{{slots} slot} other{{slots} slots}} · {courts, plural, =1{{courts} court} other{{courts} courts}}'**
  String slotsAndCourtsCount(int slots, int courts);

  /// No description provided for @methodReceivedNpr.
  ///
  /// In en, this message translates to:
  /// **'{method} received (NPR)'**
  String methodReceivedNpr(String method);

  /// No description provided for @moreThanTheTotal.
  ///
  /// In en, this message translates to:
  /// **'More than the total ({total})'**
  String moreThanTheTotal(String total);

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add {method}'**
  String addPaymentMethod(String method);

  /// No description provided for @existingCandidates.
  ///
  /// In en, this message translates to:
  /// **'Existing candidates'**
  String get existingCandidates;

  /// No description provided for @hideCandidates.
  ///
  /// In en, this message translates to:
  /// **'Hide candidates'**
  String get hideCandidates;

  /// No description provided for @noMatchingCandidate.
  ///
  /// In en, this message translates to:
  /// **'No matching candidate. Continue with these details to create a new customer.'**
  String get noMatchingCandidate;

  /// No description provided for @loadMoreCandidates.
  ///
  /// In en, this message translates to:
  /// **'Load more candidates'**
  String get loadMoreCandidates;

  /// No description provided for @unnamedCustomer.
  ///
  /// In en, this message translates to:
  /// **'Unnamed customer'**
  String get unnamedCustomer;

  /// No description provided for @reviewedRevisedPrices.
  ///
  /// In en, this message translates to:
  /// **'The server priced some slots differently from the board. I have reviewed the revised prices.'**
  String get reviewedRevisedPrices;

  /// No description provided for @payable.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get payable;

  /// No description provided for @receivedNow.
  ///
  /// In en, this message translates to:
  /// **'Received now'**
  String get receivedNow;

  /// No description provided for @remainingBalance.
  ///
  /// In en, this message translates to:
  /// **'Remaining balance'**
  String get remainingBalance;

  /// No description provided for @manualSourceFootnote.
  ///
  /// In en, this message translates to:
  /// **'Source: Manual / Vendor. Discounts and fees are applied by the server where configured.'**
  String get manualSourceFootnote;

  /// No description provided for @paymentMethodLine.
  ///
  /// In en, this message translates to:
  /// **'Payment method · {methods}'**
  String paymentMethodLine(String methods);

  /// No description provided for @paymentStatusLine.
  ///
  /// In en, this message translates to:
  /// **'Payment status · {status}'**
  String paymentStatusLine(String status);

  /// No description provided for @bookingStatusLine.
  ///
  /// In en, this message translates to:
  /// **'Booking status · {status}'**
  String bookingStatusLine(String status);

  /// No description provided for @receivedNowBy.
  ///
  /// In en, this message translates to:
  /// **'Received now ({method})'**
  String receivedNowBy(String method);

  /// No description provided for @bookedFor.
  ///
  /// In en, this message translates to:
  /// **'Booked for {name}'**
  String bookedFor(String name);

  /// No description provided for @bookingsFor.
  ///
  /// In en, this message translates to:
  /// **'{count} bookings for {name}'**
  String bookingsFor(int count, String name);

  /// No description provided for @paymentPendingToCollect.
  ///
  /// In en, this message translates to:
  /// **'Payment pending · {amount} to collect'**
  String paymentPendingToCollect(String amount);

  /// No description provided for @paidInFullBy.
  ///
  /// In en, this message translates to:
  /// **'Paid in full · {methods}'**
  String paidInFullBy(String methods);

  /// No description provided for @paidAndToCollect.
  ///
  /// In en, this message translates to:
  /// **'{paid} paid · {due} to collect'**
  String paidAndToCollect(String paid, String due);

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @holdSlotsAndReview.
  ///
  /// In en, this message translates to:
  /// **'Hold slots & review'**
  String get holdSlotsAndReview;

  /// No description provided for @confirmBookingSentence.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBookingSentence;

  /// No description provided for @newBooking.
  ///
  /// In en, this message translates to:
  /// **'New booking'**
  String get newBooking;

  /// No description provided for @clearAllSentence.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllSentence;

  /// No description provided for @tapFreeSlotsOnBoard.
  ///
  /// In en, this message translates to:
  /// **'Tap free slots on the board'**
  String get tapFreeSlotsOnBoard;

  /// No description provided for @pickAnyMixOfSlots.
  ///
  /// In en, this message translates to:
  /// **'Pick any mix of courts, venues and times. Separate times stay separate — the gap is never booked.'**
  String get pickAnyMixOfSlots;

  /// No description provided for @pricedOnHold.
  ///
  /// In en, this message translates to:
  /// **'Priced on hold'**
  String get pricedOnHold;

  /// No description provided for @holdExpired.
  ///
  /// In en, this message translates to:
  /// **'Hold expired — confirming will recheck availability.'**
  String get holdExpired;

  /// No description provided for @maybeFromPrice.
  ///
  /// In en, this message translates to:
  /// **'{isFrom, select, true{from {amount}} other{{amount}}}'**
  String maybeFromPrice(String amount, String isFrom);

  /// No description provided for @selectionFooterSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} slot} other{{count} slots}} · {hours} court-h · {price}'**
  String selectionFooterSummary(int count, String hours, String price);

  /// No description provided for @removeSlotAt.
  ///
  /// In en, this message translates to:
  /// **'Remove {time}'**
  String removeSlotAt(String time);

  /// No description provided for @ticketRangeLine.
  ///
  /// In en, this message translates to:
  /// **'{date} · {start} – {end} ({duration}, {count, plural, =1{{count} slot} other{{count} slots}})'**
  String ticketRangeLine(
    String date,
    String start,
    String end,
    String duration,
    int count,
  );

  /// No description provided for @bookingNumber.
  ///
  /// In en, this message translates to:
  /// **'Booking #{id}'**
  String bookingNumber(String id);

  /// No description provided for @wasPrice.
  ///
  /// In en, this message translates to:
  /// **'was {amount}'**
  String wasPrice(String amount);

  /// No description provided for @slotsHeldFor.
  ///
  /// In en, this message translates to:
  /// **'Slots held for {minutes}:{seconds}'**
  String slotsHeldFor(String minutes, String seconds);

  /// No description provided for @slotsCountWithTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} slot} other{{count} slots}} · {total}'**
  String slotsCountWithTotal(int count, String total);

  /// No description provided for @removeThisPayment.
  ///
  /// In en, this message translates to:
  /// **'Remove this payment'**
  String get removeThisPayment;

  /// No description provided for @paidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid by {method}'**
  String paidBy(String method);

  /// No description provided for @stepOfThree.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 3, {label}'**
  String stepOfThree(String step, String label);

  /// No description provided for @floodlights.
  ///
  /// In en, this message translates to:
  /// **'Floodlights'**
  String get floodlights;

  /// No description provided for @parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parking;

  /// No description provided for @changingRoom.
  ///
  /// In en, this message translates to:
  /// **'Changing Room'**
  String get changingRoom;

  /// No description provided for @shower.
  ///
  /// In en, this message translates to:
  /// **'Shower'**
  String get shower;

  /// No description provided for @wiFi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get wiFi;

  /// No description provided for @firstAid.
  ///
  /// In en, this message translates to:
  /// **'First Aid'**
  String get firstAid;

  /// No description provided for @liveScoreboard.
  ///
  /// In en, this message translates to:
  /// **'Live Scoreboard'**
  String get liveScoreboard;

  /// No description provided for @warmUpZone.
  ///
  /// In en, this message translates to:
  /// **'Warm-Up Zone'**
  String get warmUpZone;

  /// No description provided for @cafeteria.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria'**
  String get cafeteria;

  /// No description provided for @spectatorSeating.
  ///
  /// In en, this message translates to:
  /// **'Spectator Seating'**
  String get spectatorSeating;

  /// No description provided for @equipmentRental.
  ///
  /// In en, this message translates to:
  /// **'Equipment Rental'**
  String get equipmentRental;

  /// No description provided for @lockerStorage.
  ///
  /// In en, this message translates to:
  /// **'Locker Storage'**
  String get lockerStorage;

  /// No description provided for @goalNets.
  ///
  /// In en, this message translates to:
  /// **'Goal Nets'**
  String get goalNets;

  /// No description provided for @scoreboard.
  ///
  /// In en, this message translates to:
  /// **'Scoreboard'**
  String get scoreboard;

  /// No description provided for @ballStand.
  ///
  /// In en, this message translates to:
  /// **'Ball Stand'**
  String get ballStand;

  /// No description provided for @benches.
  ///
  /// In en, this message translates to:
  /// **'Benches'**
  String get benches;

  /// No description provided for @drinkingWater.
  ///
  /// In en, this message translates to:
  /// **'Drinking Water'**
  String get drinkingWater;

  /// No description provided for @lighting.
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get lighting;

  /// No description provided for @indoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get indoor;

  /// No description provided for @roofed.
  ///
  /// In en, this message translates to:
  /// **'Roofed'**
  String get roofed;

  /// No description provided for @changingArea.
  ///
  /// In en, this message translates to:
  /// **'Changing Area'**
  String get changingArea;

  /// No description provided for @washroomAccess.
  ///
  /// In en, this message translates to:
  /// **'Washroom Access'**
  String get washroomAccess;

  /// No description provided for @parkingAccess.
  ///
  /// In en, this message translates to:
  /// **'Parking Access'**
  String get parkingAccess;

  /// No description provided for @spectatorZone.
  ///
  /// In en, this message translates to:
  /// **'Spectator Zone'**
  String get spectatorZone;

  /// No description provided for @outdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get outdoor;

  /// No description provided for @vendorOnboardingComplete.
  ///
  /// In en, this message translates to:
  /// **'Vendor onboarding is complete.'**
  String get vendorOnboardingComplete;

  /// No description provided for @draftSaveFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Draft save failed. Try again.'**
  String get draftSaveFailedTryAgain;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @selectValidStartAndEndTime.
  ///
  /// In en, this message translates to:
  /// **'Select a valid start and end time.'**
  String get selectValidStartAndEndTime;

  /// No description provided for @startAndEndTimeCannotBeSame.
  ///
  /// In en, this message translates to:
  /// **'Start and end time cannot be the same.'**
  String get startAndEndTimeCannotBeSame;

  /// No description provided for @anotherSlot.
  ///
  /// In en, this message translates to:
  /// **'another slot'**
  String get anotherSlot;

  /// No description provided for @timeSlotAlreadyExistsOnSelectedDays.
  ///
  /// In en, this message translates to:
  /// **'This time slot already exists on the selected day(s).'**
  String get timeSlotAlreadyExistsOnSelectedDays;

  /// No description provided for @timeOverlapsWithOnSelectedDays.
  ///
  /// In en, this message translates to:
  /// **'This time overlaps with {name} on the selected day(s).'**
  String timeOverlapsWithOnSelectedDays(String name);

  /// No description provided for @provideFutsalName.
  ///
  /// In en, this message translates to:
  /// **'Please provide the name of your futsal.'**
  String get provideFutsalName;

  /// No description provided for @uniqueSlugRequired.
  ///
  /// In en, this message translates to:
  /// **'A unique slug is required for your futsal profile.'**
  String get uniqueSlugRequired;

  /// No description provided for @slugInvalidCharacters.
  ///
  /// In en, this message translates to:
  /// **'The slug may only contain lowercase letters, numbers, and hyphens.'**
  String get slugInvalidCharacters;

  /// No description provided for @enterValidContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid contact phone number.'**
  String get enterValidContactPhone;

  /// No description provided for @enterValidContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid contact email address.'**
  String get enterValidContactEmail;

  /// No description provided for @provideValidWebsiteOrSocialLink.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid website or social media link (including http/https).'**
  String get provideValidWebsiteOrSocialLink;

  /// No description provided for @provideFutsalDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide a description for your futsal.'**
  String get provideFutsalDescription;

  /// No description provided for @enterCompleteFutsalAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete address of your futsal.'**
  String get enterCompleteFutsalAddress;

  /// No description provided for @specifyFutsalExactLocation.
  ///
  /// In en, this message translates to:
  /// **'Please specify the exact location of your futsal.'**
  String get specifyFutsalExactLocation;

  /// No description provided for @provideLongitudeAndLatitude.
  ///
  /// In en, this message translates to:
  /// **'Please provide both longitude and latitude coordinates.'**
  String get provideLongitudeAndLatitude;

  /// No description provided for @selectAtLeastOneFutsalAmenityOrFeature.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one amenity or feature for your futsal.'**
  String get selectAtLeastOneFutsalAmenityOrFeature;

  /// No description provided for @specifyCancellationPolicy.
  ///
  /// In en, this message translates to:
  /// **'Please specify your cancellation policy.'**
  String get specifyCancellationPolicy;

  /// No description provided for @provideFutsalRules.
  ///
  /// In en, this message translates to:
  /// **'Please provide the rules for your futsal.'**
  String get provideFutsalRules;

  /// No description provided for @specifyCommissionPercentage.
  ///
  /// In en, this message translates to:
  /// **'Please specify the commission percentage.'**
  String get specifyCommissionPercentage;

  /// No description provided for @uploadFutsalCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Please upload a cover image for your futsal.'**
  String get uploadFutsalCoverImage;

  /// No description provided for @uploadAtLeastOneGalleryImage.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least one image to the futsal gallery.'**
  String get uploadAtLeastOneGalleryImage;

  /// No description provided for @uploadRequiredCompanyDocuments.
  ///
  /// In en, this message translates to:
  /// **'Please upload the required company documents before proceeding.'**
  String get uploadRequiredCompanyDocuments;

  /// No description provided for @enterCourtName.
  ///
  /// In en, this message translates to:
  /// **'Enter the court name.'**
  String get enterCourtName;

  /// No description provided for @enterCourtBasePrice.
  ///
  /// In en, this message translates to:
  /// **'Enter the court base price.'**
  String get enterCourtBasePrice;

  /// No description provided for @selectCourtType.
  ///
  /// In en, this message translates to:
  /// **'Select the court type.'**
  String get selectCourtType;

  /// No description provided for @enterCourtDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the court description.'**
  String get enterCourtDescription;

  /// No description provided for @uploadAtLeastOneCourtPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload at least one photo or memory for the court.'**
  String get uploadAtLeastOneCourtPhoto;

  /// No description provided for @selectAdvancePaymentType.
  ///
  /// In en, this message translates to:
  /// **'Select an advance payment type.'**
  String get selectAdvancePaymentType;

  /// No description provided for @enterAdvancePaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter the advance payment amount.'**
  String get enterAdvancePaymentAmount;

  /// No description provided for @advanceMustBeAtLeastPercent.
  ///
  /// In en, this message translates to:
  /// **'The advance must be at least {percent}%.'**
  String advanceMustBeAtLeastPercent(String percent);

  /// No description provided for @percentageCannotExceed100.
  ///
  /// In en, this message translates to:
  /// **'Percentage cannot exceed 100.'**
  String get percentageCannotExceed100;

  /// No description provided for @flatAmountCannotExceedBasePrice.
  ///
  /// In en, this message translates to:
  /// **'Flat amount cannot exceed the base price.'**
  String get flatAmountCannotExceedBasePrice;

  /// No description provided for @advanceMustBeAtLeastPercentOfBasePrice.
  ///
  /// In en, this message translates to:
  /// **'The advance must be at least {percent}% of the base price ({minimum}).'**
  String advanceMustBeAtLeastPercentOfBasePrice(String percent, String minimum);

  /// No description provided for @uploadAdvancePaymentQr.
  ///
  /// In en, this message translates to:
  /// **'Upload the QR used for advance payment.'**
  String get uploadAdvancePaymentQr;

  /// No description provided for @selectAtLeastOneCourtAmenity.
  ///
  /// In en, this message translates to:
  /// **'Select at least one court amenity.'**
  String get selectAtLeastOneCourtAmenity;

  /// No description provided for @selectAtLeastOneCourtFacility.
  ///
  /// In en, this message translates to:
  /// **'Select at least one court facility.'**
  String get selectAtLeastOneCourtFacility;

  /// No description provided for @addAtLeastOneSlotForCourt.
  ///
  /// In en, this message translates to:
  /// **'Add at least one slot for this court.'**
  String get addAtLeastOneSlotForCourt;

  /// No description provided for @completeDayAndTimeForAllSlots.
  ///
  /// In en, this message translates to:
  /// **'Complete day and time details for all slots.'**
  String get completeDayAndTimeForAllSlots;

  /// No description provided for @resolveOverlappingSlots.
  ///
  /// In en, this message translates to:
  /// **'Resolve overlapping slots before continuing.'**
  String get resolveOverlappingSlots;

  /// No description provided for @thisSlot.
  ///
  /// In en, this message translates to:
  /// **'this slot'**
  String get thisSlot;

  /// No description provided for @saveLabelBeforeContinuing.
  ///
  /// In en, this message translates to:
  /// **'Save {label} before continuing.'**
  String saveLabelBeforeContinuing(String label);

  /// No description provided for @createFutsalVenueFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your futsal venue first — courts are added to a saved venue.'**
  String get createFutsalVenueFirst;

  /// No description provided for @finishFutsalStepsBeforeCourts.
  ///
  /// In en, this message translates to:
  /// **'Finish every futsal step before setting up courts.'**
  String get finishFutsalStepsBeforeCourts;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @continueToCourts.
  ///
  /// In en, this message translates to:
  /// **'Continue to Courts'**
  String get continueToCourts;

  /// No description provided for @reviewAndPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Review & Publish'**
  String get reviewAndPublishTitle;

  /// No description provided for @addCourtBeforeOpeningCourtSteps.
  ///
  /// In en, this message translates to:
  /// **'Add a court before opening court steps.'**
  String get addCourtBeforeOpeningCourtSteps;

  /// No description provided for @addCourtBeforeOpeningCourtSubsteps.
  ///
  /// In en, this message translates to:
  /// **'Add a court before opening court substeps.'**
  String get addCourtBeforeOpeningCourtSubsteps;

  /// No description provided for @addAtLeastOneCourtBeforeContinuing.
  ///
  /// In en, this message translates to:
  /// **'Add at least one court before continuing.'**
  String get addAtLeastOneCourtBeforeContinuing;

  /// No description provided for @defaultCourtName.
  ///
  /// In en, this message translates to:
  /// **'Court {number}'**
  String defaultCourtName(int number);

  /// No description provided for @defaultSlotLabel.
  ///
  /// In en, this message translates to:
  /// **'Slot {number}'**
  String defaultSlotLabel(int number);

  /// No description provided for @saveCourtBeforeManagingSlots.
  ///
  /// In en, this message translates to:
  /// **'Save the court before managing slots.'**
  String get saveCourtBeforeManagingSlots;

  /// No description provided for @saveSlotBeforeSettingPrices.
  ///
  /// In en, this message translates to:
  /// **'Save the slot before setting prices.'**
  String get saveSlotBeforeSettingPrices;

  /// No description provided for @waitForCurrentSaveToFinish.
  ///
  /// In en, this message translates to:
  /// **'Please wait for the current save to finish.'**
  String get waitForCurrentSaveToFinish;

  /// No description provided for @addAtLeastOneCourtBeforePublishing.
  ///
  /// In en, this message translates to:
  /// **'Add at least one court before publishing.'**
  String get addAtLeastOneCourtBeforePublishing;

  /// No description provided for @addAtLeastOneCourtBeforeFinishing.
  ///
  /// In en, this message translates to:
  /// **'Add at least one court before finishing.'**
  String get addAtLeastOneCourtBeforeFinishing;

  /// No description provided for @aCourt.
  ///
  /// In en, this message translates to:
  /// **'A court'**
  String get aCourt;

  /// No description provided for @courtNotSetUpYet.
  ///
  /// In en, this message translates to:
  /// **'{name} is not set up yet. Complete it before finishing.'**
  String courtNotSetUpYet(String name);

  /// No description provided for @completeAndSaveFutsalBeforeAddingCourts.
  ///
  /// In en, this message translates to:
  /// **'Complete and save the futsal venue before adding courts.'**
  String get completeAndSaveFutsalBeforeAddingCourts;

  /// No description provided for @mediaLibrary.
  ///
  /// In en, this message translates to:
  /// **'Media Library'**
  String get mediaLibrary;

  /// No description provided for @selectSavedMediaOrAddNewFiles.
  ///
  /// In en, this message translates to:
  /// **'Select saved media or add new files for this section.'**
  String get selectSavedMediaOrAddNewFiles;

  /// No description provided for @removeFromSavedCollectionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove \"{name}\" from your saved collection?'**
  String removeFromSavedCollectionPrompt(String name);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @useSelectedItems.
  ///
  /// In en, this message translates to:
  /// **'Use Selected Items'**
  String get useSelectedItems;

  /// No description provided for @useSelectedItem.
  ///
  /// In en, this message translates to:
  /// **'Use Selected Item'**
  String get useSelectedItem;

  /// No description provided for @noMediaSelected.
  ///
  /// In en, this message translates to:
  /// **'No media selected'**
  String get noMediaSelected;

  /// No description provided for @itemsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} item selected} other{{count} items selected}}'**
  String itemsSelected(int count);

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @tapToAttachFilesForSection.
  ///
  /// In en, this message translates to:
  /// **'Tap {actionLabel} to attach files for this section.'**
  String tapToAttachFilesForSection(String actionLabel);

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get notStarted;

  /// No description provided for @inProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressTitle;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// No description provided for @sessionState.
  ///
  /// In en, this message translates to:
  /// **'Session state'**
  String get sessionState;

  /// No description provided for @readyInSession.
  ///
  /// In en, this message translates to:
  /// **'Ready in session'**
  String get readyInSession;

  /// No description provided for @savingDraft.
  ///
  /// In en, this message translates to:
  /// **'Saving draft...'**
  String get savingDraft;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draftSaved;

  /// No description provided for @savedAt.
  ///
  /// In en, this message translates to:
  /// **'Saved at {time}'**
  String savedAt(String time);

  /// No description provided for @draftSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Draft save failed'**
  String get draftSaveFailed;

  /// No description provided for @sessionOnly.
  ///
  /// In en, this message translates to:
  /// **'Session only'**
  String get sessionOnly;

  /// No description provided for @searchLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Search location...'**
  String get searchLocationHint;

  /// No description provided for @deleteCourtConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{courtName}\"? This action cannot be undone.'**
  String deleteCourtConfirmation(String courtName);

  /// No description provided for @courtDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'\"{courtName}\" deleted successfully.'**
  String courtDeletedSuccessfully(String courtName);

  /// No description provided for @unnamedCourt.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Court'**
  String get unnamedCourt;

  /// No description provided for @slotCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} slot} other{{count} slots}}'**
  String slotCountLabel(int count);

  /// No description provided for @saveChangesAndExit.
  ///
  /// In en, this message translates to:
  /// **'Save changes & exit?'**
  String get saveChangesAndExit;

  /// No description provided for @courtSetupProgressSavedBeforeHome.
  ///
  /// In en, this message translates to:
  /// **'Your current court setup progress will be saved before returning home.'**
  String get courtSetupProgressSavedBeforeHome;

  /// No description provided for @saveAndGoHome.
  ///
  /// In en, this message translates to:
  /// **'Save & go home'**
  String get saveAndGoHome;

  /// No description provided for @stayHere.
  ///
  /// In en, this message translates to:
  /// **'Stay here'**
  String get stayHere;

  /// No description provided for @enterCourtNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the court. You can change it later. \nMake sure to use a proper standard name for the court.'**
  String get enterCourtNameHelper;

  /// No description provided for @stepNumber.
  ///
  /// In en, this message translates to:
  /// **'Step {section}.{substep}'**
  String stepNumber(int section, int substep);

  /// No description provided for @enterFirstCourtNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for your first court. You can change it later.\nMake sure to use a proper standard name for the court.'**
  String get enterFirstCourtNameHelper;

  /// No description provided for @courtSetupSentenceCase.
  ///
  /// In en, this message translates to:
  /// **'Court setup'**
  String get courtSetupSentenceCase;

  /// No description provided for @futsalSetup.
  ///
  /// In en, this message translates to:
  /// **'Futsal setup'**
  String get futsalSetup;

  /// No description provided for @courtDetailsAndBookingSetup.
  ///
  /// In en, this message translates to:
  /// **'Court details and booking setup'**
  String get courtDetailsAndBookingSetup;

  /// No description provided for @businessProfileAndLocation.
  ///
  /// In en, this message translates to:
  /// **'Business profile and location'**
  String get businessProfileAndLocation;

  /// No description provided for @futsalStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Futsal {status}'**
  String futsalStatusLabel(String status);

  /// No description provided for @courtCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} court} other{{count} courts}}'**
  String courtCountLabel(int count);

  /// No description provided for @onboardingProgressSavedBeforeHome.
  ///
  /// In en, this message translates to:
  /// **'Your current onboarding progress will be saved before returning home.'**
  String get onboardingProgressSavedBeforeHome;

  /// No description provided for @loadingCourtTypes.
  ///
  /// In en, this message translates to:
  /// **'Loading court types...'**
  String get loadingCourtTypes;

  /// No description provided for @loadingMatchFormats.
  ///
  /// In en, this message translates to:
  /// **'Loading match formats...'**
  String get loadingMatchFormats;

  /// No description provided for @basicPlanDescriptionHtml.
  ///
  /// In en, this message translates to:
  /// **'<ul><li>Basic listing</li><li>Standard visibility</li><li>Email support</li></ul>'**
  String get basicPlanDescriptionHtml;

  /// No description provided for @standardPlanDescriptionHtml.
  ///
  /// In en, this message translates to:
  /// **'<ul><li>Priority support</li><li>Featured listing</li><li>Activity logs</li><li>Detailed reports</li></ul>'**
  String get standardPlanDescriptionHtml;

  /// No description provided for @planPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan {percent}%'**
  String planPercentLabel(int percent);

  /// No description provided for @defaultPackageDescriptionHtml.
  ///
  /// In en, this message translates to:
  /// **'<p>Platform support based on selected package</p>'**
  String get defaultPackageDescriptionHtml;

  /// No description provided for @playerFacingFacilitiesAtCourt.
  ///
  /// In en, this message translates to:
  /// **'Player-facing facilities available at this court.'**
  String get playerFacingFacilitiesAtCourt;

  /// No description provided for @courtSpecificServicesAndEquipment.
  ///
  /// In en, this message translates to:
  /// **'Court-specific services and equipment.'**
  String get courtSpecificServicesAndEquipment;

  /// No description provided for @noFacilitiesAvailableRightNow.
  ///
  /// In en, this message translates to:
  /// **'No facilities available right now. Please try again later.'**
  String get noFacilitiesAvailableRightNow;

  /// No description provided for @noAmenitiesAvailableRightNow.
  ///
  /// In en, this message translates to:
  /// **'No amenities available right now. Please try again later.'**
  String get noAmenitiesAvailableRightNow;

  /// No description provided for @selectedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{selected}/{total} selected'**
  String selectedOfTotal(int selected, int total);

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add new'**
  String get addNew;

  /// No description provided for @addPaymentQrs.
  ///
  /// In en, this message translates to:
  /// **'Add payment QRs'**
  String get addPaymentQrs;

  /// No description provided for @youCanAddOneMoreQr.
  ///
  /// In en, this message translates to:
  /// **'You can add 1 more QR.'**
  String get youCanAddOneMoreQr;

  /// No description provided for @youCanAddUpToMoreQrs.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {remaining} more QRs.'**
  String youCanAddUpToMoreQrs(int remaining);

  /// No description provided for @courtQrLimitReached.
  ///
  /// In en, this message translates to:
  /// **'A court can have {max} QRs. Only the first {remaining, plural, =1{{remaining} was} other{{remaining} were}} added.'**
  String courtQrLimitReached(int max, int remaining);

  /// No description provided for @enterTheAdvanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter the advance amount.'**
  String get enterTheAdvanceAmount;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero.'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @flatAmountCannotExceedBasePriceOf.
  ///
  /// In en, this message translates to:
  /// **'Flat amount cannot exceed the base price ({base}).'**
  String flatAmountCannotExceedBasePriceOf(String base);

  /// No description provided for @minimumPercentUpTo100.
  ///
  /// In en, this message translates to:
  /// **'Minimum {percent}%, up to 100%'**
  String minimumPercentUpTo100(String percent);

  /// No description provided for @enterFlatAdvanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter the flat advance amount'**
  String get enterFlatAdvanceAmount;

  /// No description provided for @fromAmountToAmount.
  ///
  /// In en, this message translates to:
  /// **'From {from} to {to}'**
  String fromAmountToAmount(String from, String to);

  /// No description provided for @enterAdvanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter the advance amount'**
  String get enterAdvanceAmount;

  /// No description provided for @everyCourtCollectsAdvance.
  ///
  /// In en, this message translates to:
  /// **'Every court collects an advance of at least {percent}% before a booking is confirmed.'**
  String everyCourtCollectsAdvance(String percent);

  /// No description provided for @advancePercentageLabel.
  ///
  /// In en, this message translates to:
  /// **'Advance percentage (%)'**
  String get advancePercentageLabel;

  /// No description provided for @advanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Advance amount'**
  String get advanceAmount;

  /// No description provided for @removeQr.
  ///
  /// In en, this message translates to:
  /// **'Remove QR'**
  String get removeQr;

  /// No description provided for @removePaymentQrPrompt.
  ///
  /// In en, this message translates to:
  /// **'Remove this payment QR from the court?'**
  String get removePaymentQrPrompt;

  /// No description provided for @addQrForEachWalletOrBank.
  ///
  /// In en, this message translates to:
  /// **'Add a QR for each wallet or bank you accept. Players can pay through any of them.'**
  String get addQrForEachWalletOrBank;

  /// No description provided for @qrNumber.
  ///
  /// In en, this message translates to:
  /// **'QR {number}'**
  String qrNumber(int number);

  /// No description provided for @tapToViewLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}, tap to view'**
  String tapToViewLabel(String label);

  /// No description provided for @uploadQr.
  ///
  /// In en, this message translates to:
  /// **'Upload QR'**
  String get uploadQr;

  /// No description provided for @addQr.
  ///
  /// In en, this message translates to:
  /// **'Add QR'**
  String get addQr;

  /// No description provided for @noBookingDays.
  ///
  /// In en, this message translates to:
  /// **'No booking days'**
  String get noBookingDays;

  /// No description provided for @enterSlotLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter a slot label.'**
  String get enterSlotLabel;

  /// No description provided for @selectAtLeastOneBookingDay.
  ///
  /// In en, this message translates to:
  /// **'Select at least one booking day.'**
  String get selectAtLeastOneBookingDay;

  /// No description provided for @selectBothStartAndEndTime.
  ///
  /// In en, this message translates to:
  /// **'Select both start and end time.'**
  String get selectBothStartAndEndTime;

  /// No description provided for @editSlot.
  ///
  /// In en, this message translates to:
  /// **'Edit Slot'**
  String get editSlot;

  /// No description provided for @bookingDays.
  ///
  /// In en, this message translates to:
  /// **'Booking days'**
  String get bookingDays;

  /// No description provided for @updateSlot.
  ///
  /// In en, this message translates to:
  /// **'Update Slot'**
  String get updateSlot;

  /// No description provided for @untitledSlot.
  ///
  /// In en, this message translates to:
  /// **'Untitled slot'**
  String get untitledSlot;

  /// No description provided for @timeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Time not set'**
  String get timeNotSet;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @addHoliday.
  ///
  /// In en, this message translates to:
  /// **'Add Holiday'**
  String get addHoliday;

  /// No description provided for @addClosedDate.
  ///
  /// In en, this message translates to:
  /// **'Add Closed Date'**
  String get addClosedDate;

  /// No description provided for @basePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Base {price}'**
  String basePriceLabel(String price);

  /// No description provided for @weekendPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekend {price}'**
  String weekendPriceLabel(String price);

  /// No description provided for @holidayPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Holiday {price}'**
  String holidayPriceLabel(String price);

  /// No description provided for @discountPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount {price}'**
  String discountPriceLabel(String price);

  /// No description provided for @customDatesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} custom date} other{{count} custom dates}}'**
  String customDatesCount(int count);

  /// No description provided for @noSpecialPricingSet.
  ///
  /// In en, this message translates to:
  /// **'No special pricing set'**
  String get noSpecialPricingSet;

  /// No description provided for @discountPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount %'**
  String get discountPercentLabel;

  /// No description provided for @discountPrice.
  ///
  /// In en, this message translates to:
  /// **'Discount price'**
  String get discountPrice;

  /// No description provided for @closureType.
  ///
  /// In en, this message translates to:
  /// **'Closure type'**
  String get closureType;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get periodYear;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get periodCustom;

  /// No description provided for @bookingStatuses.
  ///
  /// In en, this message translates to:
  /// **'Booking statuses'**
  String get bookingStatuses;

  /// No description provided for @revenueTrend.
  ///
  /// In en, this message translates to:
  /// **'Revenue trend'**
  String get revenueTrend;

  /// No description provided for @bookingOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking overview'**
  String get bookingOverviewTitle;

  /// No description provided for @snapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get snapshot;

  /// No description provided for @netEarnings.
  ///
  /// In en, this message translates to:
  /// **'Net earnings'**
  String get netEarnings;

  /// No description provided for @performanceByVenue.
  ///
  /// In en, this message translates to:
  /// **'Performance by venue'**
  String get performanceByVenue;

  /// No description provided for @topCourts.
  ///
  /// In en, this message translates to:
  /// **'Top courts'**
  String get topCourts;

  /// No description provided for @topCustomers.
  ///
  /// In en, this message translates to:
  /// **'Top customers'**
  String get topCustomers;

  /// No description provided for @bookedHours.
  ///
  /// In en, this message translates to:
  /// **'Booked hours'**
  String get bookedHours;

  /// No description provided for @bookedHrs.
  ///
  /// In en, this message translates to:
  /// **'Booked hrs'**
  String get bookedHrs;

  /// No description provided for @noVenueActivityInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No venue activity in this period.'**
  String get noVenueActivityInPeriod;

  /// No description provided for @twelveAm.
  ///
  /// In en, this message translates to:
  /// **'12 AM'**
  String get twelveAm;

  /// No description provided for @elevenPm.
  ///
  /// In en, this message translates to:
  /// **'11 PM'**
  String get elevenPm;

  /// No description provided for @overheadsAndProcessing.
  ///
  /// In en, this message translates to:
  /// **'Overheads + processing'**
  String get overheadsAndProcessing;

  /// No description provided for @acrossAllPaidSlots.
  ///
  /// In en, this message translates to:
  /// **'Across all paid slots'**
  String get acrossAllPaidSlots;

  /// No description provided for @ofAvailableCourtHours.
  ///
  /// In en, this message translates to:
  /// **'Of available court hours'**
  String get ofAvailableCourtHours;

  /// No description provided for @avgNpr.
  ///
  /// In en, this message translates to:
  /// **'Avg NPR {amount}'**
  String avgNpr(String amount);

  /// No description provided for @avgPerBooking.
  ///
  /// In en, this message translates to:
  /// **'Avg {amount} / booking'**
  String avgPerBooking(String amount);

  /// No description provided for @bookingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} booking} other{{count} bookings}}'**
  String bookingCount(int count);

  /// No description provided for @rowCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} row} other{{count} rows}}'**
  String rowCount(int count);

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String daysShort(int days);

  /// No description provided for @totalBookingsCount.
  ///
  /// In en, this message translates to:
  /// **'{total} total bookings'**
  String totalBookingsCount(int total);

  /// No description provided for @vsPreviousPeriod.
  ///
  /// In en, this message translates to:
  /// **'vs {amount} previous period'**
  String vsPreviousPeriod(String amount);

  /// No description provided for @paidCount.
  ///
  /// In en, this message translates to:
  /// **'{count} paid'**
  String paidCount(int count);

  /// No description provided for @percentOfBookings.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of bookings'**
  String percentOfBookings(String percent);

  /// No description provided for @allDates.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get allDates;

  /// No description provided for @dateModeDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dateModeDay;

  /// No description provided for @dateModeRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get dateModeRange;

  /// No description provided for @noInternetCheckNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get noInternetCheckNetwork;

  /// No description provided for @somethingWentWrongLoadingBookings.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading bookings. Please try again.'**
  String get somethingWentWrongLoadingBookings;

  /// No description provided for @couldNotLoadAccountForBookings.
  ///
  /// In en, this message translates to:
  /// **'We could not load your account details, so your bookings cannot be shown.'**
  String get couldNotLoadAccountForBookings;

  /// No description provided for @accountRoleMissingForBookings.
  ///
  /// In en, this message translates to:
  /// **'Your account role is missing, so we cannot tell which bookings to show.'**
  String get accountRoleMissingForBookings;

  /// No description provided for @searchVenueCourtOrBookingId.
  ///
  /// In en, this message translates to:
  /// **'Search venue, court or booking ID'**
  String get searchVenueCourtOrBookingId;

  /// No description provided for @searchCourtPlayerOrBookingId.
  ///
  /// In en, this message translates to:
  /// **'Search court, player or booking ID'**
  String get searchCourtPlayerOrBookingId;

  /// No description provided for @failedToLoadBookings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookings.'**
  String get failedToLoadBookings;

  /// No description provided for @failedToLoadFutsalBookings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load futsal bookings.'**
  String get failedToLoadFutsalBookings;

  /// No description provided for @failedToLoadRecentBookings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recent bookings.'**
  String get failedToLoadRecentBookings;

  /// No description provided for @noMatchingBookings.
  ///
  /// In en, this message translates to:
  /// **'No matching bookings'**
  String get noMatchingBookings;

  /// No description provided for @noBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookingsYet;

  /// No description provided for @noFutsalBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No futsal bookings yet'**
  String get noFutsalBookingsYet;

  /// No description provided for @upcomingCourtBookingsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your upcoming court bookings will appear here.'**
  String get upcomingCourtBookingsAppearHere;

  /// No description provided for @venueBookingsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Bookings made at your venues will appear here.'**
  String get venueBookingsAppearHere;

  /// No description provided for @tryDifferentSearchOrDateRange.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or date range.'**
  String get tryDifferentSearchOrDateRange;

  /// No description provided for @couldNotLoadMoreRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not load more. Retry'**
  String get couldNotLoadMoreRetry;

  /// No description provided for @loadMoreBookings.
  ///
  /// In en, this message translates to:
  /// **'Load more bookings'**
  String get loadMoreBookings;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @addProducts.
  ///
  /// In en, this message translates to:
  /// **'Add products'**
  String get addProducts;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @monthShortJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthShortJan;

  /// No description provided for @monthShortFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthShortFeb;

  /// No description provided for @monthShortMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthShortMar;

  /// No description provided for @monthShortApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthShortApr;

  /// No description provided for @monthShortMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthShortMay;

  /// No description provided for @monthShortJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthShortJun;

  /// No description provided for @monthShortJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthShortJul;

  /// No description provided for @monthShortAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthShortAug;

  /// No description provided for @monthShortSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthShortSep;

  /// No description provided for @monthShortOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthShortOct;

  /// No description provided for @monthShortNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthShortNov;

  /// No description provided for @monthShortDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthShortDec;

  /// No description provided for @editDateFilter.
  ///
  /// In en, this message translates to:
  /// **'Edit date filter'**
  String get editDateFilter;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldestFirst;

  /// No description provided for @everyBookingShownWhateverDate.
  ///
  /// In en, this message translates to:
  /// **'Every booking is shown, whatever its date.'**
  String get everyBookingShownWhateverDate;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @ratingPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get ratingPoor;

  /// No description provided for @ratingFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get ratingFair;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get ratingGreat;

  /// No description provided for @ratingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get ratingExcellent;

  /// No description provided for @howWasYourGame.
  ///
  /// In en, this message translates to:
  /// **'How was your game?'**
  String get howWasYourGame;

  /// No description provided for @ratingHelpsOtherPlayers.
  ///
  /// In en, this message translates to:
  /// **'Your rating helps other players choose a venue.'**
  String get ratingHelpsOtherPlayers;

  /// No description provided for @pickStarRatingFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a star rating first.'**
  String get pickStarRatingFirst;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get yourReview;

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'Court condition, facilities, how it all went…'**
  String get reviewHint;

  /// No description provided for @writeAFewWordsAboutVenue.
  ///
  /// In en, this message translates to:
  /// **'Write a few words about the venue.'**
  String get writeAFewWordsAboutVenue;

  /// No description provided for @aLittleMoreDetailPlease.
  ///
  /// In en, this message translates to:
  /// **'A little more detail, please.'**
  String get aLittleMoreDetailPlease;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get submitReview;

  /// No description provided for @youReviewedThisBooking.
  ///
  /// In en, this message translates to:
  /// **'You reviewed this booking'**
  String get youReviewedThisBooking;

  /// No description provided for @checkingYourReview.
  ///
  /// In en, this message translates to:
  /// **'Checking your review…'**
  String get checkingYourReview;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(int minutes);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} m'**
  String minutesShort(int minutes);

  /// No description provided for @hoursShortHr.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr'**
  String hoursShortHr(int hours);

  /// No description provided for @timeAgo.
  ///
  /// In en, this message translates to:
  /// **'{value} ago'**
  String timeAgo(String value);

  /// No description provided for @timeIn.
  ///
  /// In en, this message translates to:
  /// **'in {value}'**
  String timeIn(String value);

  /// No description provided for @fromDateLabel.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String fromDateLabel(String date);

  /// No description provided for @untilDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String untilDateLabel(String date);

  /// No description provided for @noStatusBookingsMatch.
  ///
  /// In en, this message translates to:
  /// **'No {status} bookings match your search or date range.'**
  String noStatusBookingsMatch(String status);

  /// No description provided for @youHaveNoStatusBookings.
  ///
  /// In en, this message translates to:
  /// **'You have no {status} bookings.'**
  String youHaveNoStatusBookings(String status);

  /// No description provided for @typedBooking.
  ///
  /// In en, this message translates to:
  /// **'{type} booking'**
  String typedBooking(String type);

  /// No description provided for @reviewStatus.
  ///
  /// In en, this message translates to:
  /// **'Review {status}'**
  String reviewStatus(String status);

  /// No description provided for @refNumber.
  ///
  /// In en, this message translates to:
  /// **'Ref #{ref}'**
  String refNumber(String ref);

  /// No description provided for @paidAtCounter.
  ///
  /// In en, this message translates to:
  /// **'Paid at counter'**
  String get paidAtCounter;

  /// No description provided for @couldNotReadCandidatesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not read candidates from the server.'**
  String get couldNotReadCandidatesFromServer;

  /// No description provided for @enterAmountLikeExample.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount like 1200 or 1200.50.'**
  String get enterAmountLikeExample;

  /// No description provided for @enterAmountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get enterAmountGreaterThanZero;

  /// No description provided for @manualBookingAndAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Manual booking & adjustments'**
  String get manualBookingAndAdjustments;

  /// No description provided for @noVenuesToBookYet.
  ///
  /// In en, this message translates to:
  /// **'No venues to book yet'**
  String get noVenuesToBookYet;

  /// No description provided for @noVenuesToBookYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Once a venue with courts is approved, you can take walk-in bookings for it here.'**
  String get noVenuesToBookYetMessage;

  /// No description provided for @chooseWhereBookingWillBeCreated.
  ///
  /// In en, this message translates to:
  /// **'Choose where this booking will be created.'**
  String get chooseWhereBookingWillBeCreated;

  /// No description provided for @selectAVenueDot.
  ///
  /// In en, this message translates to:
  /// **'Select a venue.'**
  String get selectAVenueDot;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer details'**
  String get customerDetails;

  /// No description provided for @walkInCustomerContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact information for the walk-in customer.'**
  String get walkInCustomerContactInfo;

  /// No description provided for @enterCustomerPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter the customer\'s phone number'**
  String get enterCustomerPhoneNumber;

  /// No description provided for @bookingDetailsSentenceCase.
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get bookingDetailsSentenceCase;

  /// No description provided for @setInitialPaymentAndBookingStatus.
  ///
  /// In en, this message translates to:
  /// **'Set the initial payment and booking status.'**
  String get setInitialPaymentAndBookingStatus;

  /// No description provided for @totalAmountNpr.
  ///
  /// In en, this message translates to:
  /// **'Total amount (NPR)'**
  String get totalAmountNpr;

  /// No description provided for @leaveBlankToUseSlotPrices.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to use slot prices'**
  String get leaveBlankToUseSlotPrices;

  /// No description provided for @enterBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter booking details'**
  String get enterBookingDetails;

  /// No description provided for @nextSelectDateAndTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Next, select an available date and time slot.'**
  String get nextSelectDateAndTimeSlot;

  /// No description provided for @noExistingCandidateFound.
  ///
  /// In en, this message translates to:
  /// **'No existing candidate found. This booking will use the new customer details.'**
  String get noExistingCandidateFound;

  /// No description provided for @continueToSlotSelection.
  ///
  /// In en, this message translates to:
  /// **'Continue to slot selection'**
  String get continueToSlotSelection;

  /// No description provided for @dueAmountCollectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Due amount collected successfully.'**
  String get dueAmountCollectedSuccessfully;

  /// No description provided for @couldNotCollectDueAmount.
  ///
  /// In en, this message translates to:
  /// **'Could not collect the due amount.'**
  String get couldNotCollectDueAmount;

  /// No description provided for @vendorInfoUnavailableForMessaging.
  ///
  /// In en, this message translates to:
  /// **'Vendor information is unavailable for messaging.'**
  String get vendorInfoUnavailableForMessaging;

  /// No description provided for @customerInfoUnavailableForMessaging.
  ///
  /// In en, this message translates to:
  /// **'Customer information is unavailable for messaging.'**
  String get customerInfoUnavailableForMessaging;

  /// No description provided for @thanksForReviewingBooking.
  ///
  /// In en, this message translates to:
  /// **'Thanks for reviewing this booking.'**
  String get thanksForReviewingBooking;

  /// No description provided for @couldNotLoadLatestBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not load the latest booking details.'**
  String get couldNotLoadLatestBookingDetails;

  /// No description provided for @bookingInformation.
  ///
  /// In en, this message translates to:
  /// **'Booking information'**
  String get bookingInformation;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment summary'**
  String get paymentSummary;

  /// No description provided for @toCollect.
  ///
  /// In en, this message translates to:
  /// **'To collect'**
  String get toCollect;

  /// No description provided for @dueAmount.
  ///
  /// In en, this message translates to:
  /// **'Due amount'**
  String get dueAmount;

  /// No description provided for @collectDue.
  ///
  /// In en, this message translates to:
  /// **'Collect due'**
  String get collectDue;

  /// No description provided for @unknownCustomer.
  ///
  /// In en, this message translates to:
  /// **'Unknown customer'**
  String get unknownCustomer;

  /// No description provided for @bookingTotal.
  ///
  /// In en, this message translates to:
  /// **'Booking total'**
  String get bookingTotal;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand total'**
  String get grandTotal;

  /// No description provided for @includesProductsSold.
  ///
  /// In en, this message translates to:
  /// **'Includes products sold'**
  String get includesProductsSold;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @submittedPaymentScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Submitted payment screenshot'**
  String get submittedPaymentScreenshot;

  /// No description provided for @noPaymentScreenshot.
  ///
  /// In en, this message translates to:
  /// **'No payment screenshot'**
  String get noPaymentScreenshot;

  /// No description provided for @screenshotUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Screenshot unavailable'**
  String get screenshotUnavailable;

  /// No description provided for @noScreenshotWasSubmitted.
  ///
  /// In en, this message translates to:
  /// **'No screenshot was submitted'**
  String get noScreenshotWasSubmitted;

  /// No description provided for @discountWithCode.
  ///
  /// In en, this message translates to:
  /// **'Discount ({code})'**
  String discountWithCode(String code);

  /// No description provided for @productsItemCount.
  ///
  /// In en, this message translates to:
  /// **'Products ({count, plural, =1{{count} item} other{{count} items}})'**
  String productsItemCount(int count);

  /// No description provided for @paymentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} payment} other{{count} payments}}'**
  String paymentCount(int count);

  /// No description provided for @recurrenceSeriesBooking.
  ///
  /// In en, this message translates to:
  /// **'{recurrence} · Series booking'**
  String recurrenceSeriesBooking(String recurrence);

  /// No description provided for @productsSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Products subtotal'**
  String get productsSubtotal;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @addMoreProducts.
  ///
  /// In en, this message translates to:
  /// **'Add more products'**
  String get addMoreProducts;

  /// No description provided for @productsAddedToBooking.
  ///
  /// In en, this message translates to:
  /// **'Products added to the booking.'**
  String get productsAddedToBooking;

  /// No description provided for @couldNotAddProductsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not add products. Please try again.'**
  String get couldNotAddProductsTryAgain;

  /// No description provided for @couldNotLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Could not load products'**
  String get couldNotLoadProducts;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get noProductsAvailable;

  /// No description provided for @venueHasNoActiveProducts.
  ///
  /// In en, this message translates to:
  /// **'This venue has no active products to sell yet.'**
  String get venueHasNoActiveProducts;

  /// No description provided for @sellAddOnsForBooking.
  ///
  /// In en, this message translates to:
  /// **'Sell water, drinks & add-ons for this booking.'**
  String get sellAddOnsForBooking;

  /// No description provided for @collectedRemainingDueInPerson.
  ///
  /// In en, this message translates to:
  /// **'Collected remaining due amount in person'**
  String get collectedRemainingDueInPerson;

  /// No description provided for @collectDueAmount.
  ///
  /// In en, this message translates to:
  /// **'Collect due amount'**
  String get collectDueAmount;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @enterCollectedAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter collected amount'**
  String get enterCollectedAmount;

  /// No description provided for @howWasDueAmountCollected.
  ///
  /// In en, this message translates to:
  /// **'How was the due amount collected?'**
  String get howWasDueAmountCollected;

  /// No description provided for @completeBooking.
  ///
  /// In en, this message translates to:
  /// **'Complete booking'**
  String get completeBooking;

  /// No description provided for @completeBookingDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the payment and record how it was collected. This can\'t be undone.'**
  String get completeBookingDescription;

  /// No description provided for @discountAmount.
  ///
  /// In en, this message translates to:
  /// **'Discount amount'**
  String get discountAmount;

  /// No description provided for @discountAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 100'**
  String get discountAmountHint;

  /// No description provided for @amountReceivedNowNpr.
  ///
  /// In en, this message translates to:
  /// **'Amount received now (NPR)'**
  String get amountReceivedNowNpr;

  /// No description provided for @enterAmountForEachPayment.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount for each payment, or remove it.'**
  String get enterAmountForEachPayment;

  /// No description provided for @collectingNow.
  ///
  /// In en, this message translates to:
  /// **'Collecting now'**
  String get collectingNow;

  /// No description provided for @payableAfterDiscount.
  ///
  /// In en, this message translates to:
  /// **'Payable after discount'**
  String get payableAfterDiscount;

  /// No description provided for @remainingDue.
  ///
  /// In en, this message translates to:
  /// **'Remaining due'**
  String get remainingDue;

  /// No description provided for @bookingPayment.
  ///
  /// In en, this message translates to:
  /// **'Booking payment'**
  String get bookingPayment;

  /// No description provided for @alreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'Already paid'**
  String get alreadyPaid;

  /// No description provided for @extraItems.
  ///
  /// In en, this message translates to:
  /// **'Extra items'**
  String get extraItems;

  /// No description provided for @noExtraItemsOnBooking.
  ///
  /// In en, this message translates to:
  /// **'No extra items on this booking.'**
  String get noExtraItemsOnBooking;

  /// No description provided for @extraItemsTotal.
  ///
  /// In en, this message translates to:
  /// **'Extra items total'**
  String get extraItemsTotal;

  /// No description provided for @totalToCollect.
  ///
  /// In en, this message translates to:
  /// **'Total to collect'**
  String get totalToCollect;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @qtyCount.
  ///
  /// In en, this message translates to:
  /// **'Qty {quantity}'**
  String qtyCount(int quantity);

  /// No description provided for @productNumber.
  ///
  /// In en, this message translates to:
  /// **'Product #{id}'**
  String productNumber(Object id);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @addToBookingCount.
  ///
  /// In en, this message translates to:
  /// **'Add to booking ({count})'**
  String addToBookingCount(int count);

  /// No description provided for @amountCannotExceed.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot exceed {amount}'**
  String amountCannotExceed(String amount);

  /// No description provided for @remainsDueForCompletedBooking.
  ///
  /// In en, this message translates to:
  /// **'{amount} remains due for this completed booking.'**
  String remainsDueForCompletedBooking(String amount);

  /// No description provided for @collectAmount.
  ///
  /// In en, this message translates to:
  /// **'Collect {amount}'**
  String collectAmount(String amount);

  /// No description provided for @typeReceivedNpr.
  ///
  /// In en, this message translates to:
  /// **'{type} received (NPR)'**
  String typeReceivedNpr(String type);

  /// No description provided for @addPaymentType.
  ///
  /// In en, this message translates to:
  /// **'Add {type}'**
  String addPaymentType(String type);

  /// No description provided for @moreThanAmountDue.
  ///
  /// In en, this message translates to:
  /// **'More than the amount due ({amount}).'**
  String moreThanAmountDue(String amount);

  /// No description provided for @aYearAgo.
  ///
  /// In en, this message translates to:
  /// **'a year ago'**
  String get aYearAgo;

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{years} years ago'**
  String yearsAgo(int years);

  /// No description provided for @aMonthAgo.
  ///
  /// In en, this message translates to:
  /// **'a month ago'**
  String get aMonthAgo;

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{months} months ago'**
  String monthsAgo(int months);

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get relativeYesterday;

  /// No description provided for @anHourAgo.
  ///
  /// In en, this message translates to:
  /// **'an hour ago'**
  String get anHourAgo;

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get relativeJustNow;

  /// No description provided for @twoWeeks.
  ///
  /// In en, this message translates to:
  /// **'2 Weeks'**
  String get twoWeeks;

  /// No description provided for @oneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get oneMonth;

  /// No description provided for @twoMonths.
  ///
  /// In en, this message translates to:
  /// **'2 Months'**
  String get twoMonths;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get threeMonths;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @couldNotLoadVenueCourts.
  ///
  /// In en, this message translates to:
  /// **'Could not load venue courts. Please try again.'**
  String get couldNotLoadVenueCourts;

  /// No description provided for @couldNotParseCourtSlotsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not parse court slots from server.'**
  String get couldNotParseCourtSlotsFromServer;

  /// No description provided for @couldNotCreateCourtSlot.
  ///
  /// In en, this message translates to:
  /// **'Could not create the court slot.'**
  String get couldNotCreateCourtSlot;

  /// No description provided for @couldNotSaveCourtSlot.
  ///
  /// In en, this message translates to:
  /// **'Could not save the court slot.'**
  String get couldNotSaveCourtSlot;

  /// No description provided for @couldNotDeleteCourtSlot.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the court slot.'**
  String get couldNotDeleteCourtSlot;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @playersCountTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} Players'**
  String playersCountTitle(int count);

  /// No description provided for @checkOutVenueOnHamroFutsal.
  ///
  /// In en, this message translates to:
  /// **'Check out {name} on Hamro Futsal.'**
  String checkOutVenueOnHamroFutsal(String name);

  /// No description provided for @startingFrom.
  ///
  /// In en, this message translates to:
  /// **'Starting from {price}'**
  String startingFrom(String price);

  /// No description provided for @distanceInMeters.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String distanceInMeters(Object meters);

  /// No description provided for @distanceInKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceInKm(Object km);

  /// No description provided for @thatIsEveryReview.
  ///
  /// In en, this message translates to:
  /// **'That is every review.'**
  String get thatIsEveryReview;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @playHereAndBeFirstToReview.
  ///
  /// In en, this message translates to:
  /// **'Play here and be the first to leave one.'**
  String get playHereAndBeFirstToReview;

  /// No description provided for @choosePreferredTime.
  ///
  /// In en, this message translates to:
  /// **'Choose Preferred Time'**
  String get choosePreferredTime;

  /// No description provided for @fromPrice.
  ///
  /// In en, this message translates to:
  /// **'from {price}'**
  String fromPrice(String price);

  /// No description provided for @sessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String sessionsCount(int count);

  /// No description provided for @saveAmountSuffix.
  ///
  /// In en, this message translates to:
  /// **' · save {amount}'**
  String saveAmountSuffix(String amount);

  /// No description provided for @oneReview.
  ///
  /// In en, this message translates to:
  /// **'1 review'**
  String get oneReview;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsCount(int count);

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @viewAllCount.
  ///
  /// In en, this message translates to:
  /// **'View all ({count})'**
  String viewAllCount(int count);

  /// No description provided for @everyWeekdaysSameTime.
  ///
  /// In en, this message translates to:
  /// **'Every {weekdays} · same time'**
  String everyWeekdaysSameTime(String weekdays);

  /// No description provided for @repeatWeeklyOnTheDaysYouChoose.
  ///
  /// In en, this message translates to:
  /// **'Repeat weekly on the days you choose'**
  String get repeatWeeklyOnTheDaysYouChoose;

  /// No description provided for @sessionsDateRange.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions · {first} → {last}'**
  String sessionsDateRange(int count, String first, String last);

  /// No description provided for @someDatesAreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Some dates are unavailable'**
  String get someDatesAreUnavailable;

  /// No description provided for @availableUnavailableCount.
  ///
  /// In en, this message translates to:
  /// **'{available} available · {unavailable} unavailable'**
  String availableUnavailableCount(int available, int unavailable);

  /// No description provided for @allDatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'All {count} dates available'**
  String allDatesAvailable(int count);

  /// No description provided for @totalSessions.
  ///
  /// In en, this message translates to:
  /// **'Total · {count} sessions'**
  String totalSessions(int count);

  /// No description provided for @unavailableDatesNotChargedSkipped.
  ///
  /// In en, this message translates to:
  /// **'Unavailable dates are not charged and will be skipped.'**
  String get unavailableDatesNotChargedSkipped;

  /// No description provided for @saveAmount.
  ///
  /// In en, this message translates to:
  /// **'save {amount}'**
  String saveAmount(String amount);

  /// No description provided for @totalLowercaseSessions.
  ///
  /// In en, this message translates to:
  /// **'total · {count} sessions'**
  String totalLowercaseSessions(int count);

  /// No description provided for @selectATimeSlotToContinue.
  ///
  /// In en, this message translates to:
  /// **'Select a time slot to continue'**
  String get selectATimeSlotToContinue;

  /// No description provided for @courtEveryWeekdaysAtTime.
  ///
  /// In en, this message translates to:
  /// **'{court} · Every {weekdays} · {time}'**
  String courtEveryWeekdaysAtTime(String court, String weekdays, String time);

  /// No description provided for @selectSlot.
  ///
  /// In en, this message translates to:
  /// **'Select Slot'**
  String get selectSlot;

  /// No description provided for @hamroFutsalPvtLtd.
  ///
  /// In en, this message translates to:
  /// **'Hamro Futsal Pvt. Ltd.'**
  String get hamroFutsalPvtLtd;

  /// No description provided for @paymentAmountNotReady.
  ///
  /// In en, this message translates to:
  /// **'The payment amount is not ready yet. Please try again.'**
  String get paymentAmountNotReady;

  /// No description provided for @receiptAcceptedForManualVerification.
  ///
  /// In en, this message translates to:
  /// **'Receipt accepted for manual verification (score: {score}%).'**
  String receiptAcceptedForManualVerification(int score);

  /// No description provided for @pleaseUploadYourPaymentProof.
  ///
  /// In en, this message translates to:
  /// **'Please upload your payment proof.'**
  String get pleaseUploadYourPaymentProof;

  /// No description provided for @pleaseAcceptTheBookingTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the booking terms.'**
  String get pleaseAcceptTheBookingTerms;

  /// No description provided for @onlineQrProofAttached.
  ///
  /// In en, this message translates to:
  /// **'Online (QR) · proof attached'**
  String get onlineQrProofAttached;

  /// No description provided for @couldNotCreateBooking.
  ///
  /// In en, this message translates to:
  /// **'Could not create booking. Please try again.'**
  String get couldNotCreateBooking;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking summary'**
  String get bookingSummary;

  /// No description provided for @applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply coupon'**
  String get applyCoupon;

  /// No description provided for @priceDetails.
  ///
  /// In en, this message translates to:
  /// **'Price details'**
  String get priceDetails;

  /// No description provided for @confirmedByVenue.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by venue'**
  String get confirmedByVenue;

  /// No description provided for @totalRsAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Rs {amount}'**
  String totalRsAmount(String amount);

  /// No description provided for @totalDash.
  ///
  /// In en, this message translates to:
  /// **'Total —'**
  String get totalDash;

  /// No description provided for @confirmingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Confirming…'**
  String get confirmingEllipsis;

  /// No description provided for @starts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get starts;

  /// No description provided for @upToPlayers.
  ///
  /// In en, this message translates to:
  /// **'Up to {count}'**
  String upToPlayers(int count);

  /// No description provided for @weeklyRecurrenceSessions.
  ///
  /// In en, this message translates to:
  /// **'Weekly · {recurrence} · {sessions} sessions'**
  String weeklyRecurrenceSessions(String recurrence, int sessions);

  /// No description provided for @appliedSavedRs.
  ///
  /// In en, this message translates to:
  /// **'applied · saved Rs {amount}'**
  String appliedSavedRs(String amount);

  /// No description provided for @minusRsAmount.
  ///
  /// In en, this message translates to:
  /// **'- Rs {amount}'**
  String minusRsAmount(String amount);

  /// No description provided for @couldNotCalculateThePrice.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t calculate the price'**
  String get couldNotCalculateThePrice;

  /// No description provided for @slotCouldNotBeHeldTryAgain.
  ///
  /// In en, this message translates to:
  /// **'The slot could not be held. Please try again.'**
  String get slotCouldNotBeHeldTryAgain;

  /// No description provided for @estimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get estimatedTotal;

  /// No description provided for @venueConfirmsFinalPriceAndAdvance.
  ///
  /// In en, this message translates to:
  /// **'The venue confirms the final price and advance with your booking.'**
  String get venueConfirmsFinalPriceAndAdvance;

  /// No description provided for @calculatingFinalPriceAndAdvance.
  ///
  /// In en, this message translates to:
  /// **'Calculating the final price and advance…'**
  String get calculatingFinalPriceAndAdvance;

  /// No description provided for @oneSession.
  ///
  /// In en, this message translates to:
  /// **'1 session'**
  String get oneSession;

  /// No description provided for @checkingPaymentReceipt.
  ///
  /// In en, this message translates to:
  /// **'Checking payment receipt…'**
  String get checkingPaymentReceipt;

  /// No description provided for @attachedWithSize.
  ///
  /// In en, this message translates to:
  /// **'Attached · {size}'**
  String attachedWithSize(String size);

  /// No description provided for @payExactAmountNote.
  ///
  /// In en, this message translates to:
  /// **'Please pay the exact amount shown for your booking.'**
  String get payExactAmountNote;

  /// No description provided for @uploadClearReceiptScreenshotNote.
  ///
  /// In en, this message translates to:
  /// **'After completing the payment, upload a clear screenshot of the payment confirmation receipt.'**
  String get uploadClearReceiptScreenshotNote;

  /// No description provided for @incorrectPaymentMayBeCancelledNote.
  ///
  /// In en, this message translates to:
  /// **'Bookings with an incorrect payment amount or unclear/invalid screenshot may be cancelled.'**
  String get incorrectPaymentMayBeCancelledNote;

  /// No description provided for @bookingRequestSentDetails.
  ///
  /// In en, this message translates to:
  /// **'{court} · {time}\nWe will confirm once your advance of Rs {advance} is verified. Balance Rs {balance} payable later.'**
  String bookingRequestSentDetails(
    String court,
    String time,
    String advance,
    String balance,
  );

  /// No description provided for @bookingConfirmedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed successfully.'**
  String get bookingConfirmedSuccessfully;

  /// No description provided for @couldNotCheckAvailabilityForSelectedDates.
  ///
  /// In en, this message translates to:
  /// **'Could not check availability for the selected dates.'**
  String get couldNotCheckAvailabilityForSelectedDates;

  /// No description provided for @couldNotLoadSlotsForThisDate.
  ///
  /// In en, this message translates to:
  /// **'Could not load slots for this date.'**
  String get couldNotLoadSlotsForThisDate;

  /// No description provided for @forTheSelectedTime.
  ///
  /// In en, this message translates to:
  /// **'For the selected time'**
  String get forTheSelectedTime;

  /// No description provided for @allCourtsForThisDate.
  ///
  /// In en, this message translates to:
  /// **'All courts for this date'**
  String get allCourtsForThisDate;

  /// No description provided for @noCourtsAvailableForDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'No courts are available for this date and time.'**
  String get noCourtsAvailableForDateAndTime;

  /// No description provided for @noCourtsAvailableForDate.
  ///
  /// In en, this message translates to:
  /// **'No courts are available for this date.'**
  String get noCourtsAvailableForDate;

  /// No description provided for @noneOfTheseDatesAreAvailable.
  ///
  /// In en, this message translates to:
  /// **'None of these dates are available. Please choose another date or time slot.'**
  String get noneOfTheseDatesAreAvailable;

  /// No description provided for @showingNearestAvailability.
  ///
  /// In en, this message translates to:
  /// **'{hasType, select, true{Showing the nearest availability we could find ({fallbackType}).} other{Showing the nearest availability we could find.}}'**
  String showingNearestAvailability(String hasType, String fallbackType);

  /// No description provided for @zeroCourts.
  ///
  /// In en, this message translates to:
  /// **'0 courts'**
  String get zeroCourts;

  /// No description provided for @availableOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{available} of {total} available'**
  String availableOfTotal(int available, int total);

  /// No description provided for @oneOtherPersonViewingThisDate.
  ///
  /// In en, this message translates to:
  /// **'1 other person viewing this date'**
  String get oneOtherPersonViewingThisDate;

  /// No description provided for @othersViewingThisDate.
  ///
  /// In en, this message translates to:
  /// **'{count} others viewing this date'**
  String othersViewingThisDate(int count);

  /// No description provided for @someSessionsAreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Some sessions are unavailable'**
  String get someSessionsAreUnavailable;

  /// No description provided for @slotIsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Slot is available'**
  String get slotIsAvailable;

  /// No description provided for @allSessionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'All {total} sessions available'**
  String allSessionsAvailable(int total);

  /// No description provided for @slotIsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Slot is not available'**
  String get slotIsNotAvailable;

  /// No description provided for @noneOfTheSessionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'None of the {total} sessions are available'**
  String noneOfTheSessionsAvailable(int total);

  /// No description provided for @sessionNoun.
  ///
  /// In en, this message translates to:
  /// **'session'**
  String get sessionNoun;

  /// No description provided for @sessionsUnavailableSummary.
  ///
  /// In en, this message translates to:
  /// **'{taken} unavailable · {available} of {total} available'**
  String sessionsUnavailableSummary(String taken, int available, int total);

  /// No description provided for @atTimeSuffix.
  ///
  /// In en, this message translates to:
  /// **' at {time}'**
  String atTimeSuffix(String time);

  /// No description provided for @scheduleDatesAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'One or more dates in this schedule are already taken{at}. Please pick another date or time.'**
  String scheduleDatesAlreadyTaken(String at);

  /// No description provided for @thisDateIsFree.
  ///
  /// In en, this message translates to:
  /// **'This date is free{at}.'**
  String thisDateIsFree(String at);

  /// No description provided for @everyDateInScheduleIsFree.
  ///
  /// In en, this message translates to:
  /// **'Every date in this schedule is free{at}.'**
  String everyDateInScheduleIsFree(String at);

  /// No description provided for @thisSlotIsAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'This slot is already taken{at}. Please pick another date or time.'**
  String thisSlotIsAlreadyTaken(String at);

  /// No description provided for @slotTakenOnEveryScheduleDate.
  ///
  /// In en, this message translates to:
  /// **'This slot is taken{at} on every date in the schedule. Please pick another date or time.'**
  String slotTakenOnEveryScheduleDate(String at);

  /// No description provided for @sessionLabelIs.
  ///
  /// In en, this message translates to:
  /// **'{label} is'**
  String sessionLabelIs(String label);

  /// No description provided for @datesCountAre.
  ///
  /// In en, this message translates to:
  /// **'{count} dates are'**
  String datesCountAre(int count);

  /// No description provided for @theOtherSession.
  ///
  /// In en, this message translates to:
  /// **'the other session'**
  String get theOtherSession;

  /// No description provided for @theOtherSessions.
  ///
  /// In en, this message translates to:
  /// **'the other {count} sessions'**
  String theOtherSessions(int count);

  /// No description provided for @pronounIt.
  ///
  /// In en, this message translates to:
  /// **'it'**
  String get pronounIt;

  /// No description provided for @pronounThem.
  ///
  /// In en, this message translates to:
  /// **'them'**
  String get pronounThem;

  /// No description provided for @alreadyTakenSkipAndBook.
  ///
  /// In en, this message translates to:
  /// **'{which} already taken{at}. Skip {them} and book {rest}, or pick another date or time.'**
  String alreadyTakenSkipAndBook(
    String which,
    String at,
    String them,
    String rest,
  );

  /// No description provided for @unavailableWithCount.
  ///
  /// In en, this message translates to:
  /// **'Unavailable · {count}'**
  String unavailableWithCount(int count);

  /// No description provided for @availableWithCount.
  ///
  /// In en, this message translates to:
  /// **'Available · {count}'**
  String availableWithCount(int count);

  /// No description provided for @plusMore.
  ///
  /// In en, this message translates to:
  /// **'+ {label}'**
  String plusMore(String label);

  /// No description provided for @moreAvailableDateNoun.
  ///
  /// In en, this message translates to:
  /// **'more available date'**
  String get moreAvailableDateNoun;

  /// No description provided for @pickAnotherDate.
  ///
  /// In en, this message translates to:
  /// **'Pick another date'**
  String get pickAnotherDate;

  /// No description provided for @skipAndBook.
  ///
  /// In en, this message translates to:
  /// **'Skip & book {count}'**
  String skipAndBook(int count);

  /// No description provided for @oneDateIsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'1 date is unavailable'**
  String get oneDateIsUnavailable;

  /// No description provided for @datesAreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{count} dates are unavailable'**
  String datesAreUnavailable(int count);

  /// No description provided for @continueWithoutTheseDates.
  ///
  /// In en, this message translates to:
  /// **'Continue without these dates, or choose another date and slot.'**
  String get continueWithoutTheseDates;

  /// No description provided for @continueWithOneDate.
  ///
  /// In en, this message translates to:
  /// **'Continue with 1 date'**
  String get continueWithOneDate;

  /// No description provided for @continueWithDates.
  ///
  /// In en, this message translates to:
  /// **'Continue with {count} dates'**
  String continueWithDates(int count);

  /// No description provided for @chooseAnotherDateAndSlot.
  ///
  /// In en, this message translates to:
  /// **'Choose another date & slot'**
  String get chooseAnotherDateAndSlot;

  /// No description provided for @noLocationsFoundForThatSearch.
  ///
  /// In en, this message translates to:
  /// **'No locations found for that search.'**
  String get noLocationsFoundForThatSearch;

  /// No description provided for @unableToSearchLocationsRightNow.
  ///
  /// In en, this message translates to:
  /// **'Unable to search locations right now.'**
  String get unableToSearchLocationsRightNow;

  /// No description provided for @searchingExactLocationFor.
  ///
  /// In en, this message translates to:
  /// **'Searching exact location for {lat}, {lng}'**
  String searchingExactLocationFor(String lat, String lng);

  /// No description provided for @pinnedLocation.
  ///
  /// In en, this message translates to:
  /// **'Pinned location ({lat}, {lng})'**
  String pinnedLocation(String lat, String lng);

  /// No description provided for @searchPlaceOrTapMapForExactLocation.
  ///
  /// In en, this message translates to:
  /// **'Search a place or tap on the map to capture the exact location.'**
  String get searchPlaceOrTapMapForExactLocation;

  /// No description provided for @locatingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get locatingEllipsis;

  /// No description provided for @useLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Location'**
  String get useLocation;

  /// No description provided for @selectedPackage.
  ///
  /// In en, this message translates to:
  /// **'Selected package'**
  String get selectedPackage;

  /// No description provided for @tapToChoosePackage.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose package'**
  String get tapToChoosePackage;

  /// No description provided for @createShop.
  ///
  /// In en, this message translates to:
  /// **'Create Shop'**
  String get createShop;

  /// No description provided for @stepOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOfTotal(int step, int total);

  /// No description provided for @advanceRequiredOnEveryCourt.
  ///
  /// In en, this message translates to:
  /// **'Required on every court — at least {percent}% is collected before a booking is confirmed.'**
  String advanceRequiredOnEveryCourt(String percent);

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @nprAmount.
  ///
  /// In en, this message translates to:
  /// **'NPR {amount}'**
  String nprAmount(String amount);

  /// No description provided for @cityFieldName.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityFieldName;

  /// No description provided for @countryFieldName.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryFieldName;

  /// No description provided for @futsalNameFieldName.
  ///
  /// In en, this message translates to:
  /// **'Futsal name'**
  String get futsalNameFieldName;

  /// No description provided for @contactPhoneFieldName.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get contactPhoneFieldName;

  /// No description provided for @contactEmailFieldName.
  ///
  /// In en, this message translates to:
  /// **'Contact email'**
  String get contactEmailFieldName;

  /// No description provided for @couldNotLoadMoreVenues.
  ///
  /// In en, this message translates to:
  /// **'Could not load more venues.'**
  String get couldNotLoadMoreVenues;

  /// No description provided for @startByAddingYourFirstVenue.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first venue'**
  String get startByAddingYourFirstVenue;

  /// No description provided for @everythingYouOwnAtAGlance.
  ///
  /// In en, this message translates to:
  /// **'Everything you own, at a glance'**
  String get everythingYouOwnAtAGlance;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @courtIsNowInactive.
  ///
  /// In en, this message translates to:
  /// **'Court is now inactive.'**
  String get courtIsNowInactive;

  /// No description provided for @courtIsNowActive.
  ///
  /// In en, this message translates to:
  /// **'Court is now active.'**
  String get courtIsNowActive;

  /// No description provided for @playersCountLowercase.
  ///
  /// In en, this message translates to:
  /// **'{count} players'**
  String playersCountLowercase(int count);

  /// No description provided for @perHrSuffix.
  ///
  /// In en, this message translates to:
  /// **' /hr'**
  String get perHrSuffix;

  /// No description provided for @noAdvance.
  ///
  /// In en, this message translates to:
  /// **'No advance'**
  String get noAdvance;

  /// No description provided for @makeInactive.
  ///
  /// In en, this message translates to:
  /// **'Make Inactive'**
  String get makeInactive;

  /// No description provided for @makeActive.
  ///
  /// In en, this message translates to:
  /// **'Make Active'**
  String get makeActive;

  /// No description provided for @noFutsalVenuesYet.
  ///
  /// In en, this message translates to:
  /// **'No futsal venues yet'**
  String get noFutsalVenuesYet;

  /// No description provided for @tryADifferentSearchOrFilter.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or filter.'**
  String get tryADifferentSearchOrFilter;

  /// No description provided for @createYourFirstVenueAndAddCourts.
  ///
  /// In en, this message translates to:
  /// **'Create your first venue and add courts for online booking.'**
  String get createYourFirstVenueAndAddCourts;

  /// No description provided for @myFutsal.
  ///
  /// In en, this message translates to:
  /// **'My Futsal'**
  String get myFutsal;

  /// No description provided for @confirmDeleteCourt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String confirmDeleteCourt(String name);

  /// No description provided for @showerArea.
  ///
  /// In en, this message translates to:
  /// **'Shower Area'**
  String get showerArea;

  /// No description provided for @firstAidDesk.
  ///
  /// In en, this message translates to:
  /// **'First Aid Desk'**
  String get firstAidDesk;

  /// No description provided for @starterPackagePrice.
  ///
  /// In en, this message translates to:
  /// **'NPR 2,500 / month'**
  String get starterPackagePrice;

  /// No description provided for @growthPackagePrice.
  ///
  /// In en, this message translates to:
  /// **'NPR 5,500 / month'**
  String get growthPackagePrice;

  /// No description provided for @elitePackagePrice.
  ///
  /// In en, this message translates to:
  /// **'NPR 9,500 / month'**
  String get elitePackagePrice;

  /// No description provided for @oneVenueProfile.
  ///
  /// In en, this message translates to:
  /// **'1 venue profile'**
  String get oneVenueProfile;

  /// No description provided for @basicListingVisibility.
  ///
  /// In en, this message translates to:
  /// **'Basic listing visibility'**
  String get basicListingVisibility;

  /// No description provided for @manualBookingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Manual booking confirmation'**
  String get manualBookingConfirmation;

  /// No description provided for @priorityListingPlacement.
  ///
  /// In en, this message translates to:
  /// **'Priority listing placement'**
  String get priorityListingPlacement;

  /// No description provided for @bookingWorkflowSupport.
  ///
  /// In en, this message translates to:
  /// **'Booking workflow support'**
  String get bookingWorkflowSupport;

  /// No description provided for @basicReportingAccess.
  ///
  /// In en, this message translates to:
  /// **'Basic reporting access'**
  String get basicReportingAccess;

  /// No description provided for @multiCourtManagement.
  ///
  /// In en, this message translates to:
  /// **'Multi-court management'**
  String get multiCourtManagement;

  /// No description provided for @premiumBrandingPlacement.
  ///
  /// In en, this message translates to:
  /// **'Premium branding placement'**
  String get premiumBrandingPlacement;

  /// No description provided for @prioritySupportRouting.
  ///
  /// In en, this message translates to:
  /// **'Priority support routing'**
  String get prioritySupportRouting;

  /// No description provided for @advancePaymentOptional.
  ///
  /// In en, this message translates to:
  /// **'Advance payment optional'**
  String get advancePaymentOptional;

  /// No description provided for @cancellationAllowed.
  ///
  /// In en, this message translates to:
  /// **'Cancellation allowed'**
  String get cancellationAllowed;

  /// No description provided for @cancellationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Cancellation not allowed'**
  String get cancellationNotAllowed;

  /// No description provided for @refundsSupported.
  ///
  /// In en, this message translates to:
  /// **'Refunds supported'**
  String get refundsSupported;

  /// No description provided for @refundsNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Refunds not supported'**
  String get refundsNotSupported;

  /// No description provided for @fieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldIsRequired(String field);

  /// No description provided for @fieldMustBePositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'{field} must be a positive number'**
  String fieldMustBePositiveNumber(String field);

  /// No description provided for @useLowercaseLettersNumbersHyphensOnly.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters, numbers, and hyphens only'**
  String get useLowercaseLettersNumbersHyphensOnly;

  /// No description provided for @enterAValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterAValidEmailAddress;

  /// No description provided for @enterAValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterAValidPhoneNumber;

  /// No description provided for @establishedYearFieldName.
  ///
  /// In en, this message translates to:
  /// **'Established year'**
  String get establishedYearFieldName;

  /// No description provided for @enterAValidFourDigitYear.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 4-digit year'**
  String get enterAValidFourDigitYear;

  /// No description provided for @yearMustBeBetween1900And.
  ///
  /// In en, this message translates to:
  /// **'Year must be between 1900 and {currentYear}'**
  String yearMustBeBetween1900And(String currentYear);

  /// No description provided for @enterAValidWebsiteUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid website URL'**
  String get enterAValidWebsiteUrl;

  /// No description provided for @basicPriceFieldName.
  ///
  /// In en, this message translates to:
  /// **'Basic price'**
  String get basicPriceFieldName;

  /// No description provided for @enterAValidPriceAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price amount'**
  String get enterAValidPriceAmount;

  /// No description provided for @bookingAdvanceDaysFieldName.
  ///
  /// In en, this message translates to:
  /// **'Booking advance days'**
  String get bookingAdvanceDaysFieldName;

  /// No description provided for @cancellationWindowFieldName.
  ///
  /// In en, this message translates to:
  /// **'Cancellation window'**
  String get cancellationWindowFieldName;

  /// No description provided for @exactLocationIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Exact location is required'**
  String get exactLocationIsRequired;

  /// No description provided for @selectExactLocationFromMap.
  ///
  /// In en, this message translates to:
  /// **'Select the exact location from the map'**
  String get selectExactLocationFromMap;

  /// No description provided for @enterAValidUrlHttps.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL (https://...)'**
  String get enterAValidUrlHttps;

  /// No description provided for @houseRulesFieldName.
  ///
  /// In en, this message translates to:
  /// **'House rules'**
  String get houseRulesFieldName;

  /// No description provided for @selectAtLeastOneAmenityOrFacility.
  ///
  /// In en, this message translates to:
  /// **'Select at least one amenity or facility.'**
  String get selectAtLeastOneAmenityOrFacility;

  /// No description provided for @chooseAPackageToContinue.
  ///
  /// In en, this message translates to:
  /// **'Choose a package to continue.'**
  String get chooseAPackageToContinue;

  /// No description provided for @couldNotReadTheSelectedFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file.'**
  String get couldNotReadTheSelectedFile;

  /// No description provided for @couldNotOpenMapsApplication.
  ///
  /// In en, this message translates to:
  /// **'Could not open the maps application.'**
  String get couldNotOpenMapsApplication;

  /// No description provided for @venueHasNotSharedMapCoordinates.
  ///
  /// In en, this message translates to:
  /// **'This venue hasn\'t shared map coordinates yet.'**
  String get venueHasNotSharedMapCoordinates;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @hostingSince.
  ///
  /// In en, this message translates to:
  /// **'Hosting since {since}'**
  String hostingSince(String since);

  /// No description provided for @seeAllCount.
  ///
  /// In en, this message translates to:
  /// **'See All ({count})'**
  String seeAllCount(String count);

  /// No description provided for @contactForHours.
  ///
  /// In en, this message translates to:
  /// **'Contact for hours'**
  String get contactForHours;

  /// No description provided for @aboutThisVenue.
  ///
  /// In en, this message translates to:
  /// **'About this venue'**
  String get aboutThisVenue;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get readLess;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @otherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherCategory;

  /// No description provided for @amenityCategoryFacility.
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get amenityCategoryFacility;

  /// No description provided for @amenityCategoryLighting.
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get amenityCategoryLighting;

  /// No description provided for @amenityCategoryAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get amenityCategoryAccess;

  /// No description provided for @amenityCategoryComfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get amenityCategoryComfort;

  /// No description provided for @amenityCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get amenityCategoryFood;

  /// No description provided for @amenityCategorySafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get amenityCategorySafety;

  /// No description provided for @amenityCategoryConnectivity.
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get amenityCategoryConnectivity;

  /// No description provided for @couldNotParseFeedbackOptions.
  ///
  /// In en, this message translates to:
  /// **'Could not parse feedback options from server.'**
  String get couldNotParseFeedbackOptions;

  /// No description provided for @couldNotParseFeedbackList.
  ///
  /// In en, this message translates to:
  /// **'Could not parse feedback list from server.'**
  String get couldNotParseFeedbackList;

  /// No description provided for @couldNotParseFeedbackDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not parse feedback details from server.'**
  String get couldNotParseFeedbackDetails;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @biometricNotAvailableOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Face ID or fingerprint is not available on this device.'**
  String get biometricNotAvailableOnDevice;

  /// No description provided for @addReasonForDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Please add a reason for deleting your account.'**
  String get addReasonForDeletingAccount;

  /// No description provided for @myFeedback.
  ///
  /// In en, this message translates to:
  /// **'My Feedback'**
  String get myFeedback;

  /// No description provided for @feedbackSubmissionsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} submission · tap one to see its details and status} other{{count} submissions · tap one to see its details and status}}'**
  String feedbackSubmissionsSummary(int count);

  /// No description provided for @noFeedbackYet.
  ///
  /// In en, this message translates to:
  /// **'No feedback yet'**
  String get noFeedbackYet;

  /// No description provided for @submittedFeedbackWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your submitted feedback will appear here once you share it with us.'**
  String get submittedFeedbackWillAppearHere;

  /// No description provided for @chooseFeedbackTypeAndCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Please choose a feedback type and category first.'**
  String get chooseFeedbackTypeAndCategoryFirst;

  /// No description provided for @rateYourExperienceBeforeSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Please rate your experience before submitting.'**
  String get rateYourExperienceBeforeSubmitting;

  /// No description provided for @howWasYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get howWasYourExperience;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'What worked well? What should we improve? The more detail, the better.'**
  String get feedbackMessageHint;

  /// No description provided for @addAShortMessage.
  ///
  /// In en, this message translates to:
  /// **'Please add a short message.'**
  String get addAShortMessage;

  /// No description provided for @provideALittleMoreDetail.
  ///
  /// In en, this message translates to:
  /// **'Please provide a little more detail.'**
  String get provideALittleMoreDetail;

  /// No description provided for @phoneNumberOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Phone number or email'**
  String get phoneNumberOrEmail;

  /// No description provided for @enterAValidContact.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid contact.'**
  String get enterAValidContact;

  /// No description provided for @loadingOptions.
  ///
  /// In en, this message translates to:
  /// **'Loading options...'**
  String get loadingOptions;

  /// No description provided for @noFeedbackCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No feedback categories available.'**
  String get noFeedbackCategoriesAvailable;

  /// No description provided for @noFeedbackTypesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No feedback types available.'**
  String get noFeedbackTypesAvailable;

  /// No description provided for @ratingTerrible.
  ///
  /// In en, this message translates to:
  /// **'Terrible'**
  String get ratingTerrible;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get thankYou;

  /// No description provided for @loadingVersion.
  ///
  /// In en, this message translates to:
  /// **'Loading version…'**
  String get loadingVersion;

  /// No description provided for @madeBy.
  ///
  /// In en, this message translates to:
  /// **'Made by'**
  String get madeBy;

  /// No description provided for @ourMission.
  ///
  /// In en, this message translates to:
  /// **'Our mission'**
  String get ourMission;

  /// No description provided for @whatWeOffer.
  ///
  /// In en, this message translates to:
  /// **'What we offer'**
  String get whatWeOffer;

  /// No description provided for @whyWeBuiltThis.
  ///
  /// In en, this message translates to:
  /// **'Why we built this'**
  String get whyWeBuiltThis;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Hamro Futsal · v{version}'**
  String appVersionLabel(String version);

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String versionLabel(String version);

  /// No description provided for @feedbackDetailsCouldNotBeOpened.
  ///
  /// In en, this message translates to:
  /// **'Feedback details could not be opened.'**
  String get feedbackDetailsCouldNotBeOpened;

  /// No description provided for @feedbackDetails.
  ///
  /// In en, this message translates to:
  /// **'Feedback Details'**
  String get feedbackDetails;

  /// No description provided for @submittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted on'**
  String get submittedOn;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get contactInfo;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out…'**
  String get loggingOut;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @profileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile unavailable'**
  String get profileUnavailable;

  /// No description provided for @pullToRefreshYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh your account'**
  String get pullToRefreshYourAccount;

  /// No description provided for @logOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutQuestion;

  /// No description provided for @logOutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your bookings, chats, and profile.'**
  String get logOutConfirmationMessage;

  /// No description provided for @vendorAccountActive.
  ///
  /// In en, this message translates to:
  /// **'Vendor account active'**
  String get vendorAccountActive;

  /// No description provided for @businessVerifiedReadyForBookings.
  ///
  /// In en, this message translates to:
  /// **'Your business is verified and ready to receive bookings.'**
  String get businessVerifiedReadyForBookings;

  /// No description provided for @vendorActiveVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Your vendor account is active. Business verification is pending.'**
  String get vendorActiveVerificationPending;

  /// No description provided for @businessUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Business under review'**
  String get businessUnderReview;

  /// No description provided for @hamroFutsalReviewingBusinessInfo.
  ///
  /// In en, this message translates to:
  /// **'Hamro Futsal is reviewing your submitted business information.'**
  String get hamroFutsalReviewingBusinessInfo;

  /// No description provided for @businessVerificationRejected.
  ///
  /// In en, this message translates to:
  /// **'Business verification rejected'**
  String get businessVerificationRejected;

  /// No description provided for @reviewBusinessInfoAndResubmit.
  ///
  /// In en, this message translates to:
  /// **'Review your business information and submit it again.'**
  String get reviewBusinessInfoAndResubmit;

  /// No description provided for @vendorAccountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Vendor account suspended'**
  String get vendorAccountSuspended;

  /// No description provided for @contactSupportForAssistance.
  ///
  /// In en, this message translates to:
  /// **'Contact Hamro Futsal support for assistance.'**
  String get contactSupportForAssistance;

  /// No description provided for @actionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action required'**
  String get actionRequired;

  /// No description provided for @updateVendorInfoToContinue.
  ///
  /// In en, this message translates to:
  /// **'Update your vendor information to continue.'**
  String get updateVendorInfoToContinue;

  /// No description provided for @completeVendorSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete vendor setup'**
  String get completeVendorSetup;

  /// No description provided for @finishVenueAndBusinessDetails.
  ///
  /// In en, this message translates to:
  /// **'Finish your venue and business details to start accepting bookings.'**
  String get finishVenueAndBusinessDetails;

  /// No description provided for @startVendorSetup.
  ///
  /// In en, this message translates to:
  /// **'Start vendor setup'**
  String get startVendorSetup;

  /// No description provided for @addBusinessAndVenueDetails.
  ///
  /// In en, this message translates to:
  /// **'Add your business and venue details to become a verified vendor.'**
  String get addBusinessAndVenueDetails;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactInformation;

  /// No description provided for @nameNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Name not provided'**
  String get nameNotProvided;

  /// No description provided for @addressNotSet.
  ///
  /// In en, this message translates to:
  /// **'Address not set'**
  String get addressNotSet;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @enterYourBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Enter your business name'**
  String get enterYourBusinessName;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @enterYourBusinessAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your business address'**
  String get enterYourBusinessAddress;

  /// No description provided for @addAnOptionalMessage.
  ///
  /// In en, this message translates to:
  /// **'Add an optional message'**
  String get addAnOptionalMessage;

  /// No description provided for @bookingSavedReference.
  ///
  /// In en, this message translates to:
  /// **'Booking saved. Reference: {reference}'**
  String bookingSavedReference(String reference);

  /// No description provided for @paymentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment: {payment}'**
  String paymentStatusLabel(String payment);

  /// No description provided for @referenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference: {reference}'**
  String referenceLabel(String reference);

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @goodDayVendor.
  ///
  /// In en, this message translates to:
  /// **'Good day, vendor'**
  String get goodDayVendor;

  /// No description provided for @freeSlots.
  ///
  /// In en, this message translates to:
  /// **'Free slots'**
  String get freeSlots;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @amountInRupees.
  ///
  /// In en, this message translates to:
  /// **'Rs. {amount}'**
  String amountInRupees(String amount);

  /// No description provided for @dueRsAmount.
  ///
  /// In en, this message translates to:
  /// **'Due Rs. {amount}'**
  String dueRsAmount(String amount);

  /// No description provided for @todaySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today schedule'**
  String get todaySchedule;

  /// No description provided for @tapFreeTimeToAddToBooking.
  ///
  /// In en, this message translates to:
  /// **'Tap a free time to add it to a booking.'**
  String get tapFreeTimeToAddToBooking;

  /// No description provided for @selectFreeTimesFirst.
  ///
  /// In en, this message translates to:
  /// **'Select free times first.'**
  String get selectFreeTimesFirst;

  /// No description provided for @timesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} time selected'**
  String timesSelected(int count);

  /// No description provided for @slotTimeAndPrice.
  ///
  /// In en, this message translates to:
  /// **'{timeRange} · Rs. {price}'**
  String slotTimeAndPrice(String timeRange, String price);

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer phone'**
  String get customerPhone;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmount;

  /// No description provided for @saveBooking.
  ///
  /// In en, this message translates to:
  /// **'Save booking'**
  String get saveBooking;

  /// No description provided for @todaysBookings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s bookings'**
  String get todaysBookings;

  /// No description provided for @searchByNamePhoneOrReference.
  ///
  /// In en, this message translates to:
  /// **'Search by name, phone, or reference.'**
  String get searchByNamePhoneOrReference;

  /// No description provided for @searchBooking.
  ///
  /// In en, this message translates to:
  /// **'Search booking'**
  String get searchBooking;

  /// No description provided for @noBookingsFound.
  ///
  /// In en, this message translates to:
  /// **'No bookings found.'**
  String get noBookingsFound;

  /// No description provided for @tapAFreeTime.
  ///
  /// In en, this message translates to:
  /// **'Tap a free time'**
  String get tapAFreeTime;

  /// No description provided for @selectedTimesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Selected times will appear here.'**
  String get selectedTimesWillAppearHere;

  /// No description provided for @expenseCategoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get expenseCategoryRent;

  /// No description provided for @expenseCategoryMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get expenseCategoryMaintenance;

  /// No description provided for @expenseCategorySalaries.
  ///
  /// In en, this message translates to:
  /// **'Salaries'**
  String get expenseCategorySalaries;

  /// No description provided for @expenseCategorySupplies.
  ///
  /// In en, this message translates to:
  /// **'Supplies'**
  String get expenseCategorySupplies;

  /// No description provided for @expenseCategoryMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get expenseCategoryMarketing;

  /// No description provided for @expenseCategoryRefreshments.
  ///
  /// In en, this message translates to:
  /// **'Refreshments'**
  String get expenseCategoryRefreshments;

  /// No description provided for @expenseCategoryInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get expenseCategoryInsurance;

  /// No description provided for @expenseCategoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get expenseCategoryUtilities;

  /// No description provided for @expenseCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expenseCategoryOther;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @hourlySpend.
  ///
  /// In en, this message translates to:
  /// **'Hourly spend'**
  String get hourlySpend;

  /// No description provided for @monthlySpend.
  ///
  /// In en, this message translates to:
  /// **'Monthly spend'**
  String get monthlySpend;

  /// No description provided for @dailySpend.
  ///
  /// In en, this message translates to:
  /// **'Daily spend'**
  String get dailySpend;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @couldNotLoadExpenses.
  ///
  /// In en, this message translates to:
  /// **'Could not load expenses.'**
  String get couldNotLoadExpenses;

  /// No description provided for @expenseAdded.
  ///
  /// In en, this message translates to:
  /// **'Expense added · {amount}'**
  String expenseAdded(String amount);

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted · {amount}'**
  String expenseDeleted(String amount);

  /// No description provided for @expenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated · {amount}'**
  String expenseUpdated(String amount);

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpense;

  /// No description provided for @newExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get newExpenseTitle;

  /// No description provided for @pickACategory.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get pickACategory;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update expense'**
  String get updateExpense;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get saveExpense;

  /// No description provided for @updateExpenseWithAmount.
  ///
  /// In en, this message translates to:
  /// **'Update expense · {amount}'**
  String updateExpenseWithAmount(String amount);

  /// No description provided for @saveExpenseWithAmount.
  ///
  /// In en, this message translates to:
  /// **'Save expense · {amount}'**
  String saveExpenseWithAmount(String amount);

  /// No description provided for @todayCommaDate.
  ///
  /// In en, this message translates to:
  /// **'Today, {date}'**
  String todayCommaDate(String date);

  /// No description provided for @fileSizeMb.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String fileSizeMb(String size);

  /// No description provided for @fileSizeKb.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String fileSizeKb(String size);

  /// No description provided for @totalSpend.
  ///
  /// In en, this message translates to:
  /// **'Total spend'**
  String get totalSpend;

  /// No description provided for @trend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @byCourt.
  ///
  /// In en, this message translates to:
  /// **'By court'**
  String get byCourt;

  /// No description provided for @recordsForCategory.
  ///
  /// In en, this message translates to:
  /// **'Records · {category}'**
  String recordsForCategory(String category);

  /// No description provided for @selectAStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select a start date'**
  String get selectAStartDate;

  /// No description provided for @sevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get sevenDays;

  /// No description provided for @thirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get thirtyDays;

  /// No description provided for @avgAmount.
  ///
  /// In en, this message translates to:
  /// **'Avg {amount}'**
  String avgAmount(String amount);

  /// No description provided for @plusMoreCount.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more'**
  String plusMoreCount(int count);

  /// No description provided for @enterAmountGreaterThan0.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get enterAmountGreaterThan0;

  /// No description provided for @tapToEnterExpenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Tap to enter the expense amount'**
  String get tapToEnterExpenseAmount;

  /// No description provided for @avgPerDayWithEntries.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount} / day · {entries, plural, =1{{entries} entry} other{{entries} entries}}'**
  String avgPerDayWithEntries(String amount, int entries);

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @avgPerEntry.
  ///
  /// In en, this message translates to:
  /// **'Avg {amount} / entry'**
  String avgPerEntry(String amount);

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYet;

  /// No description provided for @noMatchingRecords.
  ///
  /// In en, this message translates to:
  /// **'No matching records'**
  String get noMatchingRecords;

  /// No description provided for @noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecordsYet;

  /// No description provided for @tryDifferentPeriodVenueOrCategory.
  ///
  /// In en, this message translates to:
  /// **'Try a different period, venue or category.'**
  String get tryDifferentPeriodVenueOrCategory;

  /// No description provided for @expensesYouAddWillShowUpHere.
  ///
  /// In en, this message translates to:
  /// **'Expenses you add will show up here.'**
  String get expensesYouAddWillShowUpHere;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @todayUpper.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayUpper;

  /// No description provided for @yesterdayUpper.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get yesterdayUpper;

  /// No description provided for @dotEntryCount.
  ///
  /// In en, this message translates to:
  /// **'· {count, plural, =1{{count} entry} other{{count} entries}}'**
  String dotEntryCount(int count);

  /// No description provided for @rangeEntriesSummary.
  ///
  /// In en, this message translates to:
  /// **'{label} · {count} entries · {total}'**
  String rangeEntriesSummary(String label, int count, String total);

  /// No description provided for @customDays.
  ///
  /// In en, this message translates to:
  /// **'Custom · {days}d'**
  String customDays(int days);

  /// No description provided for @allMethods.
  ///
  /// In en, this message translates to:
  /// **'All methods'**
  String get allMethods;

  /// No description provided for @venueCourt.
  ///
  /// In en, this message translates to:
  /// **'Venue · Court'**
  String get venueCourt;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @couldNotDownloadChatMedia.
  ///
  /// In en, this message translates to:
  /// **'Could not download chat media.'**
  String get couldNotDownloadChatMedia;

  /// No description provided for @tooManyRequestsTryAgainIn.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again in {seconds} seconds.'**
  String tooManyRequestsTryAgainIn(int seconds);

  /// No description provided for @parseTargetConversations.
  ///
  /// In en, this message translates to:
  /// **'conversations'**
  String get parseTargetConversations;

  /// No description provided for @parseTargetRegisteredUsers.
  ///
  /// In en, this message translates to:
  /// **'registered users'**
  String get parseTargetRegisteredUsers;

  /// No description provided for @parseTargetConversation.
  ///
  /// In en, this message translates to:
  /// **'the conversation'**
  String get parseTargetConversation;

  /// No description provided for @parseTargetGroupConversation.
  ///
  /// In en, this message translates to:
  /// **'the group conversation'**
  String get parseTargetGroupConversation;

  /// No description provided for @parseTargetUserPresence.
  ///
  /// In en, this message translates to:
  /// **'user presence'**
  String get parseTargetUserPresence;

  /// No description provided for @parseTargetProfile.
  ///
  /// In en, this message translates to:
  /// **'the profile'**
  String get parseTargetProfile;

  /// No description provided for @parseTargetMessages.
  ///
  /// In en, this message translates to:
  /// **'messages'**
  String get parseTargetMessages;

  /// No description provided for @parseTargetSentMessage.
  ///
  /// In en, this message translates to:
  /// **'the sent message'**
  String get parseTargetSentMessage;

  /// No description provided for @conversationFilterDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get conversationFilterDirect;

  /// No description provided for @conversationFilterGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get conversationFilterGroups;

  /// No description provided for @conversationFilterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get conversationFilterArchived;

  /// No description provided for @conversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get conversation;

  /// No description provided for @noMessagesYetSayHello.
  ///
  /// In en, this message translates to:
  /// **'No messages yet — say hello!'**
  String get noMessagesYetSayHello;

  /// No description provided for @youPrefixed.
  ///
  /// In en, this message translates to:
  /// **'You: {text}'**
  String youPrefixed(String text);

  /// No description provided for @nowLower.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get nowLower;

  /// No description provided for @hoursAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr ago'**
  String hoursAgoShort(int hours);

  /// No description provided for @daysAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{days} day ago'**
  String daysAgoShort(int days);

  /// No description provided for @groupPhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group photo updated.'**
  String get groupPhotoUpdated;

  /// No description provided for @groupUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group updated.'**
  String get groupUpdated;

  /// No description provided for @youJoinedTheGroup.
  ///
  /// In en, this message translates to:
  /// **'You joined the group.'**
  String get youJoinedTheGroup;

  /// No description provided for @invitationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined.'**
  String get invitationDeclined;

  /// No description provided for @youLeftTheGroup.
  ///
  /// In en, this message translates to:
  /// **'You left the group.'**
  String get youLeftTheGroup;

  /// No description provided for @memberAdded.
  ///
  /// In en, this message translates to:
  /// **'Member added.'**
  String get memberAdded;

  /// No description provided for @membersAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} members added.'**
  String membersAdded(int count);

  /// No description provided for @conversationArchived.
  ///
  /// In en, this message translates to:
  /// **'Conversation archived.'**
  String get conversationArchived;

  /// No description provided for @conversationUnarchived.
  ///
  /// In en, this message translates to:
  /// **'Conversation unarchived.'**
  String get conversationUnarchived;

  /// No description provided for @conversationMuted.
  ///
  /// In en, this message translates to:
  /// **'Conversation muted.'**
  String get conversationMuted;

  /// No description provided for @conversationUnmuted.
  ///
  /// In en, this message translates to:
  /// **'Conversation unmuted.'**
  String get conversationUnmuted;

  /// No description provided for @participantBlocked.
  ///
  /// In en, this message translates to:
  /// **'Participant blocked.'**
  String get participantBlocked;

  /// No description provided for @participantUnblocked.
  ///
  /// In en, this message translates to:
  /// **'Participant unblocked.'**
  String get participantUnblocked;

  /// No description provided for @messageDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Message deleted.'**
  String get messageDeletedSuccess;

  /// No description provided for @messageMaxFiles.
  ///
  /// In en, this message translates to:
  /// **'A message can contain at most 5 files.'**
  String get messageMaxFiles;

  /// No description provided for @locationUnavailableCheckPermission.
  ///
  /// In en, this message translates to:
  /// **'Location is unavailable. Check location permission and services.'**
  String get locationUnavailableCheckPermission;

  /// No description provided for @sharedLocation.
  ///
  /// In en, this message translates to:
  /// **'Shared location'**
  String get sharedLocation;

  /// No description provided for @saveFileNamed.
  ///
  /// In en, this message translates to:
  /// **'Save {name}'**
  String saveFileNamed(String name);

  /// No description provided for @couldNotLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Could not load messages.'**
  String get couldNotLoadMessages;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} member} other{{count} members}}'**
  String memberCount(int count);

  /// No description provided for @checkingPresence.
  ///
  /// In en, this message translates to:
  /// **'Checking presence…'**
  String get checkingPresence;

  /// No description provided for @couldNotLoadUsers.
  ///
  /// In en, this message translates to:
  /// **'Could not load users.'**
  String get couldNotLoadUsers;

  /// No description provided for @selectAtLeastOneMember.
  ///
  /// In en, this message translates to:
  /// **'Select at least one member.'**
  String get selectAtLeastOneMember;

  /// No description provided for @groupMaxMembers.
  ///
  /// In en, this message translates to:
  /// **'A group can contain at most {max} members.'**
  String groupMaxMembers(int max);

  /// No description provided for @tapToAddUpToPeople.
  ///
  /// In en, this message translates to:
  /// **'Tap to add up to {max} people.'**
  String tapToAddUpToPeople(int max);

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @registeredUsersWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Registered users will appear here.'**
  String get registeredUsersWillAppearHere;

  /// No description provided for @declineInvitationTo.
  ///
  /// In en, this message translates to:
  /// **'Decline the invitation to \"{title}\"?'**
  String declineInvitationTo(String title);

  /// No description provided for @couldNotLoadConversations.
  ///
  /// In en, this message translates to:
  /// **'Could not load conversations.'**
  String get couldNotLoadConversations;

  /// No description provided for @selectAConversation.
  ///
  /// In en, this message translates to:
  /// **'Select a conversation'**
  String get selectAConversation;

  /// No description provided for @pickAChatToReadAndReply.
  ///
  /// In en, this message translates to:
  /// **'Pick a chat from the list to read and reply here.'**
  String get pickAChatToReadAndReply;

  /// No description provided for @couldNotLoadMoreConversations.
  ///
  /// In en, this message translates to:
  /// **'Could not load more conversations.'**
  String get couldNotLoadMoreConversations;

  /// No description provided for @conversationsUnreadSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} conversations'**
  String conversationsUnreadSummary(int count);

  /// No description provided for @conversationsUnreadSummarySuffix.
  ///
  /// In en, this message translates to:
  /// **' · {unread} unread'**
  String conversationsUnreadSummarySuffix(int unread);

  /// No description provided for @creatingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creatingEllipsis;

  /// No description provided for @cannotSendMessagesInConversation.
  ///
  /// In en, this message translates to:
  /// **'You cannot send messages in this conversation.'**
  String get cannotSendMessagesInConversation;

  /// No description provided for @typeHere.
  ///
  /// In en, this message translates to:
  /// **'Type here'**
  String get typeHere;

  /// No description provided for @notifyEveryone.
  ///
  /// In en, this message translates to:
  /// **'Notify everyone'**
  String get notifyEveryone;

  /// No description provided for @deletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleted message'**
  String get deletedMessage;

  /// No description provided for @replyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to {senderName}: {body}'**
  String replyingTo(String senderName, String body);

  /// No description provided for @replyingToMessageFallback.
  ///
  /// In en, this message translates to:
  /// **'message'**
  String get replyingToMessageFallback;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// No description provided for @opensInTheApp.
  ///
  /// In en, this message translates to:
  /// **'{text}, opens in the app'**
  String opensInTheApp(String text);

  /// No description provided for @userNumber.
  ///
  /// In en, this message translates to:
  /// **'User #{id}'**
  String userNumber(int id);

  /// No description provided for @selectAtLeastOneNewMember.
  ///
  /// In en, this message translates to:
  /// **'Select at least one new member.'**
  String get selectAtLeastOneNewMember;

  /// No description provided for @choosePeopleToAddInGroup.
  ///
  /// In en, this message translates to:
  /// **'Choose people to add in this group'**
  String get choosePeopleToAddInGroup;

  /// No description provided for @addMemberCount.
  ///
  /// In en, this message translates to:
  /// **'Add {count, plural, =1{{count} member} other{{count} members}}'**
  String addMemberCount(int count);

  /// No description provided for @noMatchingConversations.
  ///
  /// In en, this message translates to:
  /// **'No matching conversations'**
  String get noMatchingConversations;

  /// No description provided for @tryDifferentFilterOrSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter or search term.'**
  String get tryDifferentFilterOrSearch;

  /// No description provided for @yourConversationsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your conversations will appear here.'**
  String get yourConversationsWillAppearHere;

  /// No description provided for @greetingFallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get greetingFallbackName;

  /// No description provided for @checkConnectionAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get checkConnectionAndTryAgain;

  /// No description provided for @rsPriceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Rs. --'**
  String get rsPriceUnavailable;

  /// No description provided for @rsDotAmount.
  ///
  /// In en, this message translates to:
  /// **'Rs. {amount}'**
  String rsDotAmount(String amount);

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String distanceKm(String value);

  /// No description provided for @thisMonthRevenue.
  ///
  /// In en, this message translates to:
  /// **'This month revenue'**
  String get thisMonthRevenue;

  /// No description provided for @bookedSlotsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Booked slots this month'**
  String get bookedSlotsThisMonth;

  /// No description provided for @courtUsageToday.
  ///
  /// In en, this message translates to:
  /// **'Court usage today'**
  String get courtUsageToday;

  /// No description provided for @cancelledReservations.
  ///
  /// In en, this message translates to:
  /// **'Cancelled reservations'**
  String get cancelledReservations;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get openNow;

  /// No description provided for @closedNow.
  ///
  /// In en, this message translates to:
  /// **'Closed Now'**
  String get closedNow;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// No description provided for @futsalVendor.
  ///
  /// In en, this message translates to:
  /// **'Futsal Vendor'**
  String get futsalVendor;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @activeNowAt.
  ///
  /// In en, this message translates to:
  /// **'Active now · {time}'**
  String activeNowAt(String time);

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get markRead;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @football.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get football;

  /// No description provided for @trainingBibs.
  ///
  /// In en, this message translates to:
  /// **'Training bibs'**
  String get trainingBibs;

  /// No description provided for @goalkeeperGloves.
  ///
  /// In en, this message translates to:
  /// **'Goalkeeper gloves'**
  String get goalkeeperGloves;

  /// No description provided for @conesSetOf10.
  ///
  /// In en, this message translates to:
  /// **'Cones (set of 10)'**
  String get conesSetOf10;

  /// No description provided for @shinGuards.
  ///
  /// In en, this message translates to:
  /// **'Shin guards'**
  String get shinGuards;

  /// No description provided for @futsalBoots.
  ///
  /// In en, this message translates to:
  /// **'Futsal boots'**
  String get futsalBoots;

  /// No description provided for @waterBottle.
  ///
  /// In en, this message translates to:
  /// **'Water bottle'**
  String get waterBottle;

  /// No description provided for @towel.
  ///
  /// In en, this message translates to:
  /// **'Towel'**
  String get towel;

  /// No description provided for @tacticBoard.
  ///
  /// In en, this message translates to:
  /// **'Tactic board'**
  String get tacticBoard;

  /// No description provided for @bibs.
  ///
  /// In en, this message translates to:
  /// **'Bibs'**
  String get bibs;

  /// No description provided for @gloves.
  ///
  /// In en, this message translates to:
  /// **'Gloves'**
  String get gloves;

  /// No description provided for @cones.
  ///
  /// In en, this message translates to:
  /// **'Cones'**
  String get cones;

  /// No description provided for @boots.
  ///
  /// In en, this message translates to:
  /// **'Boots'**
  String get boots;

  /// No description provided for @bottle.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get bottle;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @equipmentAdded.
  ///
  /// In en, this message translates to:
  /// **'Equipment added · {name}'**
  String equipmentAdded(String name);

  /// No description provided for @addEquipmentFirst.
  ///
  /// In en, this message translates to:
  /// **'Add equipment first'**
  String get addEquipmentFirst;

  /// No description provided for @rentalStartedFor.
  ///
  /// In en, this message translates to:
  /// **'Rental started for {customer}'**
  String rentalStartedFor(String customer);

  /// No description provided for @markedReturned.
  ///
  /// In en, this message translates to:
  /// **'Marked returned · {customer}'**
  String markedReturned(String customer);

  /// No description provided for @addItemsToStartRenting.
  ///
  /// In en, this message translates to:
  /// **'Add items to start renting them out.'**
  String get addItemsToStartRenting;

  /// No description provided for @equipmentRateAndDeposit.
  ///
  /// In en, this message translates to:
  /// **'{kind} · {hourlyRate}/hr · Deposit {deposit}'**
  String equipmentRateAndDeposit(
    String kind,
    String hourlyRate,
    String deposit,
  );

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @availableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} available'**
  String availableCount(int count);

  /// No description provided for @percentOfStockRented.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of stock currently rented'**
  String percentOfStockRented(int percent);

  /// No description provided for @noActiveRentals.
  ///
  /// In en, this message translates to:
  /// **'No active rentals'**
  String get noActiveRentals;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @startNewRentalFromButtonBelow.
  ///
  /// In en, this message translates to:
  /// **'Start a new rental from the button below.'**
  String get startNewRentalFromButtonBelow;

  /// No description provided for @returnedRentalsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Returned rentals will appear here.'**
  String get returnedRentalsWillAppearHere;

  /// No description provided for @equipmentWithQty.
  ///
  /// In en, this message translates to:
  /// **'{name} · ×{qty}'**
  String equipmentWithQty(String name, int qty);

  /// No description provided for @overdueBy.
  ///
  /// In en, this message translates to:
  /// **'Overdue by'**
  String get overdueBy;

  /// No description provided for @returnsIn.
  ///
  /// In en, this message translates to:
  /// **'Returns in'**
  String get returnsIn;

  /// No description provided for @returnedAt.
  ///
  /// In en, this message translates to:
  /// **'Returned · {time}'**
  String returnedAt(String time);

  /// No description provided for @itemType.
  ///
  /// In en, this message translates to:
  /// **'Item type'**
  String get itemType;

  /// No description provided for @pickAType.
  ///
  /// In en, this message translates to:
  /// **'Pick a type'**
  String get pickAType;

  /// No description provided for @pickAnItem.
  ///
  /// In en, this message translates to:
  /// **'Pick an item'**
  String get pickAnItem;

  /// No description provided for @nameWithHourlyRate.
  ///
  /// In en, this message translates to:
  /// **'{name} · {hourlyRate}/hr'**
  String nameWithHourlyRate(String name, String hourlyRate);

  /// No description provided for @depositPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Deposit {deposit} / unit'**
  String depositPerUnit(String deposit);

  /// No description provided for @quantityAndDuration.
  ///
  /// In en, this message translates to:
  /// **'Quantity & duration'**
  String get quantityAndDuration;

  /// No description provided for @onlyUnitsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Only {count} unit available.} other{Only {count} units available.}}'**
  String onlyUnitsAvailable(int count);

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @rateBreakdown.
  ///
  /// In en, this message translates to:
  /// **'{rate} × {qty} × {hours}h'**
  String rateBreakdown(String rate, int qty, int hours);

  /// No description provided for @receiptImageDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'Receipt image does not exist.'**
  String get receiptImageDoesNotExist;

  /// No description provided for @receiptImageResolutionTooLow.
  ///
  /// In en, this message translates to:
  /// **'Receipt image resolution is too low'**
  String get receiptImageResolutionTooLow;

  /// No description provided for @receiptImageFileTooSmall.
  ///
  /// In en, this message translates to:
  /// **'Receipt image file is too small'**
  String get receiptImageFileTooSmall;

  /// No description provided for @receiptImageAppearsBlank.
  ///
  /// In en, this message translates to:
  /// **'Receipt image appears blank'**
  String get receiptImageAppearsBlank;

  /// No description provided for @receiptImageAppearsBlurry.
  ///
  /// In en, this message translates to:
  /// **'Receipt image appears blurry or unreadable'**
  String get receiptImageAppearsBlurry;

  /// No description provided for @receiptImageQualityNotAcceptable.
  ///
  /// In en, this message translates to:
  /// **'Receipt image quality is not acceptable'**
  String get receiptImageQualityNotAcceptable;

  /// No description provided for @receiptTextNotReadable.
  ///
  /// In en, this message translates to:
  /// **'Receipt text is not readable'**
  String get receiptTextNotReadable;

  /// No description provided for @merchantNameDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Merchant name does not match'**
  String get merchantNameDoesNotMatch;

  /// No description provided for @expectedAmountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Expected amount {amount} not found'**
  String expectedAmountNotFound(String amount);

  /// No description provided for @paymentNotMarkedSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment is not marked successful'**
  String get paymentNotMarkedSuccessful;

  /// No description provided for @successfulPaymentStatusNotFound.
  ///
  /// In en, this message translates to:
  /// **'Successful payment status not found'**
  String get successfulPaymentStatusNotFound;

  /// No description provided for @transactionReferenceIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Transaction/reference ID not found'**
  String get transactionReferenceIdNotFound;

  /// No description provided for @transactionDateNotFound.
  ///
  /// In en, this message translates to:
  /// **'Transaction date not found'**
  String get transactionDateNotFound;

  /// No description provided for @qrCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'QR code not found'**
  String get qrCodeNotFound;

  /// No description provided for @transactionIdAlreadySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID has already been submitted'**
  String get transactionIdAlreadySubmitted;

  /// No description provided for @receiptValidationScoreBelow.
  ///
  /// In en, this message translates to:
  /// **'Receipt validation score is below {score}%'**
  String receiptValidationScoreBelow(int score);

  /// No description provided for @proofAcceptedPendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Proof accepted. Pending manual payment verification.'**
  String get proofAcceptedPendingVerification;

  /// No description provided for @unableToProcessPaymentReceipt.
  ///
  /// In en, this message translates to:
  /// **'Unable to process payment receipt: {error}'**
  String unableToProcessPaymentReceipt(String error);

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @fullNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Full name cannot exceed 80 characters'**
  String get fullNameTooLong;

  /// No description provided for @fullNameLettersOnly.
  ///
  /// In en, this message translates to:
  /// **'Full name can contain letters and spaces only'**
  String get fullNameLettersOnly;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailTooLong.
  ///
  /// In en, this message translates to:
  /// **'Email address is too long'**
  String get emailTooLong;

  /// No description provided for @enterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmailAddress;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @enterValidNepalMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Nepal mobile number'**
  String get enterValidNepalMobile;

  /// No description provided for @useNepalMobileFormat.
  ///
  /// In en, this message translates to:
  /// **'Use a 97/98 mobile number with optional +977 prefix'**
  String get useNepalMobileFormat;

  /// No description provided for @chooseVenueAgainToViewSlots.
  ///
  /// In en, this message translates to:
  /// **'Please choose a venue again to view available slots.'**
  String get chooseVenueAgainToViewSlots;

  /// No description provided for @bookingNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This booking is no longer available.'**
  String get bookingNoLongerAvailable;

  /// No description provided for @pickYourSlotAgainToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please pick your slot again to continue.'**
  String get pickYourSlotAgainToContinue;

  /// No description provided for @biometricSignInReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to sign in to Hamro Futsal'**
  String get biometricSignInReason;

  /// No description provided for @fileIsEmptyAttachAgain.
  ///
  /// In en, this message translates to:
  /// **'That file is empty. Please attach it again.'**
  String get fileIsEmptyAttachAgain;

  /// No description provided for @fileCameThroughEmpty.
  ///
  /// In en, this message translates to:
  /// **'That file came through empty. Please attach it again.'**
  String get fileCameThroughEmpty;

  /// No description provided for @fileCouldNotBeRead.
  ///
  /// In en, this message translates to:
  /// **'That file could not be read. Please attach it again.'**
  String get fileCouldNotBeRead;

  /// No description provided for @fileNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'That file is no longer available. Please attach it again.'**
  String get fileNoLongerAvailable;

  /// No description provided for @unsupportedFileTypeAttachSupported.
  ///
  /// In en, this message translates to:
  /// **'The selected file type is not supported. Please attach a supported file.'**
  String get unsupportedFileTypeAttachSupported;

  /// No description provided for @theSelectedFile.
  ///
  /// In en, this message translates to:
  /// **'The selected file'**
  String get theSelectedFile;

  /// No description provided for @uploadAtMostFiles.
  ///
  /// In en, this message translates to:
  /// **'You can upload at most {count} files at once.'**
  String uploadAtMostFiles(int count);

  /// No description provided for @namedFileIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'{name} is empty. Please attach it again.'**
  String namedFileIsEmpty(String name);

  /// No description provided for @namedFileMustBeOrSmaller.
  ///
  /// In en, this message translates to:
  /// **'{name} must be {size} or smaller.'**
  String namedFileMustBeOrSmaller(String name, String size);

  /// No description provided for @uploadExceedsRequestLimit.
  ///
  /// In en, this message translates to:
  /// **'The upload exceeds the {size} request limit.'**
  String uploadExceedsRequestLimit(String size);

  /// No description provided for @selectedFilesExceedRequestLimit.
  ///
  /// In en, this message translates to:
  /// **'The selected files exceed the {size} request limit.'**
  String selectedFilesExceedRequestLimit(String size);

  /// No description provided for @onlyFileTypesCanBeUploaded.
  ///
  /// In en, this message translates to:
  /// **'Only {types} files can be uploaded.'**
  String onlyFileTypesCanBeUploaded(String types);

  /// No description provided for @fileMustBeOrSmaller.
  ///
  /// In en, this message translates to:
  /// **'The file must be {size} or smaller.'**
  String fileMustBeOrSmaller(String size);

  /// No description provided for @imageCouldNotBeReducedBelow.
  ///
  /// In en, this message translates to:
  /// **'The image could not be reduced below {size}. Please choose a smaller image.'**
  String imageCouldNotBeReducedBelow(String size);

  /// No description provided for @imageStillLargerThan.
  ///
  /// In en, this message translates to:
  /// **'The image is still larger than {size}. Please choose a smaller image.'**
  String imageStillLargerThan(String size);

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @englishAdCalendar.
  ///
  /// In en, this message translates to:
  /// **'English (AD)'**
  String get englishAdCalendar;

  /// No description provided for @nepaliBsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Nepali (BS)'**
  String get nepaliBsCalendar;

  /// No description provided for @adShort.
  ///
  /// In en, this message translates to:
  /// **'AD'**
  String get adShort;

  /// No description provided for @bsShort.
  ///
  /// In en, this message translates to:
  /// **'BS'**
  String get bsShort;

  /// No description provided for @englishLetters.
  ///
  /// In en, this message translates to:
  /// **'English letters'**
  String get englishLetters;

  /// No description provided for @nepaliScript.
  ///
  /// In en, this message translates to:
  /// **'नेपाली'**
  String get nepaliScript;

  /// No description provided for @serverMalformedData.
  ///
  /// In en, this message translates to:
  /// **'The server responded with malformed data, please retry again.'**
  String get serverMalformedData;

  /// No description provided for @serverErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'The server encountered an error and could not complete your request, please retry again.'**
  String get serverErrorRetry;

  /// No description provided for @noInternetConnectionCheckSettings.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection, please check your network settings and try again.'**
  String get noInternetConnectionCheckSettings;

  /// No description provided for @networkUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Network unreachable, please check your network settings and try again.'**
  String get networkUnreachable;

  /// No description provided for @noContentFound.
  ///
  /// In en, this message translates to:
  /// **'No content found.'**
  String get noContentFound;

  /// No description provided for @fileTooLargeForServer.
  ///
  /// In en, this message translates to:
  /// **'The selected file is too large for the server. Choose a smaller file and try again.'**
  String get fileTooLargeForServer;

  /// No description provided for @serverCouldNotReadAttachment.
  ///
  /// In en, this message translates to:
  /// **'The server could not read the attachment. Reattach a smaller file and try again.'**
  String get serverCouldNotReadAttachment;

  /// No description provided for @sessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get sessionEnded;

  /// No description provided for @sessionExpiredLogInAgain.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get sessionExpiredLogInAgain;

  /// No description provided for @uploadSendTimedOut.
  ///
  /// In en, this message translates to:
  /// **'The upload timed out while sending the attachment. Check your connection and try again.'**
  String get uploadSendTimedOut;

  /// No description provided for @uploadProcessingTimedOut.
  ///
  /// In en, this message translates to:
  /// **'The upload timed out while the server was processing it. Check whether your change was saved before trying again.'**
  String get uploadProcessingTimedOut;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get unexpectedError;

  /// No description provided for @highImportanceNotificationsChannel.
  ///
  /// In en, this message translates to:
  /// **'High Importance Notifications'**
  String get highImportanceNotificationsChannel;

  /// No description provided for @highImportanceNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Important updates from Hamro Futsal.'**
  String get highImportanceNotificationsDescription;

  /// No description provided for @youHaveNewNotification.
  ///
  /// In en, this message translates to:
  /// **'You have a new notification.'**
  String get youHaveNewNotification;

  /// No description provided for @mapPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Map preview unavailable'**
  String get mapPreviewUnavailable;

  /// No description provided for @couldNotLoadThisPage.
  ///
  /// In en, this message translates to:
  /// **'Could not load this page.'**
  String get couldNotLoadThisPage;

  /// No description provided for @typePrefix.
  ///
  /// In en, this message translates to:
  /// **'Type '**
  String get typePrefix;

  /// No description provided for @belowToConfirm.
  ///
  /// In en, this message translates to:
  /// **' below to confirm.'**
  String get belowToConfirm;

  /// No description provided for @belowToContinue.
  ///
  /// In en, this message translates to:
  /// **' below to continue.'**
  String get belowToContinue;

  /// No description provided for @selectBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Select Background Color'**
  String get selectBackgroundColor;

  /// No description provided for @selectTextColor.
  ///
  /// In en, this message translates to:
  /// **'Select Text Color'**
  String get selectTextColor;

  /// No description provided for @pageOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{page} of {total}'**
  String pageOfTotal(int page, int total);

  /// No description provided for @selectVenueFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a venue first.'**
  String get selectVenueFirst;

  /// No description provided for @deleteProductQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete product?'**
  String get deleteProductQuestion;

  /// No description provided for @removeProductConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will remove {name} from your products.'**
  String removeProductConfirmation(String name);

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String productsCount(String count);

  /// No description provided for @manageProductsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage product name, price and active status per venue.'**
  String get manageProductsSubtitle;

  /// No description provided for @selectVenue.
  ///
  /// In en, this message translates to:
  /// **'Select venue'**
  String get selectVenue;

  /// No description provided for @productList.
  ///
  /// In en, this message translates to:
  /// **'Product list'**
  String get productList;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProduct;

  /// No description provided for @updateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update product'**
  String get updateProduct;

  /// No description provided for @createProduct.
  ///
  /// In en, this message translates to:
  /// **'Create product'**
  String get createProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @productNameHint.
  ///
  /// In en, this message translates to:
  /// **'Water bottle'**
  String get productNameHint;

  /// No description provided for @enterProductName.
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get enterProductName;

  /// No description provided for @enterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter valid price'**
  String get enterValidPrice;

  /// No description provided for @activeProduct.
  ///
  /// In en, this message translates to:
  /// **'Active product'**
  String get activeProduct;

  /// No description provided for @visibleForSale.
  ///
  /// In en, this message translates to:
  /// **'Visible for sale'**
  String get visibleForSale;

  /// No description provided for @hiddenFromSale.
  ///
  /// In en, this message translates to:
  /// **'Hidden from sale'**
  String get hiddenFromSale;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// No description provided for @tapCreateToAddFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Tap Create to add your first product.'**
  String get tapCreateToAddFirstProduct;

  /// No description provided for @selectVenueToManageProducts.
  ///
  /// In en, this message translates to:
  /// **'Select a venue to manage its products'**
  String get selectVenueToManageProducts;

  /// No description provided for @itemsYouSellAt.
  ///
  /// In en, this message translates to:
  /// **'Items you sell at {venueName}'**
  String itemsYouSellAt(String venueName);

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get newProduct;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total products'**
  String get totalProducts;

  /// No description provided for @averagePrice.
  ///
  /// In en, this message translates to:
  /// **'Average price'**
  String get averagePrice;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchProducts;

  /// No description provided for @noProductsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No products match your search.'**
  String get noProductsMatchSearch;

  /// No description provided for @actionsUpper.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get actionsUpper;

  /// No description provided for @noVenuesFoundForProducts.
  ///
  /// In en, this message translates to:
  /// **'No venues found for products.'**
  String get noVenuesFoundForProducts;

  /// No description provided for @productCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product created successfully.'**
  String get productCreatedSuccessfully;

  /// No description provided for @productUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully.'**
  String get productUpdatedSuccessfully;

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully.'**
  String get productDeletedSuccessfully;

  /// No description provided for @couldNotReadVenuesFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not read venues from the server.'**
  String get couldNotReadVenuesFromServer;

  /// No description provided for @couldNotReadProductsFromServer.
  ///
  /// In en, this message translates to:
  /// **'Could not read products from the server.'**
  String get couldNotReadProductsFromServer;

  /// No description provided for @venueVendor.
  ///
  /// In en, this message translates to:
  /// **'Venue Vendor'**
  String get venueVendor;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'your email'**
  String get yourEmail;

  /// No description provided for @otpResentSuccessfullyCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully. Check your email.'**
  String get otpResentSuccessfullyCheckEmail;

  /// No description provided for @otpVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP verified successfully.'**
  String get otpVerifiedSuccessfully;

  /// No description provided for @otpVerifiedSuccessfullyShort.
  ///
  /// In en, this message translates to:
  /// **'OTP verified successfully'**
  String get otpVerifiedSuccessfullyShort;

  /// No description provided for @otpVerifiedPleaseSignIn.
  ///
  /// In en, this message translates to:
  /// **'OTP verified successfully. Please sign in to continue.'**
  String get otpVerifiedPleaseSignIn;

  /// No description provided for @enterOtpCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the {otpLength}-digit code sent to {email}'**
  String enterOtpCodeSentTo(int otpLength, String email);

  /// No description provided for @enterOtpCodeAndChooseNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the {otpLength}-digit code sent to {email} and choose a new password'**
  String enterOtpCodeAndChooseNewPassword(int otpLength, String email);

  /// No description provided for @chooseNewPasswordFor.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for {email}'**
  String chooseNewPasswordFor(String email);

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendCodeIn(int seconds);

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @noBiometricAccountSaved.
  ///
  /// In en, this message translates to:
  /// **'No biometric account is saved. Sign in with your password first.'**
  String get noBiometricAccountSaved;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// No description provided for @pleaseConfirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmYourPassword;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get createYourAccount;

  /// No description provided for @signInToBookMatchesOrManageVenue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to book matches or manage your venue.'**
  String get signInToBookMatchesOrManageVenue;

  /// No description provided for @joinAsPlayerOrVenueVendor.
  ///
  /// In en, this message translates to:
  /// **'Join as a player or a venue vendor.'**
  String get joinAsPlayerOrVenueVendor;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInTitle;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @newToHamroFutsal.
  ///
  /// In en, this message translates to:
  /// **'New to Hamro Futsal?'**
  String get newToHamroFutsal;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @signInWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Sign in with biometrics'**
  String get signInWithBiometrics;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @googleSignInNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not configured for this app version. Please contact support. (Google 10)'**
  String get googleSignInNotConfigured;

  /// No description provided for @googleErrorCode.
  ///
  /// In en, this message translates to:
  /// **'(Google {code})'**
  String googleErrorCode(String code);

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registrationSuccessful;

  /// No description provided for @pleaseSelectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Please select an account type'**
  String get pleaseSelectAccountType;

  /// No description provided for @youMustAcceptTermsToContinue.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms to continue'**
  String get youMustAcceptTermsToContinue;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeToThe;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @andConnector.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andConnector;

  /// No description provided for @stepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {step}'**
  String stepLabel(int step);

  /// No description provided for @percentOff.
  ///
  /// In en, this message translates to:
  /// **'{percent}% off'**
  String percentOff(String percent);

  /// No description provided for @amountOff.
  ///
  /// In en, this message translates to:
  /// **'{amount} off'**
  String amountOff(String amount);

  /// No description provided for @rsAmountOff.
  ///
  /// In en, this message translates to:
  /// **'Rs {amount} off'**
  String rsAmountOff(String amount);

  /// No description provided for @pointsEarnedTitle.
  ///
  /// In en, this message translates to:
  /// **'Points earned'**
  String get pointsEarnedTitle;

  /// No description provided for @pointsRedeemedTitle.
  ///
  /// In en, this message translates to:
  /// **'Points redeemed'**
  String get pointsRedeemedTitle;

  /// No description provided for @pointsExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Points expired'**
  String get pointsExpiredTitle;

  /// No description provided for @pointsAdjustedTitle.
  ///
  /// In en, this message translates to:
  /// **'Points adjusted'**
  String get pointsAdjustedTitle;

  /// No description provided for @thatsAllYourRewardActivity.
  ///
  /// In en, this message translates to:
  /// **'That’s all your reward activity'**
  String get thatsAllYourRewardActivity;

  /// No description provided for @pointsUsed.
  ///
  /// In en, this message translates to:
  /// **'Points used'**
  String get pointsUsed;

  /// No description provided for @pointsLeft.
  ///
  /// In en, this message translates to:
  /// **'Points left'**
  String get pointsLeft;

  /// No description provided for @validTill.
  ///
  /// In en, this message translates to:
  /// **'Valid till'**
  String get validTill;

  /// No description provided for @worthAmount.
  ///
  /// In en, this message translates to:
  /// **' worth {amount}'**
  String worthAmount(String amount);

  /// No description provided for @youCanRedeemPointsForCoupon.
  ///
  /// In en, this message translates to:
  /// **'You can redeem {points} points for a coupon{worth}.'**
  String youCanRedeemPointsForCoupon(String points, String worth);

  /// No description provided for @morePointsForNextCoupon.
  ///
  /// In en, this message translates to:
  /// **'{points} more points for your next coupon.'**
  String morePointsForNextCoupon(String points);

  /// No description provided for @couponUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Coupon unlocked'**
  String get couponUnlocked;

  /// No description provided for @nextCoupon.
  ///
  /// In en, this message translates to:
  /// **'Next coupon'**
  String get nextCoupon;

  /// No description provided for @pointsProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target} pts'**
  String pointsProgress(String current, String target);

  /// No description provided for @couponsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Coupons available'**
  String get couponsAvailable;

  /// No description provided for @couponWithCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon {code}'**
  String couponWithCode(String code);

  /// No description provided for @refWithValue.
  ///
  /// In en, this message translates to:
  /// **'Ref {reference}'**
  String refWithValue(String reference);

  /// No description provided for @balanceWithPoints.
  ///
  /// In en, this message translates to:
  /// **'Bal {points}'**
  String balanceWithPoints(String points);

  /// No description provided for @pointsEqualsCoupon.
  ///
  /// In en, this message translates to:
  /// **'{points} points = {amount} coupon.'**
  String pointsEqualsCoupon(String points, String amount);

  /// No description provided for @pointsEqualsDiscountCoupon.
  ///
  /// In en, this message translates to:
  /// **'{points} points = 1 discount coupon.'**
  String pointsEqualsDiscountCoupon(String points);

  /// No description provided for @applyCouponAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'Apply the generated coupon code at checkout to use your discount.'**
  String get applyCouponAtCheckout;

  /// No description provided for @enterACouponCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a coupon code.'**
  String get enterACouponCode;

  /// No description provided for @emptyAppStoreLookupResponse.
  ///
  /// In en, this message translates to:
  /// **'Empty App Store lookup response'**
  String get emptyAppStoreLookupResponse;

  /// No description provided for @appStoreLookupFailed.
  ///
  /// In en, this message translates to:
  /// **'App Store lookup failed'**
  String get appStoreLookupFailed;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @couldNotChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Could not change the password.'**
  String get couldNotChangePassword;

  /// No description provided for @morningTimeRange.
  ///
  /// In en, this message translates to:
  /// **'06:00 AM - 12:00 PM'**
  String get morningTimeRange;

  /// No description provided for @afternoonTimeRange.
  ///
  /// In en, this message translates to:
  /// **'12:00 PM - 06:00 PM'**
  String get afternoonTimeRange;

  /// No description provided for @eveningTimeRange.
  ///
  /// In en, this message translates to:
  /// **'06:00 PM - 12:00 AM'**
  String get eveningTimeRange;

  /// No description provided for @setYourHourlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Set your hourly budget'**
  String get setYourHourlyBudget;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// No description provided for @courtPreferences.
  ///
  /// In en, this message translates to:
  /// **'Court preferences'**
  String get courtPreferences;

  /// No description provided for @chooseCourtAndMatchYouPrefer.
  ///
  /// In en, this message translates to:
  /// **'Choose the court and match you prefer'**
  String get chooseCourtAndMatchYouPrefer;

  /// No description provided for @onlyShowCourtsWithPreferredRating.
  ///
  /// In en, this message translates to:
  /// **'Only show courts with your preferred rating'**
  String get onlyShowCourtsWithPreferredRating;

  /// No description provided for @anyRating.
  ///
  /// In en, this message translates to:
  /// **'Any rating'**
  String get anyRating;

  /// No description provided for @ratingAndUp.
  ///
  /// In en, this message translates to:
  /// **'{rating} & up'**
  String ratingAndUp(String rating);

  /// No description provided for @tapStarToSetMinimumRating.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to set the minimum venue rating.'**
  String get tapStarToSetMinimumRating;

  /// No description provided for @selectConvenientPlayTimes.
  ///
  /// In en, this message translates to:
  /// **'Select one or more convenient play times'**
  String get selectConvenientPlayTimes;

  /// No description provided for @yourPreferencesAreReady.
  ///
  /// In en, this message translates to:
  /// **'Your preferences are ready'**
  String get yourPreferencesAreReady;

  /// No description provided for @refineYourSearch.
  ///
  /// In en, this message translates to:
  /// **'Refine your search'**
  String get refineYourSearch;

  /// No description provided for @adjustSelectionsToSeeMatchingCourts.
  ///
  /// In en, this message translates to:
  /// **'Adjust selections or apply them to see matching courts.'**
  String get adjustSelectionsToSeeMatchingCourts;

  /// No description provided for @chooseBudgetCourtTypeRatingOrPlayTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a budget, court type, rating, or play time.'**
  String get chooseBudgetCourtTypeRatingOrPlayTime;

  /// No description provided for @countSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String countSelected(String count);

  /// No description provided for @couldNotLoadOptions.
  ///
  /// In en, this message translates to:
  /// **'Could not load options.'**
  String get couldNotLoadOptions;

  /// No description provided for @showingAllCourts.
  ///
  /// In en, this message translates to:
  /// **'Showing all courts'**
  String get showingAllCourts;

  /// No description provided for @filtersSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} filter selected} other{{count} filters selected}}'**
  String filtersSelected(int count);

  /// No description provided for @showCourts.
  ///
  /// In en, this message translates to:
  /// **'Show courts'**
  String get showCourts;

  /// No description provided for @couldNotLoadFaqs.
  ///
  /// In en, this message translates to:
  /// **'Could not load FAQs.'**
  String get couldNotLoadFaqs;

  /// No description provided for @noFaqsYet.
  ///
  /// In en, this message translates to:
  /// **'No FAQs yet'**
  String get noFaqsYet;

  /// No description provided for @faqsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions will appear here.'**
  String get faqsWillAppearHere;

  /// No description provided for @couldNotLoadHelpTopics.
  ///
  /// In en, this message translates to:
  /// **'Could not load help topics.'**
  String get couldNotLoadHelpTopics;

  /// No description provided for @noHelpTopicsYet.
  ///
  /// In en, this message translates to:
  /// **'No help topics yet'**
  String get noHelpTopicsYet;

  /// No description provided for @helpGuidesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Help and how-to guides will appear here.'**
  String get helpGuidesWillAppearHere;

  /// No description provided for @connectWithUs.
  ///
  /// In en, this message translates to:
  /// **'Connect with us'**
  String get connectWithUs;

  /// No description provided for @reachOutOnSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Reach out on social media — we usually reply within a few hours.'**
  String get reachOutOnSocialMedia;

  /// No description provided for @helpGuides.
  ///
  /// In en, this message translates to:
  /// **'Help guides'**
  String get helpGuides;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenter;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answers, guides and videos for using Hamro Futsal.'**
  String get helpCenterSubtitle;

  /// No description provided for @searchFaqsAndGuides.
  ///
  /// In en, this message translates to:
  /// **'Search FAQs and guides'**
  String get searchFaqsAndGuides;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @tryDifferentWordOrBrowse.
  ///
  /// In en, this message translates to:
  /// **'Try a different word, or browse the other sections.'**
  String get tryDifferentWordOrBrowse;

  /// No description provided for @bookingIncome.
  ///
  /// In en, this message translates to:
  /// **'Booking income'**
  String get bookingIncome;

  /// No description provided for @opponentMatchIncome.
  ///
  /// In en, this message translates to:
  /// **'Opponent match income'**
  String get opponentMatchIncome;

  /// No description provided for @platformCommission.
  ///
  /// In en, this message translates to:
  /// **'Platform commission'**
  String get platformCommission;

  /// No description provided for @settlementPayout.
  ///
  /// In en, this message translates to:
  /// **'Settlement payout'**
  String get settlementPayout;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @adjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get adjustment;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @enterAValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get enterAValidAmount;

  /// No description provided for @amountCantExceed.
  ///
  /// In en, this message translates to:
  /// **'Amount can\'t exceed {amount}.'**
  String amountCantExceed(String amount);

  /// No description provided for @settleTheFull.
  ///
  /// In en, this message translates to:
  /// **'Settle the full {amount}.'**
  String settleTheFull(String amount);

  /// No description provided for @uploadReceiptBeforeSubmittingMax.
  ///
  /// In en, this message translates to:
  /// **'Upload the payment receipt before submitting (max {maxSizeMb} MB).'**
  String uploadReceiptBeforeSubmittingMax(int maxSizeMb);

  /// No description provided for @allFutsals.
  ///
  /// In en, this message translates to:
  /// **'All futsals'**
  String get allFutsals;

  /// No description provided for @proofTypesMaxSize.
  ///
  /// In en, this message translates to:
  /// **'{types} · Max {maxSizeMb} MB'**
  String proofTypesMaxSize(String types, int maxSizeMb);

  /// No description provided for @scanAndPay.
  ///
  /// In en, this message translates to:
  /// **'Scan and pay'**
  String get scanAndPay;

  /// No description provided for @sendCommissionUsingQr.
  ///
  /// In en, this message translates to:
  /// **'Send the commission to Hamro Futsal using this QR.'**
  String get sendCommissionUsingQr;

  /// No description provided for @commissionToPay.
  ///
  /// In en, this message translates to:
  /// **'Commission to pay'**
  String get commissionToPay;

  /// No description provided for @confirmThePayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm the payment'**
  String get confirmThePayment;

  /// No description provided for @enterWhatYouSentAndAttachReceipt.
  ///
  /// In en, this message translates to:
  /// **'Enter what you sent and attach the receipt as proof.'**
  String get enterWhatYouSentAndAttachReceipt;

  /// No description provided for @commissionAmountNpr.
  ///
  /// In en, this message translates to:
  /// **'Commission amount (NPR)'**
  String get commissionAmountNpr;

  /// No description provided for @fullCommissionInOneRequest.
  ///
  /// In en, this message translates to:
  /// **'The full commission must be paid in one request.'**
  String get fullCommissionInOneRequest;

  /// No description provided for @transactionReference.
  ///
  /// In en, this message translates to:
  /// **'Transaction reference'**
  String get transactionReference;

  /// No description provided for @transactionReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Bank / eSewa / Khalti transaction ID'**
  String get transactionReferenceHint;

  /// No description provided for @enterPaymentTransactionReference.
  ///
  /// In en, this message translates to:
  /// **'Enter the payment transaction reference.'**
  String get enterPaymentTransactionReference;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @paymentRemark.
  ///
  /// In en, this message translates to:
  /// **'Payment remark'**
  String get paymentRemark;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get submitting;

  /// No description provided for @submitCommissionPayment.
  ///
  /// In en, this message translates to:
  /// **'Submit Commission Payment'**
  String get submitCommissionPayment;

  /// No description provided for @fileSizeBytes.
  ///
  /// In en, this message translates to:
  /// **'{bytes} B'**
  String fileSizeBytes(int bytes);

  /// No description provided for @uploadPaymentProof.
  ///
  /// In en, this message translates to:
  /// **'Upload payment proof'**
  String get uploadPaymentProof;

  /// No description provided for @uploadReceiptBeforeSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Upload the payment receipt before submitting.'**
  String get uploadReceiptBeforeSubmitting;

  /// No description provided for @noAccountActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No account activity yet'**
  String get noAccountActivityYet;

  /// No description provided for @accountActivityWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Booking income, platform commission and payouts will appear here.'**
  String get accountActivityWillAppearHere;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @commissionPaymentNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Commission payment is not available right now.'**
  String get commissionPaymentNotAvailable;

  /// No description provided for @futsalBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Futsal breakdown'**
  String get futsalBreakdown;

  /// No description provided for @futsalBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Futsal Breakdown'**
  String get futsalBreakdownTitle;

  /// No description provided for @futsalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} futsal} other{{count} futsals}}'**
  String futsalCount(int count);

  /// No description provided for @noSettlementsYet.
  ///
  /// In en, this message translates to:
  /// **'No settlements yet'**
  String get noSettlementsYet;

  /// No description provided for @settlementsInProgress.
  ///
  /// In en, this message translates to:
  /// **'{inProgress} in progress · {total} total'**
  String settlementsInProgress(int inProgress, int total);

  /// No description provided for @settlementsTotal.
  ///
  /// In en, this message translates to:
  /// **'{total} total'**
  String settlementsTotal(int total);

  /// No description provided for @noFutsalsYet.
  ///
  /// In en, this message translates to:
  /// **'No futsals yet'**
  String get noFutsalsYet;

  /// No description provided for @futsalBalancesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Balances for each of your futsals will appear here.'**
  String get futsalBalancesWillAppearHere;

  /// No description provided for @noCommissionDueForFutsal.
  ///
  /// In en, this message translates to:
  /// **'No commission due for this futsal yet.'**
  String get noCommissionDueForFutsal;

  /// No description provided for @settlementNotAvailableForFutsal.
  ///
  /// In en, this message translates to:
  /// **'Settlement is not available for this futsal yet.'**
  String get settlementNotAvailableForFutsal;

  /// No description provided for @couldNotLoadFutsalBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Could not load the futsal breakdown.'**
  String get couldNotLoadFutsalBreakdown;

  /// No description provided for @requestSettlementEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Request a settlement and Hamro Futsal will pay your balance out to you.'**
  String get requestSettlementEmptyMessage;

  /// No description provided for @scanAnyQrToPay.
  ///
  /// In en, this message translates to:
  /// **'Scan any QR to pay'**
  String get scanAnyQrToPay;

  /// No description provided for @scanToPay.
  ///
  /// In en, this message translates to:
  /// **'Scan to pay'**
  String get scanToPay;

  /// No description provided for @payTo.
  ///
  /// In en, this message translates to:
  /// **'Pay to'**
  String get payTo;

  /// No description provided for @phoneNumberCopied.
  ///
  /// In en, this message translates to:
  /// **'Phone number copied.'**
  String get phoneNumberCopied;

  /// No description provided for @chooseAnExistingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose an existing photo'**
  String get chooseAnExistingPhoto;

  /// No description provided for @takeAPhotoNow.
  ///
  /// In en, this message translates to:
  /// **'Take a photo now'**
  String get takeAPhotoNow;

  /// No description provided for @browseYourDocuments.
  ///
  /// In en, this message translates to:
  /// **'Browse your documents'**
  String get browseYourDocuments;

  /// No description provided for @addAFile.
  ///
  /// In en, this message translates to:
  /// **'Add a file'**
  String get addAFile;

  /// No description provided for @cameraDidNotFinishSavingImage.
  ///
  /// In en, this message translates to:
  /// **'The camera did not finish saving the image. Please take the photo again.'**
  String get cameraDidNotFinishSavingImage;

  /// No description provided for @fileCameThroughEmptySelectAgain.
  ///
  /// In en, this message translates to:
  /// **'That file came through empty. Please select it again.'**
  String get fileCameThroughEmptySelectAgain;

  /// No description provided for @couldNotOpenThatFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open that file. Please try again.'**
  String get couldNotOpenThatFile;

  /// No description provided for @mediaLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select saved media or add new files for this section.'**
  String get mediaLibrarySubtitle;

  /// No description provided for @uploadWithoutUsableMediaReference.
  ///
  /// In en, this message translates to:
  /// **'The upload completed without a usable media reference. Please try again.'**
  String get uploadWithoutUsableMediaReference;

  /// No description provided for @uploadAtMostFiveFiles.
  ///
  /// In en, this message translates to:
  /// **'You can upload at most 5 files at once.'**
  String get uploadAtMostFiveFiles;

  /// No description provided for @selectedImageIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'The selected image is empty. Please select the original image again.'**
  String get selectedImageIsEmpty;

  /// No description provided for @couldNotSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Could not select image. Please try again.'**
  String get couldNotSelectImage;

  /// No description provided for @couldNotOpenCamera.
  ///
  /// In en, this message translates to:
  /// **'Could not open camera. Please try again.'**
  String get couldNotOpenCamera;

  /// No description provided for @filesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} files'**
  String filesCount(int count);

  /// No description provided for @uploadFileToMediaLibraryQuoted.
  ///
  /// In en, this message translates to:
  /// **'Do you want to upload \"{file}\" to media library?'**
  String uploadFileToMediaLibraryQuoted(String file);

  /// No description provided for @uploadFilesToMediaLibrary.
  ///
  /// In en, this message translates to:
  /// **'Do you want to upload {files} to media library?'**
  String uploadFilesToMediaLibrary(String files);

  /// No description provided for @remoteMediaIsReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Remote media is read-only in this library.'**
  String get remoteMediaIsReadOnly;

  /// No description provided for @removeItemFromSavedCollection.
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove \"{name}\" from your saved collection?'**
  String removeItemFromSavedCollection(String name);

  /// No description provided for @moreSelected.
  ///
  /// In en, this message translates to:
  /// **'+{count} more selected'**
  String moreSelected(int count);

  /// No description provided for @chooseFromYourPhotos.
  ///
  /// In en, this message translates to:
  /// **'Choose from your photos'**
  String get chooseFromYourPhotos;

  /// No description provided for @takeANewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a new photo'**
  String get takeANewPhoto;

  /// No description provided for @browseDocuments.
  ///
  /// In en, this message translates to:
  /// **'Browse documents'**
  String get browseDocuments;

  /// No description provided for @mediaUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Media uploaded successfully.'**
  String get mediaUploadedSuccessfully;

  /// No description provided for @hoursAgoPlural.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{{hours} hour ago} other{{hours} hours ago}}'**
  String hoursAgoPlural(int hours);

  /// No description provided for @daysAgoPlural.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{{days} day ago} other{{days} days ago}}'**
  String daysAgoPlural(int days);

  /// No description provided for @venuesYouSaveForLater.
  ///
  /// In en, this message translates to:
  /// **'Venues you save for later'**
  String get venuesYouSaveForLater;

  /// No description provided for @savedVenuesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} saved venue} other{{count} saved venues}}'**
  String savedVenuesCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
