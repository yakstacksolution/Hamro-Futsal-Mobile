import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/features/public/data/model/help_video_model.dart';
import 'package:hamro_futsal/features/public/presentation/widgets/help_videos_tab.dart';

/// Plays a Help & FAQ video guide inside the app with the YouTube iFrame
/// player, with the rest of the guides listed under it as "Up next".
///
/// Picking another guide swaps the video in the same player rather than
/// pushing a new page, so back always returns to the Videos tab.
class HelpVideoPlayerPage extends StatefulWidget {
  const HelpVideoPlayerPage({
    super.key,
    required this.initial,
    required this.playlist,
  });

  /// The guide to start with.
  final HelpVideo initial;

  /// Every playable guide for the same audience, [initial] included.
  final List<HelpVideo> playlist;

  @override
  State<HelpVideoPlayerPage> createState() => _HelpVideoPlayerPageState();
}

class _HelpVideoPlayerPageState extends State<HelpVideoPlayerPage> {
  late final YoutubePlayerController _controller;
  final ScrollController _scrollController = ScrollController();
  late HelpVideo _current = widget.initial;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _current.youtubeId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    _scrollController.dispose();
    super.dispose();
  }

  List<HelpVideo> get _upNext => widget.playlist
      // By guide, not by video id: several guides can share one video.
      .where((HelpVideo v) => v != _current)
      .toList(growable: false);

  void _select(HelpVideo video) {
    setState(() => _current = video);
    _controller.loadVideoById(videoId: video.youtubeId);
    // Bring the details of the new video back into view.
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<HelpVideo> upNext = _upNext;
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.videos),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            // Pinned above the scrolling details, so the video keeps playing
            // in view while the user browses what is next.
            ColoredBox(
              color: Colors.black,
              child: YoutubePlayer(
                controller: _controller,
                backgroundColor: Colors.black,
              ),
            ),
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverToBoxAdapter(child: _VideoDetails(video: _current)),
                  if (upNext.isNotEmpty) ...<Widget>[
                    SliverPadding(
                      padding: AppUtils().getPadding(
                        left: AppDimens.paddingX16,
                        right: AppDimens.paddingX16,
                        top: AppDimens.paddingX8,
                        bottom: AppDimens.paddingX12,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          StringConstants.upNext,
                          style: FutsalTheme.getTextTheme(context).bodyTextSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: LightColor.primaryTextColor,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: AppUtils().getPadding(
                        left: AppDimens.paddingX16,
                        right: AppDimens.paddingX16,
                        bottom: AppDimens.paddingX24,
                      ),
                      sliver: SliverList.separated(
                        itemCount: upNext.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppDimens.sizeX12),
                        itemBuilder: (BuildContext context, int index) =>
                            HelpVideoRow(
                              video: upNext[index],
                              onTap: () => _select(upNext[index]),
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category, duration, title and description of the video that is playing.
class _VideoDetails extends StatelessWidget {
  const _VideoDetails({required this.video});

  final HelpVideo video;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      margin: AppUtils().getPadding(all: AppDimens.paddingX16),
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (video.category != null || video.duration != null) ...<Widget>[
            Row(
              children: <Widget>[
                if (video.category != null)
                  Flexible(
                    child: Container(
                      padding: AppUtils().getPadding(
                        symmetricHorizontal: AppDimens.paddingX8,
                        symmetricVertical: AppDimens.paddingX4,
                      ),
                      decoration: BoxDecoration(
                        color: LightColor.secondaryColor.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusX20,
                        ),
                      ),
                      child: Text(
                        video.category!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMiniSubTitle?.copyWith(
                          color: LightColor.brandTextColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                if (video.duration != null) ...<Widget>[
                  Icon(
                    Icons.schedule_rounded,
                    size: AppDimens.sizeX14,
                    color: LightColor.secondaryTextColor,
                  ),
                  const SizedBox(width: AppDimens.sizeX4),
                  Text(
                    video.duration!,
                    style: textTheme.bodyMiniSubTitle?.copyWith(
                      color: LightColor.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimens.sizeX8),
          ],
          Text(
            video.title,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
              height: 1.3,
            ),
          ),
          if (video.description != null) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX8),
            Text(
              video.description!,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
