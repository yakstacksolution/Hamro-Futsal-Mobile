import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/utils/booking_search.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_products_sheet.dart';
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
    this.onFloatingActionExtentAfterChanged,
  });

  final BookingListKind kind;
  final BookingStatusFilter filter;

  /// Search and the date range stay on-device: they narrow the rows in hand,
  /// where status is the server's own filter.
  final String searchQuery;
  final BookingDateOrder dateOrder;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<double>? onFloatingActionExtentAfterChanged;

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

        if (items.isEmpty) {
          onFloatingActionExtentAfterChanged?.call(double.infinity);
          return _refreshBar(slice, _empty(context));
        }

        return _refreshBar(
          slice,
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              _reportFloatingActionObstruction(notification);
              if (_shouldLoadMore(notification, slice)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  _load(context, silent: true, loadMore: true);
                });
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
                  final BookingModel booking = items[i];
                  return BookingCard(
                    booking: booking,
                    // The vendor's own list is where add-ons are sold and a
                    // booking is closed out, so the quick actions live on the
                    // card there; the customer's list has nothing to act on.
                    footer:
                        !_isMine &&
                            (bookingSupportsProducts(booking) ||
                                bookingCanComplete(booking))
                        ? _BookingCardActions(
                            booking: booking,
                            onChanged: () =>
                                _load(context, silent: true, force: true),
                          )
                        : null,
                    onTap: () async {
                      await context.pushNamed(
                        AppRouterParams.bookingDetails.name,
                        queryParameters: <String, String>{
                          'futsal': _isMine ? 'false' : 'true',
                        },
                        extra: booking,
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

  bool _shouldLoadMore(
    ScrollNotification notification,
    BookingListSlice slice,
  ) {
    if (notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical ||
        notification.metrics.extentAfter >= 300 ||
        !slice.hasMorePages ||
        slice.isLoadingMore) {
      return false;
    }
    return notification is ScrollUpdateNotification ||
        notification is OverscrollNotification;
  }

  void _reportFloatingActionObstruction(ScrollNotification notification) {
    final ValueChanged<double>? callback = onFloatingActionExtentAfterChanged;
    if (callback == null || _isMine || notification.depth != 0) return;

    final ScrollMetrics metrics = notification.metrics;
    if (!metrics.hasContentDimensions) return;
    callback(metrics.extentAfter);
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

/// Quick actions on a futsal booking card: "Add products" and "Complete".
///
/// Both open the same sheets the details page uses, so the vendor can sell an
/// add-on or close a booking out without leaving the list. [onChanged] refetches
/// the status page whenever one of them actually changed something.
class _BookingCardActions extends StatelessWidget {
  const _BookingCardActions({required this.booking, required this.onChanged});

  final BookingModel booking;
  final VoidCallback onChanged;

  Future<void> _addProducts(BuildContext context) async {
    final bool? added = await openBookingProductsSheet(context, booking);
    if (added == true && context.mounted) onChanged();
  }

  Future<void> _complete(BuildContext context) async {
    final BookingCompleteResult? result = await showBookingCompleteSheet(
      context,
      booking,
    );
    if (result == null || !context.mounted) return;
    final bool ok = await completeBooking(booking.id, result: result);
    if (!context.mounted) return;
    AppUtils().showSnackBar(
      context,
      ok ? MsgType.success : MsgType.error,
      ok ? 'Booking marked as completed.' : 'Could not complete the booking.',
    );
    if (ok) onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final bool canAdd = bookingSupportsProducts(booking);
    final bool canComplete = bookingCanComplete(booking);
    final int count = booking.extraItemsCount;

    return Row(
      children: <Widget>[
        if (canAdd)
          Expanded(
            child: _CardAction(
              icon: count > 0
                  ? Icons.shopping_bag_rounded
                  : Icons.add_shopping_cart_rounded,
              label: count > 0 ? 'Products' : 'Add products',
              // The count is what the vendor scans for on a busy list, so it
              // reads as a badge rather than as part of the label.
              badge: count > 0 ? '$count' : null,
              color: LightColor.secondaryColor,
              onTap: () => _addProducts(context),
            ),
          ),
        if (canAdd && canComplete) const SizedBox(width: AppDimens.paddingX8),
        if (canComplete)
          Expanded(
            child: _CardAction(
              icon: Icons.check_rounded,
              label: 'Complete',
              color: LightColor.secondaryColor,
              // Closing the booking out is the end of the flow, so it carries
              // the only filled surface on the card.
              filled: true,
              onTap: () => _complete(context),
            ),
          ),
      ],
    );
  }
}

/// One footer action. [filled] paints the brand surface for the primary move;
/// the rest sit on a soft tint of [color] so the card stays quiet until read.
class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color foreground = filled ? LightColor.onBrandSurface : color;
    return Material(
      color: filled ? color : color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: foreground.withValues(alpha: 0.12),
        highlightColor: foreground.withValues(alpha: 0.06),
        child: Container(
          height: AppDimens.sizeX36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: filled
                ? null
                : Border.all(color: color.withValues(alpha: 0.22)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: AppDimens.sizeX16, color: foreground),
              const SizedBox(width: AppDimens.paddingX6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: AppDimens.paddingX6),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: AppDimens.sizeX18,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingX4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: filled
                        ? foreground.withValues(alpha: 0.22)
                        : color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badge!,
                    style: FutsalTheme.getTextTheme(context).bodyTextSmall
                        ?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
