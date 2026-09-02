import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/expenses/data/model/expense_model.dart';
import 'package:hamro_futsal/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

/// Bottom sheet showing an expense's full details with edit and delete
/// actions. Pops with [editAction] or [deleteAction] accordingly.
class ExpenseDetailsSheet extends StatelessWidget {
  const ExpenseDetailsSheet({
    super.key,
    required this.expense,
    required this.venueName,
    this.courtName,
  });

  static const editAction = 'edit';
  static const deleteAction = 'delete';

  final ExpenseModel expense;
  final String venueName;
  final String? courtName;

  String get _dateLabel {
    final d = expense.date;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${formatShortDate(d)}, ${d.year} · ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final category = expense.category;
    return SafeArea(
      child: ConstrainedBox(
        // Documents make the sheet tall — cap and scroll instead of
        // overflowing on small screens.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX20,
            AppDimens.paddingX12,
            AppDimens.paddingX20,
            AppDimens.paddingX20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LightColor.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.paddingX16),
              Row(
                children: [
                  // Server category image when available, local icon otherwise.
                  ExpenseCategoryIcon(
                    category: category,
                    categoryId: expense.categoryId,
                    boxSize: 44,
                    iconSize: 20,
                    radius: AppDimens.radiusX8,
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.vendor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyTextMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          // Server category title when available.
                          expense.categoryDetail?.name ?? category.label,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: category.color,
                            fontWeight: FontWeight.w600,
                            fontSize: AppDimens.fontBodySubTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX10),
                  Text(
                    '- ${ExpenseFmt.npr(expense.amount)}',
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: LightColor.redColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.paddingX14),
              Divider(height: 1, color: LightColor.dividerColor),
              const SizedBox(height: AppDimens.paddingX6),
              _DetailRow(label: StringConstants.purpose, value: expense.vendor),
              _DetailRow(label: StringConstants.date, value: _dateLabel),
              _DetailRow(
                label: StringConstants.venue,
                value: courtName == null
                    ? venueName
                    : '$venueName · $courtName',
              ),
              _DetailRow(
                label: StringConstants.paidVia,
                value: expense.method.label,
              ),
              _DetailRow(
                label: StringConstants.note,
                value: expense.note ?? '—',
              ),
              if (expense.document != null) ...[
                const SizedBox(height: AppDimens.paddingX8),
                Text(
                  StringConstants.document,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.hintTextColor,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX8),
                _DocumentPreview(document: expense.document!),
              ],
              const SizedBox(height: AppDimens.paddingX16),
              Row(
                children: [
                  Expanded(
                    child: _SheetAction(
                      label: StringConstants.edit,
                      icon: Icons.edit_outlined,
                      color: LightColor.secondaryColor,
                      onTap: () => Navigator.of(context).pop(editAction),
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Expanded(
                    child: _SheetAction(
                      label: StringConstants.delete,
                      icon: Icons.delete_outline_rounded,
                      color: LightColor.redColor,
                      onTap: () => Navigator.of(context).pop(deleteAction),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline preview of the attached document: images render as a photo;
/// PDFs / Word files render as a file row.
class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({required this.document});

  final String document;

  bool get _isImage {
    final d = document.toLowerCase();
    return d.endsWith('.jpg') ||
        d.endsWith('.jpeg') ||
        d.endsWith('.png') ||
        d.endsWith('.webp');
  }

  bool get _isNetwork => document.toLowerCase().startsWith('http');

  String get _fileName => document.split('/').last;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    if (!_isImage) {
      final lower = document.toLowerCase();
      return Container(
        padding: const EdgeInsets.all(AppDimens.paddingX12),
        decoration: BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          border: Border.all(color: LightColor.dividerColor),
        ),
        child: Row(
          children: [
            Icon(
              lower.endsWith('.pdf')
                  ? Icons.picture_as_pdf_outlined
                  : Icons.description_outlined,
              size: 20,
              color: LightColor.secondaryColor,
            ),
            const SizedBox(width: AppDimens.paddingX10),
            Expanded(
              child: Text(
                _fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LightColor.primaryTextColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: SizedBox(
        width: double.infinity,
        height: 160,
        child: _isNetwork
            ? CustomImageView(
                url: document,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              )
            : CustomImageView(
                file: File(document),
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

/// Outlined action button used by the sheet footer (Edit / Delete).
class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        ),
      ),
      label: Text(
        label,
        style: FutsalTheme.getTextTheme(
          context,
        ).bodyTextMedium?.copyWith(fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyTextSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
