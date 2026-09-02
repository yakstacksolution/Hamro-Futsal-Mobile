import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';
import 'package:hamro_futsal/features/public/presentation/bloc/public_venue/public_venue_bloc.dart';

/// Searchable venue picker for the "find an available court slot" path.
/// Filters the public venue list by name/address as you type; pops with the
/// tapped venue (or null when dismissed).
Future<PublicListingVenueModel?> showVenueSearchSheet(
  BuildContext context, {
  required PublicVenueBloc bloc,
}) {
  return showModalBottomSheet<PublicListingVenueModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.surfaceElevated,
    barrierColor: LightColor.scrimColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppDimens.radiusX16),
        topRight: Radius.circular(AppDimens.radiusX16),
      ),
    ),
    builder: (_) =>
        BlocProvider.value(value: bloc, child: const _VenueSearchSheet()),
  );
}

class _VenueSearchSheet extends StatefulWidget {
  const _VenueSearchSheet();

  @override
  State<_VenueSearchSheet> createState() => _VenueSearchSheetState();
}

class _VenueSearchSheetState extends State<_VenueSearchSheet> {
  String _query = '';

  List<PublicListingVenueModel> _filtered(List<PublicListingVenueModel> all) {
    final q = _query.trim().toLowerCase();
    final bookable = all.where((v) => v.id != null);
    if (q.isEmpty) return bookable.toList(growable: false);
    return bookable
        .where(
          (v) =>
              (v.name ?? '').toLowerCase().contains(q) ||
              (v.address ?? '').toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
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
                    StringConstants.preferredVenue,
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX12),
                  CustomTextField(
                    labelText: StringConstants.search,
                    hintText: StringConstants.searchVenuesCourtsOrLocation,
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
              child: BlocBuilder<PublicVenueBloc, PublicVenueState>(
                builder: (context, state) {
                  if ((state.status == PublicVenueStatus.idle ||
                          state.status == PublicVenueStatus.loading) &&
                      state.venues.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: LightColor.secondaryColor,
                      ),
                    );
                  }
                  if (state.status == PublicVenueStatus.failure &&
                      state.venues.isEmpty) {
                    return Center(
                      child: TextButton.icon(
                        onPressed: () => context.read<PublicVenueBloc>().add(
                          const FetchPublicVenuesEvent(),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          state.errorMessage ?? 'Could not load venues. Retry',
                        ),
                      ),
                    );
                  }
                  final venues = _filtered(state.venues);
                  if (venues.isEmpty) {
                    return Center(
                      child: Text(
                        'No venues match "$_query".',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryTextColor,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: AppUtils().getPadding(
                      symmetricHorizontal: AppDimens.paddingX16,
                      bottom: AppDimens.paddingX24,
                    ),
                    itemCount: venues.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: LightColor.dividerColor),
                    itemBuilder: (_, i) {
                      final venue = venues[i];
                      return ListTile(
                        contentPadding: AppUtils().getPadding(
                          symmetricHorizontal: AppDimens.paddingX4,
                        ),
                        leading: const Icon(
                          Icons.stadium_outlined,
                          color: LightColor.secondaryColor,
                        ),
                        title: Text(
                          venue.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: (venue.address ?? '').trim().isEmpty
                            ? null
                            : Text(
                                venue.address!.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMiniSubTitle?.copyWith(
                                  color: LightColor.secondaryTextColor,
                                ),
                              ),
                        onTap: () => Navigator.of(context).pop(venue),
                      );
                    },
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
