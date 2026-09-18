import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/review_change_request.dart';

/// Collects what travels with `POST /reviews/{review}/change-request`.
///
/// A delete needs only the reason. An edit also needs the review the user
/// wants in its place — the server refuses the request without it — so the
/// current comment and rating are offered here for them to change. Both are
/// validated on this side rather than waiting for a 422.
class ReviewChangeRequestSheet extends StatefulWidget {
  const ReviewChangeRequestSheet({
    super.key,
    required this.type,
    this.initialComment = '',
  });

  final ReviewChangeRequestType type;

  /// The review as it stands, so an edit starts from it instead of a blank box.
  final String initialComment;

  /// Returns the filled request, or null when the sheet was dismissed.
  static Future<ReviewChangeRequestInput?> show(
    BuildContext context, {
    required ReviewChangeRequestType type,
    String initialComment = '',
  }) {
    return showAppBottomSheet<ReviewChangeRequestInput>(
      context: context,
      builder: (_) =>
          ReviewChangeRequestSheet(type: type, initialComment: initialComment),
    );
  }

  @override
  State<ReviewChangeRequestSheet> createState() =>
      _ReviewChangeRequestSheetState();
}

class _ReviewChangeRequestSheetState extends State<ReviewChangeRequestSheet> {
  final TextEditingController _reasonCtrl = TextEditingController();
  late final TextEditingController _reviewCtrl = TextEditingController(
    text: widget.initialComment,
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isDelete => widget.type == ReviewChangeRequestType.delete;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      ReviewChangeRequestInput(
        type: widget.type,
        reason: _reasonCtrl.text.trim(),
        requestedReview: _isDelete ? '' : _reviewCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX36,
                height: AppDimens.sizeX36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isDelete
                      ? LightColor.redColor.withValues(alpha: 0.12)
                      : LightColor.categoryContainer(LightColor.secondaryColor),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Icon(
                  _isDelete
                      ? Icons.delete_outline_rounded
                      : Icons.edit_outlined,
                  size: AppDimens.sizeX18,
                  color: _isDelete
                      ? LightColor.redColor
                      : LightColor.brandTextColor,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: Text(
                  _isDelete
                      ? StringConstants.requestDeleteTitle
                      : StringConstants.requestEditTitle,
                  style: textTheme.headingSubTitle?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX8),
          Text(
            _isDelete
                ? StringConstants.requestDeleteSubtitle
                : StringConstants.requestEditSubtitle,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.5,
            ),
          ),
          if (!_isDelete) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX16),
            CustomTextField(
              labelText: StringConstants.updatedReview,
              hintText: StringConstants.updatedReviewHint,
              controller: _reviewCtrl,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              ensureVisibleOnFocus: true,
              validator: (String? value) => (value ?? '').trim().isEmpty
                  ? StringConstants.updatedReviewRequired
                  : null,
            ),
          ],
          const SizedBox(height: AppDimens.sizeX16),
          CustomTextField(
            labelText: StringConstants.reason,
            hintText: StringConstants.reasonHint,
            controller: _reasonCtrl,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            ensureVisibleOnFocus: true,
            validator: (String? value) => (value ?? '').trim().isEmpty
                ? StringConstants.reasonRequired
                : null,
          ),
          const SizedBox(height: AppDimens.sizeX20),
          Row(
            children: <Widget>[
              Expanded(
                child: CustomButton(
                  text: StringConstants.cancel,
                  isOutlined: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: CustomButton(
                  text: StringConstants.submitRequest,
                  backgroundColor: _isDelete ? LightColor.redColor : null,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
