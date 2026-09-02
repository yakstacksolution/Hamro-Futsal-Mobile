import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/loading_widget.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/account/data/repositories/account_repository_impl.dart';
import 'package:hamro_futsal/features/account/domain/usecase/account_usecase.dart';
import 'package:hamro_futsal/features/account/presentation/bloc/account_bloc/account_bloc.dart';
import 'package:hamro_futsal/features/account/presentation/utils/account_ui_utils.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_loading_widgets.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_widgets.dart';
import 'package:hamro_futsal/features/account/presentation/pages/request_settlement_page.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AccountBloc(AccountUseCase(AccountRepositoryImpl()))
            ..add(const LoadAccountEvent()),
      child: const AccountView(),
    );
  }
}

@visibleForTesting
class AccountView extends StatelessWidget {
  const AccountView({super.key});

  void _pushDetail(BuildContext context, Widget page) {
    final bloc = context.read<AccountBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(value: bloc, child: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.financeAndPayouts),
      body: SafeArea(
        top: false,
        // The settlement form now stays open until the request resolves, so
        // this screen no longer needs an overlay to cover the gap.
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<AccountBloc, AccountState>(
      listenWhen: (prev, curr) => prev.submitStatus != curr.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == AccountStatus.success) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            StringConstants.commissionSettled,
          );
        } else if (state.submitStatus == AccountStatus.failure) {
          AppUtils().showSnackBar(
            context,
            MsgType.error,
            state.errorMessage ??
                StringConstants.couldNotSubmitSettlementRequest,
          );
        }
      },
      builder: (context, state) {
        if (state.summaryStatus == AccountStatus.loading && !state.refreshing) {
          return const AccountLoadingView();
        }
        if (state.summaryStatus == AccountStatus.failure) {
          return _AccountError(
            message: state.errorMessage,
            onRetry: () =>
                context.read<AccountBloc>().add(const LoadAccountEvent()),
          );
        }
        final summary = state.summary;
        // `actions.can_request_settlement` plus a non-zero requestable
        // amount is what the server will accept. The commission shown on
        // the hero is checked too — offering to pay NPR 0 makes no sense.
        final canSettle =
            summary.settlementEligible &&
            (summary.requestableAmount > 0 || summary.availableBalance > 0) &&
            summary.totalCommission > 0 &&
            !state.hasPendingSettlement &&
            state.submitStatus != AccountStatus.loading;
        final recent = state.entries.toList();
        final Widget balance = AccountBalanceCard(
          commissionPayable: summary.totalCommission,
          availableBalance: summary.availableBalance,
          totalEarned: summary.totalEarned,
          pendingClearance: summary.pendingClearance,
          onRequestSettlement: canSettle
              ? () => openSettlementSheet(context)
              : null,
          disabledReason: canSettle ? null : settlementBlockedReason(state),
        );
        final Widget shortcuts = _ShortcutsCard(
          state: state,
          onFutsalBreakdown: () =>
              _pushDetail(context, const _VenueBreakdownPage()),
          onSettlements: () => _pushDetail(context, const _SettlementsPage()),
        );
        final Widget activity = _ListCard(
          child: state.statementStatus == AccountStatus.loading
              ? const AccountListLoading(itemCount: 4)
              : recent.isEmpty
              ? const AccountEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No account activity yet',
                  body:
                      'Booking income, platform commission and payouts will appear here.',
                )
              : Column(
                  children: [
                    for (int i = 0; i < recent.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: AppDimens.paddingX20,
                          thickness: 1,
                          color: LightColor.dividerColor,
                        ),
                      AccountEntryTile(entry: recent[i]),
                    ],
                  ],
                ),
        );
        final Widget activityHeader = _RecentActivityHeader(
          onViewAll: () => _pushDetail(context, const _StatementPage()),
        );

        final bool desktop = context.isDesktop;
        final double horizontal = context.responsive<double>(
          mobile: AppDimens.paddingX20,
          tablet: AppDimens.paddingX32,
        );

        return RefreshIndicator(
          color: LightColor.brandTextColor,
          onRefresh: () async => context.read<AccountBloc>().add(
            const LoadAccountEvent(silent: true),
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              horizontal,
              AppDimens.paddingX16,
              horizontal,
              AppDimens.paddingX50,
            ),
            children: desktop
                // Balance, stats and the statement carry the page; the
                // shortcuts become a side column instead of a band the
                // reader has to scroll past.
                ? <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              balance,
                              const SizedBox(height: AppDimens.paddingX12),
                              AccountStatsRow(summary: summary),
                              const SizedBox(height: AppDimens.paddingX20),
                              activityHeader,
                              const SizedBox(height: AppDimens.paddingX10),
                              activity,
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimens.paddingX20),
                        SizedBox(
                          width: AppDimens.accountShortcutsColumnWidth,
                          child: shortcuts,
                        ),
                      ],
                    ),
                  ]
                : <Widget>[
                    balance,
                    const SizedBox(height: AppDimens.paddingX12),
                    AccountStatsRow(summary: summary),
                    const SizedBox(height: AppDimens.paddingX16),
                    shortcuts,
                    const SizedBox(height: AppDimens.paddingX20),
                    activityHeader,
                    const SizedBox(height: AppDimens.paddingX10),
                    activity,
                  ],
          ),
        );
      },
    );
  }
}

double _detailListInset(BuildContext context) {
  const double base = AppDimens.paddingX20;
  if (!context.isTabletOrWider) return base;
  final double slack =
      (context.screenWidth - AppDimens.accountListMaxWidth) / 2;
  return slack > base ? slack : AppDimens.paddingX32;
}

String settlementBlockedReason(AccountState state) {
  if (state.summary.settlementBlockingReason.isNotEmpty) {
    return state.summary.settlementBlockingReason;
  }
  if (state.hasPendingSettlement) {
    return 'A commission payment is already being verified.';
  }
  if (state.summary.totalCommission <= 0) {
    return StringConstants.noCommissionDue;
  }
  return 'Commission payment is not available right now.';
}

/// True while [openSettlementSheet] is between the first tap and the pay page
/// closing again. The flow awaits two network calls before it pushes, and the
/// button stays live across them, so without this a second tap fires the
/// preview again and stacks a duplicate page on the first.
bool _openingSettlementFlow = false;

Future<void> openSettlementSheet(
  BuildContext context, {
  VenueAccountModel? venue,
}) async {
  if (_openingSettlementFlow) return;
  _openingSettlementFlow = true;
  try {
    final bloc = context.read<AccountBloc>();
    if (bloc.state.settlementsPage == 0) {
      final counts = await bloc.useCase.getSettlements(page: 1, perPage: 20);
      if (!context.mounted) return;
      final bool pending = counts.fold(
        (_) => true,
        (page) => page.summary.inProgress > 0,
      );
      if (pending) {
        AppUtils().showSnackBar(
          context,
          MsgType.info,
          StringConstants.settlementAwaitingApproval,
        );
        return;
      }
    } else if (bloc.state.hasPendingSettlement) {
      AppUtils().showSnackBar(
        context,
        MsgType.info,
        StringConstants.settlementAwaitingApproval,
      );
      return;
    }
    final previewFuture = bloc.useCase.getSettlementPreview(venueId: venue?.id);
    final qrFuture = bloc.useCase.getQrCodes();
    final result = await previewFuture;
    final qrCodes = (await qrFuture).fold(
      (_) => const <SettlementQrCodeModel>[],
      (codes) => codes,
    );
    if (!context.mounted) return;
    final preview = result.fold((failure) {
      AppUtils().showSnackBar(context, MsgType.error, failure.errorMessage);
      return null;
    }, (p) => p);
    if (preview == null) return;
    final double commissionPayable =
        venue?.totalCommission ?? bloc.state.summary.totalCommission;
    final double totalEarned =
        venue?.totalEarned ?? bloc.state.summary.totalEarned;
    final bool blocked =
        preview.blockingReason.isNotEmpty ||
        (!preview.eligible && commissionPayable <= 0);
    if (blocked) {
      AppUtils().showSnackBar(
        context,
        MsgType.info,
        preview.blockingReason.isNotEmpty
            ? preview.blockingReason
            : StringConstants.noCommissionDue,
      );
      return;
    }
    // The page files the request itself and stays open until the outcome is
    // known, so there is nothing to dispatch here.
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider<AccountBloc>.value(
          value: bloc,
          child: RequestSettlementPage(
            preview: preview,
            venueName: venue?.name ?? '',
            commissionPayable: commissionPayable,
            totalEarned: totalEarned,
            qrCodes: qrCodes,
            venueId: venue?.id ?? preview.venue?.id,
          ),
        ),
      ),
    );
  } finally {
    _openingSettlementFlow = false;
  }
}

class _ShortcutsCard extends StatelessWidget {
  const _ShortcutsCard({
    required this.state,
    required this.onFutsalBreakdown,
    required this.onSettlements,
  });

  final AccountState state;
  final VoidCallback onFutsalBreakdown;
  final VoidCallback onSettlements;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    final venueCount =
        summary.sectionCount('breakdown') ?? summary.venues.length;
    final settlementCount =
        summary.sectionCount('settlements') ?? state.settlementCounts.total;
    final inProgress = state.settlementCounts.inProgress;
    final tiles = <Widget>[
      if (summary.venues.isNotEmpty || venueCount > 0)
        AccountNavTile(
          icon: Icons.stadium_outlined,
          title: 'Futsal breakdown',
          subtitle: '$venueCount ${venueCount == 1 ? 'futsal' : 'futsals'}',
          onTap: onFutsalBreakdown,
        ),
      AccountNavTile(
        icon: Icons.history_rounded,
        title: StringConstants.settlements,
        subtitle: settlementCount == 0
            ? 'No settlements yet'
            : inProgress > 0
            ? '$inProgress in progress · $settlementCount total'
            : '$settlementCount total',
        iconColor: LightColor.blueColor,
        onTap: onSettlements,
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: Column(
          children: [
            for (int i = 0; i < tiles.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: EdgeInsets.only(left: AppDimens.paddingX46),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: LightColor.dividerColor,
                  ),
                ),
              tiles[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentActivityHeader extends StatelessWidget {
  const _RecentActivityHeader({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            StringConstants.recentActivity,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        InkWell(
          onTap: onViewAll,
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingX4),
            child: Text(
              'View all',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.brandTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VenueBreakdownPage extends StatefulWidget {
  const _VenueBreakdownPage();

  @override
  State<_VenueBreakdownPage> createState() => _VenueBreakdownPageState();
}

class _VenueBreakdownPageState extends State<_VenueBreakdownPage> {
  @override
  void initState() {
    super.initState();
    // No-op in the bloc when a breakdown is already held.
    context.read<AccountBloc>().add(const LoadSettlementBreakdownEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Futsal Breakdown'),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            final venues = state.summary.venues;
            // Only a first load blanks the screen; a refetch keeps the held
            // rows visible underneath.
            if (state.breakdownStatus == AccountStatus.loading &&
                venues.isEmpty) {
              return const AccountListLoading(itemCount: 4);
            }
            if (state.breakdownStatus == AccountStatus.failure &&
                venues.isEmpty) {
              return _BreakdownError(
                message: state.errorMessage,
                onRetry: () => context.read<AccountBloc>().add(
                  const LoadSettlementBreakdownEvent(refresh: true),
                ),
              );
            }
            if (venues.isEmpty) {
              return const AccountEmptyState(
                icon: Icons.stadium_outlined,
                title: 'No futsals yet',
                body: 'Balances for each of your futsals will appear here.',
              );
            }
            return RefreshIndicator(
              color: LightColor.brandTextColor,
              onRefresh: () async => context.read<AccountBloc>().add(
                const LoadSettlementBreakdownEvent(refresh: true),
              ),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                // Capped and centred: a settlement/statement row is one line of
                // text, and stretching it across a wide window makes the label
                // and the amount unreadably far apart.
                padding: EdgeInsets.symmetric(
                  horizontal: _detailListInset(context),
                  vertical: AppDimens.paddingX20,
                ),
                itemCount: venues.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimens.paddingX12),
                itemBuilder: (context, index) {
                  final venue = venues[index];
                  // A settlement pays commission, so commission owed is the
                  // condition — not the balance. A futsal can sit on a healthy
                  // balance with nothing owed, and paying NPR 0 makes no sense.
                  final canSettle =
                      venue.settlementEligible &&
                      venue.totalCommission > 0 &&
                      !state.hasPendingSettlement &&
                      state.submitStatus != AccountStatus.loading;
                  return _VenueCard(
                    venue: venue,
                    onSettle: canSettle
                        ? () => openSettlementSheet(context, venue: venue)
                        : null,
                    // Explain a missing CTA rather than leaving a dead card.
                    disabledReason: canSettle
                        ? null
                        : state.hasPendingSettlement
                        ? 'A settlement request is already being processed.'
                        : venue.totalCommission <= 0
                        ? 'No commission due for this futsal yet.'
                        : 'Settlement is not available for this futsal yet.',
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Retry affordance for a failed breakdown fetch. The account screen's own
/// error banner cannot cover this — the request now happens on this screen.
class _BreakdownError extends StatelessWidget {
  const _BreakdownError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: AppDimens.sizeX32,
              color: LightColor.redColor,
            ),
            const SizedBox(height: AppDimens.paddingX12),
            Text(
              message ?? 'Could not load the futsal breakdown.',
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: AppDimens.sizeX16),
              label: Text(StringConstants.retry),
              style: TextButton.styleFrom(
                foregroundColor: LightColor.brandTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label/value line under a futsal's headline commission.
class _VenueFigureRow extends StatelessWidget {
  const _VenueFigureRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.primaryTextColor,
            fontSize: AppDimens.fontBodySubTitle,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({
    required this.venue,
    required this.onSettle,
    this.disabledReason,
  });

  final VenueAccountModel venue;
  final VoidCallback? onSettle;

  /// Shown in place of the CTA when this futsal cannot be settled yet.
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (venue.location.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        venue.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX8),
              // The commission is the headline: it is the figure the button
              // below pays. The balance it was charged from sits underneath as
              // context — leading with the balance invited reading it as the
              // amount due.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AccountFmt.npr(venue.totalCommission),
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: LightColor.brandTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    StringConstants.commissionPayable,
                    style: textTheme.bodyMiniSubTitle?.copyWith(
                      color: LightColor.hintTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
          const SizedBox(height: AppDimens.paddingX8),
          _VenueFigureRow(
            label: StringConstants.totalEarned,
            value: AccountFmt.npr(venue.totalEarned),
          ),
          const SizedBox(height: AppDimens.paddingX4),
          _VenueFigureRow(
            label: StringConstants.availableBalance,
            value: AccountFmt.npr(venue.availableBalance),
          ),
          if (venue.pendingClearance > 0) ...[
            const SizedBox(height: AppDimens.paddingX4),
            _VenueFigureRow(
              label: StringConstants.pendingClearance,
              value: AccountFmt.npr(venue.pendingClearance),
            ),
          ],
          if (onSettle == null && disabledReason != null) ...[
            const SizedBox(height: AppDimens.paddingX8),
            Text(
              disabledReason!,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
                fontSize: AppDimens.fontBodySubTitle,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (onSettle != null) ...[
            const SizedBox(height: AppDimens.paddingX10),
            SizedBox(
              width: double.infinity,
              height: AppDimens.sizeX36,
              child: OutlinedButton(
                onPressed: onSettle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: LightColor.brandTextColor,
                  side: BorderSide(color: LightColor.brandTextColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                  ),
                ),
                child: Text(
                  StringConstants.payCommission,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.brandTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Detail page: the full ledger.
/// Detail page: the full account ledger, paginated.
///
/// This screen owns the `/auth/settlement-recent-activity` request. The account
/// summary carries only a short preview of the same rows, so the full list is
/// not fetched until the reader asks for it.
class _StatementPage extends StatefulWidget {
  const _StatementPage();

  @override
  State<_StatementPage> createState() => _StatementPageState();
}

class _StatementPageState extends State<_StatementPage> {
  late final AccountBloc _bloc;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<AccountBloc>();
    // A no-op in the bloc when a page is already held.
    _bloc.add(const LoadRecentActivityEvent());
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Fetches ahead of the bottom so the next page is usually there on arrival.
  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final double remaining =
        _scrollCtrl.position.maxScrollExtent - _scrollCtrl.position.pixels;
    if (remaining < 400) _loadMore();
  }

  void _loadMore() {
    final state = _bloc.state;
    if (state.activityLoadingMore ||
        !state.activityHasMore ||
        state.activityLoadMoreError != null) {
      return;
    }
    _bloc.add(const LoadRecentActivityEvent(loadMore: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.recentActivity),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            final entries = state.activityEntries;
            // `initial` counts as loading: the fetch is dispatched from
            // initState, so the first frame lands before the bloc moves off it.
            if ((state.activityStatus == AccountStatus.loading ||
                    state.activityStatus == AccountStatus.initial) &&
                entries.isEmpty) {
              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _detailListInset(context),
                    vertical: AppDimens.paddingX20,
                  ),
                  child: const AccountListLoading(),
                ),
              );
            }
            if (state.activityStatus == AccountStatus.failure &&
                entries.isEmpty) {
              return _BreakdownError(
                message: state.errorMessage,
                onRetry: () =>
                    _bloc.add(const LoadRecentActivityEvent(refresh: true)),
              );
            }
            if (entries.isEmpty) {
              return const AccountEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No account activity yet',
                body:
                    'Booking income, platform commission and payouts will appear here.',
              );
            }

            final bool showFooter =
                state.activityHasMore ||
                state.activityLoadingMore ||
                state.activityLoadMoreError != null;
            return RefreshIndicator(
              color: LightColor.brandTextColor,
              onRefresh: () async =>
                  _bloc.add(const LoadRecentActivityEvent(refresh: true)),
              child: ListView.separated(
                controller: _scrollCtrl,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                // Capped and centred: a statement row is one line of text, and
                // stretching it across a wide window makes the label and the
                // amount unreadably far apart.
                padding: EdgeInsets.symmetric(
                  horizontal: _detailListInset(context),
                  vertical: AppDimens.paddingX20,
                ),
                itemCount: entries.length + (showFooter ? 1 : 0),
                separatorBuilder: (_, int index) => index == entries.length - 1
                    ? const SizedBox.shrink()
                    : Divider(
                        height: AppDimens.paddingX24,
                        thickness: 1,
                        color: LightColor.dividerColor,
                      ),
                itemBuilder: (context, index) {
                  if (index >= entries.length) {
                    return _SettlementsFooter(
                      loading: state.activityLoadingMore,
                      error: state.activityLoadMoreError,
                      onRetry: () => _bloc.add(
                        const LoadRecentActivityEvent(loadMore: true),
                      ),
                    );
                  }
                  return AccountEntryTile(entry: entries[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Detail page: the settlement request history, paginated.
///
/// The server's `summary` counts every request; the list itself walks pages of
/// 20 as the reader scrolls.
class _SettlementsPage extends StatefulWidget {
  const _SettlementsPage();

  @override
  State<_SettlementsPage> createState() => _SettlementsPageState();
}

class _SettlementsPageState extends State<_SettlementsPage> {
  late final AccountBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<AccountBloc>();
    // This screen owns the `/auth/settlements` request — the account load no
    // longer makes it. Page 0 means nothing is held yet, which is the normal
    // case on first open and after a pull-to-refresh invalidated it.
    if (_bloc.state.settlementsPage == 0) {
      _bloc.add(const LoadSettlementsEvent());
    }
  }

  void _loadMore() {
    final state = _bloc.state;
    if (state.settlementsLoadingMore ||
        !state.settlementsHasMore ||
        state.settlementsLoadMoreError != null) {
      return;
    }
    _bloc.add(const LoadSettlementsEvent(loadMore: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.settlements),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            // `initial` counts as loading here: the fetch is dispatched from
            // initState, so the first frame lands before the bloc has moved off
            // it — without this the empty state flashes on every open.
            if ((state.settlementsStatus == AccountStatus.loading ||
                    state.settlementsStatus == AccountStatus.initial) &&
                state.settlements.isEmpty) {
              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  // Same inset as the loaded list, so the rows do not shift
                  // sideways the moment real data replaces the skeleton.
                  padding: EdgeInsets.symmetric(
                    horizontal: _detailListInset(context),
                    vertical: AppDimens.paddingX20,
                  ),
                  child: const AccountSettlementListLoading(),
                ),
              );
            }
            final double inset = _detailListInset(context);
            final bool showSummary = state.settlementCounts.total > 0;
            if (state.settlements.isEmpty) {
              return RefreshIndicator(
                color: LightColor.brandTextColor,
                onRefresh: () async =>
                    _bloc.add(const LoadSettlementsEvent(refresh: true)),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  children: const [
                    SizedBox(height: AppDimens.paddingX50),
                    AccountEmptyState(
                      icon: Icons.account_balance_outlined,
                      title: 'No settlements yet',
                      body:
                          'Request a settlement and Hamro Futsal will pay your balance out to you.',
                    ),
                  ],
                ),
              );
            }
            // Header (the summary chips) + rows + the paging footer.
            final int headerCount = showSummary ? 1 : 0;
            final bool showFooter =
                state.settlementsLoadingMore ||
                state.settlementsLoadMoreError != null;
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 300) _loadMore();
                return false;
              },
              child: RefreshIndicator(
                color: LightColor.brandTextColor,
                onRefresh: () async =>
                    _bloc.add(const LoadSettlementsEvent(refresh: true)),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: inset,
                    vertical: AppDimens.paddingX20,
                  ),
                  itemCount:
                      headerCount +
                      state.settlements.length +
                      (showFooter ? 1 : 0),
                  // Cards carry their own border, so the rows are separated by
                  // space rather than dividers.
                  separatorBuilder: (_, index) =>
                      const SizedBox(height: AppDimens.paddingX12),
                  itemBuilder: (context, index) {
                    if (showSummary && index == 0) {
                      return SettlementSummaryRow(
                        counts: state.settlementCounts,
                      );
                    }
                    final int row = index - headerCount;
                    if (row >= state.settlements.length) {
                      return _SettlementsFooter(
                        loading: state.settlementsLoadingMore,
                        error: state.settlementsLoadMoreError,
                        onRetry: () => _bloc.add(
                          const LoadSettlementsEvent(loadMore: true),
                        ),
                      );
                    }
                    return SettlementCard(settlement: state.settlements[row]);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Paging footer for the settlements list: the app spinner, or a retry row.
class _SettlementsFooter extends StatelessWidget {
  const _SettlementsFooter({
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
      child: Center(
        child: error != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(StringConstants.retry),
                    style: TextButton.styleFrom(
                      foregroundColor: LightColor.brandTextColor,
                    ),
                  ),
                ],
              )
            : Opacity(
                opacity: loading ? 1 : 0,
                child: CustomLoading(
                  color: LightColor.brandTextColor,
                  size: 22,
                  strokeWidth: 2.5,
                  secondCircleColor: LightColor.secondaryLight,
                  thirdCircleColor: LightColor.secondaryLight,
                ),
              ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: child,
    );
  }
}

class _AccountError extends StatelessWidget {
  const _AccountError({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: LightColor.iconGrey),
            const SizedBox(height: AppDimens.paddingX12),
            Text(
              message ?? StringConstants.couldNotParseAccountFromServer,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh_rounded,
                size: AppDimens.sizeX16,
                color: LightColor.brandTextColor,
              ),
              label: Text(
                StringConstants.retry,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.brandTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
