import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/rewards/data/model/rewards_model.dart';
import 'package:hamro_footsall/features/rewards/presentation/utils/rewards_ui.dart';

/// The reward balance hero: gradient card with the point balance, tier badge,
/// progress towards the next coupon and the redeem action.
///
/// Used on the rewards page and, in [compact] form, as the profile section.
class RewardBalanceCard extends StatelessWidget {
  const RewardBalanceCard({
    super.key,
    required this.summary,
    this.onRedeem,
    this.onTap,
    this.isRedeeming = false,
    this.compact = false,
  });

  final RewardsSummaryModel summary;

  /// Null hides the redeem button (e.g. the compact profile card, which taps
  /// through to the rewards page instead).
  final VoidCallback? onRedeem;

  /// Tapping anywhere on the card; used by the compact profile variant.
  final VoidCallback? onTap;

  final bool isRedeeming;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            LightColor.secondaryColor,
            LightColor.secondaryDark,
            LightColor.primaryDark,
          ],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x332C7969),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        child: Stack(
          children: <Widget>[
            // Soft light blooms, so the flat gradient reads as a card with depth.
            const Positioned(right: -30, top: -40, child: _Bloom(size: 150)),
            const Positioned(left: -40, bottom: -60, child: _Bloom(size: 130)),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(
                    compact ? AppDimens.paddingX16 : AppDimens.paddingX20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const _CardIcon(),
                          const SizedBox(width: AppDimens.paddingX10),
                          Expanded(
                            child: Text(
                              StringConstants.availablePoints,
                              style: textTheme.bodyTextSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          if (summary.tier.isNotEmpty)
                            _TierBadge(tier: summary.tier),
                          if (onTap != null && summary.tier.isEmpty)
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: AppDimens.sizeX20,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.paddingX12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            RewardFmt.points(summary.availablePoints),
                            style:
                                (compact
                                        ? textTheme.headingSmall
                                        : textTheme.headingMedium)
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      height: 1.05,
                                    ),
                          ),
                          const SizedBox(width: AppDimens.paddingX6),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimens.paddingX2,
                            ),
                            child: Text(
                              StringConstants.rewardPoints.toLowerCase(),
                              style: textTheme.bodyTextSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.paddingX12),
                      _RedeemProgress(summary: summary),
                      if (onRedeem != null) ...<Widget>[
                        const SizedBox(height: AppDimens.paddingX16),
                        _RedeemButton(
                          enabled: summary.canRedeem && !isRedeeming,
                          isLoading: isRedeeming,
                          onPressed: onRedeem!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bloom extends StatelessWidget {
  const _Bloom({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.07),
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.sizeX28,
      height: AppDimens.sizeX28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.workspace_premium_rounded,
        color: LightColor.whiteColor,
        size: AppDimens.sizeX18,
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final String tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX10,
        vertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: LightColor.yellowColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        tier.toUpperCase(),
        style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Progress meter towards the next coupon, plus the "N more points" hint.
class _RedeemProgress extends StatelessWidget {
  const _RedeemProgress({required this.summary});

  final RewardsSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final int missing = summary.pointsToNextCoupon;

    final String caption;
    if (summary.pointsPerCoupon <= 0) {
      caption = summary.hasPoints
          ? StringConstants.rewardCouponReady
          : StringConstants.noRewardPointsYetMessage;
    } else if (missing == 0) {
      final String value = summary.couponValue > 0
          ? ' worth ${RewardFmt.money(summary.couponValue, currency: summary.currency)}'
          : '';
      caption =
          'You can redeem ${RewardFmt.points(summary.pointsPerCoupon)} points '
          'for a coupon$value.';
    } else {
      caption =
          '${RewardFmt.points(missing)} more points for your next coupon.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          child: LinearProgressIndicator(
            value: summary.progressToNextCoupon,
            minHeight: AppDimens.sizeX6,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            valueColor: const AlwaysStoppedAnimation<Color>(
              LightColor.yellowColor,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.paddingX8),
        Text(
          caption,
          style: textTheme.bodyTextSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _RedeemButton extends StatelessWidget {
  const _RedeemButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return SizedBox(
      width: double.infinity,
      height: AppDimens.sizeX46,
      child: Material(
        color: enabled
            ? LightColor.whiteColor
            : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: AppDimens.sizeX20,
                    height: AppDimens.sizeX20,
                    child: CustomLoading(
                      color: LightColor.secondaryColor,
                      size: AppDimens.sizeX20,
                      strokeWidth: 2.5,
                      secondCircleColor: LightColor.secondaryLight,
                      thirdCircleColor: LightColor.secondaryLightMedium,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.confirmation_num_outlined,
                        size: AppDimens.sizeX18,
                        color: enabled
                            ? LightColor.secondaryColor
                            : Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: AppDimens.paddingX8),
                      Text(
                        enabled
                            ? StringConstants.generateCoupon
                            : StringConstants.needMorePointsToRedeem,
                        style: textTheme.bodyTextMedium?.copyWith(
                          color: enabled
                              ? LightColor.secondaryColor
                              : Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Lifetime earned / redeemed / expiring tiles under the hero card.
class RewardStatsRow extends StatelessWidget {
  const RewardStatsRow({super.key, required this.summary});

  final RewardsSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tiles = <Widget>[
      _RewardStatTile(
        icon: Icons.trending_up_rounded,
        color: LightColor.secondaryColor,
        label: StringConstants.pointsEarned,
        value: RewardFmt.points(summary.totalEarnedPoints),
      ),
      _RewardStatTile(
        icon: Icons.local_activity_outlined,
        color: LightColor.purpleColor,
        label: StringConstants.pointsRedeemed,
        value: RewardFmt.points(summary.totalRedeemedPoints),
      ),
      if (summary.redeemableCoupons > 0)
        _RewardStatTile(
          icon: Icons.card_giftcard_rounded,
          color: LightColor.yellowColor,
          label: 'Coupons available',
          value: summary.redeemableCoupons.toString(),
        ),
    ];

    return Row(
      children: <Widget>[
        for (int i = 0; i < tiles.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: AppDimens.paddingX10),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

class _RewardStatTile extends StatelessWidget {
  const _RewardStatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: AppDimens.sizeX28,
            height: AppDimens.sizeX28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: AppDimens.sizeX16),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextLarge?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Warning strip for points that lapse soon; renders nothing when the server
/// does not report an expiry.
class RewardExpiryNotice extends StatelessWidget {
  const RewardExpiryNotice({super.key, required this.summary});

  final RewardsSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final DateTime? expiresAt = summary.expiresAt;
    if (expiresAt == null || summary.expiringPoints <= 0) {
      return const SizedBox.shrink();
    }

    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.warningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: LightColor.warningColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.schedule_rounded,
            color: LightColor.warningColor,
            size: AppDimens.sizeX18,
          ),
          const SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: Text(
              '${RewardFmt.points(summary.expiringPoints)} '
              '${StringConstants.rewardPointsExpiring} '
              '${RewardFmt.date(expiresAt)}',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.primaryTextColor,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One reward history row.
class RewardHistoryTile extends StatelessWidget {
  const RewardHistoryTile({super.key, required this.entry});

  final RewardHistoryEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final Color accent = entry.type.color;

    final String title = entry.title.isNotEmpty
        ? entry.title
        : entry.type.fallbackTitle;

    // The densest useful detail line, in priority order.
    final List<String> details = <String>[
      if (entry.description.isNotEmpty) entry.description,
      if (entry.couponCode.isNotEmpty) 'Coupon ${entry.couponCode}',
      if (entry.reference.isNotEmpty) 'Ref ${entry.reference}',
    ];
    final String? subtitle = details.isEmpty ? null : details.first;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX14,
        vertical: AppDimens.paddingX12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: AppDimens.sizeX36,
            height: AppDimens.sizeX36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            alignment: Alignment.center,
            child: Icon(entry.type.icon, color: accent, size: 18),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: AppDimens.paddingX2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                ],
                if (entry.createdAt != null) ...<Widget>[
                  const SizedBox(height: AppDimens.paddingX4),
                  Text(
                    RewardFmt.dateTime(entry.createdAt!),
                    style: textTheme.bodySubTitle?.copyWith(
                      color: LightColor.hintTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppDimens.paddingX8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                entry.signedPoints,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: entry.isCredit ? LightColor.secondaryColor : accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (entry.balanceAfter != null)
                Text(
                  'Bal ${RewardFmt.points(entry.balanceAfter!)}',
                  style: textTheme.bodySubTitle?.copyWith(
                    color: LightColor.hintTextColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card wrapper that draws [entries] as a divided list.
class RewardHistoryCard extends StatelessWidget {
  const RewardHistoryCard({super.key, required this.entries});

  final List<RewardHistoryEntryModel> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < entries.length; i++) ...<Widget>[
            RewardHistoryTile(entry: entries[i]),
            if (i != entries.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: AppDimens.paddingX50),
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: LightColor.dividerColor,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Section header with an optional trailing action.
class RewardSectionHeader extends StatelessWidget {
  const RewardSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingX4),
              child: Row(
                children: <Widget>[
                  Text(
                    actionLabel!,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: LightColor.secondaryColor,
                    size: AppDimens.sizeX18,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// How points are earned and spent — shown under the balance so the programme
/// explains itself without a separate help page.
class RewardHowItWorksCard extends StatelessWidget {
  const RewardHowItWorksCard({super.key, required this.summary});

  final RewardsSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);

    final List<(IconData, String)> rows = <(IconData, String)>[
      (
        Icons.sports_soccer_rounded,
        summary.note.isNotEmpty
            ? summary.note
            : StringConstants.rewardProgrammeNote,
      ),
      if (summary.pointsPerCoupon > 0)
        (
          Icons.swap_horiz_rounded,
          '${RewardFmt.points(summary.pointsPerCoupon)} points'
              '${summary.couponValue > 0 ? ' = ${RewardFmt.money(summary.couponValue, currency: summary.currency)} coupon' : ' = 1 discount coupon'}.',
        ),
      (
        Icons.receipt_long_rounded,
        'Apply the generated coupon code at checkout to use your discount.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'How it works',
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: AppDimens.paddingX10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  rows[i].$1,
                  size: AppDimens.sizeX16,
                  color: LightColor.secondaryColor,
                ),
                const SizedBox(width: AppDimens.paddingX10),
                Expanded(
                  child: Text(
                    rows[i].$2,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
