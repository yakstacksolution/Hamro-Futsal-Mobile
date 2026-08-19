import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/helper/wishlist_store.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/footsall_home_page.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/dashboard_layout.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/loading/home_body_loading.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/wishlist/domain/usecase/get_wishlist_use_case.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/app_message_view.dart';

/// Candidate's saved venues tab — `GET /auth/wishlist`.
///
/// The response matches the home venue listing, so the page reuses the same
/// model ([PublicListingVenueModel]) and card ([CourtCard]).
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final GetWishlistUseCase _getWishlist = GetWishlistUseCase(
    PublicRepositoryImpl(),
  );

  bool _loading = true;
  String? _error;
  List<PublicListingVenueModel> _venues = const [];
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    _fetch();
    // Tabs stay alive inside the dashboard's IndexedStack, so a fetch that
    // failed while offline would otherwise show a stale error forever.
    // Re-fetch automatically whenever this tab becomes visible again.
    DashboardScreen.selectedNavIndex.addListener(_retryFailedFetchOnTabVisible);
  }

  @override
  void dispose() {
    DashboardScreen.selectedNavIndex.removeListener(
      _retryFailedFetchOnTabVisible,
    );
    super.dispose();
  }

  void _retryFailedFetchOnTabVisible() {
    if (!mounted || DashboardScreen.selectedNavIndex.value != 3) return;
    if (!_loading) _fetch(silent: _loadedOnce);
  }

  Future<void> _fetch({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      _error = null;
    }
    final result = await _getWishlist();
    if (!mounted) return;
    result.fold(
      (failure) {
        if (silent && _venues.isNotEmpty) {
          setState(() => _error = failure.errorMessage);
          return;
        }
        setState(() {
          _loading = false;
          _error = failure.errorMessage;
        });
      },
      (page) {
        // The fetched wishlist is canonical — re-seed the shared heart state.
        WishlistStore.instance.seed(
          page.venues.map((v) => v.id).whereType<int>().toList(),
        );
        setState(() {
          _loading = false;
          _loadedOnce = true;
          _venues = page.venues;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: WishlistStore.instance.ids,
      builder: (context, ids, _) {
        // Fetched venues narrowed by the live wishlist ids, so un-hearting
        // a card removes it immediately without a refetch.
        final venues = _venues
            .where((v) => v.id == null || ids.contains(v.id))
            .toList(growable: false);
        return _content(context, venues);
      },
    );
  }

  Widget _content(BuildContext context, List<PublicListingVenueModel> venues) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: context.responsive<double>(
              mobile: AppDimens.paddingX20,
              tablet: AppDimens.paddingX32,
            ),
            right: context.responsive<double>(
              mobile: AppDimens.paddingX20,
              tablet: AppDimens.paddingX32,
            ),
            top: AppDimens.paddingX24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StringConstants.wishlist,
                style: textTheme.bodyTextLarge?.copyWith(
                  fontSize: AppDimens.fontHeadingSmall,
                  fontWeight: FontWeight.w700,
                  color: LightColor.primaryTextColor,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX4),
              Text(
                venues.isEmpty
                    ? 'Venues you save for later'
                    : '${venues.length} saved ${venues.length == 1 ? 'venue' : 'venues'}',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _body(venues)),
      ],
    );
  }

  Widget _body(List<PublicListingVenueModel> venues) {
    if (_loading && _venues.isEmpty) {
      return const HomeBodyLoading();
    }
    if (_error != null && _venues.isEmpty) {
      return AppMessageView(
        icon: Icons.wifi_off_rounded,
        title: StringConstants.unableToLoadWishlist,
        message: _error!,
        actionLabel: 'Retry',
        onAction: _fetch,
      );
    }
    if (venues.isEmpty) {
      return const AppMessageView(
        icon: Icons.favorite_outline_rounded,
        title: StringConstants.noFavouritesYet,
        message: StringConstants.tapTheHeartOnAVenueToSaveItHereForQuickBooking,
      );
    }

    return RefreshIndicator(
      color: LightColor.secondaryColor,
      onRefresh: _fetch,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Same helper as the home feed, so both listings agree on how many
          // cards fit -- and both use the same CourtCard.
          final int columns = venueGridColumns(context, constraints.maxWidth);
          final EdgeInsets padding = EdgeInsets.only(
            left: context.responsive<double>(
              mobile: AppDimens.paddingX20,
              tablet: AppDimens.paddingX32,
            ),
            right: context.responsive<double>(
              mobile: AppDimens.paddingX20,
              tablet: AppDimens.paddingX32,
            ),
            top: AppDimens.paddingX10,
            bottom: AppDimens.sizeX120,
          );
          const ScrollPhysics physics = BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          );

          if (columns == 1) {
            return ListView.separated(
              physics: physics,
              padding: padding,
              itemCount: venues.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimens.sizeX20),
              // Same card the home listing uses.
              itemBuilder: (_, i) =>
                  CourtCard(publicListingVenueModel: venues[i]),
            );
          }

          return GridView.builder(
            physics: physics,
            padding: padding,
            itemCount: venues.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: AppDimens.sizeX20,
              mainAxisSpacing: AppDimens.sizeX20,
              mainAxisExtent: AppDimens.courtCardGridExtent,
            ),
            itemBuilder: (_, i) => CourtCard(
              publicListingVenueModel: venues[i],
              flexibleCover: true,
            ),
          );
        },
      ),
    );
  }
}
