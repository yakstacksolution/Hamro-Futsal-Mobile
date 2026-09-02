import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/message/presentation/widgets/group_member_widgets.dart';
import 'package:hamro_futsal/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

/// Adding people to a group that already exists. Creating one is a full page
/// — see `CreateGroupConversationPage` — because that form is far longer; this
/// one is a single list, which a sheet suits.
const double _kAddMembersSheetHeightFactor = 0.70;

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
    return _selected.isNotEmpty && _totalMemberCount <= kMaxGroupMembers;
  }

  void _submit() {
    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one new member.');
      return;
    }

    if (_totalMemberCount > kMaxGroupMembers) {
      setState(() {
        _error = 'A group can contain at most $kMaxGroupMembers members.';
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
      return const GroupEmptyStateCard(
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

        return GroupMemberTile(
          participant: participant,
          selected: selected,
          // The cap counts the members already in the group, so rows go
          // unselectable here as soon as adding one more would exceed it.
          disabled: !selected && _totalMemberCount >= kMaxGroupMembers,
          onTap: () => _toggleParticipant(participant),
        );
      },
    );
  }

  Widget _buildBottomAction() {
    return GroupBottomActionContainer(
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
