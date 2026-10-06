import 'package:flutter/widgets.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';

const double kMinVenueCardWidth = 280;

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
