import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_date_picker.dart';
import 'package:hamro_footsall/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/domain/entities/opponent_match_entities.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/models/opponent_cost_split.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_cost_split_card.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_sheets.dart';

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
  final _messageCtrl = TextEditingController(
    text: 'Looking for a friendly competitive futsal match.',
  );

  TeamModel? _team;
  MatchFormat _format = MatchFormat.fiveASide;

  /// Selected opponent level from `/opponent-levels`; defaults to the first
  /// fetched level (see [_resolveLevel]) until the user picks one.
  OpponentLevelModel? _level;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  String? _venue;
  SplitMode _split = SplitMode.even;
  SplitBasis _basis = SplitBasis.teams;
  int _myPercent = 50;
  int _loserPercent = 70;
  bool _submitted = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  OpponentCostSplit get _cost => OpponentCostSplit(
    format: _format,
    split: _split,
    basis: _basis,
    myPercent: _myPercent,
    loserPercent: _loserPercent,
    playerCount: _team?.players.length ?? 0,
  );

  Future<void> _pickDate() async {
    final picked = await showCustomDatePicker(
      context,
      title: 'Match date',
      initialDate: _date,
      minDate: DateTime.now().subtract(const Duration(days: 1)),
      maxDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: LightColor.secondaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _pickVenue(List<String> venues, String? selected) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.transparentColor,
      builder: (ctx) => VenuePickerSheet(
        venues: venues,
        selected: selected,
        onSelect: (v) {
          setState(() => _venue = v);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  /// Levels come from the API; until they land (or if the fetch failed) the
  /// static defaults keep the picker usable.
  List<OpponentLevelModel> _levelOptions(OpponentMatchState state) =>
      state.levels.isEmpty ? OpponentLevelModel.defaults : state.levels;

  /// The active selection — the user's pick, or the first option.
  OpponentLevelModel _resolveLevel(List<OpponentLevelModel> levels) =>
      _level ?? levels.first;

  void _send(String? venue) {
    setState(() => _submitted = true);
    final team = _team;
    if (team == null || venue == null) return;
    HapticFeedback.mediumImpact();
    final state = context.read<OpponentMatchBloc>().state;
    final level = _resolveLevel(_levelOptions(state));
    final cost = _cost;
    final dateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    context.read<OpponentMatchBloc>().add(
      SendOpponentRequestEvent(
        CreateOpponentRequestEntity(
          team: team.name,
          dateTime: dateTime,
          summary:
              '${level.name} · ${_format.label} · '
              '${team.players.length} players · ${cost.shareSummary}',
          venue: venue,
          slot: OpponentFmt.slot(_time),
          totalFee: cost.courtFee,
          yourShare: cost.isResultBased ? cost.loserShare : cost.yourShare,
          myPct: cost.myPct,
          message: _messageCtrl.text.trim(),
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'New Request'),
      body: SafeArea(
        top: false,
        child: BlocBuilder<OpponentMatchBloc, OpponentMatchState>(
          builder: (context, state) {
            // Venue defaults to the first fetched one until the user picks.
            final venue =
                _venue ?? (state.venues.isEmpty ? null : state.venues.first);

            return ListView(
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
                    labelText: 'Your team',
                    hintText: 'Select your team',
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
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      OpponentPickerRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Date',
                        value: OpponentFmt.shortDate(_date),
                        onTap: _pickDate,
                      ),
                      const OpponentRowDivider(),
                      OpponentPickerRow(
                        icon: Icons.schedule_outlined,
                        label: 'Time',
                        value: OpponentFmt.time(_time),
                        onTap: _pickTime,
                      ),
                      const OpponentRowDivider(),
                      OpponentPickerRow(
                        icon: Icons.location_on_outlined,
                        label: 'Venue',
                        value: venue ?? 'Select a venue',
                        onTap: () => _pickVenue(state.venues, venue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX18),

                const OpponentSectionLabel('Message'),
                OpponentCard(
                  child: CustomTextField(
                    controller: _messageCtrl,
                    labelText: 'Message',
                    hintText: 'Message',
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
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomBar(
        onSend: () {
          final state = context.read<OpponentMatchBloc>().state;
          _send(_venue ?? (state.venues.isEmpty ? null : state.venues.first));
        },
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onSend});

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
          child: CustomButton(
            text: 'Send Opponent Request',
            icon: Icons.send_rounded,
            onPressed: onSend,
          ),
        ),
      ),
    );
  }
}
