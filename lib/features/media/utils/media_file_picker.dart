import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/upload_attachment.dart';
import 'package:hamro_futsal/features/media/utils/heic_to_png_jpg.dart';
import 'package:hamro_futsal/features/media/utils/stable_media_file.dart';
import 'package:image_picker/image_picker.dart';

/// Image extensions every upload in the app accepts. Kept here so the pickers
/// share one list instead of each screen drifting its own.
const Set<String> kImageUploadExtensions = <String>{'jpg', 'jpeg', 'png'};

/// Server-side cap for an uploaded proof/media file.
const int kMaxUploadBytes = kUploadMaxFileBytes;

/// Where a file came from. Mirrors the media library's "Pick from" menu.
enum MediaPickSource {
  gallery('Gallery', 'Choose an existing photo', Icons.photo_library_outlined),
  camera('Camera', 'Take a photo now', Icons.photo_camera_outlined),
  files('Files', 'Browse your documents', Icons.folder_open_outlined);

  const MediaPickSource(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;
}

/// A local file chosen by the user, already normalised: camera writes are
/// flushed, HEIC/HEIF is converted to JPEG, and the contents are read once,
/// here, into [bytes].
///
/// The bytes — not the path — are what gets uploaded. Picker results live in
/// OS-managed caches (image_picker's temp dir, a content-provider copy), and
/// those can be reclaimed or invalidated between attaching a file and pressing
/// Confirm, which is how a proof ended up being sent as 0 bytes.
typedef PickedMediaFile = UploadAttachment;

/// Asks where to take the file from, then picks and normalises a single one —
/// the same gallery/camera/files flow (and the same 1920px, quality-85
/// downscale) the media library uses, minus its multi-select.
///
/// Returns null when the user backs out or the file fails validation; every
/// rejection is reported to the user here, so callers only handle the success
/// case. [allowCamera] can be turned off for sources that are never a photo.
Future<PickedMediaFile?> pickMediaFile(
  BuildContext context, {
  Set<String> allowedExtensions = kImageUploadExtensions,
  int maxBytes = kMaxUploadBytes,
  bool allowCamera = true,
  String title = 'Add a file',
  String subtitle = '',
}) async {
  final MediaPickSource? source = await _askSource(
    context,
    allowCamera: allowCamera,
    title: title,
    subtitle: subtitle,
  );
  if (source == null || !context.mounted) return null;

  try {
    final UploadPolicy policy = UploadPolicy(
      allowedExtensions: allowedExtensions,
      maxInputBytes: maxBytes,
    );
    final _RawPick raw = switch (source) {
      MediaPickSource.gallery => await _pickImage(ImageSource.gallery, policy),
      MediaPickSource.camera => await _pickImage(ImageSource.camera, policy),
      MediaPickSource.files => await _pickFile(allowedExtensions, policy),
    };
    if (!context.mounted) return null;

    // A pick that produced an unreadable file is the flush failure
    // `stabilizePickedMedia` guards against — say so, because retrying works.
    // A plain cancel says nothing.
    if (raw.unreadable) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        source == MediaPickSource.camera
            ? 'The camera did not finish saving the image. '
                  'Please take the photo again.'
            : 'That file came through empty. Please select it again.',
        key: 'media_unreadable',
      );
      return null;
    }
    if (raw.file == null) return null;

    return raw.file;
  } on UploadValidationException catch (error) {
    if (!context.mounted) return null;
    AppUtils().showSnackBar(
      context,
      MsgType.error,
      error.message,
      key: 'media_validation_failed',
    );
    return null;
  } catch (_) {
    if (!context.mounted) return null;
    AppUtils().showSnackBar(
      context,
      MsgType.error,
      'Could not open that file. Please try again.',
      key: 'media_pick_failed',
    );
    return null;
  }
}

/// Full-screen look at a picked image — pinch to zoom, tap outside to close.
/// Renders from [PickedMediaFile.bytes], so it cannot go blank if the source
/// file behind it disappears.
Future<void> showPickedMediaPreview(
  BuildContext context,
  PickedMediaFile file,
) async {
  if (!file.isImage) return;
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (BuildContext ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppDimens.paddingX16),
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          InteractiveViewer(
            maxScale: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              child: Image.memory(file.bytes, fit: BoxFit.contain),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(ctx).pop(),
            icon: const CircleAvatar(
              backgroundColor: Colors.black54,
              child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    ),
  );
}

// ───────────────────────────── internals ─────────────────────────────

Future<MediaPickSource?> _askSource(
  BuildContext context, {
  required bool allowCamera,
  required String title,
  required String subtitle,
}) {
  final textTheme = FutsalTheme.getTextTheme(context);
  final List<MediaPickSource> sources = <MediaPickSource>[
    MediaPickSource.gallery,
    if (allowCamera) MediaPickSource.camera,
    MediaPickSource.files,
  ];

  return showModalBottomSheet<MediaPickSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) => SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(AppDimens.paddingX12),
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.paddingX18,
          horizontal: AppDimens.paddingX16,
        ),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: LightColor.primaryTextColor,
              ),
            ),
            if (subtitle.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppDimens.paddingX2),
              Text(
                subtitle,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                ),
              ),
            ],
            const SizedBox(height: AppDimens.paddingX12),
            for (final MediaPickSource source in sources)
              _SourceTile(
                source: source,
                onTap: () => Navigator.of(ctx).pop(source),
              ),
          ],
        ),
      ),
    ),
  );
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source, required this.onTap});

  final MediaPickSource source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.paddingX10,
            horizontal: AppDimens.paddingX6,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX36,
                height: AppDimens.sizeX36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: Icon(
                  source.icon,
                  size: AppDimens.sizeX20,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      source.label,
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    Text(
                      source.description,
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: LightColor.hintTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: LightColor.hintTextColor,
                size: AppDimens.sizeX20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A pick before validation. [unreadable] separates "the user cancelled" from
/// "we got a file we cannot read", which are different messages.
class _RawPick {
  const _RawPick({this.file, this.unreadable = false});

  final PickedMediaFile? file;
  final bool unreadable;
}

/// Gallery/camera through image_picker, downscaled exactly like the media
/// library's, then stabilised so an unflushed camera file cannot be uploaded
/// empty.
Future<_RawPick> _pickImage(ImageSource source, UploadPolicy policy) async {
  final XFile? captured = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1920,
    maxHeight: 1920,
    imageQuality: 85,
  );
  if (captured == null) return const _RawPick();
  final XFile? stable = await stabilizePickedMedia(captured);
  if (stable == null) return const _RawPick(unreadable: true);
  final PickedMediaFile? file = await _fromPath(
    stable.path,
    stable.name,
    policy,
  );
  return file == null ? const _RawPick(unreadable: true) : _RawPick(file: file);
}

Future<_RawPick> _pickFile(
  Set<String> allowedExtensions,
  UploadPolicy policy,
) async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: allowedExtensions.toList(growable: false),
    withData: false,
  );
  final PlatformFile? file = result?.files.singleOrNull;
  if (file?.path == null) return const _RawPick();
  final PickedMediaFile? picked = await _fromPath(
    file!.path!,
    file.name,
    policy,
  );
  return picked == null
      ? const _RawPick(unreadable: true)
      : _RawPick(file: picked);
}

/// Converts HEIC/HEIF (what an iPhone gallery hands over) to JPEG, then reads
/// the file into memory straight away — the only moment it is guaranteed to
/// still be there. An empty read is reported as a failed pick.
Future<PickedMediaFile?> _fromPath(
  String path,
  String name,
  UploadPolicy policy,
) async {
  final String finalPath = await heicToPngJpg(path);
  final String finalName = finalPath == path
      ? name
      : finalPath.split(Platform.pathSeparator).last;
  return loadUploadAttachment(
    path: finalPath,
    filename: finalName,
    policy: policy,
  );
}
