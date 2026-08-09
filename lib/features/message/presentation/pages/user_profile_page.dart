import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/features/message/data/model/message_profile_model.dart';
import 'package:hamro_footsall/features/message/presentation/bloc/message_bloc/message_bloc.dart';

/// Pushes the view-only profile of another chat participant.
///
/// Reuses the caller's [MessageBloc] (the chat page's, which stays alive below
/// this route) so the profile request rides the feature's existing bloc rather
/// than spinning up a second one.
Future<void> openUserProfilePage({
  required BuildContext context,
  required int userId,
  String fallbackName = '',
  String fallbackImageUrl = '',
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
        ),
      ),
    ),
  );

  if (!bloc.isClosed) bloc.add(const ClearMessageProfileEvent());
}

/// Read-only profile of another user: a full-width image banner, then the
/// name, address and gender. Nothing here is editable.
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    super.key,
    required this.userId,
    this.fallbackName = '',
    this.fallbackImageUrl = '',
  });

  final int userId;

  /// Shown until the request lands, so the page is never blank.
  final String fallbackName;
  final String fallbackImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.profile),
      body: BlocBuilder<MessageBloc, MessageState>(
        buildWhen: (previous, current) =>
            previous.profileStatus != current.profileStatus ||
            previous.profile != current.profile,
        builder: (context, state) {
          final MessageProfileModel? profile = state.profile;
          final name = (profile?.name.isNotEmpty ?? false)
              ? profile!.name
              : fallbackName;
          final imageUrl = (profile?.imageUrl.isNotEmpty ?? false)
              ? profile!.imageUrl
              : fallbackImageUrl;
          final loading = state.profileStatus == MessageStatus.loading;

          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppDimens.paddingX24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimens.formContentMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileBanner(imageUrl: imageUrl, name: name),
                      const SizedBox(height: AppDimens.paddingX20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingX16,
                        ),
                        child: state.profileStatus == MessageStatus.failure
                            ? _ProfileError(
                                message:
                                    state.profileErrorMessage ??
                                    StringConstants.tryAgain,
                                onRetry: () => context.read<MessageBloc>().add(
                                  LoadMessageProfileEvent(userId),
                                ),
                              )
                            : _ProfileDetailsCard(
                                name: name,
                                address: profile?.address ?? '',
                                gender: profile?.genderLabel ?? '',
                                loading: loading,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Full-width rectangular image across the top of the page. Keeps a fixed 4:3
/// box so the layout doesn't jump between the placeholder and the loaded photo,
/// and crops with [BoxFit.cover] so portrait and landscape uploads both fill it.
class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner({required this.imageUrl, required this.name});

  final String imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX16,
        AppDimens.paddingX8,
        AppDimens.paddingX16,
        0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX18),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
            ),
            child: imageUrl.isEmpty
                ? Center(
                    child: Text(
                      name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                      style: textTheme.headingLarge?.copyWith(
                        color: LightColor.secondaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                // No width/height and no alignment: the tight AspectRatio box
                // constrains the image so `cover` fills the rectangle. Passing
                // an alignment here would wrap it in an Align that loosens
                // those constraints and the image would size to its intrinsics.
                : CustomImageView(url: imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  const _ProfileDetailsCard({
    required this.name,
    required this.address,
    required this.gender,
    required this.loading,
  });

  final String name;
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
        boxShadow: [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: AppDimens.radiusX16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            name.isEmpty ? StringConstants.notProvided : name,
            style: textTheme.headingSubTitle?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
            child: Divider(height: 1, color: LightColor.dividerColor),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimens.paddingX18),
              child: Center(
                child: SizedBox(
                  width: AppDimens.sizeX22,
                  height: AppDimens.sizeX22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: LightColor.secondaryColor,
                  ),
                ),
              ),
            )
          else ...[
            _ProfileRow(
              icon: Icons.location_on_outlined,
              label: StringConstants.address,
              value: address,
            ),
            const SizedBox(height: AppDimens.paddingX14),
            _ProfileRow(
              icon: Icons.person_outline_rounded,
              label: StringConstants.gender,
              value: gender,
            ),
          ],
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final hasValue = value.trim().isNotEmpty;

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
      ),
      child: Column(
        children: [
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
