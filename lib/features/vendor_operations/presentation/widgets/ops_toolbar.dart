import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/date_format.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_futsal/core/widgets/custom_date_picker.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/bloc/vendor_ops_bloc.dart';

class OpsToolbar extends StatelessWidget {
  const OpsToolbar({
    super.key,
    required this.onManualBooking,
    this.operationalHomeEnabled = true,
    this.onHomeModeChanged,
    this.hasUnreadNotifications = false,
    this.onNotifications,
    this.userName,
  });

  final VoidCallback onManualBooking;
  final bool operationalHomeEnabled;
  final ValueChanged<bool>? onHomeModeChanged;
  final bool hasUnreadNotifications;
  final VoidCallback? onNotifications;

  /// The vendor's first name; "there" until the profile has loaded.
  final String? userName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOpsBloc, VendorOpsState>(
      buildWhen: (VendorOpsState a, VendorOpsState b) =>
          a.date != b.date ||
          a.venueIds != b.venueIds ||
          a.courtIds != b.courtIds ||
          a.focus != b.focus ||
          a.courts != b.courts,
      builder: (BuildContext context, VendorOpsState state) {
        final String name = userName?.trim().isNotEmpty == true
            ? userName!.trim()
            : 'there';
        // Styled as the futsal home's greeting.
        final Widget greeting = Text(
          '${AppUtils().greeting()}, $name 👋',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
            fontSize: AppDimens.fontBodyTextLarge,
            fontWeight: FontWeight.w600,
            color: LightColor.primaryTextColor,
          ),
        );
        // The futsal home's header, as is: the round switch, then the
        // bell, at every width.
        final Widget modeSwitch = HomeModeSwitch(
          operational: operationalHomeEnabled,
          onChanged: onHomeModeChanged,
          compact: true,
        );
        final Widget notifications = _NotificationAction(
          hasUnread: hasUnreadNotifications,
          onPressed: onNotifications,
        );
        // final Widget bookButton = _ManualBookingButton(
        // onPressed: onManualBooking,
        // compact: !wide,
        // );

        // Same background as the page below, so the top reads as part
        // of the page rather than a separate bar.
        return Material(
          color: LightColor.background,
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsive<double>(
                mobile: AppDimens.paddingX20,
                tablet: AppDimens.paddingX20,
                desktop: AppDimens.paddingX24,
                large: AppDimens.paddingX32,
              ),
              vertical: context.responsive<double>(
                mobile: AppDimens.paddingX10,
                tablet: AppDimens.paddingX12,
                desktop: AppDimens.paddingX12,
                large: AppDimens.paddingX14,
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: greeting),
                const SizedBox(width: AppDimens.paddingX8),
                modeSwitch,
                const SizedBox(width: AppDimens.paddingX8),
                notifications,
                // const SizedBox(width: AppDimens.paddingX8),
                // bookButton,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationAction extends StatelessWidget {
  const _NotificationAction({required this.hasUnread, this.onPressed});

  final bool hasUnread;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: LightColor.whiteColor,
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: LightColor.secondaryColor,
              ),
            ),
          ),
        ),
        if (hasUnread)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: LightColor.redColor,
                shape: BoxShape.circle,
                border: Border.all(color: LightColor.whiteColor, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// `‹ date ›  [Today]` — steps the dashboard's date a day at a time, opens
/// the date picker on the date itself, and jumps back to today. The top bar
/// and the Day board share it.
class OpsDateControls extends StatelessWidget {
  const OpsDateControls({
    super.key,
    required this.state,
    this.showDayLabel = true,
    this.alignStart = false,
  });

  final VendorOpsState state;

  /// The small `TODAY` / weekday line above the date.
  final bool showDayLabel;

  /// Pulls the whole row left so the `‹` glyph sits 4 px inside the
  /// leading edge, instead of inset by the button's padding and the glyph's
  /// own margin. Everything keeps its spacing; the tap targets their size.
  final bool alignStart;

  /// The `‹` glyph starts 16 px into the row: 8 px of compact button around
  /// its icon, then 8 px of the chevron's own margin. Taking back 12 leaves
  /// it 4 px in.
  static const double _alignStartShift = -12;

  Future<void> _pick(BuildContext context) async {
    final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
    final DateTime today = KathmanduClock.today();
    final DateTime? picked = await showCustomDatePicker(
      context,
      title: 'Select date',
      initialDate: state.date,
      minDate: DateTime(today.year - 1, today.month, today.day),
      maxDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (picked != null) bloc.add(VendorOpsDateChanged(picked));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
    final DateTime date = state.date;
    final bool isToday = state.isToday;
    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          tooltip: 'Previous day',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => bloc.add(
            VendorOpsDateChanged(date.subtract(const Duration(days: 1))),
          ),
        ),
        Flexible(
          child: Semantics(
            button: true,
            label: 'Selected date ${DateFmt.date(date)}. Change date',
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _pick(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (showDayLabel)
                            Text(
                              isToday ? 'Today' : _weekday(date),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMiniSubTitle?.copyWith(
                                color: isToday
                                    ? LightColor.brandTextColor
                                    : LightColor.secondaryTextColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 8,
                                letterSpacing: 0.3,
                              ),
                            ),
                          Text(
                            DateFmt.date(date),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyTextSmall?.copyWith(
                              color: LightColor.primaryTextColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next day',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () =>
              bloc.add(VendorOpsDateChanged(date.add(const Duration(days: 1)))),
        ),
        const SizedBox(width: 4),
        // Keeps the venue and court filters — only the date moves.
        _TodayButton(
          active: isToday,
          onPressed: () =>
              bloc.add(VendorOpsDateChanged(KathmanduClock.today())),
        ),
      ],
    );
    return alignStart
        ? Transform.translate(
            offset: const Offset(_alignStartShift, 0),
            child: row,
          )
        : row;
  }

  static String _weekday(DateTime d) => const <String>[
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ][d.weekday - 1];
}

class _TodayButton extends StatelessWidget {
  const _TodayButton({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: active ? 'Showing today' : 'Go to today',
      child: ExcludeSemantics(
        // Text only — slim enough for the smallest phones.
        child: OutlinedButton(
          onPressed: active ? null : onPressed,
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.padded,
            foregroundColor: LightColor.brandTextColor,
            disabledForegroundColor: LightColor.brandTextColor.withValues(
              alpha: 0.55,
            ),
            side: BorderSide(
              color: LightColor.secondaryColor.withValues(
                alpha: active ? 0.25 : 0.7,
              ),
            ),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            minimumSize: const Size(0, 28),
          ),
          child: const Text(
            'Today',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

/// Toggles a vendor between the operations home and the normal home. The
/// normal home's app bar shows the compact form too.
class HomeModeSwitch extends StatelessWidget {
  const HomeModeSwitch({
    super.key,
    required this.operational,
    required this.compact,
    this.onChanged,
  });

  final bool operational;
  final bool compact;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    final Color selectedFg = LightColor.onBrandSurface;
    final Color idleFg = enabled
        ? LightColor.secondaryTextColor
        : LightColor.hintTextColor;
    if (compact) {
      return Tooltip(
        message: operational ? 'Show normal home' : 'Show operations home',
        child: OutlinedButton(
          onPressed: enabled ? () => onChanged!(!operational) : null,
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.padded,
            foregroundColor: operational
                ? LightColor.secondaryColor
                : LightColor.secondaryTextColor,
            side: BorderSide(color: LightColor.dividerColor),
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            fixedSize: const Size(44, 44),
          ),
          // Where a tap goes, not where you are: Home from the operations
          // home, the operations dashboard from the normal home.
          child: Icon(
            operational
                ? Icons.home_rounded
                : Icons.dashboard_customize_rounded,
            size: 18,
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      selected: operational,
      label: operational ? 'Operations home selected' : 'Normal home selected',
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: LightColor.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ModeOption(
              icon: Icons.dashboard_customize_rounded,
              label: compact ? null : 'Ops',
              selected: operational,
              foreground: operational ? selectedFg : idleFg,
              onTap: enabled && !operational ? () => onChanged!(true) : null,
            ),
            _ModeOption(
              icon: Icons.home_rounded,
              label: compact ? null : 'Home',
              selected: !operational,
              foreground: !operational ? selectedFg : idleFg,
              onTap: enabled && operational ? () => onChanged!(false) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.icon,
    required this.selected,
    required this.foreground,
    this.label,
    this.onTap,
  });

  final IconData icon;
  final String? label;
  final bool selected;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? LightColor.secondaryColor : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: label == null ? 9 : 11),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 17, color: foreground),
              if (label != null) ...<Widget>[
                const SizedBox(width: 5),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _Filters extends StatelessWidget {
  const _Filters({required this.state, required this.search});

  final VendorOpsState state;
  final TextEditingController search;

  @override
  Widget build(BuildContext context) {
    final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
    final List<(int, String)> venues = state.venues;
    final List<OpsCourt> courts = state.filterableCourts;

    String venueLabel() {
      if (state.venueIds.isEmpty) return 'All venues';
      if (state.venueIds.length == 1) {
        return venues
                .where(((int, String) v) => v.$1 == state.venueIds.first)
                .firstOrNull
                ?.$2 ??
            '1 venue';
      }
      return '${state.venueIds.length} venues';
    }

    String courtLabel() {
      if (state.courtIds.isEmpty) return 'All courts';
      if (state.courtIds.length == 1) {
        final OpsCourt? c = courts
            .where((OpsCourt c) => c.id == state.courtIds.first)
            .firstOrNull;
        return c?.name ?? '1 court';
      }
      return '${state.courtIds.length} courts';
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _FilterButton(
          icon: Icons.stadium_rounded,
          label: venueLabel(),
          active: state.venueIds.isNotEmpty,
          onTap: () async {
            final Set<int>? picked = await showOpsMultiSelect<int>(
              context,
              title: 'Venues',
              options: <OpsOption<int>>[
                for (final (int id, String name) in venues)
                  OpsOption<int>(id, name),
              ],
              selected: state.venueIds,
            );
            if (picked == null) return;
            bloc.add(VendorOpsVenuesFiltered(picked));
            // Courts outside the new venues no longer apply.
            final Set<int> keep = state.courtIds
                .where(
                  (int id) => state.courts.any(
                    (OpsCourt c) =>
                        c.id == id &&
                        (picked.isEmpty || picked.contains(c.venueId)),
                  ),
                )
                .toSet();
            if (keep.length != state.courtIds.length) {
              bloc.add(VendorOpsCourtsFiltered(keep));
            }
          },
        ),
        _FilterButton(
          icon: Icons.grid_view_rounded,
          label: courtLabel(),
          active: state.courtIds.isNotEmpty,
          onTap: () async {
            final Set<int>? picked = await showOpsMultiSelect<int>(
              context,
              title: 'Courts',
              options: <OpsOption<int>>[
                for (final OpsCourt c in courts)
                  OpsOption<int>(c.id, c.name, subtitle: c.venueName),
              ],
              selected: state.courtIds,
            );
            if (picked != null) bloc.add(VendorOpsCourtsFiltered(picked));
          },
        ),
        PopupMenuButton<OpsFocus>(
          tooltip: 'Booking status',
          initialValue: state.focus,
          onSelected: (OpsFocus f) => bloc.add(VendorOpsFocusChanged(f)),
          itemBuilder: (_) => <PopupMenuEntry<OpsFocus>>[
            for (final OpsFocus f in OpsFocus.values)
              CheckedPopupMenuItem<OpsFocus>(
                value: f,
                checked: f == state.focus,
                child: Text(f.label),
              ),
          ],
          child: IgnorePointer(
            child: _FilterButton(
              icon: Icons.tune_rounded,
              label: state.focus == OpsFocus.all
                  ? 'Any status'
                  : state.focus.label,
              active: state.focus != OpsFocus.all,
              onTap: () {},
            ),
          ),
        ),
        // Rebuilds with the text so the clear button tracks it.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: search,
          builder: (BuildContext context, TextEditingValue value, _) =>
              SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: search,
                  onChanged: (String q) => bloc.add(VendorOpsSearchChanged(q)),
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Name, phone or reference',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    suffixIcon: search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded, size: 16),
                            onPressed: () {
                              search.clear();
                              bloc.add(const VendorOpsSearchChanged(''));
                            },
                          ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    filled: true,
                    fillColor: LightColor.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: LightColor.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: LightColor.dividerColor),
                    ),
                  ),
                ),
              ),
        ),
        if (state.hasActiveFilters)
          TextButton.icon(
            onPressed: () {
              search.clear();
              bloc
                ..add(const VendorOpsVenuesFiltered(<int>{}))
                ..add(const VendorOpsCourtsFiltered(<int>{}))
                ..add(const VendorOpsFocusChanged(OpsFocus.all))
                ..add(const VendorOpsSearchChanged(''));
            },
            icon: const Icon(Icons.restart_alt_rounded, size: 16),
            label: const Text('Reset filters'),
          ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = active
        ? LightColor.brandTextColor
        : LightColor.primaryTextColor;
    return Material(
      color: active
          ? LightColor.secondaryColor.withValues(alpha: 0.10)
          : LightColor.background,
      shape: StadiumBorder(
        side: BorderSide(
          color: active
              ? LightColor.secondaryColor.withValues(alpha: 0.5)
              : LightColor.dividerColor,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40, maxWidth: 220),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.expand_more_rounded, size: 18, color: fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OpsOption<T> {
  const OpsOption(this.value, this.label, {this.subtitle});

  final T value;
  final String label;
  final String? subtitle;
}

/// A searchable multi-select sheet. An empty result means "all". Returns
/// null when dismissed.
Future<Set<T>?> showOpsMultiSelect<T>(
  BuildContext context, {
  required String title,
  required List<OpsOption<T>> options,
  required Set<T> selected,
}) {
  return showAppBottomSheet<Set<T>>(
    context: context,
    builder: (_) =>
        _MultiSelectSheet<T>(title: title, options: options, initial: selected),
  );
}

class _MultiSelectSheet<T> extends StatefulWidget {
  const _MultiSelectSheet({
    required this.title,
    required this.options,
    required this.initial,
  });

  final String title;
  final List<OpsOption<T>> options;
  final Set<T> initial;

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  late final Set<T> _selected = Set<T>.of(widget.initial);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final String q = _query.trim().toLowerCase();
    final List<OpsOption<T>> shown = widget.options
        .where(
          (OpsOption<T> o) =>
              q.isEmpty ||
              o.label.toLowerCase().contains(q) ||
              (o.subtitle?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            widget.title,
            style: textTheme.bodyTextLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(height: 10),
          if (widget.options.length > 6)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                autofocus: false,
                onChanged: (String v) => setState(() => _query = v),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search ${widget.title.toLowerCase()}',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          CheckboxListTile(
            value: _selected.isEmpty,
            onChanged: (_) => setState(_selected.clear),
            title: Text(
              'All ${widget.title.toLowerCase()}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: LightColor.secondaryColor,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 1),
          Flexible(
            child: shown.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No matches',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: LightColor.secondaryTextColor),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      for (final OpsOption<T> o in shown)
                        CheckboxListTile(
                          value: _selected.contains(o.value),
                          onChanged: (bool? v) => setState(() {
                            if (v ?? false) {
                              _selected.add(o.value);
                            } else {
                              _selected.remove(o.value);
                            }
                          }),
                          title: Text(o.label),
                          subtitle: o.subtitle == null
                              ? null
                              : Text(o.subtitle!),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: LightColor.secondaryColor,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(Set<T>.of(_selected)),
            style: FilledButton.styleFrom(
              backgroundColor: LightColor.secondaryColor,
              foregroundColor: LightColor.onBrandSurface,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _selected.isEmpty ? 'Show all' : 'Apply (${_selected.length})',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
