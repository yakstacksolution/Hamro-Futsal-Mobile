import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

class VenueStatusWidget extends StatelessWidget {
  final bool isOpen;
  const VenueStatusWidget({super.key, required this.isOpen});

  /// The brand green is too dark to read on a dark pill, so the open state uses
  /// the brightness-aware success token rather than `secondaryColor`.
  Color get _statusColor =>
      isOpen ? LightColor.successColor : LightColor.redColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.sizeX30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX4,
          ),
          decoration: BoxDecoration(
            // Tracks the card surface it sits on, so the pill reads as part of
            // the card in both themes. Anchoring it to white left a glaring
            // white chip on the dark card.
            color: LightColor.elevatedCardColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppDimens.sizeX30),
            border: Border.all(
              color: _statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: AppDimens.sizeX6,
                width: AppDimens.sizeX6,
                decoration: BoxDecoration(
                  color: _statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX4),
              Text(
                isOpen ? 'Open Now' : 'Closed Now',
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      fontSize: AppDimens.sizeX10,
                      color: _statusColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
