import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/utils/booking_search.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_shared_widgets.dart';

/// Which endpoint a page draws from.
enum BookingListKind {
  /// `/futsal-bookings` — the bookings made at the vendor's own venues.
  futsal,

  /// `/bookings` — the bookings this user made.
  mine,
}

/// One status's page of bookings: the rows the server returned for
/// `?status=…`, with its own pagination, refresh and empty state.
///
/// One page per status, held side by side in the caller's [PageView], is what
/// makes the status switch smooth: every status keeps its own rows, its own
/// cursor and its own scroll offset, so swiping back to one is instant instead
/// of a fresh request and a skeleton.
class BookingStatusPage extends StatelessWidget {
  const BookingStatusPage({
    super.key,
    required this.kind,
    required this.filter,
    this.searchQuery = '',
    this.dateOrder = BookingDateOrder.descending,
    this.fromDate,
    this.toDate,
  });

  final BookingListKind kind;
  final BookingStatusFilter filter;

  /// Search and the date range stay on-device: they narrow the rows in hand,
  /// where status is the server's own filter.
  final String searchQuery;
  final BookingDateOrder dateOrder;
  final DateTime? fromDate;
  final DateTime? toDate;

  bool get _isMine => kind == BookingListKind.mine;

  BookingListSlice _slice(BookingState state) =>
      _isMine ? state.mySlice(filter) : state.futsalSlice(filter);

  void _load(
    BuildContext context, {
    bool silent = false,
    bool loadMore = false,
    bool force = false,
  }) {
    final BookingBloc bloc = context.read<BookingBloc>();
    bloc.add(
      _isMine
          ? FetchMyBookingsEvent(
              filter: filter,
              silent: silent,
              loadMore: loadMore,
              force: force,
            )
          : FetchFutsalBookingsEvent(
              filter: filter,
              silent: silent,
              loadMore: loadMore,
              force: force,
            ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final BookingBloc bloc = context.read<BookingBloc>();
    final int startTick = bloc.state.refreshTick;
    _load(context, silent: true, force: true);
    // Wait until the fetch actually completes (refreshTick is bumped on every
    // finished fetch). Timeout guarantees the indicator always dismisses.
    await bloc.stream
        .firstWhere((BookingState state) => state.refreshTick != startTick)
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
  }

  EdgeInsets _listPadding(BuildContext context) => EdgeInsets.fromLTRB(
    AppDimens.paddingX16,
    AppDimens.paddingX8,
    AppDimens.paddingX16,
    AppDimens.sizeX100 + MediaQuery.viewPaddingOf(context).bottom,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      buildWhen: (BookingState p, BookingState c) => _slice(p) != _slice(c),
      builder: (BuildContext context, BookingState state) {
        final BookingListSlice slice = _slice(state);

        if (slice.loadStatus == BookingLoadStatus.idle ||
            slice.loadStatus == BookingLoadStatus.loading) {
          return const BookingSkeletonLoader();
        }

        if (slice.loadStatus == BookingLoadStatus.failure) {
          return BookingErrorView(
            message:
                slice.error ??
                (_isMine
                    ? 'Failed to load bookings.'
                    : 'Failed to load futsal bookings.'),
            onRetry: () => _load(context, force: true),
          );
        }

        final List<BookingModel> sorted = sortBookingsByDate(
          slice.bookings.where(
            (BookingModel booking) =>
                bookingMatchesSearch(booking, searchQuery) &&
                bookingFallsWithinDateRange(
                  booking,
                  fromDate: fromDate,
                  toDate: toDate,
                ),
          ),
          dateOrder,
        );

        // In the vendor's "All" view, pending bookings come first — they are
        // the ones waiting on a decision — keeping the date order within each
        // group.
        final List<BookingModel> items =
            !_isMine && filter == BookingStatusFilter.all
            ? <BookingModel>[
                ...sorted.where(
                  (BookingModel b) => b.status == BookingStatus.pending,
                ),
                ...sorted.where(
                  (BookingModel b) => b.status != BookingStatus.pending,
                ),
              ]
            : sorted;

        if (items.isEmpty) return _refreshBar(slice, _empty(context));

        return _refreshBar(
          slice,
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification.metrics.extentAfter < 300 &&
                  slice.hasMorePages &&
                  !slice.isLoadingMore) {
                _load(context, silent: true, loadMore: true);
              }
              return false;
            },
            child: RefreshIndicator(
              color: LightColor.secondaryColor,
              onRefresh: () => _refresh(context),
              child: ListView.separated(
                // Each status page keeps its own scroll offset while the others
                // stay built beside it.
                key: PageStorageKey<String>('${kind.name}-${filter.name}'),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: _listPadding(context),
                itemCount:
                    items.length +
                    (slice.isLoadingMore || slice.loadMoreFailed ? 1 : 0),
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimens.paddingX10),
                itemBuilder: (BuildContext context, int i) {
                  if (i == items.length) return _footer(context, slice);
                  return BookingCard(
                    booking: items[i],
                    onTap: () async {
                      await context.pushNamed(
                        AppRouterParams.bookingDetails.name,
                        queryParameters: <String, String>{
                          'futsal': _isMine ? 'false' : 'true',
                        },
                        extra: items[i],
                      );
                      // Refresh with the latest data on returning from details.
                      if (context.mounted) {
                        _load(context, silent: true, force: true);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// A slim line above the list while this status is being refetched — the
  /// swipe onto the page starts one, and the rows underneath stay readable
  /// instead of being replaced by a skeleton.
  Widget _refreshBar(BookingListSlice slice, Widget child) {
    if (!slice.isRefreshing) return child;
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 2,
          child: LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.transparent,
            color: LightColor.secondaryColor,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  /// A page with nothing on it still scrolls, so pull-to-refresh works from an
  /// empty status too.
  Widget _empty(BuildContext context) {
    final bool hasCriteria =
        filter != BookingStatusFilter.all ||
        searchQuery.trim().isNotEmpty ||
        fromDate != null ||
        toDate != null;

    return RefreshIndicator(
      color: LightColor.secondaryColor,
      onRefresh: () => _refresh(context),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: _listPadding(context),
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: BookingEmptyView(
                icon: Icons.calendar_month_outlined,
                title: hasCriteria
                    ? 'No matching bookings'
                    : _isMine
                    ? 'No bookings yet'
                    : 'No futsal bookings yet',
                subtitle: hasCriteria
                    ? _emptySubtitle
                    : _isMine
                    ? 'Your upcoming court bookings will appear here.'
                    : 'Bookings made at your venues will appear here.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Names the filter that came up empty rather than a generic "try again":
  /// on a status page the status is usually the reason.
  String get _emptySubtitle {
    final bool narrowed =
        searchQuery.trim().isNotEmpty || fromDate != null || toDate != null;
    if (filter == BookingStatusFilter.all) {
      return 'Try a different search or date range.';
    }
    final String status = filter.query;
    return narrowed
        ? 'No $status bookings match your search or date range.'
        : 'You have no $status bookings.';
  }

  Widget _footer(BuildContext context, BookingListSlice slice) {
    if (slice.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(AppDimens.paddingX16),
        child: Center(
          child: CustomLoading(
            color: LightColor.secondaryColor,
            size: 24,
            strokeWidth: 3,
            secondCircleColor: LightColor.secondaryLight,
            thirdCircleColor: LightColor.secondaryLight,
          ),
        ),
      );
    }
    return Center(
      child: TextButton.icon(
        onPressed: () => _load(context, silent: true, loadMore: true),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Could not load more. Retry'),
      ),
    );
  }
}
