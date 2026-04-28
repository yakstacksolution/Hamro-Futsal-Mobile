import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/overall_performance_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/recent_bookings_widget.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overview'), centerTitle: true),
      body: _overviewSection(),
    );
  }

  Widget _overviewSection() {
    return ListView(
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
    );
  }
}
