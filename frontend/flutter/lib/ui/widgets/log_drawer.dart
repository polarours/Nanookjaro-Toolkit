import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LogDrawer extends StatelessWidget {
  const LogDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
  color: theme.colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(loc.activityLog, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(
            loc.logDrawerDescription,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
