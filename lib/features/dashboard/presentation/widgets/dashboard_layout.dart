import 'package:flutter/widgets.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';

/// Smallest venue-card width that still fits the price and the status pill on
/// one line with space between them.
///
/// Fixed column counts per breakpoint do not work here: the content pane is
/// the screen minus the side rail and its padding, so a 600px tablet at two
/// columns left ~220px cells and the pill was forced onto a second line.
const double kMinVenueCardWidth = 280;

/// Column count for the home venue feed, derived from the width actually
/// available to the grid (pass `constraints.maxWidth` from a `LayoutBuilder`,
/// not the screen width).
///
/// Shared by the real feed and its loading skeleton so the two cannot drift —
/// a mismatch makes the skeleton-to-content transition jump between layouts.
int venueGridColumns(BuildContext context, double availableWidth) {
  // Phones always keep the single-column list.
  if (!context.isTabletOrWider) return 1;

  // Capped at 3: beyond that the cards get thin without adding information.
  return columnsFor(
    availableWidth: availableWidth,
    minItemWidth: kMinVenueCardWidth,
    spacing: AppDimens.sizeX20,
    maxColumns: 3,
  );
}
