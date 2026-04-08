import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';

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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFF7FBFF), Color(0xFFF3F7FF)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasLogo
              ? LightColor.skyBlue.withValues(alpha: 0.48)
              : LightColor.lightGrey,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasLogo
                      ? LightColor.skyBlue.withValues(alpha: 0.4)
                      : LightColor.lightGrey,
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
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.cloud_upload_rounded,
                          size: 34,
                          color: LightColor.skyBlue,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to upload shop logo',
                          style: TextStyle(
                            color: LightColor.titleTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'PNG, JPG, JPEG, WEBP',
                          style: TextStyle(
                            color: LightColor.darkgrey,
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
                  color: LightColor.skyBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName ?? 'selected_image',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: LightColor.titleTextColor,
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
                  label: const Text('Choose File'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LightColor.skyBlue,
                    side: BorderSide(
                      color: LightColor.skyBlue.withValues(alpha: 0.5),
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
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LightColor.red,
                      side: BorderSide(
                        color: LightColor.red.withValues(alpha: 0.4),
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
