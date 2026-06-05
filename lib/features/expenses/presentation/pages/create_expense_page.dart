import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_date_picker.dart';
import 'package:hamro_footsall/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/domain/entities/expense_entities.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_common.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_filter_widgets.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_form_widgets.dart';

class CreateExpensePage extends StatefulWidget {
  const CreateExpensePage({
    super.key,
    required this.venues,
    this.courts = const [],
  });

  final List<VenueModel> venues;
  final List<CourtModel> courts;

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final _amountCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _amountFocus = FocusNode();

  ExpenseCategory? _category;
  late VenueModel _venue = widget.venues.first;
  CourtModel? _court;
  DateTime _date = DateTime.now();
  PaymentMethod _method = PaymentMethod.cash;
  bool _submitted = false;

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
      title: 'Expense date',
      initialDate: _date,
      minDate: DateTime(_date.year - 2),
      maxDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    setState(() => _submitted = true);
    if (!_canSave) return;
    HapticFeedback.mediumImpact();
    final note = _noteCtrl.text.trim();
    Navigator.of(context).pop(
      CreateExpenseEntity(
        date: _date,
        category: _category!,
        vendor: _vendorCtrl.text.trim(),
        amount: _amountInt!,
        venueId: _venue.id,
        method: _method,
        courtId: _court?.id,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: 'New expense',
        actions: [
          // Rebuilds only this button while typing — not the whole form.
          ListenableBuilder(
            listenable: Listenable.merge([_amountCtrl, _vendorCtrl]),
            builder: (context, _) => TextButton(
              onPressed: _canSave ? _save : null,
              child: Text(
                'Save',
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
                  // One-tap presets for common amounts.
                  Wrap(
                    spacing: AppDimens.paddingX8,
                    runSpacing: AppDimens.paddingX8,
                    children: _presets
                        .map(
                          (p) => ExpenseChip(
                            label: ExpenseFmt.group('$p'),
                            selected: _amountInt == p,
                            onTap: () => _setAmount(p),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),

            ExpenseSectionLabel('Category'),
            ExpenseSurface(
              child: CustomDropdownField<ExpenseCategory>(
                labelText: 'Category',
                hintText: 'Select a category',
                icon: Icons.category_outlined,
                initialValue: _category,
                autovalidateMode: _submitted
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                validator: (v) => v == null ? 'Pick a category' : null,
                onChanged: (c) => setState(() => _category = c),
                items: ExpenseCategory.values
                    .map(
                      (c) => DropdownMenuItem<ExpenseCategory>(
                        value: c,
                        child: Text(c.label),
                      ),
                    )
                    .toList(),
              ),
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
                      labelText: 'Purpose',
                      hintText: 'e.g. Turf repair, monthly rent',
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
                      labelText: 'Venue',
                      hintText: 'Select a venue',
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
                        labelText: 'Court',
                        hintText: 'Select a court',
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
                    label: 'Date',
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
                          'Payment method',
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
                labelText: 'Note',
                hintText: 'Add a remark, invoice ref, etc.',
                icon: Icons.notes_rounded,
                maxLines: 3,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                isRequired: false,
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
                    ? 'Save expense · ${ExpenseFmt.npr(_amountInt ?? 0)}'
                    : 'Save expense',
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
