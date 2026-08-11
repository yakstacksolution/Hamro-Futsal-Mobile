import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/app_message_view.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/transactions/data/model/transaction_history_model.dart';
import 'package:hamro_footsall/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:hamro_footsall/features/transactions/domain/model/booking_transaction.dart';
import 'package:hamro_footsall/features/transactions/domain/repository/transaction_repository.dart';
import 'package:hamro_footsall/features/transactions/domain/usecase/transaction_usecase.dart';
import 'package:hamro_footsall/features/transactions/presentation/bloc/transaction_history_bloc/transaction_history_bloc.dart';
import 'package:hamro_footsall/features/transactions/presentation/widgets/transaction_filter_sheet.dart';
import 'package:hamro_footsall/features/transactions/presentation/widgets/transaction_loading_widgets.dart';
import 'package:hamro_footsall/features/transactions/presentation/widgets/transaction_widgets.dart';
import 'package:intl/intl.dart';

/// Infinitely scrolling `GET /auth/transaction-history` (`per_page=20`).
///
/// Everything the user can narrow by — `direction`, `type`, `search`,
/// `date_from`/`date_to` — is applied server-side, so every control refetches
/// from page 1 rather than filtering the rows already on screen.
class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({
    super.key,
    required this.perspective,
    this.repository,
  });

  /// Only drives the empty-state wording; the ledger itself is whatever the
  /// server returns for the signed-in user.
  final TransactionPerspective perspective;
  final TransactionRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionHistoryBloc>(
      create: (_) => TransactionHistoryBloc(
        TransactionUseCase(repository ?? TransactionRepositoryImpl()),
      )..add(const LoadTransactionHistoryEvent()),
      child: _TransactionHistoryView(perspective: perspective),
    );
  }
}

class _TransactionHistoryView extends StatefulWidget {
  const _TransactionHistoryView({required this.perspective});

  final TransactionPerspective perspective;

  @override
  State<_TransactionHistoryView> createState() =>
      _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<_TransactionHistoryView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;

  /// Distance from the bottom at which the next page is requested.
  static const double _loadMoreThreshold = 280;

  /// Keystrokes are coalesced before hitting the endpoint.
  static const Duration _searchDebounceDelay = Duration(milliseconds: 400);

  /// Long enough to read as a transition, short enough not to delay the result.
  static const Duration _transition = Duration(milliseconds: 220);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double remaining =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (remaining <= _loadMoreThreshold) {
      // The bloc ignores this while a page is in flight or the list has ended.
      context.read<TransactionHistoryBloc>().add(
        const LoadMoreTransactionHistoryEvent(),
      );
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDelay, () {
      if (!mounted) return;
      context.read<TransactionHistoryBloc>().add(
        SearchTransactionsEvent(value),
      );
    });
  }

  void _onSearchCleared() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {});
    context.read<TransactionHistoryBloc>().add(
      const SearchTransactionsEvent(''),
    );
  }

  Future<void> _refresh() async {
    final TransactionHistoryBloc bloc = context.read<TransactionHistoryBloc>();
    bloc.add(const LoadTransactionHistoryEvent(isRefresh: true));
    await bloc.stream.firstWhere(
      (TransactionHistoryState state) =>
          state.status != TransactionHistoryStatus.loading,
    );
  }

  /// `Custom` opens the filter sheet, where the two dates are picked; every
  /// other chip resolves to a window immediately.
  Future<void> _onRangeChipSelected(TransactionRangeFilter filter) async {
    if (filter == TransactionRangeFilter.custom) {
      await _openFilters();
      return;
    }
    context.read<TransactionHistoryBloc>().add(
      ChangeTransactionRangeEvent(TransactionDateRange.of(filter)),
    );
  }

  Future<void> _openFilters() async {
    final TransactionHistoryBloc bloc = context.read<TransactionHistoryBloc>();
    final TransactionHistoryState state = bloc.state;

    final TransactionFilterSelection? selection =
        await showTransactionFilterSheet(
          context: context,
          direction: state.direction,
          type: state.type,
          range: state.range,
          availableTypes: state.availableTypes,
        );
    if (selection == null) return;

    // Each control is its own event and the bloc no-ops on unchanged values, so
    // applying the sheet costs one request per filter the user actually moved.
    bloc
      ..add(ChangeTransactionDirectionEvent(selection.direction))
      ..add(ChangeTransactionTypeEvent(selection.type))
      ..add(ChangeTransactionRangeEvent(selection.range));
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {});
    context.read<TransactionHistoryBloc>().add(
      const ClearTransactionFiltersEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double horizontal = context.responsive<double>(
      mobile: AppDimens.paddingX16,
      tablet: AppDimens.paddingX32,
    );

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.transactionHistory),
      body: SafeArea(
        top: false,
        child: BlocBuilder<TransactionHistoryBloc, TransactionHistoryState>(
          builder: (BuildContext context, TransactionHistoryState state) {
            if (state.isInitialLoading) {
              return TransactionHistoryLoadingView(horizontal: horizontal);
            }

            // A hard failure with nothing cached takes the whole surface; a
            // failure with rows on screen is reported in the list footer.
            if (state.items.isEmpty &&
                state.status == TransactionHistoryStatus.failure) {
              return AppMessageView(
                icon: Icons.wifi_off_rounded,
                title: StringConstants.couldNotLoadTransactionHistory,
                message:
                    state.errorMessage ?? StringConstants.somethingWentWrong,
                actionLabel: StringConstants.retry,
                onAction: () => context.read<TransactionHistoryBloc>().add(
                  const LoadTransactionHistoryEvent(),
                ),
              );
            }

            final List<_ListRow> rows = _buildRows(state.items);

            return RefreshIndicator(
              color: LightColor.secondaryColor,
              onRefresh: _refresh,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: <Widget>[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      AppDimens.paddingX14,
                      horizontal,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: TransactionSummaryPanel(
                        summary: state.summary,
                        rangeLabel: transactionRangeLabel(state.range),
                        fallbackCount: state.total > 0
                            ? state.total
                            : state.items.length,
                      ),
                    ),
                  ),

                  // Search stays reachable while the ledger scrolls under it.
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SearchHeaderDelegate(
                      horizontal: horizontal,
                      child: TransactionSearchBar(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onClear: _onSearchCleared,
                        onOpenFilters: _openFilters,
                        activeFilterCount: state.activeFilterCount,
                      ),
                    ),
                  ),

                  // The range row, with the in-flight line directly beneath it —
                  // every chip refetches, so progress belongs next to the
                  // control that triggered it.
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: <Widget>[
                          TransactionRangeChips(
                            selected: state.range,
                            onSelected: _onRangeChipSelected,
                          ),
                          const SizedBox(height: AppDimens.paddingX10),
                          _FilterProgressLine(isLoading: state.isReloading),
                        ],
                      ),
                    ),
                  ),

                  // Collapses to nothing when no filter is set, so the row
                  // grows and shrinks rather than popping in.
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    sliver: SliverToBoxAdapter(
                      child: AnimatedSize(
                        duration: _transition,
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: state.hasFilters
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: AppDimens.paddingX12,
                                ),
                                child: _ActiveFilterSummary(
                                  state: state,
                                  onClear: _clearFilters,
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ),
                  ),

                  // Rows dim and stop taking taps while the next query is in
                  // flight, then fade back in — so a filter change reads as a
                  // transition instead of an abrupt swap.
                  SliverAnimatedOpacity(
                    opacity: state.isReloading ? 0.35 : 1,
                    duration: _transition,
                    curve: Curves.easeOut,
                    sliver: SliverIgnorePointer(
                      ignoring: state.isReloading,
                      sliver: rows.isEmpty
                          ? SliverToBoxAdapter(
                              child: _EmptyState(hasFilters: state.hasFilters),
                            )
                          : SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontal,
                              ),
                              sliver: SliverList.builder(
                                itemCount: rows.length,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        rows[index].build(context),
                              ),
                            ),
                    ),
                  ),

                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      0,
                      horizontal,
                      AppDimens.paddingX32,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _ListFooter(state: state),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Flattens the accumulated items into month headers plus rows, so the whole
  /// ledger is one lazily built sliver — which also lets it fade as a unit.
  List<_ListRow> _buildRows(List<TransactionHistoryItemModel> items) {
    final DateFormat monthFormat = DateFormat('MMMM yyyy');
    final List<_ListRow> rows = <_ListRow>[];
    String? currentMonth;

    for (int index = 0; index < items.length; index++) {
      final TransactionHistoryItemModel item = items[index];
      final String month = item.date == null
          ? StringConstants.transactions
          : monthFormat.format(item.date!);

      final bool firstInGroup = month != currentMonth;
      if (firstInGroup) {
        currentMonth = month;
        rows.add(_MonthHeaderRow(month));
      }

      // The divider is dropped when the next item starts a new month, so each
      // group reads as its own block.
      final TransactionHistoryItemModel? next = index + 1 < items.length
          ? items[index + 1]
          : null;
      final bool lastInGroup =
          next == null ||
          (next.date == null
                  ? StringConstants.transactions
                  : monthFormat.format(next.date!)) !=
              month;
      rows.add(
        _TransactionRow(
          item,
          showDivider: !lastInGroup,
          // The group's outer corners are rounded; the seams between its rows
          // are square, so a month reads as one continuous card.
          isFirst: firstInGroup,
          isLast: lastInGroup,
        ),
      );
    }
    return rows;
  }
}

/// One entry in the flattened list: a month header or a transaction.
sealed class _ListRow {
  const _ListRow();

  Widget build(BuildContext context);
}

class _MonthHeaderRow extends _ListRow {
  const _MonthHeaderRow(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => TransactionSectionHeader(title: title);
}

class _TransactionRow extends _ListRow {
  const _TransactionRow(
    this.item, {
    required this.showDivider,
    required this.isFirst,
    required this.isLast,
  });

  final TransactionHistoryItemModel item;
  final bool showDivider;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) => TransactionTile(
    item: item,
    showDivider: showDivider,
    isFirst: isFirst,
    isLast: isLast,
  );
}

/// Pins the search bar, painting the page background behind it so rows do not
/// show through as they scroll past.
class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SearchHeaderDelegate({required this.child, required this.horizontal});

  final Widget child;
  final double horizontal;

  /// The hairline's space is always reserved, so revealing it never nudges the
  /// list.
  static const double _height =
      AppDimens.sizeX44 + (AppDimens.paddingX12 * 2) + 1;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: LightColor.background,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontal,
              AppDimens.paddingX12,
              horizontal,
              AppDimens.paddingX12,
            ),
            child: child,
          ),
          // A hairline appears only once rows are sliding underneath, so the
          // header detaches from the summary as the page scrolls.
          SizedBox(
            height: 1,
            child: overlapsContent
                ? ColoredBox(color: LightColor.dividerColor)
                : null,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchHeaderDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.horizontal != horizontal;
}

/// The in-flight line under the range chips: a track that is always laid out,
/// carrying an indeterminate bar only while a query is running.
///
/// Built only while loading, because an indeterminate indicator animates
/// forever — mounted at zero opacity it would burn frames and never let a test
/// settle. Its 3px is reserved either way, so revealing it never nudges the
/// list.
class _FilterProgressLine extends StatelessWidget {
  const _FilterProgressLine({required this.isLoading});

  final bool isLoading;

  static const double _thickness = 3;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_thickness),
      child: SizedBox(
        height: _thickness,
        width: double.infinity,
        child: isLoading
            ? LinearProgressIndicator(
                minHeight: _thickness,
                backgroundColor: LightColor.secondaryColor.withValues(
                  alpha: 0.14,
                ),
                color: LightColor.secondaryColor,
              )
            : ColoredBox(color: LightColor.dividerColor),
      ),
    );
  }
}

/// Reads back what is currently narrowing the list, with a one-tap reset.
class _ActiveFilterSummary extends StatelessWidget {
  const _ActiveFilterSummary({required this.state, required this.onClear});

  final TransactionHistoryState state;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final List<String> parts = <String>[
      if (state.direction != TransactionDirectionFilter.all)
        transactionDirectionLabel(state.direction),
      if (state.type != 'all') TxnParse.humanize(state.type),
      if (state.range.isActive) transactionRangeLabel(state.range),
      if (state.search.isNotEmpty) '"${state.search}"',
    ];

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            parts.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
        ),
        TextButton(
          onPressed: onClear,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX8,
            ),
            minimumSize: Size.zero,
          ),
          child: Text(
            StringConstants.clearAll,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryColor,
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingX32),
      child: AppMessageView(
        icon: hasFilters
            ? Icons.search_off_rounded
            : Icons.receipt_long_outlined,
        title: hasFilters
            ? StringConstants.noTransactionsFound
            : StringConstants.noTransactionsYet,
        message: hasFilters
            ? StringConstants.tryAdjustingOrClearingYourFilters
            : StringConstants.transactionsWillAppearHere,
      ),
    );
  }
}

/// Pagination spinner, load-more retry, or the end-of-list marker.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final TransactionHistoryState state;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);

    if (state.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX20),
        child: Center(
          child: SizedBox(
            width: AppDimens.sizeX24,
            height: AppDimens.sizeX24,
            child: CustomLoading(
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX24,
              strokeWidth: 2.5,
              secondCircleColor: LightColor.secondaryLight,
              thirdCircleColor: LightColor.secondaryLightMedium,
            ),
          ),
        ),
      );
    }

    if (state.errorMessage != null && state.items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
        child: Center(
          child: TextButton.icon(
            onPressed: () => context.read<TransactionHistoryBloc>().add(
              const LoadMoreTransactionHistoryEvent(),
            ),
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
        ),
      );
    }

    return const SizedBox(height: AppDimens.paddingX8);
  }
}
