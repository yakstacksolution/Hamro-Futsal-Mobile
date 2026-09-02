import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/payment_qr_model.dart';
import 'package:hamro_futsal/features/account/presentation/utils/account_ui_utils.dart';

/// Gradient hero card: the commission the vendor owes Hamro Futsal, which is
/// what a settlement pays. Earnings and the cleared balance sit underneath as
/// context — they explain where the commission came from, they are not the
/// figure being settled. When the CTA is disabled, [disabledReason] explains
/// why right below it.
class AccountBalanceCard extends StatelessWidget {
  const AccountBalanceCard({
    super.key,
    required this.commissionPayable,
    required this.availableBalance,
    required this.pendingClearance,
    this.totalEarned = 0,
    this.onRequestSettlement,
    this.disabledReason,
  });

  /// The amount a settlement pays — commission retained by the platform.
  final double commissionPayable;
  final double availableBalance;
  final double pendingClearance;
  final double totalEarned;

  /// Null renders the CTA disabled.
  final VoidCallback? onRequestSettlement;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
                Icons.percent_rounded,
                size: AppDimens.sizeX16,
                color: LightColor.onBrandSurface.withValues(alpha: 0.85),
              ),
              const SizedBox(width: AppDimens.paddingX6),
              Text(
                StringConstants.commissionPayable,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.onBrandSurface.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Text(
            AccountFmt.npr(commissionPayable),
            style: textTheme.headingLarge?.copyWith(
              color: LightColor.onBrandSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX6),
          Text(
            // Where the commission came from, kept subordinate to it.
            [
              '${StringConstants.totalEarned} ${AccountFmt.npr(totalEarned)}',
              '${StringConstants.availableBalance} ${AccountFmt.npr(availableBalance)}',
            ].join('  ·  '),
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.onBrandSurface.withValues(alpha: 0.75),
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (pendingClearance > 0) ...[
            const SizedBox(height: AppDimens.paddingX4),
            Row(
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 12,
                  color: LightColor.onBrandSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: AppDimens.paddingX4),
                Text(
                  '${AccountFmt.npr(pendingClearance)} ${StringConstants.pendingClearance.toLowerCase()}',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.onBrandSurface.withValues(alpha: 0.7),
                    fontSize: AppDimens.fontBodySubTitle,
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
                  ? LightColor.onBrandSurface
                  : LightColor.onBrandSurface.withValues(alpha: 0.35),
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
                        Icons.upload_rounded,
                        size: AppDimens.sizeX16,
                        color: LightColor.secondaryColor,
                      ),
                      const SizedBox(width: AppDimens.paddingX6),
                      Text(
                        StringConstants.payCommission,
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
                color: LightColor.onBrandSurface.withValues(alpha: 0.75),
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
            // Commission moved to the hero card; this slot carries the
            // cleared balance the commission was taken out of.
            label: StringConstants.availableBalance,
            value: AccountFmt.npr(summary.availableBalance),
            icon: Icons.account_balance_wallet_rounded,
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
          Icon(
            icon,
            size: AppDimens.sizeX16,
            color: LightColor.categoryAccent(color),
          ),
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
                  color: LightColor.categoryContainer(iconColor),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: LightColor.categoryAccent(iconColor),
                ),
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
              Icon(
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
      if (entry.venueName.isNotEmpty) entry.venueName,
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
                ? LightColor.brandTextColor
                : LightColor.redColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// One settlement request, as an amount-led card.
///
/// The figure is the anchor — it is what the vendor scans the list for — with
/// its caption naming which figure it is, so a pending claim is never read as
/// money already received. Identity (code, venue, timestamp) sits underneath,
/// and the references and the proof link share a footer below a hairline.
///
/// Everything is optional in the payload: a missing venue, reference, proof or
/// timestamp takes its own slot away rather than leaving an empty one, and long
/// values truncate instead of overflowing.
class SettlementCard extends StatelessWidget {
  const SettlementCard({super.key, required this.settlement});

  final SettlementModel settlement;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final SettlementStatus status = settlement.status;
    final String? proofUrl = settlement.proofImageUrl;

    final String amountCaption = switch (status) {
      SettlementStatus.approved => StringConstants.approvedAmount,
      SettlementStatus.paid => StringConstants.paidAmount,
      _ => StringConstants.requestedAmount,
    };

    // Venue-scoped requests name their futsal; a consolidated one says so
    // instead of leaving the line blank.
    final String scopeLabel = settlement.venueName.isNotEmpty
        ? settlement.venueName
        : (settlement.scope.isEmpty
              ? ''
              : (settlement.scope.toLowerCase() == 'venue'
                    ? StringConstants.singleVenue
                    : StringConstants.allVenues));
    final String identityLine = <String>[
      if (settlement.reference.isNotEmpty)
        settlement.reference
      else
        '${StringConstants.settlement} #${settlement.id}',
      if (scopeLabel.isNotEmpty) scopeLabel,
    ].join('  ·  ');
    final DateTime? shownDate = settlement.resolvedAt ?? settlement.requestedAt;

    // One line of references: what the vendor quotes when chasing a payout.
    final String metaLine = <String>[
      if (settlement.transactionReference.isNotEmpty)
        '${StringConstants.txnShort} ${settlement.transactionReference}',
      if (settlement.itemCount > 0)
        '${settlement.itemCount} '
            '${settlement.itemCount == 1 ? 'item' : 'items'}',
    ].join('  ·  ');

    final bool showClearing =
        settlement.pendingClearanceAmount > 0 &&
        (status == SettlementStatus.pending ||
            status == SettlementStatus.processing);
    final bool showFooter = metaLine.isNotEmpty || proofUrl != null;

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      // Six-figure payouts must not clip on a narrow phone.
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        AccountFmt.npr(settlement.amount),
                        style: textTheme.bodyTextLarge?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      amountCaption,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX8),
              _StatusPill(status: status),
            ],
          ),
          if (showClearing) ...[
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              '${AccountFmt.npr(settlement.pendingClearanceAmount)} '
              '${StringConstants.stillClearing}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
                fontSize: AppDimens.fontBodySubTitle,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: AppDimens.paddingX10),
          Text(
            identityLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontSize: AppDimens.fontBodyTextSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (shownDate != null) ...[
            const SizedBox(height: 2),
            Text(
              AccountFmt.dateTime(shownDate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
                fontSize: AppDimens.fontBodySubTitle,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (showFooter) ...[
            const SizedBox(height: AppDimens.paddingX10),
            Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
            const SizedBox(height: AppDimens.paddingX6),
            Row(
              children: [
                Expanded(
                  child: metaLine.isEmpty
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: settlement.transactionReference.isEmpty
                              ? null
                              : () => _copy(
                                  context,
                                  settlement.transactionReference,
                                  StringConstants.transactionReferenceCopied,
                                ),
                          child: Text(
                            metaLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyTextSmall?.copyWith(
                              color: LightColor.secondaryTextColor,
                              fontSize: AppDimens.fontBodySubTitle,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
                if (proofUrl != null) ...[
                  const SizedBox(width: AppDimens.paddingX8),
                  _SettlementProofAction(imageUrl: proofUrl),
                ],
              ],
            ),
          ],
          if (settlement.rejectedReason.isNotEmpty &&
              (status == SettlementStatus.rejected ||
                  status == SettlementStatus.failed ||
                  status == SettlementStatus.cancelled)) ...[
            const SizedBox(height: AppDimens.paddingX8),
            _RejectionBanner(reason: settlement.rejectedReason),
          ],
        ],
      ),
    );
  }

  void _copy(BuildContext context, String value, String message) {
    Clipboard.setData(ClipboardData(text: value));
    AppUtils().showSnackBar(context, MsgType.success, message);
  }
}

/// Status badge — colour and wording come from the parsed status, never from
/// the raw string, so an unknown server status still renders sensibly.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final SettlementStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        border: Border.all(color: status.color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX4),
          Text(
            status.label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: status.color,
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Why a request did not go through, called out rather than buried in the meta.
class _RejectionBanner extends StatelessWidget {
  const _RejectionBanner({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX8,
        vertical: AppDimens.paddingX6,
      ),
      decoration: BoxDecoration(
        color: LightColor.redColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 12,
            color: LightColor.redColor,
          ),
          const SizedBox(width: AppDimens.paddingX6),
          Expanded(
            child: Text(
              reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.redColor,
                fontSize: AppDimens.fontBodySubTitle,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact text action that opens the attached proof full screen.
///
/// Deliberately no inline thumbnail: the list would otherwise pull a full-size
/// receipt per row over the network, and a half-loaded image reads as a broken
/// card. The image is fetched only once the vendor asks to see it.
class _SettlementProofAction extends StatelessWidget {
  const _SettlementProofAction({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return InkWell(
      key: const Key('settlement-proof-action'),
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => SettlementProofViewer(imageUrl: imageUrl),
        ),
      ),
      child: Padding(
        // Keeps the row a comfortable target without adding card height.
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_outlined,
              size: 13,
              color: LightColor.secondaryColor,
            ),
            const SizedBox(width: AppDimens.paddingX4),
            Text(
              StringConstants.viewProof,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryColor,
                fontSize: AppDimens.fontBodySubTitle,
                fontWeight: FontWeight.w700,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: LightColor.secondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen, zoomable view of a settlement's payment proof.
class SettlementProofViewer extends StatelessWidget {
  const SettlementProofViewer({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          StringConstants.paymentProof,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: Center(
                child: CustomImageView(
                  url: imageUrl,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  fit: BoxFit.contain,
                  isHidePlaceholderImage: true,
                ),
              ),
            );
          },
        ),
      ),
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
              color: LightColor.categoryContainer(LightColor.secondaryColor),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: LightColor.brandTextColor.withValues(alpha: 0.7),
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

/// The QR step of the settlement form, as one card.
///
/// Every QR shares the card's chrome — header, amount row, border — and only
/// the code itself slides. Giving each QR its own full card duplicated all of
/// that per slide and forced a fixed slide height with dead space inside it;
/// here the card is exactly as tall as one QR plus its label.
class SettlementQrCarouselCard extends StatefulWidget {
  const SettlementQrCarouselCard({
    super.key,
    required this.codes,
    required this.amountLabel,
    required this.amountValue,
    this.fallbackQr,
    this.fallbackPayeeName = '',
    this.payeePhone = '',
  });

  /// `/auth/qr-codes`, already filtered and ordered by the model.
  final List<SettlementQrCodeModel> codes;

  final String amountLabel;
  final String amountValue;

  /// Used when [codes] is empty — the QR the settlement preview carried.
  final PaymentQrModel? fallbackQr;
  final String fallbackPayeeName;
  final String payeePhone;

  @override
  State<SettlementQrCarouselCard> createState() =>
      _SettlementQrCarouselCardState();
}

class _SettlementQrCarouselCardState extends State<SettlementQrCarouselCard> {
  final PageController _controller = PageController();
  int _index = 0;

  static const double _qrSize = AppDimens.sizeX180;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// One synthetic entry keeps the slider a single code path when the list is
  /// empty — the layout below never has to branch on which source it drew.
  List<SettlementQrCodeModel> get _slides => widget.codes.isNotEmpty
      ? widget.codes
      : <SettlementQrCodeModel>[
          SettlementQrCodeModel(
            title: widget.fallbackPayeeName,
            qr: widget.fallbackQr ?? const PaymentQrModel(),
          ),
        ];

  void _zoom(SettlementQrCodeModel code) {
    if (!code.hasQr) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: LightColor.qrSurface,
        insetPadding: const EdgeInsets.all(AppDimens.paddingX24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingX24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _QrImage(qr: code.qr, size: AppDimens.sizeX250),
              if (code.title.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppDimens.sizeX12),
                Text(
                  code.title,
                  textAlign: TextAlign.center,
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium
                      ?.copyWith(
                        color: LightColor.onQrSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final List<SettlementQrCodeModel> slides = _slides;
    final bool isSlider = slides.length > 1;
    final int active = _index.clamp(0, slides.length - 1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.qr_code_2_rounded,
                size: AppDimens.sizeX18,
                color: LightColor.brandTextColor,
              ),
              const SizedBox(width: AppDimens.paddingX6),
              Expanded(
                child: Text(
                  isSlider ? 'Scan any QR to pay' : 'Scan to pay',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isSlider)
                Text(
                  '${active + 1}/${slides.length}',
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          SizedBox(
            // The card is sized to its content rather than a guessed constant:
            // the QR box plus the single label line under it.
            height: _qrSize + AppDimens.sizeX24,
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              physics: isSlider
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              onPageChanged: (int i) => setState(() => _index = i),
              itemBuilder: (BuildContext context, int i) {
                final SettlementQrCodeModel code = slides[i];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => _zoom(code),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimens.paddingX8),
                        decoration: BoxDecoration(
                          color: LightColor.qrSurface,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX10,
                          ),
                        ),
                        child: _QrImage(
                          qr: code.qr,
                          size: _qrSize - AppDimens.sizeX16,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX6),
                    Text(
                      code.title.isEmpty
                          ? widget.fallbackPayeeName
                          : code.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (isSlider) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(slides.length, (int i) {
                final bool isActive = i == active;
                return GestureDetector(
                  onTap: () => _controller.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingX2,
                      vertical: AppDimens.paddingX4,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      height: AppDimens.sizeX6,
                      // The active dot stretches instead of only recolouring,
                      // so position reads without counting dots.
                      width: isActive ? AppDimens.sizeX18 : AppDimens.sizeX6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? LightColor.secondaryColor
                            : LightColor.dividerColor,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusX50,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: AppDimens.paddingX12),
          Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
          const SizedBox(height: AppDimens.paddingX12),
          _RecipientRow(
            label: widget.amountLabel,
            value: widget.amountValue,
            emphasise: true,
          ),
        ],
      ),
    );
  }
}

/// QR bitmap from either of the two shapes the API sends, with a neutral
/// placeholder when it sends neither.
class _QrImage extends StatelessWidget {
  const _QrImage({required this.qr, required this.size});

  final PaymentQrModel qr;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = qr.qrImageBytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    final String? url = qr.qrImageUrl;
    if (url != null && url.isNotEmpty) {
      return CustomImageView(
        url: url,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => SizedBox(
    width: size,
    height: size,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.qr_code_2_rounded,
          size: size * 0.4,
          color: LightColor.onQrSurfaceMuted,
        ),
        const SizedBox(height: AppDimens.sizeX6),
        Text(
          StringConstants.qrUnavailable,
          style: TextStyle(
            color: LightColor.onQrSurfaceMuted,
            fontSize: AppDimens.sizeX12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

/// Who the vendor pays, as `/auth/settlement-preview` reports it — logo, name
/// and the phone to send the transfer to, plus the payable figures.
class SettlementRecipientCard extends StatelessWidget {
  const SettlementRecipientCard({
    super.key,
    required this.recipient,
    required this.maximumPayable,
    this.pendingClearance = 0,
    this.totalEarned = 0,
  });

  final SettlementRecipientModel recipient;
  final double maximumPayable;
  final double pendingClearance;

  /// Lifetime gross earnings. Context for the commission — it is where the
  /// commission was charged from — never a figure this request pays.
  final double totalEarned;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (recipient.logoUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                  child: CustomImageView(
                    imagePath: recipient.logoUrl,
                    height: 46,
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 46,
                  width: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: LightColor.categoryContainer(
                      LightColor.secondaryColor,
                    ),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    size: 20,
                    color: LightColor.brandTextColor,
                  ),
                ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay to',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recipient.name.isEmpty
                          ? StringConstants.hamroFutsal
                          : recipient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (recipient.phone.isNotEmpty) ...[
            const SizedBox(height: AppDimens.paddingX12),
            _RecipientRow(
              label: 'Phone',
              value: recipient.phone,
              // The number is what the transfer is sent to — make it copyable
              // rather than something to re-type by hand.
              onCopy: () async {
                await Clipboard.setData(ClipboardData(text: recipient.phone));
                if (!context.mounted) return;
                AppUtils().showSnackBar(
                  context,
                  MsgType.success,
                  'Phone number copied.',
                );
              },
            ),
          ],
          const SizedBox(height: AppDimens.paddingX12),
          Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
          const SizedBox(height: AppDimens.paddingX12),
          if (totalEarned > 0) ...[
            _RecipientRow(
              label: StringConstants.totalEarned,
              value: AccountFmt.npr(totalEarned),
            ),
            const SizedBox(height: AppDimens.paddingX6),
          ],
          if (pendingClearance > 0) ...[
            _RecipientRow(
              label: StringConstants.pendingClearance,
              value: AccountFmt.npr(pendingClearance),
            ),
            const SizedBox(height: AppDimens.paddingX6),
          ],
          // The amount this request actually pays sits last and emphasised, so
          // the context rows above it can never be mistaken for the total due.
          _RecipientRow(
            label: 'Commission payable',
            value: AccountFmt.npr(maximumPayable),
            emphasise: true,
          ),
        ],
      ),
    );
  }
}

class _RecipientRow extends StatelessWidget {
  const _RecipientRow({
    required this.label,
    required this.value,
    this.emphasise = false,
    this.onCopy,
  });

  final String label;
  final String value;
  final bool emphasise;
  final Future<void> Function()? onCopy;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyTextSmall?.copyWith(
            color: emphasise
                ? LightColor.brandTextColor
                : LightColor.primaryTextColor,
            fontWeight: emphasise ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        if (onCopy != null) ...[
          const SizedBox(width: AppDimens.paddingX4),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingX4),
              child: Icon(
                Icons.copy_rounded,
                size: AppDimens.sizeX16,
                color: LightColor.brandTextColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Server-reported settlement counts as a compact chip row.
class SettlementSummaryRow extends StatelessWidget {
  const SettlementSummaryRow({super.key, required this.counts});

  final SettlementStatusCounts counts;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, int, Color)>[
      ('Pending', counts.pending, SettlementStatus.pending.color),
      ('Approved', counts.approved, SettlementStatus.approved.color),
      ('Paid', counts.paid, SettlementStatus.paid.color),
      ('Rejected', counts.rejected, SettlementStatus.rejected.color),
    ];
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(width: AppDimens.paddingX8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.paddingX8,
                horizontal: AppDimens.paddingX6,
              ),
              decoration: BoxDecoration(
                color: entries[i].$3.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              ),
              child: Column(
                children: [
                  Text(
                    '${entries[i].$2}',
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: entries[i].$3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entries[i].$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                      fontSize: AppDimens.fontBodySubTitle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
