import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class LogoPickerCard extends StatelessWidget {
  const LogoPickerCard({
    super.key,
    required this.logoBytes,
    required this.fileName,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? logoBytes;
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bool hasLogo = logoBytes != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[LightColor.elevatedCardColor, LightColor.cardColor],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasLogo
              ? LightColor.secondaryColor.withValues(alpha: 0.48)
              : LightColor.borderColor,
          width: 1.2,
        ),
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 148,
              decoration: BoxDecoration(
                color: LightColor.elevatedCardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasLogo
                      ? LightColor.secondaryColor.withValues(alpha: 0.4)
                      : LightColor.borderColor,
                ),
              ),
              child: hasLogo
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: CustomImageView(
                        imageBytes: logoBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.cloud_upload_rounded,
                          size: 34,
                          color: LightColor.secondaryColor,
                        ),
                        SizedBox(height: 8),
                        Text(
                          StringConstants.tapToUploadShopLogo,
                          style: TextStyle(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          StringConstants.pngJpgJpegWebp,
                          style: TextStyle(
                            color: LightColor.secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (hasLogo) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.image_rounded,
                  size: 16,
                  color: LightColor.secondaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName ?? 'selected_image',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.file_open_rounded, size: 18),
                  label: const Text(StringConstants.chooseFile),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LightColor.secondaryColor,
                    side: BorderSide(
                      color: LightColor.secondaryColor.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (hasLogo) ...<Widget>[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text(StringConstants.remove),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LightColor.redColor,
                      side: BorderSide(
                        color: LightColor.redColor.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
