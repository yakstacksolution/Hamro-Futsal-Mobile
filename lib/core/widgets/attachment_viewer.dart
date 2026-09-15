import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/helper/download_helper.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

/// True when [url] points at something this app can render inline.
///
/// A proof is usually a screenshot, but the same field accepts a PDF, and an
/// image widget handed a PDF only shows a broken placeholder. Anything that is
/// not a known image extension is treated as a file: it gets a file tile and
/// the download action rather than a preview.
bool isViewableImageUrl(String? url) {
  final String path = Uri.tryParse(url?.trim() ?? '')?.path.toLowerCase() ?? '';
  return const <String>[
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.heic',
    '.heif',
    '.gif',
    '.bmp',
  ].any(path.endsWith);
}

/// The app's download affordance for a remote attachment.
///
/// Owns its own in-flight state and its own origin key (iPad and macOS anchor
/// the save sheet to the tapped button), so a caller only has to say what to
/// download and where to put the button.
class AttachmentDownloadAction extends StatefulWidget {
  const AttachmentDownloadAction({
    super.key,
    this.url,
    this.bytes,
    this.fileName,
    this.color,
    this.labelled = false,
    this.tooltip,
  }) : assert(
         url != null || bytes != null,
         'AttachmentDownloadAction needs either a url or bytes to save.',
       );

  final String? url;

  /// Image already in memory — used instead of [url] when set, for a payload
  /// that arrived inline (a base64 payment QR) and has nothing to re-fetch.
  final Uint8List? bytes;

  /// Name the saved file should get. Derived from the URL when omitted.
  final String? fileName;
  final Color? color;

  /// Renders as a labelled button rather than a bare icon — for the places
  /// where the icon has no surrounding context to explain it.
  final bool labelled;

  /// Overrides the icon's tooltip, for a surface where "Download" alone is
  /// ambiguous about what would be saved.
  final String? tooltip;

  @override
  State<AttachmentDownloadAction> createState() =>
      _AttachmentDownloadActionState();
}

class _AttachmentDownloadActionState extends State<AttachmentDownloadAction> {
  final GlobalKey _originKey = GlobalKey();
  bool _busy = false;

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _busy = true);
    await downloadAttachment(
      context,
      url: widget.url,
      bytes: widget.bytes,
      fileName: widget.fileName,
      originKey: _originKey,
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final Color tint = widget.color ?? LightColor.secondaryColor;
    final Widget icon = _busy
        ? SizedBox(
            width: AppDimens.sizeX18,
            height: AppDimens.sizeX18,
            child: CircularProgressIndicator(strokeWidth: 2, color: tint),
          )
        : Icon(Icons.download_rounded, color: tint);

    if (widget.labelled) {
      return TextButton.icon(
        key: _originKey,
        onPressed: _busy ? null : _download,
        icon: icon,
        label: Text(
          _busy
              ? StringConstants.downloadingAttachment
              : StringConstants.download,
          style: TextStyle(color: tint, fontWeight: FontWeight.w600),
        ),
      );
    }

    // Tighter than the 48px default: the bare icon rides on a header line or
    // inside a QR's light band, where a full-size button would push the row's
    // height out or eat into the code.
    return IconButton(
      key: _originKey,
      tooltip: widget.tooltip ?? StringConstants.download,
      onPressed: _busy ? null : _download,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(
        width: AppDimens.sizeX36,
        height: AppDimens.sizeX36,
      ),
      icon: icon,
    );
  }
}

/// Full-screen view of an attachment, with a download action in the app bar.
///
/// Shared by every surface that shows a payment proof, so the download
/// behaviour — and what the user is told about it — exists once.
class AttachmentViewer extends StatelessWidget {
  const AttachmentViewer({
    super.key,
    required this.url,
    required this.title,
    this.fileName,
  });

  final String url;
  final String title;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: <Widget>[
          AttachmentDownloadAction(
            key: const Key('attachment-viewer-download'),
            url: url,
            fileName: fileName,
            color: Colors.white,
          ),
          const SizedBox(width: AppDimens.paddingX4),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (!isViewableImageUrl(url)) {
              return _FileBody(url: url, fileName: fileName);
            }
            return InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: Center(
                child: CustomImageView(
                  url: url,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  fit: BoxFit.contain,
                  isHidePlaceholderImage: true,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// What a non-image attachment shows instead of a preview: what it is, and the
/// one thing that can be done with it.
class _FileBody extends StatelessWidget {
  const _FileBody({required this.url, this.fileName});

  final String url;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: AppDimens.paddingX16),
            const Text(
              StringConstants.proofIsAFile,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: AppDimens.paddingX20),
            AttachmentDownloadAction(
              key: const Key('attachment-file-download'),
              url: url,
              fileName: fileName,
              color: Colors.white,
              labelled: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Downloads [url] and tells the user how it went.
///
/// Every caller wants the same messages, so they are written once here rather
/// than at each button.
Future<DownloadOutcome> downloadAttachment(
  BuildContext context, {
  String? url,
  Uint8List? bytes,
  String? fileName,
  GlobalKey? originKey,
}) async {
  final DownloadOutcome outcome = bytes != null && bytes.isNotEmpty
      ? await DownloadHelper.saveBytes(
          bytes: bytes,
          fileName: fileName,
          originKey: originKey,
        )
      : await DownloadHelper.download(
          url: url,
          fileName: fileName,
          originKey: originKey,
        );
  if (!context.mounted) return outcome;

  switch (outcome) {
    case DownloadOutcome.savedToGallery:
      AppUtils().showSnackBar(
        context,
        MsgType.success,
        StringConstants.attachmentSavedToGallery,
      );
    case DownloadOutcome.savedToFiles:
      AppUtils().showSnackBar(
        context,
        MsgType.success,
        Platform.isIOS
            ? StringConstants.attachmentSaved
            : StringConstants.attachmentSavedToFiles,
      );
    case DownloadOutcome.permissionDenied:
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        StringConstants.attachmentSavePermissionDenied,
      );
    case DownloadOutcome.saved:
      AppUtils().showSnackBar(
        context,
        MsgType.success,
        StringConstants.attachmentSaved,
      );
    case DownloadOutcome.failed:
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        StringConstants.attachmentDownloadFailed,
      );
    case DownloadOutcome.nothingToDownload:
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        StringConstants.attachmentUnavailable,
      );
    case DownloadOutcome.dismissed:
    case DownloadOutcome.unknown:
      // The user backed out of the save sheet, or the platform will not say.
      // Either way there is nothing to report.
      break;
  }
  return outcome;
}
