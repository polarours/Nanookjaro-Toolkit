import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/metrics_provider.dart';
import '../../l10n/app_localizations.dart';
import 'glass_card.dart';

class CircularMetricsCard extends ConsumerWidget {
  const CircularMetricsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(metricsProvider);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.systemOverviewTitle,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: metrics.when(
              data: (summary) {
                double cpuUsage = summary.cpuUsagePercent;
                double memoryUsage = summary.memoryUsagePercent;
                double diskUsage = 0.0;
                if (summary.filesystems.isNotEmpty) {
                  final fs = summary.filesystems.first;
                  if (fs.totalBytes > 0) {
                    diskUsage = (fs.totalBytes - fs.availableBytes) / fs.totalBytes * 100;
                  }
                }
                // Use a fixed value for GPU for now, as we don't have real GPU usage data
                double gpuUsage = 0.0;
                if (summary.gpus.isNotEmpty && summary.gpus.first != "No GPU detected") {
                  gpuUsage = 50.0; // Placeholder value for GPU usage
                }
                
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CircularMetric(
                          title: loc.metricCpu,
                          value: cpuUsage,
                          icon: Icons.memory_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        _CircularMetric(
                          title: loc.gpu,
                          value: gpuUsage,
                          icon: Icons.view_in_ar_rounded,
                          color: theme.colorScheme.secondary,
                        ),
                        _CircularMetric(
                          title: loc.metricMemory,
                          value: memoryUsage,
                          icon: Icons.storage_rounded,
                          color: theme.colorScheme.tertiary,
                        ),
                        _CircularMetric(
                          title: loc.filesystemTitle,
                          value: diskUsage,
                          icon: Icons.disc_full_rounded,
                          color: theme.colorScheme.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _NetworkInfoSection(summary: summary),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _ProcessesSection(),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error loading metrics')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularMetric extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const _CircularMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 6,
                backgroundColor: theme.colorScheme.surfaceVariant,
                color: color,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 4),
                Text(
                  '${value.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _NetworkInfoSection extends ConsumerWidget {
  final SystemSummary summary;

  const _NetworkInfoSection({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    
    // Get real network information from the summary
    String ipAddress = "N/A";
    String uploadSpeed = "0 KB/s";
    String downloadSpeed = "0 KB/s";
    
    if (summary.networkInterfaces.isNotEmpty) {
      final interface = summary.networkInterfaces.first; // Use the first interface
      ipAddress = interface.ipv4Address != "Unknown" ? interface.ipv4Address : "N/A";
      uploadSpeed = "${interface.txRateKbps.toStringAsFixed(2)} KB/s";
      downloadSpeed = "${interface.rxRateKbps.toStringAsFixed(2)} KB/s";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Network",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NetworkInfoItem(
              icon: Icons.network_wifi,
              label: "IP Address",
              value: ipAddress,
            ),
            _NetworkInfoItem(
              icon: Icons.upload,
              label: "Upload",
              value: uploadSpeed,
            ),
            _NetworkInfoItem(
              icon: Icons.download,
              label: "Download",
              value: downloadSpeed,
            ),
          ],
        ),
      ],
    );
  }
}

class _NetworkInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _NetworkInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _ProcessesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Top Processes",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              _ProcessItem(name: "code", cpu: "12.4%", memory: "8.2%"),
              _ProcessItem(name: "firefox", cpu: "8.7%", memory: "15.3%"),
              _ProcessItem(name: "docker", cpu: "5.2%", memory: "6.8%"),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProcessItem extends StatelessWidget {
  final String name;
  final String cpu;
  final String memory;

  const _ProcessItem({
    required this.name,
    required this.cpu,
    required this.memory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              cpu,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              memory,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}