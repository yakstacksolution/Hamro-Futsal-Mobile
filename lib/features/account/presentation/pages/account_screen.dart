import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';
import 'package:hamro_footsall/features/account/data/repositories/account_repository_impl.dart';
import 'package:hamro_footsall/features/account/domain/usecase/account_usecase.dart';
import 'package:hamro_footsall/features/account/presentation/bloc/account_bloc/account_bloc.dart';
import 'package:hamro_footsall/features/account/presentation/utils/account_ui_utils.dart';
import 'package:hamro_footsall/features/account/presentation/widgets/account_loading_widgets.dart';
import 'package:hamro_footsall/features/account/presentation/widgets/account_widgets.dart';
import 'package:hamro_footsall/features/account/presentation/pages/request_settlement_page.dart';

/// How many ledger entries the main screen previews before "View all".
const int _kRecentActivityCount = 5;

/// Vendor ↔ Hamro Futsal account. The main screen stays minimal — hero
/// balance, lifetime stats, shortcuts and recent activity — while the futsal
/// breakdown, full statement and settlement history live on detail pages.
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

/// The account body, split out from [AccountScreen] so it can be rendered
/// against an injected [AccountBloc] (the screen itself fetches on create).
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
      appBar: const CustomAppBar(title: StringConstants.account),
      body: SafeArea(
        top: false,
        child: BlocConsumer<AccountBloc, AccountState>(
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
            if (state.summaryStatus == AccountStatus.loading &&
                !state.refreshing) {
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
                (summary.requestableAmount > 0 ||
                    summary.availableBalance > 0) &&
                summary.totalCommission > 0 &&
                !state.hasPendingSettlement &&
                state.submitStatus != AccountStatus.loading;
            final recent = state.entries.take(_kRecentActivityCount).toList();
            final Widget balance = AccountBalanceCard(
              // A settlement pays the platform's commission, not the balance.
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
              onSettlements: () =>
                  _pushDetail(context, const _SettlementsPage()),
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
              hasMore: state.entries.length > recent.length,
              onViewAll: () => _pushDetail(context, const _StatementPage()),
            );

            final bool desktop = context.isDesktop;
            final double horizontal = context.responsive<double>(
              mobile: AppDimens.paddingX20,
              tablet: AppDimens.paddingX32,
            );

            return RefreshIndicator(
              color: LightColor.secondaryColor,
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
        ),
      ),
    );
  }
}

/// Horizontal inset that keeps a detail list (statement, settlements, futsal
/// breakdown) capped at [AppDimens.accountListMaxWidth] and centred. These
/// pages are full-screen, so the screen width is the pane width.
double _detailListInset(BuildContext context) {
  const double base = AppDimens.paddingX20;
  if (!context.isTabletOrWider) return base;
  final double slack =
      (context.screenWidth - AppDimens.accountListMaxWidth) / 2;
  return slack > base ? slack : AppDimens.paddingX32;
}

/// Why the settlement CTA is disabled right now; empty when it isn't.
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

/// Opens the request form for [venue] (or all futsals when null).
///
/// The form is built from `/auth/settlement-preview` for that scope — the
/// server owns the copy, the ceiling, the exact-amount rule and the proof
/// constraints, so the call must succeed before the form can be shown. A
/// stale cached balance would let the vendor submit a figure the server
/// rejects, so a failed preview surfaces the error instead.
Future<void> openSettlementSheet(
  BuildContext context, {
  VenueAccountModel? venue,
}) async {
  final bloc = context.read<AccountBloc>();
  if (bloc.state.hasPendingSettlement) {
    AppUtils().showSnackBar(
      context,
      MsgType.info,
      StringConstants.settlementAwaitingApproval,
    );
    return;
  }
  final result = await bloc.useCase.getSettlementPreview(venueId: venue?.id);
  if (!context.mounted) return;
  final preview = result.fold((failure) {
    AppUtils().showSnackBar(context, MsgType.error, failure.errorMessage);
    return null;
  }, (p) => p);
  if (preview == null) return;
  if (!preview.eligible) {
    AppUtils().showSnackBar(
      context,
      MsgType.info,
      preview.blockingReason.isNotEmpty
          ? preview.blockingReason
          : StringConstants.noCommissionDue,
    );
    return;
  }
  final request = await Navigator.of(context).push<SettlementRequestDraft>(
    MaterialPageRoute(
      builder: (_) =>
          RequestSettlementPage(preview: preview, venueName: venue?.name ?? ''),
    ),
  );
  if (request == null) return;
  bloc.add(
    RequestSettlementEvent(
      amount: request.amount,
      transactionReference: request.transactionReference,
      // A venue-scoped preview carries the id the request must be filed under.
      venueId: venue?.id ?? preview.venue?.id,
      paymentProofPath: request.paymentProofPath,
      note: request.note,
    ),
  );
}

/// Navigation shortcuts: futsal breakdown and settlements.
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
    // `data.sections` is authoritative for the counts; the loaded rows are
    // only a fallback before it arrives.
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
  const _RecentActivityHeader({required this.hasMore, required this.onViewAll});

  final bool hasMore;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent activity',
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (hasMore)
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingX4),
              child: Text(
                'View all',
                style: textTheme.bodyTextSmall?.copyWith(
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

/// Detail page: per-futsal balances with a venue-scoped settlement action.
class _VenueBreakdownPage extends StatelessWidget {
  const _VenueBreakdownPage();

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
            if (venues.isEmpty) {
              return const AccountEmptyState(
                icon: Icons.stadium_outlined,
                title: 'No futsals yet',
                body: 'Balances for each of your futsals will appear here.',
              );
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
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
                final canSettle =
                    venue.settlementEligible &&
                    venue.availableBalance > 0 &&
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
                      : venue.availableBalance <= 0
                      ? 'Nothing available to settle yet.'
                      : 'Settlement is not available for this futsal yet.',
                );
              },
            );
          },
        ),
      ),
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
              Text(
                AccountFmt.npr(venue.availableBalance),
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (venue.pendingClearance > 0) ...[
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              '${AccountFmt.npr(venue.pendingClearance)} pending clearance',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
                fontSize: AppDimens.fontBodySubTitle,
                fontWeight: FontWeight.w500,
              ),
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
                  foregroundColor: LightColor.secondaryColor,
                  side: const BorderSide(color: LightColor.secondaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                  ),
                ),
                child: Text(
                  StringConstants.payCommission,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryColor,
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
class _StatementPage extends StatelessWidget {
  const _StatementPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.accountStatement),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state.statementStatus == AccountStatus.loading) {
              return const Padding(
                padding: EdgeInsets.all(AppDimens.paddingX20),
                child: AccountListLoading(),
              );
            }
            if (state.entries.isEmpty) {
              return const AccountEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No account activity yet',
                body:
                    'Booking income, platform commission and payouts will appear here.',
              );
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              // Capped and centred: a settlement/statement row is one line of
              // text, and stretching it across a wide window makes the label
              // and the amount unreadably far apart.
              padding: EdgeInsets.symmetric(
                horizontal: _detailListInset(context),
                vertical: AppDimens.paddingX20,
              ),
              itemCount: state.entries.length,
              separatorBuilder: (_, __) => Divider(
                height: AppDimens.paddingX24,
                thickness: 1,
                color: LightColor.dividerColor,
              ),
              itemBuilder: (context, index) =>
                  AccountEntryTile(entry: state.entries[index]),
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
    // The first page rides along with the account load; ask only if it is
    // somehow still missing (a failed initial fetch, for instance).
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
            if (state.settlementsStatus == AccountStatus.loading &&
                state.settlements.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppDimens.paddingX20),
                child: AccountSettlementListLoading(),
              );
            }
            final double inset = _detailListInset(context);
            final bool showSummary = state.settlementCounts.total > 0;
            if (state.settlements.isEmpty) {
              return RefreshIndicator(
                color: LightColor.secondaryColor,
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
                color: LightColor.secondaryColor,
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
                  separatorBuilder: (_, index) => index == 0 && showSummary
                      ? const SizedBox(height: AppDimens.paddingX16)
                      : Divider(
                          height: AppDimens.paddingX24,
                          thickness: 1,
                          color: LightColor.dividerColor,
                        ),
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
                    return SettlementTile(settlement: state.settlements[row]);
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
                      foregroundColor: LightColor.secondaryColor,
                    ),
                  ),
                ],
              )
            : Opacity(
                opacity: loading ? 1 : 0,
                child: CustomLoading(
                  color: LightColor.secondaryColor,
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
              icon: const Icon(
                Icons.refresh_rounded,
                size: AppDimens.sizeX16,
                color: LightColor.secondaryColor,
              ),
              label: Text(
                StringConstants.retry,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryColor,
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
