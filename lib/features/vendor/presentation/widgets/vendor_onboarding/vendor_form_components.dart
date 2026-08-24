// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_delete_dialog.dart';
import 'package:hamro_footsall/core/widgets/custom_checkbox.dart';
import 'package:hamro_footsall/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/courts/data/model/picked_location.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:http/http.dart' as http;

class VendorPanel extends StatelessWidget {
  const VendorPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.secondaryColor.withValues(alpha: 0.05),
            blurRadius: AppDimens.radiusX22,
            offset: const Offset(0, AppDimens.sizeX8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class VendorPanelHeading extends StatelessWidget {
  const VendorPanelHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX4),
        Text(
          subtitle,

          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class VendorSummaryBadge extends StatelessWidget {
  const VendorSummaryBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX12,
        vertical: AppDimens.paddingX10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class VendorErrorBanner extends StatelessWidget {
  const VendorErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX8),
      decoration: BoxDecoration(
        color: LightColor.redLightColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.redLightColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: AppUtils().getPadding(top: AppDimens.sizeX2),
            child: Icon(
              Icons.error_outline_rounded,
              color: LightColor.redColor,
              size: AppDimens.sizeX18,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX8),
          Expanded(
            child: Text(
              message,

              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VendorFieldLabel extends StatelessWidget {
  const VendorFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
        color: LightColor.primaryTextColor,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class VendorOnboardingSectionHeader extends StatelessWidget {
  const VendorOnboardingSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: AppDimens.sizeX40,
            height: AppDimens.sizeX40,
            decoration: BoxDecoration(
              color: LightColor.secondaryLight.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            ),
            child: Icon(
              icon,
              size: AppDimens.sizeX18,
              color: LightColor.brandTextColor,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium!
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        color: LightColor.primaryTextColor,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall!
                      .copyWith(
                        fontWeight: FontWeight.w400,
                        color: LightColor.secondaryTextColor,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: AppDimens.sizeX8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class VendorGroupedContentCard extends StatelessWidget {
  const VendorGroupedContentCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX30,
                height: AppDimens.sizeX30,
                decoration: BoxDecoration(
                  color: LightColor.whiteColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Icon(
                  icon,
                  size: AppDimens.sizeX16,
                  color: LightColor.brandTextColor,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: LightColor.primaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX10),
          child,
        ],
      ),
    );
  }
}

class VendorTemplateResetButton extends StatelessWidget {
  const VendorTemplateResetButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: StringConstants.resetToDefaultTemplate,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: AppDimens.sizeX30,
          height: AppDimens.sizeX30,
          decoration: BoxDecoration(
            color: LightColor.secondaryLight.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            Icons.refresh_rounded,
            size: AppDimens.sizeX16,
            color: LightColor.brandTextColor,
          ),
        ),
      ),
    );
  }
}

class VendorInputField extends StatelessWidget {
  const VendorInputField({
    super.key,
    this.label,
    this.controller,
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.enableIcon,
    this.readOnly = false,
    this.onTap,
    this.isRequired = false,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.ensureVisibleOnFocus = false,
  });

  final String? label;
  final TextEditingController? controller;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool? enableIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool isRequired;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool ensureVisibleOnFocus;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      ensureVisibleOnFocus: ensureVisibleOnFocus,
      isRequired: isRequired,
      labelText: label ?? '',
      icon: enableIcon == true
          ? _vendorFieldIcon(label ?? '', keyboardType)
          : null,
      initialValue: initialValue,
      hintText: hintText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      textCapitalization: maxLines > 1
          ? TextCapitalization.sentences
          : TextCapitalization.none,
    );
  }
}

class VendorDropdownField<T> extends StatelessWidget {
  const VendorDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.hintText,
    this.enableIcon,
    this.isRequired = false,
    this.enabled = true,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? initialValue;
  final String? hintText;
  final bool? enableIcon;
  final bool isRequired;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return CustomDropdownField<T>(
      labelText: label,
      initialValue: initialValue,
      hintText: hintText,
      icon: enableIcon == true ? _vendorFieldIcon(label, null) : null,
      isRequired: isRequired,
      enabled: enabled,
      items: items,
      onChanged: onChanged,
    );
  }
}

class VendorSelectableChip extends StatelessWidget {
  const VendorSelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.imageUrl,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  /// Network URL of a leading icon (e.g. facility icon from the API). Takes
  /// precedence over [icon] when provided.
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: Ink(
        padding: AppUtils().getPadding(
          horizontal: AppDimens.paddingX6,
          vertical: AppDimens.paddingX10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? LightColor.secondaryLight : LightColor.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          border: Border.all(
            color: isSelected
                ? LightColor.secondaryColor
                : LightColor.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            VendorMiniCheckbox(isChecked: isSelected, size: AppDimens.sizeX16),
            SizedBox(width: AppDimens.sizeX6),
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              CustomImageView(
                url: imageUrl,
                color: LightColor.monoIconColor,
                height: AppDimens.sizeX20,
                width: AppDimens.sizeX20,
                fit: BoxFit.contain,
                isHidePlaceholderImage: true,
              ),
              SizedBox(width: AppDimens.sizeX6),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: AppDimens.sizeX16,
                color: isSelected
                    ? LightColor.brandTextColor
                    : LightColor.secondaryTextColor,
              ),
              SizedBox(width: AppDimens.sizeX6),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
                  color: isSelected
                      ? LightColor.brandTextColor
                      : LightColor.primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VendorMiniCheckbox extends StatelessWidget {
  const VendorMiniCheckbox({
    super.key,
    required this.isChecked,
    this.size = 14,
    this.onChanged,
  });

  final bool isChecked;
  final double size;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomCheckbox(
      value: isChecked,
      onChanged: onChanged == null
          ? null
          : (bool? value) => onChanged!(value ?? false),
      labelWidget: const SizedBox.shrink(),
      size: size,
      spacing: 0,
      activeColor: LightColor.secondaryColor,
      inactiveColor: Colors.transparent,
      borderColor: LightColor.borderColor,
      checkColor: LightColor.inverseTextColor,
    );
  }
}

class VendorUploadSection extends StatelessWidget {
  const VendorUploadSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPick,
    required this.files,
    required this.onRemove,
    this.onReplace,
    this.onReorder,
    this.actionLabel = 'Upload',
    this.actionIcon = Icons.upload_rounded,
    this.previewAsImage = false,
    this.asGrid = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPick;
  final List<UploadRef> files;
  final ValueChanged<UploadRef>? onRemove;
  final ValueChanged<UploadRef>? onReplace;

  /// When provided (and there are 2+ files), the list becomes drag-to-reorder.
  final void Function(int oldIndex, int newIndex)? onReorder;
  final String actionLabel;
  final IconData actionIcon;
  final bool previewAsImage;

  /// Renders the files as a two-column grid of document tiles whose actions
  /// follow the verification status: rejected → replace + remove, fresh
  /// (not yet reviewed) → remove, pending/approved → locked (no actions).
  final bool asGrid;

  @override
  Widget build(BuildContext context) {
    final bool hasFiles = files.isNotEmpty;

    return Container(
      padding: AppUtils().getPadding(all: AppDimens.sizeX12),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.greyBorderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: AppDimens.radiusX12,
            offset: const Offset(0, AppDimens.sizeX4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: FutsalTheme.getTextTheme(context).bodyTextMedium
                          ?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppDimens.sizeX4),
                    Text(
                      subtitle,

                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(
                            color: LightColor.secondaryTextColor,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.sizeX10),
              InkWell(
                onTap: onPick,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: LightColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX6),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: LightColor.secondaryColor.withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: AppDimens.radiusX10,
                        offset: const Offset(0, AppDimens.sizeX4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: AppUtils().getPadding(
                      horizontal: AppDimens.sizeX12,
                      vertical: AppDimens.sizeX6,
                    ),
                    child: Text(
                      actionLabel,
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(color: LightColor.inverseTextColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: hasFiles
                ? _buildFileList(context)
                : Container(
                    key: const ValueKey<String>('upload_empty'),
                    width: double.infinity,
                    padding: AppUtils().getPadding(
                      horizontal: AppDimens.sizeX14,
                      vertical: AppDimens.sizeX18,
                    ),
                    decoration: BoxDecoration(
                      color: LightColor.background,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                      border: Border.all(
                        color: LightColor.greyBorderColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: AppDimens.sizeX48,
                          height: AppDimens.sizeX48,
                          decoration: BoxDecoration(
                            color: LightColor.whiteColor,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusX14,
                            ),
                          ),
                          child: Icon(
                            actionIcon,
                            color: LightColor.brandTextColor,
                            size: AppDimens.sizeX22,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sizeX10),
                        Text(
                          StringConstants.noUploadsYet,
                          style: FutsalTheme.getTextTheme(context)
                              .bodyTextMedium
                              ?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: AppDimens.sizeX4),
                        Text(
                          'Tap $actionLabel to attach files for this section.',
                          textAlign: TextAlign.center,
                          style: FutsalTheme.getTextTheme(context).bodyTextSmall
                              ?.copyWith(
                                color: LightColor.secondaryTextColor,
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(BuildContext context) {
    // Image galleries: big hero (first image) + a horizontal strip of small,
    // drag-to-reorder thumbnails below it.
    if (previewAsImage) {
      return _buildImageHeroLayout(context);
    }

    // Documents as a two-column grid of status-aware tiles.
    if (asGrid) {
      return GridView.builder(
        key: const ValueKey<String>('upload_files_grid'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: files.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimens.sizeX10,
          mainAxisSpacing: AppDimens.sizeX10,
          mainAxisExtent: AppDimens.sizeX160,
        ),
        itemBuilder: (BuildContext context, int index) {
          final UploadRef file = files[index];
          return _DocumentGridTile(
            file: file,
            onRemove: onRemove == null
                ? null
                : () => unawaited(_confirmRemove(context, file)),
            onReplace: onReplace == null ? null : () => onReplace!(file),
          );
        },
      );
    }

    // Documents / non-image files: vertical list, drag-to-reorder when 2+.
    final bool canReorder = onReorder != null && files.length > 1;
    if (!canReorder) {
      return Column(
        key: const ValueKey<String>('upload_files'),
        children: files
            .map(
              (UploadRef file) => VendorUploadItem(
                file: file,
                previewAsImage: previewAsImage,
                forceFileLayout: true,
                onRemove: onRemove == null ? null : () => onRemove!(file),
                onReplace: onReplace == null ? null : () => onReplace!(file),
              ),
            )
            .toList(),
      );
    }

    return ReorderableListView.builder(
      key: const ValueKey<String>('upload_files_reorderable'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: files.length,
      onReorder: onReorder!,
      itemBuilder: (BuildContext context, int index) {
        final UploadRef file = files[index];
        return Row(
          key: ObjectKey(file),
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: AppUtils().getPadding(right: AppDimens.sizeX6),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: LightColor.secondaryTextColor,
                  size: AppDimens.sizeX22,
                ),
              ),
            ),
            Expanded(
              child: VendorUploadItem(
                file: file,
                previewAsImage: previewAsImage,
                forceFileLayout: true,
                onRemove: onRemove == null ? null : () => onRemove!(file),
                onReplace: onReplace == null ? null : () => onReplace!(file),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmRemove(BuildContext context, UploadRef file) async {
    if (onRemove == null) return;
    final bool confirmed = await showDeleteDialog(
      context: context,
      title: StringConstants.deleteFile,
      message: '${StringConstants.removeFileConfirmationPrefix}"${file.name}"?',
      confirmText: StringConstants.delete,
      cancelText: StringConstants.cancel,
      icon: Icons.delete_outline_rounded,
      confirmColor: LightColor.redColor,
    );
    if (confirmed) onRemove!(file);
  }

  Widget _buildImageHeroLayout(BuildContext context) {
    final UploadRef hero = files.first;
    final bool canReorder = onReorder != null && files.length > 1;

    return Column(
      key: const ValueKey<String>('upload_hero'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // ── Large hero (first image) ──
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusX14),
          child: Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _UploadImageView(file: hero),
              ),
              if (onRemove != null)
                Positioned(
                  top: AppDimens.sizeX8,
                  right: AppDimens.sizeX8,
                  child: _ThumbDeleteButton(
                    onTap: () => unawaited(_confirmRemove(context, hero)),
                  ),
                ),
            ],
          ),
        ),

        // ── Horizontal thumbnail strip (all images) ──
        if (files.length > 1) ...<Widget>[
          const SizedBox(height: AppDimens.sizeX12),
          SizedBox(
            height: AppDimens.sizeX80,
            child: canReorder
                ? ReorderableListView.builder(
                    key: const ValueKey<String>('upload_thumbs_reorderable'),
                    scrollDirection: Axis.horizontal,
                    buildDefaultDragHandles: false,
                    itemCount: files.length,
                    onReorder: onReorder!,
                    itemBuilder: (BuildContext context, int index) {
                      final UploadRef file = files[index];
                      return ReorderableDragStartListener(
                        key: ObjectKey(file),
                        index: index,
                        child: _buildThumb(context, file, index),
                      );
                    },
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: files.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _buildThumb(context, files[index], index),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildThumb(BuildContext context, UploadRef file, int index) {
    final bool isCover = index == 0;
    return Container(
      width: AppDimens.sizeX80,
      margin: AppUtils().getMargin(right: AppDimens.sizeX10),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                border: Border.all(
                  color: isCover
                      ? LightColor.secondaryColor
                      : LightColor.greyBorderColor,
                  width: isCover ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                child: _UploadImageView(file: file),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: AppDimens.sizeX4,
              right: AppDimens.sizeX4,
              child: _ThumbDeleteButton(
                small: true,
                onTap: () => unawaited(_confirmRemove(context, file)),
              ),
            ),
        ],
      ),
    );
  }
}

class _UploadImageView extends StatelessWidget {
  const _UploadImageView({required this.file});

  final UploadRef file;

  String get _rawImageSource => (file.remoteUrl ?? '').trim();

  bool get _isNetwork {
    final String source = _resolveMediaUrl(_rawImageSource).toLowerCase();
    return source.startsWith('http://') || source.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (_rawImageSource.isEmpty) {
      return ColoredBox(
        color: LightColor.background,
        child: Center(
          child: Icon(
            Icons.image_not_supported_rounded,
            color: LightColor.secondaryTextColor,
            size: AppDimens.sizeX22,
          ),
        ),
      );
    }
    return _isNetwork
        ? CustomImageView(
            url: _resolveMediaUrl(_rawImageSource),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
        : CustomImageView(
            file: File(_rawImageSource),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
  }
}

/// Simple red remove icon used on hero / thumbnail previews.
class _ThumbDeleteButton extends StatelessWidget {
  const _ThumbDeleteButton({required this.onTap, this.small = false});

  final VoidCallback onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final double size = small ? AppDimens.sizeX22 : AppDimens.sizeX28;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: LightColor.whiteColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          color: LightColor.redColor,
          size: small ? AppDimens.sizeX14 : AppDimens.sizeX18,
        ),
      ),
    );
  }
}

class _DocumentGridTile extends StatelessWidget {
  const _DocumentGridTile({
    required this.file,
    required this.onRemove,
    required this.onReplace,
  });

  final UploadRef file;
  final VoidCallback? onRemove;
  final VoidCallback? onReplace;

  bool get _isRejected =>
      file.verificationStatus == UploadVerificationStatus.rejected;

  bool get _isFresh => file.verificationStatus == UploadVerificationStatus.none;

  bool get _hasImageContent {
    final String source = (file.remoteUrl ?? '').trim();
    if (source.isEmpty) return false;
    final String path = _pathWithoutQuery(source).toLowerCase();
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  /// Small white circular badge holding the corner status icon.
  Widget _cornerBadge({required Widget child, String? tooltip}) {
    final Widget badge = Container(
      width: AppDimens.sizeX22,
      height: AppDimens.sizeX22,
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        shape: BoxShape.circle,
      ),
      child: child,
    );
    if (tooltip == null) return badge;
    return Tooltip(message: tooltip, child: badge);
  }

  @override
  Widget build(BuildContext context) {
    final bool canRemove = onRemove != null && (_isRejected || _isFresh);
    final bool canReplace = onReplace != null && _isRejected;
    final UploadVerificationStatus status = file.verificationStatus;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: _isRejected ? LightColor.redColor : LightColor.greyBorderColor,
          width: _isRejected ? 1.2 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: AppDimens.radiusX10,
            offset: const Offset(0, AppDimens.sizeX4),
          ),
        ],
      ),
      // Full-bleed preview; status lives in a single corner indicator.
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _hasImageContent
              ? _UploadImageView(file: file)
              : Container(
                  color: LightColor.background,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.insert_drive_file_rounded,
                        color: LightColor.brandTextColor,
                        size: AppDimens.sizeX28,
                      ),
                      const SizedBox(height: AppDimens.sizeX6),
                      Text(
                        file.name.split('.').last.toUpperCase(),
                        style: FutsalTheme.getTextTheme(context).bodyTextSmall
                            ?.copyWith(
                              color: LightColor.secondaryTextColor,
                              fontSize: AppDimens.fontBodySubTitle,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
          Positioned(
            top: AppDimens.sizeX6,
            right: AppDimens.sizeX6,
            child: switch (status) {
              UploadVerificationStatus.pending => _cornerBadge(
                tooltip: StringConstants.underReview,
                child: Icon(
                  Icons.hourglass_top_rounded,
                  color: LightColor.warningColor,
                  size: AppDimens.sizeX14,
                ),
              ),
              UploadVerificationStatus.approved => _cornerBadge(
                tooltip: StringConstants.approved,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: LightColor.successColor,
                  size: AppDimens.sizeX16,
                ),
              ),
              _ =>
                canRemove
                    ? _ThumbDeleteButton(small: true, onTap: onRemove!)
                    : const SizedBox.shrink(),
            },
          ),
          // Rejected documents stay updatable — replace action bottom-right.
          if (canReplace)
            Positioned(
              bottom: AppDimens.sizeX6,
              right: AppDimens.sizeX6,
              child: Tooltip(
                message: StringConstants.replaceThisRejectedDocument,
                child: InkWell(
                  onTap: onReplace,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                  child: Container(
                    width: AppDimens.sizeX28,
                    height: AppDimens.sizeX28,
                    decoration: BoxDecoration(
                      color: LightColor.redLightColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    ),
                    child: Icon(
                      Icons.cached_rounded,
                      color: LightColor.redColor,
                      size: AppDimens.sizeX16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VendorUploadItem extends StatelessWidget {
  const VendorUploadItem({
    super.key,
    required this.file,
    this.previewAsImage = false,
    this.forceFileLayout = false,
    this.onRemove,
    this.onReplace,
  });

  final UploadRef file;
  final bool previewAsImage;

  /// Forces the compact file-row (list) layout even for image files —
  /// used for the company-documents list.
  final bool forceFileLayout;
  final VoidCallback? onRemove;
  final VoidCallback? onReplace;

  bool get _isRejected =>
      file.verificationStatus == UploadVerificationStatus.rejected;

  bool get _isImageFile {
    if (forceFileLayout) return false;
    if (previewAsImage && _rawImageSource.isNotEmpty) return true;
    return _hasImageContent;
  }

  /// Whether the file is an image (by extension), regardless of layout mode —
  /// drives the document-row thumbnail.
  bool get _hasImageContent {
    if (_rawImageSource.isEmpty) return false;
    final String path = _pathWithoutQuery(_rawImageSource).toLowerCase();
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  String get _rawImageSource {
    final String remotePath = (file.remoteUrl ?? '').trim();
    return remotePath.isNotEmpty ? remotePath : file.remoteUrl ?? '';
  }

  String get _imageSource => _resolveMediaUrl(_rawImageSource);

  bool get _isNetworkImage {
    final String source = _imageSource.toLowerCase();
    return source.startsWith('http://') || source.startsWith('https://');
  }

  Future<void> _confirmRemove(BuildContext context) async {
    if (onRemove == null) return;

    final bool confirmed = await showDeleteDialog(
      context: context,
      title: StringConstants.deleteFile,
      message: '${StringConstants.removeFileConfirmationPrefix}"${file.name}"?',
      confirmText: StringConstants.delete,
      cancelText: StringConstants.cancel,
      icon: Icons.delete_outline_rounded,
      confirmColor: LightColor.redColor,
    );

    if (confirmed) {
      onRemove!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isImageFile) {
      return Container(
        margin: AppUtils().getMargin(bottom: AppDimens.sizeX10),
        decoration: BoxDecoration(
          color: _isRejected
              ? LightColor.redLightColor.withValues(alpha: 0.35)
              : LightColor.whiteColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX14),
          border: Border.all(
            color: _isRejected
                ? LightColor.redColor
                : LightColor.greyBorderColor,
            width: _isRejected ? 1.2 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: LightColor.shadowColor,
              blurRadius: AppDimens.radiusX10,
              offset: const Offset(0, AppDimens.sizeX4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _isNetworkImage
                  ? CustomImageView(
                      url: _imageSource,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : CustomImageView(
                      file: File(_rawImageSource),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
            ),

            Padding(
              padding: AppUtils().getPadding(
                left: AppDimens.sizeX12,
                top: AppDimens.sizeX10,
                right: AppDimens.sizeX8,
                bottom: AppDimens.sizeX10,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FutsalTheme.getTextTheme(context)
                              .bodyTextMedium
                              ?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (file.verificationStatus !=
                            UploadVerificationStatus.none) ...<Widget>[
                          const SizedBox(height: AppDimens.sizeX6),
                          VerificationStatusBadge(
                            status: file.verificationStatus,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.sizeX8),
                  _UploadActionButton(
                    file: file,
                    onRemove: onRemove == null
                        ? null
                        : () => _confirmRemove(context),
                    onReplace: onReplace,
                  ),
                ],
              ),
            ),
            if (_isRejected)
              const _RejectionCallout(
                message: StringConstants
                    .thisDocumentWasRejectedPleaseRemoveItAndAddANewC30fa5f11,
              ),
          ],
        ),
      );
    }

    return Container(
      margin: AppUtils().getMargin(bottom: AppDimens.sizeX10),
      padding: AppUtils().getPadding(all: AppDimens.sizeX12),
      decoration: BoxDecoration(
        color: _isRejected
            ? LightColor.redLightColor.withValues(alpha: 0.35)
            : LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(
          color: _isRejected ? LightColor.redColor : LightColor.greyBorderColor,
          width: _isRejected ? 1.2 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: AppDimens.radiusX10,
            offset: const Offset(0, AppDimens.sizeX4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX44,
                height: AppDimens.sizeX44,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: LightColor.background,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                ),
                child: _hasImageContent
                    ? _UploadImageView(file: file)
                    : Icon(
                        Icons.insert_drive_file_rounded,
                        color: LightColor.brandTextColor,
                        size: AppDimens.sizeX22,
                      ),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: FutsalTheme.getTextTheme(context).bodyTextMedium
                          ?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppDimens.sizeX6),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            padding: AppUtils().getPadding(
                              horizontal: AppDimens.sizeX8,
                              vertical: AppDimens.sizeX4,
                            ),
                            decoration: BoxDecoration(
                              color: LightColor.inputFillColor,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusX50,
                              ),
                            ),
                            child: Text(
                              file.name.split('.').last.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FutsalTheme.getTextTheme(context)
                                  .bodyTextSmall
                                  ?.copyWith(
                                    color: LightColor.secondaryTextColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                        if (file.verificationStatus !=
                            UploadVerificationStatus.none) ...<Widget>[
                          const SizedBox(width: AppDimens.sizeX8),
                          Flexible(
                            child: VerificationStatusBadge(
                              status: file.verificationStatus,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (onRemove != null || onReplace != null)
                _UploadActionButton(
                  file: file,
                  onRemove: onRemove == null
                      ? null
                      : () => _confirmRemove(context),
                  onReplace: onReplace,
                ),
            ],
          ),
          if (_isRejected) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX10),
            const _RejectionCallout(
              message: StringConstants
                  .thisDocumentWasRejectedPleaseRemoveItAndAddANewC30fa5f11,
            ),
          ],
        ],
      ),
    );
  }
}

class _RejectionCallout extends StatelessWidget {
  const _RejectionCallout({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppUtils().getMargin(
        top: AppDimens.sizeX10,
        left: AppDimens.sizeX12,
        right: AppDimens.sizeX12,
        bottom: AppDimens.sizeX12,
      ),
      padding: AppUtils().getPadding(
        horizontal: AppDimens.sizeX10,
        vertical: AppDimens.sizeX8,
      ),
      decoration: BoxDecoration(
        color: LightColor.redLightColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.redColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: LightColor.redColor,
            size: AppDimens.sizeX18,
          ),
          const SizedBox(width: AppDimens.sizeX8),
          Expanded(
            child: Text(
              message,
              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
                color: LightColor.redColor,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadActionButton extends StatelessWidget {
  const _UploadActionButton({
    required this.file,
    required this.onRemove,
    required this.onReplace,
  });

  final UploadRef file;
  final VoidCallback? onRemove;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    final bool locked = file.verificationStatus.isLocked;
    final bool rejected =
        file.verificationStatus == UploadVerificationStatus.rejected;

    if (locked) {
      return _IconActionButton(
        icon: Icons.lock_outline_rounded,
        background: LightColor.background,
        foreground: LightColor.disabledTextColor,
        onTap: null,
        tooltip: StringConstants
            .thisDocumentIsLockedWhileUnderReviewItCanBeRepla3c137b54,
      );
    }

    if (rejected && onReplace != null) {
      return _IconActionButton(
        icon: Icons.cached_rounded,
        background: LightColor.redLightColor,
        foreground: LightColor.redColor,
        onTap: onReplace,
        tooltip: StringConstants.replaceThisRejectedDocument,
      );
    }

    return _IconActionButton(
      icon: Icons.delete_outline_rounded,
      background: LightColor.background,
      foreground: LightColor.brandTextColor,
      onTap: onRemove,
      tooltip: null,
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget button = Container(
      width: AppDimens.sizeX36,
      height: AppDimens.sizeX36,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: foreground, size: AppDimens.sizeX18),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class VerificationStatusBadge extends StatelessWidget {
  const VerificationStatusBadge({super.key, required this.status});

  final UploadVerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final _BadgePalette palette = _paletteFor(status);
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.sizeX8,
        vertical: AppDimens.sizeX4,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX50),
        border: Border.all(color: palette.foreground.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            palette.icon,
            size: AppDimens.sizeX12,
            color: palette.foreground,
          ),
          const SizedBox(width: AppDimens.sizeX4),
          Flexible(
            child: Text(
              palette.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
                color: palette.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _BadgePalette _paletteFor(UploadVerificationStatus status) {
    switch (status) {
      case UploadVerificationStatus.pending:
        return _BadgePalette(
          label: StringConstants.pending,
          icon: Icons.schedule_rounded,
          foreground: LightColor.warningColor,
          background: LightColor.warningLightColor,
        );
      case UploadVerificationStatus.approved:
        return _BadgePalette(
          label: StringConstants.approved,
          icon: Icons.verified_rounded,
          foreground: LightColor.brandTextColor,
          background: LightColor.secondarySoft,
        );
      case UploadVerificationStatus.rejected:
        return _BadgePalette(
          label: StringConstants.rejected,
          icon: Icons.error_outline_rounded,
          foreground: LightColor.redColor,
          background: LightColor.redLightColor,
        );
      case UploadVerificationStatus.none:
        return _BadgePalette(
          label: '',
          icon: Icons.help_outline_rounded,
          foreground: LightColor.secondaryTextColor,
          background: LightColor.inputFillColor,
        );
    }
  }
}

class _BadgePalette {
  const _BadgePalette({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
}

String _pathWithoutQuery(String value) {
  final Uri? uri = Uri.tryParse(value);
  if (uri != null && uri.path.isNotEmpty) return uri.path;
  return value.split('?').first;
}

String _resolveMediaUrl(String value) {
  final List<String> candidates = _resolveMediaUrlCandidates(value);
  return candidates.isEmpty ? value.trim() : candidates.first;
}

List<String> _resolveMediaUrlCandidates(String value) {
  final String source = value.trim();
  if (source.isEmpty) return const <String>[];
  final String lower = source.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return <String>[source];
  }
  if (File(source).existsSync()) return <String>[source];

  final Uri apiUri = Uri.parse(APIEndpoint.baseUrl);
  final String origin =
      '${apiUri.scheme}://${apiUri.host}'
      '${apiUri.hasPort ? ':${apiUri.port}' : ''}';
  final String path = source.startsWith('/') ? source : '/$source';
  final String apiBase = APIEndpoint.baseUrl.endsWith('/')
      ? APIEndpoint.baseUrl.substring(0, APIEndpoint.baseUrl.length - 1)
      : APIEndpoint.baseUrl;

  return <String>{'$origin$path', '$apiBase$path'}.toList(growable: false);
}

InputDecoration vendorInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: LightColor.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusX18),
      borderSide: BorderSide(color: LightColor.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusX18),
      borderSide: BorderSide(color: LightColor.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusX18),
      borderSide: const BorderSide(
        color: LightColor.secondaryColor,
        width: 1.4,
      ),
    ),
  );
}

String stepStatusLabel(StepStatus status) {
  switch (status) {
    case StepStatus.locked:
      return 'Locked';
    case StepStatus.notStarted:
      return 'Not Started';
    case StepStatus.inProgress:
      return 'In Progress';
    case StepStatus.complete:
      return 'Complete';
    case StepStatus.error:
      return 'Needs Attention';
    case StepStatus.pending:
      throw UnimplementedError();
  }
}

Color stepStatusColor(StepStatus status) {
  switch (status) {
    case StepStatus.locked:
      return LightColor.hintTextColor;
    case StepStatus.notStarted:
      return LightColor.secondaryTextColor;
    case StepStatus.inProgress:
      return LightColor.warningColor;
    case StepStatus.complete:
      return LightColor.secondaryColor;
    case StepStatus.error:
      return LightColor.redColor;
    case StepStatus.pending:
      throw UnimplementedError();
  }
}

String saveStatusLabel(DraftSaveStatus status, DateTime? lastSavedAt) {
  switch (status) {
    case DraftSaveStatus.idle:
      if (lastSavedAt == null) return 'Session state';
      return 'Ready in session';
    case DraftSaveStatus.saving:
      return 'Saving draft...';
    case DraftSaveStatus.saved:
      if (lastSavedAt == null) return 'Draft saved';
      return 'Saved at ${formatTime(lastSavedAt)}';
    case DraftSaveStatus.failure:
      return 'Draft save failed';
    case DraftSaveStatus.error:
      throw UnimplementedError();
    case DraftSaveStatus.unsaved:
      return 'Session only';
  }
}

class VendorSwitchButton extends StatelessWidget {
  const VendorSwitchButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = AppDimens.sizeX44,
    this.height = AppDimens.sizeX26,
    this.thumbSize = AppDimens.sizeX20,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final double thumbSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: value,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: width,
          height: height,
          padding: AppUtils().getPadding(all: AppDimens.paddingX4),
          decoration: BoxDecoration(
            color: value
                ? LightColor.secondaryColor
                : LightColor.secondaryTextColor.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: thumbSize,
            height: thumbSize,
            decoration: BoxDecoration(
              color: LightColor.whiteColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

String formatTime(DateTime value) {
  final int hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final String minute = value.minute.toString().padLeft(2, '0');
  final String suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

double? parseDouble(String value) {
  final String normalized = value.trim().replaceAll(',', '');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

int? parseInt(String value) {
  final String normalized = value.trim().replaceAll(',', '');
  if (normalized.isEmpty) return null;
  return int.tryParse(normalized);
}

String formatDouble(double? value) {
  if (value == null) return '';
  if (value == value.toInt()) return '${value.toInt()}';
  return value.toString();
}

String formatInt(int? value) {
  if (value == null) return '';
  return '$value';
}

IconData _vendorFieldIcon(String label, TextInputType? keyboardType) {
  final String normalized = label.toLowerCase();

  if (normalized.contains('exact location')) {
    return Icons.location_on_outlined;
  }

  if (normalized.contains('name')) return Icons.person_outline_rounded;
  if (normalized.contains('registration') || normalized.contains('reg no')) {
    return Icons.confirmation_number_outlined;
  }
  if (normalized.contains('website') || normalized.contains('url')) {
    return Icons.link_rounded;
  }
  if (normalized.contains('social')) return Icons.people_outline_rounded;
  if (normalized.contains('location') ||
      normalized.contains('exact location')) {
    return Icons.image_outlined;
  }
  if (normalized.contains('email')) return Icons.email_outlined;
  if (normalized.contains('phone')) return Icons.phone_outlined;
  if (normalized.contains('address') || normalized.contains('location')) {
    return Icons.location_on_outlined;
  }
  if (normalized.contains('time')) return Icons.schedule_rounded;
  if (normalized.contains('price') ||
      normalized.contains('payment') ||
      normalized.contains('commission')) {
    return Icons.payments_outlined;
  }
  if (normalized.contains('description') ||
      normalized.contains('policy') ||
      normalized.contains('rules')) {
    return Icons.notes_rounded;
  }
  if (keyboardType == TextInputType.phone) return Icons.phone_outlined;
  if (keyboardType == TextInputType.emailAddress) {
    return Icons.email_outlined;
  }
  return Icons.edit_outlined;
}

/// A location search field with autocomplete suggestions from Nominatim.
class VendorLocationSearchField extends StatefulWidget {
  const VendorLocationSearchField({
    super.key,
    required this.initialValue,
    required this.onLocationSelected,
    this.label = 'Exact location',
    this.hintText = 'Search location...',
  });

  final String initialValue;
  final ValueChanged<PickedLocation> onLocationSelected;
  final String label;
  final String hintText;

  @override
  State<VendorLocationSearchField> createState() =>
      _VendorLocationSearchFieldState();
}

class _VendorLocationSearchFieldState extends State<VendorLocationSearchField> {
  late final TextEditingController _controller;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<List<_LocationResult>> _resultsNotifier =
      ValueNotifier<List<_LocationResult>>(<_LocationResult>[]);
  final ValueNotifier<bool> _isSearchingNotifier = ValueNotifier<bool>(false);

  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(VendorLocationSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _resultsNotifier.dispose();
    _isSearchingNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final String query = value.trim();
    final int requestId = ++_requestId;

    if (query.length < 3) {
      _removeOverlay();
      _resultsNotifier.value = <_LocationResult>[];
      _isSearchingNotifier.value = false;
      return;
    }

    _isSearchingNotifier.value = true;
    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => _searchPlaces(query, requestId),
    );
  }

  Future<void> _searchPlaces(String query, int requestId) async {
    if (query.isEmpty) {
      _isSearchingNotifier.value = false;
      return;
    }

    try {
      final Uri uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        <String, String>{
          'q': query,
          'format': 'jsonv2',
          'limit': '6',
          'addressdetails': '1',
        },
      );

      final http.Response response = await http.get(
        uri,
        headers: <String, String>{
          'User-Agent': 'hamro_footsall/1.0 (location-search)',
          'Accept-Language': 'en',
        },
      );

      if (response.statusCode != 200) {
        _isSearchingNotifier.value = false;
        return;
      }

      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      final List<_LocationResult> matches = decoded
          .map((dynamic item) {
            final Map<String, dynamic> json = item as Map<String, dynamic>;
            return _LocationResult(
              displayName: (json['display_name'] as String? ?? '').trim(),
              latitude: double.parse(json['lat'] as String),
              longitude: double.parse(json['lon'] as String),
            );
          })
          .where((result) => result.displayName.isNotEmpty)
          .toList();

      if (!mounted || requestId != _requestId) return;

      _resultsNotifier.value = matches;
      _isSearchingNotifier.value = false;

      if (matches.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      _isSearchingNotifier.value = false;
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: context.findRenderObject() != null
            ? (context.findRenderObject() as RenderBox?)?.size.width ?? 300
            : 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            color: LightColor.cardColor,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LightColor.borderColor),
              ),
              child: ValueListenableBuilder<List<_LocationResult>>(
                valueListenable: _resultsNotifier,
                builder:
                    (BuildContext context, List<_LocationResult> results, _) {
                      return ListView.separated(
                        shrinkWrap: true,
                        padding: AppUtils().getPadding(
                          vertical: AppDimens.sizeX4,
                        ),
                        itemCount: results.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: AppDimens.sizeX1),
                        itemBuilder: (context, index) {
                          final result = results[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.location_on_outlined,
                              size: AppDimens.sizeX18,
                              color: LightColor.brandTextColor,
                            ),
                            title: Text(
                              result.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppDimens.sizeX12,
                                color: LightColor.primaryTextColor,
                              ),
                            ),
                            onTap: () => _selectResult(result),
                          );
                        },
                      );
                    },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectResult(_LocationResult result) {
    _removeOverlay();
    _controller.text = result.displayName;
    _focusNode.unfocus();

    widget.onLocationSelected(
      PickedLocation(
        label: result.displayName,
        latitude: result.latitude,
        longitude: result.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isSearchingNotifier,
        builder: (BuildContext context, bool isSearching, _) {
          return ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (BuildContext context, TextEditingValue value, __) {
              return CustomTextField(
                controller: _controller,
                focusNode: _focusNode,
                labelText: widget.label,
                hintText: widget.hintText,
                icon: Icons.search_rounded,
                onChanged: _onSearchChanged,
                suffixIcon: isSearching
                    ? Padding(
                        padding: AppUtils().getPadding(all: AppDimens.sizeX12),
                        child: SizedBox(
                          width: AppDimens.sizeX18,
                          height: AppDimens.sizeX18,
                          child: LoadingWidget(),
                        ),
                      )
                    : value.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: AppDimens.sizeX18),
                        onPressed: () {
                          _controller.clear();
                          _removeOverlay();
                          _isSearchingNotifier.value = false;
                          _resultsNotifier.value = <_LocationResult>[];
                        },
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _LocationResult {
  const _LocationResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;
}
