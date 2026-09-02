import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/validation/app_validators.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

/// Rounded, drag-handled shell shared by every bottom sheet in the feature.
class OpponentSheetShell extends StatelessWidget {
  const OpponentSheetShell({
    super.key,
    required this.title,
    required this.child,
  });

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
          decoration: BoxDecoration(
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
                        fontSize: AppDimens.fontBodyTextLarge,
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
      title: StringConstants.chooseVenue,
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

/// Create or rename a team. Pass [initialName] to switch to edit mode.
class CreateTeamSheet extends StatefulWidget {
  const CreateTeamSheet({
    super.key,
    required this.onCreate,
    this.initialName,
    this.title = 'Create Team',
    this.actionLabel = 'Create Team',
    this.actionIcon = Icons.add_rounded,
  });

  final ValueChanged<String> onCreate;
  final String? initialName;
  final String title;
  final String actionLabel;
  final IconData actionIcon;

  @override
  State<CreateTeamSheet> createState() => _CreateTeamSheetState();
}

class _CreateTeamSheetState extends State<CreateTeamSheet> {
  late final _teamCtrl = TextEditingController(text: widget.initialName ?? '');

  @override
  void dispose() {
    _teamCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = _teamCtrl.text.trim();
    final enabled = trimmed.isNotEmpty && trimmed != widget.initialName?.trim();
    return OpponentSheetShell(
      title: widget.title,
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
          CustomButton(
            text: widget.actionLabel,
            icon: widget.actionIcon,
            minHeight: AppDimens.sizeX44,
            backgroundColor: LightColor.buttonColor,
            onPressed: enabled
                ? () {
                    final name = _teamCtrl.text.trim();
                    if (name.isEmpty) return;
                    widget.onCreate(name);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

/// Add a player to the roster, or — when [initialPlayer] is set — edit an
/// existing member's name/position (`teams/{team}/members/{member}/update`).
class AddPlayerSheet extends StatefulWidget {
  const AddPlayerSheet({
    super.key,
    required this.teamName,
    required this.positions,
    required this.onAdd,
    this.initialPlayer,
  });

  final String teamName;

  /// Positions from the `/positions` API (caller falls back to
  /// [PlayerPositionModel.defaults] when the fetch hasn't landed).
  final List<PlayerPositionModel> positions;
  final ValueChanged<PlayerModel> onAdd;

  /// When set, the sheet opens in edit mode prefilled with this member; the
  /// model passed to [onAdd] keeps its member id.
  final PlayerModel? initialPlayer;

  @override
  State<AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<AddPlayerSheet> {
  late final _nameCtrl = TextEditingController(
    text: widget.initialPlayer?.name ?? '',
  );
  late final _emailCtrl = TextEditingController(
    text: widget.initialPlayer?.email ?? '',
  );
  PlayerPositionModel? _position;

  bool get _isEdit => widget.initialPlayer != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPlayer;
    if (initial == null) return;
    // Preselect the member's current position — by API row id first, then by
    // name (covers the static fallback list, which has no ids).
    final String currentName = initial.positionName.trim().isNotEmpty
        ? initial.positionName.trim()
        : initial.position.label;
    for (final p in widget.positions) {
      final bool sameId = p.id.isNotEmpty && p.id == initial.positionId.trim();
      if (sameId || p.name.toLowerCase() == currentName.toLowerCase()) {
        _position = p;
        break;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  /// Email is optional, so a blank field is fine — but anything typed has to be
  /// a valid address before the player can be saved.
  String? get _emailError {
    final String text = _emailCtrl.text.trim();
    if (text.isEmpty) return null;
    return AppValidators.email(text);
  }

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _position != null &&
      _emailError == null;

  @override
  Widget build(BuildContext context) {
    return OpponentSheetShell(
      title: _isEdit ? 'Edit Player' : 'Add Player',
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
          const SizedBox(height: AppDimens.sizeX12),
          _SheetInput(
            controller: _emailCtrl,
            hint: 'Player email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            // Addresses are never capitalised, unlike the name above.
            textCapitalization: TextCapitalization.none,
            errorText: _emailError,
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
            children: widget.positions.map((p) {
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
                    p.name,
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
          CustomButton(
            text: _isEdit ? 'Save Changes' : 'Add Player',
            icon: _isEdit ? Icons.check_rounded : Icons.person_add_outlined,
            minHeight: AppDimens.sizeX44,
            backgroundColor: LightColor.buttonColor,
            onPressed: _canSubmit
                ? () {
                    final name = _nameCtrl.text.trim();
                    final position = _position;
                    if (name.isEmpty || position == null) return;
                    widget.onAdd(
                      PlayerModel(
                        // Editing keeps the member id so the update hits
                        // the right `members/{member}/update` row.
                        id: widget.initialPlayer?.id ?? '',
                        name: name,
                        email: _emailCtrl.text.trim(),
                        // Local display enum; the API row id is what gets stored.
                        position: PlayerPositionX.fromAny(position.name),
                        positionName: position.name,
                        positionId: position.id,
                      ),
                    );
                  }
                : null,
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
    this.keyboardType,
    this.textCapitalization = TextCapitalization.words,
    this.errorText,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  /// Shown under the field when set. Validation is driven by the sheet's state
  /// rather than a Form, so the message is passed in instead of returned by a
  /// validator.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller,
          labelText: hint,
          hintText: hint,
          icon: icon,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: TextInputAction.done,
          isRequired: false,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: errorText == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimens.paddingX4,
                    left: AppDimens.paddingX4,
                  ),
                  child: Text(
                    errorText!,
                    style: FutsalTheme.getTextTheme(context).bodyTextSmall
                        ?.copyWith(
                          color: LightColor.redColor,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                  ),
                ),
        ),
      ],
    );
  }
}
