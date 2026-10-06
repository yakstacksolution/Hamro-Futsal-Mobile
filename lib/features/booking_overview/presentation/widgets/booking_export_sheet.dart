import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/features/booking_overview/domain/model/booking_export_file.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/pages/booking_export_viewer_page.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/utils/csv_parser.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showBookingExportSheet({
  required BuildContext context,
  required File savedFile,
  required BookingExportFile export,
}) {
  return showAppBottomSheet<void>(
    context: context,
    builder: (_) => _BookingExportSheet(savedFile: savedFile, export: export),
  );
}

class _BookingExportSheet extends StatefulWidget {
  const _BookingExportSheet({required this.savedFile, required this.export});

  final File savedFile;
  final BookingExportFile export;

  @override
  State<_BookingExportSheet> createState() => _BookingExportSheetState();
}

class _BookingExportSheetState extends State<_BookingExportSheet> {
  final GlobalKey _viewKey = GlobalKey();
  late final int _rows = math.max(
    0,
    parseCsvBytes(widget.export.bytes).length - 1,
  );
  bool _opening = false;

  String get _fileName => widget.savedFile.uri.pathSegments.last;

  String get _location {
    final String path = widget.savedFile.path;
    if (Platform.isAndroid && path.contains('/Download')) {
      return StringConstants.exportSavedInDownloads;
    }
    if (Platform.isIOS) return StringConstants.exportSavedInFiles;
    return widget.savedFile.parent.path;
  }

  static String _size(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _view() async {
    if (_opening) return;
    setState(() => _opening = true);
    final bool opened = await _openExternally(widget.savedFile);
    if (!mounted) return;
    setState(() => _opening = false);
    if (opened) {
      Navigator.of(context).pop();
      return;
    }
    if (await _openWith()) return;
    if (!mounted) return;
    AppUtils().showSnackBar(
      context,
      MsgType.info,
      StringConstants.couldNotOpenExport,
    );
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => BookingExportViewerPage(file: widget.export),
      ),
    );
  }

  static Future<bool> _openExternally(File file) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final OpenResult result = await OpenFilex.open(
          file.path,
          type: 'text/csv',
          uti: 'public.comma-separated-values-text',
        );
        return result.type == ResultType.done;
      }
      return await launchUrl(Uri.file(file.path));
    } catch (_) {
      return false;
    }
  }

  Future<bool> _openWith() async {
    final RenderObject? box = _viewKey.currentContext?.findRenderObject();
    try {
      final ShareResult result = await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(widget.savedFile.path, mimeType: 'text/csv')],
          sharePositionOrigin: box is RenderBox && box.hasSize
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        ),
      );
      return result.status != ShareResultStatus.unavailable;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color accent = LightColor.secondaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Container(
            width: AppDimens.sizeX54,
            height: AppDimens.sizeX54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.download_done_rounded,
              color: accent,
              size: AppDimens.sizeX28,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.paddingX14),
        Text(
          StringConstants.exportDownloadedTitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyTextLarge?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimens.paddingX6),
        Text(
          StringConstants.exportReadyToView,
          textAlign: TextAlign.center,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppDimens.paddingX18),
        // The file, with its own View action.
        Container(
          padding: const EdgeInsets.all(AppDimens.paddingX12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(color: accent.withValues(alpha: 0.30)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX44,
                height: AppDimens.sizeX44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Icon(
                  Icons.table_chart_outlined,
                  color: accent,
                  size: AppDimens.sizeX22,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingX2),
                    Text(
                      'CSV · ${_size(widget.export.bytes.length)} · $_rows '
                      '${_rows == 1 ? 'row' : 'rows'}',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                      ),
                    ),
                    Text(
                      _location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX8),
              CustomButton(
                key: _viewKey,
                text: StringConstants.viewExport,
                icon: Icons.open_in_new_rounded,
                isLoading: _opening,
                backgroundColor: accent,
                minWidth: AppDimens.sizeX80,
                minHeight: AppDimens.sizeX36,
                onPressed: _view,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.paddingX16),
        CustomButton(
          text: StringConstants.done,
          isOutlined: true,
          borderColor: accent,
          foregroundColor: accent,
          minHeight: AppDimens.sizeX46,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
