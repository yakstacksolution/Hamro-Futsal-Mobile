import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';

/// Picker for the "I have already booked a venue" branch: lists the courts the
/// user has already booked (upcoming, not cancelled) so the request reuses a
/// real booking instead of re-typing the venue. Pops with the tapped booking,
/// or null when dismissed.
Future<BookingModel?> showExistingBookingSheet(BuildContext context) {
  return showModalBottomSheet<BookingModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: LightColor.whiteColor,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppDimens.radiusX16),
        topRight: Radius.circular(AppDimens.radiusX16),
      ),
    ),
    builder: (_) => BlocProvider<BookingBloc>(
      create: (_) =>
          BookingBloc(GetBookingsUseCase(BookingRepositoryImpl()))
            ..add(const FetchMyBookingsEvent()),
      child: const _ExistingBookingSheet(),
    ),
  );
}

class _ExistingBookingSheet extends StatefulWidget {
  const _ExistingBookingSheet();

  @override
  State<_ExistingBookingSheet> createState() => _ExistingBookingSheetState();
}

class _ExistingBookingSheetState extends State<_ExistingBookingSheet> {
  String _query = '';

  /// Only bookings that can still host a match: confirmed or pending, and not
  /// already in the past.
  List<BookingModel> _selectable(List<BookingModel> all) {
    final DateTime cutoff = DateTime.now().subtract(const Duration(hours: 3));
    final String q = _query.trim().toLowerCase();
    return all
        .where(
          (b) =>
              b.status != BookingStatus.cancelled &&
              b.status != BookingStatus.rejected &&
              b.date.isAfter(cutoff),
        )
        .where(
          (b) =>
              q.isEmpty ||
              b.futsalName.toLowerCase().contains(q) ||
              b.courtName.toLowerCase().contains(q) ||
              b.bookingRef.toLowerCase().contains(q),
        )
        .toList(growable: false)
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: AppDimens.sizeX2,
                width: AppDimens.sizeX110,
                margin: AppUtils().getMargin(
                  top: AppDimens.marginX22,
                  bottom: AppDimens.marginX20,
                ),
                decoration: BoxDecoration(
                  color: LightColor.greyBorderColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
              ),
            ),
            Padding(
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select an existing booking',
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX4),
                  Text(
                    'The court, date, time and fee are taken from the booking '
                    'you pick.',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX12),
                  CustomTextField(
                    labelText: StringConstants.search,
                    hintText: 'Venue, court or booking reference',
                    icon: Icons.search_rounded,
                    isRequired: false,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX10),
            Expanded(
              child: BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  if (state.myBookingsStatus == BookingLoadStatus.loading ||
                      state.myBookingsStatus == BookingLoadStatus.idle) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: LightColor.secondaryColor,
                      ),
                    );
                  }
                  if (state.myBookingsStatus == BookingLoadStatus.failure &&
                      state.myBookings.isEmpty) {
                    return Center(
                      child: TextButton.icon(
                        onPressed: () => context.read<BookingBloc>().add(
                          const FetchMyBookingsEvent(),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          state.myBookingsError ??
                              'Could not load your bookings. Retry',
                        ),
                      ),
                    );
                  }
                  final bookings = _selectable(state.myBookings);
                  if (bookings.isEmpty) {
                    return _Empty(hasQuery: _query.trim().isNotEmpty);
                  }
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: AppUtils().getPadding(
                      symmetricHorizontal: AppDimens.paddingX16,
                      bottom: AppDimens.paddingX24,
                    ),
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimens.paddingX10),
                    itemBuilder: (_, i) => _BookingTile(booking: bookings[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool confirmed = booking.status == BookingStatus.confirmed;
    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        onTap: () => Navigator.of(context).pop(booking),
        child: Container(
          padding: AppUtils().getPadding(all: AppDimens.paddingX12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(color: LightColor.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: AppDimens.sizeX40,
                height: AppDimens.sizeX40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  size: AppDimens.sizeX20,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        booking.courtName,
                        booking.futsalName,
                      ].where((s) => s.trim().isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      '${OpponentFmt.shortDate(booking.date)}'
                      '${booking.displayTimeRange.isEmpty ? '' : ' · ${booking.displayTimeRange}'}',
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      OpponentFmt.npr(booking.bookingTotal.round()),
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: LightColor.secondaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: confirmed
                      ? LightColor.secondaryColor.withValues(alpha: 0.10)
                      : LightColor.warningLightColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                ),
                child: Text(
                  confirmed ? 'Confirmed' : 'Pending',
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontSize: AppDimens.fontBodySubTitle,
                    fontWeight: FontWeight.w600,
                    color: confirmed
                        ? LightColor.secondaryColor
                        : LightColor.warningColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: AppUtils().getPadding(all: AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy_outlined,
              size: 36,
              color: LightColor.hintTextColor,
            ),
            const SizedBox(height: AppDimens.paddingX12),
            Text(
              hasQuery
                  ? 'No booking matches your search.'
                  : 'You have no upcoming bookings to attach.\nBook a court '
                        'first, or enter the venue manually.',
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
