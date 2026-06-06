import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/opponent_match/data/repositories/opponent_match_repository_impl.dart';
import 'package:hamro_footsall/features/opponent_match/domain/usecase/opponent_match_usecase.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/pages/create_opponent_request_page.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_requests_view.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_teams_view.dart';

/// Requests come first — sending one is the primary action (via the FAB);
/// team management lives on its own tab.
enum _OpponentTab { requests, teams }

extension on _OpponentTab {
  String get label => switch (this) {
    _OpponentTab.requests => 'Requests',
    _OpponentTab.teams => 'My Teams',
  };
}

class OpponentMatchScreen extends StatelessWidget {
  const OpponentMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OpponentMatchBloc(
              OpponentMatchUseCase(OpponentMatchRepositoryImpl()),
            )
            ..add(const LoadTeamsEvent())
            ..add(const LoadVenuesEvent())
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

class _OpponentMatchViewState extends State<_OpponentMatchView> {
  _OpponentTab _tab = _OpponentTab.requests;
  RequestFilter _requestFilter = RequestFilter.all;

  Future<void> _openCreateRequest() async {
    final bloc = context.read<OpponentMatchBloc>();
    // Sending a request needs a team — steer the user to create one first.
    if (bloc.state.teams.isEmpty) {
      setState(() => _tab = _OpponentTab.teams);
      _showSnack('Create a team first, then send a request.');
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
    setState(() {
      _tab = _OpponentTab.requests;
      _requestFilter = RequestFilter.settled;
    });
    _showSnack('Request sent successfully');
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
    if (_tab == _OpponentTab.teams) {
      final total = state.teams.length;
      return '$total ${total == 1 ? 'team' : 'teams'}';
    }
    final total = state.requests.length;
    final open = state.openRequestCount;
    return '$total ${total == 1 ? 'request' : 'requests'}'
        '${open > 0 ? ' · $open open' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Opponent Match'),
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
            'New Request',
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
                SizedBox(
                  height: AppDimens.sizeX32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: AppUtils().getPadding(
                      symmetricHorizontal: AppDimens.paddingX20,
                    ),
                    itemCount: _OpponentTab.values.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppDimens.paddingX8),
                    itemBuilder: (context, index) {
                      final tab = _OpponentTab.values[index];
                      return OpponentCountChip(
                        label: tab.label,
                        count: tab == _OpponentTab.requests
                            ? state.requests.length
                            : state.teams.length,
                        isSelected: tab == _tab,
                        filled: true,
                        onTap: () {
                          if (_tab != tab) setState(() => _tab = tab);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX10),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    child: _tab == _OpponentTab.requests
                        ? _RequestsTabBody(
                            key: const ValueKey('requests'),
                            state: state,
                            filter: _requestFilter,
                            onFilter: (f) =>
                                setState(() => _requestFilter = f),
                          )
                        : _TeamsTabBody(
                            key: const ValueKey('teams'),
                            state: state,
                          ),
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
    super.key,
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
  const _TeamsTabBody({super.key, required this.state});

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
              text: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
