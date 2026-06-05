import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

class VenueStatusWidget extends StatelessWidget {
  final bool isOpen;
  const VenueStatusWidget({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.sizeX30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppDimens.sizeX30),
            border: Border.all(
              color: isOpen
                  ? LightColor.secondaryColor.withValues(alpha: 0.3)
                  : LightColor.redColor.withValues(alpha: 0.3),
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
                  color: isOpen
                      ? LightColor.secondaryColor
                      : LightColor.redColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX4),
              Text(
                isOpen ? 'Open Now' : 'Closed',
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      fontSize: AppDimens.sizeX10,
                      color: isOpen
                          ? LightColor.secondaryColor
                          : LightColor.redColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
