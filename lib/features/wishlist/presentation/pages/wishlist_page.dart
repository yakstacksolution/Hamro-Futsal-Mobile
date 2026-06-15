import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/helper/wishlist_store.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/footsall_home_page.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/loading/home_body_loading.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/wishlist/domain/usecase/get_wishlist_use_case.dart';

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
    if (_error != null && !_loading) _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _getWishlist();
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.errorMessage;
      }),
      (page) {
        // The fetched wishlist is canonical — re-seed the shared heart state.
        WishlistStore.instance.seed(
          page.venues.map((v) => v.id).whereType<int>().toList(),
        );
        setState(() {
          _loading = false;
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
          padding: AppUtils().getPadding(
            left: AppDimens.paddingX20,
            right: AppDimens.paddingX20,
            top: AppDimens.paddingX24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wishlist',
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
      return _MessageView(
        icon: Icons.wifi_off_rounded,
        title: 'Unable to load wishlist',
        message: _error!,
        actionLabel: 'Retry',
        onAction: _fetch,
      );
    }
    if (venues.isEmpty) {
      return const _MessageView(
        icon: Icons.favorite_outline_rounded,
        title: 'No favourites yet',
        message: 'Tap the heart on a venue to save it here for quick booking.',
      );
    }

    return RefreshIndicator(
      color: LightColor.secondaryColor,
      onRefresh: _fetch,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: AppUtils().getPadding(
          left: AppDimens.paddingX20,
          right: AppDimens.paddingX20,
          top: AppDimens.paddingX10,
          bottom: AppDimens.sizeX120,
        ),
        itemCount: venues.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimens.sizeX20),
        // Same card the home listing uses.
        itemBuilder: (_, i) => CourtCard(court: venues[i]),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: AppUtils().getPadding(all: AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: LightColor.secondaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              title,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppDimens.paddingX18),
              CustomButton(
                text: actionLabel!,
                icon: Icons.refresh_rounded,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
