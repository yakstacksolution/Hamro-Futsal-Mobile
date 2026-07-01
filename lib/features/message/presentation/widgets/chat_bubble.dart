import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/presentation/utils/message_fmt.dart';

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
        color: isMe ? LightColor.secondaryColor : LightColor.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppDimens.radiusX14),
          topRight: const Radius.circular(AppDimens.radiusX14),
          // Small "tail" corner on the sender's side.
          bottomLeft: Radius.circular(isMe ? AppDimens.radiusX14 : 4),
          bottomRight: Radius.circular(isMe ? 4 : AppDimens.radiusX14),
        ),
        boxShadow: const [
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
                color: (isMe ? Colors.white : LightColor.secondaryColor)
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
                      ? LightColor.whiteColor.withValues(alpha: 0.85)
                      : LightColor.secondaryTextColor,
                ),
              ),
            ),
          if (message.isDeleted || message.body.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.isDeleted ? 'Message deleted' : message.body,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: isMe
                      ? LightColor.whiteColor
                      : LightColor.primaryTextColor,
                  fontWeight: FontWeight.w500,
                  fontStyle: message.isDeleted
                      ? FontStyle.italic
                      : FontStyle.normal,
                  height: 1.4,
                ),
              ),
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
                        ? LightColor.whiteColor
                        : LightColor.secondaryColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX4),
                  Text(
                    locationText,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: isMe
                          ? LightColor.whiteColor
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
                  'edited · ',
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: isMe
                        ? LightColor.whiteColor.withValues(alpha: 0.7)
                        : LightColor.hintTextColor,
                  ),
                ),
              Text(
                MessageFmt.clock(message.createdAt),
                style: textTheme.bodyTextSmall?.copyWith(
                  fontSize: 10,
                  color: isMe
                      ? LightColor.whiteColor.withValues(alpha: 0.75)
                      : LightColor.hintTextColor,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: AppDimens.paddingX4),
                Icon(
                  message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                  size: 13,
                  color: LightColor.whiteColor.withValues(alpha: 0.85),
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
    final fg = isMe ? LightColor.whiteColor : LightColor.secondaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: (isMe ? LightColor.whiteColor : LightColor.secondaryColor)
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
                      ? LightColor.whiteColor
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
