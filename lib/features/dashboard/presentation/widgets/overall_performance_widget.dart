import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';

class OverallPerformanceWidget extends StatelessWidget {
  const OverallPerformanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<OverviewMetric> kMetrics = [
      OverviewMetric(
        title: 'Total Earning',
        value: 'NPR 52,400',
        caption: 'This month revenue',
        icon: Icons.account_balance_wallet_rounded,
        accentColor: LightColor.secondaryGreen,
        dimColor: LightColor.secondaryGreen.withValues(alpha: 0.12),
        glowColor: LightColor.secondaryGreen.withValues(alpha: 0.10),
        trackColor: LightColor.secondaryGreen.withValues(alpha: 0.20),
        progress: 0.74,
        trend: '+12.4%',
        trendUp: true,
      ),
      OverviewMetric(
        title: 'Total Booking',
        value: '186',
        caption: 'Booked slots this month',
        icon: Icons.calendar_month_rounded,
        accentColor: LightColor.skyBlue,
        dimColor: LightColor.skyBlue.withValues(alpha: 0.12),
        glowColor: LightColor.skyBlue.withValues(alpha: 0.10),
        trackColor: LightColor.skyBlue.withValues(alpha: 0.20),
        progress: 0.62,
        trend: '+8.1%',
        trendUp: true,
      ),
      OverviewMetric(
        title: 'Occupancy',
        value: '84%',
        caption: 'Court usage today',
        icon: Icons.stadium_rounded,
        accentColor: LightColor.primaryGreen,
        dimColor: LightColor.primaryGreen.withValues(alpha: 0.11),
        glowColor: LightColor.primaryGreen.withValues(alpha: 0.10),
        trackColor: LightColor.primaryGreen.withValues(alpha: 0.18),
        progress: 0.84,
        trend: '+3.5%',
        trendUp: true,
      ),
      OverviewMetric(
        title: 'Cancelled',
        value: '12',
        caption: 'Cancelled reservations',
        icon: Icons.cancel_rounded,
        accentColor: LightColor.red,
        dimColor: LightColor.red.withValues(alpha: 0.12),
        glowColor: LightColor.red.withValues(alpha: 0.10),
        trackColor: LightColor.red.withValues(alpha: 0.18),
        progress: 0.15,
        trend: '-2.0%',
        trendUp: false,
      ),
    ];

    return GridView.builder(
      itemCount: kMetrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.04,
      ),
      itemBuilder: (context, index) => _AnimatedMetricCard(
        metric: kMetrics[index],
        delay: Duration(milliseconds: 60 + index * 80),
      ),
    );
  }
}

class _AnimatedMetricCard extends StatefulWidget {
  const _AnimatedMetricCard({required this.metric, required this.delay});
  final OverviewMetric metric;
  final Duration delay;

  @override
  State<_AnimatedMetricCard> createState() => _AnimatedMetricCardState();
}

class _AnimatedMetricCardState extends State<_AnimatedMetricCard>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _arcCtrl;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _arcAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _arcCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideAnim = Tween<double>(
      begin: 24,
      end: 0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _arcAnim = Tween<double>(
      begin: 0,
      end: widget.metric.progress,
    ).animate(CurvedAnimation(parent: _arcCtrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) {
        _entryCtrl.forward();
        _arcCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _arcCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryCtrl, _arcCtrl]),
      builder: (context, _) => Opacity(
        opacity: _fadeAnim.value,
        child: Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: _MetricCard(
            metric: widget.metric,
            arcProgress: _arcAnim.value,
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatefulWidget {
  const _MetricCard({required this.metric, required this.arcProgress});
  final OverviewMetric metric;
  final double arcProgress;

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.965,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.metric;
    final cardBackground = Color.alphaBlend(
      LightColor.background.withValues(alpha: 0.45),
      LightColor.surface,
    );
    final accentWash = Color.alphaBlend(
      m.accentColor.withValues(alpha: 0.08),
      LightColor.surface,
    );

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accentWash, cardBackground],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: m.glowColor.withAlpha(40)),
            // boxShadow: [
            //   BoxShadow(
            //     color: m.glowColor,
            //     blurRadius: 22,
            //     offset: const Offset(0, 10),
            //   ),
            //   BoxShadow(
            //     color: LightColor.accentGreen.withAlpha(15),
            //     blurRadius: 18,
            //     offset: const Offset(0, 8),
            //   ),
            // ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          m.dimColor,
                          Colors.transparent,
                          LightColor.background.withValues(alpha: 0.28),
                        ],
                        stops: const [0, 0.42, 1],
                      ),
                    ),
                  ),
                ),

                // Corner glow blob
                Positioned(
                  top: -24,
                  right: -24,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: m.glowColor,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: m.dimColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: m.accentColor.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Icon(m.icon, color: m.accentColor, size: 18),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CustomPaint(
                              painter: _ArcPainter(
                                progress: widget.arcProgress,
                                color: m.accentColor,
                                trackColor: m.trackColor,
                              ),
                              child: Center(
                                child: Text(
                                  '${(widget.arcProgress * 100).round()}%',
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w800,
                                    color: m.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Value
                      Text(
                        m.value,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: LightColor.titleTextColor,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Title
                      Text(
                        m.title,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: LightColor.subTitleTextColor,
                        ),
                      ),

                      const Spacer(),

                      // Bottom row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              m.caption,
                              style: const TextStyle(
                                fontSize: 9,
                                color: LightColor.darkgrey,
                                height: 1.4,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          _TrendBadge(
                            label: m.trend,
                            up: m.trendUp,
                            color: m.accentColor,
                            dimColor: m.dimColor,
                          ),
                        ],
                      ),
                    ],
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

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const startAngle = -math.pi * 0.75;
    const sweep = math.pi * 1.5;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      startAngle,
      sweep,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        rect,
        startAngle,
        sweep * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({
    required this.label,
    required this.up,
    required this.color,
    required this.dimColor,
  });

  final String label;
  final bool up;
  final Color color;
  final Color dimColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
      decoration: BoxDecoration(
        color: dimColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 8,
            color: color,
          ),
          const SizedBox(width: 1.5),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class OverviewMetric {
  const OverviewMetric({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.accentColor,
    required this.dimColor,
    required this.glowColor,
    required this.trackColor,
    required this.progress,
    required this.trend,
    required this.trendUp,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color accentColor;
  final Color dimColor;
  final Color glowColor;
  final Color trackColor;
  final double progress;
  final String trend;
  final bool trendUp;
}
