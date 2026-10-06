import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_html_viewer.dart';
import 'package:hamro_futsal/core/widgets/loading_widget.dart';
import 'package:hamro_futsal/features/public/data/model/public_faq_model.dart';
import 'package:hamro_futsal/features/public/data/model/public_help_model.dart';
import 'package:hamro_futsal/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_futsal/features/public/domain/repository/public_repository.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_faqs_use_case.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_helps_use_case.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_youtube_videos_use_case.dart';
import 'package:hamro_futsal/features/public/presentation/bloc/support/support_bloc.dart';
import 'package:hamro_futsal/features/public/presentation/widgets/help_videos_tab.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key, this.isVendor = false, this.repository});

  final bool isVendor;

  @visibleForTesting
  final PublicRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupportBloc>(
      create: (_) {
        final PublicRepository repository =
            this.repository ?? PublicRepositoryImpl();
        return SupportBloc(
            GetFaqsUseCase(repository),
            GetHelpsUseCase(repository),
            GetYoutubeVideosUseCase(repository),
          )
          ..add(const FetchFaqsEvent())
          ..add(const FetchHelpsEvent())
          ..add(const FetchVideosEvent());
      },
      child: _HelpFaqView(isVendor: isVendor),
    );
  }
}

class _HelpFaqView extends StatelessWidget {
  const _HelpFaqView({required this.isVendor});

  final bool isVendor;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    // Tablet / desktop: a help-centre layout instead of the phone's tabs.
    if (context.isTabletOrWider) {
      return Scaffold(
        backgroundColor: LightColor.background,
        appBar: const CustomAppBar(title: StringConstants.helpAndFaq),
        body: SafeArea(top: false, child: _HelpCenterWide(isVendor: isVendor)),
      );
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: LightColor.background,
        appBar: const CustomAppBar(title: StringConstants.helpAndFaq),
        body: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              TabBar(
                labelColor: LightColor.secondaryColor,
                unselectedLabelColor: LightColor.secondaryTextColor,
                indicatorColor: LightColor.secondaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: LightColor.dividerColor,
                labelStyle: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                tabs: const <Widget>[
                  Tab(text: StringConstants.faqs, height: 40),
                  Tab(text: StringConstants.help, height: 40),
                  Tab(text: StringConstants.videos, height: 40),
                ],
              ),
              Expanded(
                child: BlocBuilder<SupportBloc, SupportState>(
                  builder: (BuildContext context, SupportState state) {
                    return TabBarView(
                      children: <Widget>[
                        _SupportTab(
                          status: state.faqsStatus,
                          isEmpty: state.faqs.isEmpty,
                          errorMessage:
                              state.faqsError ?? 'Could not load FAQs.',
                          emptyTitle: 'No FAQs yet',
                          emptyMessage:
                              'Frequently asked questions will appear here.',
                          onRetry: () => context.read<SupportBloc>().add(
                            const FetchFaqsEvent(),
                          ),
                          child: _FaqList(faqs: state.faqs),
                        ),
                        Builder(
                          builder: (BuildContext context) {
                            final List<_SocialChannel> socials =
                                _socialChannelsFromHelps(state.helps);
                            final List<PublicHelpModel> otherHelps = state.helps
                                .where((PublicHelpModel h) => !_isSocialHelp(h))
                                .toList(growable: false);
                            // Social links come from the same payload, so once
                            // any exist the tab has loaded and can render as
                            // one scrollable list (links first, then topics).
                            if (socials.isNotEmpty) {
                              return _HelpList(
                                header: _SocialConnectSection(
                                  channels: socials,
                                ),
                                helps: otherHelps,
                              );
                            }
                            return _SupportTab(
                              status: state.helpsStatus,
                              isEmpty: otherHelps.isEmpty,
                              errorMessage:
                                  state.helpsError ??
                                  'Could not load help topics.',
                              emptyTitle: 'No help topics yet',
                              emptyMessage:
                                  'Help and how-to guides will appear here.',
                              onRetry: () => context.read<SupportBloc>().add(
                                const FetchHelpsEvent(),
                              ),
                              child: _HelpList(helps: otherHelps),
                            );
                          },
                        ),
                        _SupportTab(
                          status: state.videosStatus,
                          isEmpty: state.videos.isEmpty,
                          errorMessage:
                              state.videosError ??
                              StringConstants.couldNotLoadVideos,
                          emptyTitle: StringConstants.noVideosYet,
                          emptyMessage: StringConstants.noVideosYetMessage,
                          onRetry: () => context.read<SupportBloc>().add(
                            const FetchVideosEvent(),
                          ),
                          child: HelpVideosTab(
                            isVendor: isVendor,
                            videos: state.videos,
                            onRefresh: () {
                              final Completer<void> done = Completer<void>();
                              context.read<SupportBloc>().add(
                                FetchVideosEvent(
                                  isRefresh: true,
                                  completer: done,
                                ),
                              );
                              return done.future;
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportTab extends StatelessWidget {
  const _SupportTab({
    required this.status,
    required this.isEmpty,
    required this.errorMessage,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRetry,
    required this.child,
  });

  final SupportStatus status;
  final bool isEmpty;
  final String errorMessage;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (status == SupportStatus.initial || status == SupportStatus.loading) {
      return const Center(
        child: SizedBox(
          width: AppDimens.sizeX30,
          height: AppDimens.sizeX30,
          child: LoadingWidget(isTransparentBackground: true),
        ),
      );
    }
    if (status == SupportStatus.failure) {
      return _SupportMessage(
        icon: Icons.cloud_off_rounded,
        title: errorMessage,
        message: StringConstants.checkYourConnectionAndTryAgain,
        actionLabel: 'Retry',
        onAction: onRetry,
      );
    }
    if (isEmpty) {
      return _SupportMessage(
        icon: Icons.inbox_rounded,
        title: emptyTitle,
        message: emptyMessage,
      );
    }
    return child;
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList({required this.faqs});

  final List<PublicFaqModel> faqs;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX16,
      ),
      itemCount: faqs.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.paddingX10),
      itemBuilder: (BuildContext context, int index) =>
          _FaqTile(faq: faqs[index]),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final PublicFaqModel faq;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final RoundedRectangleBorder tileShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      side: BorderSide(color: LightColor.dividerColor),
    );

    return Theme(
      // Strip ExpansionTile's default top/bottom dividers; the rounded shape
      // already separates each card.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        clipBehavior: Clip.antiAlias,
        backgroundColor: LightColor.cardColor,
        collapsedBackgroundColor: LightColor.cardColor,
        shape: tileShape,
        collapsedShape: tileShape,
        tilePadding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX14,
          symmetricVertical: AppDimens.paddingX4,
        ),
        childrenPadding: AppUtils().getPadding(
          left: AppDimens.paddingX14,
          right: AppDimens.paddingX14,
          bottom: AppDimens.paddingX14,
        ),
        leading: Container(
          width: AppDimens.sizeX36,
          height: AppDimens.sizeX36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          ),
          child: const Icon(
            Icons.help_outline_rounded,
            size: AppDimens.sizeX18,
            color: LightColor.secondaryColor,
          ),
        ),
        iconColor: LightColor.secondaryColor,
        collapsedIconColor: LightColor.secondaryTextColor,
        title: Text(
          faq.question,
          style: textTheme.bodyTextMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: LightColor.primaryTextColor,
          ),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(
            height: AppDimens.paddingX16,
            thickness: 1,
            color: LightColor.dividerColor,
          ),
          Text(
            faq.answer.isEmpty ? '—' : faq.answer,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpList extends StatelessWidget {
  const _HelpList({required this.helps, this.header});

  final List<PublicHelpModel> helps;

  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final int offset = header == null ? 0 : 1;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX16,
      ),
      itemCount: helps.length + offset,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.paddingX10),
      itemBuilder: (BuildContext context, int index) =>
          index < offset ? header! : _HelpTile(help: helps[index - offset]),
    );
  }
}

class _HelpTile extends StatelessWidget {
  const _HelpTile({required this.help});

  final PublicHelpModel help;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final RoundedRectangleBorder tileShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      side: BorderSide(color: LightColor.dividerColor),
    );

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        clipBehavior: Clip.antiAlias,
        backgroundColor: LightColor.cardColor,
        collapsedBackgroundColor: LightColor.cardColor,
        shape: tileShape,
        collapsedShape: tileShape,
        tilePadding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX14,
          symmetricVertical: AppDimens.paddingX4,
        ),
        childrenPadding: AppUtils().getPadding(
          left: AppDimens.paddingX14,
          right: AppDimens.paddingX14,
          bottom: AppDimens.paddingX14,
        ),
        leading: Container(
          width: AppDimens.sizeX36,
          height: AppDimens.sizeX36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: AppDimens.sizeX18,
            color: LightColor.secondaryColor,
          ),
        ),
        iconColor: LightColor.secondaryColor,
        collapsedIconColor: LightColor.secondaryTextColor,
        title: Text(
          help.title,
          style: textTheme.bodyTextMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: LightColor.primaryTextColor,
          ),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(
            height: AppDimens.paddingX16,
            thickness: 1,
            color: LightColor.dividerColor,
          ),
          if (help.description.isEmpty)
            Text(
              '—',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            )
          else
            CustomHtmlReader(
              html: help.description,
              textStyle: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _SocialChannel {
  const _SocialChannel({
    required this.label,
    required this.icon,
    required this.color,
    required this.url,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String url;
}

const Map<String, ({IconData icon, Color color})>
_socialCatalog = <String, ({IconData icon, Color color})>{
  'facebook': (icon: Icons.facebook_rounded, color: Color(0xFF1877F2)),
  'messenger': (
    icon: Icons.messenger_outline_rounded,
    color: Color(0xFF0084FF),
  ),
  'instagram': (icon: Icons.camera_alt_rounded, color: Color(0xFFE1306C)),
  'whatsapp': (icon: Icons.chat_rounded, color: Color(0xFF25D366)),
  'viber': (icon: Icons.phone_in_talk_rounded, color: Color(0xFF7360F2)),
  'telegram': (icon: Icons.send_rounded, color: Color(0xFF229ED9)),
  'youtube': (icon: Icons.play_circle_fill_rounded, color: Color(0xFFFF0000)),
  'tiktok': (icon: Icons.music_note_rounded, color: Color(0xFF010101)),
  'twitter': (icon: Icons.alternate_email_rounded, color: Color(0xFF1DA1F2)),
  'linkedin': (icon: Icons.business_center_rounded, color: Color(0xFF0A66C2)),
  'website': (icon: Icons.language_rounded, color: Color(0xFF2C7969)),
  'email': (icon: Icons.email_rounded, color: Color(0xFFEA4335)),
  'phone': (icon: Icons.phone_rounded, color: Color(0xFF2C7969)),
};

const ({IconData icon, Color color}) _genericChannel = (
  icon: Icons.link_rounded,
  color: Color(0xFF2C7969),
);

String? _socialKeyOf(PublicHelpModel help) {
  final String title = help.title.toLowerCase().replaceAll(
    RegExp(r'[\s_-]'),
    '',
  );
  for (final String key in _socialCatalog.keys) {
    if (title.contains(key)) return key;
  }
  // 'x' is Twitter's rebrand — match only as a standalone title.
  if (title == 'x') return 'twitter';
  return null;
}

bool _isSocialHelp(PublicHelpModel help) =>
    _linkFrom(help.description) != null &&
    (_socialKeyOf(help) != null || _looksLinkOnly(help.description));

bool _looksLinkOnly(String description) {
  final String d = description.trim();
  final String? link = _linkFrom(d);
  if (link == null) return false;
  // Allow minor wrapping punctuation/anchor markup around the bare link.
  return d.length <= link.length + 16;
}

String? _linkFrom(String description) {
  final RegExpMatch? match = RegExp(
    r'https?://[^\s"'
    "'"
    r'<>]+',
  ).firstMatch(description);
  final String raw = (match?.group(0) ?? description).trim();
  return raw.isEmpty ? null : raw;
}

List<_SocialChannel> _socialChannelsFromHelps(List<PublicHelpModel> helps) {
  final List<_SocialChannel> channels = <_SocialChannel>[];
  for (final PublicHelpModel help in helps) {
    if (!_isSocialHelp(help)) continue;
    final String? url = _linkFrom(help.description);
    if (url == null) continue;
    final String? key = _socialKeyOf(help);
    final ({IconData icon, Color color}) meta = key != null
        ? _socialCatalog[key]!
        : _genericChannel;
    channels.add(
      _SocialChannel(
        label: help.title.trim().isEmpty
            ? (key == null ? 'Link' : key[0].toUpperCase() + key.substring(1))
            : help.title.trim(),
        icon: meta.icon,
        color: LightColor.brandSafe(meta.color),
        url: url,
      ),
    );
  }
  return channels;
}

class _SocialConnectSection extends StatelessWidget {
  const _SocialConnectSection({required this.channels});

  final List<_SocialChannel> channels;

  Future<void> _open(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    final bool ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        StringConstants.somethingWentWrong,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Connect with us',
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX4),
          Text(
            'Reach out on social media — we usually reply within a few hours.',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX16),
          for (int i = 0; i < channels.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: AppDimens.paddingX8),
            _SocialTile(
              channel: channels[i],
              onTap: () => _open(context, channels[i].url),
            ),
          ],
        ],
      ),
    );
  }
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({required this.channel, required this.onTap});

  final _SocialChannel channel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: LightColor.brandSafe(channel.color).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppUtils().getPadding(
            symmetricVertical: AppDimens.paddingX10,
            symmetricHorizontal: AppDimens.paddingX12,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX36,
                height: AppDimens.sizeX36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.brandSafe(channel.color),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  channel.icon,
                  size: AppDimens.sizeX18,
                  color: LightColor.inverseTextColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Text(
                  channel.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColor.primaryTextColor,
                  ),
                ),
              ),
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

class _SupportMessage extends StatelessWidget {
  const _SupportMessage({
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
        padding: AppUtils().getPadding(all: AppDimens.paddingX24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: AppDimens.sizeX40, color: LightColor.iconGrey),
            const SizedBox(height: AppDimens.paddingX12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppDimens.paddingX16),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: LightColor.secondaryColor,
                  side: const BorderSide(color: LightColor.secondaryColor),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _HelpSection { faqs, guides, videos }

class _HelpCenterWide extends StatefulWidget {
  const _HelpCenterWide({required this.isVendor});

  final bool isVendor;

  @override
  State<_HelpCenterWide> createState() => _HelpCenterWideState();
}

class _HelpCenterWideState extends State<_HelpCenterWide> {
  final TextEditingController _search = TextEditingController();
  _HelpSection _section = _HelpSection.faqs;

  static const double _maxWidth = 1200;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String get _query => _search.text.trim().toLowerCase();

  String _label(_HelpSection s) => switch (s) {
    _HelpSection.faqs => StringConstants.faqs,
    _HelpSection.guides => 'Help guides',
    _HelpSection.videos => StringConstants.videos,
  };

  IconData _icon(_HelpSection s) => switch (s) {
    _HelpSection.faqs => Icons.quiz_outlined,
    _HelpSection.guides => Icons.menu_book_outlined,
    _HelpSection.videos => Icons.play_circle_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportBloc, SupportState>(
      builder: (BuildContext context, SupportState state) {
        final List<_SocialChannel> socials = _socialChannelsFromHelps(
          state.helps,
        );
        final List<PublicHelpModel> guides = state.helps
            .where((PublicHelpModel h) => !_isSocialHelp(h))
            .toList(growable: false);
        final String q = _query;
        final List<PublicFaqModel> faqs = q.isEmpty
            ? state.faqs
            : state.faqs
                  .where(
                    (PublicFaqModel f) =>
                        f.question.toLowerCase().contains(q) ||
                        f.answer.toLowerCase().contains(q),
                  )
                  .toList(growable: false);
        final List<PublicHelpModel> shownGuides = q.isEmpty
            ? guides
            : guides
                  .where(
                    (PublicHelpModel h) => h.title.toLowerCase().contains(q),
                  )
                  .toList(growable: false);
        final Map<_HelpSection, int> counts = <_HelpSection, int>{
          _HelpSection.faqs: state.faqs.length,
          _HelpSection.guides: guides.length,
          _HelpSection.videos: state.videos.length,
        };

        final bool desktop = context.isDesktop;
        // Desktop shows the contact links in their own card, so a guides
        // section holding nothing else is left out of the navigation.
        final List<_HelpSection> sections = <_HelpSection>[
          for (final _HelpSection s in _HelpSection.values)
            if (!(desktop && s == _HelpSection.guides && guides.isEmpty)) s,
        ];
        if (!sections.contains(_section)) _section = _HelpSection.faqs;
        final Widget content = _sectionContent(
          context,
          state,
          faqs: faqs,
          guides: shownGuides,
          socials: desktop ? const <_SocialChannel>[] : socials,
        );

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingX24,
                AppDimens.paddingX20,
                AppDimens.paddingX24,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _header(context),
                  const SizedBox(height: AppDimens.paddingX20),
                  if (!desktop) ...<Widget>[
                    _segmented(counts),
                    const SizedBox(height: AppDimens.paddingX16),
                  ],
                  Expanded(
                    child: desktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 280,
                                child: ListView(
                                  padding: const EdgeInsets.only(
                                    bottom: AppDimens.paddingX24,
                                  ),
                                  children: <Widget>[
                                    _sidebar(counts, sections),
                                    if (socials.isNotEmpty) ...<Widget>[
                                      const SizedBox(
                                        height: AppDimens.paddingX16,
                                      ),
                                      _SocialConnectSection(channels: socials),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppDimens.paddingX24),
                              Expanded(child: content),
                            ],
                          )
                        : content,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Help center',
                style: textTheme.headingSmall?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX4),
              Text(
                'Answers, guides and videos for using Hamro Futsal.',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.paddingX16),
        SizedBox(
          width: 360,
          height: 44,
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
            ),
            decoration: InputDecoration(
              hintText: 'Search FAQs and guides',
              hintStyle: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: AppDimens.sizeX20,
                color: LightColor.hintTextColor,
              ),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: Icon(
                        Icons.close_rounded,
                        size: AppDimens.sizeX18,
                        color: LightColor.hintTextColor,
                      ),
                      onPressed: () => setState(_search.clear),
                    ),
              filled: true,
              fillColor: LightColor.cardColor,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                borderSide: BorderSide(color: LightColor.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                borderSide: BorderSide(color: LightColor.dividerColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sidebar(Map<_HelpSection, int> counts, List<_HelpSection> sections) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX8),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: <Widget>[
          for (final _HelpSection s in sections)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Material(
                color: s == _section
                    ? LightColor.secondaryColor.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                  onTap: () => setState(() => _section = s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingX12,
                      vertical: AppDimens.paddingX12,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          _icon(s),
                          size: AppDimens.sizeX20,
                          color: s == _section
                              ? LightColor.secondaryColor
                              : LightColor.secondaryTextColor,
                        ),
                        const SizedBox(width: AppDimens.paddingX12),
                        Expanded(
                          child: Text(
                            _label(s),
                            style: textTheme.bodyTextSmall?.copyWith(
                              color: s == _section
                                  ? LightColor.primaryTextColor
                                  : LightColor.secondaryTextColor,
                              fontWeight: s == _section
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 26),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.paddingX8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: s == _section
                                ? LightColor.secondaryColor
                                : LightColor.inputFillColor,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusX20,
                            ),
                          ),
                          child: Text(
                            '${counts[s]}',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyTextSmall?.copyWith(
                              fontSize: 12,
                              color: s == _section
                                  ? LightColor.inverseTextColor
                                  : LightColor.secondaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _segmented(Map<_HelpSection, int> counts) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 42,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          border: Border.all(color: LightColor.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final _HelpSection s in _HelpSection.values)
              GestureDetector(
                onTap: () => setState(() => _section = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingX16,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s == _section
                        ? LightColor.secondaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                  ),
                  child: Text(
                    '${_label(s)}  ${counts[s]}',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: s == _section
                          ? LightColor.inverseTextColor
                          : LightColor.secondaryTextColor,
                      fontWeight: s == _section
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionContent(
    BuildContext context,
    SupportState state, {
    required List<PublicFaqModel> faqs,
    required List<PublicHelpModel> guides,
    required List<_SocialChannel> socials,
  }) {
    Widget list(List<Widget> items) => ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppDimens.paddingX24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.paddingX10),
      itemBuilder: (_, int i) => items[i],
    );
    Widget noMatch() => _SupportMessage(
      icon: Icons.search_off_rounded,
      title: 'No results for "${_search.text.trim()}"',
      message: 'Try a different word, or browse the other sections.',
    );

    switch (_section) {
      case _HelpSection.faqs:
        return _SupportTab(
          status: state.faqsStatus,
          isEmpty: state.faqs.isEmpty,
          errorMessage: state.faqsError ?? 'Could not load FAQs.',
          emptyTitle: 'No FAQs yet',
          emptyMessage: 'Frequently asked questions will appear here.',
          onRetry: () =>
              context.read<SupportBloc>().add(const FetchFaqsEvent()),
          child: faqs.isEmpty
              ? noMatch()
              : list(<Widget>[for (final f in faqs) _FaqTile(faq: f)]),
        );
      case _HelpSection.guides:
        final bool hasAny = guides.isNotEmpty || socials.isNotEmpty;
        return _SupportTab(
          status: state.helpsStatus,
          isEmpty: state.helps.isEmpty,
          errorMessage: state.helpsError ?? 'Could not load help topics.',
          emptyTitle: 'No help topics yet',
          emptyMessage: 'Help and how-to guides will appear here.',
          onRetry: () =>
              context.read<SupportBloc>().add(const FetchHelpsEvent()),
          child: !hasAny && _query.isNotEmpty
              ? noMatch()
              : list(<Widget>[
                  if (socials.isNotEmpty)
                    _SocialConnectSection(channels: socials),
                  for (final h in guides) _HelpTile(help: h),
                ]),
        );
      case _HelpSection.videos:
        return _SupportTab(
          status: state.videosStatus,
          isEmpty: state.videos.isEmpty,
          errorMessage: state.videosError ?? StringConstants.couldNotLoadVideos,
          emptyTitle: StringConstants.noVideosYet,
          emptyMessage: StringConstants.noVideosYetMessage,
          onRetry: () =>
              context.read<SupportBloc>().add(const FetchVideosEvent()),
          child: HelpVideosTab(
            isVendor: widget.isVendor,
            videos: state.videos,
            onRefresh: () {
              final Completer<void> done = Completer<void>();
              context.read<SupportBloc>().add(
                FetchVideosEvent(isRefresh: true, completer: done),
              );
              return done.future;
            },
          ),
        );
    }
  }
}
