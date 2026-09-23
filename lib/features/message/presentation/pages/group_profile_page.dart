import 'package:hamro_futsal/core/utils/bloc_safe_add.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/features/vendor/data/repositories/vendor_onboarding_repository_impl.dart';
import 'package:hamro_futsal/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_futsal/features/vendor/domain/usecase/vendor_onboarding_usecase.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_futsal/features/media/presentation/widgets/media_library_sheet.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_futsal/features/message/presentation/pages/user_profile_page.dart';
import 'package:hamro_futsal/features/message/presentation/widgets/group_conversation_sheet.dart';
import 'package:hamro_futsal/features/message/presentation/widgets/group_member_widgets.dart';

/// The group behind a chat: its picture, its name and everyone in it.
///
/// Reached by tapping the chat's app-bar header, the same gesture that opens a
/// person's profile in a direct chat. The member list used to live in the
/// chat's overflow sheet, which could only ever show a cramped strip of it.
///
/// Pops `true` when the user has left the group, which is the chat page's cue
/// to close itself — the thread it is showing is no longer theirs.
Future<bool> openGroupProfilePage({
  required BuildContext context,
  required ConversationModel conversation,
}) async {
  final bloc = context.read<MessageBloc>();
  final bool? left = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: GroupProfilePage(conversation: conversation),
      ),
    ),
  );
  return left ?? false;
}

class GroupProfilePage extends StatefulWidget {
  const GroupProfilePage({super.key, required this.conversation});

  /// The conversation as the chat page knows it — the fallback while the bloc
  /// holds no fresher copy of it.
  final ConversationModel conversation;

  @override
  State<GroupProfilePage> createState() => _GroupProfilePageState();
}

class _GroupProfilePageState extends State<GroupProfilePage> {
  /// Owns the media library sheet's working state — the same throwaway cubit
  /// the profile screen uses to pick an avatar. It holds no onboarding draft;
  /// the library is simply where the app keeps its images.
  late final VendorOnboardingCubit _mediaCubit;

  @override
  void initState() {
    super.initState();
    _mediaCubit = VendorOnboardingCubit(
      const EphemeralVendorDraftRepository(),
      onboardingUseCase: VendorOnboardingUseCase(
        VendorOnboardingRepositoryImpl(),
      ),
    );
  }

  @override
  void dispose() {
    _mediaCubit.close();
    super.dispose();
  }

  ConversationModel get conversation => widget.conversation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.cardColor,
      appBar: CustomAppBar(title: StringConstants.groupInfo),
      body: BlocConsumer<MessageBloc, MessageState>(
        listenWhen: (previous, current) =>
            previous.leftConversationId != current.leftConversationId ||
            previous.actionMessage != current.actionMessage ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          final bloc = context.read<MessageBloc>();
          if (state.leftConversationId == conversation.id) {
            bloc.addIfOpen(const ClearLeftConversationEvent());
            Navigator.of(context).pop(true);
            return;
          }
          if (state.errorMessage case final message?) {
            AppUtils().showSnackBar(context, MsgType.error, message);
            bloc.addIfOpen(const ClearMessageActionEvent());
            return;
          }
          // Renames and added members both report back through here.
          if (state.actionMessage case final message?) {
            AppUtils().showSnackBar(context, MsgType.success, message);
            bloc.add(const ClearMessageActionEvent());
          }
        },
        builder: (context, state) {
          // The bloc's copy wins while it is about this same group: members
          // added or blocked from here land there first.
          final ConversationModel group =
              state.activeConversation?.id == conversation.id
              ? state.activeConversation!
              : conversation;

          // The last member row would otherwise end under the home
          // indicator; the app bar already handles the top inset.
          return SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppDimens.paddingX24),
              children: [
                _Header(
                  group: group,
                  currentUserId: state.currentUserId,
                  busy: state.actionBusy,
                  mediaCubit: _mediaCubit,
                ),
                const SizedBox(height: AppDimens.paddingX16),
                _Actions(group: group, busy: state.actionBusy),
                const SizedBox(height: AppDimens.paddingX16),
                _Members(group: group, currentUserId: state.currentUserId),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Picture, name and size. A group has no image of its own in the API, so its
/// members' faces stand in for one — the same read the inbox row gives.
class _Header extends StatelessWidget {
  const _Header({
    required this.group,
    required this.currentUserId,
    required this.busy,
    required this.mediaCubit,
  });

  final ConversationModel group;
  final int currentUserId;
  final bool busy;
  final VendorOnboardingCubit mediaCubit;

  Future<void> _rename(BuildContext context) async {
    final MessageBloc bloc = context.read<MessageBloc>();
    final String? title = await showChangeGroupNameDialog(
      context: context,
      currentTitle: group.displayTitle(currentUserId),
    );
    if (title == null || bloc.isClosed) return;
    bloc.add(UpdateGroupConversationEvent(group.id, title: title));
  }

  /// Picks a new group photo from the app's media library and sends it on its
  /// own — the name is edited separately, and pairing them would make changing
  /// one look like changing both.
  ///
  /// The library returns saved images by id, and new uploads land there first,
  /// so what goes to the API is always a media id rather than a file.
  Future<void> _changePhoto(BuildContext context) async {
    final MessageBloc bloc = context.read<MessageBloc>();
    final List<UploadRef>? picked = await showVendorMediaLibrarySheet(
      context: context,
      cubit: mediaCubit,
      allowedExtensions: const <String>['png', 'jpg', 'jpeg', 'webp'],
      allowMultiple: false,
      title: StringConstants.groupPhoto,
      subtitle: StringConstants.chooseASavedImageOrUploadANewOne,
    );
    if (picked == null || picked.isEmpty || bloc.isClosed) return;

    final UploadRef selected = picked.first;
    final int? mediaId = selected.id;
    // An image still uploading has no id yet; there is nothing to send until
    // the library has it.
    if (mediaId == null) return;

    bloc.add(
      UpdateGroupConversationEvent(
        group.id,
        mediaId: mediaId,
        // Shown straight away, so the picture changes on selection instead of
        // waiting for the server to echo it back.
        imageUrl: selected.remoteUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final List<ParticipantModel> members = group.participants;
    final String venue = group.venue?.name.trim() ?? '';
    // A superadmin's group owns its own name and picture; neither is the
    // members' to change, so both edit affordances are gone rather than
    // offered and refused by the API.
    final bool locked = group.isSuperadminCreatedGroup;

    // Material again: the name below is an InkWell, and its ripple would be
    // painted behind a plain coloured box.
    return Material(
      color: LightColor.background,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX16,
          vertical: AppDimens.paddingX20,
        ),
        child: Column(
          children: [
            // The picture is editable now, so it carries its own camera badge
            // rather than relying on the pencil beside the name below. A group
            // a superadmin created is managed centrally: no badge, no picker.
            _GroupImage(
              members: members,
              imageUrl: group.imageUrl,
              onEdit: busy || locked ? null : () => _changePhoto(context),
            ),
            const SizedBox(height: AppDimens.paddingX12),
            // The name is the one thing here that can be edited, so it carries
            // the pencil rather than hiding a rename in the overflow.
            InkWell(
              onTap: busy || locked ? null : () => _rename(context),
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX8,
                  vertical: AppDimens.paddingX4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        group.displayTitle(currentUserId),
                        textAlign: TextAlign.center,
                        style: textTheme.bodyTextLarge?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!locked) ...[
                      const SizedBox(width: AppDimens.paddingX6),
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: LightColor.secondaryColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${members.length} ${members.length == 1 ? 'member' : 'members'}',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            if (venue.isNotEmpty) ...[
              const SizedBox(height: AppDimens.paddingX10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stadium_outlined,
                    size: 16,
                    color: LightColor.secondaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    venue,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One large circle: a single member's photo when that is all there is, and a
/// two-by-two of faces once the group is bigger, with the group glyph as the
/// fallback for members who have no picture.
class _GroupImage extends StatelessWidget {
  const _GroupImage({required this.members, this.imageUrl = '', this.onEdit});

  final List<ParticipantModel> members;

  /// The group's own picture. When it has one, it replaces the collage of
  /// member faces that stands in until then.
  final String imageUrl;

  /// Opens the picker. Null while an edit is already in flight.
  final VoidCallback? onEdit;

  static const double _size = 108;

  @override
  Widget build(BuildContext context) {
    final Widget picture = _picture();
    if (onEdit == null) return picture;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        // Tapping anywhere on the picture opens the picker; the badge says so.
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onEdit, child: picture),
        ),
        // The badge carries its own tap.
        //
        // It sits past the circle's edge, where the picture's InkWell does not
        // reach, so as decoration it looked like the button and did nothing.
        // The transparent padding around it makes the target 44 without
        // changing how big the badge looks, and keeps it inside the stack's
        // bounds — a child positioned outside them paints but cannot be hit.
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onEdit,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: LightColor.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: LightColor.background, width: 2),
                  ),
                  child: Icon(
                    Icons.photo_camera_rounded,
                    size: 17,
                    color: LightColor.inverseTextColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _picture() {
    if (imageUrl.trim().isNotEmpty) {
      return ClipOval(
        child: CustomImageView(
          imagePath: imageUrl,
          width: _size,
          height: _size,
          fit: BoxFit.cover,
        ),
      );
    }

    final List<ParticipantModel> withPhotos = members
        .where((m) => m.avatarUrl.trim().isNotEmpty)
        .toList(growable: false);

    if (withPhotos.isEmpty) {
      return Container(
        width: _size,
        height: _size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: LightColor.secondaryColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.groups_2_rounded,
          size: 46,
          color: LightColor.secondaryColor,
        ),
      );
    }

    if (withPhotos.length == 1) {
      return GroupMemberAvatar(
        participant: withPhotos.first,
        size: _size,
        showPresence: false,
      );
    }

    final List<ParticipantModel> tiles = withPhotos
        .take(4)
        .toList(growable: false);
    return ClipOval(
      child: SizedBox(
        width: _size,
        height: _size,
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          children: [
            for (final participant in tiles)
              GroupMemberAvatar(
                participant: participant,
                size: _size / 2,
                showPresence: false,
              ),
          ],
        ),
      ),
    );
  }
}

/// What can be done to the group from here: pull more people in, or step out.
class _Actions extends StatelessWidget {
  const _Actions({required this.group, required this.busy});

  final ConversationModel group;
  final bool busy;

  Future<void> _addMembers(BuildContext context) async {
    final MessageBloc bloc = context.read<MessageBloc>();
    final Set<int> existing =
        group.participants.map((participant) => participant.userId).toSet()
          ..add(bloc.state.currentUserId);
    final List<int>? ids = await showAddGroupMembersSheet(
      context: context,
      excludedUserIds: existing,
      participants: bloc.state.conversations.expand(
        (conversation) => conversation.participants,
      ),
    );
    if (ids == null || ids.isEmpty || bloc.isClosed) return;
    bloc.add(AddGroupMembersEvent(group.id, ids));
  }

  Future<void> _leave(BuildContext context) async {
    final MessageBloc bloc = context.read<MessageBloc>();
    final bool? confirmed = await showAppBottomSheet<bool>(
      context: context,
      builder: (_) => const _LeaveGroupSheet(),
    );
    if (confirmed != true || bloc.isClosed) return;
    bloc.add(LeaveGroupConversationEvent(group.id));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    // Material, not a coloured Container: a ListTile paints its background and
    // its ink splash onto the nearest Material ancestor, so a plain ColoredBox
    // in between swallows both (and Flutter asserts about it).
    return Material(
      color: LightColor.background,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.person_add_alt_1_rounded,
              color: LightColor.secondaryColor,
            ),
            title: Text(
              StringConstants.addMembers,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: busy ? null : () => _addMembers(context),
          ),
          const Divider(height: 1, indent: AppDimens.paddingX16),
          ListTile(
            leading: busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.logout_rounded, color: LightColor.redColor),
            title: Text(
              busy ? StringConstants.leaving : StringConstants.leaveGroup,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.redColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: busy ? null : () => _leave(context),
          ),
        ],
      ),
    );
  }
}

class _LeaveGroupSheet extends StatelessWidget {
  const _LeaveGroupSheet();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppDimens.sizeX44,
              height: AppDimens.sizeX44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: LightColor.redColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: LightColor.redColor,
                size: AppDimens.sizeX24,
              ),
            ),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringConstants.leaveGroupQuestion,
                    style: textTheme.bodyTextLarge?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX6),
                  Text(
                    StringConstants.leaveGroupMessage,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.paddingX20),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                key: const Key('cancel-leave-group-button'),
                text: StringConstants.cancel,
                isOutlined: true,
                minHeight: AppDimens.sizeX46,
                borderRadius: AppDimens.radiusX12,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              child: CustomButton(
                key: const Key('confirm-leave-group-button'),
                text: StringConstants.leaveGroup,
                icon: Icons.logout_rounded,
                backgroundColor: LightColor.redColor,
                foregroundColor: LightColor.inverseTextColor,
                minHeight: AppDimens.sizeX46,
                borderRadius: AppDimens.radiusX12,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Everyone in the group. Tapping a row opens that person's profile; the
/// overflow carries the block action the chat's overflow sheet used to hold.
class _Members extends StatelessWidget {
  const _Members({required this.group, required this.currentUserId});

  final ConversationModel group;
  final int currentUserId;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final List<ParticipantModel> members = [
      // The signed-in user first, labelled, so the list reads as "me and
      // these others" rather than hiding them somewhere in the middle.
      ...group.participants.where((p) => p.userId == currentUserId),
      ...group.participants.where((p) => p.userId != currentUserId),
    ];

    // Material for the same reason as [_Actions]: the member rows are
    // ListTiles and need it to ink against.
    return Material(
      color: LightColor.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingX16,
                vertical: AppDimens.paddingX8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${StringConstants.participants} · ${members.length}',
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    StringConstants.groupMembersSectionHint,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            for (final participant in members)
              _MemberRow(
                participant: participant,
                isSelf: participant.userId == currentUserId,
                conversationId: group.id,
                locked: group.isSuperadminCreatedGroup,
              ),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.participant,
    required this.isSelf,
    required this.conversationId,
    this.locked = false,
  });

  final ParticipantModel participant;
  final bool isSelf;
  final int conversationId;

  /// A superadmin's group: who is in it, and who may speak, is not the
  /// members' call, so the row offers no overflow menu to block anyone from.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final String name = groupDisplayName(participant);
    final String subtitle = participant.email.trim().isNotEmpty
        ? participant.email.trim()
        : participant.role.trim();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX16,
        vertical: AppDimens.paddingX4,
      ),
      leading: GroupMemberAvatar(participant: participant),
      title: Row(
        children: [
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isSelf) ...[
            const SizedBox(width: AppDimens.paddingX6),
            Text(
              '(${StringConstants.you})',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
          ],
          if (participant.isBlocked) ...[
            const SizedBox(width: AppDimens.paddingX6),
            Text(
              StringConstants.blocked,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.redColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
      onTap: isSelf || participant.userId <= 0
          ? null
          : () => openUserProfilePage(
              context: context,
              userId: participant.userId,
              fallbackName: name,
              fallbackImageUrl: participant.avatarUrl,
              isOnline: participant.isOnline,
            ),
      trailing: isSelf || locked || participant.userId <= 0
          ? null
          : PopupMenuButton<bool>(
              tooltip: StringConstants.moreOptions,
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onSelected: (_) => context.read<MessageBloc>().add(
                SetParticipantBlockedEvent(
                  conversationId: conversationId,
                  userId: participant.userId,
                  blocked: !participant.isBlocked,
                ),
              ),
              itemBuilder: (_) => [
                PopupMenuItem<bool>(
                  value: true,
                  child: Text(
                    participant.isBlocked
                        ? StringConstants.unblock
                        : StringConstants.block,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Asks for a new group name, returning it trimmed, or null when the user
/// backed out or did not change anything.
///
/// A bottom sheet rather than an `AlertDialog`: the app asks for input this way
/// everywhere else, it rides the keyboard instead of fighting it, and the
/// dialog form tripped the framework's `!semantics.parentDataDirty` assertion —
/// `CustomButton` builds through a `LayoutBuilder`, which `AlertDialog.actions`
/// lays out in an `OverflowBar`.
Future<String?> showChangeGroupNameDialog({
  required BuildContext context,
  required String currentTitle,
}) => showAppBottomSheet<String>(
  context: context,
  builder: (_) => _ChangeGroupNameSheet(currentTitle: currentTitle),
);

class _ChangeGroupNameSheet extends StatefulWidget {
  const _ChangeGroupNameSheet({required this.currentTitle});

  final String currentTitle;

  @override
  State<_ChangeGroupNameSheet> createState() => _ChangeGroupNameSheetState();
}

class _ChangeGroupNameSheetState extends State<_ChangeGroupNameSheet> {
  late final TextEditingController _title = TextEditingController(
    text: widget.currentTitle,
  );

  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _submit() {
    final String title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = StringConstants.enterAGroupName);
      return;
    }
    if (title.length > 255) {
      setState(() => _error = StringConstants.groupNameTooLong);
      return;
    }
    // Unchanged is not worth a request; close as if nothing was asked.
    Navigator.of(
      context,
    ).pop(title == widget.currentTitle.trim() ? null : title);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          StringConstants.changeGroupName,
          style: textTheme.bodyTextLarge?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimens.paddingX16),
        CustomTextField(
          controller: _title,
          labelText: StringConstants.groupName,
          hintText: StringConstants.eGWeekendFutsalTeam,
          icon: Icons.groups_2_outlined,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _submit(),
        ),
        if (_error case final message?) ...[
          const SizedBox(height: AppDimens.paddingX8),
          Text(
            message,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.redColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: AppDimens.paddingX16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: StringConstants.cancel,
                isOutlined: true,
                minHeight: AppDimens.sizeX46,
                borderRadius: AppDimens.radiusX12,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              child: CustomButton(
                text: StringConstants.save,
                icon: Icons.check_rounded,
                minHeight: AppDimens.sizeX46,
                borderRadius: AppDimens.radiusX12,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
