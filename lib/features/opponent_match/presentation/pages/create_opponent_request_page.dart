import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/acknowledge_sheet.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_date_picker.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/core/widgets/custom_time_picker_bottom_sheet.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_draft.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/slots_selection_route_args.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/models/opponent_cost_split.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/existing_booking_sheet.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/opponent_common.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/opponent_cost_split_card.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/opponent_sheets.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';
import 'package:hamro_futsal/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_public_venues_use_case.dart';
import 'package:hamro_futsal/features/public/data/model/public_option_model.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_step_request.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_court_options_use_case.dart';
import 'package:hamro_futsal/features/public/presentation/bloc/public_court_options/public_court_options_bloc.dart';
import 'package:hamro_futsal/features/public/presentation/bloc/public_venue/public_venue_bloc.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/venue_search_sheet.dart';

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
}

/// Full-page wizard to compose and publish one opponent request.
///
/// Teams are managed on the "My Teams" tab — here you only pick one.
/// Pops with `true` after the request is dispatched.
///
/// Pass [draft] to resume an unpublished request from "My Requests": its match
/// section is pre-selected, the wizard opens on the step the backend stopped at
/// (`main_step`), and the first-step submit patches that request instead of
/// opening a second one.
class CreateOpponentRequestPage extends StatefulWidget {
  const CreateOpponentRequestPage({super.key, this.draft});

  final OpponentRequestModel? draft;

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
  late final PublicCourtOptionsBloc _optionsBloc;

  /// Match formats come from their own bloc, so a resumed draft has to watch it
  /// too — not just the shared [OpponentMatchBloc].
  StreamSubscription<PublicCourtOptionsState>? _optionsSub;

  _Step _step = _Step.match;

  /// Armed by a system back press on the first step, and disarmed a couple of
  /// seconds later. The wizard holds several steps of work, and the OS back
  /// gesture is easy to trigger by accident, so leaving takes two presses.
  Timer? _exitArmedTimer;

  bool get _exitArmed => _exitArmedTimer?.isActive ?? false;

  TeamModel? _team;

  /// Selected match format from `/match-formate`. The payload needs its
  /// server id, so the old local 5v5/6v6/7v7 enum cannot drive this any more.
  PublicOptionModel? _format;

  /// Selected opponent level from `/opponent-levels`; defaults to the first
  /// fetched level (see [_resolveLevel]) until the user picks one.
  OpponentLevelModel? _level;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  _VenuePlan _venuePlan = _VenuePlan.alreadyBooked;
  _BookedSource _bookedSource = _BookedSource.existingBooking;

  /// The booked window on the "booked elsewhere" path. The server requires both
  /// ends for an external venue, so they are part of that branch rather than
  /// derived from step one's preferred time.
  TimeOfDay _externalStart = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _externalEnd = const TimeOfDay(hour: 19, minute: 0);

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

  /// Resuming a draft: true once every selection the payload described has been
  /// matched against its lookup list, so the pickers are not re-seeded over a
  /// choice the user has since changed.
  bool _draftApplied = false;

  /// The court fee the server stored for this request, read back after the
  /// venue step. Fills the gap when the branch cannot work the fee out locally
  /// — a platform booking whose total the slot draft never carried, for
  /// instance — so the cost step shows the real figure instead of nothing.
  int? _serverCourtFee;

  /// True while a summary edit sheet is open. The venue flow can be reached
  /// from there too, and the sheet owns its own save — so the step must not
  /// advance underneath it.
  bool _editSheetOpen = false;

  /// Bumped by every [setState]. The summary's edit sheets live on their own
  /// route, so a page rebuild does not reach them — they listen to this instead
  /// and re-run the very same section builders step one to three use.
  final ValueNotifier<int> _editRevision = ValueNotifier<int>(0);

  /// True once the server's copy of the draft (`GET /auth/opponent-requests/
  /// {id}`) has filled the plain fields — date, time, message, venue, step.
  /// One-shot, so a later refetch never overwrites the user's edits.
  bool _draftHydrated = false;

  @override
  void initState() {
    super.initState();
    _publicVenueBloc = PublicVenueBloc(
      GetPublicVenuesUseCase(PublicRepositoryImpl()),
      perPage: 100,
    );
    _optionsBloc = PublicCourtOptionsBloc(
      GetCourtOptionsUseCase(PublicRepositoryImpl()),
    )..add(const FetchPublicMatchFormatsEvent());
    if (widget.draft != null) {
      _optionsSub = _optionsBloc.stream.listen((_) {
        if (!mounted) return;
        _applyDraftSelections(context.read<OpponentMatchBloc>().state);
      });
    }

    final OpponentRequestModel? draft = widget.draft;
    if (draft != null) {
      // The kickoff the match step captured; the venue step has not run on a
      // step-1 draft, so this is `preferred_date` + `preferred_time`.
      _date = draft.dateTime;
      _time = TimeOfDay(
        hour: draft.dateTime.hour,
        minute: draft.dateTime.minute,
      );
      _step = _stepFromMainStep(draft.mainStep);
    }

    // The id lives on the shared bloc, so a previous run of this wizard could
    // still be holding one. Seeding it here means opening the page either
    // starts a new request or, when resuming, patches the draft being
    // completed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final OpponentMatchBloc bloc = context.read<OpponentMatchBloc>();
      bloc.add(ResetOpponentMatchStepEvent(draftRequestId: draft?.id ?? ''));
      // The list row is only a summary — refetch the request so the wizard
      // autofills from the server's authoritative copy.
      if (draft != null) bloc.add(LoadOpponentDraftEvent(draft.id));
      _applyDraftSelections(bloc.state);
    });
  }

  static T? _firstOrNull<T>(Iterable<T> items, bool Function(T) test) {
    for (final T item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  /// The backend's 1-based `main_step` mapped onto the wizard's steps. An
  /// unknown or out-of-range value lands on the first step, which is always
  /// safe to re-submit.
  _Step _stepFromMainStep(int mainStep) => switch (mainStep) {
    2 => _Step.venue,
    3 => _Step.cost,
    4 => _Step.publish,
    _ => _Step.match,
  };

  /// Fills the wizard's plain fields from the fetched draft: the kickoff its
  /// match step saved, the note, and whatever its venue step settled — the
  /// booking itself for a court booked here, the typed fields for one booked
  /// elsewhere.
  void _hydrateFromDraft(OpponentRequestModel draft) {
    // The kickoff the match step saved — not the booked slot, which `dateTime`
    // prefers and which the venue step owns. Only the booked-elsewhere branch
    // shows a date picker now, and it is seeded from this.
    final DateTime preferred = draft.preferredDateTime ?? draft.dateTime;
    _date = preferred;
    _time = TimeOfDay(hour: preferred.hour, minute: preferred.minute);
    _step = _stepFromMainStep(draft.mainStep);
    if (draft.message.isNotEmpty) _messageCtrl.text = draft.message;

    // The split rule the cost step saved, so resuming shows what was submitted
    // rather than the card's defaults.
    if (draft.splitType.isNotEmpty) {
      _split = draft.splitType.toLowerCase() == 'custom'
          ? SplitMode.custom
          : SplitMode.even;
      _basis = draft.splitBasis.toLowerCase() == 'result'
          ? SplitBasis.result
          : SplitBasis.teams;
      final int percent = draft.requestingTeamPercent;
      // A result-based rule may legitimately be 100 (loser pays it all), so
      // only the fixed per-side split rejects the extremes.
      if (percent > 0 && percent <= 100) {
        if (_basis == SplitBasis.result) {
          _loserPercent = percent;
        } else if (percent < 100) {
          _myPercent = percent;
        }
      }
    }

    final String source = draft.venueSource.toLowerCase();
    if (source.isEmpty) return;
    if (source == 'booking' || draft.venueBookingId.isNotEmpty) {
      _venuePlan = _VenuePlan.alreadyBooked;
      _bookedSource = _BookedSource.existingBooking;
      // The payload nests the whole booking, which is the same shape the
      // bookings list serves — so the selection is restored, not just its
      // branch, and the step is complete without re-picking.
      if (draft.venueBooking.isNotEmpty) {
        _existingBooking = BookingModel.fromJson(draft.venueBooking);
      }
      return;
    }
    _venuePlan = _VenuePlan.alreadyBooked;
    _bookedSource = _BookedSource.manual;
    // Only the venue name — the manual form has no court field, so joining the
    // court in would send it back as part of the venue's name.
    _venueNameCtrl.text = draft.venueName;
    _venueLocationCtrl.text = draft.venueAddress;
    if (draft.totalFee > 0) _courtFeeCtrl.text = draft.totalFee.toString();
    // The window the venue step saved, so re-submitting keeps it rather than
    // silently replacing it with this branch's defaults.
    final TimeOfDay? start = draft.venueStartTime == null
        ? null
        : _parseApiTime(draft.venueStartTime!);
    final TimeOfDay? end = draft.venueEndTime == null
        ? null
        : _parseApiTime(draft.venueEndTime!);
    if (start != null) _externalStart = start;
    if (end != null) _externalEnd = end;
    if (start != null && !_externalWindowValid) {
      _externalEnd = TimeOfDay(
        hour: (start.hour + 1) % 24,
        minute: start.minute,
      );
    }
    // The external branch's own date, when it differs from the preferred one.
    if (draft.dateTime != draft.preferredDateTime) _date = draft.dateTime;
  }

  /// Re-selects the draft's team, format and level once their lookup lists have
  /// landed. Runs on every bloc emission until each one is matched, because the
  /// lists arrive from three independent fetches.
  /// Picks up the fee the server stored, for any request the wizard is working
  /// on — new or resumed. Runs on every emission because the venue step is what
  /// produces it.
  void _syncServerCourtFee(OpponentMatchState state) {
    final int? fee = state.draftDetail?.totalFee;
    if (fee == null || fee <= 0 || fee == _serverCourtFee || !mounted) return;
    setState(() => _serverCourtFee = fee);
  }

  void _applyDraftSelections(OpponentMatchState state) {
    if (widget.draft == null || !mounted) return;
    // The fetched copy wins over the list row it was opened with.
    final OpponentRequestModel draft = state.draftDetail ?? widget.draft!;

    if (state.draftDetail != null && !_draftHydrated) {
      _draftHydrated = true;
      setState(() => _hydrateFromDraft(state.draftDetail!));
    }
    if (_draftApplied) return;

    final List<PublicOptionModel> formats = _optionsBloc.state.matchFormats;

    final TeamModel? team =
        _team ??
        _firstOrNull<TeamModel>(
          state.teams,
          (TeamModel t) => t.id == draft.requesterTeamId,
        );
    final PublicOptionModel? format =
        _format ??
        _firstOrNull<PublicOptionModel>(
          formats,
          (PublicOptionModel f) => f.id == draft.matchFormatId,
        );
    final OpponentLevelModel? level =
        _level ??
        _firstOrNull<OpponentLevelModel>(
          state.levels,
          (OpponentLevelModel l) => l.id == draft.opponentLevelId,
        );

    if (team == _team && format == _format && level == _level) return;

    setState(() {
      _team = team;
      _format = format;
      _level = level;
      // Every list that had something to match has now been consulted.
      _draftApplied =
          (team != null || state.teams.isNotEmpty) &&
          (format != null || formats.isNotEmpty) &&
          (level != null || state.levels.isNotEmpty);
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    // Cheap and synchronous: an open edit sheet is rebuilt from the same state
    // the page just changed, so the two never disagree.
    _editRevision.value++;
  }

  @override
  void dispose() {
    _editRevision.dispose();
    _messageCtrl.dispose();
    _venueNameCtrl.dispose();
    _venueLocationCtrl.dispose();
    _courtFeeCtrl.dispose();
    _exitArmedTimer?.cancel();
    _optionsSub?.cancel();
    _publicVenueBloc.close();
    _optionsBloc.close();
    super.dispose();
  }

  // ───────────────────────────── derived state ─────────────────────────────

  /// The court fee the requester typed — manual already-booked path only.
  int? get _enteredCourtFee => int.tryParse(_courtFeeCtrl.text.trim());

  /// The real court fee behind the current venue choice, when one is known.
  ///
  /// The local answer wins so an edit shows immediately; [_serverCourtFee] only
  /// fills in when this branch cannot name a fee itself. Never falls back to the
  /// per-format table — see [OpponentCostSplit.courtFee].
  int? get _resolvedCourtFee => _localCourtFee ?? _serverCourtFee;

  int? get _localCourtFee {
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

  /// Display label of the chosen format, e.g. `5v5`.
  String get _formatLabel => _format?.name ?? '';

  /// The chosen format mapped back onto the local enum, which still drives the
  /// court-fee table used before a real venue is settled. Falls back to the
  /// smallest tier when the server's label is one the table does not know.
  MatchFormat get _formatTier => MatchFormat.values.firstWhere(
    (MatchFormat f) => f.label.toLowerCase() == _formatLabel.toLowerCase(),
    orElse: () => MatchFormat.fiveASide,
  );

  OpponentCostSplit get _cost => OpponentCostSplit(
    format: _formatTier,
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
    // Booked elsewhere: the window the user typed is the kickoff.
    if (_venuePlan == _VenuePlan.alreadyBooked &&
        _bookedSource == _BookedSource.manual) {
      return _combine(_date, _externalStart);
    }
    return _combine(_date, _time);
  }

  /// The date half of the kickoff line. When a slot range is shown next to it
  /// the range already carries the time, so repeating it read as two different
  /// times — "Tomorrow, 6:00 AM · 6:00 AM – 7:00 AM". Only a kickoff with no
  /// range keeps its time here.
  String get _kickoffWhen => _slotLabel.isEmpty
      ? OpponentFmt.friendlyDateTime(_kickoff)
      : OpponentFmt.friendlyDate(_kickoff);

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
    if (_venuePlan == _VenuePlan.alreadyBooked &&
        _bookedSource == _BookedSource.manual) {
      return '${OpponentFmt.time(_externalStart)} – '
          '${OpponentFmt.time(_externalEnd)}';
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

  /// Minutes past midnight, for comparing the two ends of the booked window.
  static int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  /// The booked window has to actually be a window.
  bool get _externalWindowValid =>
      _minutes(_externalEnd) > _minutes(_externalStart);

  /// Whether the venue step has everything the request needs.
  bool get _venueSettled {
    if (_venuePlan == _VenuePlan.alreadyBooked) {
      if (_bookedSource == _BookedSource.existingBooking) {
        return _existingBooking != null;
      }
      return _venueNameCtrl.text.trim().isNotEmpty &&
          _venueLocationCtrl.text.trim().isNotEmpty &&
          (_enteredCourtFee ?? 0) > 0 &&
          _externalWindowValid;
    }
    return _preferredVenue?.id != null && _confirmedSlot != null;
  }

  bool _stepComplete(_Step step) => switch (step) {
    // The format needs a server id to be submittable, so a step whose lookup
    // has not landed yet is not complete even though a pill looks selected.
    _Step.match => _team != null && _selectedFormatId != null,
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

  Future<void> _next() async {
    if (_step == _Step.publish) {
      await _publish();
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
    // A step advances only once its call succeeded. The wizard builds one
    // request on the server step by step, so moving on after a rejected save
    // would carry the user forward on answers the server never stored — and
    // every later step patches that same id, so they would all fail too.
    // The reason is already on screen; the step stays put so it can be fixed.
    // Step one opens the request (or patches the one it already opened).
    if (_step == _Step.match && !await _saveMatchStep()) return;
    // Step two attaches the venue to that id. Only the "already booked on this
    // platform" branch has an endpoint so far; the other branches still carry
    // their venue through to publish.
    if (_step == _Step.venue && !await _saveVenueStep()) return;
    // Step three replaces the split rule on that same id.
    if (_step == _Step.cost && !await _saveCostStep()) return;
    if (!mounted) return;

    HapticFeedback.selectionClick();
    _goTo(_Step.values[_step.index + 1]);
  }

  /// `POST /auth/opponent-requests` the first time, then
  /// `PATCH /auth/opponent-requests/{id}/match` on every later pass.
  ///
  /// Returns false when the call failed, with the reason already on screen —
  /// the wizard stays on this step, and a summary edit sheet stays open, until
  /// the change is actually saved.
  Future<bool> _saveMatchStep() async {
    final OpponentMatchBloc bloc = context.read<OpponentMatchBloc>();
    final int? teamId = int.tryParse(_team?.id ?? '');
    final int? formatId = _selectedFormatId;
    final int? levelId = int.tryParse(
      _resolveLevel(_levelOptions(bloc.state)).id,
    );

    if (teamId == null || formatId == null || levelId == null) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Some match details are still loading. Please try again.',
        key: 'opponent_match_step_ids',
      );
      return false;
    }

    bloc.add(
      SaveOpponentMatchStepEvent(
        OpponentMatchStepRequest(
          teamId: teamId,
          matchFormatId: formatId,
          opponentLevelId: levelId,
        ),
      ),
    );

    final OpponentMatchState result = await bloc.stream.firstWhere(
      (OpponentMatchState s) =>
          s.matchStepStatus != OpponentMatchStatus.loading,
    );
    if (!mounted) return false;

    if (result.matchStepStatus == OpponentMatchStatus.failure) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        result.matchStepError ?? StringConstants.somethingWentWrong,
        key: 'opponent_match_step_failed',
      );
      return false;
    }
    return true;
  }

  /// `PUT /auth/opponent-requests/{id}/venue` — sent for every venue branch.
  ///
  /// A court booked through this platform travels as its booking id
  /// (`venue_source: booking`); a court booked elsewhere is described field by
  /// field (`venue_source: external`).
  ///
  /// Returns false when the call failed, with the reason already on screen —
  /// the wizard stays on this step, and a summary edit sheet stays open, until
  /// the change is actually saved.
  Future<bool> _saveVenueStep() async {
    final OpponentVenueStepRequest? request = _venueStepRequest();
    if (request == null) return false;

    final OpponentMatchBloc bloc = context.read<OpponentMatchBloc>();
    bloc.add(SaveOpponentVenueStepEvent(request));

    final OpponentMatchState result = await bloc.stream.firstWhere(
      (OpponentMatchState s) =>
          s.venueStepStatus != OpponentMatchStatus.loading,
    );
    if (!mounted) return false;

    if (result.venueStepStatus == OpponentMatchStatus.failure) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        result.venueStepError ?? StringConstants.somethingWentWrong,
        key: 'opponent_venue_step_failed',
      );
      return false;
    }
    // Read the request back: the venue step is what settles the court fee, and
    // for a platform booking the server is the only one that knows it.
    if (result.draftRequestId.isNotEmpty) {
      bloc.add(LoadOpponentDraftEvent(result.draftRequestId));
    }
    return true;
  }

  /// Builds the venue body for whichever branch the user completed. Null means
  /// the branch has nothing submittable, which [_stepComplete] already guards.
  OpponentVenueStepRequest? _venueStepRequest() {
    if (_venuePlan == _VenuePlan.alreadyBooked) {
      if (_bookedSource == _BookedSource.existingBooking) {
        final BookingModel? booking = _existingBooking;
        return booking == null
            ? null
            : OpponentVenueStepRequest.existingBooking(booking.id);
      }
      // Booked elsewhere: the court is only known by what the user typed —
      // including the match date, which this branch picks itself.
      final String venueName = _venueNameCtrl.text.trim();
      if (venueName.isEmpty) return null;
      if (!_externalWindowValid) return null;
      return OpponentVenueStepRequest.external(
        venueName: venueName,
        courtName: '',
        address: _venueLocationCtrl.text.trim(),
        date: _date,
        // The match day this branch picked, which step one no longer asks for.
        preferredDate: _date,
        startTime: (hour: _externalStart.hour, minute: _externalStart.minute),
        endTime: (hour: _externalEnd.hour, minute: _externalEnd.minute),
        feeAmount: _enteredCourtFee ?? 0,
      );
    }

    // Find-available: once the slot is booked on this platform it has an id, so
    // it goes as a booking; before that it is described like an external court.
    final PublicListingVenueModel? venue = _preferredVenue;
    final BookingDraft? slot = _confirmedSlot;
    if (slot == null) return null;
    final int? bookingId = slot.bookingId;
    if (bookingId != null) {
      return OpponentVenueStepRequest.existingBooking(bookingId);
    }
    final TimeOfDay start =
        _parseApiTime(slot.apiTime ?? slot.selectedTime) ?? _time;
    // The server requires both ends of an external window, so an unstated end
    // becomes the usual one-hour slot rather than a 422.
    final TimeOfDay end =
        (slot.apiEndTime == null ? null : _parseApiTime(slot.apiEndTime!)) ??
        TimeOfDay(hour: (start.hour + 1) % 24, minute: start.minute);
    return OpponentVenueStepRequest.external(
      venueName: venue?.name ?? '',
      courtName: slot.courtName,
      address: venue?.address ?? '',
      date: slot.selectedDate,
      // Same payload shape, so the match day travels here too — the slot's own
      // date is the day being played.
      preferredDate: slot.selectedDate,
      startTime: (hour: start.hour, minute: start.minute),
      endTime: (hour: end.hour, minute: end.minute),
      feeAmount: _resolvedCourtFee ?? 0,
    );
  }

  /// `PUT /auth/opponent-requests/{id}/cost` — the split rule the accepting
  /// team sees before it pays.
  ///
  /// Returns false when the call failed, with the reason already on screen —
  /// the wizard stays on this step, and a summary edit sheet stays open, until
  /// the change is actually saved.
  Future<bool> _saveCostStep() async {
    final OpponentMatchBloc bloc = context.read<OpponentMatchBloc>();
    bloc.add(SaveOpponentCostStepEvent(_costStepRequest()));

    final OpponentMatchState result = await bloc.stream.firstWhere(
      (OpponentMatchState s) => s.costStepStatus != OpponentMatchStatus.loading,
    );
    if (!mounted) return false;

    if (result.costStepStatus == OpponentMatchStatus.failure) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        result.costStepError ?? StringConstants.somethingWentWrong,
        key: 'opponent_cost_step_failed',
      );
      return false;
    }
    return true;
  }

  /// Maps the card's selections onto the cost payload. An even split carries no
  /// percentage; a custom one is keyed either to the side (the requester's fixed
  /// share) or to the result (what the losing side carries).
  OpponentCostStepRequest _costStepRequest() {
    if (_split == SplitMode.even) return const OpponentCostStepRequest.even();
    return _basis == SplitBasis.result
        ? OpponentCostStepRequest.custom(
            basis: OpponentSplitBasis.result,
            requestingTeamPercent: _loserPercent,
          )
        : OpponentCostStepRequest.custom(
            basis: OpponentSplitBasis.team,
            requestingTeamPercent: _myPercent,
          );
  }

  /// Server id of the chosen format, once the lookup has landed.
  int? get _selectedFormatId {
    final PublicOptionModel? format = _resolveFormat(
      _optionsBloc.state.matchFormats,
    );
    return format == null ? null : int.tryParse(format.id);
  }

  void _back() {
    if (_step == _Step.match) {
      Navigator.of(context).pop();
      return;
    }
    _goTo(_Step.values[_step.index - 1]);
  }

  /// The OS back gesture used to close the whole wizard from any step, which
  /// threw away the steps the user had filled in. It now walks back through
  /// them the way the Back button does, and leaving from the first step asks
  /// for a second press.
  void _handleSystemBack() {
    if (_step != _Step.match) {
      _goTo(_Step.values[_step.index - 1]);
      return;
    }
    if (_exitArmed) {
      _exitArmedTimer?.cancel();
      Navigator.of(context).pop();
      return;
    }
    HapticFeedback.selectionClick();
    AppUtils().showSnackBar(
      context,
      MsgType.info,
      StringConstants.pressBackAgainToLeaveRequest,
      key: 'opponent_request_exit_hint',
    );
    // Only a press that follows this one closely counts as confirmation.
    _exitArmedTimer?.cancel();
    _exitArmedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  String _stepHint(_Step step) => switch (step) {
    _Step.match =>
      _team == null
          ? 'Select the team that will play.'
          : 'Pick a match type to continue.',
    _Step.venue =>
      _venuePlan != _VenuePlan.alreadyBooked
          ? 'Pick a venue, then confirm a court slot.'
          : _bookedSource == _BookedSource.existingBooking
          ? 'Select the booking that hosts this match.'
          : !_externalWindowValid
          ? 'The end time has to be after the start time.'
          : 'Fill in the venue, its location, the fee and the booked date '
                'and time.',
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
    // Land back on the venue step, not the next one: the confirmed card is the
    // receipt for what was just booked, and the user gets to see it before the
    // wizard moves on.
    setState(() {
      _confirmedSlot = booking;
      _date = booking.selectedDate;
      _time = _parseApiTime(booking.apiTime ?? '') ?? _time;
      _submitted = false;
    });
    HapticFeedback.selectionClick();

    // Unclosable on purpose: attaching the booking and moving the wizard on
    // both happen after this, so the user has to have seen it. Awaiting it is
    // what replaces the old "let the card paint first" delay.
    await showAcknowledgeSheet(
      context: context,
      title: StringConstants.bookingCompleted,
      message: StringConstants.bookingCompletedMessage,
      details: <AcknowledgeLine>[
        if (_venueLabelText.isNotEmpty)
          (icon: Icons.location_on_outlined, text: _venueLabelText),
        (
          icon: Icons.schedule_outlined,
          text: _slotLabel.isEmpty
              ? _kickoffWhen
              : '$_kickoffWhen · $_slotLabel',
        ),
        if ((_resolvedCourtFee ?? 0) > 0)
          (
            icon: Icons.payments_outlined,
            text: '${OpponentFmt.npr(_resolvedCourtFee!)} court fee',
          ),
        if (booking.bookingId != null)
          (
            icon: Icons.confirmation_number_outlined,
            text: 'Booking #${booking.bookingId}',
          ),
      ],
    );
    if (!mounted) return;

    // No booking id means the court was chosen but not booked on this platform,
    // so there is nothing to attach — the user continues from the step as usual.
    if (booking.bookingId == null) return;
    // Reached from a summary edit sheet: it saves and closes on its own terms.
    if (_editSheetOpen) return;

    // `PUT /auth/opponent-requests/{id}/venue` with
    // {"venue_source": "booking", "booking_id": <id>} — built by
    // [_venueStepRequest] from this very slot.
    // Same rule as Continue: a rejected venue save keeps the user on the step.
    if (!await _saveVenueStep() || !mounted) return;
    _goTo(_Step.cost);
  }

  // ───────────────────────────── summary editing ─────────────────────────────

  /// Opens one summary row's controls in a sheet, so a late correction never
  /// costs the user their place on the publish step.
  ///
  /// [body] is the same section builder the wizard step uses — there is no
  /// second copy of any form. [save] is the step endpoint that owns those
  /// fields; the sheet closes only once it succeeds, so a rejected change stays
  /// on screen with its reason.
  Future<void> _openEditSheet({
    required String title,
    required IconData icon,
    required List<Widget> Function(OpponentMatchState state) body,
    required Future<bool> Function() save,
    String? Function()? validate,
  }) async {
    final OpponentMatchBloc bloc = context.read<OpponentMatchBloc>();
    _editSheetOpen = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusX20),
        ),
      ),
      builder: (BuildContext sheetContext) =>
          BlocProvider<OpponentMatchBloc>.value(
            // The bloc is provided inside this page's route, which a sheet route
            // cannot see — hand it over explicitly.
            value: bloc,
            child: _EditSheet(
              title: title,
              icon: icon,
              revision: _editRevision,
              body: body,
              save: save,
              validate: validate,
            ),
          ),
    );
    _editSheetOpen = false;
    if (mounted) setState(() {});
  }

  Future<void> _editTeam() => _openEditSheet(
    title: 'Team',
    icon: Icons.shield_outlined,
    body: _teamSection,
    save: _saveMatchStep,
    validate: () => _team == null ? 'Select the team that will play.' : null,
  );

  Future<void> _editMatchDetails() => _openEditSheet(
    title: 'Match format',
    icon: Icons.sports_soccer_rounded,
    body: _matchDetailsSection,
    save: _saveMatchStep,
    validate: () =>
        _selectedFormatId == null ? 'Pick a match type to continue.' : null,
  );

  /// Kickoff and venue are the same answer — the attached booking settles both,
  /// so both rows open this one sheet.
  Future<void> _editVenue() => _openEditSheet(
    title: 'Kickoff & venue',
    icon: Icons.stadium_outlined,
    body: (_) => _venueSection(),
    save: _saveVenueStep,
    validate: () => _venueSettled ? null : _stepHint(_Step.venue),
  );

  Future<void> _editCostSplit() => _openEditSheet(
    title: 'Cost split',
    icon: Icons.pie_chart_outline_rounded,
    body: (_) => _costSection(),
    save: _saveCostStep,
  );

  // ───────────────────────────── publish ─────────────────────────────

  /// Last step: `POST /auth/opponent-requests/{id}/publish`, carrying only the
  /// message. Every other section already lives on the server, saved by its own
  /// step, so nothing else is re-sent.
  ///
  /// Pops with `true` once the server confirms; the confirmation message itself
  /// is shown by the screen underneath, from the bloc's success message.
  Future<void> _publish() async {
    setState(() => _submitted = true);
    if (_team == null) {
      AppUtils().showSnackBar(context, MsgType.info, _stepHint(_Step.match));
      _goTo(_Step.match);
      return;
    }
    if (!_venueSettled) {
      AppUtils().showSnackBar(context, MsgType.info, _stepHint(_Step.venue));
      _goTo(_Step.venue);
      return;
    }

    final OpponentMatchBloc bloc = context.read<OpponentMatchBloc>();
    HapticFeedback.mediumImpact();
    bloc.add(PublishOpponentRequestEvent(message: _messageCtrl.text.trim()));

    final OpponentMatchState result = await bloc.stream.firstWhere(
      (OpponentMatchState s) => s.publishStatus != OpponentMatchStatus.loading,
    );
    if (!mounted) return;

    if (result.publishStatus == OpponentMatchStatus.failure) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        result.publishError ?? StringConstants.somethingWentWrong,
        key: 'opponent_publish_failed',
      );
      return;
    }
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

  /// The active format — the user's pick, or the first one the server sent.
  /// Null only while the list is still loading or failed.
  PublicOptionModel? _resolveFormat(List<PublicOptionModel> formats) {
    if (formats.isEmpty) return null;
    final PublicOptionModel? picked = _format;
    if (picked == null) return formats.first;
    return formats.firstWhere(
      (PublicOptionModel f) => f.id == picked.id,
      orElse: () => formats.first,
    );
  }

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
    // `canPop: false` hands the system back gesture to [_handleSystemBack];
    // programmatic pops (publishing, the Back button on the first step) are
    // unaffected.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _handleSystemBack();
      },
      child: Scaffold(
        backgroundColor: LightColor.background,
        appBar: CustomAppBar(
          title: widget.draft == null
              ? StringConstants.newRequest
              : StringConstants.completeRequest,
          // The visible arrow steps back through the wizard too, instead of
          // abandoning it from step three.
          onBack: _back,
        ),
        body: SafeArea(
          top: false,
          child: BlocConsumer<OpponentMatchBloc, OpponentMatchState>(
            // Teams and levels arrive after the page opens; a resumed draft
            // re-selects itself as soon as they do.
            listener: (context, state) {
              _syncServerCourtFee(state);
              _applyDraftSelections(state);
              if (state.draftStatus == OpponentMatchStatus.failure) {
                AppUtils().showSnackBar(
                  context,
                  MsgType.error,
                  state.draftError ?? StringConstants.somethingWentWrong,
                  key: 'opponent_draft_load_failed',
                );
              }
            },
            builder: (context, state) {
              // Hold the form back until the draft's own data is in, so the user
              // never edits fields that are about to be overwritten.
              if (widget.draft != null &&
                  !_draftHydrated &&
                  state.isLoadingDraft) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: LightColor.secondaryColor,
                  ),
                );
              }
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
        bottomNavigationBar: BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
          buildWhen: (a, b) =>
              a.matchStepStatus != b.matchStepStatus ||
              a.venueStepStatus != b.venueStepStatus ||
              a.costStepStatus != b.costStepStatus ||
              a.publishStatus != b.publishStatus ||
              a.draftStatus != b.draftStatus,
          builder: (context, state) => SizedBox(
            height: 120,
            child: _BottomBar(
              text: _step == _Step.publish ? 'Publish Request' : 'Continue',
              icon: _step == _Step.publish
                  ? Icons.campaign_rounded
                  : Icons.arrow_forward_rounded,
              onNext: _next,
              onBack: _back,
              backText: _step == _Step.match ? 'Cancel' : 'Back',
              isBusy:
                  state.isSavingMatchStep ||
                  state.isSavingVenueStep ||
                  state.isSavingCostStep ||
                  state.isPublishing ||
                  (widget.draft != null &&
                      !_draftHydrated &&
                      state.isLoadingDraft),
            ),
          ),
        ),
      ),
    );
  }

  // ── Step 1: team + match details ──

  /// Team plus format/level in one step. The team blocks progress; the format
  /// and level below it both have a sensible default. The schedule is not asked
  /// here — it comes from the booking attached on the venue step.
  List<Widget> _matchStep(OpponentMatchState state) => <Widget>[
    const OpponentGuidanceCard(
      icon: Icons.sports_soccer_rounded,
      title: 'Who plays, and what match?',
      message:
          'Pick the team that will play — its roster size drives the per-player '
          'share shown later — then describe the match you want. The match '
          'date and time come from the booking you attach next.',
    ),
    const SizedBox(height: AppDimens.paddingX18),
    ..._teamSection(state),
    const SizedBox(height: AppDimens.paddingX18),
    ..._matchDetailsSection(state),
    const SizedBox(height: AppDimens.paddingX18),
    ..._matchPreviewSection(state),
  ];

  /// Team picker. Shared by step one and the summary's "Team" edit sheet.
  List<Widget> _teamSection(OpponentMatchState state) => <Widget>[
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
  ];

  /// Match type + opponent level. Shared by step one and the summary's "Match"
  /// edit sheet.
  List<Widget> _matchDetailsSection(OpponentMatchState state) => <Widget>[
    const OpponentSectionLabel('Match format'),
    OpponentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OpponentFieldLabel('Match Type'),
          // Formats come from `/match-formate` because the request payload
          // carries `match_format_id` — there is no id to send for a locally
          // defined 5v5/6v6/7v7.
          BlocBuilder<PublicCourtOptionsBloc, PublicCourtOptionsState>(
            bloc: _optionsBloc,
            builder: (context, optionsState) {
              final formats = optionsState.matchFormats;

              if (formats.isEmpty) {
                return optionsState.isLoadingMatchFormats
                    ? const _PillRowLoading()
                    : _InlineRetry(
                        message: 'Could not load match types.',
                        onRetry: () => _optionsBloc.add(
                          const FetchPublicMatchFormatsEvent(),
                        ),
                      );
              }

              return _PillRow(
                children: formats
                    .map(
                      (f) => OpponentPillChip(
                        label: f.name,
                        active: _resolveFormat(formats)?.id == f.id,
                        padding: _kPillRowPadding,
                        onTap: () => setState(() => _format = f),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: AppDimens.paddingX14),
          const OpponentFieldLabel('Opponent Level'),
          // Same row treatment and the same pill height as Match Type, so the
          // two fields sit on a shared grid instead of looking like unrelated
          // controls that happen to share a card.
          _PillRow(
            children: _levelOptions(state)
                .map(
                  (l) => OpponentPillChip(
                    label: l.name,
                    active: _resolveLevel(_levelOptions(state)) == l,
                    padding: _kPillRowPadding,
                    onTap: () => setState(() => _level = l),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  ];

  /// Reads back the three answers step one owns, so the step ends on a
  /// statement instead of trailing off after the last pill row.
  List<Widget> _matchPreviewSection(OpponentMatchState state) => <Widget>[
    const OpponentSectionLabel('Match preview'),
    OpponentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _MiniLine(
            icon: Icons.shield_outlined,
            text: _team == null
                ? 'No team selected yet'
                : '${_team!.name} · ${_team!.players.length} '
                      '${_team!.players.length == 1 ? 'player' : 'players'}',
          ),
          const SizedBox(height: AppDimens.paddingX8),
          _MiniLine(
            icon: Icons.sports_soccer_rounded,
            text: <String>[
              _formatLabel,
              _resolveLevel(_levelOptions(state)).name,
            ].where((String s) => s.trim().isNotEmpty).join(' · '),
          ),
          const SizedBox(height: AppDimens.paddingX8),
          const _MiniLine(
            icon: Icons.schedule_outlined,
            text: 'Date, time and venue are set on the next step',
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
    ..._venueSection(),
  ];

  /// The whole venue branch — arrangement, then whichever form it opens.
  /// Shared by step two and the summary's "Kickoff"/"Venue" edit sheet.
  List<Widget> _venueSection() => <Widget>[
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
          when: _kickoffWhen,
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
    const SizedBox(height: AppDimens.paddingX14),
    const OpponentSectionLabel('Booked date & time'),
    OpponentCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          OpponentPickerRow(
            icon: Icons.calendar_month_outlined,
            label: StringConstants.matchDate,
            value: OpponentFmt.shortDate(_date),
            onTap: _pickDate,
          ),
          const OpponentRowDivider(),
          OpponentPickerRow(
            icon: Icons.play_circle_outline,
            label: StringConstants.startTime,
            value: OpponentFmt.time(_externalStart),
            onTap: _pickExternalStart,
          ),
          const OpponentRowDivider(),
          OpponentPickerRow(
            icon: Icons.stop_circle_outlined,
            label: StringConstants.endTime,
            value: OpponentFmt.time(_externalEnd),
            onTap: _pickExternalEnd,
          ),
        ],
      ),
    ),
    if (_submitted && !_externalWindowValid) ...<Widget>[
      const SizedBox(height: AppDimens.paddingX6),
      Padding(
        padding: const EdgeInsets.only(left: AppDimens.paddingX4),
        child: Text(
          'The end time has to be after the start time.',
          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            color: LightColor.redColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  ];

  /// Start of the externally booked window. Nudges the end along so the window
  /// stays valid — an hour after the new start, the usual court slot.
  Future<void> _pickExternalStart() async {
    final TimeOfDay? picked = await customCupertinoTimePicker(
      context,
      StringConstants.startTime,
      initialTime: _externalStart,
    );
    if (picked == null) return;
    setState(() {
      _externalStart = picked;
      if (!_externalWindowValid) {
        _externalEnd = TimeOfDay(
          hour: (picked.hour + 1) % 24,
          minute: picked.minute,
        );
      }
    });
  }

  Future<void> _pickExternalEnd() async {
    final TimeOfDay? picked = await customCupertinoTimePicker(
      context,
      StringConstants.endTime,
      initialTime: _externalEnd,
    );
    if (picked != null) setState(() => _externalEnd = picked);
  }

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
        when: _kickoffWhen,
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
    ..._costSection(),
  ];

  /// The split rule card. Shared by step three and the summary's "Cost split"
  /// edit sheet.
  List<Widget> _costSection() => <Widget>[
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
    final int totalFee = cost.courtFee;
    final String feeLabel = cost.hasCourtFee
        ? '${OpponentFmt.npr(totalFee)} total'
        : 'Court fee ${StringConstants.courtFeeNotSetYet.toLowerCase()}';
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
              onEdit: _editTeam,
            ),
            const SizedBox(height: AppDimens.paddingX10),
            _SummaryRow(
              icon: Icons.sports_soccer_rounded,
              label: 'Match',
              value: '$_formatLabel · ${level.name}',
              onEdit: _editMatchDetails,
            ),
            const SizedBox(height: AppDimens.paddingX10),
            _SummaryRow(
              icon: Icons.schedule_outlined,
              label: 'Kickoff',
              value:
                  '$_kickoffWhen'
                  '${_slotLabel.isEmpty ? '' : ' · $_slotLabel'}',
              onEdit: _editVenue,
            ),
            const SizedBox(height: AppDimens.paddingX10),
            _SummaryRow(
              icon: Icons.location_on_outlined,
              label: 'Venue',
              value: _venueLabelText.isEmpty ? 'Not set' : _venueLabelText,
              onEdit: _editVenue,
            ),
            const SizedBox(height: AppDimens.paddingX10),
            _SummaryRow(
              icon: Icons.payments_outlined,
              label: 'Cost split',
              value:
                  '$feeLabel · '
                  '${cost.isResultBased ? 'Loser pays $_loserPercent%' : 'You pay ${cost.myPct ?? 0}%'}',
              onEdit: _editCostSplit,
            ),
          ],
        ),
      ),
      const SizedBox(height: AppDimens.paddingX12),
      OpponentCard(
        child: Text(
          'After publishing, the request becomes visible to all eligible '
          'teams and their invitations arrive under My Requests.',
          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
            height: 1.4,
          ),
        ),
      ),
    ];
  }
}

/// One summary row's controls, hosted on their own route.
///
/// It renders the wizard's own section builders — nothing is duplicated — and
/// rebuilds from [revision] whenever the page's state changes, since a page
/// rebuild does not reach a sheet route. Save runs the step endpoint that owns
/// these fields and pops only on success.
class _EditSheet extends StatefulWidget {
  const _EditSheet({
    required this.title,
    required this.icon,
    required this.revision,
    required this.body,
    required this.save,
    this.validate,
  });

  final String title;
  final IconData icon;
  final ValueListenable<int> revision;
  final List<Widget> Function(OpponentMatchState state) body;
  final Future<bool> Function() save;

  /// Returns why the change cannot be saved yet, or null when it can.
  final String? Function()? validate;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  bool _saving = false;

  Future<void> _save() async {
    final String? problem = widget.validate?.call();
    if (problem != null) {
      AppUtils().showSnackBar(context, MsgType.info, problem);
      return;
    }
    setState(() => _saving = true);
    final bool ok = await widget.save();
    if (!mounted) return;
    setState(() => _saving = false);
    // The save reports its own failure; keep the sheet up so the change is not
    // silently lost.
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          // Tall enough for the venue branch, short enough to still read as a
          // sheet over the summary it edits.
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: AppDimens.paddingX12),
              Container(
                width: AppDimens.sizeX36,
                height: AppDimens.sizeX4,
                decoration: BoxDecoration(
                  color: LightColor.dividerColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX4),
                ),
              ),
              Padding(
                padding: AppUtils().getPadding(
                  symmetricHorizontal: AppDimens.paddingX20,
                  symmetricVertical: AppDimens.paddingX14,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      widget.icon,
                      size: AppDimens.sizeX20,
                      color: LightColor.secondaryColor,
                    ),
                    const SizedBox(width: AppDimens.paddingX10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: textTheme.bodyTextLarge?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        size: AppDimens.sizeX20,
                        color: LightColor.iconGrey,
                      ),
                      tooltip: StringConstants.cancel,
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                color: LightColor.dividerColor,
              ),
              Flexible(
                child: BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
                  builder: (BuildContext context, OpponentMatchState state) =>
                      ValueListenableBuilder<int>(
                        valueListenable: widget.revision,
                        builder: (BuildContext context, _, _) => ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: AppUtils().getPadding(
                            symmetricHorizontal: AppDimens.paddingX20,
                            top: AppDimens.paddingX16,
                            bottom: AppDimens.paddingX16,
                          ),
                          shrinkWrap: true,
                          children: widget.body(state),
                        ),
                      ),
                ),
              ),
              Padding(
                padding: AppUtils().getPadding(
                  symmetricHorizontal: AppDimens.paddingX20,
                  top: AppDimens.paddingX8,
                  bottom: AppDimens.paddingX16,
                ),
                child: CustomButton(
                  text: StringConstants.saveChanges,
                  icon: Icons.check_rounded,
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

/// Padding for a pill in a [_PillRow], where the column already sets the
/// width — kept tight so a long label has room before it ellipsises.
const EdgeInsets _kPillRowPadding = EdgeInsets.symmetric(
  horizontal: AppDimens.paddingX6,
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

/// Options across one row, every pill the same width.
///
/// A [Wrap] sized each pill to its label, so `5v5 6v6 7v7` and
/// `Beginner Intermediate Advanced` came out as two ragged rows that did not
/// line up with each other. Equal columns make the two fields read as one
/// block, and a long label ellipsises inside its share rather than pushing the
/// row onto a second line.
///
/// Falls back to [_PillWrap] past [_maxInRow] options, where equal columns
/// would be too narrow to read — the level list comes from the server, so the
/// count is not guaranteed.
class _PillRow extends StatelessWidget {
  const _PillRow({required this.children});

  final List<Widget> children;

  static const int _maxInRow = 4;

  @override
  Widget build(BuildContext context) {
    if (children.length > _maxInRow) return _PillWrap(children: children);

    return Row(
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: AppDimens.paddingX8),
          Expanded(child: children[i]),
        ],
      ],
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
    return Container(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX12,
      ),
      color: LightColor.cardColor,
      child: Row(
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
                onTap: step.index <= current.index ? () => onTap(step) : null,
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
              ? Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: LightColor.inverseTextColor,
                )
              : Text(
                  '${step.index + 1}',
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: active
                        ? LightColor.inverseTextColor
                        : LightColor.hintTextColor,
                  ),
                ),
        ),
        const SizedBox(height: AppDimens.sizeX4),
        // The full name lives here now that the "Step 3 of 4 · …" line is gone.
        // Two lines, because a column is roughly a quarter of the width.
        Text(
          step.title,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMiniSubTitle?.copyWith(
            color: color,
            height: 1.25,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Placeholder occupying a [_PillRow]'s height while its options load, so the
/// card does not jump when they arrive.
class _PillRowLoading extends StatelessWidget {
  const _PillRowLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.sizeX40,
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: AppDimens.sizeX18,
        height: AppDimens.sizeX18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(LightColor.secondaryColor),
        ),
      ),
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
    this.isBusy = false,
  });

  final String text;
  final IconData icon;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String backText;

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
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
            color: LightColor.shadowOf(0.12),
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
                  onPressed: isBusy ? null : onBack,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: LightColor.dividerColor),
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
                child: CustomButton(
                  text: text,
                  icon: icon,
                  isLoading: isBusy,
                  onPressed: isBusy ? null : onNext,
                ),
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
                Icon(
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
          Icon(
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
        Icon(
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
