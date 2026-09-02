import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';

/// Confirms an irreversible action by making the user type [confirmationWord].
///
/// A plain yes/no dialog is one stray tap away from destroying something that
/// cannot be restored; typing the word is a deliberate act, so the confirm
/// button stays disabled until the field matches exactly (case-insensitively,
/// trimmed).
///
/// Returns true only when the user typed the word and pressed confirm —
/// dismissing the sheet any other way returns false.
///
/// ```dart
/// final bool ok = await showConfirmWordSheet(
///   context: context,
///   title: 'Delete your account?',
///   message: 'This cannot be undone.',
///   confirmationWord: 'DELETE',
///   confirmText: 'Delete Account',
/// );
/// ```
Future<bool> showConfirmWordSheet({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmationWord,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  IconData icon = Icons.warning_amber_rounded,

  /// Extra points the user should read before confirming, one per line.
  List<String> consequences = const <String>[],
}) async {
  final bool? confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: LightColor.cardColor,
    // Destructive and keyboard-driven: dragging it shut mid-typing loses the
    // typed word, and the button is the only way to say yes.
    isScrollControlled: true,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimens.radiusX20),
      ),
    ),
    builder: (BuildContext sheetContext) => _ConfirmWordSheet(
      title: title,
      message: message,
      confirmationWord: confirmationWord,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
      consequences: consequences,
    ),
  );
  return confirmed ?? false;
}

Future<String?> showConfirmWordReasonSheet({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmationWord,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  IconData icon = Icons.warning_amber_rounded,
  List<String> consequences = const <String>[],
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: LightColor.cardColor,
    isScrollControlled: true,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimens.radiusX20),
      ),
    ),
    builder: (BuildContext sheetContext) => _ConfirmWordReasonSheet(
      title: title,
      message: message,
      confirmationWord: confirmationWord,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
      consequences: consequences,
    ),
  );
}

class _ConfirmWordSheet extends StatefulWidget {
  const _ConfirmWordSheet({
    required this.title,
    required this.message,
    required this.confirmationWord,
    required this.confirmText,
    required this.cancelText,
    required this.icon,
    required this.consequences,
  });

  final String title;
  final String message;
  final String confirmationWord;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final List<String> consequences;

  @override
  State<_ConfirmWordSheet> createState() => _ConfirmWordSheetState();
}

class _ConfirmWordSheetState extends State<_ConfirmWordSheet> {
  final TextEditingController _controller = TextEditingController();

  /// True once the field holds exactly the confirmation word.
  bool get _matches =>
      _controller.text.trim().toUpperCase() ==
      widget.confirmationWord.toUpperCase();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_matches) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color danger = LightColor.redColor;

    return Padding(
      // Lifts the sheet clear of the keyboard the field brings up.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX20,
            top: AppDimens.paddingX12,
            bottom: AppDimens.paddingX20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: AppDimens.sizeX36,
                  height: AppDimens.sizeX4,
                  decoration: BoxDecoration(
                    color: LightColor.dividerColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX4),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.paddingX20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: AppDimens.sizeX44,
                    height: AppDimens.sizeX44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: danger.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: danger,
                      size: AppDimens.sizeX24,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: textTheme.bodyTextLarge?.copyWith(
                            color: danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppDimens.paddingX4),
                        Text(
                          widget.message,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.secondaryTextColor,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.consequences.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppDimens.paddingX16),
                Container(
                  width: double.infinity,
                  padding: AppUtils().getPadding(all: AppDimens.paddingX12),
                  decoration: BoxDecoration(
                    color: danger.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                    border: Border.all(color: danger.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (int i = 0; i < widget.consequences.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            top: i == 0 ? 0 : AppDimens.paddingX8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.remove_circle_outline_rounded,
                                size: AppDimens.sizeX16,
                                color: danger,
                              ),
                              const SizedBox(width: AppDimens.paddingX8),
                              Expanded(
                                child: Text(
                                  widget.consequences[i],
                                  style: textTheme.bodyTextSmall?.copyWith(
                                    color: LightColor.primaryTextColor,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppDimens.paddingX18),
              // The instruction names the word, so the disabled button is never
              // a dead end the user has to guess their way out of.
              RichText(
                text: TextSpan(
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                  children: <InlineSpan>[
                    const TextSpan(text: 'Type '),
                    TextSpan(
                      text: widget.confirmationWord,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: danger,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const TextSpan(text: ' below to confirm.'),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.paddingX10),
              CustomTextField(
                controller: _controller,
                labelText: widget.confirmationWord,
                hintText: widget.confirmationWord,
                icon: Icons.keyboard_outlined,
                iconColor: _matches ? danger : null,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                isRequired: false,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(
                    widget.confirmationWord.length,
                  ),
                ],
                // Rebuilds on every keystroke — this is what unlocks the
                // button.
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _confirm(),
                suffixIcon: _matches
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: LightColor.successColor,
                        size: AppDimens.sizeX20,
                      )
                    : null,
              ),
              const SizedBox(height: AppDimens.paddingX18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      text: widget.cancelText,
                      isOutlined: true,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Expanded(
                    child: CustomButton(
                      text: widget.confirmText,
                      // CustomButton paints one background for every state, so
                      // the disabled look has to be passed in rather than left
                      // to the null callback.
                      backgroundColor: _matches
                          ? danger
                          : danger.withValues(alpha: 0.30),
                      onPressed: _matches ? _confirm : null,
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

class _ConfirmWordReasonSheet extends StatefulWidget {
  const _ConfirmWordReasonSheet({
    required this.title,
    required this.message,
    required this.confirmationWord,
    required this.confirmText,
    required this.cancelText,
    required this.icon,
    required this.consequences,
  });

  final String title;
  final String message;
  final String confirmationWord;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final List<String> consequences;

  @override
  State<_ConfirmWordReasonSheet> createState() =>
      _ConfirmWordReasonSheetState();
}

class _ConfirmWordReasonSheetState extends State<_ConfirmWordReasonSheet> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool get _matches =>
      _wordController.text.trim().toUpperCase() ==
      widget.confirmationWord.toUpperCase();

  bool get _canConfirm => _matches && _reasonController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _wordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_canConfirm) return;
    Navigator.of(context).pop(_reasonController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color danger = LightColor.redColor;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: AppUtils().getPadding(
              symmetricHorizontal: AppDimens.paddingX20,
              top: AppDimens.paddingX12,
              bottom: AppDimens.paddingX20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: AppDimens.sizeX36,
                    height: AppDimens.sizeX4,
                    decoration: BoxDecoration(
                      color: LightColor.dividerColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX4),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: AppDimens.sizeX44,
                      height: AppDimens.sizeX44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: danger.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: danger,
                        size: AppDimens.sizeX24,
                      ),
                    ),
                    const SizedBox(width: AppDimens.paddingX12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.title,
                            style: textTheme.bodyTextLarge?.copyWith(
                              color: danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppDimens.paddingX4),
                          Text(
                            widget.message,
                            style: textTheme.bodyTextSmall?.copyWith(
                              color: LightColor.secondaryTextColor,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.consequences.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppDimens.paddingX16),
                  Container(
                    width: double.infinity,
                    padding: AppUtils().getPadding(all: AppDimens.paddingX12),
                    decoration: BoxDecoration(
                      color: danger.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                      border: Border.all(color: danger.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        for (int i = 0; i < widget.consequences.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              top: i == 0 ? 0 : AppDimens.paddingX8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.remove_circle_outline_rounded,
                                  size: AppDimens.sizeX16,
                                  color: danger,
                                ),
                                const SizedBox(width: AppDimens.paddingX8),
                                Expanded(
                                  child: Text(
                                    widget.consequences[i],
                                    style: textTheme.bodyTextSmall?.copyWith(
                                      color: LightColor.primaryTextColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppDimens.paddingX18),
                RichText(
                  text: TextSpan(
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                    children: <InlineSpan>[
                      const TextSpan(text: 'Type '),
                      TextSpan(
                        text: widget.confirmationWord,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: danger,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const TextSpan(text: ' below to continue.'),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX10),
                CustomTextField(
                  controller: _wordController,
                  labelText: widget.confirmationWord,
                  hintText: widget.confirmationWord,
                  icon: Icons.keyboard_outlined,
                  iconColor: _matches ? danger : null,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  isRequired: false,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(
                      widget.confirmationWord.length,
                    ),
                  ],
                  onChanged: (_) => setState(() {}),
                  suffixIcon: _matches
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: LightColor.successColor,
                          size: AppDimens.sizeX20,
                        )
                      : null,
                ),
                if (_matches) ...<Widget>[
                  const SizedBox(height: AppDimens.paddingX14),
                  CustomTextField(
                    controller: _reasonController,
                    labelText: StringConstants.deleteAccountReason,
                    hintText: StringConstants.deleteAccountReasonHint,
                    minLines: 3,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    isRequired: true,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _confirm(),
                  ),
                  if (_reasonController.text.trim().isEmpty) ...<Widget>[
                    const SizedBox(height: AppDimens.paddingX6),
                    Text(
                      StringConstants.deleteAccountReasonRequired,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: danger,
                        fontSize: AppDimens.fontBodySubTitle,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: AppDimens.paddingX18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        text: widget.cancelText,
                        isOutlined: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppDimens.paddingX12),
                    Expanded(
                      child: CustomButton(
                        text: widget.confirmText,
                        backgroundColor: _canConfirm
                            ? danger
                            : danger.withValues(alpha: 0.30),
                        onPressed: _canConfirm ? _confirm : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
