import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/recent_bookings_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/overall_performance_widget.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookingBloc>(
      create: (_) => BookingBloc(GetBookingsUseCase(BookingRepositoryImpl()))
        ..add(const FetchFutsalBookingsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Overview'), centerTitle: true),
        body: ListView(
          key: const ValueKey<String>('overview'),
          padding: AppUtils().getPadding(
            left: AppDimens.paddingX20,
            right: AppDimens.paddingX20,
            bottom: AppDimens.paddingX24,
            top: AppDimens.paddingX8,
          ),
          children: const <Widget>[
            OverallPerformanceWidget(),
            SizedBox(height: AppDimens.sizeX20),
            RecentBookingsWidget(),
          ],
        ),
      ),
    );
  }
}
