import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/update_provider.dart';

class PacmanUpgradeDialog extends ConsumerStatefulWidget {
  const PacmanUpgradeDialog({super.key});

  @override
  ConsumerState<PacmanUpgradeDialog> createState() => _PacmanUpgradeDialogState();
}

class _PacmanUpgradeDialogState extends ConsumerState<PacmanUpgradeDialog> {
  bool _assumeYes = false;
  bool _running = false;
  PacmanUpgradeResult? _result;
  Object? _error;

  Future<void> _runUpgrade() async {
    setState(() {
      _running = true;
      _error = null;
      _result = null;
    });
    try {
      final notifier = ref.read(updateProvider.notifier);
      final result = await notifier.upgrade(assumeYes: _assumeYes);
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _running = false;
        });
      }
    }
  }

  void _copyCommand(String command) {
    Clipboard.setData(ClipboardData(text: command));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).copyCommand)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        _result == null ? loc.upgradeDialogTitle : loc.upgradeDialogResultTitle,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 520,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: _buildContent(theme, loc),
        ),
      ),
      actions: _buildActions(theme, loc),
    );
  }

  Widget _buildContent(ThemeData theme, AppLocalizations loc) {
    if (_running) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(loc.upgradeRunning),
          ],
        ),
      );
    }

    if (_result != null) {
      final result = _result!;
      final success = result.success;
      final requiresPassword = result.requiresPassword && !success;
      final statusColor = success
          ? Colors.greenAccent.shade200
          : requiresPassword
              ? theme.colorScheme.secondary
              : theme.colorScheme.error;
      final statusIcon = success
          ? Icons.check_circle_rounded
          : requiresPassword
              ? Icons.lock_person_rounded
              : Icons.error_rounded;
      final statusLabel = success
          ? loc.upgradeCompleted
          : requiresPassword
              ? loc.upgradePasswordRequired
              : loc.upgradeFailedExit(result.exitCode);
      final outputRaw = result.output.trim();
      final outputText = outputRaw.isEmpty ? loc.noOutput : outputRaw;

      final surfaceHigh = theme.colorScheme.surfaceContainerHigh;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusChip(icon: statusIcon, color: statusColor, label: statusLabel),
          const SizedBox(height: 18),
          SelectableText(loc.nonInteractiveCommand(result.command)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SelectableText(loc.interactiveCommand(result.interactiveCommand)),
              ),
              IconButton(
                onPressed: () => _copyCommand(result.interactiveCommand),
                tooltip: loc.copyInteractive,
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
          if (requiresPassword) ...[
            const SizedBox(height: 12),
            Text(
              loc.upgradePasswordRequired,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          Text(loc.commandOutput, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: surfaceHigh.withValues(alpha: 0.4),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  outputText,
                  style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'RobotoMono',
                        height: 1.32,
                      ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusChip(
              icon: Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              label: loc.upgradeInvokeFailed,
            ),
            const SizedBox(height: 12),
            SelectableText('$_error'),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.upgradeDescription, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(loc.proxyAutoYes),
          subtitle: Text(loc.proxyAutoYesSubtitle),
          value: _assumeYes,
          onChanged: (value) => setState(() => _assumeYes = value),
        ),
      ],
    );
  }

  List<Widget> _buildActions(ThemeData theme, AppLocalizations loc) {
    if (_running) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.close),
        ),
        FilledButton.icon(
          onPressed: null,
          icon: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: Text(loc.upgradeRunning),
        ),
      ];
    }

    if (_result != null) {
      final result = _result!;
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(result),
          child: Text(loc.close),
        ),
      ];
    }

    if (_error != null) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.close),
        ),
        FilledButton(
          onPressed: _runUpgrade,
          child: Text(loc.retry),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(loc.cancelLower),
      ),
      FilledButton.icon(
        onPressed: _runUpgrade,
        icon: const Icon(Icons.system_update_alt_rounded),
        label: Text(loc.runUpgrade),
      ),
    ];
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
  color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
  border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
