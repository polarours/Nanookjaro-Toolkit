import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/metrics_provider.dart';
import '../../l10n/app_localizations.dart';
import 'glass_card.dart';

class FilesystemUsageCard extends ConsumerWidget {
  const FilesystemUsageCard({super.key});

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
            loc.filesystemTitle,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          metrics.when(
            data: (summary) {
              if (summary.filesystems.isEmpty) {
                return Center(
                  child: Text(
                    loc.filesystemEmpty,
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }

              return Column(
                children: [
                  for (final fs in summary.filesystems)
                    ...[
                      _FilesystemTile(filesystem: fs, loc: loc, theme: theme),
                      const SizedBox(height: 16),
                    ],
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
            error: (error, _) => Text(loc.filesystemFailed(error)),
          ),
        ],
      ),
    );
  }
}

class _FilesystemTile extends StatelessWidget {
  const _FilesystemTile({
    required this.filesystem,
    required this.loc,
    required this.theme,
  });

  final FilesystemUsage filesystem;
  final AppLocalizations loc;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final usedPercent = filesystem.usedPercent * 100;
    final totalGb = filesystem.totalBytes / (1024 * 1024 * 1024);
    final availableGb = filesystem.availableBytes / (1024 * 1024 * 1024);
    final usedGb = totalGb - availableGb;

    Color getColorForPercentage(double percentage) {
      if (percentage < 70) return Colors.green;
      if (percentage < 90) return Colors.orange;
      return Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              filesystem.mountPoint,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${usedGb.toStringAsFixed(1)} GB / ${totalGb.toStringAsFixed(1)} GB',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: filesystem.usedPercent,
            backgroundColor: theme.colorScheme.surfaceVariant,
            color: getColorForPercentage(usedPercent),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          loc.percentUsed(usedPercent.toStringAsFixed(1)),
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }
}