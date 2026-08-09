import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/models/opponent_cost_split.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/widgets/opponent_common.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Court-fee split configurator: even / custom-%, with by-team or by-result
/// basis and a live breakdown of who pays what.
class OpponentCostSplitCard extends StatelessWidget {
  const OpponentCostSplitCard({
    super.key,
    required this.cost,
    required this.onSplit,
    required this.onBasisChange,
    required this.onPercentChange,
    required this.onLoserPctChange,
  });

  final OpponentCostSplit cost;
  final ValueChanged<SplitMode> onSplit;
  final ValueChanged<SplitBasis> onBasisChange;
  final ValueChanged<int> onPercentChange;
  final ValueChanged<int> onLoserPctChange;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return OpponentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Court fee · ${cost.format.label}',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      OpponentFmt.npr(cost.courtFee),
                      style: textTheme.bodyTextLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                ),
                child: Text(
                  cost.badgeLabel,
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontSize: AppDimens.fontBodySubTitle,
                    fontWeight: FontWeight.w700,
                    color: LightColor.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Row(
            children: List.generate(SplitMode.values.length, (i) {
              final m = SplitMode.values[i];
              final isLast = i == SplitMode.values.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isLast ? 0 : AppDimens.paddingX6,
                  ),
                  child: OpponentPillChip(
                    label: m.label,
                    active: cost.split == m,
                    compact: true,
                    onTap: () => onSplit(m),
                  ),
                ),
              );
            }),
          ),
          if (cost.split == SplitMode.custom) ...[
            const SizedBox(height: AppDimens.paddingX10),
            _BasisToggle(basis: cost.basis, onChange: onBasisChange),
            const SizedBox(height: AppDimens.paddingX10),
            _PercentSlider(
              percent: cost.isResultBased ? cost.loserPercent : cost.myPercent,
              leftLabel: cost.isResultBased ? 'Loser pays' : 'My side pays',
              rightLabel: cost.isResultBased ? 'Winner' : 'Opponent',
              min: cost.isResultBased ? 50 : 10,
              max: 90,
              onChanged: cost.isResultBased
                  ? onLoserPctChange
                  : onPercentChange,
            ),
          ],
          const SizedBox(height: AppDimens.paddingX12),
          Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
          const SizedBox(height: AppDimens.paddingX12),
          if (cost.isResultBased) ...[
            const _CostHintRow(
              icon: Icons.emoji_events_outlined,
              text: StringConstants
                  .loserCoversTheLargerShareSettleTheAmountAfterThe2a150fda,
            ),
            const SizedBox(height: AppDimens.paddingX12),
            _CostLine(
              label: StringConstants.loserPays,
              value: OpponentFmt.npr(cost.loserShare),
              pct: cost.loserPercent,
              emphasised: true,
            ),
            const SizedBox(height: AppDimens.paddingX8),
            _CostLine(
              label: StringConstants.winnerPays,
              value: OpponentFmt.npr(cost.winnerShare),
              pct: 100 - cost.loserPercent,
            ),
          ] else ...[
            _CostLine(
              label: StringConstants.yourTeam,
              value: OpponentFmt.npr(cost.yourShare),
              pct: cost.myPct,
              emphasised: true,
            ),
            const SizedBox(height: AppDimens.paddingX8),
            _CostLine(
              label: StringConstants.opponentTeam,
              value: OpponentFmt.npr(cost.opponentShare),
              pct: 100 - (cost.myPct ?? 50),
            ),
            const SizedBox(height: AppDimens.paddingX8),
            _CostLine(
              label: cost.playerCount == 0
                  ? 'Per player'
                  : 'Per player (${cost.playerCount})',
              value: cost.perPlayerShare == 0
                  ? '—'
                  : OpponentFmt.npr(cost.perPlayerShare),
              muted: true,
            ),
          ],
          const SizedBox(height: AppDimens.paddingX12),
          Container(
            padding: AppUtils().getPadding(
              symmetricHorizontal: AppDimens.paddingX12,
              symmetricVertical: AppDimens.paddingX10,
            ),
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            child: Row(
              children: [
                Text(
                  cost.isResultBased ? 'You pay (if loser)' : 'You pay',
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColor.secondaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  cost.isResultBased
                      ? '${OpponentFmt.npr(cost.loserShare)} · ${cost.loserPercent}%'
                      : '${OpponentFmt.npr(cost.yourShare)} · ${cost.myPct ?? 50}%',
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: LightColor.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BasisToggle extends StatelessWidget {
  const _BasisToggle({required this.basis, required this.onChange});

  final SplitBasis basis;
  final ValueChanged<SplitBasis> onChange;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: SplitBasis.values.map((b) {
          final active = basis == b;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChange(b),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? LightColor.cardColor
                      : LightColor.transparentColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: LightColor.shadowColor,
                            blurRadius: 6,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      b == SplitBasis.teams
                          ? Icons.groups_2_outlined
                          : Icons.emoji_events_outlined,
                      size: 14,
                      color: active
                          ? LightColor.secondaryColor
                          : LightColor.secondaryTextColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      b.label,
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? LightColor.secondaryColor
                            : LightColor.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PercentSlider extends StatelessWidget {
  const _PercentSlider({
    required this.percent,
    required this.onChanged,
    this.leftLabel = 'My side pays',
    this.rightLabel = 'Opponent',
    this.min = 10,
    this.max = 90,
  });

  final int percent;
  final ValueChanged<int> onChanged;
  final String leftLabel;
  final String rightLabel;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final divisions = ((max - min) / 10).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                leftLabel,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$percent%',
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.secondaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '  ·  $rightLabel ${100 - percent}%',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: LightColor.secondaryColor,
            inactiveTrackColor: LightColor.dividerColor,
            thumbColor: LightColor.secondaryColor,
            overlayColor: LightColor.secondaryColor.withValues(alpha: 0.12),
            valueIndicatorColor: LightColor.secondaryColor,
            valueIndicatorTextStyle: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.inverseTextColor,
              fontWeight: FontWeight.w600,
            ),
            showValueIndicator: ShowValueIndicator.onDrag,
          ),
          child: Slider(
            value: percent.clamp(min, max).toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: divisions,
            label: '$percent%',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Row(
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              enabled: percent > min,
              onTap: () => onChanged((percent - 10).clamp(min, max)),
            ),
            const SizedBox(width: AppDimens.paddingX8),
            _StepButton(
              icon: Icons.add_rounded,
              enabled: percent < max,
              onTap: () => onChanged((percent + 10).clamp(min, max)),
            ),
            const Spacer(),
            Text(
              StringConstants.text10Steps,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
                fontSize: AppDimens.fontBodySubTitle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? LightColor.secondaryColor
        : LightColor.disabledTextColor;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Container(
          width: 32,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.background,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(color: LightColor.dividerColor),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _CostLine extends StatelessWidget {
  const _CostLine({
    required this.label,
    required this.value,
    this.pct,
    this.muted = false,
    this.emphasised = false,
  });

  final String label;
  final String value;
  final int? pct;
  final bool muted;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color labelColor = muted
        ? LightColor.hintTextColor
        : LightColor.secondaryTextColor;
    final Color valueColor = muted
        ? LightColor.hintTextColor
        : (emphasised
              ? LightColor.secondaryColor
              : LightColor.primaryTextColor);
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (pct != null) ...[
                const SizedBox(width: AppDimens.paddingX6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: emphasised
                        ? LightColor.secondaryColor.withValues(alpha: 0.10)
                        : LightColor.dividerColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                  ),
                  child: Text(
                    '$pct%',
                    style: textTheme.bodyTextSmall?.copyWith(
                      fontSize: AppDimens.fontBodySubTitle,
                      fontWeight: FontWeight.w700,
                      color: emphasised
                          ? LightColor.secondaryColor
                          : LightColor.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          value,
          style: textTheme.bodyTextSmall?.copyWith(
            color: valueColor,
            fontWeight: muted ? FontWeight.w600 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CostHintRow extends StatelessWidget {
  const _CostHintRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: LightColor.secondaryTextColor),
        const SizedBox(width: AppDimens.paddingX8),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
