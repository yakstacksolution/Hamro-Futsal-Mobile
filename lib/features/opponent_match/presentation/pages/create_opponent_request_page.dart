import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_date_picker.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/core/widgets/custom_time_picker_bottom_sheet.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_draft.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/slots_selection_route_args.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/domain/entities/opponent_match_entities.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/models/opponent_cost_split.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/existing_booking_sheet.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_cost_split_card.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_sheets.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_venues_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_venue/public_venue_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/venue_search_sheet.dart';

/// "Venue already booked?" — the branch that opens the venue step.
enum _VenuePlan { alreadyBooked, findAvailable }

/// How an already-booked venue is supplied: reuse one of my bookings, or type
/// the details of a court booked outside the app.
enum _BookedSource { existingBooking, manual }

/// The wizard steps, in the order of the opponent-request journey:
/// team + match details → venue → cost split → publish.
///
/// Team selection and the match details used to be separate steps. They answer
/// one question between them — who plays and what kind of match — and both are
/// short pickers, so they share a step; the venue step keeps its own because of
/// its two branches.
enum _Step { match, venue, cost, publish }

extension _StepX on _Step {
  String get title => switch (this) {
    _Step.match => 'Team & match',
    _Step.venue => 'Venue',
    _Step.cost => 'Cost split',
    _Step.publish => 'Publish',
  };

  String get shortLabel => switch (this) {
    _Step.match => 'Match',
    _Step.venue => 'Venue',
    _Step.cost => 'Cost',
    _Step.publish => 'Publish',
  };
}

/// Full-page wizard to compose and publish one opponent request.
///
/// Teams are managed on the "My Teams" tab — here you only pick one.
/// Pops with `true` after the request is dispatched.
class CreateOpponentRequestPage extends StatefulWidget {
  const CreateOpponentRequestPage({super.key});

  @override
  State<CreateOpponentRequestPage> createState() =>
      _CreateOpponentRequestPageState();
}

class _CreateOpponentRequestPageState extends State<CreateOpponentRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageCtrl = TextEditingController(
    text: StringConstants.lookingForAFriendlyCompetitiveFutsalMatch,
  );
  final _venueNameCtrl = TextEditingController();
  final _venueLocationCtrl = TextEditingController();
  final _courtFeeCtrl = TextEditingController();
  late final PublicVenueBloc _publicVenueBloc;

  _Step _step = _Step.match;

  TeamModel? _team;
  MatchFormat _format = MatchFormat.fiveASide;

  /// Selected opponent level from `/opponent-levels`; defaults to the first
  /// fetched level (see [_resolveLevel]) until the user picks one.
  OpponentLevelModel? _level;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  _VenuePlan _venuePlan = _VenuePlan.alreadyBooked;
  _BookedSource _bookedSource = _BookedSource.existingBooking;

  /// The booking picked on the already-booked path.
  BookingModel? _existingBooking;

  /// The venue picked on the find-available path, and the slot confirmed for
  /// it. [_confirmedSlot] is what "Confirm venue booking" produced.
  PublicListingVenueModel? _preferredVenue;
  BookingDraft? _confirmedSlot;

  SplitMode _split = SplitMode.even;
  SplitBasis _basis = SplitBasis.teams;
  int _myPercent = 50;
  int _loserPercent = 70;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _publicVenueBloc = PublicVenueBloc(
      GetPublicVenuesUseCase(PublicRepositoryImpl()),
      perPage: 100,
    );
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _venueNameCtrl.dispose();
    _venueLocationCtrl.dispose();
    _courtFeeCtrl.dispose();
    _publicVenueBloc.close();
    super.dispose();
  }

  // ───────────────────────────── derived state ─────────────────────────────

  /// The court fee the requester typed — manual already-booked path only.
  int? get _enteredCourtFee => int.tryParse(_courtFeeCtrl.text.trim());

  /// The real court fee behind the current venue choice, when one is known.
  /// Drives the cost-split preview; for platform bookings the server still
  /// owns the authoritative figure.
  int? get _resolvedCourtFee {
    if (_venuePlan == _VenuePlan.alreadyBooked) {
      return _bookedSource == _BookedSource.existingBooking
          ? _existingBooking?.bookingTotal.round()
          : _enteredCourtFee;
    }
    final BookingDraft? booking = _confirmedSlot;
    if (booking?.bookingTotal != null) return booking!.bookingTotal!.round();
    final double subtotal = booking?.subtotal ?? 0;
    return subtotal > 0 ? subtotal.round() : null;
  }

  OpponentCostSplit get _cost => OpponentCostSplit(
    format: _format,
    split: _split,
    basis: _basis,
    myPercent: _myPercent,
    loserPercent: _loserPercent,
    playerCount: _team?.players.length ?? 0,
    // A real booked court's fee is the actual amount; the format table is only
    // the fallback while no venue has been settled.
    overrideCourtFee: _resolvedCourtFee,
  );

  /// Match kickoff, resolved from whichever venue branch supplied it.
  DateTime get _kickoff {
    final BookingModel? booking = _existingBooking;
    if (_venuePlan == _VenuePlan.alreadyBooked &&
        _bookedSource == _BookedSource.existingBooking &&
        booking != null) {
      return _combine(booking.date, _parseApiTime(booking.startTime) ?? _time);
    }
    final BookingDraft? slot = _confirmedSlot;
    if (_venuePlan == _VenuePlan.findAvailable && slot != null) {
      return _bookingDateTime(slot);
    }
    return _combine(_date, _time);
  }

  /// Human-readable slot for the current venue choice.
  String get _slotLabel {
    final BookingModel? booking = _existingBooking;
    if (_venuePlan == _VenuePlan.alreadyBooked &&
        _bookedSource == _BookedSource.existingBooking &&
        booking != null) {
      return booking.displayTimeRange;
    }
    final BookingDraft? slot = _confirmedSlot;
    if (_venuePlan == _VenuePlan.findAvailable && slot != null) {
      final String? end = slot.endTime?.trim();
      return end == null || end.isEmpty
          ? slot.selectedTime
          : '${slot.selectedTime} – $end';
    }
    return OpponentFmt.slot(_time);
  }

  /// The venue line the request is published with; empty while unresolved.
  String get _venueLabelText {
    if (_venuePlan == _VenuePlan.alreadyBooked) {
      if (_bookedSource == _BookedSource.existingBooking) {
        final BookingModel? booking = _existingBooking;
        if (booking == null) return '';
        return <String>[
          booking.courtName,
          booking.futsalName,
          booking.futsalAddress ?? '',
        ].where((s) => s.trim().isNotEmpty).join(', ');
      }
      return <String>[
        _venueNameCtrl.text.trim(),
        _venueLocationCtrl.text.trim(),
      ].where((s) => s.isNotEmpty).join(', ');
    }
    final PublicListingVenueModel? venue = _preferredVenue;
    final BookingDraft? slot = _confirmedSlot;
    if (venue == null || slot == null) return '';
    return _venueLabel(venue, courtName: slot.courtName);
  }

  /// Whether the venue step has everything the request needs.
  bool get _venueSettled {
    if (_venuePlan == _VenuePlan.alreadyBooked) {
      if (_bookedSource == _BookedSource.existingBooking) {
        return _existingBooking != null;
      }
      return _venueNameCtrl.text.trim().isNotEmpty &&
          _venueLocationCtrl.text.trim().isNotEmpty &&
          (_enteredCourtFee ?? 0) > 0;
    }
    return _preferredVenue?.id != null && _confirmedSlot != null;
  }

  bool _stepComplete(_Step step) => switch (step) {
    _Step.match => _team != null,
    _Step.venue => _venueSettled,
    _Step.cost => true,
    _Step.publish => true,
  };

  // ───────────────────────────── step handling ─────────────────────────────

  void _goTo(_Step step) {
    setState(() {
      _submitted = false;
      _step = step;
    });
  }

  void _next() {
    if (_step == _Step.publish) {
      _publish();
      return;
    }
    setState(() => _submitted = true);
    if (_step == _Step.venue &&
        _venuePlan == _VenuePlan.alreadyBooked &&
        _bookedSource == _BookedSource.manual &&
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_stepComplete(_step)) {
      AppUtils().showSnackBar(context, MsgType.info, _stepHint(_step));
      return;
    }
    HapticFeedback.selectionClick();
    _goTo(_Step.values[_step.index + 1]);
  }

  void _back() {
    if (_step == _Step.match) {
      Navigator.of(context).pop();
      return;
    }
    _goTo(_Step.values[_step.index - 1]);
  }

  String _stepHint(_Step step) => switch (step) {
    _Step.match => 'Select the team that will play.',
    _Step.venue =>
      _venuePlan == _VenuePlan.alreadyBooked
          ? 'Select the booking that hosts this match.'
          : 'Pick a venue, then confirm a court slot.',
    _ => 'Complete this step to continue.',
  };

  // ───────────────────────────── venue pickers ─────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showCustomDatePicker(
      context,
      title: StringConstants.matchDate,
      initialDate: _date,
      minDate: DateTime.now().subtract(const Duration(days: 1)),
      maxDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await customCupertinoTimePicker(
      context,
      StringConstants.matchTime,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _selectVenuePlan(_VenuePlan plan) {
    setState(() {
      _venuePlan = plan;
      _submitted = false;
    });
    if (plan == _VenuePlan.findAvailable &&
        _publicVenueBloc.state.status == PublicVenueStatus.idle) {
      _publicVenueBloc.add(const FetchPublicVenuesEvent());
    }
  }

  /// The same create-team sheet the Teams tab uses, so a user who reaches the
  /// wizard without a team can make one here instead of backing all the way out.
  /// The new team lands in `state.teams` and the list below picks it up.
  void _openCreateTeamSheet() {
    final bloc = context.read<OpponentMatchBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.transparentColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: CreateTeamSheet(
          onCreate: (name) {
            bloc.add(CreateTeamEvent(name));
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  Future<void> _pickExistingBooking() async {
    final BookingModel? booking = await showExistingBookingSheet(context);
    if (booking == null || !mounted) return;
    setState(() {
      _existingBooking = booking;
      _date = booking.date;
      _time = _parseApiTime(booking.startTime) ?? _time;
    });
  }

  Future<void> _pickPreferredVenue() async {
    if (_publicVenueBloc.state.status == PublicVenueStatus.idle) {
      _publicVenueBloc.add(const FetchPublicVenuesEvent());
    }
    final PublicListingVenueModel? selected = await showVenueSearchSheet(
      context,
      bloc: _publicVenueBloc,
    );
    if (selected == null || !mounted) return;
    setState(() {
      _preferredVenue = selected;
      // A new venue invalidates the slot confirmed for the previous one.
      _confirmedSlot = null;
    });
  }

  /// Court → date & time → confirm, on the venue's live slot calendar. The
  /// returned draft is the confirmed venue booking for this request.
  Future<void> _confirmVenueBooking() async {
    final PublicListingVenueModel? venue = _preferredVenue;
    if (venue == null || venue.id == null) {
      AppUtils().showSnackBar(
        context,
        MsgType.info,
        'Select a bookable venue first.',
      );
      return;
    }
    HapticFeedback.mediumImpact();
    final BookingDraft? booking = await context.pushNamed<BookingDraft>(
      AppRouterParams.slotsSelection.name,
      extra: SlotsSelectionRouteArgs(
        court: _courtFromVenue(venue),
        initialDate: _date,
        initialStartTime: _apiTime(_time),
      ),
    );
    if (booking == null || !mounted) return;
    setState(() {
      _confirmedSlot = booking;
      _date = booking.selectedDate;
      _time = _parseApiTime(booking.apiTime ?? '') ?? _time;
      _submitted = false;
      _step = _Step.cost;
    });
    AppUtils().showSnackBar(
      context,
      MsgType.success,
      'Booking complete.',
      key: 'opponent_request_booking_complete',
    );
    HapticFeedback.selectionClick();
  }

  // ───────────────────────────── publish ─────────────────────────────

  void _publish() {
    setState(() => _submitted = true);
    if (!_venueSettled) {
      AppUtils().showSnackBar(context, MsgType.info, _stepHint(_Step.venue));
      _goTo(_Step.venue);
      return;
    }
    if (_team == null) {
      AppUtils().showSnackBar(context, MsgType.info, _stepHint(_Step.match));
      _goTo(_Step.match);
      return;
    }

    if (_venuePlan == _VenuePlan.alreadyBooked) {
      final BookingModel? booking = _existingBooking;
      final bool fromBooking =
          _bookedSource == _BookedSource.existingBooking && booking != null;
      _send(
        _request(
          venue: _venueLabelText,
          bookedDateTime: fromBooking ? _kickoff : null,
          bookedSlot: fromBooking ? booking.displayTimeRange : null,
          bookedTotalFee: fromBooking ? booking.bookingTotal.round() : null,
          bookedEndTime: fromBooking ? booking.endTime : null,
          bookingId: fromBooking ? booking.id : null,
          venueId: fromBooking ? booking.venueId : null,
          courtId: fromBooking ? booking.courtId : null,
        ),
      );
      return;
    }

    final BookingDraft booking = _confirmedSlot!;
    _send(
      _request(
        venue: _venueLabelText,
        bookedDateTime: _bookingDateTime(booking),
        bookedSlot: _slotLabel,
        bookedTotalFee:
            booking.bookingTotal?.round() ??
            (booking.subtotal > 0 ? booking.subtotal.round() : null),
        bookedEndTime: booking.apiEndTime,
        bookingId: booking.bookingId,
        venueId: booking.venueId,
        courtId: booking.courtId,
      ),
    );
  }

  CreateOpponentRequestEntity _request({
    required String venue,
    DateTime? bookedDateTime,
    String? bookedSlot,
    int? bookedTotalFee,
    String? bookedEndTime,
    int? bookingId,
    int? venueId,
    int? courtId,
  }) {
    final TeamModel team = _team!;
    final state = context.read<OpponentMatchBloc>().state;
    final level = _resolveLevel(_levelOptions(state));
    final cost = _cost;
    final int totalFee = bookedTotalFee ?? cost.courtFee;
    final int yourShare = cost.isResultBased
        ? (totalFee * _loserPercent / 100).round()
        : (totalFee * (cost.myPct ?? 0) / 100).round();
    final dateTime = bookedDateTime ?? _combine(_date, _time);
    return CreateOpponentRequestEntity(
      team: team.name,
      dateTime: dateTime,
      summary:
          '${level.name} · ${_format.label} · '
          '${team.players.length} players · '
          '${_shareSummary(totalFee, yourShare, cost)}',
      venue: venue,
      slot: bookedSlot ?? OpponentFmt.slot(_time),
      totalFee: totalFee,
      yourShare: yourShare,
      myPct: cost.myPct,
      message: _messageCtrl.text.trim(),
      teamId: team.id,
      formatLabel: _format.label,
      levelSlug: level.slug.isNotEmpty ? level.slug : level.name.toLowerCase(),
      splitMode: _split == SplitMode.even
          ? 'even'
          : (cost.isResultBased ? 'custom_result' : 'custom_team'),
      loserPct: cost.isResultBased ? _loserPercent : null,
      endTime: bookedEndTime,
      // Only an externally-booked court reports its own fee; for platform
      // venues the server prices the booking itself.
      claimedTotalFee:
          _venuePlan == _VenuePlan.alreadyBooked &&
              _bookedSource == _BookedSource.manual
          ? _enteredCourtFee
          : null,
      bookingId: bookingId,
      venueId: venueId,
      courtId: courtId,
    );
  }

  String _shareSummary(int totalFee, int yourShare, OpponentCostSplit cost) {
    if (cost.isResultBased) {
      final int winnerShare = totalFee - yourShare;
      return 'Loser ${OpponentFmt.npr(yourShare)} ($_loserPercent%) · '
          'Winner ${OpponentFmt.npr(winnerShare)}';
    }
    final int percent = cost.myPct ?? 0;
    return 'Your share ${OpponentFmt.npr(yourShare)} of '
        '${OpponentFmt.npr(totalFee)} ($percent%)';
  }

  void _send(CreateOpponentRequestEntity request) {
    HapticFeedback.mediumImpact();
    context.read<OpponentMatchBloc>().add(SendOpponentRequestEvent(request));
    Navigator.of(context).pop(true);
  }

  // ───────────────────────────── helpers ─────────────────────────────

  /// Levels come from the API; until they land (or if the fetch failed) the
  /// static defaults keep the picker usable.
  List<OpponentLevelModel> _levelOptions(OpponentMatchState state) =>
      state.levels.isEmpty ? OpponentLevelModel.defaults : state.levels;

  /// The active selection — the user's pick, or the first option.
  OpponentLevelModel _resolveLevel(List<OpponentLevelModel> levels) =>
      _level ?? levels.first;

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  String _apiTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  /// `18:30` → 6:30 PM; null when the value isn't `HH:mm`.
  TimeOfDay? _parseApiTime(String raw) {
    final parts = raw.trim().split(':');
    if (parts.length < 2) return null;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(
      parts[1].length > 2 ? parts[1].substring(0, 2) : parts[1],
    );
    if (hour == null || minute == null || hour > 23 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  DateTime _bookingDateTime(BookingDraft booking) {
    final TimeOfDay time = _parseApiTime(booking.apiTime ?? '') ?? _time;
    return _combine(booking.selectedDate, time);
  }

  String _venueLabel(
    PublicListingVenueModel venue, {
    required String courtName,
  }) {
    final String venueName = venue.name?.trim() ?? '';
    final String location = venue.exactLocation?.trim().isNotEmpty == true
        ? venue.exactLocation!.trim()
        : venue.address?.trim() ?? '';
    return <String>[
      courtName,
      if (venueName.isNotEmpty && venueName != courtName) venueName,
      location,
    ].where((String value) => value.isNotEmpty).join(', ');
  }

  CourtDetailModel _courtFromVenue(PublicListingVenueModel venue) {
    final List<String> images = <String>[
      if (venue.featureImage?.trim().isNotEmpty == true)
        venue.featureImage!.trim(),
      ...?venue.galleryImages
          ?.map((VenueGalleryImageModel image) => image.imageUrl?.trim() ?? '')
          .where((String image) => image.isNotEmpty),
    ];
    final String location = venue.address?.trim() ?? '';
    final String exactLocation = venue.exactLocation?.trim().isNotEmpty == true
        ? venue.exactLocation!.trim()
        : location;
    final String courtType =
        venue.courtTypes
            ?.map((CourtTypeModel type) => type.name?.trim() ?? '')
            .firstWhere((String name) => name.isNotEmpty, orElse: () => '') ??
        '';
    return CourtDetailModel(
      venueId: venue.id,
      name: venue.name?.trim().isNotEmpty == true
          ? venue.name!.trim()
          : 'Futsal venue',
      location: location,
      address: exactLocation,
      price: venue.price == null ? '' : 'Rs ${venue.price!.toStringAsFixed(0)}',
      rating: 0,
      reviewCount: 0,
      images: images,
      isOpen: venue.isOpen ?? false,
      distance: '',
      features: <String>[
        if (courtType.isNotEmpty) courtType,
        if ((venue.maxPlayer ?? 0) > 0) '${venue.maxPlayer} Players',
      ],
      description: '',
      hostedByName: '',
      hostedByAvatar: '',
      hostedSince: '',
      hostedCourts: 0,
      responseRate: 0,
      policies: const <String>[],
      rules: const <String>[],
      reviews: const <ReviewModel>[],
      openTime: venue.minTime ?? '',
      closeTime: venue.maxTime ?? '',
      courtType: courtType,
      surfaceType: '',
      maxPlayers: venue.maxPlayer ?? 0,
    );
  }

  // ───────────────────────────── build ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.newRequest),
      body: SafeArea(
        top: false,
        child: BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
          builder: (context, state) {
            return Column(
              children: [
                _StepTracker(
                  current: _step,
                  isComplete: _stepComplete,
                  onTap: (step) {
                    // Only steps already satisfied can be jumped to, so the
                    // wizard can't be skipped forward.
                    if (step.index <= _step.index) _goTo(step);
                  },
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: ListView(
                        key: ValueKey<_Step>(_step),
                        physics: const BouncingScrollPhysics(),
                        padding: AppUtils().getPadding(
                          symmetricHorizontal: AppDimens.paddingX20,
                          top: AppDimens.paddingX6,
                          bottom: AppDimens.paddingX28,
                        ),
                        children: switch (_step) {
                          _Step.match => _matchStep(state),
                          _Step.venue => _venueStep(),
                          _Step.cost => _costStep(),
                          _Step.publish => _publishStep(state),
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomBar(
        text: _step == _Step.publish ? 'Publish Opponent Request' : 'Continue',
        icon: _step == _Step.publish
            ? Icons.campaign_rounded
            : Icons.arrow_forward_rounded,
        onNext: _next,
        onBack: _back,
        backText: _step == _Step.match ? 'Cancel' : 'Back',
      ),
    );
  }

  // ── Step 1: team + match details ──

  /// Team, format/level and preferred schedule in one step. The team blocks
  /// progress; everything below it has a sensible default.
  List<Widget> _matchStep(OpponentMatchState state) => <Widget>[
    const OpponentGuidanceCard(
      icon: Icons.sports_soccer_rounded,
      title: 'Who plays, and what match?',
      message:
          'Pick the team that will play — its roster size drives the per-player '
          'share shown later — then describe the match you want. Date and time '
          'can still change when you attach a booking next.',
    ),
    const SizedBox(height: AppDimens.paddingX18),
    const OpponentSectionLabel('Select / create team'),
    // Teams arrive asynchronously, so "no teams" is only true once the fetch
    // has actually settled — otherwise a slow load looked like an empty roster.
    if (state.teams.isEmpty &&
        (state.teamsStatus == OpponentMatchStatus.initial ||
            state.teamsStatus == OpponentMatchStatus.loading))
      const OpponentCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
            child: SizedBox(
              width: AppDimens.sizeX24,
              height: AppDimens.sizeX24,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: LightColor.secondaryColor,
              ),
            ),
          ),
        ),
      )
    else if (state.teams.isEmpty &&
        state.teamsStatus == OpponentMatchStatus.failure)
      _StepMessageCard(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load your teams',
        message: state.errorMessage ?? StringConstants.tryAgain,
        actionLabel: StringConstants.retry,
        actionIcon: Icons.refresh_rounded,
        onAction: () =>
            context.read<OpponentMatchBloc>().add(const LoadTeamsEvent()),
      )
    else if (state.teams.isEmpty)
      _StepMessageCard(
        icon: Icons.groups_2_outlined,
        title: 'No teams yet',
        message:
            'A request is published in a team\'s name, so create the team '
            'that will play this match.',
        actionLabel: StringConstants.createTeam,
        actionIcon: Icons.add_rounded,
        onAction: _openCreateTeamSheet,
      )
    else
      ...state.teams.map(
        (team) => Padding(
          padding: AppUtils().getPadding(bottom: AppDimens.paddingX10),
          child: _SelectableTile(
            title: team.name,
            subtitle:
                '${team.players.length} '
                '${team.players.length == 1 ? 'player' : 'players'}'
                '${team.positionSummary.isEmpty ? '' : ' · ${team.positionSummary}'}',
            icon: Icons.shield_outlined,
            selected: team.id == _team?.id,
            onTap: () => setState(() => _team = team),
          ),
        ),
      ),
    if (_submitted && _team == null) ...<Widget>[
      const SizedBox(height: AppDimens.paddingX8),
      _ValidationNote(message: _stepHint(_Step.match)),
    ],
    const SizedBox(height: AppDimens.paddingX18),
    const OpponentSectionLabel('Match format'),
    OpponentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OpponentFieldLabel('Match Type'),
          _PillWrap(
            children: MatchFormat.values
                .map(
                  (f) => OpponentPillChip(
                    label: f.label,
                    active: _format == f,
                    padding: _kPillPadding,
                    onTap: () => setState(() => _format = f),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppDimens.paddingX14),
          const OpponentFieldLabel('Opponent Level'),
          _PillWrap(
            children: _levelOptions(state)
                .map(
                  (l) => OpponentPillChip(
                    label: l.name,
                    active: _resolveLevel(_levelOptions(state)) == l,
                    compact: true,
                    padding: _kPillPadding,
                    onTap: () => setState(() => _level = l),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
    const SizedBox(height: AppDimens.paddingX18),
    const OpponentSectionLabel('Preferred schedule'),
    OpponentCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          OpponentPickerRow(
            icon: Icons.calendar_month_outlined,
            label: StringConstants.matchDate,
            value: OpponentFmt.shortDate(_date),
            onTap: _pickDate,
          ),
          const OpponentRowDivider(),
          OpponentPickerRow(
            icon: Icons.schedule_outlined,
            label: StringConstants.matchTime,
            value: OpponentFmt.time(_time),
            onTap: _pickTime,
          ),
        ],
      ),
    ),
  ];

  // ── Step 2: venue ──

  List<Widget> _venueStep() => <Widget>[
    const OpponentGuidanceCard(
      icon: Icons.stadium_outlined,
      title: 'Venue already booked?',
      message:
          'A published request always carries a venue, so opponents know '
          'exactly where and when they are playing.',
    ),
    const SizedBox(height: AppDimens.paddingX18),
    const OpponentSectionLabel('Venue arrangement'),
    _VenuePlanOption(
      title: 'Yes — I already booked a venue',
      subtitle: 'Attach one of your bookings, or enter an outside booking.',
      icon: Icons.event_available_outlined,
      selected: _venuePlan == _VenuePlan.alreadyBooked,
      onTap: () => _selectVenuePlan(_VenuePlan.alreadyBooked),
    ),
    const SizedBox(height: AppDimens.paddingX10),
    _VenuePlanOption(
      title: 'No — find and book a court now',
      subtitle: 'Browse venues, pick a court, date and time, then confirm.',
      icon: Icons.search_rounded,
      selected: _venuePlan == _VenuePlan.findAvailable,
      onTap: () => _selectVenuePlan(_VenuePlan.findAvailable),
    ),
    const SizedBox(height: AppDimens.paddingX18),
    if (_venuePlan == _VenuePlan.alreadyBooked)
      ..._alreadyBookedBranch()
    else
      ..._findAvailableBranch(),
  ];

  List<Widget> _alreadyBookedBranch() => <Widget>[
    const OpponentSectionLabel('Select existing booking'),
    OpponentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OpponentPillChip(
                  label: 'My bookings',
                  active: _bookedSource == _BookedSource.existingBooking,
                  compact: true,
                  onTap: () => setState(
                    () => _bookedSource = _BookedSource.existingBooking,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.paddingX8),
              Expanded(
                child: OpponentPillChip(
                  label: 'Booked elsewhere',
                  active: _bookedSource == _BookedSource.manual,
                  compact: true,
                  onTap: () =>
                      setState(() => _bookedSource = _BookedSource.manual),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX14),
          if (_bookedSource == _BookedSource.existingBooking)
            ..._existingBookingFields()
          else
            ..._manualVenueFields(),
        ],
      ),
    ),
    if (_submitted && !_venueSettled) ...<Widget>[
      const SizedBox(height: AppDimens.paddingX8),
      _ValidationNote(message: _stepHint(_Step.venue)),
    ],
  ];

  List<Widget> _existingBookingFields() {
    final BookingModel? booking = _existingBooking;
    return <Widget>[
      _PickerTile(
        icon: Icons.event_available_outlined,
        label: booking == null
            ? 'Choose from your bookings'
            : <String>[
                booking.courtName,
                booking.futsalName,
              ].where((s) => s.trim().isNotEmpty).join(' · '),
        value: booking == null
            ? 'Court, date, time and fee are filled in for you'
            : '${OpponentFmt.shortDate(booking.date)}'
                  '${booking.displayTimeRange.isEmpty ? '' : ' · ${booking.displayTimeRange}'}'
                  ' · ${OpponentFmt.npr(booking.bookingTotal.round())}',
        selected: booking != null,
        actionLabel: booking == null ? 'Select' : 'Change',
        onTap: _pickExistingBooking,
      ),
      if (booking != null) ...<Widget>[
        const SizedBox(height: AppDimens.paddingX12),
        _ConfirmedVenueCard(
          title: 'Booking attached',
          venue: _venueLabelText,
          when: OpponentFmt.friendlyDateTime(_kickoff),
          slot: _slotLabel,
          fee: booking.bookingTotal.round(),
          reference: booking.bookingRef,
        ),
      ],
    ];
  }

  List<Widget> _manualVenueFields() => <Widget>[
    CustomTextField(
      controller: _venueNameCtrl,
      labelText: 'Venue name',
      hintText: 'Enter the booked venue',
      icon: Icons.stadium_outlined,
      textCapitalization: TextCapitalization.words,
      onChanged: (_) => setState(() {}),
      autovalidateMode: _submitted
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      validator: (String? value) =>
          value?.trim().isEmpty ?? true ? 'Enter the venue name' : null,
    ),
    const SizedBox(height: AppDimens.paddingX14),
    CustomTextField(
      controller: _venueLocationCtrl,
      labelText: 'Venue location',
      hintText: 'Area, city or full address',
      icon: Icons.location_on_outlined,
      textCapitalization: TextCapitalization.words,
      onChanged: (_) => setState(() {}),
      autovalidateMode: _submitted
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      validator: (String? value) =>
          value?.trim().isEmpty ?? true ? 'Enter the venue location' : null,
    ),
    const SizedBox(height: AppDimens.paddingX14),
    CustomTextField(
      controller: _courtFeeCtrl,
      labelText: StringConstants.totalCourtFeeRs,
      hintText: 'What you paid for the court',
      icon: Icons.payments_outlined,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      // The cost-split preview recomputes from the real fee as it's typed.
      onChanged: (_) => setState(() {}),
      autovalidateMode: _submitted
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      validator: (String? value) =>
          (int.tryParse(value?.trim() ?? '') ?? 0) <= 0
          ? 'Enter the total court fee'
          : null,
    ),
  ];

  List<Widget> _findAvailableBranch() => <Widget>[
    const OpponentSectionLabel('Browse venues'),
    OpponentCard(
      child: BlocBuilder<PublicVenueBloc, PublicVenueState>(
        bloc: _publicVenueBloc,
        builder: (context, venueState) {
          if ((venueState.status == PublicVenueStatus.idle ||
                  venueState.status == PublicVenueStatus.loading) &&
              venueState.venues.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimens.paddingX12),
                child: CircularProgressIndicator(
                  color: LightColor.secondaryColor,
                ),
              ),
            );
          }
          final PublicListingVenueModel? venue = _preferredVenue;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _PickerTile(
                icon: Icons.stadium_outlined,
                label: venue == null
                    ? StringConstants.preferredVenue
                    : venue.name?.trim() ?? StringConstants.preferredVenue,
                value: venue == null
                    ? StringConstants.searchVenueToCheckSlots
                    : (venue.exactLocation?.trim().isNotEmpty == true
                          ? venue.exactLocation!.trim()
                          : venue.address?.trim() ?? ''),
                selected: venue != null,
                actionLabel: venue == null ? 'Search' : 'Change',
                onTap: _pickPreferredVenue,
              ),
              if (venueState.status == PublicVenueStatus.failure) ...<Widget>[
                const SizedBox(height: AppDimens.paddingX10),
                _InlineRetry(
                  message: venueState.errorMessage ?? 'Could not load venues.',
                  onRetry: () =>
                      _publicVenueBloc.add(const FetchPublicVenuesEvent()),
                ),
              ],
              const SizedBox(height: AppDimens.paddingX14),
              _PickerTile(
                icon: Icons.event_seat_outlined,
                label: 'Find and book a court now',
                value: _confirmedSlot == null
                    ? 'Choose a court, date and available time slot'
                    : '${_confirmedSlot!.courtName} · '
                          '${OpponentFmt.shortDate(_confirmedSlot!.selectedDate)} · '
                          '$_slotLabel',
                selected: _confirmedSlot != null,
                enabled: venue?.id != null,
                actionLabel: _confirmedSlot == null ? 'Open' : 'Change',
                onTap: _confirmVenueBooking,
              ),
            ],
          );
        },
      ),
    ),
    if (_confirmedSlot != null) ...<Widget>[
      const SizedBox(height: AppDimens.paddingX14),
      _ConfirmedVenueCard(
        title: 'Venue booking confirmed',
        venue: _venueLabelText,
        when: OpponentFmt.friendlyDateTime(_kickoff),
        slot: _slotLabel,
        fee: _resolvedCourtFee ?? 0,
        reference: _confirmedSlot!.bookingId == null
            ? ''
            : '#${_confirmedSlot!.bookingId}',
      ),
    ],
    if (_submitted && !_venueSettled) ...<Widget>[
      const SizedBox(height: AppDimens.paddingX8),
      _ValidationNote(message: _stepHint(_Step.venue)),
    ],
  ];

  // ── Step 3: cost split ──

  List<Widget> _costStep() => <Widget>[
    const OpponentGuidanceCard(
      icon: Icons.pie_chart_outline_rounded,
      title: 'Configure the cost split rule',
      message:
          'Decide how the court fee is divided with the opponent. The '
          'accepting team sees this exact rule before it pays.',
    ),
    const SizedBox(height: AppDimens.paddingX18),
    const OpponentSectionLabel('Cost split'),
    OpponentCostSplitCard(
      cost: _cost,
      onSplit: (v) => setState(() => _split = v),
      onBasisChange: (v) => setState(() => _basis = v),
      onPercentChange: (v) => setState(() => _myPercent = v),
      onLoserPctChange: (v) => setState(() => _loserPercent = v),
    ),
    const SizedBox(height: AppDimens.paddingX8),
    Text(
      StringConstants.finalPricingConfirmedByServer,
      style: FutsalTheme.getTextTheme(
        context,
      ).bodyMiniSubTitle?.copyWith(color: LightColor.hintTextColor),
    ),
  ];

  // ── Step 4: message + publish ──

  List<Widget> _publishStep(OpponentMatchState state) {
    final cost = _cost;
    final int totalFee = _resolvedCourtFee ?? cost.courtFee;
    final level = _resolveLevel(_levelOptions(state));
    return <Widget>[
      const OpponentGuidanceCard(
        icon: Icons.campaign_outlined,
        title: 'Review and publish',
        message:
            'Once published, every eligible team can see this request and '
            'send you an invitation. You pick the opponent you want.',
      ),
      const SizedBox(height: AppDimens.paddingX18),
      const OpponentSectionLabel('Add a message (optional)'),
      OpponentCard(
        child: CustomTextField(
          controller: _messageCtrl,
          labelText: StringConstants.message,
          hintText: StringConstants.message,
          icon: Icons.chat_bubble_outline_rounded,
          maxLines: 3,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          textCapitalization: TextCapitalization.sentences,
          isRequired: false,
        ),
      ),
      const SizedBox(height: AppDimens.paddingX18),
      const OpponentSectionLabel('Request summary'),
      OpponentCard(
        child: Column(
          children: <Widget>[
            _SummaryRow(
              icon: Icons.shield_outlined,
              label: 'Team',
              value: _team == null
                  ? '—'
                  : '${_team!.name} · ${_team!.players.length} players',
              onEdit: () => _goTo(_Step.match),
            ),
            const SizedBox(height: AppDimens.paddingX10),
            _SummaryRow(
              icon: Icons.sports_soccer_rounded,
              label: 'Match',
              value: '${_format.label} · ${level.name}',
              onEdit: () => _goTo(_Step.match),
            ),
            const SizedBox(height: AppDimens.paddingX10),
            _SummaryRow(
              icon: Icons.schedule_outlined,
              label: 'Kickoff',
              value:
                  '${OpponentFmt.friendlyDateTime(_kickoff)}'
                  '${_slotLabel.isEmpty ? '' : ' · $_slotLabel'}',
              onEdit: () => _goTo(_Step.venue),
            ),
            const SizedBox(height: AppDimens.paddingX10),
            _SummaryRow(
              icon: Icons.location_on_outlined,
              label: 'Venue',
              value: _venueLabelText.isEmpty ? 'Not set' : _venueLabelText,
              onEdit: () => _goTo(_Step.venue),
            ),
            const SizedBox(height: AppDimens.paddingX10),
            _SummaryRow(
              icon: Icons.payments_outlined,
              label: 'Cost split',
              value:
                  '${OpponentFmt.npr(totalFee)} total · '
                  '${cost.isResultBased ? 'Loser pays $_loserPercent%' : 'You pay ${cost.myPct ?? 0}%'}',
              onEdit: () => _goTo(_Step.cost),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppDimens.paddingX12),
      OpponentCard(
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.visibility_outlined,
              size: AppDimens.sizeX18,
              color: LightColor.secondaryColor,
            ),
            const SizedBox(width: AppDimens.paddingX10),
            Expanded(
              child: Text(
                'After publishing, the request becomes visible to all eligible '
                'teams and their invitations arrive under My Requests.',
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      color: LightColor.secondaryTextColor,
                      height: 1.4,
                    ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

/// Empty / error state inside a step, with one call to action.
class _StepMessageCard extends StatelessWidget {
  const _StepMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return OpponentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX36,
                height: AppDimens.sizeX36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppDimens.sizeX20,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX8),
          Text(
            message,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX14),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: AppDimens.sizeX44,
              child: CustomButton(
                text: actionLabel,
                icon: actionIcon,
                onPressed: onAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal padding that lets a pill size to its own label inside [_PillWrap].
const EdgeInsets _kPillPadding = EdgeInsets.symmetric(
  horizontal: AppDimens.paddingX14,
);

/// Wrapping row of option pills.
///
/// The level options come from `/opponent-levels`, so the count isn't known at
/// build time. A fixed row of equal columns ellipsised longer names ("Interme…")
/// once there were more than three; wrapping keeps every label readable and
/// spills onto a second line instead.
class _PillWrap extends StatelessWidget {
  const _PillWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.paddingX8,
      runSpacing: AppDimens.paddingX8,
      children: children,
    );
  }
}

/// Horizontal step tracker across the top of the wizard.
class _StepTracker extends StatelessWidget {
  const _StepTracker({
    required this.current,
    required this.isComplete,
    required this.onTap,
  });

  final _Step current;
  final bool Function(_Step) isComplete;
  final ValueChanged<_Step> onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX12,
      ),
      color: LightColor.cardColor,
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final step in _Step.values) ...<Widget>[
                if (step.index > 0)
                  // Connector sits on the dot's centre line and fills in as the
                  // wizard advances, so progress reads at a glance.
                  _StepConnector(passed: step.index <= current.index),
                Expanded(
                  child: InkWell(
                    // Forward steps aren't reachable yet; leaving them tappable
                    // produced a tap that silently did nothing.
                    onTap: step.index <= current.index
                        ? () => onTap(step)
                        : null,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    child: _StepDot(
                      step: step,
                      current: current,
                      complete: step.index < current.index && isComplete(step),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimens.paddingX8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Step ${current.index + 1} of ${_Step.values.length} · ',
                style: textTheme.bodyMiniSubTitle?.copyWith(
                  color: LightColor.hintTextColor,
                ),
              ),
              Text(
                current.title,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Track between two step dots. [passed] tints it in the brand green.
class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.passed});

  final bool passed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Half the dot height, so the line meets the dots' centres.
      padding: const EdgeInsets.only(top: AppDimens.sizeX12 - 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: AppDimens.sizeX2,
        width: AppDimens.sizeX16,
        decoration: BoxDecoration(
          color: passed ? LightColor.secondaryColor : LightColor.dividerColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX2),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.current,
    required this.complete,
  });

  final _Step step;
  final _Step current;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool active = step == current;
    final Color color = active || complete
        ? LightColor.secondaryColor
        : LightColor.hintTextColor;
    return Column(
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: AppDimens.sizeX24,
          height: AppDimens.sizeX24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: complete || active
                ? LightColor.secondaryColor
                : LightColor.background,
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: complete
              ? const Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: LightColor.whiteColor,
                )
              : Text(
                  '${step.index + 1}',
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: active
                        ? LightColor.whiteColor
                        : LightColor.hintTextColor,
                  ),
                ),
        ),
        const SizedBox(height: AppDimens.sizeX4),
        Text(
          step.shortLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMiniSubTitle?.copyWith(
            color: color,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Back + primary action footer for the wizard.
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.text,
    required this.icon,
    required this.onNext,
    required this.onBack,
    required this.backText,
  });

  final String text;
  final IconData icon;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String backText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radiusX20),
          topRight: Radius.circular(AppDimens.radiusX20),
        ),
        border: Border.all(
          color: LightColor.dividerColor.withValues(alpha: 0.7),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: AppDimens.radiusX28,
            offset: const Offset(0, AppDimens.sizeX10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: AppDimens.sizeX54,
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: LightColor.dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    ),
                  ),
                  child: Text(
                    backText,
                    style: FutsalTheme.getTextTheme(context).bodyTextSmall
                        ?.copyWith(
                          color: LightColor.secondaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: AppDimens.sizeX54,
                child: CustomButton(text: text, icon: icon, onPressed: onNext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Radio-style option row for the "venue already booked?" decision.
class _VenuePlanOption extends StatelessWidget {
  const _VenuePlanOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: AppUtils().getPadding(all: AppDimens.paddingX12),
          decoration: BoxDecoration(
            color: selected
                ? LightColor.secondaryColor.withValues(alpha: 0.08)
                : LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(
              color: selected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX38,
                height: AppDimens.sizeX38,
                decoration: BoxDecoration(
                  color: selected
                      ? LightColor.secondaryColor.withValues(alpha: 0.13)
                      : LightColor.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppDimens.sizeX20,
                  color: selected
                      ? LightColor.secondaryColor
                      : LightColor.secondaryTextColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      subtitle,
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: LightColor.secondaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? LightColor.secondaryColor
                    : LightColor.hintTextColor,
                size: AppDimens.sizeX20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selectable card used for the team list.
class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: AppUtils().getPadding(all: AppDimens.paddingX12),
          decoration: BoxDecoration(
            color: selected
                ? LightColor.secondaryColor.withValues(alpha: 0.08)
                : LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(
              color: selected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                size: AppDimens.sizeX20,
                color: selected
                    ? LightColor.secondaryColor
                    : LightColor.secondaryTextColor,
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      subtitle,
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? LightColor.secondaryColor
                    : LightColor.hintTextColor,
                size: AppDimens.sizeX20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tap-to-open row with a trailing action label, used for the venue and
/// booking pickers.
class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.actionLabel,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool selected;
  final String actionLabel;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color accent = !enabled
        ? LightColor.hintTextColor
        : selected
        ? LightColor.secondaryColor
        : LightColor.secondaryTextColor;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          child: Container(
            padding: AppUtils().getPadding(all: AppDimens.paddingX12),
            decoration: BoxDecoration(
              color: LightColor.background,
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              border: Border.all(
                color: selected
                    ? LightColor.secondaryColor.withValues(alpha: 0.55)
                    : LightColor.dividerColor,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, size: AppDimens.sizeX20, color: accent),
                const SizedBox(width: AppDimens.paddingX12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimens.sizeX2),
                      Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMiniSubTitle?.copyWith(
                          color: LightColor.secondaryTextColor,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX8),
                Text(
                  actionLabel,
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.secondaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: AppDimens.sizeX18,
                  color: LightColor.hintTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Confirmation card shown once the venue behind the request is settled.
class _ConfirmedVenueCard extends StatelessWidget {
  const _ConfirmedVenueCard({
    required this.title,
    required this.venue,
    required this.when,
    required this.slot,
    required this.fee,
    this.reference = '',
  });

  final String title;
  final String venue;
  final String when;
  final String slot;
  final int fee;
  final String reference;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: LightColor.secondaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.check_circle_rounded,
                size: AppDimens.sizeX18,
                color: LightColor.secondaryColor,
              ),
              const SizedBox(width: AppDimens.paddingX8),
              Text(
                title,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX10),
          _MiniLine(icon: Icons.location_on_outlined, text: venue),
          const SizedBox(height: AppDimens.paddingX6),
          _MiniLine(
            icon: Icons.schedule_outlined,
            text: slot.isEmpty ? when : '$when · $slot',
          ),
          if (fee > 0) ...<Widget>[
            const SizedBox(height: AppDimens.paddingX6),
            _MiniLine(
              icon: Icons.payments_outlined,
              text: '${OpponentFmt.npr(fee)} court fee',
            ),
          ],
          if (reference.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: AppDimens.paddingX6),
            _MiniLine(
              icon: Icons.confirmation_number_outlined,
              text: 'Booking ${reference.trim()}',
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  const _MiniLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 14, color: LightColor.secondaryTextColor),
        const SizedBox(width: AppDimens.paddingX8),
        Expanded(
          child: Text(
            text,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

/// Review row on the publish step, with a shortcut back to its step.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: AppDimens.sizeX18, color: LightColor.hintTextColor),
        const SizedBox(width: AppDimens.paddingX10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: textTheme.bodyMiniSubTitle?.copyWith(
                  color: LightColor.hintTextColor,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX2),
              Text(
                value,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.paddingX8),
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(AppDimens.radiusX6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              'Edit',
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: LightColor.secondaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Inline "couldn't load — retry" strip used inside a step's card.
class _InlineRetry extends StatelessWidget {
  const _InlineRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX10,
        symmetricVertical: AppDimens.paddingX8,
      ),
      decoration: BoxDecoration(
        color: LightColor.redLightColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.cloud_off_rounded,
            size: AppDimens.sizeX16,
            color: LightColor.redColor,
          ),
          const SizedBox(width: AppDimens.paddingX8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingX6),
          InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(AppDimens.radiusX6),
            child: Padding(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX6,
                symmetricVertical: AppDimens.paddingX2,
              ),
              child: Text(
                StringConstants.retry,
                style: textTheme.bodyMiniSubTitle?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationNote extends StatelessWidget {
  const _ValidationNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.error_outline_rounded,
          size: AppDimens.sizeX16,
          color: LightColor.redColor,
        ),
        const SizedBox(width: AppDimens.paddingX6),
        Expanded(
          child: Text(
            message,
            style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
              color: LightColor.redColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
