import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';
import 'package:hamro_footsall/features/account/presentation/utils/account_ui_utils.dart';

/// Gradient hero card: the balance Hamro Futsal currently owes the vendor,
/// with pending clearance + commission rate and the settlement CTA. When the
/// CTA is disabled, [disabledReason] explains why right below it.
class AccountBalanceCard extends StatelessWidget {
  const AccountBalanceCard({
    super.key,
    required this.availableBalance,
    required this.pendingClearance,
    this.onRequestSettlement,
    this.disabledReason,
  });

  final int availableBalance;
  final int pendingClearance;

  /// Null renders the CTA disabled.
  final VoidCallback? onRequestSettlement;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LightColor.secondaryColor, LightColor.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        boxShadow: [
          BoxShadow(
            color: LightColor.secondaryColor.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: AppDimens.sizeX16,
                color: LightColor.whiteColor.withValues(alpha: 0.85),
              ),
              const SizedBox(width: AppDimens.paddingX6),
              Text(
                StringConstants.availableBalance,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.whiteColor.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Text(
            AccountFmt.npr(availableBalance),
            style: textTheme.headingLarge?.copyWith(
              color: LightColor.whiteColor,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (pendingClearance > 0) ...[
            const SizedBox(height: AppDimens.paddingX6),
            Row(
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 12,
                  color: LightColor.whiteColor.withValues(alpha: 0.7),
                ),
                const SizedBox(width: AppDimens.paddingX4),
                Text(
                  '${AccountFmt.npr(pendingClearance)} ${StringConstants.pendingClearance.toLowerCase()}',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.whiteColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppDimens.paddingX16),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: onRequestSettlement != null
                  ? LightColor.whiteColor
                  : LightColor.whiteColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              child: InkWell(
                onTap: onRequestSettlement,
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                child: Container(
                  height: AppDimens.sizeX40,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_balance_rounded,
                        size: AppDimens.sizeX16,
                        color: LightColor.secondaryColor,
                      ),
                      const SizedBox(width: AppDimens.paddingX6),
                      Text(
                        StringConstants.requestSettlement,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (onRequestSettlement == null &&
              (disabledReason?.isNotEmpty ?? false)) ...[
            const SizedBox(height: AppDimens.paddingX8),
            Text(
              disabledReason!,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.whiteColor.withValues(alpha: 0.75),
                fontSize: AppDimens.fontBodySubTitle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Lifetime totals under the hero card: earned / commission / settled.
class AccountStatsRow extends StatelessWidget {
  const AccountStatsRow({super.key, required this.summary});

  final AccountSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: StringConstants.totalEarned,
            value: AccountFmt.npr(summary.totalEarned),
            icon: Icons.trending_up_rounded,
            color: LightColor.secondaryColor,
          ),
        ),
        const SizedBox(width: AppDimens.paddingX8),
        Expanded(
          child: _StatTile(
            label: StringConstants.commissionPaid,
            value: AccountFmt.npr(summary.totalCommission),
            icon: Icons.percent_rounded,
            color: LightColor.purpleColor,
          ),
        ),
        const SizedBox(width: AppDimens.paddingX8),
        Expanded(
          child: _StatTile(
            label: StringConstants.totalSettled,
            value: AccountFmt.npr(summary.totalSettled),
            icon: Icons.account_balance_rounded,
            color: LightColor.blueColor,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppDimens.sizeX16, color: color),
          const SizedBox(height: AppDimens.paddingX8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chevron navigation row used in the main screen's shortcuts card
/// (futsal breakdown, payout method, settlements).
class AccountNavTile extends StatelessWidget {
  const AccountNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle = '',
    this.iconColor = LightColor.secondaryColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX14,
            vertical: AppDimens.paddingX12,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: LightColor.iconGrey,
                size: AppDimens.sizeX20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One ledger row: typed icon, title/date, signed amount.
class AccountEntryTile extends StatelessWidget {
  const AccountEntryTile({super.key, required this.entry});

  final AccountEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final title = entry.title.isNotEmpty
        ? entry.title
        : entry.type.fallbackTitle;
    final subtitleParts = [
      if (entry.date != null) AccountFmt.date(entry.date!),
      if (entry.reference.isNotEmpty) entry.reference,
    ];
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: entry.type.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          ),
          child: Icon(entry.type.icon, size: 18, color: entry.type.color),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitleParts.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitleParts.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.hintTextColor,
                    fontSize: AppDimens.fontBodySubTitle,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppDimens.paddingX8),
        Text(
          '${entry.isCredit ? '+' : '-'} ${AccountFmt.npr(entry.amount)}',
          style: textTheme.bodyTextSmall?.copyWith(
            color: entry.isCredit
                ? LightColor.secondaryColor
                : LightColor.redColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// One settlement request row with its status badge and lifecycle dates.
class SettlementTile extends StatelessWidget {
  const SettlementTile({super.key, required this.settlement});

  final SettlementModel settlement;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final status = settlement.status;
    final DateTime? shownDate = settlement.resolvedAt ?? settlement.requestedAt;
    final subtitleParts = [
      if (shownDate != null) AccountFmt.date(shownDate),
      if (settlement.reference.isNotEmpty) settlement.reference,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              ),
              child: Icon(status.icon, size: 18, color: status.color),
            ),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AccountFmt.npr(settlement.amount),
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitleParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimens.paddingX8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingX8,
                vertical: AppDimens.paddingX4,
              ),
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusX20),
              ),
              child: Text(
                status.label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: status.color,
                  fontSize: AppDimens.fontBodySubTitle,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (status == SettlementStatus.rejected &&
            settlement.rejectedReason.isNotEmpty) ...[
          const SizedBox(height: AppDimens.paddingX8),
          Padding(
            padding: const EdgeInsets.only(left: 40 + AppDimens.paddingX12),
            child: Text(
              settlement.rejectedReason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.redColor,
                fontSize: AppDimens.fontBodySubTitle,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Shared empty placeholder for the statement / settlements lists.
class AccountEmptyState extends StatelessWidget {
  const AccountEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX32,
        vertical: AppDimens.paddingX40,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: LightColor.secondaryColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppDimens.paddingX14),
          Text(
            title,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
