import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';

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
    this.countLabel,
    this.trailingLabel,
    this.onTrailingTap,
    this.trailingColor,
  });

  final String title;

  /// Compact progress pill beside the title (e.g. `4/50`). The count used to
  /// live in a sentence under the header, where it read as help text rather
  /// than as the number the user is tracking while picking.
  final String? countLabel;

  final String? trailingLabel;
  final VoidCallback? onTrailingTap;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color accent = trailingColor ?? LightColor.secondaryColor;

    return Row(
      children: [
        // Flexible, so a scaled-up title gives way to the action beside it
        // instead of pushing the row past the screen edge.
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (countLabel case final count?) ...[
          const SizedBox(width: AppDimens.paddingX8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX8,
              vertical: AppDimens.paddingX2,
            ),
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            ),
            child: Text(
              count,
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: LightColor.secondaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (trailingLabel case final label? when onTrailingTap != null)
          Material(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            child: InkWell(
              onTap: onTrailingTap,
              borderRadius: BorderRadius.circular(AppDimens.radiusX20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX8,
                  vertical: AppDimens.paddingX2,
                ),
                child: Text(
                  label,
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
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

    // One horizontal row: the selection stays a single line no matter how many
    // people are picked, and the panel's own padding keeps the first and last
    // chip clear of its edges while scrolling.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX6),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: LightColor.secondaryColor.withValues(alpha: 0.16),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX8),
        child: Row(
          children: <Widget>[
            for (int index = 0; index < members.length; index++) ...<Widget>[
              if (index > 0) const SizedBox(width: AppDimens.paddingX6),
              InputChip(
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: LightColor.cardColor,
                side: BorderSide(
                  color: LightColor.secondaryColor.withValues(alpha: 0.24),
                ),
                avatar: GroupMemberAvatar(
                  participant: members[index],
                  size: 24,
                  showPresence: false,
                ),
                label: Text(
                  groupDisplayName(members[index]),
                  style: textTheme.bodySubTitle?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                deleteIcon: const Icon(Icons.close_rounded, size: 15),
                deleteIconColor: LightColor.secondaryTextColor,
                tooltip: StringConstants.remove,
                onDeleted: () => onRemove(members[index]),
              ),
            ],
          ],
        ),
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
    final String name = participant.name.trim();
    final String email = participant.email.trim();
    final String role = participant.role.trim();

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: selected
            ? LightColor.secondaryColor.withValues(alpha: 0.06)
            : LightColor.background,
        child: InkWell(
          onTap: disabled ? null : onTap,
          child: Row(
            children: <Widget>[
              // A selected row is marked at its edge as well as by the tick, so
              // the selection is readable while scanning the column of names.
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 3,
                height: AppDimens.sizeX52,
                color: selected
                    ? LightColor.secondaryColor
                    : Colors.transparent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingX12,
                    vertical: AppDimens.paddingX10,
                  ),
                  child: Row(
                    children: <Widget>[
                      GroupMemberAvatar(participant: participant),
                      const SizedBox(width: AppDimens.paddingX12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              name.isEmpty ? StringConstants.unknownUser : name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyTextMedium?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppDimens.paddingX2),
                            // Wrapped: at large text sizes the badges plus an
                            // email do not fit one line, and a Row overflowed
                            // instead of moving the email down.
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: AppDimens.paddingX6,
                              runSpacing: AppDimens.paddingX2,
                              children: <Widget>[
                                if (role.isNotEmpty) _RoleBadge(role: role),
                                if (participant.isOnline) const _OnlineBadge(),
                                // The email identifies people who share a
                                // first name; the role badge covers the rows
                                // that have no email at all.
                                if (email.isNotEmpty || role.isEmpty)
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.sizeOf(
                                        context,
                                      ).width,
                                    ),
                                    child: Text(
                                      email.isNotEmpty
                                          ? email
                                          : 'User #${participant.userId}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodyTextSmall?.copyWith(
                                        color: LightColor.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingX8),
                      _SelectionTick(selected: selected, disabled: disabled),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The tick on a member row.
///
/// A round outline that fills in when picked: the square checkbox read as a
/// form control on every row, which made a list of four people look like a
/// column of unchecked boxes rather than a selection.
class _SelectionTick extends StatelessWidget {
  const _SelectionTick({required this.selected, required this.disabled});

  final bool selected;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: AppDimens.sizeX22,
      height: AppDimens.sizeX22,
      decoration: BoxDecoration(
        color: selected ? LightColor.secondaryColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? LightColor.secondaryColor : LightColor.dividerColor,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(
              Icons.check_rounded,
              size: AppDimens.sizeX14,
              color: LightColor.inverseTextColor,
            )
          : null,
    );
  }
}

/// `vendor` / `client` as a quiet pill rather than another line of grey text.
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX6,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: LightColor.dividerColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Text(
        role.toUpperCase(),
        style: textTheme.bodyMiniSubTitle?.copyWith(
          color: LightColor.secondaryTextColor,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: LightColor.successColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimens.paddingX4),
        Text(
          StringConstants.online,
          style: textTheme.bodyMiniSubTitle?.copyWith(
            color: LightColor.successColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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

class GroupMembersLoadingCard extends StatelessWidget {
  const GroupMembersLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX16,
        vertical: AppDimens.paddingX24,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: const Center(
        child: SizedBox(
          width: AppDimens.sizeX22,
          height: AppDimens.sizeX22,
          child: CircularProgressIndicator(strokeWidth: 2.3),
        ),
      ),
    );
  }
}

class GroupMembersErrorCard extends StatelessWidget {
  const GroupMembersErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class GroupMembersFooter extends StatelessWidget {
  const GroupMembersFooter({
    super.key,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.paddingX14),
        child: Center(
          child: SizedBox(
            width: AppDimens.sizeX20,
            height: AppDimens.sizeX20,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      );
    }
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX12,
        AppDimens.paddingX8,
        AppDimens.paddingX12,
        AppDimens.paddingX4,
      ),
      child: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Could not load more. Retry'),
      ),
    );
  }
}
