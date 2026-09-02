// ─────────────────────────────────────────────────────────────
// CustomHeaderWidget — height-driven layout
// ─────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class CustomHeaderWidget extends StatelessWidget {
  final double height;

  final String name;
  final String location;
  final String avatarUrl;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onChangeImageTap;

  const CustomHeaderWidget({
    super.key,
    this.height = 230,
    required this.name,
    required this.location,
    required this.avatarUrl,
    this.onBackTap,
    this.onSettingsTap,
    this.onChangeImageTap,
  });

  // ── Derived scale helpers ──────────────────────────────────
  double get _scale => (height / 230).clamp(0.75, 1.6);

  double get _avatarOuter => 84 * _scale;
  double get _avatarInner => 76 * _scale;
  double get _nameFontSize => (21 * _scale).clamp(14, 28);
  double get _locationFontSize => (12.5 * _scale).clamp(10, 16);
  double get _iconSize => (17 * _scale).clamp(13, 22);
  double get _onlineDotSize => (14 * _scale).clamp(10, 18);
  double get _horizontalPad => (20 * _scale).clamp(14, 28);
  double get _verticalPad => (16 * _scale).clamp(10, 24);
  double get _topSpacing => (12 * _scale).clamp(6, 20);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: LightColor.secondaryColor.withValues(alpha: 0.28),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          // ── Only this value drives the height ──
          height: height,
          child: Stack(
            children: [
              // ── Base gradient ──────────────────
              _baseGradient(),

              // ── Shimmer overlay ────────────────
              _shimmerOverlay(),

              // ── Decorative blobs ───────────────
              _blobLayer(),

              // ── Teal accent circle ─────────────
              _accentCircle(),

              // ── Foreground content ─────────────
              _content(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Layers ──────────────────────────────────────────────────

  Widget _baseGradient() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          LightColor.secondaryColor,
          LightColor.primaryDark,
          LightColor.secondaryColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );

  Widget _shimmerOverlay() => Positioned.fill(
    child: Opacity(
      opacity: 0.12,
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.6, -0.5),
            radius: 1.2,
            colors: [LightColor.onBrandSurface, Colors.transparent],
          ),
        ),
      ),
    ),
  );

  Widget _blobLayer() => Stack(
    children: [
      Positioned(
        right: -30,
        top: -25,
        child: _blob(
          170 * _scale,
          170 * _scale,
          LightColor.primarySoft.withValues(alpha: 0.45),
        ),
      ),
      Positioned(
        right: 30,
        bottom: -(45 * _scale),
        child: _blob(
          190 * _scale,
          150 * _scale,
          LightColor.secondarySoft.withValues(alpha: 0.4),
        ),
      ),
      Positioned(
        left: 70,
        bottom: -(55 * _scale),
        child: _blob(
          200 * _scale,
          200 * _scale,
          LightColor.secondaryColor.withValues(alpha: 0.2),
        ),
      ),
    ],
  );

  Widget _accentCircle() => Positioned(
    left: -20,
    top: -20,
    child: Container(
      width: 110 * _scale,
      height: 110 * _scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LightColor.secondaryColor.withValues(alpha: 0.18),
      ),
    ),
  );

  Widget _content(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: _horizontalPad,
      vertical: _verticalPad,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top row: back + settings ──────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox.shrink(),
            Row(
              children: [
                _headerIcon(
                  Icons.arrow_back_ios_new_rounded,
                  size: _iconSize,
                  onTap: onBackTap ?? () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 10),
                _headerIcon(
                  Icons.tune_rounded,
                  size: _iconSize,
                  onTap: onSettingsTap,
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: _topSpacing),

        // ── Avatar + name ─────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _avatar(),
            SizedBox(width: 14 * _scale),
            _nameBlock(),
          ],
        ),

        const Spacer(),

        // ── Change image button ───────────────
        _changeImageButton(),
      ],
    ),
  );

  // ── Sub-widgets ─────────────────────────────────────────────

  Widget _avatar() => Stack(
    alignment: Alignment.center,
    children: [
      // Glow halo
      Container(
        width: _avatarOuter,
        height: _avatarOuter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              LightColor.primarySoft.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
      ),
      // Photo ring
      Container(
        width: _avatarInner,
        height: _avatarInner,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: LightColor.onBrandSurface.withValues(alpha: 0.7),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: LightColor.secondaryColor.withValues(alpha: 0.32),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: CustomImageView(
            url: avatarUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
      // Online dot
      Positioned(
        bottom: (_avatarOuter - _avatarInner) / 2 + 2,
        right: (_avatarOuter - _avatarInner) / 2 + 2,
        child: Container(
          width: _onlineDotSize,
          height: _onlineDotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: LightColor.secondaryColor,
            border: Border.all(color: LightColor.onBrandSurface, width: 2),
          ),
        ),
      ),
    ],
  );

  Widget _nameBlock() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        name,
        style: TextStyle(
          color: LightColor.onBrandSurface,
          fontSize: _nameFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
      SizedBox(height: 5 * _scale),
      // Location pill
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10 * _scale,
          vertical: 4 * _scale,
        ),
        decoration: BoxDecoration(
          color: LightColor.onBrandSurface.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: LightColor.onBrandSurface.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.email_outlined,
              color: LightColor.onBrandSurface.withValues(alpha: 0.7),
              size: _locationFontSize + 1,
            ),
            SizedBox(width: 4 * _scale),
            Text(
              location,
              style: TextStyle(
                color: LightColor.onBrandSurface.withValues(alpha: 0.9),
                fontSize: _locationFontSize,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _changeImageButton() => GestureDetector(
    onTap: onChangeImageTap,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * _scale,
        vertical: 6 * _scale,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LightColor.onBrandSurface.withValues(alpha: 0.22),
            LightColor.onBrandSurface.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: LightColor.onBrandSurface.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: LightColor.shadowOf(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: LightColor.onBrandSurface,
            size: _iconSize,
          ),
          SizedBox(width: 6 * _scale),
          Text(
            StringConstants.changeImage,
            style: TextStyle(
              color: LightColor.onBrandSurface,
              fontSize: (11 * _scale).clamp(9, 14),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    ),
  );

  // ── Helpers ─────────────────────────────────────────────────

  Widget _blob(double w, double h, Color color) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(w * 0.65),
        topRight: Radius.circular(w * 0.28),
        bottomLeft: Radius.circular(w * 0.42),
        bottomRight: Radius.circular(w * 0.72),
      ),
    ),
  );

  Widget _headerIcon(IconData icon, {double? size, VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(7 * _scale),
          decoration: BoxDecoration(
            color: LightColor.onBrandSurface.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: LightColor.onBrandSurface.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: LightColor.onBrandSurface,
            size: size ?? _iconSize,
          ),
        ),
      );
}
