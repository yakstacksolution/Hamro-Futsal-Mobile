import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/features/booking_overview/domain/model/booking_export_file.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/utils/csv_parser.dart';
import 'package:share_plus/share_plus.dart';

class BookingExportViewerPage extends StatefulWidget {
  const BookingExportViewerPage({super.key, required this.file});

  final BookingExportFile file;

  @override
  State<BookingExportViewerPage> createState() =>
      _BookingExportViewerPageState();
}

class _BookingExportViewerPageState extends State<BookingExportViewerPage> {
  final GlobalKey _shareKey = GlobalKey();
  final ScrollController _horizontal = ScrollController();
  late final List<List<String>> _rows = parseCsvBytes(widget.file.bytes);
  late final List<double> _widths = _columnWidths(_rows);

  static const double _rowHeight = 40;
  static const double _cellPadding = AppDimens.paddingX12;

  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  static List<double> _columnWidths(List<List<String>> rows) {
    final int columns = rows.fold<int>(
      0,
      (int widest, List<String> row) => math.max(widest, row.length),
    );
    return List<double>.generate(columns, (int c) {
      int longest = 0;
      for (final List<String> row in rows.take(200)) {
        if (c < row.length) longest = math.max(longest, row[c].length);
      }
      return (longest * 7.5 + _cellPadding * 2).clamp(72, 280).toDouble();
    });
  }

  Future<void> _share() async {
    final RenderObject? box = _shareKey.currentContext?.findRenderObject();
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[
          XFile.fromData(
            widget.file.bytes,
            name: widget.file.fileName,
            mimeType: 'text/csv',
          ),
        ],
        fileNameOverrides: <String>[widget.file.fileName],
        sharePositionOrigin: box is RenderBox && box.hasSize
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final int records = math.max(0, _rows.length - 1);
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: StringConstants.exportedBookings,
        actions: <Widget>[
          IconButton(
            key: _shareKey,
            tooltip: StringConstants.shareFile,
            onPressed: _share,
            icon: Icon(
              Icons.ios_share_rounded,
              size: 20,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingX16,
                AppDimens.paddingX4,
                AppDimens.paddingX16,
                AppDimens.paddingX12,
              ),
              child: Text(
                '${widget.file.fileName} · $records '
                '${records == 1 ? 'row' : 'rows'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                ),
              ),
            ),
            Expanded(
              child: _rows.isEmpty
                  ? Center(
                      child: Text(
                        StringConstants.noBookingsToExport,
                        style: textTheme.bodyTextMedium?.copyWith(
                          color: LightColor.secondaryTextColor,
                        ),
                      ),
                    )
                  : _table(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _table(BuildContext context) {
    final double tableWidth = _widths.fold<double>(0, (a, b) => a + b);
    return Scrollbar(
      controller: _horizontal,
      child: SingleChildScrollView(
        controller: _horizontal,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          child: Column(
            children: <Widget>[
              // Header stays put while the records scroll beneath it.
              _row(context, _rows.first, header: true),
              Expanded(
                child: ListView.builder(
                  itemCount: _rows.length - 1,
                  itemExtent: _rowHeight,
                  itemBuilder: (BuildContext context, int i) =>
                      _row(context, _rows[i + 1], striped: i.isOdd),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    List<String> cells, {
    bool header = false,
    bool striped = false,
  }) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      height: _rowHeight,
      decoration: BoxDecoration(
        color: header
            ? LightColor.sunkenColor
            : striped
            ? LightColor.cardColor
            : LightColor.background,
        border: Border(bottom: BorderSide(color: LightColor.dividerColor)),
      ),
      child: Row(
        children: List<Widget>.generate(_widths.length, (int c) {
          return SizedBox(
            width: _widths[c],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _cellPadding),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  c < cells.length ? cells[c] : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: header
                        ? LightColor.primaryTextColor
                        : LightColor.secondaryTextColor,
                    fontWeight: header ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
