import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/utils/booking_search.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_products_sheet.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_shared_widgets.dart';

class FutsalBookingsTab extends StatelessWidget {
  const FutsalBookingsTab({
    super.key,
    this.filter,
    this.searchQuery = '',
    this.dateOrder = BookingDateOrder.descending,
    this.fromDate,
    this.toDate,
  });

  final BookingStatus? filter;
  final String searchQuery;
  final BookingDateOrder dateOrder;
  final DateTime? fromDate;
  final DateTime? toDate;

  Future<void> _refresh(BuildContext context) async {
    final BookingBloc bloc = context.read<BookingBloc>();
    final int startTick = bloc.state.refreshTick;
    bloc.add(const FetchFutsalBookingsEvent(silent: true));
    // Wait until the fetch actually completes (refreshTick is bumped on every
    // finished fetch). Timeout guarantees the indicator always dismisses.
    await bloc.stream
        .firstWhere((BookingState state) => state.refreshTick != startTick)
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
  }

  // Extra bottom room so the last card clears both the dashboard's bottom
  // navigation bar and the "Manual Booking" button floating above it.
  EdgeInsets _listPadding(BuildContext context) => EdgeInsets.fromLTRB(
    AppDimens.paddingX16,
    AppDimens.paddingX8,
    AppDimens.paddingX16,
    AppDimens.sizeX140 + MediaQuery.viewPaddingOf(context).bottom,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      buildWhen: (p, c) =>
          p.futsalBookingsStatus != c.futsalBookingsStatus ||
          p.futsalBookings != c.futsalBookings ||
          p.futsalIsLoadingMore != c.futsalIsLoadingMore ||
          p.futsalHasMorePages != c.futsalHasMorePages ||
          p.futsalBookingsError != c.futsalBookingsError,
      builder: (context, state) {
        if (state.futsalBookingsStatus == BookingLoadStatus.idle ||
            state.futsalBookingsStatus == BookingLoadStatus.loading) {
          return const BookingSkeletonLoader();
        }

        if (state.futsalBookingsStatus == BookingLoadStatus.failure) {
          return BookingErrorView(
            message:
                state.futsalBookingsError ?? 'Failed to load futsal bookings.',
            onRetry: () => context.read<BookingBloc>().add(
              const FetchFutsalBookingsEvent(),
            ),
          );
        }

        final List<BookingModel> sorted = sortBookingsByDate(
          state.futsalBookings.where((BookingModel booking) {
            final bool matchesStatus =
                filter == null || booking.status == filter;
            return matchesStatus &&
                bookingMatchesSearch(booking, searchQuery) &&
                bookingFallsWithinDateRange(
                  booking,
                  fromDate: fromDate,
                  toDate: toDate,
                );
          }),
          dateOrder,
        );

        // In the "All" view, surface pending bookings first (they need action),
        // preserving the date ordering within each group.
        final List<BookingModel> items = filter == null
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
          final bool hasCriteria =
              filter != null ||
              searchQuery.trim().isNotEmpty ||
              fromDate != null ||
              toDate != null;
          return RefreshIndicator(
            color: LightColor.secondaryColor,
            onRefresh: () => _refresh(context),
            child: LayoutBuilder(
              builder: (context, constraints) => ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: _listPadding(context),
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: BookingEmptyView(
                      icon: Icons.sports_soccer_outlined,
                      title: hasCriteria
                          ? 'No matching bookings'
                          : 'No futsal bookings yet',
                      subtitle: hasCriteria
                          ? 'Try a different search or status filter.'
                          : 'Player bookings for your futsal will appear here.',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.metrics.extentAfter < 300 &&
                state.futsalHasMorePages &&
                !state.futsalIsLoadingMore) {
              context.read<BookingBloc>().add(
                const FetchFutsalBookingsEvent(silent: true, loadMore: true),
              );
            }
            return false;
          },
          child: RefreshIndicator(
            color: LightColor.secondaryColor,
            onRefresh: () => _refresh(context),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: _listPadding(context),
              itemCount:
                  items.length +
                  (state.futsalIsLoadingMore ||
                          state.futsalBookingsError != null
                      ? 1
                      : 0),
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimens.paddingX10),
              itemBuilder: (_, i) {
                if (i == items.length) {
                  if (state.futsalIsLoadingMore) {
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
                      onPressed: () => context.read<BookingBloc>().add(
                        const FetchFutsalBookingsEvent(
                          silent: true,
                          loadMore: true,
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Could not load more. Retry'),
                    ),
                  );
                }
                return BookingCard(
                  booking: items[i],
                  showPlayer: true,
                  // Every card carries the footer — it holds the relative
                  // timestamp even when there are no actions (e.g. pending).
                  footer: _BookingCardActions(booking: items[i]),
                  onTap: () async {
                    await context.pushNamed(
                      AppRouterParams.bookingDetails.name,
                      queryParameters: <String, String>{'futsal': 'true'},
                      extra: items[i],
                    );
                    // Refresh with the latest data on returning from details.
                    if (context.mounted) {
                      context.read<BookingBloc>().add(
                        const FetchFutsalBookingsEvent(silent: true),
                      );
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Quick-action chips shown at the bottom of a futsal booking card:
/// "Add products" (confirmed/completed) and "Complete" (confirmed only).
class _BookingCardActions extends StatelessWidget {
  const _BookingCardActions({required this.booking});

  final BookingModel booking;

  void _refresh(BuildContext context) => context.read<BookingBloc>().add(
    const FetchFutsalBookingsEvent(silent: true),
  );

  Future<void> _addProducts(BuildContext context) async {
    final bool? added = await openBookingProductsSheet(context, booking);
    if (added == true && context.mounted) _refresh(context);
  }

  Future<void> _complete(BuildContext context) async {
    final BookingBloc bloc = context.read<BookingBloc>();
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
    if (ok) bloc.add(const FetchFutsalBookingsEvent(silent: true));
  }

  Future<void> _collectDue(BuildContext context) async {
    final BookingCollectDueResult? result = await showCollectBookingDueSheet(
      context,
      booking,
    );
    if (result == null || !context.mounted) return;
    final bool ok = await collectBookingDue(booking.id, result);
    if (!context.mounted) return;
    AppUtils().showSnackBar(
      context,
      ok ? MsgType.success : MsgType.error,
      ok
          ? 'Due amount collected successfully.'
          : 'Could not collect the due amount.',
    );
    if (ok) _refresh(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Wrap(
            spacing: AppDimens.paddingX8,
            runSpacing: AppDimens.paddingX8,
            children: <Widget>[
              if (bookingSupportsProducts(booking))
                BookingActionChip(
                  icon: Icons.add_shopping_cart_rounded,
                  label: booking.extraItemsCount > 0
                      ? 'Products · ${booking.extraItemsCount}'
                      : 'Add products',
                  onTap: () => _addProducts(context),
                ),
              if (bookingCanComplete(booking))
                BookingActionChip(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Complete',
                  onTap: () => _complete(context),
                ),
              if (booking.status == BookingStatus.completed &&
                  booking.amountDueForCollection > 0)
                BookingActionChip(
                  icon: Icons.payments_outlined,
                  label: 'Collect due',
                  onTap: () => _collectDue(context),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.paddingX8),
        BookingTimeAgoLabel(booking: booking),
      ],
    );
  }
}
