import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_checkbox.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';

/// Pieces shared by the two member-picking surfaces: the create-group page and
/// the add-members sheet. They render the same rows, the same empty states and
/// the same footer, so the two stay consistent as either changes.

/// Server-side cap on a group's size.
const int kMaxGroupMembers = 50;

/// What the create-group page hands back: everything the create call needs.
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

/// A participant's picture, falling back to the initial of their name, with
/// the presence dot the conversation list also shows.
///
/// The picker used to draw initials only. People recognise a face faster than
/// a letter, and the same URL is already on the row in the conversation list,
/// so the two surfaces now show the same person.
class GroupMemberAvatar extends StatelessWidget {
  const GroupMemberAvatar({
    super.key,
    required this.participant,
    this.size = 42,
    this.showPresence = true,
  });

  final ParticipantModel participant;
  final double size;

  /// Off for the compact chips, where a 6px dot on a 26px avatar reads as
  /// noise rather than status.
  final bool showPresence;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final String url = participant.avatarUrl.trim();

    final Widget face = url.isEmpty
        ? Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              groupInitial(participant.name),
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.secondaryColor,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.38,
              ),
            ),
          )
        : ClipOval(
            child: CustomImageView(
              url: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          );

    if (!showPresence || !participant.isOnline) return face;

    final double dot = (size * 0.28).clamp(8.0, 13.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        face,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: dot,
            height: dot,
            decoration: BoxDecoration(
              color: LightColor.successColor,
              shape: BoxShape.circle,
              border: Border.all(color: LightColor.background, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// A section title with an optional trailing text action.
///
/// The old header rendered "Clear" as plain text with nothing behind it — it
/// looked tappable and was not. Here the action only appears when it can
/// actually do something, and it is a real button.
class GroupSectionHeader extends StatelessWidget {
  const GroupSectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
    this.trailingColor,
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailingLabel case final label? when onTrailingTap != null)
          InkWell(
            onTap: onTrailingTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingX8,
                vertical: AppDimens.paddingX4,
              ),
              child: Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: trailingColor ?? LightColor.secondaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The people picked so far, as a horizontal strip of removable chips.
///
/// Kept visible while the list is scrolled and searched: the selection is
/// otherwise invisible once the chosen names have scrolled out of view.
class GroupSelectedMembersStrip extends StatelessWidget {
  const GroupSelectedMembersStrip({
    super.key,
    required this.members,
    required this.onRemove,
  });

  final List<ParticipantModel> members;
  final ValueChanged<ParticipantModel> onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    if (members.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: AppDimens.sizeX44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX2),
        itemCount: members.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, index) {
          final ParticipantModel participant = members[index];
          return InputChip(
            visualDensity: VisualDensity.compact,
            backgroundColor: LightColor.secondaryColor.withValues(alpha: 0.08),
            side: BorderSide(
              color: LightColor.secondaryColor.withValues(alpha: 0.20),
            ),
            avatar: GroupMemberAvatar(
              participant: participant,
              size: 26,
              showPresence: false,
            ),
            label: Text(
              groupDisplayName(participant),
              style: textTheme.bodySubTitle,
            ),
            deleteIcon: const Icon(Icons.close_rounded, size: 16),
            onDeleted: () => onRemove(participant),
          );
        },
      ),
    );
  }
}

class GroupMemberTile extends StatelessWidget {
  const GroupMemberTile({
    super.key,
    required this.participant,
    required this.selected,
    required this.onTap,
    this.disabled = false,
  });

  final ParticipantModel participant;
  final bool selected;
  final VoidCallback onTap;

  /// A row that cannot be selected because the group is already full. It stays
  /// readable rather than disappearing, so the list does not shift under the
  /// user at the moment they hit the cap.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final name = participant.name.trim();
    final email = participant.email.trim();
    final role = participant.role.trim();

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
      color: selected
          ? LightColor.secondaryColor.withValues(alpha: 0.06)
          : LightColor.background,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX10,
          ),
          child: Row(
            children: [
              GroupMemberAvatar(participant: participant),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name.isEmpty ? StringConstants.unknownUser : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyTextMedium?.copyWith(
                              color: LightColor.primaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (participant.isOnline) ...[
                          const SizedBox(width: AppDimens.paddingX6),
                          Text(
                            StringConstants.online,
                            style: textTheme.bodyTextSmall?.copyWith(
                              color: LightColor.successColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
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
                onChanged: disabled ? null : (_) => onTap(),
                labelWidget: const SizedBox.shrink(),
                spacing: 0,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class GroupEmptyStateCard extends StatelessWidget {
  const GroupEmptyStateCard({
    super.key,
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

class GroupBottomActionContainer extends StatelessWidget {
  const GroupBottomActionContainer({
    super.key,
    required this.child,
    this.error,
  });

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
            GroupErrorBanner(message: message),
            const SizedBox(height: AppDimens.paddingX10),
          ],
          child,
        ],
      ),
    );
  }
}

class GroupErrorBanner extends StatelessWidget {
  const GroupErrorBanner({super.key, required this.message});

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

/// The name to print for a participant whose `name` came back blank.
String groupDisplayName(ParticipantModel participant) {
  final String name = participant.name.trim();
  return name.isEmpty ? StringConstants.unknownUser : name;
}

String groupInitial(String value) {
  final trimmed = value.trim();

  if (trimmed.isEmpty) return '?';

  return trimmed.characters.first.toUpperCase();
}
