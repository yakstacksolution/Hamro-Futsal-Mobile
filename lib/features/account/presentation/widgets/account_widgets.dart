import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/widgets/attachment_viewer.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/payment_qr_model.dart';
import 'package:hamro_futsal/features/account/presentation/utils/account_ui_utils.dart';

class AccountBalanceCard extends StatelessWidget {
  const AccountBalanceCard({
    super.key,
    required this.commissionPayable,
    required this.availableBalance,
    required this.pendingClearance,
    this.totalEarned = 0,
    this.onRequestSettlement,
    this.disabledReason,
    this.wide = false,
  });

  final double commissionPayable;
  final double availableBalance;
  final double pendingClearance;
  final double totalEarned;

  final VoidCallback? onRequestSettlement;
  final String? disabledReason;

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final List<Widget> info = [
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
    ];
    final List<Widget> cta = [
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
    ];
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
            color: LightColor.shadowOf(0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: wide
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: info,
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX24),
                SizedBox(
                  width: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: cta,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...info,
                const SizedBox(height: AppDimens.paddingX16),
                ...cta,
              ],
            ),
    );
  }
}

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
        color: LightColor.elevatedCardColor,
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

class AccountNavTile extends StatelessWidget {
  const AccountNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle = '',
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color accent = iconColor == null
        ? LightColor.brandTextColor
        : LightColor.categoryAccent(iconColor!);
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
                  color: LightColor.categoryContainer(accent),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: Icon(icon, size: 18, color: accent),
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

class AccountEntryTile extends StatelessWidget {
  const AccountEntryTile({super.key, required this.entry});

  final AccountEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final String title = entry.title.isNotEmpty
        ? entry.title
        : entry.type.fallbackTitle;
    final String direction = entry.isCredit
        ? StringConstants.credit
        : StringConstants.debit;
    // A debit is a normal movement on a statement, not an error, so it is set
    // in plain text: the sign and the chip carry the direction.
    final Color amountColor = entry.isCredit
        ? LightColor.brandTextColor
        : LightColor.primaryTextColor;

    final List<Widget> fields = <Widget>[
      if (entry.venueName.isNotEmpty)
        DataCardField(label: StringConstants.venue, value: entry.venueName),
      if (entry.date != null)
        DataCardField(
          label: StringConstants.bookingDate,
          value: AccountFmt.dateTime(entry.date!),
        ),
      if (entry.createdAt != null)
        DataCardField(
          label: StringConstants.recorded,
          value: AccountFmt.dateTime(entry.createdAt!),
        ),
      if (entry.note.isNotEmpty)
        DataCardField(
          label: StringConstants.note,
          value: entry.note,
          maxLines: 3,
        ),
    ];

    return Semantics(
      container: true,
      label: <String>[
        title,
        '$direction ${AccountFmt.npr(entry.amount)}',
        if (entry.reference.isNotEmpty) entry.reference,
        if (entry.venueName.isNotEmpty) entry.venueName,
        if (entry.date != null)
          '${StringConstants.bookingDate} ${AccountFmt.dateTime(entry.date!)}',
        if (entry.createdAt != null)
          '${StringConstants.recorded} ${AccountFmt.dateTime(entry.createdAt!)}',
      ].join(', '),
      child: DataCard(
        child: Column(
          // Shrink-wraps: a card is as tall as its content, wherever it is
          // put. Without this it fills whatever height it is offered — fine
          // inside a ListView, wrong in a Column or an Align.
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DataCardHeader(
              icon: entry.type.icon,
              iconColor: entry.type.color,
              title: title,
              subtitle: entry.reference,
              amount:
                  '${entry.isCredit ? '+' : '−'} ${AccountFmt.npr(entry.amount)}',
              amountColor: amountColor,
              chipLabel: direction,
              chipColor: amountColor,
            ),
            if (fields.isNotEmpty) ...<Widget>[
              const DataCardDivider(),
              DataCardFields(children: fields),
            ],
          ],
        ),
      ),
    );
  }
}

class AccountActivityDateHeader extends StatelessWidget {
  const AccountActivityDateHeader({
    super.key,
    required this.day,
    this.dense = false,
  });

  final DateTime day;

  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: dense ? 0 : AppDimens.paddingX20,
        bottom: AppDimens.paddingX10,
      ),
      child: Row(
        children: <Widget>[
          Text(
            AccountFmt.sectionDay(day),
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: LightColor.dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}

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
        // Shrink-wraps: a card is as tall as its content wherever it is put.
        // Without this it fills whatever height it is offered — fine inside a
        // ListView, wrong in a Column or an Align.
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                  _SettlementProofRow(imageUrl: proofUrl),
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
        color: LightColor.categoryContainer(status.color),
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        border: Border.all(color: status.color.withValues(alpha: 0.35)),
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
        color: LightColor.redLightColor,
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
              color: LightColor.brandTextColor,
            ),
            const SizedBox(width: AppDimens.paddingX4),
            Text(
              StringConstants.viewProof,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.brandTextColor,
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

class _SettlementProofRow extends StatelessWidget {
  const _SettlementProofRow({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _SettlementProofAction(imageUrl: imageUrl),
        AttachmentDownloadAction(
          key: const Key('settlement-proof-download'),
          url: imageUrl,
        ),
      ],
    );
  }
}

class SettlementProofViewer extends StatelessWidget {
  const SettlementProofViewer({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) =>
      AttachmentViewer(url: imageUrl, title: StringConstants.paymentProof);
}

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

  final List<SettlementQrCodeModel> codes;

  final String amountLabel;
  final String amountValue;

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

  List<SettlementQrCodeModel> get _slides => widget.codes.isNotEmpty
      ? widget.codes
      : <SettlementQrCodeModel>[
          SettlementQrCodeModel(
            title: widget.fallbackPayeeName,
            qr: widget.fallbackQr ?? const PaymentQrModel(),
          ),
        ];

  Widget? _downloadAction(SettlementQrCodeModel code, {Color? color}) {
    if (!code.hasQr) return null;
    return AttachmentDownloadAction(
      key: ValueKey<String>('settlement-qr-download-${code.id}'),
      bytes: code.qr.qrImageBytes,
      url: code.qr.qrImageUrl,
      fileName: _fileName(code),
      color: color,
      tooltip: StringConstants.saveQrCode,
    );
  }

  String _fileName(SettlementQrCodeModel code) {
    final String label =
        (code.title.isEmpty ? widget.fallbackPayeeName : code.title)
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'^-+|-+$'), '');
    return label.isEmpty ? 'commission-qr' : 'commission-qr-$label';
  }

  void _zoom(SettlementQrCodeModel code) {
    if (!code.hasQr) return;
    final Widget? saveAction = _downloadAction(
      code,
      color: LightColor.onQrSurface,
    );
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
              if (saveAction != null) saveAction,
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
              // Downloads the slide the vendor is looking at, not the first.
              ?_downloadAction(slides[active]),
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
                            ? LightColor.brandTextColor
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

class SettlementSummaryRow extends StatelessWidget {
  const SettlementSummaryRow({super.key, required this.counts});

  final SettlementStatusCounts counts;

  @override
  Widget build(BuildContext context) {
    // Paid is deliberately not a tile: the row is for requests still moving
    // or refused — what the vendor might act on. Paid settlements are done
    // with, and their cards are still in the list below.
    final entries = <(String, int, Color)>[
      ('Pending', counts.pending, SettlementStatus.pending.color),
      ('Approved', counts.approved, SettlementStatus.approved.color),
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
                color: LightColor.categoryContainer(entries[i].$3),
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
