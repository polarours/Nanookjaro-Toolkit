import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/metrics_provider.dart';
import 'glass_card.dart';
import 'sparkline.dart';

class RealtimeMetricCard extends ConsumerStatefulWidget {
  const RealtimeMetricCard({super.key});

  @override
  ConsumerState<RealtimeMetricCard> createState() => _RealtimeMetricCardState();
}

class _RealtimeMetricCardState extends ConsumerState<RealtimeMetricCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = ref.watch(metricsProvider);
    final loc = AppLocalizations.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.realtimeMetricsTitle,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: metrics.when(
              data: (summary) {
                return Column(
                  children: [
                    Expanded(
                      child: _MetricSection(
                        title: loc.metricCpu,
                        icon: Icons.memory_rounded,
                        currentValue: summary.cpuUsagePercent,
                        history: summary.cpuUsageHistory,
                        color: theme.colorScheme.primary,
                        context: context,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _MetricSection(
                        title: loc.metricMemory,
                        icon: Icons.storage_rounded,
                        currentValue: summary.memoryUsagePercent,
                        history: summary.memoryUsageHistory,
                        color: theme.colorScheme.secondary,
                        context: context,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(loc.failedMetrics(error))),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final double currentValue;
  final List<double> history;
  final Color color;
  final BuildContext context;

  const _MetricSection({
    required this.title,
    required this.icon,
    required this.currentValue,
    required this.history,
    required this.color,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final sparkPoints = _ensureRenderable(history);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              '${currentValue.toStringAsFixed(1)}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AspectRatio(
            aspectRatio: 3.2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.18),
                    color.withValues(alpha: 0.10),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Sparkline(points: sparkPoints, color: color),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _MetricValue(
              label: "Min",
              value: history.isNotEmpty 
                ? '${history.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}%' 
                : '0%',
            ),
            _MetricValue(
              label: "Max",
              value: history.isNotEmpty 
                ? '${history.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}%' 
                : '0%',
            ),
            _MetricValue(
              label: "Avg",
              value: history.isNotEmpty 
                ? '${(history.reduce((a, b) => a + b) / history.length).toStringAsFixed(1)}%' 
                : '0%',
            ),
            _MetricValue(
              label: "Current",
              value: '${currentValue.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ],
    );
  }

  List<double> _ensureRenderable(List<double> points) {
    if (points.isEmpty) {
      return const <double>[0, 0];
    }
    if (points.length == 1) {
      return <double>[points.first, points.first];
    }
    return points;
  }
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}