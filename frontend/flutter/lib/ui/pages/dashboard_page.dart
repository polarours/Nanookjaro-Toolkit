import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/metrics_provider.dart';
import '../../providers/update_provider.dart';
import '../../services/ffi_bridge.dart';
import '../widgets/filesystem_usage_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/realtime_metric_card.dart';
import '../widgets/system_overview_card.dart';
import '../widgets/circular_metrics_card.dart';
import '../dialogs/proxy_config_dialog.dart';
import '../dialogs/pacman_upgrade_dialog.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final statusBar = MediaQuery.of(context).padding.top;
    final topPadding = statusBar + 112;
    final loc = AppLocalizations.of(context);
    final crossAxisCount = width > 1400
        ? 3
        : width > 1000
            ? 2
            : 1;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(32, topPadding, 32, 32),
          sliver: SliverGrid.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            children: [
              const CircularMetricsCard(),
              const RealtimeMetricCard(),
              QuickActionsGrid(onAction: (action) {
                _handleQuickAction(context, ref, loc, action);
              }),
            ],
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }
  
  void _handleQuickAction(BuildContext context, WidgetRef ref, AppLocalizations loc, QuickAction action) {
    switch (action) {
      case QuickAction.rollingUpgrade:
        _runRollingUpgrade(context, ref, loc);
        break;
      case QuickAction.systemUpgrade:
        _handleSystemUpgrade(context, ref, loc);
        break;
      case QuickAction.enableProxy:
        _applyProxyProfile(context, ref, loc, enable: true);
        break;
      case QuickAction.disableProxy:
        _applyProxyProfile(context, ref, loc, enable: false);
        break;
      case QuickAction.configureProxy:
        _handleConfigureProxy(context, ref, loc);
        break;
      case QuickAction.driverScan:
      case QuickAction.cleanCache:
      case QuickAction.openLogs:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(loc.comingSoon),
          behavior: SnackBarBehavior.floating,
        ));
        break;
    }
  }
  
  Future<void> _handleSystemUpgrade(BuildContext context, WidgetRef ref, AppLocalizations loc) async {
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
  }
  
  Future<void> _handleConfigureProxy(BuildContext context, WidgetRef ref, AppLocalizations loc) async {
    final summary = ref.read(metricsProvider).maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );
    final result = await showDialog<ProxyConfigResult>(
      context: context,
      builder: (context) => ProxyConfigDialog(
        initialHttp: summary?.httpProxy ?? '',
        initialHttps: summary?.httpsProxy ?? '',
      ),
    );
    if (result == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (result.success) {
      await ref.read(metricsProvider.notifier).refresh();
    }
  }
}

Future<void> _runRollingUpgrade(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations loc,
) async {
  final rootNavigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _ProgressDialog(
      title: loc.progressTitleRollingUpgrade,
      message: loc.rollingUpgradeRunning,
    ),
  );

  PacmanUpgradeResult? result;
  Object? error;
  try {
    result = await ref.read(updateProvider.notifier).upgrade(assumeYes: true);
  } catch (err) {
    error = err;
  } finally {
    rootNavigator.pop();
  }

  if (!context.mounted) {
    return;
  }

  final messenger = ScaffoldMessenger.of(context);
  if (error != null) {
    messenger.showSnackBar(SnackBar(content: Text(loc.rollingUpgradeError(error))));
    return;
  }

  if (result == null) {
    messenger.showSnackBar(SnackBar(content: Text(loc.rollingUpgradeError('unknown'))));
    return;
  }

  if (result.success) {
    messenger.showSnackBar(SnackBar(content: Text(loc.rollingUpgradeSuccess)));
    return;
  }

  if (result.requiresPassword) {
    messenger.showSnackBar(SnackBar(content: Text(loc.rollingUpgradeNeedsPassword)));
    return;
  }

  messenger.showSnackBar(SnackBar(content: Text(loc.rollingUpgradeFailed(result.exitCode))));
}

Future<void> _applyProxyProfile(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations loc, {
  required bool enable,
}) async {
  final summary = ref.read(metricsProvider).maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );

  const fallbackProxy = 'http://127.0.0.1:7890';
  final httpValue = enable
      ? (summary?.httpProxy.isNotEmpty == true ? summary!.httpProxy : fallbackProxy)
      : '';
  final httpsValue = enable
      ? (summary?.httpsProxy.isNotEmpty == true ? summary!.httpsProxy : fallbackProxy)
      : '';

  final rootNavigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _ProgressDialog(
      title: loc.progressTitleProxy,
      message: loc.proxyApplyProgress,
    ),
  );

  Map<String, dynamic>? result;
  Object? error;
  try {
    result = NanookjaroBridge.instance.setProxy(http: httpValue, https: httpsValue);
  } catch (err) {
    error = err;
  } finally {
    rootNavigator.pop();
  }

  if (!context.mounted) {
    return;
  }

  final messenger = ScaffoldMessenger.of(context);
  if (error != null) {
    messenger.showSnackBar(SnackBar(content: Text(loc.proxyApplyFailed(error))));
    return;
  }

  final success = result?['ok'] == true;
  if (success) {
    messenger.showSnackBar(SnackBar(content: Text(enable ? loc.proxyApplySuccess : loc.proxyApplyCleared)));
    await ref.read(metricsProvider.notifier).refresh();
  } else {
    messenger.showSnackBar(
      SnackBar(
        content: Text(loc.proxyApplyFailed(result?['error'] ?? 'unknown')),
      ),
    );
  }
}

class _ProgressDialog extends StatelessWidget {
  const _ProgressDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(width: 16),
            Flexible(child: Text(message)),
          ],
        ),
      ),
    );
  }
}