import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/public/data/model/help_video_model.dart';
import 'package:hamro_futsal/features/public/presentation/pages/help_video_player_page.dart';

/// The Videos tab of Help & FAQ.
///
/// A player sees the player guides straight away. A vendor also runs the
/// player side of the app, so they get a Player / Vendor switch above the list
/// and start on the vendor guides. Guides marked for everyone show on both
/// sides.
class HelpVideosTab extends StatefulWidget {
  const HelpVideosTab({
    super.key,
    required this.isVendor,
    required this.videos,
    required this.onRefresh,
  });

  final bool isVendor;

  /// Every guide from `GET /youtube-videos`, both audiences.
  final List<HelpVideo> videos;

  /// Pull-to-refresh; completes when the refetch has finished.
  final Future<void> Function() onRefresh;

  @override
  State<HelpVideosTab> createState() => _HelpVideosTabState();
}

class _HelpVideosTabState extends State<HelpVideosTab> {
  late HelpVideoAudience _audience = widget.isVendor
      ? HelpVideoAudience.vendor
      : HelpVideoAudience.player;

  List<HelpVideo> get _visible => widget.videos
      .where((HelpVideo v) => v.audience.includes(_audience))
      .toList(growable: false);

  Future<void> _play(HelpVideo video) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HelpVideoPlayerPage(initial: video, playlist: _visible),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<HelpVideo> videos = _visible;
    return RefreshIndicator(
      color: LightColor.secondaryColor,
      onRefresh: widget.onRefresh,
      child: _buildScrollView(videos),
    );
  }

  Widget _buildScrollView(List<HelpVideo> videos) {
    return CustomScrollView(
      // Always scrollable so pull-to-refresh works on a short list too.
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverPadding(
          padding: AppUtils().getPadding(
            left: AppDimens.paddingX16,
            right: AppDimens.paddingX16,
            top: AppDimens.paddingX16,
          ),
          sliver: SliverList.list(
            children: <Widget>[
              if (widget.isVendor) ...<Widget>[
                _AudienceSwitch(
                  value: _audience,
                  onChanged: (HelpVideoAudience value) =>
                      setState(() => _audience = value),
                ),
                const SizedBox(height: AppDimens.sizeX16),
              ],
              _IntroHeader(audience: _audience, count: videos.length),
              const SizedBox(height: AppDimens.sizeX16),
            ],
          ),
        ),
        if (videos.isEmpty)
          const SliverFillRemaining(hasScrollBody: false, child: _EmptyVideos())
        else ...<Widget>[
          SliverPadding(
            padding: AppUtils().getPadding(
              symmetricHorizontal: AppDimens.paddingX16,
            ),
            sliver: SliverToBoxAdapter(
              child: _FeaturedVideoCard(
                // Keyed per audience so switching replays the entry fade.
                key: ValueKey<HelpVideoAudience>(_audience),
                video: videos.first,
                onTap: () => _play(videos.first),
              ),
            ),
          ),
          if (videos.length > 1) ...<Widget>[
            SliverPadding(
              padding: AppUtils().getPadding(
                left: AppDimens.paddingX16,
                right: AppDimens.paddingX16,
                top: AppDimens.paddingX24,
                bottom: AppDimens.paddingX12,
              ),
              sliver: SliverToBoxAdapter(
                child: _SectionTitle(StringConstants.moreVideos),
              ),
            ),
            SliverPadding(
              padding: AppUtils().getPadding(
                left: AppDimens.paddingX16,
                right: AppDimens.paddingX16,
                bottom: AppDimens.paddingX24,
              ),
              sliver: SliverList.separated(
                itemCount: videos.length - 1,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimens.sizeX12),
                itemBuilder: (BuildContext context, int index) {
                  final HelpVideo video = videos[index + 1];
                  return HelpVideoRow(video: video, onTap: () => _play(video));
                },
              ),
            ),
          ] else
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimens.sizeX24),
            ),
        ],
      ],
    );
  }
}

/// Segmented Player / Vendor switch, shown to vendors only.
class _AudienceSwitch extends StatelessWidget {
  const _AudienceSwitch({required this.value, required this.onChanged});

  final HelpVideoAudience value;
  final ValueChanged<HelpVideoAudience> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX4),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          _AudienceOption(
            label: StringConstants.playerGuides,
            icon: Icons.sports_soccer_rounded,
            selected: value == HelpVideoAudience.player,
            onTap: () => onChanged(HelpVideoAudience.player),
          ),
          _AudienceOption(
            label: StringConstants.vendorGuides,
            icon: Icons.storefront_rounded,
            selected: value == HelpVideoAudience.vendor,
            onTap: () => onChanged(HelpVideoAudience.vendor),
          ),
        ],
      ),
    );
  }
}

class _AudienceOption extends StatelessWidget {
  const _AudienceOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color foreground = selected
        ? LightColor.inverseTextColor
        : LightColor.secondaryTextColor;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: AppUtils().getPadding(
              symmetricVertical: AppDimens.paddingX10,
            ),
            decoration: BoxDecoration(
              color: selected ? LightColor.secondaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: AppDimens.sizeX16, color: foreground),
                const SizedBox(width: AppDimens.sizeX6),
                Text(
                  label,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Title + subtitle + count badge above the list.
class _IntroHeader extends StatelessWidget {
  const _IntroHeader({required this.audience, required this.count});

  final HelpVideoAudience audience;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool vendor = audience == HelpVideoAudience.vendor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                vendor
                    ? StringConstants.runYourVenue
                    : StringConstants.learnTheBasics,
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LightColor.primaryTextColor,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX4),
              Text(
                vendor
                    ? StringConstants.vendorVideosSubtitle
                    : StringConstants.playerVideosSubtitle,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.sizeX12),
        Container(
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX10,
            symmetricVertical: AppDimens.paddingX4,
          ),
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.play_circle_outline_rounded,
                size: AppDimens.sizeX14,
                color: LightColor.brandTextColor,
              ),
              const SizedBox(width: AppDimens.sizeX4),
              Text(
                '$count ${count == 1 ? 'video' : 'videos'}',
                style: textTheme.bodyMiniSubTitle?.copyWith(
                  color: LightColor.brandTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: LightColor.primaryTextColor,
        letterSpacing: 0.2,
      ),
    );
  }
}

/// Large 16:9 card for the first video of the list.
class _FeaturedVideoCard extends StatelessWidget {
  const _FeaturedVideoCard({
    super.key,
    required this.video,
    required this.onTap,
  });

  final HelpVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusX16);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double t, Widget? child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 12),
          child: child,
        ),
      ),
      child: Material(
        color: LightColor.cardColor,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: LightColor.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      _VideoThumbnail(video: video),
                      // Darkens the lower half so the chips stay readable
                      // over a bright thumbnail.
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.transparent,
                              Color(0x99000000),
                            ],
                          ),
                        ),
                      ),
                      const Center(child: _PlayButton(size: AppDimens.sizeX56)),
                      Positioned(
                        left: AppDimens.paddingX12,
                        top: AppDimens.paddingX12,
                        child: _OverlayChip(
                          icon: Icons.star_rounded,
                          label: StringConstants.startHere,
                        ),
                      ),
                      if (video.duration != null)
                        Positioned(
                          right: AppDimens.paddingX12,
                          bottom: AppDimens.paddingX12,
                          child: _OverlayChip(label: video.duration!),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: AppUtils().getPadding(all: AppDimens.paddingX14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (video.category != null) ...<Widget>[
                        _CategoryLabel(video.category!),
                        const SizedBox(height: AppDimens.sizeX6),
                      ],
                      Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: LightColor.primaryTextColor,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact row: thumbnail on the left, title and meta on the right. Also used
/// for the player page's "Up next" list.
class HelpVideoRow extends StatelessWidget {
  const HelpVideoRow({super.key, required this.video, required this.onTap});

  final HelpVideo video;
  final VoidCallback onTap;

  static const double _thumbWidth = 128;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusX12);
    return Material(
      color: LightColor.cardColor,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: AppUtils().getPadding(all: AppDimens.paddingX8),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: LightColor.dividerColor),
          ),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                child: SizedBox(
                  width: _thumbWidth,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        _VideoThumbnail(video: video),
                        const Center(
                          child: _PlayButton(size: AppDimens.sizeX32),
                        ),
                        if (video.duration != null)
                          Positioned(
                            right: AppDimens.paddingX4,
                            bottom: AppDimens.paddingX4,
                            child: _OverlayChip(
                              label: video.duration!,
                              dense: true,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (video.category != null) ...<Widget>[
                      _CategoryLabel(video.category!),
                      const SizedBox(height: AppDimens.sizeX4),
                    ],
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: LightColor.primaryTextColor,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.sizeX4),
              Icon(
                Icons.chevron_right_rounded,
                size: AppDimens.sizeX20,
                color: LightColor.secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The video's thumbnail — the server's own, else YouTube's.
class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({required this.video});

  final HelpVideo video;

  @override
  Widget build(BuildContext context) {
    return CustomImageView(
      url: video.thumbnailUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

/// White disc with a YouTube-red play glyph.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        size: size * 0.62,
        color: const Color(0xFFFF0000),
      ),
    );
  }
}

/// Small translucent-dark label over a thumbnail (duration, "Start here").
class _OverlayChip extends StatelessWidget {
  const _OverlayChip({required this.label, this.icon, this.dense = false});

  final String label;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(
        symmetricHorizontal: dense ? AppDimens.paddingX4 : AppDimens.paddingX8,
        symmetricVertical: dense ? 1 : AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(
          dense ? AppDimens.radiusX4 : AppDimens.radiusX20,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: AppDimens.sizeX12, color: const Color(0xFFFFC83D)),
            const SizedBox(width: AppDimens.sizeX4),
          ],
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
        color: LightColor.brandTextColor,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        fontSize: 10,
      ),
    );
  }
}

class _EmptyVideos extends StatelessWidget {
  const _EmptyVideos();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(all: AppDimens.paddingX24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.ondemand_video_rounded,
            size: AppDimens.sizeX40,
            color: LightColor.iconGrey,
          ),
          const SizedBox(height: AppDimens.sizeX12),
          Text(
            StringConstants.noVideosYet,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX4),
          Text(
            StringConstants.noVideosYetMessage,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
