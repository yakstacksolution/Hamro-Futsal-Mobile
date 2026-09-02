import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/presentation/widgets/group_member_widgets.dart';

/// Full-page create-group flow.
///
/// Pushed as its own route rather than shown in a sheet: the form is long —
/// a name, a searchable member list, selected-member chips and an optional
/// venue — and a sheet fought the keyboard for what little height was left.
/// Pops a [GroupConversationDraft] on submit, or null when abandoned.
class CreateGroupConversationPage extends StatefulWidget {
  const CreateGroupConversationPage({
    super.key,
    required this.participants,
    required this.currentUserId,
  });

  /// Everyone the user already shares a conversation with — the pool a group
  /// can be built from. Deduplicated and sorted by [open].
  final Iterable<ParticipantModel> participants;
  final int currentUserId;

  /// Pushes the page and returns the draft the user submitted, if any.
  static Future<GroupConversationDraft?> open(
    BuildContext context, {
    required Iterable<ParticipantModel> participants,
    required int currentUserId,
  }) {
    final byUserId = <int, ParticipantModel>{};
    for (final participant in participants) {
      if (participant.userId > 0 && participant.userId != currentUserId) {
        byUserId[participant.userId] = participant;
      }
    }
    final candidates = byUserId.values.toList(growable: false)
      // Online first, then by name: the people who can answer now are the
      // ones a pickup game is usually built from.
      ..sort((a, b) {
        if (a.isOnline != b.isOnline) return a.isOnline ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Navigator.of(context).push<GroupConversationDraft>(
      MaterialPageRoute<GroupConversationDraft>(
        builder: (_) => CreateGroupConversationPage(
          participants: candidates,
          currentUserId: currentUserId,
        ),
      ),
    );
  }

  @override
  State<CreateGroupConversationPage> createState() =>
      _CreateGroupConversationPageState();
}

class _CreateGroupConversationPageState
    extends State<CreateGroupConversationPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _search = TextEditingController();
  final TextEditingController _venueId = TextEditingController();
  final FocusNode _titleFocus = FocusNode();

  /// Insertion-ordered so the chip strip reads in the order people were
  /// picked, which is the order the user remembers choosing them in.
  final Set<int> _selected = <int>{};

  String? _error;
  bool _venueExpanded = false;

  List<ParticipantModel> get _candidates =>
      widget.participants is List<ParticipantModel>
      ? widget.participants as List<ParticipantModel>
      : widget.participants.toList(growable: false);

  int get _selectedCount => _selected.length;

  bool get _isFull => _selectedCount >= kMaxGroupMembers;

  List<ParticipantModel> get _visibleCandidates {
    final query = _search.text.trim().toLowerCase();

    if (query.isEmpty) return _candidates;

    return _candidates
        .where((participant) {
          return participant.name.toLowerCase().contains(query) ||
              participant.email.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  /// Chips follow the pick order, not the list order.
  List<ParticipantModel> get _selectedMembers {
    final byUserId = <int, ParticipantModel>{
      for (final participant in _candidates) participant.userId: participant,
    };
    return <ParticipantModel>[
      for (final id in _selected)
        if (byUserId[id] case final participant?) participant,
    ];
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _title.dispose();
    _search.dispose();
    _venueId.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();

    if (title.isEmpty) {
      setState(() => _error = 'Enter a group name.');
      _titleFocus.requestFocus();
      return;
    }

    if (title.length > 255) {
      setState(() => _error = 'Group name must be 255 characters or fewer.');
      _titleFocus.requestFocus();
      return;
    }

    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one member.');
      return;
    }

    if (_selected.length > kMaxGroupMembers) {
      setState(() {
        _error = 'A group can contain at most $kMaxGroupMembers members.';
      });
      return;
    }

    // A venue id that is not a number used to be dropped without a word, so
    // the group was created unlinked and the user never knew.
    final String rawVenue = _venueId.text.trim();
    final int? venueId = rawVenue.isEmpty ? null : int.tryParse(rawVenue);

    if (rawVenue.isNotEmpty && venueId == null) {
      setState(() {
        _venueExpanded = true;
        _error = 'Venue id must be a number.';
      });
      return;
    }

    Navigator.of(context).pop(
      GroupConversationDraft(
        title: title,
        participantIds: _selected.toList(growable: false),
        venueId: venueId,
      ),
    );
  }

  void _toggleParticipant(ParticipantModel participant) {
    final bool isSelected = _selected.contains(participant.userId);

    // Adding past the cap is refused where the tap happened, rather than only
    // at submit time once the form has scrolled away.
    if (!isSelected && _isFull) {
      HapticFeedback.heavyImpact();
      setState(() => _error = StringConstants.groupMemberLimitReached);
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      _error = null;

      if (isSelected) {
        _selected.remove(participant.userId);
      } else {
        _selected.add(participant.userId);
      }
    });
  }

  /// Adds everyone currently listed — the whole pool, or just the search
  /// results when a query narrowed it. Stops at the cap rather than refusing.
  void _selectAllVisible() {
    HapticFeedback.selectionClick();
    setState(() {
      _error = null;
      for (final participant in _visibleCandidates) {
        if (_selected.length >= kMaxGroupMembers) {
          _error = StringConstants.groupMemberLimitReached;
          break;
        }
        _selected.add(participant.userId);
      }
    });
  }

  void _clearSelection() {
    HapticFeedback.selectionClick();
    setState(() {
      _selected.clear();
      _error = null;
    });
  }

  void _clearSearch() {
    _search.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.cardColor,
      appBar: CustomAppBar(title: StringConstants.createGroup),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimens.paddingX12),
              _buildHeader(),
              const SizedBox(height: AppDimens.paddingX12),
              // One scroll for the whole form. The member list used to be its
              // own 420px scroller inside this one, which trapped the gesture
              // and hid the venue section below it.
              Expanded(child: _buildScrollableContent()),
              _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  /// A summary card: who is in so far, and how far off the cap that is.
  Widget _buildHeader() {
    final textTheme = FutsalTheme.getTextTheme(context);
    final List<ParticipantModel> members = _selectedMembers;

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: LightColor.secondaryColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          if (members.isEmpty)
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              ),
              child: const Icon(
                Icons.groups_2_rounded,
                color: LightColor.secondaryColor,
                size: 24,
              ),
            )
          else
            _buildSelectedAvatarStack(members),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedCount == 0
                      ? StringConstants.addMembers
                      : '$_selectedCount of $kMaxGroupMembers ${StringConstants.selected.toLowerCase()}',
                  style: textTheme.bodyTextLarge?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isFull
                      ? StringConstants.groupFull
                      : _selectedCount == 0
                      ? StringConstants.nameTheGroupAndChooseWhoIsInIt
                      : StringConstants.tapANameToAddOrRemoveThem,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: _isFull
                        ? LightColor.redColor
                        : LightColor.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX8),
                // How close the selection is to the cap, without a number to
                // read: the count above already carries that.
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    value: _selectedCount / kMaxGroupMembers,
                    backgroundColor: LightColor.secondaryColor.withValues(
                      alpha: 0.12,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isFull ? LightColor.redColor : LightColor.secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Up to three faces, overlapped, with a "+n" for the rest — the selection
  /// at a glance while the chip strip is scrolled away.
  Widget _buildSelectedAvatarStack(List<ParticipantModel> members) {
    final textTheme = FutsalTheme.getTextTheme(context);
    const double size = 34;
    const double step = 22;
    final List<ParticipantModel> shown = members
        .take(3)
        .toList(growable: false);
    final int extra = members.length - shown.length;
    final int slots = shown.length + (extra > 0 ? 1 : 0);

    return SizedBox(
      width: step * (slots - 1) + size,
      height: 46,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          for (int i = 0; i < shown.length; i++)
            Positioned(
              left: step * i,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: LightColor.cardColor, width: 2),
                ),
                child: GroupMemberAvatar(
                  participant: shown[i],
                  size: size,
                  showPresence: false,
                ),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: step * shown.length,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: LightColor.cardColor, width: 2),
                ),
                child: Text(
                  '+$extra',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.inverseTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent() {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppDimens.paddingX16),
      children: [
        const SizedBox(height: 6),
        _buildGroupNameField(),
        const SizedBox(height: AppDimens.paddingX12),
        _buildMembersHeader(),
        const SizedBox(height: AppDimens.paddingX10),
        if (_candidates.isNotEmpty) ...[
          _buildSearchField(),
          const SizedBox(height: AppDimens.paddingX10),
        ],
        if (_selected.isNotEmpty) ...[
          GroupSelectedMembersStrip(
            members: _selectedMembers,
            onRemove: _toggleParticipant,
          ),
          const SizedBox(height: AppDimens.paddingX12),
        ],
        _buildMembersList(),
        const SizedBox(height: AppDimens.paddingX16),
        _buildOptionalVenueSection(),
        const SizedBox(height: AppDimens.paddingX16),
      ],
    );
  }

  Widget _buildGroupNameField() {
    return CustomTextField(
      controller: _title,
      focusNode: _titleFocus,
      textCapitalization: TextCapitalization.words,
      onChanged: (_) => setState(() => _error = null),
      labelText: StringConstants.groupName,
      hintText: StringConstants.eGWeekendFutsalTeam,
      icon: Icons.groups_2_outlined,
      ensureVisibleOnFocus: true,
    );
  }

  /// "Members" with the one action that applies right now: clear what is
  /// selected, or add everyone listed when nothing is.
  Widget _buildMembersHeader() {
    final bool canSelectAll =
        _visibleCandidates.isNotEmpty &&
        !_isFull &&
        _visibleCandidates.any((p) => !_selected.contains(p.userId));

    return GroupSectionHeader(
      title: _selectedCount == 0
          ? StringConstants.members
          : '${StringConstants.members} · $_selectedCount',
      trailingLabel: _selectedCount > 0
          ? StringConstants.clearAll
          : canSelectAll
          ? StringConstants.selectAll
          : null,
      trailingColor: _selectedCount > 0
          ? LightColor.redColor
          : LightColor.secondaryColor,
      onTrailingTap: _selectedCount > 0
          ? _clearSelection
          : canSelectAll
          ? _selectAllVisible
          : null,
    );
  }

  Widget _buildSearchField() {
    return CustomTextField(
      controller: _search,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      labelText: StringConstants.searchMembers,
      hintText: StringConstants.searchByNameOrEmail,
      icon: Icons.search_rounded,
      isRequired: false,
      suffixIcon: _search.text.isEmpty
          ? null
          : IconButton(
              tooltip: StringConstants.clearSearch,
              onPressed: _clearSearch,
              icon: const Icon(Icons.close_rounded),
            ),
    );
  }

  Widget _buildMembersList() {
    if (_candidates.isEmpty) {
      return const GroupEmptyStateCard(
        icon: Icons.person_search_outlined,
        title: StringConstants.noMembersFound,
        message: StringConstants.startAConversationFirstThenCreateAGroupFromIt,
      );
    }

    final List<ParticipantModel> visible = _visibleCandidates;

    if (visible.isEmpty) {
      return const GroupEmptyStateCard(
        icon: Icons.search_off_rounded,
        title: StringConstants.noMatchingMembers,
        message: StringConstants.trySearchingWithAnotherNameOrEmail,
      );
    }

    // Laid out, not scrolled: the page owns the only scroll, so every row is
    // reachable with one gesture and the venue section sits below the list
    // instead of behind it.
    return Container(
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: Column(
          children: [
            const SizedBox(height: AppDimens.paddingX4),
            for (int index = 0; index < visible.length; index++) ...[
              if (index > 0)
                const Divider(
                  height: 1,
                  indent: 64,
                  endIndent: AppDimens.paddingX12,
                ),
              GroupMemberTile(
                participant: visible[index],
                selected: _selected.contains(visible[index].userId),
                disabled: _isFull && !_selected.contains(visible[index].userId),
                onTap: () => _toggleParticipant(visible[index]),
              ),
            ],
            const SizedBox(height: AppDimens.paddingX4),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalVenueSection() {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            onTap: () => setState(() => _venueExpanded = !_venueExpanded),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingX12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: LightColor.secondaryColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    ),
                    child: const Icon(
                      Icons.stadium_outlined,
                      color: LightColor.secondaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringConstants.optionalVenue,
                          style: textTheme.bodyTextMedium?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          StringConstants.connectThisGroupToAVenue,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _venueExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _venueExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingX12,
                      0,
                      AppDimens.paddingX12,
                      AppDimens.paddingX12,
                    ),
                    child: CustomTextField(
                      controller: _venueId,
                      keyboardType: TextInputType.number,
                      labelText: StringConstants.venueId,
                      hintText: StringConstants.enterVenueId,
                      icon: Icons.tag_rounded,
                      isRequired: false,
                      ensureVisibleOnFocus: true,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  /// The button stays live even when the form is incomplete: [_submit] names
  /// what is missing in the banner above it. Handing it `null` instead left a
  /// button that looked pressable, did nothing, and said nothing.
  Widget _buildBottomAction() {
    return GroupBottomActionContainer(
      error: _error,
      child: CustomButton(
        text: _selectedCount == 0
            ? StringConstants.createGroupAction
            : '${StringConstants.createGroupAction} · $_selectedCount',
        onPressed: _submit,
        icon: Icons.group_add_rounded,
        minHeight: 46,
        borderRadius: AppDimens.radiusX12,
      ),
    );
  }
}
