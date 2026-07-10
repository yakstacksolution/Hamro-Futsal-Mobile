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
import 'package:hamro_footsall/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/core/widgets/custom_time_picker_bottom_sheet.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_draft.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/slots_selection_route_args.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/domain/entities/opponent_match_entities.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/models/opponent_cost_split.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_cost_split_card.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_venues_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_venue/public_venue_bloc.dart';

enum _VenuePlan { alreadyBooked, findAvailable }

/// Full-page form to compose and send one opponent request.
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
  final _preferredVenueCtrl = TextEditingController();
  late final PublicVenueBloc _publicVenueBloc;

  TeamModel? _team;
  MatchFormat _format = MatchFormat.fiveASide;

  /// Selected opponent level from `/opponent-levels`; defaults to the first
  /// fetched level (see [_resolveLevel]) until the user picks one.
  OpponentLevelModel? _level;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  _VenuePlan _venuePlan = _VenuePlan.alreadyBooked;
  PublicListingVenueModel? _preferredVenue;
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
    _preferredVenueCtrl.dispose();
    _publicVenueBloc.close();
    super.dispose();
  }

  /// The court fee the requester says they paid — already-booked path only.
  int? get _enteredCourtFee => int.tryParse(_courtFeeCtrl.text.trim());

  OpponentCostSplit get _cost => OpponentCostSplit(
    format: _format,
    split: _split,
    basis: _basis,
    myPercent: _myPercent,
    loserPercent: _loserPercent,
    playerCount: _team?.players.length ?? 0,
    // For an externally-booked court the requester's entered fee is the real
    // amount; the format table is only the find-available fallback.
    overrideCourtFee: _venuePlan == _VenuePlan.alreadyBooked
        ? _enteredCourtFee
        : null,
  );

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

  /// Levels come from the API; until they land (or if the fetch failed) the
  /// static defaults keep the picker usable.
  List<OpponentLevelModel> _levelOptions(OpponentMatchState state) =>
      state.levels.isEmpty ? OpponentLevelModel.defaults : state.levels;

  /// The active selection — the user's pick, or the first option.
  OpponentLevelModel _resolveLevel(List<OpponentLevelModel> levels) =>
      _level ?? levels.first;

  void _selectVenuePlan(_VenuePlan plan) {
    setState(() => _venuePlan = plan);
    if (plan == _VenuePlan.findAvailable &&
        _publicVenueBloc.state.status == PublicVenueStatus.idle) {
      _publicVenueBloc.add(const FetchPublicVenuesEvent());
    }
  }

  CreateOpponentRequestEntity _request({
    required String venue,
    DateTime? bookedDateTime,
    String? bookedSlot,
    int? bookedTotalFee,
    String? bookedEndTime,
  }) {
    final TeamModel team = _team!;
    final state = context.read<OpponentMatchBloc>().state;
    final level = _resolveLevel(_levelOptions(state));
    final cost = _cost;
    final int totalFee = bookedTotalFee ?? cost.courtFee;
    final int yourShare = cost.isResultBased
        ? (totalFee * _loserPercent / 100).round()
        : (totalFee * (cost.myPct ?? 0) / 100).round();
    final dateTime =
        bookedDateTime ??
        DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
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
      claimedTotalFee: _venuePlan == _VenuePlan.alreadyBooked
          ? _enteredCourtFee
          : null,
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

  Future<void> _continue() async {
    setState(() => _submitted = true);
    if (_venuePlan == _VenuePlan.findAvailable &&
        (_publicVenueBloc.state.status == PublicVenueStatus.idle ||
            _publicVenueBloc.state.status == PublicVenueStatus.loading)) {
      AppUtils().showSnackBar(
        context,
        MsgType.info,
        'Available venues are still loading.',
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_venuePlan == _VenuePlan.alreadyBooked) {
      final String venue = <String>[
        _venueNameCtrl.text.trim(),
        _venueLocationCtrl.text.trim(),
      ].where((String value) => value.isNotEmpty).join(', ');
      _send(_request(venue: venue));
      return;
    }

    final PublicListingVenueModel? venue = _preferredVenue;
    if (venue == null || venue.id == null) return;
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

    final DateTime bookedDateTime = _bookingDateTime(booking);
    final String? endTime = booking.endTime?.trim();
    final String slot = endTime == null || endTime.isEmpty
        ? booking.selectedTime
        : '${booking.selectedTime} – $endTime';
    _send(
      _request(
        venue: _venueLabel(venue, courtName: booking.courtName),
        bookedDateTime: bookedDateTime,
        bookedSlot: slot,
        bookedTotalFee: booking.subtotal > 0 ? booking.subtotal.round() : null,
        bookedEndTime: booking.apiEndTime,
      ),
    );
  }

  void _send(CreateOpponentRequestEntity request) {
    HapticFeedback.mediumImpact();
    context.read<OpponentMatchBloc>().add(SendOpponentRequestEvent(request));
    Navigator.of(context).pop(true);
  }

  String _apiTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  DateTime _bookingDateTime(BookingDraft booking) {
    final String raw = booking.apiTime ?? '';
    final List<String> parts = raw.split(':');
    final int hour = parts.isEmpty
        ? _time.hour
        : int.tryParse(parts[0]) ?? _time.hour;
    final int minute = parts.length < 2
        ? _time.minute
        : int.tryParse(parts[1]) ?? _time.minute;
    return DateTime(
      booking.selectedDate.year,
      booking.selectedDate.month,
      booking.selectedDate.day,
      hour,
      minute,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.newRequest),
      body: SafeArea(
        top: false,
        child: BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: AppUtils().getPadding(
                  symmetricHorizontal: AppDimens.paddingX20,
                  top: AppDimens.paddingX6,
                  bottom: AppDimens.paddingX28,
                ),
                children: [
                  const OpponentSectionLabel('Team'),
                  OpponentCard(
                    child: CustomDropdownField<TeamModel>(
                      labelText: StringConstants.yourTeam,
                      hintText: StringConstants.selectYourTeam,
                      icon: Icons.groups_2_outlined,
                      initialValue: _team,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      validator: (v) => v == null ? 'Pick a team' : null,
                      onChanged: (t) => setState(() => _team = t),
                      items: state.teams
                          .map(
                            (t) => DropdownMenuItem<TeamModel>(
                              value: t,
                              child: Text(
                                '${t.name} · ${t.players.length} players',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX18),

                  const OpponentSectionLabel('Match format'),
                  OpponentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const OpponentFieldLabel('Match Type'),
                        Row(
                          children: MatchFormat.values
                              .map(
                                (f) => Expanded(
                                  child: Padding(
                                    padding: AppUtils().getPadding(
                                      right: AppDimens.paddingX6,
                                    ),
                                    child: OpponentPillChip(
                                      label: f.label,
                                      active: _format == f,
                                      onTap: () => setState(() => _format = f),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: AppDimens.paddingX14),
                        const OpponentFieldLabel('Opponent Level'),
                        Row(
                          children: _levelOptions(state)
                              .map(
                                (l) => Expanded(
                                  child: Padding(
                                    padding: AppUtils().getPadding(
                                      right: AppDimens.paddingX6,
                                    ),
                                    child: OpponentPillChip(
                                      label: l.name,
                                      active:
                                          _resolveLevel(_levelOptions(state)) ==
                                          l,
                                      compact: true,
                                      onTap: () => setState(() => _level = l),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX18),

                  const OpponentSectionLabel('Schedule & venue'),
                  OpponentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const OpponentRowDivider(),
                        const SizedBox(height: AppDimens.paddingX12),
                        const OpponentFieldLabel('Venue arrangement'),
                        _VenuePlanOption(
                          title: 'I have already booked a venue',
                          subtitle: 'Add the venue name and match location.',
                          icon: Icons.event_available_outlined,
                          selected: _venuePlan == _VenuePlan.alreadyBooked,
                          onTap: () =>
                              _selectVenuePlan(_VenuePlan.alreadyBooked),
                        ),
                        const SizedBox(height: AppDimens.paddingX10),
                        _VenuePlanOption(
                          title: 'Find an available court slot',
                          subtitle:
                              'Choose a venue, select a live slot, and book it.',
                          icon: Icons.search_rounded,
                          selected: _venuePlan == _VenuePlan.findAvailable,
                          onTap: () =>
                              _selectVenuePlan(_VenuePlan.findAvailable),
                        ),
                        const SizedBox(height: AppDimens.paddingX14),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _venuePlan == _VenuePlan.alreadyBooked
                              ? Column(
                                  key: const ValueKey<String>('booked'),
                                  children: <Widget>[
                                    CustomTextField(
                                      controller: _venueNameCtrl,
                                      labelText: 'Venue name',
                                      hintText: 'Enter the booked venue',
                                      icon: Icons.stadium_outlined,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      autovalidateMode: _submitted
                                          ? AutovalidateMode.always
                                          : AutovalidateMode.disabled,
                                      validator: (String? value) =>
                                          value?.trim().isEmpty ?? true
                                          ? 'Enter the venue name'
                                          : null,
                                    ),
                                    const SizedBox(
                                      height: AppDimens.paddingX14,
                                    ),
                                    CustomTextField(
                                      controller: _venueLocationCtrl,
                                      labelText: 'Venue location',
                                      hintText: 'Area, city or full address',
                                      icon: Icons.location_on_outlined,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      autovalidateMode: _submitted
                                          ? AutovalidateMode.always
                                          : AutovalidateMode.disabled,
                                      validator: (String? value) =>
                                          value?.trim().isEmpty ?? true
                                          ? 'Enter the venue location'
                                          : null,
                                    ),
                                    const SizedBox(
                                      height: AppDimens.paddingX14,
                                    ),
                                    CustomTextField(
                                      controller: _courtFeeCtrl,
                                      labelText:
                                          StringConstants.totalCourtFeeRs,
                                      hintText: 'What you paid for the court',
                                      icon: Icons.payments_outlined,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      // The cost-split card recomputes from
                                      // the real fee as it's typed.
                                      onChanged: (_) => setState(() {}),
                                      autovalidateMode: _submitted
                                          ? AutovalidateMode.always
                                          : AutovalidateMode.disabled,
                                      validator: (String? value) =>
                                          (int.tryParse(value?.trim() ?? '') ??
                                                  0) <=
                                              0
                                          ? 'Enter the total court fee'
                                          : null,
                                    ),
                                  ],
                                )
                              : BlocBuilder<PublicVenueBloc, PublicVenueState>(
                                  key: const ValueKey<String>('available'),
                                  bloc: _publicVenueBloc,
                                  builder:
                                      (
                                        BuildContext context,
                                        PublicVenueState venueState,
                                      ) {
                                        if ((venueState.status ==
                                                    PublicVenueStatus.idle ||
                                                venueState.status ==
                                                    PublicVenueStatus
                                                        .loading) &&
                                            venueState.venues.isEmpty) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                AppDimens.paddingX12,
                                              ),
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            // Searchable picker — tapping
                                            // opens a filterable venue sheet.
                                            CustomTextField(
                                              controller: _preferredVenueCtrl,
                                              labelText: StringConstants
                                                  .preferredVenue,
                                              hintText: StringConstants
                                                  .searchVenueToCheckSlots,
                                              icon: Icons.stadium_outlined,
                                              suffixIcon: const Icon(
                                                Icons.search_rounded,
                                                color: LightColor
                                                    .secondaryTextColor,
                                              ),
                                              readOnly: true,
                                              // onTap: _pickPreferredVenue,
                                              autovalidateMode: _submitted
                                                  ? AutovalidateMode.always
                                                  : AutovalidateMode.disabled,
                                              validator: (_) =>
                                                  _preferredVenue == null
                                                  ? 'Select a venue'
                                                  : _preferredVenue!.id == null
                                                  ? 'This venue cannot be booked'
                                                  : null,
                                            ),
                                            if (venueState.status ==
                                                PublicVenueStatus
                                                    .failure) ...<Widget>[
                                              const SizedBox(
                                                height: AppDimens.paddingX8,
                                              ),
                                              TextButton.icon(
                                                onPressed: () =>
                                                    _publicVenueBloc.add(
                                                      const FetchPublicVenuesEvent(),
                                                    ),
                                                icon: const Icon(
                                                  Icons.refresh_rounded,
                                                ),
                                                label: Text(
                                                  venueState.errorMessage ??
                                                      'Could not load venues. Retry',
                                                ),
                                              ),
                                            ],
                                          ],
                                        );
                                      },
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX18),

                  const OpponentSectionLabel('Message'),
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
                    style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle
                        ?.copyWith(color: LightColor.hintTextColor),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomBar(
        text: _venuePlan == _VenuePlan.alreadyBooked
            ? StringConstants.sendOpponentRequest
            : 'Find available slots',
        icon: _venuePlan == _VenuePlan.alreadyBooked
            ? Icons.send_rounded
            : Icons.arrow_forward_rounded,
        onSend: _continue,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.text,
    required this.icon,
    required this.onSend,
  });

  final String text;
  final IconData icon;
  final VoidCallback onSend;

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
        child: SizedBox(
          height: AppDimens.sizeX54,
          width: double.infinity,
          child: CustomButton(text: text, icon: icon, onPressed: onSend),
        ),
      ),
    );
  }
}

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
                : LightColor.background,
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
                      : LightColor.cardColor,
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
