import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'glass_card.dart';

enum QuickAction {
  rollingUpgrade,
  systemUpgrade,
  enableProxy,
  disableProxy,
  configureProxy,
  driverScan,
  cleanCache,
  openLogs,
}

typedef QuickActionCallback = void Function(QuickAction action);

class QuickActionsGrid extends StatelessWidget {
  final QuickActionCallback onAction;

  const QuickActionsGrid({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.quickActionsTitle,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ActionTile(
                  icon: Icons.autorenew_rounded,
                  title: loc.quickActionRollingUpgrade,
                  onTap: () => onAction(QuickAction.rollingUpgrade),
                ),
                _ActionTile(
                  icon: Icons.system_update_alt_rounded,
                  title: loc.quickActionSystemUpgrade,
                  onTap: () => onAction(QuickAction.systemUpgrade),
                ),
                _ActionTile(
                  icon: Icons.vpn_lock_rounded,
                  title: loc.quickActionEnableProxy,
                  onTap: () => onAction(QuickAction.enableProxy),
                ),
                _ActionTile(
                  icon: Icons.no_encryption_rounded,
                  title: loc.quickActionDisableProxy,
                  onTap: () => onAction(QuickAction.disableProxy),
                ),
                _ActionTile(
                  icon: Icons.settings_ethernet_rounded,
                  title: loc.quickActionConfigureProxy,
                  onTap: () => onAction(QuickAction.configureProxy),
                ),
                _ActionTile(
                  icon: Icons.drive_eta_rounded,
                  title: loc.quickActionDriverScan,
                  onTap: () => onAction(QuickAction.driverScan),
                ),
                _ActionTile(
                  icon: Icons.cleaning_services_rounded,
                  title: loc.quickActionCleanCache,
                  onTap: () => onAction(QuickAction.cleanCache),
                ),
                _ActionTile(
                  icon: Icons.description_rounded,
                  title: loc.quickActionOpenLogs,
                  onTap: () => onAction(QuickAction.openLogs),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}