import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/data/model/message_profile_model.dart';
import 'package:hamro_footsall/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_footsall/features/message/presentation/pages/chat_launcher.dart';

/// Pushes the view-only profile of another chat participant.
///
/// Reuses the caller's [MessageBloc] (the chat page's, which stays alive below
/// this route) so the profile request rides the feature's existing bloc rather
/// than spinning up a second one.
///
/// [canMessage] adds a Message button that opens a direct chat with this
/// person. Off for the profile reached from a direct chat's own header — that
/// chat is the screen underneath, so the button would lead back where the user
/// already is. [isOnline] paints the presence pill when the caller knows it;
/// the profile endpoint itself carries no presence.
Future<void> openUserProfilePage({
  required BuildContext context,
  required int userId,
  String fallbackName = '',
  String fallbackImageUrl = '',
  bool canMessage = true,
  bool? isOnline,
}) async {
  final bloc = context.read<MessageBloc>();
  bloc.add(LoadMessageProfileEvent(userId));

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: UserProfilePage(
          userId: userId,
          fallbackName: fallbackName,
          fallbackImageUrl: fallbackImageUrl,
          canMessage: canMessage,
          isOnline: isOnline,
        ),
      ),
    ),
  );

  if (!bloc.isClosed) bloc.add(const ClearMessageProfileEvent());
}

/// Read-only profile of another user: a photo that fills the top of the screen
/// with the name written over it, then the details and the way to reach them.
/// Nothing here is editable.
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    super.key,
    required this.userId,
    this.fallbackName = '',
    this.fallbackImageUrl = '',
    this.canMessage = true,
    this.isOnline,
  });

  final int userId;

  /// Shown until the request lands, so the page is never blank.
  final String fallbackName;
  final String fallbackImageUrl;

  /// Whether to offer a chat with this person — see [openUserProfilePage].
  final bool canMessage;

  /// Presence as the caller knows it; null hides the pill entirely rather than
  /// claiming the person is offline.
  final bool? isOnline;

  /// A direct thread with this user that the inbox already holds, if any.
  ///
  /// Opening that one keeps the conversation whole; asking the server to start
  /// a direct chat again would hand back a second thread beside it.
  ConversationModel? _existingDirect(MessageState state) {
    for (final ConversationModel conversation in state.conversations) {
      if (conversation.isGroup) continue;
      final bool withThisUser = conversation.participants.any(
        (participant) => participant.userId == userId,
      );
      if (withThisUser) return conversation;
    }
    return null;
  }

  Future<void> _message(BuildContext context, MessageState state) async {
    final ConversationModel? existing = _existingDirect(state);
    if (existing != null) {
      await ChatLauncher.openConversation(
        context,
        conversationId: existing.id,
      );
      return;
    }
    await ChatLauncher.startDirectUser(context, userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      body: BlocBuilder<MessageBloc, MessageState>(
        buildWhen: (previous, current) =>
            previous.profileStatus != current.profileStatus ||
            previous.profile != current.profile ||
            previous.conversations != current.conversations ||
            previous.currentUserId != current.currentUserId,
        builder: (context, state) {
          final MessageProfileModel? profile = state.profile;
          final String name = (profile?.name.isNotEmpty ?? false)
              ? profile!.name
              : fallbackName;
          final String imageUrl = (profile?.imageUrl.isNotEmpty ?? false)
              ? profile!.imageUrl
              : fallbackImageUrl;
          final bool loading = state.profileStatus == MessageStatus.loading;
          final bool failed = state.profileStatus == MessageStatus.failure;
          final bool showMessage =
              canMessage && userId > 0 && userId != state.currentUserId;

          return CustomScrollView(
            slivers: [
              _ProfileHero(
                name: name,
                imageUrl: imageUrl,
                isOnline: isOnline,
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppDimens.formContentMaxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.paddingX16,
                        AppDimens.paddingX18,
                        AppDimens.paddingX16,
                        AppDimens.paddingX24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showMessage) ...[
                            CustomButton(
                              text: StringConstants.message,
                              icon: Icons.chat_bubble_outline_rounded,
                              minHeight: AppDimens.sizeX46,
                              borderRadius: AppDimens.radiusX12,
                              onPressed: () => _message(context, state),
                            ),
                            const SizedBox(height: AppDimens.paddingX16),
                          ],
                          if (failed)
                            _ProfileError(
                              message:
                                  state.profileErrorMessage ??
                                  StringConstants.tryAgain,
                              onRetry: () => context.read<MessageBloc>().add(
                                LoadMessageProfileEvent(userId),
                              ),
                            )
                          else
                            _AboutCard(
                              address: profile?.address ?? '',
                              gender: profile?.genderLabel ?? '',
                              loading: loading,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The photo as the top of the screen rather than a card inside it: it
/// collapses into a plain app bar as the page scrolls, so the name stays
/// legible the whole way down.
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.imageUrl,
    required this.isOnline,
  });

  final String name;
  final String imageUrl;
  final bool? isOnline;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final double height = (MediaQuery.sizeOf(context).height * 0.42).clamp(
      260.0,
      380.0,
    );

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: height,
      backgroundColor: LightColor.cardColor,
      surfaceTintColor: LightColor.transparentColor,
      elevation: 0,
      // The collapsed bar sits on the card colour, the expanded one on the
      // photo — so the back button and title take a light-on-dark treatment
      // only while the photo is behind them.
      leading: const _HeroBackButton(),
      title: Text(
        name.isEmpty ? StringConstants.profile : name,
        style: textTheme.bodyTextMedium?.copyWith(
          color: LightColor.primaryTextColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isEmpty)
              _MonogramBackdrop(name: name)
            else
              // No width/height and no alignment: the Stack constrains the
              // image tightly so `cover` fills it. An alignment here would
              // loosen those constraints and the image would size to its
              // intrinsics instead.
              CustomImageView(url: imageUrl, fit: BoxFit.cover),
            // Scrim: the name below has to stay readable over a photo of any
            // brightness.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x14000000),
                    Color(0xB3000000),
                  ],
                  stops: [0.35, 0.6, 1],
                ),
              ),
            ),
            Positioned(
              left: AppDimens.paddingX20,
              right: AppDimens.paddingX20,
              bottom: AppDimens.paddingX20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name.isEmpty ? StringConstants.unknownUser : name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headingSubTitle?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isOnline case final online?) ...[
                    const SizedBox(height: AppDimens.paddingX8),
                    _PresencePill(isOnline: online),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A back button that reads over both a photo and the collapsed bar.
class _HeroBackButton extends StatelessWidget {
  const _HeroBackButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.black.withValues(alpha: 0.28),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).pop(),
          child: const SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Stands in for a photo nobody uploaded: the initial over a tinted wash,
/// rather than an empty grey rectangle.
class _MonogramBackdrop extends StatelessWidget {
  const _MonogramBackdrop({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LightColor.secondaryColor.withValues(alpha: 0.22),
            LightColor.secondaryColor.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: Center(
        child: Text(
          name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase(),
          style: textTheme.headingLarge?.copyWith(
            fontSize: 72,
            color: LightColor.secondaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PresencePill extends StatelessWidget {
  const _PresencePill({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color color = isOnline
        ? LightColor.successColor
        : LightColor.iconGrey;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? StringConstants.online : StringConstants.offline,
            style: textTheme.bodyTextSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The details the endpoint carries. Loading shows the same rows as skeletons
/// so the card keeps its shape instead of collapsing to a spinner.
class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.address,
    required this.gender,
    required this.loading,
  });

  final String address;
  final String gender;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX18),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: AppDimens.radiusX16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            StringConstants.about,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX16),
          _ProfileRow(
            icon: Icons.location_on_outlined,
            label: StringConstants.address,
            value: address,
            loading: loading,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimens.paddingX14,
            ),
            child: Divider(height: 1, color: LightColor.dividerColor),
          ),
          _ProfileRow(
            icon: Icons.person_outline_rounded,
            label: StringConstants.gender,
            value: gender,
            loading: loading,
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool hasValue = value.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppDimens.sizeX38,
          height: AppDimens.sizeX38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
          child: Icon(icon, size: 18, color: LightColor.secondaryColor),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.hintTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX2),
              if (loading)
                const _SkeletonBar()
              else
                Text(
                  hasValue ? value.trim() : StringConstants.notProvided,
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: hasValue
                        ? LightColor.primaryTextColor
                        : LightColor.hintTextColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A single pulsing bar where a value will land.
class _SkeletonBar extends StatefulWidget {
  const _SkeletonBar();

  @override
  State<_SkeletonBar> createState() => _SkeletonBarState();
}

class _SkeletonBarState extends State<_SkeletonBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.9).animate(_controller),
      child: Container(
        height: 14,
        margin: const EdgeInsets.only(top: 3, right: AppDimens.paddingX40),
        decoration: BoxDecoration(
          color: LightColor.dividerColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX18),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 28,
            color: LightColor.hintTextColor,
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          TextButton(
            onPressed: onRetry,
            child: const Text(StringConstants.retry),
          ),
        ],
      ),
    );
  }
}
