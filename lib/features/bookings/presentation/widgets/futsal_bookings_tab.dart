import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_shared_widgets.dart';

class FutsalBookingsTab extends StatelessWidget {
  const FutsalBookingsTab({super.key, this.filter});

  final BookingStatus? filter;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      buildWhen: (p, c) =>
          p.futsalBookingsStatus != c.futsalBookingsStatus ||
          p.futsalBookings != c.futsalBookings,
      builder: (context, state) {
        if (state.futsalBookingsStatus == BookingLoadStatus.loading) {
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

        final List<BookingModel> items = filter == null
            ? state.futsalBookings
            : state.futsalBookings
                  .where((b) => b.status == filter)
                  .toList(growable: false);

        if (items.isEmpty) {
          return BookingEmptyView(
            icon: Icons.sports_soccer_outlined,
            title: filter == null
                ? 'No futsal bookings yet'
                : 'No ${filter!.value} bookings',
            subtitle: filter == null
                ? 'Player bookings for your futsal will appear here.'
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
            showPlayer: true,
            onTap: () => context.pushNamed(
              AppRouterParams.bookingDetails.name,
              queryParameters: <String, String>{'futsal': 'true'},
              extra: items[i],
            ),
          ),
        );
      },
    );
  }
}
