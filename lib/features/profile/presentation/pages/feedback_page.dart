import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/profile/data/model/feedback_option_model.dart';
import 'package:hamro_footsall/features/profile/data/repositories/feedback_repository_impl.dart';

const int _kMinMessageLength = 12;
const int _kMaxMessageLength = 600;

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static final FeedbackRepositoryImpl _repository = FeedbackRepositoryImpl();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  FeedbackCatalog? _catalog;
  FeedbackOptionModel? _selectedType;
  FeedbackOptionModel? _selectedCategory;
  int _rating = 0;
  int _messageLength = 0;
  bool _isSubmitting = false;
  bool _isLoadingOptions = true;
  String? _optionsError;

  @override
  void initState() {
    super.initState();
    _loadFeedbackOptions();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedbackOptions({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _isLoadingOptions = true;
        _optionsError = null;
      });
    }

    final result = await _repository.getCatalog(forceRefresh: forceRefresh);
    if (!mounted) return;

    result.fold(
      (error) => setState(() {
        _isLoadingOptions = false;
        _optionsError = error.errorMessage;
      }),
      (catalog) => setState(() {
        _catalog = catalog;
        _isLoadingOptions = false;
        _optionsError = null;
        _selectedType = _resolveTypeSelection(catalog);
        _selectedCategory = _resolveCategorySelection(catalog, _selectedType);
      }),
    );
  }

  FeedbackOptionModel? _resolveTypeSelection(FeedbackCatalog catalog) {
    final FeedbackOptionModel? current = _selectedType;
    if (current != null) {
      for (final FeedbackOptionModel type in catalog.types) {
        if (type.id == current.id) return type;
      }
    }
    return catalog.types.isEmpty ? null : catalog.types.first;
  }

  FeedbackOptionModel? _resolveCategorySelection(
    FeedbackCatalog catalog,
    FeedbackOptionModel? selectedType,
  ) {
    final List<FeedbackOptionModel> available = catalog.categoriesForType(
      selectedType?.id,
    );
    final FeedbackOptionModel? current = _selectedCategory;
    if (current != null) {
      for (final FeedbackOptionModel category in available) {
        if (category.id == current.id) return category;
      }
    }
    return available.isEmpty ? null : available.first;
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isSubmitting) return;
    if (_selectedType == null || _selectedCategory == null) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Please choose a feedback type and category first.',
        key: 'feedback_option_required',
      );
      return;
    }
    if (_rating == 0) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Please rate your experience before submitting.',
        key: 'rating_required',
      );
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    final result = await _repository.submitFeedback(
      feedbackCategoryId: _selectedCategory!.id,
      feedbackTypeId: _selectedType!.id,
      rating: _rating,
      message: _messageController.text.trim(),
      contactInfo: _contactController.text.trim(),
    );
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    final bool submitted = result.fold((error) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        error.errorMessage,
        key: 'feedback_submit_failed',
      );
      return false;
    }, (_) => true);

    if (!submitted) return;

    await _showThankYouDialog();
    if (mounted) Navigator.of(context).pop();
  }

  /// A small celebratory confirmation beats a passing snackbar for the one
  /// moment the user gives us their time.
  Future<void> _showThankYouDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          _ThankYouDialog(onDone: () => Navigator.of(dialogContext).pop()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: StringConstants.feedback,
        actions: <Widget>[
          TextButton(
            onPressed: () => context.pushNamed(AppRouterParams.myFeedback.name),
            child: Text(
              'My Feedback',
              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
                color: LightColor.secondaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX20,
            AppDimens.paddingX16,
            AppDimens.paddingX20,
            AppDimens.paddingX28,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _HeroPanel(),
                const SizedBox(height: AppDimens.paddingX16),
                _FormCard(
                  children: <Widget>[
                    const _SectionLabel(
                      icon: Icons.category_outlined,
                      label: StringConstants.feedbackCategory,
                    ),
                    const SizedBox(height: AppDimens.paddingX10),
                    _FeedbackOptionsBlock(
                      isLoading: _isLoadingOptions,
                      errorText: _optionsError,
                      onRetry: () => _loadFeedbackOptions(forceRefresh: true),
                      child: _AudienceSegments(
                        options:
                            _catalog?.categories ??
                            const <FeedbackOptionModel>[],
                        value: _selectedCategory,
                        onChanged: (FeedbackOptionModel value) =>
                            setState(() => _selectedCategory = value),
                      ),
                    ),
                    const _SectionDivider(),
                    const _SectionLabel(
                      icon: Icons.sell_outlined,
                      label: StringConstants.feedbackType,
                    ),
                    const SizedBox(height: AppDimens.paddingX10),
                    _FeedbackOptionsBlock(
                      isLoading: _isLoadingOptions,
                      errorText: _optionsError,
                      onRetry: () => _loadFeedbackOptions(forceRefresh: true),
                      child: _MoodChips(
                        options:
                            _catalog?.types ?? const <FeedbackOptionModel>[],
                        value: _selectedType,
                        onChanged: (FeedbackOptionModel value) => setState(() {
                          _selectedType = value;
                          _selectedCategory = _resolveCategorySelection(
                            _catalog ??
                                const FeedbackCatalog(
                                  types: <FeedbackOptionModel>[],
                                  categories: <FeedbackOptionModel>[],
                                ),
                            value,
                          );
                        }),
                      ),
                    ),
                    const _SectionDivider(),
                    const _SectionLabel(
                      icon: Icons.star_outline_rounded,
                      label: 'How was your experience?',
                    ),
                    const SizedBox(height: AppDimens.paddingX10),
                    _RatingBlock(
                      rating: _rating,
                      onChanged: (rating) {
                        HapticFeedback.selectionClick();
                        setState(() => _rating = rating);
                      },
                    ),
                    const _SectionDivider(),
                    const _SectionLabel(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: StringConstants.feedbackMessage,
                    ),
                    const SizedBox(height: AppDimens.paddingX10),
                    CustomTextField(
                      labelText: StringConstants.feedbackMessage,
                      hintText:
                          'What worked well? What should we improve? The more detail, the better.',
                      maxLines: 6,
                      minLines: 4,
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      ensureVisibleOnFocus: true,
                      onChanged: (value) =>
                          setState(() => _messageLength = value.trim().length),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(_kMaxMessageLength),
                      ],
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) return 'Please add a short message.';
                        if (text.length < _kMinMessageLength) {
                          return 'Please provide a little more detail.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimens.paddingX6),
                    _MessageCounter(length: _messageLength),
                    const SizedBox(height: AppDimens.paddingX14),
                    CustomTextField(
                      labelText: StringConstants.feedbackContact,
                      hintText: 'Phone number or email',
                      icon: Icons.alternate_email_rounded,
                      controller: _contactController,
                      isRequired: false,
                      keyboardType: TextInputType.emailAddress,
                      ensureVisibleOnFocus: true,
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) return null;
                        if (text.length < 5) {
                          return 'Please enter a valid contact.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingX14),
                const _PrivacyNote(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: AppDimens.sizeX70,
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX20,
            AppDimens.paddingX12,
            AppDimens.paddingX20,
            AppDimens.paddingX12,
          ),
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            border: Border(
              top: BorderSide(color: LightColor.dividerColor, width: 1),
            ),
          ),
          child: CustomButton(
            text: StringConstants.submitFeedback,
            icon: Icons.send_rounded,
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}

/// Brand gradient header with soft decorative circles.
class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF163A34), LightColor.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(top: -30, right: -20, child: _decorCircle(110, 0.10)),
            Positioned(bottom: -40, right: 60, child: _decorCircle(90, 0.06)),
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingX18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(AppDimens.paddingX10),
                    decoration: BoxDecoration(
                      color: LightColor.whiteColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                    ),
                    child: Icon(
                      Icons.reviews_rounded,
                      color: LightColor.inverseTextColor,
                      size: AppDimens.sizeX24,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          StringConstants.feedbackTitle,
                          style: textTheme.bodyTextLarge?.copyWith(
                            color: LightColor.inverseTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppDimens.paddingX4),
                        Text(
                          StringConstants.feedbackSubtitle,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.inverseTextColor.withValues(
                              alpha: 0.9,
                            ),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: LightColor.whiteColor.withValues(alpha: alpha),
    ),
  );
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: AppDimens.sizeX16, color: LightColor.secondaryColor),
        const SizedBox(width: AppDimens.paddingX8),
        Text(
          label,
          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
      child: Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
    );
  }
}

class _FeedbackOptionsBlock extends StatelessWidget {
  const _FeedbackOptionsBlock({
    required this.isLoading,
    required this.errorText,
    required this.onRetry,
    required this.child,
  });

  final bool isLoading;
  final String? errorText;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _FeedbackStatusRow(
        leading: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: LightColor.secondaryColor,
          ),
        ),
        message: 'Loading options...',
      );
    }

    if (errorText != null) {
      return _FeedbackStatusRow(
        leading: Icon(
          Icons.error_outline_rounded,
          size: 18,
          color: LightColor.redColor,
        ),
        message: errorText!,
        actionLabel: StringConstants.retry,
        onAction: onRetry,
      );
    }

    return child;
  }
}

class _AudienceSegments extends StatelessWidget {
  const _AudienceSegments({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<FeedbackOptionModel> options;
  final FeedbackOptionModel? value;
  final ValueChanged<FeedbackOptionModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    if (options.isEmpty) {
      return _FeedbackStatusRow(
        leading: Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: LightColor.hintTextColor,
        ),
        message: 'No feedback categories available.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX4),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: options
            .map((FeedbackOptionModel option) {
              final bool selected = option.id == value?.id;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    height: AppDimens.sizeX36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? LightColor.secondaryColor
                          : LightColor.transparentColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    ),
                    child: Text(
                      option.name,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: selected
                            ? LightColor.inverseTextColor
                            : LightColor.secondaryTextColor,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _MoodChips extends StatelessWidget {
  const _MoodChips({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<FeedbackOptionModel> options;
  final FeedbackOptionModel? value;
  final ValueChanged<FeedbackOptionModel> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return _FeedbackStatusRow(
        leading: Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: LightColor.hintTextColor,
        ),
        message: 'No feedback types available.',
      );
    }

    return Row(
      children: <Widget>[
        for (final FeedbackOptionModel option in options) ...<Widget>[
          if (option != options.first)
            const SizedBox(width: AppDimens.paddingX8),
          Expanded(
            child: _MoodChip(
              option: option,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ],
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.option,
    required this.value,
    required this.onChanged,
  });

  final FeedbackOptionModel option;
  final FeedbackOptionModel? value;
  final ValueChanged<FeedbackOptionModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color accent =
        _parseHexColor(option.colorHex) ?? _fallbackChipColor();
    final bool selected = option.id == value?.id;
    return GestureDetector(
      onTap: () => onChanged(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: AppDimens.sizeX36,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? accent : accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppDimens.radiusX50),
          border: Border.all(
            color: selected ? accent : accent.withValues(alpha: 0.25),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            option.name,
            maxLines: 1,
            style: textTheme.bodyTextSmall?.copyWith(
              color: selected ? LightColor.inverseTextColor : accent,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

Color _fallbackChipColor() => LightColor.secondaryColor;

Color? _parseHexColor(String value) {
  final String normalized = value.trim().replaceFirst('#', '');
  if (normalized.isEmpty) return null;
  final String hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  if (hex.length != 8) return null;
  final int? colorValue = int.tryParse(hex, radix: 16);
  return colorValue == null ? null : Color(colorValue);
}

class _FeedbackStatusRow extends StatelessWidget {
  const _FeedbackStatusRow({
    required this.leading,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final Widget leading;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          leading,
          const SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(width: AppDimens.paddingX10),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _RatingBlock extends StatelessWidget {
  const _RatingBlock({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  static const List<String> _labels = <String>[
    'Terrible',
    'Poor',
    'Okay',
    'Good',
    'Excellent',
  ];

  Color get _labelColor => switch (rating) {
    1 || 2 => LightColor.redColor,
    3 => LightColor.warningColor,
    _ => LightColor.secondaryColor,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: List<Widget>.generate(5, (index) {
            final int value = index + 1;
            final bool selected = value <= rating;
            return Padding(
              padding: EdgeInsets.only(
                right: index == 4 ? 0 : AppDimens.paddingX8,
              ),
              child: GestureDetector(
                onTap: () => onChanged(value),
                child: AnimatedScale(
                  scale: selected ? 1.0 : 0.92,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: AppDimens.sizeX42,
                    height: AppDimens.sizeX42,
                    decoration: BoxDecoration(
                      color: selected
                          ? LightColor.secondaryColor.withValues(alpha: 0.1)
                          : LightColor.background,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX6),
                      border: Border.all(
                        color: selected
                            ? LightColor.secondaryColor.withValues(alpha: 0.5)
                            : LightColor.dividerColor,
                      ),
                    ),
                    child: Icon(
                      selected ? Icons.star_rounded : Icons.star_border_rounded,
                      color: selected
                          ? LightColor.secondaryColor
                          : LightColor.iconGrey,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(sizeFactor: animation, child: child),
          ),
          child: rating == 0
              ? const SizedBox.shrink()
              : Padding(
                  key: ValueKey<int>(rating),
                  padding: const EdgeInsets.only(top: AppDimens.paddingX8),
                  child: Text(
                    _labels[rating - 1],
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: _labelColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _MessageCounter extends StatelessWidget {
  const _MessageCounter({required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    final bool enough = length >= _kMinMessageLength;
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '$length / $_kMaxMessageLength',
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: length == 0
              ? LightColor.hintTextColor
              : enough
              ? LightColor.secondaryColor
              : LightColor.warningColor,
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.shield_outlined,
            color: LightColor.secondaryColor,
            size: AppDimens.sizeX18,
          ),
          const SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: Text(
              StringConstants.feedbackHelpNote,
              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scale-in green check + thank-you message shown after a submit.
class _ThankYouDialog extends StatelessWidget {
  const _ThankYouDialog({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Dialog(
      backgroundColor: LightColor.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.4, end: 1),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: LightColor.secondaryColor,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX16),
            Text(
              'Thank you!',
              style: textTheme.bodyTextLarge?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              StringConstants.feedbackSuccess,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),
            CustomButton(text: 'Done', onPressed: onDone),
          ],
        ),
      ),
    );
  }
}
