import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_date_picker.dart';
import 'package:hamro_footsall/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/domain/entities/expense_entities.dart';
import 'package:hamro_footsall/features/expenses/presentation/bloc/expenses_bloc/expenses_bloc.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_common.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_filter_widgets.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_form_widgets.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Create a new expense, or edit an existing one when [initial] is provided.
class CreateExpensePage extends StatefulWidget {
  const CreateExpensePage({
    super.key,
    required this.venues,
    this.courts = const [],
    this.initial,
  });

  final List<VenueModel> venues;
  final List<CourtModel> courts;

  /// Expense being edited; null when creating.
  final ExpenseModel? initial;

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  late final _amountCtrl = TextEditingController(
    text: widget.initial == null
        ? ''
        : ExpenseFmt.group('${widget.initial!.amount}'),
  );
  late final _vendorCtrl = TextEditingController(
    text: widget.initial?.vendor ?? '',
  );
  late final _noteCtrl = TextEditingController(
    text: widget.initial?.note ?? '',
  );
  final _amountFocus = FocusNode();

  ExpenseCategoryModel? _category;
  late VenueModel _venue = widget.initial == null
      ? widget.venues.first
      : widget.venues.firstWhere(
          (v) => v.id == widget.initial!.venueId,
          orElse: () => widget.venues.first,
        );
  late CourtModel? _court = widget.initial?.courtId == null
      ? null
      : widget.courts.where((c) => c.id == widget.initial!.courtId).firstOrNull;
  late DateTime _date = widget.initial?.date ?? DateTime.now();
  late PaymentMethod _method = widget.initial?.method ?? PaymentMethod.cash;
  PlatformFile? _document;
  bool _submitted = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    // Pre-select the API category matching the edited record — by server id
    // first, then by the enum mapping as a fallback.
    final initial = widget.initial;
    if (initial != null) {
      final categories = context.read<ExpensesBloc>().state.categories;
      _category =
          categories.where((c) => c.id == initial.categoryId).firstOrNull ??
          categories.where((c) => c.asEnum == initial.category).firstOrNull;
    }
  }

  /// Mirrors the backend rule: jpg,jpeg,png,webp,pdf,doc,docx · max 10 MB.
  static const _documentExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'pdf',
    'doc',
    'docx',
  ];
  static const _maxDocumentBytes = 10 * 1024 * 1024;

  static const _presets = [500, 1000, 2500, 5000, 10000];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _vendorCtrl.dispose();
    _noteCtrl.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  int? get _amountInt {
    final raw = _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  bool get _canSave =>
      (_amountInt ?? 0) > 0 &&
      _category != null &&
      _vendorCtrl.text.trim().isNotEmpty;

  /// Courts that belong to the currently selected venue.
  List<CourtModel> get _venueCourts =>
      widget.courts.where((c) => c.venueId == _venue.id).toList();

  void _setAmount(int value) {
    final text = ExpenseFmt.group('$value');
    _amountCtrl.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showCustomDatePicker(
      context,
      title: StringConstants.expenseDate,
      initialDate: _date,
      minDate: DateTime(_date.year - 2),
      maxDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  /// Documents come from the device file browser only (no gallery), matching
  /// the backend rule: image/pdf/doc, max 10 MB.
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _documentExtensions,
    );
    final file = result?.files.singleOrNull;
    if (file == null || !mounted) return;
    if (file.path == null) return;
    if (file.size > _maxDocumentBytes) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(StringConstants.documentMustBeSmallerThan10Mb),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    setState(() => _document = file);
  }

  void _save() {
    setState(() => _submitted = true);
    if (!_canSave) return;
    HapticFeedback.mediumImpact();
    final note = _noteCtrl.text.trim();
    Navigator.of(context).pop(
      CreateExpenseEntity(
        date: _date,
        category: _category!.asEnum,
        categoryDetail: _category,
        vendor: _vendorCtrl.text.trim(),
        amount: _amountInt!,
        venueId: _venue.id,
        method: _method,
        courtId: _court?.id,
        note: note.isEmpty ? null : note,
        documentPath: _document?.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: _isEdit ? 'Edit expense' : 'New expense',
        actions: [
          ListenableBuilder(
            listenable: Listenable.merge([_amountCtrl, _vendorCtrl]),
            builder: (context, _) => TextButton(
              onPressed: _canSave ? _save : null,
              child: Text(
                StringConstants.save,
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _canSave
                      ? LightColor.secondaryColor
                      : LightColor.disabledTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX20,
            top: AppDimens.paddingX4,
            bottom: AppDimens.paddingX28,
          ),
          children: [
            ExpenseSectionLabel('Amount'),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _amountCtrl,
              builder: (context, _, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpenseAmountCard(
                    controller: _amountCtrl,
                    focusNode: _amountFocus,
                    showError: _submitted && (_amountInt ?? 0) <= 0,
                  ),
                  const SizedBox(height: AppDimens.paddingX10),
                  // One-tap presets for common amounts — equal-width chips
                  // so all five always fit on a single row.
                  Row(
                    children: [
                      for (final p in _presets) ...[
                        if (p != _presets.first)
                          const SizedBox(width: AppDimens.paddingX8),
                        Expanded(
                          child: ExpenseChip(
                            label: ExpenseFmt.group('$p'),
                            selected: _amountInt == p,
                            onTap: () => _setAmount(p),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            ExpenseSectionLabel('Category'),
            // Categories are fetched from the expense-categories API; the
            // dropdown follows the bloc so it stays in sync with the fetch.
            BlocBuilder<ExpensesBloc, ExpensesState>(
              buildWhen: (prev, curr) =>
                  prev.categoriesStatus != curr.categoriesStatus ||
                  prev.categories != curr.categories,
              builder: (context, state) {
                if (state.categoriesStatus == ExpensesStatus.initial ||
                    state.categoriesStatus == ExpensesStatus.loading) {
                  return const ExpenseSurface(
                    child: _CategoryStatusRow(
                      leading: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: LightColor.secondaryColor,
                        ),
                      ),
                      message: StringConstants.loadingCategories,
                    ),
                  );
                }
                // Only an actual API failure shows the retry row — a
                // successful-but-empty response still renders the dropdown
                // (with no items), mirroring the server state.
                if (state.categoriesStatus == ExpensesStatus.failure) {
                  return ExpenseSurface(
                    child: _CategoryStatusRow(
                      leading: const Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: LightColor.redColor,
                      ),
                      message: StringConstants.couldNotLoadCategories,
                      onRetry: () => context.read<ExpensesBloc>().add(
                        const LoadExpenseCategoriesEvent(),
                      ),
                    ),
                  );
                }
                return ExpenseSurface(
                  child: CustomDropdownField<ExpenseCategoryModel>(
                    labelText: StringConstants.category,
                    hintText: StringConstants.selectACategory,
                    icon: Icons.category_outlined,
                    initialValue: _category,
                    autovalidateMode: _submitted
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    validator: (v) => v == null ? 'Pick a category' : null,
                    onChanged: (c) => setState(() => _category = c),
                    items: state.categories
                        .map(
                          (c) => DropdownMenuItem<ExpenseCategoryModel>(
                            value: c,
                            child: _CategoryOption(category: c),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimens.paddingX18),

            ExpenseSectionLabel('Details'),
            ExpenseSurface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingX14,
                      AppDimens.paddingX14,
                      AppDimens.paddingX14,
                      AppDimens.paddingX18,
                    ),
                    child: CustomTextField(
                      controller: _vendorCtrl,
                      labelText: StringConstants.purpose,
                      hintText: StringConstants.eGTurfRepairMonthlyRent,
                      icon: Icons.assignment_outlined,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      isRequired: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingX14,
                      0,
                      AppDimens.paddingX14,
                      AppDimens.paddingX18,
                    ),
                    child: CustomDropdownField<VenueModel>(
                      labelText: StringConstants.venue,
                      hintText: StringConstants.selectAVenue,
                      icon: Icons.stadium_outlined,
                      initialValue: _venue,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _venue = v;
                            // Court belongs to a venue — reset on change.
                            _court = null;
                          });
                        }
                      },
                      items: widget.venues
                          .map(
                            (v) => DropdownMenuItem<VenueModel>(
                              value: v,
                              child: Text(v.name),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (_venueCourts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.paddingX14,
                        0,
                        AppDimens.paddingX14,
                        AppDimens.paddingX10,
                      ),
                      child: CustomDropdownField<CourtModel>(
                        // Rebuild when the venue changes so the stale court
                        // selection doesn't linger in the field.
                        key: ValueKey(_venue.id),
                        labelText: StringConstants.court,
                        hintText: StringConstants.selectACourt,
                        icon: Icons.sports_soccer_outlined,
                        initialValue: _court,
                        isRequired: false,
                        onChanged: (c) => setState(() => _court = c),
                        items: _venueCourts
                            .map(
                              (c) => DropdownMenuItem<CourtModel>(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  const ExpenseFormDivider(),
                  ExpensePickerRow(
                    icon: Icons.calendar_today_outlined,
                    label: StringConstants.date,
                    value: _formatDate(_date),
                    onTap: _pickDate,
                  ),
                  const ExpenseFormDivider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingX14,
                      AppDimens.paddingX12,
                      AppDimens.paddingX14,
                      AppDimens.paddingX14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringConstants.paymentMethod,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.hintTextColor,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: AppDimens.paddingX10),
                        _PaymentMethodSelector(
                          selected: _method,
                          onChanged: (m) => setState(() => _method = m),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            ExpenseSectionLabel('Note'),
            ExpenseSurface(
              child: CustomTextField(
                controller: _noteCtrl,
                labelText: StringConstants.note,
                hintText: StringConstants.addARemarkInvoiceRefEtc,
                icon: Icons.notes_rounded,
                maxLines: 3,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                isRequired: false,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            ExpenseSectionLabel('Document'),
            ExpenseSurface(
              child: _DocumentField(
                document: _document,
                onPick: _pickDocument,
                onRemove: () => setState(() => _document = null),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(height: 150, child: _buildBottomBar()),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radiusX20),
          topRight: Radius.circular(AppDimens.radiusX20),
        ),
        border: Border.all(
          color: LightColor.dividerColor.withValues(alpha: 0.7),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: AppDimens.radiusX28,
            offset: const Offset(0, AppDimens.sizeX10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ListenableBuilder(
            listenable: Listenable.merge([_amountCtrl, _vendorCtrl]),
            builder: (context, _) => SizedBox(
              height: AppDimens.sizeX54,
              width: double.infinity,
              child: CustomButton(
                text: _canSave
                    ? '${_isEdit ? 'Update' : 'Save'} expense · ${ExpenseFmt.npr(_amountInt ?? 0)}'
                    : '${_isEdit ? 'Update' : 'Save'} expense',
                icon: Icons.save_outlined,
                onPressed: _canSave ? _save : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today, ${months[d.month - 1]} ${d.day}';
    }
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

/// Dropdown row for one API category: server icon (svg/raster) + title,
/// falling back to the local enum icon when the server sent no image.
class _CategoryOption extends StatelessWidget {
  const _CategoryOption({required this.category});

  final ExpenseCategoryModel category;

  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final Widget icon;
    if (!category.hasImage) {
      final fallback = category.asEnum;
      icon = Icon(fallback.icon, size: _iconSize - 2, color: fallback.color);
    } else if (category.isSvgImage) {
      icon = CustomImageView(
        svgPath: category.image,
        svgFromOnline: true,
        height: _iconSize,
        width: _iconSize,
      );
    } else {
      icon = CustomImageView(
        url: category.image,
        height: _iconSize,
        width: _iconSize,
        fit: BoxFit.contain,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: _iconSize, height: _iconSize, child: icon),
        const SizedBox(width: AppDimens.paddingX10),
        Flexible(child: Text(category.name, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

/// Optional supporting document for the expense (receipt, invoice…).
///
/// Picks strictly from the device file browser — never the gallery — and
/// only the types the backend accepts (image / PDF / Word, max 10 MB).
class _DocumentField extends StatelessWidget {
  const _DocumentField({
    required this.document,
    required this.onPick,
    required this.onRemove,
  });

  final PlatformFile? document;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  IconData get _icon {
    final ext = (document?.extension ?? '').toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf_outlined;
    if (ext == 'doc' || ext == 'docx') return Icons.description_outlined;
    return Icons.image_outlined;
  }

  String get _size {
    final bytes = document?.size ?? 0;
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).ceil()} KB';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final file = document;

    if (file == null) {
      return InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.upload_file_rounded,
                  size: 20,
                  color: LightColor.secondaryColor,
                ),
                const SizedBox(width: AppDimens.paddingX10),
                Expanded(
                  child: Text(
                    StringConstants.uploadDocument,
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: LightColor.hintTextColor,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              StringConstants.documentUploadRequirements,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
                fontSize: AppDimens.fontBodySubTitle,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          ),
          child: Icon(_icon, size: 20, color: LightColor.secondaryColor),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LightColor.primaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _size,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.hintTextColor,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: StringConstants.removeDocument,
          onPressed: onRemove,
          icon: const Icon(
            Icons.close_rounded,
            color: LightColor.iconGrey,
            size: 18,
          ),
        ),
      ],
    );
  }
}

/// Inline status row shown in place of the category dropdown while the
/// categories API is loading or after it failed (with a retry action).
class _CategoryStatusRow extends StatelessWidget {
  const _CategoryStatusRow({
    required this.leading,
    required this.message,
    this.onRetry,
  });

  final Widget leading;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        leading,
        const SizedBox(width: AppDimens.paddingX10),
        Expanded(
          child: Text(
            message,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: Text(
              StringConstants.retry,
              style: textTheme.bodyTextSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: LightColor.secondaryColor,
              ),
            ),
          ),
      ],
    );
  }
}

/// Two-option segmented selector for the payment method (Cash / Online).
class _PaymentMethodSelector extends StatelessWidget {
  const _PaymentMethodSelector({
    required this.selected,
    required this.onChanged,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  IconData _iconFor(PaymentMethod m) => switch (m) {
    PaymentMethod.cash => Icons.payments_outlined,
    PaymentMethod.online => Icons.account_balance_wallet_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: PaymentMethod.values.map((m) {
        final isSelected = m == selected;
        final isFirst = m == PaymentMethod.values.first;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: isFirst ? 0 : AppDimens.paddingX10),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(m);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.paddingX12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? LightColor.secondaryColor.withValues(alpha: 0.08)
                        : LightColor.cardColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    border: Border.all(
                      color: isSelected
                          ? LightColor.secondaryColor
                          : LightColor.dividerColor,
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _iconFor(m),
                        size: 18,
                        color: isSelected
                            ? LightColor.secondaryColor
                            : LightColor.secondaryTextColor,
                      ),
                      const SizedBox(width: AppDimens.paddingX8),
                      Text(
                        m.label,
                        style: textTheme.bodyTextMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? LightColor.secondaryColor
                              : LightColor.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
