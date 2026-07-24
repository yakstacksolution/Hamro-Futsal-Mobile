import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_confirm_dialog.dart';
import 'package:hamro_footsall/features/opponent_match/data/repositories/opponent_match_repository_impl.dart';
import 'package:hamro_footsall/features/opponent_match/domain/usecase/opponent_match_usecase.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/pages/create_opponent_request_page.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_requests_view.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_sheets.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_teams_view.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class OpponentMatchScreen extends StatelessWidget {
  const OpponentMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OpponentMatchBloc(OpponentMatchUseCase(OpponentMatchRepositoryImpl()))
            ..add(const LoadTeamsEvent())
            ..add(const LoadVenuesEvent())
            ..add(const LoadPositionsEvent())
            ..add(const LoadOpponentLevelsEvent())
            ..add(const LoadOpponentRequestsEvent()),
      child: const _OpponentMatchView(),
    );
  }
}

class _OpponentMatchView extends StatefulWidget {
  const _OpponentMatchView();

  @override
  State<_OpponentMatchView> createState() => _OpponentMatchViewState();
}

class _OpponentMatchViewState extends State<_OpponentMatchView>
    with SingleTickerProviderStateMixin {
  // Requests come first — sending one is the primary action (via the FAB);
  // team management lives on its own tab.
  late final TabController _tabCtrl;
  RequestFilter _requestFilter = RequestFilter.all;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this)
      // Rebuild so the subtitle and tab badges track the active tab,
      // including swipes on the TabBarView.
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _openCreateRequest() async {
    final bloc = context.read<OpponentMatchBloc>();
    // Sending a request needs a team — steer the user to create one first.
    if (bloc.state.teams.isEmpty) {
      if (bloc.state.teamsStatus == OpponentMatchStatus.loading ||
          bloc.state.teamsStatus == OpponentMatchStatus.initial) {
        _showSnack('Your teams are still loading — try again in a moment.');
        return;
      }
      final bool create = await showConfirmDialog(
        context: context,
        title: StringConstants.createYourTeamFirst,
        message: StringConstants.youNeedATeamToChallengeOpponents,
        confirmText: StringConstants.createTeam,
        icon: Icons.groups_2_outlined,
      );
      if (!create || !mounted) return;
      _tabCtrl.animateTo(1);
      _openCreateTeamSheet(bloc);
      return;
    }
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        // Share the bloc with the new route so the form reads teams/venues
        // and dispatches the send event on the same instance.
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const CreateOpponentRequestPage(),
        ),
      ),
    );
    if (sent != true || !mounted) return;
    // The request I just sent lands in "My Requests" as pending.
    setState(() => _requestFilter = RequestFilter.mine);
    _tabCtrl.animateTo(0);
    _showSnack('Request sent successfully');
  }

  /// Same create-team sheet the Teams tab uses (`OpponentTeamsView`).
  void _openCreateTeamSheet(OpponentMatchBloc bloc) {
    showModalBottomSheet(
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

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
              color: LightColor.inverseTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: LightColor.secondaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
          margin: AppUtils().getMargin(
            horizontal: AppDimens.paddingX16,
            vertical: AppDimens.paddingX12,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  String _subtitle(OpponentMatchState state) {
    if (_tabCtrl.index == 1) {
      final total = state.teams.length;
      return '$total ${total == 1 ? 'team' : 'teams'}';
    }
    final total = state.requests.length;
    final open = state.openRequestCount;
    return '$total ${total == 1 ? 'request' : 'requests'}'
        '${open > 0 ? ' · $open open' : ''}';
  }

  /// Segmented pill tab bar: a soft rounded track with a sliding filled
  /// indicator and a live count badge inside each tab.
  Widget _tabBar(OpponentMatchState state) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(symmetricHorizontal: AppDimens.paddingX20),
      child: Container(
        height: AppDimens.sizeX46,
        padding: AppUtils().getPadding(all: AppDimens.paddingX4),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          border: Border.all(color: LightColor.dividerColor),
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicator: BoxDecoration(
            color: LightColor.secondaryColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            boxShadow: [
              BoxShadow(
                color: LightColor.secondaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          splashBorderRadius: BorderRadius.circular(AppDimens.radiusX10),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelColor: LightColor.whiteColor,
          unselectedLabelColor: LightColor.secondaryTextColor,
          labelStyle: textTheme.bodyTextSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: textTheme.bodyTextSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            _tabItem(
              label: StringConstants.requests,
              count: state.requests.length,
              selected: _tabCtrl.index == 0,
            ),
            _tabItem(
              label: StringConstants.myTeams,
              count: state.teams.length,
              selected: _tabCtrl.index == 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem({
    required String label,
    required int count,
    required bool selected,
  }) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Tab(
      height: AppDimens.sizeX36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: AppDimens.paddingX6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: AppUtils().getPadding(
              symmetricHorizontal: AppDimens.paddingX6,
              symmetricVertical: AppDimens.paddingX2,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? LightColor.whiteColor.withValues(alpha: 0.22)
                  : LightColor.dividerColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            ),
            child: Text(
              '$count',
              style: textTheme.bodyTextSmall?.copyWith(
                fontSize: AppDimens.fontBodySubTitle,
                fontWeight: FontWeight.w700,
                color: selected
                    ? LightColor.whiteColor
                    : LightColor.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.opponentMatch),
      floatingActionButton: SizedBox(
        height: 44,
        child: FloatingActionButton.extended(
          onPressed: _openCreateRequest,
          backgroundColor: LightColor.secondaryColor,
          foregroundColor: LightColor.whiteColor,
          elevation: 0,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const StadiumBorder(),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(
            'Find an Opponent',
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.whiteColor,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocConsumer<OpponentMatchBloc, OpponentMatchState>(
          // Surface mutation errors (create team, send request…) as a snack
          // without disturbing the page.
          listenWhen: (prev, curr) =>
              curr.errorMessage != null &&
              prev.errorMessage != curr.errorMessage,
          listener: (context, state) => _showSnack(state.errorMessage!),
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: AppUtils().getPadding(
                    symmetricHorizontal: AppDimens.paddingX20,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      _subtitle(state),
                      key: ValueKey(_subtitle(state)),
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(color: LightColor.secondaryTextColor),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX12),
                _tabBar(state),
                const SizedBox(height: AppDimens.paddingX10),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _RequestsTabBody(
                        state: state,
                        filter: _requestFilter,
                        onFilter: (f) => setState(() => _requestFilter = f),
                      ),
                      _TeamsTabBody(state: state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Requests tab wrapper: spinner / retry around [OpponentRequestsView].
class _RequestsTabBody extends StatelessWidget {
  const _RequestsTabBody({
    required this.state,
    required this.filter,
    required this.onFilter,
  });

  final OpponentMatchState state;
  final RequestFilter filter;
  final ValueChanged<RequestFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    if (state.requestsStatus == OpponentMatchStatus.initial ||
        state.requestsStatus == OpponentMatchStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: LightColor.secondaryColor),
      );
    }
    if (state.requestsStatus == OpponentMatchStatus.failure &&
        state.requests.isEmpty) {
      return _LoadError(
        message: state.errorMessage ?? 'Could not load opponent requests.',
        onRetry: () => context.read<OpponentMatchBloc>().add(
          const LoadOpponentRequestsEvent(),
        ),
      );
    }
    return OpponentRequestsView(filter: filter, onFilter: onFilter);
  }
}

/// Teams tab wrapper: spinner / retry around [OpponentTeamsView].
class _TeamsTabBody extends StatelessWidget {
  const _TeamsTabBody({required this.state});

  final OpponentMatchState state;

  @override
  Widget build(BuildContext context) {
    if (state.teamsStatus == OpponentMatchStatus.initial ||
        state.teamsStatus == OpponentMatchStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: LightColor.secondaryColor),
      );
    }
    if (state.teamsStatus == OpponentMatchStatus.failure &&
        state.teams.isEmpty) {
      return _LoadError(
        message: state.errorMessage ?? 'Could not load your teams.',
        onRetry: () => context.read<OpponentMatchBloc>()
          ..add(const LoadTeamsEvent())
          ..add(const LoadVenuesEvent()),
      );
    }
    return const OpponentTeamsView();
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: AppUtils().getPadding(all: AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: LightColor.hintTextColor,
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),
            CustomButton(
              text: StringConstants.retry,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
