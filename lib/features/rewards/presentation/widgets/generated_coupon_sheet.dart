import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/rewards/data/model/rewards_model.dart';
import 'package:hamro_footsall/features/rewards/presentation/utils/rewards_ui.dart';

/// Success sheet for a freshly generated reward coupon: the code, its value and
/// a copy action.
class GeneratedCouponSheet extends StatelessWidget {
  const GeneratedCouponSheet({super.key, required this.coupon});

  final GeneratedRewardCouponModel coupon;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: coupon.code));
    if (!context.mounted) return;
    AppUtils().showSnackBar(
      context,
      MsgType.success,
      StringConstants.codeCopied,
    );
  }

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final String value = RewardFmt.couponValue(coupon);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX20,
        AppDimens.paddingX8,
        AppDimens.paddingX20,
        AppDimens.paddingX8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: LightColor.secondaryColor,
                size: AppDimens.sizeX28,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingX14),
          Text(
            StringConstants.couponGenerated,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextLarge?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX6),
          Text(
            coupon.message.isNotEmpty
                ? coupon.message
                : StringConstants.rewardCouponReady,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX18),
          _CodeTicket(code: coupon.code, onCopy: () => _copy(context)),
          if (value.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppDimens.paddingX12),
            Center(
              child: Text(
                value,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppDimens.paddingX12),
          _CouponMeta(coupon: coupon),
          const SizedBox(height: AppDimens.paddingX18),
          CustomButton(
            text: StringConstants.copyCode,
            icon: Icons.copy_rounded,
            onPressed: () => _copy(context),
          ),
          const SizedBox(height: AppDimens.paddingX8),
          CustomButton(
            text: StringConstants.close,
            isOutlined: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

/// Dashed-border ticket holding the coupon code.
class _CodeTicket extends StatelessWidget {
  const _CodeTicket({required this.code, required this.onCopy});

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return InkWell(
      onTap: onCopy,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX16,
          vertical: AppDimens.paddingX14,
        ),
        decoration: BoxDecoration(
          color: LightColor.secondaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          border: Border.all(
            color: LightColor.secondaryColor.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextLarge?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            const SizedBox(width: AppDimens.paddingX10),
            const Icon(
              Icons.copy_rounded,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Points used / balance left / validity, whichever the server reported.
class _CouponMeta extends StatelessWidget {
  const _CouponMeta({required this.coupon});

  final GeneratedRewardCouponModel coupon;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);

    final List<(String, String)> rows = <(String, String)>[
      if (coupon.pointsUsed > 0)
        ('Points used', RewardFmt.points(coupon.pointsUsed)),
      if (coupon.remainingPoints != null)
        ('Points left', RewardFmt.points(coupon.remainingPoints!)),
      if (coupon.expiresAt != null)
        ('Valid till', RewardFmt.date(coupon.expiresAt!)),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      children: <Widget>[
        for (int i = 0; i < rows.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppDimens.paddingX8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  rows[i].$1,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ),
              Text(
                rows[i].$2,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
