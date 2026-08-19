import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_checkbox.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

const int _kMaxGroupMembers = 50;
const double _kCreateGroupSheetHeightFactor = 0.88;
const double _kAddMembersSheetHeightFactor = 0.70;

final class GroupConversationDraft {
  const GroupConversationDraft({
    required this.title,
    required this.participantIds,
    this.venueId,
  });

  final String title;
  final List<int> participantIds;
  final int? venueId;
}

Future<List<int>?> showAddGroupMembersSheet({
  required BuildContext context,
  required Iterable<ParticipantModel> participants,
  required Set<int> excludedUserIds,
}) {
  final candidates = <int, ParticipantModel>{};

  for (final participant in participants) {
    if (participant.userId > 0 &&
        !excludedUserIds.contains(participant.userId)) {
      candidates[participant.userId] = participant;
    }
  }

  final sortedCandidates = candidates.values.toList(growable: false)
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return showAppBottomSheet<List<int>>(
    context: context,
    builder: (_) => _AddGroupMembersForm(
      candidates: sortedCandidates,
      excludedUserIds: excludedUserIds,
    ),
  );
}

class _AddGroupMembersForm extends StatefulWidget {
  const _AddGroupMembersForm({
    required this.candidates,
    required this.excludedUserIds,
  });

  final List<ParticipantModel> candidates;
  final Set<int> excludedUserIds;

  @override
  State<_AddGroupMembersForm> createState() => _AddGroupMembersFormState();
}

class _AddGroupMembersFormState extends State<_AddGroupMembersForm> {
  final Set<int> _selected = <int>{};

  String? _error;

  int get _totalMemberCount => _selected.length + widget.excludedUserIds.length;

  bool get _canSubmit {
    return _selected.isNotEmpty && _totalMemberCount <= _kMaxGroupMembers;
  }

  void _submit() {
    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one new member.');
      return;
    }

    if (_totalMemberCount > _kMaxGroupMembers) {
      setState(() {
        _error = 'A group can contain at most $_kMaxGroupMembers members.';
      });
      return;
    }

    Navigator.of(context).pop(_selected.toList(growable: false));
  }

  void _toggleParticipant(ParticipantModel participant) {
    HapticFeedback.selectionClick();

    setState(() {
      _error = null;

      if (_selected.contains(participant.userId)) {
        _selected.remove(participant.userId);
      } else {
        _selected.add(participant.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final preferredHeight =
            MediaQuery.sizeOf(context).height * _kAddMembersSheetHeightFactor;
        return SizedBox(
          height: math.min(preferredHeight, constraints.maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BottomSheetDragHandle(),
              const SizedBox(height: AppDimens.paddingX12),
              _buildHeader(),
              const SizedBox(height: AppDimens.paddingX16),
              Expanded(child: _buildContent()),
              _buildBottomAction(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: LightColor.secondaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StringConstants.addMembersTitle,
                style: textTheme.bodyTextLarge?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _selected.isEmpty
                    ? 'Choose people to add in this group'
                    : '${_selected.length} selected',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: _selected.isEmpty
                      ? LightColor.secondaryTextColor
                      : LightColor.secondaryColor,
                  fontWeight: _selected.isEmpty
                      ? FontWeight.w400
                      : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: StringConstants.close,
          style: IconButton.styleFrom(
            backgroundColor: LightColor.background,
            foregroundColor: LightColor.secondaryTextColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 20),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (widget.candidates.isEmpty) {
      return const _EmptyStateCard(
        icon: Icons.person_search_outlined,
        title: StringConstants.noMembersAvailable,
        message: StringConstants.thereAreNoNewPeopleAvailableToAddInThisGroup,
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppDimens.paddingX16),
      itemCount: widget.candidates.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
      itemBuilder: (_, index) {
        final participant = widget.candidates[index];
        final selected = _selected.contains(participant.userId);

        return _MemberTile(
          participant: participant,
          selected: selected,
          onTap: () => _toggleParticipant(participant),
        );
      },
    );
  }

  Widget _buildBottomAction() {
    return _BottomActionContainer(
      error: _error,
      child: FilledButton.icon(
        onPressed: _canSubmit ? _submit : null,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(
          _selected.isEmpty
              ? 'Add members'
              : 'Add ${_selected.length} ${_selected.length == 1 ? 'member' : 'members'}',
        ),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: LightColor.secondaryColor,
          disabledBackgroundColor: LightColor.secondaryColor.withValues(
            alpha: 0.35,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
        ),
      ),
    );
  }
}

Future<GroupConversationDraft?> showGroupConversationSheet({
  required BuildContext context,
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
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return showAppBottomSheet<GroupConversationDraft>(
    context: context,
    builder: (_) => _GroupConversationForm(
      candidates: candidates,
      currentUserId: currentUserId,
    ),
  );
}

class _GroupConversationForm extends StatefulWidget {
  const _GroupConversationForm({
    required this.candidates,
    required this.currentUserId,
  });

  final List<ParticipantModel> candidates;
  final int currentUserId;

  @override
  State<_GroupConversationForm> createState() => _GroupConversationFormState();
}

class _GroupConversationFormState extends State<_GroupConversationForm> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _search = TextEditingController();
  final TextEditingController _venueId = TextEditingController();

  final Set<int> _selected = <int>{};

  String? _error;
  bool _venueExpanded = false;

  int get _selectedCount => _selected.length;

  List<ParticipantModel> get _visibleCandidates {
    final query = _search.text.trim().toLowerCase();

    if (query.isEmpty) return widget.candidates;

    return widget.candidates
        .where((participant) {
          return participant.name.toLowerCase().contains(query) ||
              participant.email.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  bool get _canSubmit {
    final title = _title.text.trim();

    return title.isNotEmpty &&
        title.length <= 255 &&
        _selectedCount > 0 &&
        _selectedCount <= _kMaxGroupMembers;
  }

  @override
  void dispose() {
    _title.dispose();
    _search.dispose();
    _venueId.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();

    if (title.isEmpty) {
      setState(() => _error = 'Enter a group name.');
      return;
    }

    if (title.length > 255) {
      setState(() => _error = 'Group name must be 255 characters or fewer.');
      return;
    }

    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one member.');
      return;
    }

    if (_selected.length > _kMaxGroupMembers) {
      setState(() {
        _error = 'A group can contain at most $_kMaxGroupMembers members.';
      });
      return;
    }

    final venueId = int.tryParse(_venueId.text.trim());

    Navigator.of(context).pop(
      GroupConversationDraft(
        title: title,
        participantIds: _selected.toList(growable: false),
        venueId: venueId,
      ),
    );
  }

  void _toggleParticipant(ParticipantModel participant) {
    HapticFeedback.selectionClick();

    setState(() {
      _error = null;

      if (_selected.contains(participant.userId)) {
        _selected.remove(participant.userId);
      } else {
        _selected.add(participant.userId);
      }
    });
  }

  void _clearSearch() {
    _search.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final preferredHeight =
            MediaQuery.sizeOf(context).height * _kCreateGroupSheetHeightFactor;
        return SizedBox(
          height: math.min(preferredHeight, constraints.maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimens.paddingX12),
              _buildHeader(),
              const SizedBox(height: AppDimens.paddingX16),
              Expanded(child: _buildScrollableContent()),
              _buildBottomAction(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
          child: const Icon(
            Icons.groups_2_rounded,
            color: LightColor.secondaryColor,
            size: 26,
          ),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StringConstants.createGroup,
                style: textTheme.bodyTextLarge?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _selectedCount == 0
                    ? 'Add members and start a group conversation'
                    : '$_selectedCount/$_kMaxGroupMembers members selected',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: _selectedCount == 0
                      ? LightColor.secondaryTextColor
                      : LightColor.secondaryColor,
                  fontWeight: _selectedCount == 0
                      ? FontWeight.w400
                      : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: StringConstants.close,
          style: IconButton.styleFrom(
            backgroundColor: LightColor.background,
            foregroundColor: LightColor.secondaryTextColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 20),
        ),
      ],
    );
  }

  Widget _buildScrollableContent() {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppDimens.paddingX16),
      children: [
        SizedBox(height: 6),
        _buildGroupNameField(),
        const SizedBox(height: AppDimens.paddingX8),
        _buildMembersHeader(),
        const SizedBox(height: AppDimens.paddingX10),
        if (widget.candidates.isNotEmpty) ...[
          _buildSearchField(),
          const SizedBox(height: AppDimens.paddingX10),
        ],
        if (_selected.isNotEmpty) ...[
          _buildSelectedMembers(),
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
      textCapitalization: TextCapitalization.words,
      onChanged: (_) => setState(() => _error = null),
      labelText: StringConstants.groupName,
      hintText: StringConstants.eGWeekendFutsalTeam,
      icon: Icons.groups_2_outlined,
      ensureVisibleOnFocus: true,
    );
  }

  Widget _buildMembersHeader() {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            StringConstants.members,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            StringConstants.clear,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.redColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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

  Widget _buildSelectedMembers() {
    final textTheme = FutsalTheme.getTextTheme(context);
    final selectedMembers = widget.candidates
        .where((participant) {
          return _selected.contains(participant.userId);
        })
        .toList(growable: false);

    return SizedBox(
      height: AppDimens.sizeX44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX2),
        itemCount: selectedMembers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, index) {
          final participant = selectedMembers[index];

          return InputChip(
            backgroundColor: LightColor.secondaryColor.withValues(alpha: 0.08),
            side: BorderSide(
              color: LightColor.secondaryColor.withValues(alpha: 0.20),
            ),
            avatar: CircleAvatar(
              backgroundColor: LightColor.secondaryColor.withValues(
                alpha: 0.14,
              ),
              child: Text(
                _getInitial(participant.name),
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            label: Text(
              participant.name.trim().isEmpty
                  ? 'Unknown user'
                  : participant.name,
              style: textTheme.bodySubTitle,
            ),
            onDeleted: () => _toggleParticipant(participant),
          );
        },
      ),
    );
  }

  Widget _buildMembersList() {
    if (widget.candidates.isEmpty) {
      return const _EmptyStateCard(
        icon: Icons.person_search_outlined,
        title: StringConstants.noMembersFound,
        message: StringConstants.startAConversationFirstThenCreateAGroupFromIt,
      );
    }

    if (_visibleCandidates.isEmpty) {
      return const _EmptyStateCard(
        icon: Icons.search_off_rounded,
        title: StringConstants.noMatchingMembers,
        message: StringConstants.trySearchingWithAnotherNameOrEmail,
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 310),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX4),
          itemCount: _visibleCandidates.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 64,
            endIndent: AppDimens.paddingX12,
          ),
          itemBuilder: (_, index) {
            final participant = _visibleCandidates[index];
            final selected = _selected.contains(participant.userId);

            return _MemberTile(
              participant: participant,
              selected: selected,
              onTap: () => _toggleParticipant(participant),
            );
          },
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
                  Icon(
                    _venueExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ],
              ),
            ),
          ),
          if (_venueExpanded)
            Padding(
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
            ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return _BottomActionContainer(
      error: _error,
      child: CustomButton(
        text: _selectedCount == 0
            ? 'Create group'
            : 'Create group with $_selectedCount',
        onPressed: _canSubmit ? _submit : null,
        icon: Icons.group_add_rounded,
        minHeight: 46,
        borderRadius: AppDimens.radiusX12,
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.participant,
    required this.selected,
    required this.onTap,
  });

  final ParticipantModel participant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final name = participant.name.trim();
    final email = participant.email.trim();
    final role = participant.role.trim();

    return Material(
      color: selected
          ? LightColor.secondaryColor.withValues(alpha: 0.06)
          : LightColor.background,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX10,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: LightColor.secondaryColor.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  _getInitial(name),
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Unknown user' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email.isNotEmpty
                          ? email
                          : role.isNotEmpty
                          ? role
                          : 'User #${participant.userId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX8),
              CustomCheckbox(
                value: selected,
                onChanged: (_) => onTap(),
                labelWidget: const SizedBox.shrink(),
                spacing: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: LightColor.hintTextColor, size: 24),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionContainer extends StatelessWidget {
  const _BottomActionContainer({required this.child, this.error});

  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        0,
        AppDimens.paddingX12,
        0,
        AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: LightColor.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error case final message?) ...[
            _ErrorBanner(message: message),
            const SizedBox(height: AppDimens.paddingX10),
          ],
          child,
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingX10),
      decoration: BoxDecoration(
        color: LightColor.redLightColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.redColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: LightColor.redColor,
            size: 18,
          ),
          const SizedBox(width: AppDimens.paddingX8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.redColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetDragHandle extends StatelessWidget {
  const _BottomSheetDragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: LightColor.dividerColor,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

String _getInitial(String value) {
  final trimmed = value.trim();

  if (trimmed.isEmpty) return '?';

  return trimmed.characters.first.toUpperCase();
}
