import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/utils/booking_search.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_shared_widgets.dart';

class MyBookingsTab extends StatelessWidget {
  const MyBookingsTab({
    super.key,
    this.filter,
    this.searchQuery = '',
    this.dateOrder = BookingDateOrder.ascending,
    this.fromDate,
    this.toDate,
  });

  final BookingStatus? filter;
  final String searchQuery;
  final BookingDateOrder dateOrder;
  final DateTime? fromDate;
  final DateTime? toDate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      buildWhen: (p, c) =>
          p.myBookingsStatus != c.myBookingsStatus ||
          p.myBookings != c.myBookings,
      builder: (context, state) {
        if (state.myBookingsStatus == BookingLoadStatus.loading) {
          return const BookingSkeletonLoader();
        }

        if (state.myBookingsStatus == BookingLoadStatus.failure) {
          return BookingErrorView(
            message: state.myBookingsError ?? 'Failed to load bookings.',
            onRetry: () =>
                context.read<BookingBloc>().add(const FetchMyBookingsEvent()),
          );
        }

        final List<BookingModel> items = sortBookingsByDate(
          state.myBookings.where((BookingModel booking) {
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

        if (items.isEmpty) {
          final bool hasCriteria =
              filter != null ||
              searchQuery.trim().isNotEmpty ||
              fromDate != null ||
              toDate != null;
          return BookingEmptyView(
            icon: Icons.calendar_month_outlined,
            title: hasCriteria ? 'No matching bookings' : 'No bookings yet',
            subtitle: hasCriteria
                ? 'Try a different search or status filter.'
                : 'Your upcoming court bookings will appear here.',
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX16,
            top: AppDimens.paddingX8,
            bottom: AppDimens.paddingX50,
          ),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimens.paddingX10),
          itemBuilder: (_, i) => BookingCard(
            booking: items[i],
            onTap: () => context.pushNamed(
              AppRouterParams.bookingDetails.name,
              extra: items[i],
            ),
          ),
        );
      },
    );
  }
}
