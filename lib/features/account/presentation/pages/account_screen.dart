import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
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
                StringConstants.settlementRequestSubmitted,
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
            final canSettle =
                summary.settlementEligible &&
                summary.availableBalance > 0 &&
                !state.hasPendingSettlement &&
                state.submitStatus != AccountStatus.loading;
            final recent = state.entries.take(_kRecentActivityCount).toList();
            final Widget balance = AccountBalanceCard(
              availableBalance: summary.availableBalance,
              pendingClearance: summary.pendingClearance,
              // onRequestSettlement: canSettle
              //     ? () => openSettlementSheet(context)
              //     : null,
              onRequestSettlement: () => openSettlementSheet(context),
              disabledReason: settlementBlockedReason(state),
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
    return 'A settlement request is already being processed.';
  }
  return 'Settlement is not currently available.';
}

/// Opens the full-page request form scoped to [venue] (or all futsals when
/// null) and dispatches the settlement event with the returned draft.
Future<void> openSettlementSheet(
  BuildContext context, {
  VenueAccountModel? venue,
}) async {
  final bloc = context.read<AccountBloc>();
  final state = bloc.state;
  if (state.hasPendingSettlement) {
    AppUtils().showSnackBar(
      context,
      MsgType.info,
      StringConstants.settlementAwaitingApproval,
    );
    return;
  }
  // Server-authoritative preview of what can be settled for this scope;
  // falls back to the cached summary/venue balance if the call fails.
  final preview = (await bloc.useCase.getSettlementPreview(
    venueId: venue?.id,
  )).fold((_) => null, (p) => p);
  if (!context.mounted) return;
  if (preview != null && !preview.eligible) {
    AppUtils().showSnackBar(
      context,
      MsgType.info,
      preview.blockingReason.isNotEmpty
          ? preview.blockingReason
          : StringConstants.settlementAwaitingApproval,
    );
    return;
  }
  final fallbackBalance =
      venue?.availableBalance ?? state.summary.availableBalance;
  final previewAmount = preview?.payableAmount ?? 0;
  final request = await Navigator.of(context).push<SettlementRequestDraft>(
    MaterialPageRoute(
      builder: (_) => RequestSettlementPage(
        summary: state.summary,
        availableBalance: previewAmount > 0 ? previewAmount : fallbackBalance,
        scopeLabel: venue?.name ?? 'All futsals · consolidated settlement',
        minSettlementAmount: preview?.minSettlementAmount,
      ),
    ),
  );
  if (request == null) return;
  bloc.add(
    RequestSettlementEvent(
      amount: request.amount,
      transactionReference: request.transactionReference,
      venueId: venue?.id,
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
    final pendingCount = state.settlements
        .where((s) => s.status != SettlementStatus.paid)
        .length;
    final tiles = <Widget>[
      if (state.summary.venues.isNotEmpty)
        AccountNavTile(
          icon: Icons.stadium_outlined,
          title: 'Futsal breakdown',
          subtitle: '${state.summary.venues.length} futsals',
          onTap: onFutsalBreakdown,
        ),
      AccountNavTile(
        icon: Icons.history_rounded,
        title: StringConstants.settlements,
        subtitle: state.settlements.isEmpty
            ? 'No settlements yet'
            : pendingCount > 0
            ? '$pendingCount in progress'
            : '${state.settlements.length} completed',
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
                  // onSettle: canSettle
                  //     ? () => openSettlementSheet(context, venue: venue)
                  //     : null,
                  onSettle: () => openSettlementSheet(context, venue: venue),
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
  const _VenueCard({required this.venue, required this.onSettle});

  final VenueAccountModel venue;
  final VoidCallback? onSettle;

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
                  StringConstants.requestSettlement,
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

/// Detail page: the settlement request history.
class _SettlementsPage extends StatelessWidget {
  const _SettlementsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.settlements),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state.settlementsStatus == AccountStatus.loading) {
              return const Padding(
                padding: EdgeInsets.all(AppDimens.paddingX20),
                child: AccountSettlementListLoading(),
              );
            }
            if (state.settlements.isEmpty) {
              return const AccountEmptyState(
                icon: Icons.account_balance_outlined,
                title: 'No settlements yet',
                body:
                    'Request a settlement and Hamro Futsal will pay your balance out to you.',
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
              itemCount: state.settlements.length,
              separatorBuilder: (_, __) => Divider(
                height: AppDimens.paddingX24,
                thickness: 1,
                color: LightColor.dividerColor,
              ),
              itemBuilder: (context, index) =>
                  SettlementTile(settlement: state.settlements[index]),
            );
          },
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
