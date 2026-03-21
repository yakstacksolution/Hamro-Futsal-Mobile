import 'package:flutter/material.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/header_componet_widget.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/profile_header_background.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String location;
  final String avatarUrl;
  final VoidCallback? onBackTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onChangeImageTap;
  final Object? heroTag;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.location,
    required this.avatarUrl,
    this.onBackTap,
    this.onShareTap,
    this.onSettingsTap,
    this.onChangeImageTap,
    this.heroTag = kProfileHeaderSurfaceHeroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ProfileHeaderBackground(
        height: 230,
        heroTag: heroTag,
        child: HeaderComponetWidget(
          name: name,
          location: location,
          avatarUrl: avatarUrl,
          onBackTap: onBackTap,
          onSettingsTap: onSettingsTap,
          onChangeImageTap: onChangeImageTap,
        ),
      ),
    );
  }
}
