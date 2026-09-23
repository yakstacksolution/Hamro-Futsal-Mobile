import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/presentation/pages/bookings_page.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_status_page.dart';
import 'package:hamro_futsal/features/dashboard/presentation/page/dashboard_screen.dart';

/// Index of the bookings tab inside [DashboardScreen]'s bottom navigation.
const int bookingsTabIndex = 1;

/// Opens a booking's details with the bookings list underneath it.
///
/// Both entry points into the details page — a booking notification and the
/// end of the checkout flow — want the same thing: pressing back lands on the
/// list the booking belongs to, never back inside the funnel the user came
/// from. So the stack is reset to the dashboard, the bookings tab is selected,
/// and the details page is pushed on top of it.
///
/// [booking] only has to carry a real `id`; the details page fetches the rest.
Future<void> openBookingDetails(
  BuildContext context, {
  required BookingModel booking,
  bool isFutsalView = false,
}) async {
  final GoRouter router = GoRouter.of(context);

  // The list behind the details page is the one this booking belongs to:
  // the venue's own list for a vendor, the player's otherwise.
  BookingsPage.requestedList.value = isFutsalView
      ? BookingListKind.futsal
      : BookingListKind.mine;
  DashboardScreen.selectedNavIndex.value = bookingsTabIndex;

  // Drop the funnel (venue -> slots -> checkout) before pushing the details,
  // so back from details goes to the bookings list.
  router.go(AppRouterParams.dashboard.path);
  // Let the shell rebuild on the reset stack before the details page goes on
  // top of it; pushing in the same frame can land on the outgoing route.
  await WidgetsBinding.instance.endOfFrame;
  await router.pushNamed<void>(
    AppRouterParams.bookingDetails.name,
    queryParameters: <String, String>{
      'futsal': isFutsalView ? 'true' : 'false',
    },
    extra: booking,
  );
}

/// A details-page seed for a booking the app has only just created.
///
/// The page refetches by id on open, so this only has to carry enough to paint
/// the first frame without an empty header.
BookingModel bookingSeed({
  required int id,
  String? courtName,
  String? futsalName,
  DateTime? date,
  String? startTime,
  String? endTime,
}) => BookingModel.fromJson(<String, dynamic>{
  'id': id,
  if (courtName != null) 'court_name': courtName,
  if (futsalName != null) 'futsal_name': futsalName,
  if (date != null) 'booking_date': date.toIso8601String(),
  if (startTime != null) 'start_time': startTime,
  if (endTime != null) 'end_time': endTime,
});
