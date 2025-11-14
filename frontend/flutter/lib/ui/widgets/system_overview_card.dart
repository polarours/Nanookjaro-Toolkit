import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/metrics_provider.dart';
import '../../providers/update_provider.dart';
import '../../l10n/app_localizations.dart';
import '../dialogs/pacman_upgrade_dialog.dart';
import 'glass_card.dart';

class SystemOverviewCard extends ConsumerWidget {
  const SystemOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(metricsProvider);
    final updates = ref.watch(updateProvider);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return GlassCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.systemOverviewTitle,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            metrics.when(
              data: (summary) {
                final isCompact = MediaQuery.of(context).size.width < 1100;
                final overview = _OverviewMetrics(summary: summary);
                final metaPanel = _OverviewMeta(summary: summary);
                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [overview, const SizedBox(height: 20), metaPanel],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: overview),
                    const SizedBox(width: 24),
                    Expanded(flex: 5, child: metaPanel),
                  ],
                );
              },
              loading: () => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator.adaptive(),
                    const SizedBox(height: 12),
                    Text(loc.metricsLoading),
                  ],
                ),
              ),
              error: (error, _) => Text(loc.failedMetrics(error)),
            ),
            const SizedBox(height: 24),
            updates.when(
              data: (info) {
                final statusText = info.pendingCount == 0
                    ? loc.updateStatusAllGood
                    : [
                        loc.updateStatusPending(info.pendingCount),
                        if (info.requiresReboot) loc.updateStatusReboot,
                      ].join(' ');
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        statusText,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final result = await showDialog<PacmanUpgradeResult>(
                          context: context,
                          builder: (context) => const PacmanUpgradeDialog(),
                        );
                        if (result == null) {
                          return;
                        }
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.summaryMessage),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.system_update_alt_rounded),
                      label: Text(loc.upgradeNow),
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(loc.updateCheckFailed(error)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetrics extends StatelessWidget {
  const _OverviewMetrics({required this.summary});

  final SystemSummary summary;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final stats = [
      _InfoTile(label: loc.cpuModel, value: summary.cpuModel),
      _InfoTile(label: loc.cpuCores, value: '${summary.cpuCores}'),
      _InfoTile(label: loc.cpuUsage, value: '${summary.cpuUsagePercent.toStringAsFixed(1)}%'),
      _InfoTile(
        label: loc.memory,
        value: _memoryLabel(context, summary.memoryUsedKb, summary.memoryTotalKb, summary.memoryUsagePercent),
      ),
      _InfoTile(
        label: loc.swap,
        value: summary.swapTotalKb == 0
            ? loc.swapNotConfigured
            : _swapLabel(context, summary.swapUsedKb, summary.swapTotalKb, summary.swapUsagePercent),
      ),
      _InfoTile(
        label: loc.loadAverage,
        value: summary.loadAverage.isEmpty
            ? 'n/a'
            : summary.loadAverage.map((value) => value.toStringAsFixed(2)).join(' / '),
      ),
      if (summary.gpus.isNotEmpty)
        _InfoTile(
          label: loc.gpu,
          value: summary.gpus.join('\n'),
        ),
      _InfoTile(
        label: loc.proxy,
        value: _proxyLabel(context, summary.httpProxy, summary.httpsProxy),
      ),
    ];

    return Wrap(
      spacing: 32,
      runSpacing: 18,
      children: stats,
    );
  }

  String _memoryLabel(BuildContext context, int usedKb, int totalKb, double percent) {
    final loc = AppLocalizations.of(context);
    final usedGb = usedKb / 1024 / 1024;
    final totalGb = totalKb / 1024 / 1024;
    return loc.memoryUtilized(
      usedGb.toStringAsFixed(1),
      totalGb.toStringAsFixed(1),
      percent.toStringAsFixed(1),
    );
  }

  String _swapLabel(BuildContext context, int usedKb, int totalKb, double percent) {
    final loc = AppLocalizations.of(context);
    final usedGb = usedKb / 1024 / 1024;
    final totalGb = totalKb / 1024 / 1024;
    return loc.swapUtilized(
      usedGb.toStringAsFixed(1),
      totalGb.toStringAsFixed(1),
      percent.toStringAsFixed(1),
    );
  }

  String _proxyLabel(BuildContext context, String httpProxy, String httpsProxy) {
    final loc = AppLocalizations.of(context);
    if (httpProxy.isEmpty && httpsProxy.isEmpty) {
      return loc.proxyNone;
    }
    if (httpProxy == httpsProxy) {
      return loc.proxyMatch(httpProxy);
    }
    if (httpProxy.isEmpty) {
      return loc.proxyHttps(httpsProxy);
    }
    if (httpsProxy.isEmpty) {
      return loc.proxyHttp(httpProxy);
    }
    return loc.proxyBoth(httpProxy, httpsProxy);
  }
}

class _OverviewMeta extends StatelessWidget {
  const _OverviewMeta({required this.summary});

  final SystemSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final timeLabel = DateFormat('HH:mm:ss').format(summary.timestamp.toLocal());
    String loadValue(int index) {
      if (index >= summary.loadAverage.length) {
        return 'n/a';
      }
      return summary.loadAverage[index].toStringAsFixed(2);
    }
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.24),
            theme.colorScheme.secondary.withValues(alpha: 0.16),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.lastRefresh, style: theme.textTheme.labelLarge),
              Text(timeLabel, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 28),
          const SizedBox(height: 4),
          Text(
            loc.loadSnapshot,
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _LoadPill(label: loc.loadShort1, value: loadValue(0)),
              _LoadPill(label: loc.loadShort5, value: loadValue(1)),
              _LoadPill(label: loc.loadShort15, value: loadValue(2)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.secondary),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _LoadPill extends StatelessWidget {
  const _LoadPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
