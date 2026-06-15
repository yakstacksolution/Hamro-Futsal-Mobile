import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_shared_widgets.dart';

class MyBookingsTab extends StatelessWidget {
  const MyBookingsTab({super.key, this.filter});

  final BookingStatus? filter;

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

        final List<BookingModel> items = filter == null
            ? state.myBookings
            : state.myBookings
                .where((b) => b.status == filter)
                .toList(growable: false);

        if (items.isEmpty) {
          return BookingEmptyView(
            icon: Icons.calendar_month_outlined,
            title: filter == null ? 'No bookings yet' : 'No ${filter!.value} bookings',
            subtitle: filter == null
                ? 'Your upcoming court bookings will appear here.'
                : 'Try a different filter.',
          );
        }

        return ListView.separated(
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
