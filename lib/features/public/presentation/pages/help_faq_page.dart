import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_html_viewer.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/public/data/model/public_faq_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_help_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_faqs_use_case.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_helps_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/support/support_bloc.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Help & FAQ — two tabs backed by the public `GET /faqs` and `GET /helps`
/// endpoints, opened from the profile's Support section.
class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupportBloc>(
      create: (_) {
        final PublicRepositoryImpl repository = PublicRepositoryImpl();
        return SupportBloc(
            GetFaqsUseCase(repository),
            GetHelpsUseCase(repository),
          )
          ..add(const FetchFaqsEvent())
          ..add(const FetchHelpsEvent());
      },
      child: const _HelpFaqView(),
    );
  }
}

class _HelpFaqView extends StatelessWidget {
  const _HelpFaqView();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return DefaultTabController(
      length: 2,
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
                            return Column(
                              children: <Widget>[
                                if (socials.isNotEmpty)
                                  _SocialConnectSection(channels: socials),
                                Expanded(
                                  child:
                                      (otherHelps.isEmpty &&
                                          socials.isNotEmpty &&
                                          state.helpsStatus ==
                                              SupportStatus.success)
                                      // Only social links exist — no need for
                                      // an empty-help placeholder below them.
                                      ? const SizedBox.shrink()
                                      : _SupportTab(
                                          status: state.helpsStatus,
                                          isEmpty: otherHelps.isEmpty,
                                          errorMessage:
                                              state.helpsError ??
                                              'Could not load help topics.',
                                          emptyTitle: 'No help topics yet',
                                          emptyMessage:
                                              'Help and how-to guides will appear here.',
                                          onRetry: () => context
                                              .read<SupportBloc>()
                                              .add(const FetchHelpsEvent()),
                                          child: _HelpList(helps: otherHelps),
                                        ),
                                ),
                              ],
                            );
                          },
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

/// Shared loading / error / empty scaffolding for one tab.
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

/// Expandable question/answer card.
///
/// The surface (color + rounded border) is provided through the
/// [ExpansionTile.shape]/[ExpansionTile.collapsedShape] so the tile wraps its
/// own [Material]. Painting the background with an outer `Container` instead
/// would place a colored `DecoratedBox` between the inner `ListTile` and its
/// nearest `Material`, which trips the framework's
/// "ListTile background color or ink splashes may be invisible" assertion.
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
  const _HelpList({required this.helps});

  final List<PublicHelpModel> helps;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX16,
      ),
      itemCount: helps.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.paddingX10),
      itemBuilder: (BuildContext context, int index) =>
          _HelpTile(help: helps[index]),
    );
  }
}

/// Expandable help article. The body content arrives as HTML from the server,
/// so it is rendered with [CustomHtmlReader].
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

/// A social channel shown in the Help tab's "Connect with us" section.
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

/// Known social platforms, keyed by the help item's title. Detection is
/// substring-based so titles like "Facebook Page" still match.
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

/// Fallback presentation for a link-only help item not in [_socialCatalog].
const ({IconData icon, Color color}) _genericChannel = (
  icon: Icons.link_rounded,
  color: Color(0xFF2C7969),
);

/// The catalog key a help item's title maps to, or null if unknown.
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

/// A help item is a "link" tile when its description contains a URL. Known
/// platforms get their branded icon; anything else falls back to a link icon.
bool _isSocialHelp(PublicHelpModel help) =>
    _linkFrom(help.description) != null &&
    (_socialKeyOf(help) != null || _looksLinkOnly(help.description));

/// True when the description is essentially just a URL (title carries meaning).
bool _looksLinkOnly(String description) {
  final String d = description.trim();
  final String? link = _linkFrom(d);
  if (link == null) return false;
  // Allow minor wrapping punctuation/anchor markup around the bare link.
  return d.length <= link.length + 16;
}

/// Extracts a link from a help item's [description], accepting either a bare
/// URL or one embedded in surrounding text/HTML.
String? _linkFrom(String description) {
  final RegExpMatch? match = RegExp(
    r'https?://[^\s"'
    "'"
    r'<>]+',
  ).firstMatch(description);
  final String raw = (match?.group(0) ?? description).trim();
  return raw.isEmpty ? null : raw;
}

/// Builds the ordered list of social channels present in [helps].
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

/// "Connect with us" card with tappable social channels shown atop the Help
/// tab. Each tile opens the respective app/site via [launchUrl].
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
      margin: AppUtils().getPadding(
        left: AppDimens.paddingX16,
        right: AppDimens.paddingX16,
        top: AppDimens.paddingX16,
      ),
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
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const double spacing = AppDimens.paddingX12;
              // Up to 3 per row; fewer channels stretch to fill the row.
              final int perRow = channels.length < 3 ? channels.length : 3;
              final double tileWidth =
                  (constraints.maxWidth - spacing * (perRow - 1)) / perRow;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: <Widget>[
                  for (final _SocialChannel channel in channels)
                    SizedBox(
                      width: tileWidth,
                      child: _SocialTile(
                        channel: channel,
                        onTap: () => _open(context, channel.url),
                      ),
                    ),
                ],
              );
            },
          ),
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
            symmetricVertical: AppDimens.paddingX14,
            symmetricHorizontal: AppDimens.paddingX8,
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX40,
                height: AppDimens.sizeX40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.brandSafe(channel.color),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  channel.icon,
                  size: AppDimens.sizeX20,
                  color: LightColor.inverseTextColor,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX8),
              Text(
                channel.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LightColor.primaryTextColor,
                ),
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
