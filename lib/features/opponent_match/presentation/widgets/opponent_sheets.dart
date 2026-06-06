import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';

/// Rounded, drag-handled shell shared by every bottom sheet in the feature.
class OpponentSheetShell extends StatelessWidget {
  const OpponentSheetShell({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * .86;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusX24),
            ),
          ),
          padding: AppUtils().getPadding(
            left: AppDimens.paddingX20,
            top: AppDimens.paddingX14,
            right: AppDimens.paddingX20,
            bottom: AppDimens.paddingX36,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: AppDimens.sizeX36,
                    height: AppDimens.sizeX3,
                    margin: AppUtils().getMargin(bottom: AppDimens.paddingX20),
                    decoration: BoxDecoration(
                      color: LightColor.dividerColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: FutsalTheme.getTextTheme(context).bodyTextLarge
                      ?.copyWith(
                        fontSize: AppDimens.fontHeadingSmall,
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                ),
                const SizedBox(height: AppDimens.sizeX16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VenuePickerSheet extends StatelessWidget {
  const VenuePickerSheet({
    super.key,
    required this.venues,
    required this.selected,
    required this.onSelect,
  });

  final List<String> venues;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return OpponentSheetShell(
      title: 'Choose venue',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: venues.map((v) {
          final active = v == selected;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.paddingX8),
            child: Material(
              color: active
                  ? LightColor.secondaryColor.withValues(alpha: 0.08)
                  : LightColor.background,
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                onTap: () => onSelect(v),
                child: Container(
                  padding: AppUtils().getPadding(
                    symmetricHorizontal: AppDimens.paddingX14,
                    symmetricVertical: AppDimens.paddingX14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                    border: Border.all(
                      color: active
                          ? LightColor.secondaryColor.withValues(alpha: 0.35)
                          : LightColor.dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: active
                            ? LightColor.secondaryColor
                            : LightColor.secondaryTextColor,
                      ),
                      const SizedBox(width: AppDimens.paddingX12),
                      Expanded(
                        child: Text(
                          v,
                          style: textTheme.bodyTextMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                      ),
                      if (active)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: LightColor.secondaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ConfirmDeleteSheet extends StatelessWidget {
  const ConfirmDeleteSheet({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return OpponentSheetShell(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX20),
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  label: 'Cancel',
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: _DangerButton(label: 'Remove', onTap: onConfirm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreateTeamSheet extends StatefulWidget {
  const CreateTeamSheet({super.key, required this.onCreate});

  final ValueChanged<String> onCreate;

  @override
  State<CreateTeamSheet> createState() => _CreateTeamSheetState();
}

class _CreateTeamSheetState extends State<CreateTeamSheet> {
  final _teamCtrl = TextEditingController();

  @override
  void dispose() {
    _teamCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OpponentSheetShell(
      title: 'Create Team',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetInput(
            controller: _teamCtrl,
            hint: 'Team name',
            icon: Icons.groups_2_outlined,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimens.sizeX20),
          _PrimaryButton(
            label: 'Create Team',
            icon: Icons.add_rounded,
            enabled: _teamCtrl.text.trim().isNotEmpty,
            onTap: () {
              final name = _teamCtrl.text.trim();
              if (name.isEmpty) return;
              widget.onCreate(name);
            },
          ),
        ],
      ),
    );
  }
}

class AddPlayerSheet extends StatefulWidget {
  const AddPlayerSheet({super.key, required this.teamName, required this.onAdd});

  final String teamName;
  final ValueChanged<PlayerModel> onAdd;

  @override
  State<AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<AddPlayerSheet> {
  final _nameCtrl = TextEditingController();
  PlayerPosition? _position;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OpponentSheetShell(
      title: 'Add Player',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetInput(
            controller: _nameCtrl,
            hint: 'Player name',
            icon: Icons.person_outline_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimens.sizeX14),
          Text(
            'Position in ${widget.teamName}',
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimens.sizeX8,
            crossAxisSpacing: AppDimens.sizeX8,
            childAspectRatio: 3.2,
            children: PlayerPosition.values.map((p) {
              final active = _position == p;
              final textTheme = FutsalTheme.getTextTheme(context);
              return GestureDetector(
                onTap: () => setState(() => _position = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? LightColor.secondaryColor
                        : LightColor.background,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    border: Border.all(
                      color: active
                          ? LightColor.secondaryColor
                          : LightColor.dividerColor,
                    ),
                  ),
                  child: Text(
                    p.label,
                    style: textTheme.bodyTextSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: active
                          ? LightColor.inverseTextColor
                          : LightColor.secondaryTextColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.sizeX20),
          _PrimaryButton(
            label: 'Add Player',
            icon: Icons.person_add_outlined,
            enabled: _nameCtrl.text.trim().isNotEmpty && _position != null,
            onTap: () {
              final name = _nameCtrl.text.trim();
              final position = _position;
              if (name.isEmpty || position == null) return;
              widget.onAdd(PlayerModel(name: name, position: position));
            },
          ),
        ],
      ),
    );
  }
}

class _SheetInput extends StatelessWidget {
  const _SheetInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: hint,
      hintText: hint,
      icon: icon,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      isRequired: false,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1.0 : .45,
      child: Material(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusX14),
          onTap: enabled ? onTap : null,
          child: Container(
            height: AppDimens.sizeX54,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: LightColor.whiteColor,
                  size: AppDimens.sizeX18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: LightColor.background,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        onTap: onTap,
        child: Container(
          height: AppDimens.sizeX46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(color: LightColor.dividerColor),
          ),
          child: Text(
            label,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: LightColor.redColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        onTap: onTap,
        child: Container(
          height: AppDimens.sizeX46,
          alignment: Alignment.center,
          child: Text(
            label,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.whiteColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
