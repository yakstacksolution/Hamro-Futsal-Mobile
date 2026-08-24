import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/helper/wishlist_store.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/wishlist/domain/usecase/toggle_wishlist_use_case.dart';

class DetailsImageGallery extends StatefulWidget {
  const DetailsImageGallery({
    super.key,
    this.images = const <String>[],
    this.venueId,
  });

  final List<String> images;

  final int? venueId;

  @override
  State<DetailsImageGallery> createState() => _DetailsImageGalleryState();
}

class _DetailsImageGalleryState extends State<DetailsImageGallery> {
  late final PageController _imagePageController;
  int _currentImageIndex = 0;
  bool _isSaved = false;

  @override
  void initState() {
    _imagePageController = PageController();
    super.initState();
  }

  Future<void> _toggleWishlist() async {
    final int? venueId = widget.venueId;
    HapticFeedback.lightImpact();
    if (venueId == null) {
      setState(() => _isSaved = !_isSaved);
      return;
    }
    final String? error = await ToggleWishlistUseCase(PublicRepositoryImpl())(
      venueId,
    );
    if (error != null && mounted) {
      AppUtils().showSnackBar(context, MsgType.error, error);
    }
  }

  void _showImage(int index) {
    _imagePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isTabletOrWider) return _buildImageGallery(context);

    // Wide layouts get a thumbnail strip: the hero alone gives no sense of how
    // many photos there are without swiping through them.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildImageGallery(context),
        if (widget.images.length > 1) _buildThumbnailStrip(context),
      ],
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    final bool wide = context.isTabletOrWider;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Phones keep the original fixed band. Wider layouts scale 16:9 with
        // the pane -- the pane, not the window, because on desktop the gallery
        // sits in the left column beside the booking card.
        final double height = wide
            ? math.min(
                constraints.maxWidth * 9 / 16,
                AppDimens.venueHeroMaxHeight,
              )
            : 340;
        return SizedBox(
          height: height,
          child: BackdropGroup(
            // All frosted controls can reuse one backdrop capture while the
            // hero moves beneath them, avoiding several blur passes per frame.
            child: Stack(
              children: [
                widget.images.isEmpty
                    ? Container(color: LightColor.inputFillColor)
                    : PageView.builder(
                        controller: _imagePageController,
                        // Build neighbouring slides early so their resized image
                        // starts loading before the user's swipe reaches it.
                        allowImplicitScrolling: true,
                        itemCount: widget.images.length,
                        onPageChanged: (i) =>
                            setState(() => _currentImageIndex = i),
                        itemBuilder: (context, index) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomImageView(
                                url: widget.images[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                cacheWidth: constraints.maxWidth,
                                cacheHeight: height,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 120,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        LightColor.transparentColor,
                                        LightColor.primaryTextColor.withValues(
                                          alpha: 0.5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: wide ? AppDimens.paddingX24 : 16,
                  right: wide ? AppDimens.paddingX24 : 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _glassButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      Row(
                        children: [
                          _glassButton(
                            icon: Icons.share_outlined,
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          // Heart follows the shared wishlist store when a venue id
                          // is available.
                          ValueListenableBuilder<Set<int>>(
                            valueListenable: WishlistStore.instance.ids,
                            builder: (context, ids, _) {
                              final bool saved = widget.venueId != null
                                  ? ids.contains(widget.venueId)
                                  : _isSaved;
                              return _glassButton(
                                icon: saved
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                iconColor: saved
                                    ? LightColor.secondaryColor
                                    : LightColor.primaryTextColor,
                                onTap: _toggleWishlist,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.images.isNotEmpty && !wide)
                        Row(
                          children: List.generate(widget.images.length, (i) {
                            final active = i == _currentImageIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 6),
                              width: active ? 24 : 8,
                              height: 6,
                              decoration: BoxDecoration(
                                color: active
                                    ? LightColor.whiteColor
                                    : LightColor.whiteColor.withValues(
                                        alpha: 0.4,
                                      ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                            );
                          }),
                        ),
                      if (widget.images.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter.grouped(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: LightColor.primaryTextColor.withValues(
                                  alpha: 0.35,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: LightColor.onBrandSurface.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.photo,
                                    color: LightColor.inverseTextColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${_currentImageIndex + 1}/${widget.images.length}',
                                    style: TextStyle(
                                      color: LightColor.inverseTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnailStrip(BuildContext context) {
    return SizedBox(
      height: AppDimens.venueThumbnailSize + AppDimens.sizeX20,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX24,
          vertical: AppDimens.paddingX10,
        ),
        itemCount: widget.images.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.sizeX8),
        itemBuilder: (BuildContext context, int index) {
          final bool active = index == _currentImageIndex;
          return GestureDetector(
            onTap: () => _showImage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: AppDimens.venueThumbnailSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                border: Border.all(
                  color: active
                      ? LightColor.secondaryColor
                      : LightColor.dividerColor,
                  width: active ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                child: CustomImageView(
                  url: widget.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  cacheWidth: AppDimens.venueThumbnailSize,
                  cacheHeight: AppDimens.venueThumbnailSize,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              // Soft frosted cream background so the dark icons stay legible
              // over any image without looking starkly white.
              color: LightColor.elevatedCardColor.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: LightColor.primaryTextColor.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: LightColor.primaryTextColor.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor ?? context.appColors.primaryText,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
