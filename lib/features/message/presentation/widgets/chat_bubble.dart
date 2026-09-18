import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/routers/link_opener.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/features/message/domain/model/message_links.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/message/data/model/chat_message_model.dart';
import 'package:hamro_futsal/features/message/domain/model/message_mentions.dart';
import 'package:hamro_futsal/features/message/presentation/utils/message_fmt.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

/// One chat bubble — mine: filled accent, right-aligned with delivery ticks;
/// theirs: white card, left-aligned (sender name shown in groups).
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showSender = false,
    this.onLongPress,
    this.onMediaTap,
    this.mediaBytesLoader,
    this.mentionCandidates = const <MentionCandidate>[],
    this.mentionsMe = false,
  });

  final ChatMessageModel message;
  final bool isMe;

  /// Show the sender's name above the bubble (group chats).
  final bool showSender;
  final VoidCallback? onLongPress;
  final ValueChanged<ChatMediaModel>? onMediaTap;

  /// Fetches the authed bytes for an attachment. When provided, image
  /// attachments render inline (the relative media URL needs a bearer token,
  /// so it can't be loaded as a plain network image).
  final Future<Uint8List?> Function(ChatMediaModel media)? mediaBytesLoader;

  /// The conversation's participants, so `@name` in the body can be matched
  /// and highlighted.
  final List<MentionCandidate> mentionCandidates;

  /// Whether this message calls out the signed-in user — a direct mention or
  /// an `@all`.
  final bool mentionsMe;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final metadata = message.metadata;
    final String? locationText = message.type == 'location' && metadata is Map
        ? _locationText(metadata)
        : null;

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.76,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX12,
        AppDimens.paddingX10,
        AppDimens.paddingX12,
        AppDimens.paddingX6,
      ),
      decoration: BoxDecoration(
        // A message that names you is tinted and outlined, so it is findable
        // when scrolling back through a busy group.
        color: mentionsMe
            ? LightColor.secondaryColor.withValues(alpha: 0.10)
            : isMe
            ? LightColor.secondaryColor
            : LightColor.cardColor,
        border: mentionsMe
            ? Border.all(
                color: LightColor.secondaryColor.withValues(alpha: 0.45),
              )
            : null,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppDimens.radiusX14),
          topRight: const Radius.circular(AppDimens.radiusX14),
          // Small "tail" corner on the sender's side.
          bottomLeft: Radius.circular(isMe ? AppDimens.radiusX14 : 4),
          bottomRight: Radius.circular(isMe ? 4 : AppDimens.radiusX14),
        ),
        boxShadow: [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSender && !isMe)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.senderName,
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontSize: AppDimens.fontBodySubTitle,
                    fontWeight: FontWeight.w700,
                    color: LightColor.secondaryColor,
                  ),
                ),
              ),
            ),
          if (message.replyTo != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color:
                    (isMe
                            ? LightColor.onBrandSurface
                            : LightColor.secondaryColor)
                        .withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(AppDimens.radiusX6),
              ),
              child: Text(
                message.replyTo!.isDeleted
                    ? 'Deleted message'
                    : message.replyTo!.body.trim().isNotEmpty
                    ? message.replyTo!.body
                    : 'Attachment',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextSmall?.copyWith(
                  fontSize: AppDimens.fontBodySubTitle,
                  color: isMe
                      ? LightColor.inverseTextColor.withValues(alpha: 0.85)
                      : LightColor.secondaryTextColor,
                ),
              ),
            ),
          if (message.isDeleted || message.body.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: _buildBody(textTheme),
            ),
          if (!message.isDeleted && locationText != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: isMe
                        ? LightColor.inverseTextColor
                        : LightColor.secondaryColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX4),
                  Text(
                    locationText,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: isMe
                          ? LightColor.inverseTextColor
                          : LightColor.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          // Attachments: images render inline; other files as compact chips.
          // Both are streamed via the authed media API.
          for (final m in message.media)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: m.isImage && mediaBytesLoader != null
                    ? _InlineImage(
                        media: m,
                        isMe: isMe,
                        loader: mediaBytesLoader!,
                        onTap: onMediaTap == null ? null : () => onMediaTap!(m),
                      )
                    : _MediaChip(
                        media: m,
                        isMe: isMe,
                        onTap: onMediaTap == null ? null : () => onMediaTap!(m),
                      ),
              ),
            ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isEdited)
                Text(
                  StringConstants.edited,
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: isMe
                        ? LightColor.inverseTextColor.withValues(alpha: 0.7)
                        : LightColor.hintTextColor,
                  ),
                ),
              Text(
                MessageFmt.clock(message.createdAt),
                style: textTheme.bodyTextSmall?.copyWith(
                  fontSize: 10,
                  color: isMe
                      ? LightColor.inverseTextColor.withValues(alpha: 0.75)
                      : LightColor.hintTextColor,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: AppDimens.paddingX4),
                Icon(
                  message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                  size: 13,
                  color: LightColor.inverseTextColor.withValues(alpha: 0.85),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX16,
        vertical: AppDimens.paddingX4,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(onLongPress: onLongPress, child: bubble),
      ),
    );
  }

  /// The message body, with any `@mention` and any URL picked out of it.
  Widget _buildBody(dynamic textTheme) {
    final TextStyle? base = textTheme.bodyTextSmall?.copyWith(
      color: isMe ? LightColor.inverseTextColor : LightColor.primaryTextColor,
      fontWeight: FontWeight.w500,
      fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
      height: 1.4,
    );

    if (message.isDeleted) {
      return Text('Message deleted', style: base);
    }

    return _MessageBodyText(
      body: message.body,
      baseStyle: base,
      isMe: isMe,
      mentionCandidates: mentionCandidates,
    );
  }

  String? _locationText(Map metadata) {
    final latitude = metadata['latitude'] ?? metadata['lat'];
    final longitude = metadata['longitude'] ?? metadata['lng'];
    if (latitude == null || longitude == null) return null;
    return '$latitude, $longitude';
  }
}

/// Attachment row inside a bubble: type icon, file name and size.
class _MediaChip extends StatelessWidget {
  const _MediaChip({required this.media, required this.isMe, this.onTap});

  final ChatMediaModel media;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final fg = isMe ? LightColor.inverseTextColor : LightColor.secondaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color:
              (isMe ? LightColor.inverseTextColor : LightColor.secondaryColor)
                  .withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              media.isImage
                  ? Icons.image_outlined
                  : Icons.insert_drive_file_outlined,
              size: 15,
              color: fg,
            ),
            const SizedBox(width: AppDimens.paddingX6),
            Flexible(
              child: Text(
                media.humanReadableSize.isEmpty
                    ? media.name
                    : '${media.name} · ${media.humanReadableSize}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextSmall?.copyWith(
                  fontSize: AppDimens.fontBodySubTitle,
                  fontWeight: FontWeight.w600,
                  color: isMe
                      ? LightColor.inverseTextColor
                      : LightColor.primaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Module-level cache of resolved image bytes, keyed by media id, so scrolling
/// or rebuilding the thread doesn't refetch every visible image. Capped to keep
/// a long-lived session from growing unbounded.
final Map<int, Uint8List> _imageBytesCache = <int, Uint8List>{};
const int _imageBytesCacheCap = 60;

/// Inline preview for an image attachment. Fetches the authed bytes once (via
/// [loader], then cached), shows a placeholder while loading, and falls back to
/// the file chip on failure. Tapping opens the full-screen viewer via [onTap].
class _InlineImage extends StatefulWidget {
  const _InlineImage({
    required this.media,
    required this.isMe,
    required this.loader,
    this.onTap,
  });

  final ChatMediaModel media;
  final bool isMe;
  final Future<Uint8List?> Function(ChatMediaModel media) loader;
  final VoidCallback? onTap;

  @override
  State<_InlineImage> createState() => _InlineImageState();
}

class _InlineImageState extends State<_InlineImage> {
  static const double _maxWidth = 230;
  static const double _placeholderHeight = 160;

  Uint8List? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _bytes = _imageBytesCache[widget.media.id];
    if (_bytes == null) _resolve();
  }

  Future<void> _resolve() async {
    final bytes = await widget.loader(widget.media);
    if (!mounted) return;
    setState(() {
      if (bytes == null || bytes.isEmpty) {
        _failed = true;
      } else {
        if (_imageBytesCache.length >= _imageBytesCacheCap) {
          _imageBytesCache.remove(_imageBytesCache.keys.first);
        }
        _imageBytesCache[widget.media.id] = bytes;
        _bytes = bytes;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return _MediaChip(
        media: widget.media,
        isMe: widget.isMe,
        onTap: widget.onTap,
      );
    }

    final Widget content = _bytes != null
        ? Image.memory(
            _bytes!,
            width: _maxWidth,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _MediaChip(
              media: widget.media,
              isMe: widget.isMe,
              onTap: widget.onTap,
            ),
          )
        : Container(
            width: _maxWidth,
            height: _placeholderHeight,
            alignment: Alignment.center,
            color: LightColor.dividerColor.withValues(alpha: 0.35),
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        onTap: widget.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _maxWidth,
            maxHeight: 260,
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Centered day separator chip (`Today`, `Yesterday`, `2 Jun`).
class ChatDayChip extends StatelessWidget {
  const ChatDayChip({super.key, required this.date});

  final DateTime date;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get _label {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${day.day} ${_months[day.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimens.paddingX10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: LightColor.dividerColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        ),
        child: Text(
          _label,
          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            fontSize: AppDimens.fontBodySubTitle,
            fontWeight: FontWeight.w600,
            color: LightColor.secondaryTextColor,
          ),
        ),
      ),
    );
  }
}

/// A message body rendered as text with its `@mentions` highlighted and its
/// links tappable.
///
/// Stateful only because a tappable span needs a [TapGestureRecognizer], and a
/// recognizer has to be disposed; building them inside a stateless `build`
/// leaks one per rebuild, and a chat rebuilds constantly.
class _MessageBodyText extends StatefulWidget {
  const _MessageBodyText({
    required this.body,
    required this.baseStyle,
    required this.isMe,
    required this.mentionCandidates,
  });

  final String body;
  final TextStyle? baseStyle;
  final bool isMe;
  final List<MentionCandidate> mentionCandidates;

  @override
  State<_MessageBodyText> createState() => _MessageBodyTextState();
}

class _MessageBodyTextState extends State<_MessageBodyText> {
  /// One recognizer per link, kept across rebuilds and keyed by where the link
  /// sits in the body. Reused rather than rebuilt because disposing a
  /// recognizer that a finger is still on throws — and a chat rebuilds under
  /// the user's finger every time a message arrives.
  final Map<String, TapGestureRecognizer> _recognizers =
      <String, TapGestureRecognizer>{};

  @override
  void didUpdateWidget(_MessageBodyText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // An edited message is a different body: the old offsets no longer mean
    // anything, so the recognizers built from them go.
    if (oldWidget.body != widget.body) _disposeRecognizers();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final TapGestureRecognizer recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer _recognizerFor(LinkSpan link) {
    final TapGestureRecognizer recognizer = _recognizers.putIfAbsent(
      '${link.start}:${link.text}',
      TapGestureRecognizer.new,
    );
    return recognizer..onTap = () => _openLink(link);
  }

  Future<void> _openLink(LinkSpan link) async {
    final bool opened = await LinkOpener.open(link.uri);
    if (opened || !mounted) return;
    AppUtils().showSnackBar(
      context,
      MsgType.error,
      StringConstants.couldNotOpenThisLink,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String body = widget.body;
    final List<MentionSpan> mentions = findMentionSpans(
      body,
      widget.mentionCandidates,
    );
    final List<LinkSpan> links = findLinkSpans(body);
    if (mentions.isEmpty && links.isEmpty) {
      return Text(body, style: widget.baseStyle);
    }

    // A mention is set in the accent colour and bolded; on my own (green)
    // bubbles the accent is unreadable, so weight alone carries it there.
    final TextStyle? mentionStyle = widget.baseStyle?.copyWith(
      fontWeight: FontWeight.w800,
      color: widget.isMe
          ? LightColor.inverseTextColor
          : LightColor.secondaryColor,
    );
    final TextStyle? linkStyle = widget.baseStyle?.copyWith(
      color: widget.isMe
          ? LightColor.inverseTextColor
          : LightColor.secondaryColor,
      decoration: TextDecoration.underline,
      decorationColor: widget.isMe
          ? LightColor.inverseTextColor
          : LightColor.secondaryColor,
      fontWeight: FontWeight.w700,
    );

    // Both passes read the same body, so a `@name` inside a URL would be
    // highlighted twice. Links win: the URL has to stay tappable as one run.
    final List<_BodySpan> ordered = <_BodySpan>[
      ...links.map(_BodySpan.link),
      ...mentions
          .where(
            (MentionSpan mention) => !links.any(
              (LinkSpan link) =>
                  mention.start < link.end && link.start < mention.end,
            ),
          )
          .map(_BodySpan.mention),
    ]..sort((_BodySpan a, _BodySpan b) => a.start.compareTo(b.start));

    final List<InlineSpan> pieces = <InlineSpan>[];
    int cursor = 0;
    for (final _BodySpan span in ordered) {
      if (span.start > cursor) {
        pieces.add(TextSpan(text: body.substring(cursor, span.start)));
      }
      final LinkSpan? link = span.link;
      if (link == null) {
        pieces.add(TextSpan(text: span.text, style: mentionStyle));
      } else {
        pieces.add(
          TextSpan(
            text: span.text,
            style: linkStyle,
            recognizer: _recognizerFor(link),
            semanticsLabel: link.isInternal
                ? '${link.text}, opens in the app'
                : null,
          ),
        );
      }
      cursor = span.end;
    }
    if (cursor < body.length) {
      pieces.add(TextSpan(text: body.substring(cursor)));
    }

    return Text.rich(TextSpan(children: pieces), style: widget.baseStyle);
  }
}

/// A run of the body that is drawn differently from the rest — either a
/// mention or a link.
class _BodySpan {
  const _BodySpan._({
    required this.start,
    required this.end,
    required this.text,
    this.link,
  });

  factory _BodySpan.mention(MentionSpan span) =>
      _BodySpan._(start: span.start, end: span.end, text: span.text);

  factory _BodySpan.link(LinkSpan span) => _BodySpan._(
    start: span.start,
    end: span.end,
    text: span.text,
    link: span,
  );

  final int start;
  final int end;
  final String text;
  final LinkSpan? link;
}
