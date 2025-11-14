import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ffi_bridge.dart';

class PackageUpdate {
  PackageUpdate({required this.name, required this.currentVersion, required this.nextVersion});

  final String name;
  final String currentVersion;
  final String nextVersion;

  bool get rebootLikely => _rebootPackages.any((prefix) => name.startsWith(prefix));

  static const List<String> _rebootPackages = <String>[
    'linux',
    'systemd',
    'glibc',
    'nvidia',
  ];
}

class UpdateInfo {
  UpdateInfo({
    required this.command,
    required this.exitCode,
    required this.fallbackUsed,
    required this.output,
    required this.updates,
  });

  final String command;
  final int exitCode;
  final bool fallbackUsed;
  final String output;
  final List<PackageUpdate> updates;

  int get pendingCount => updates.length;
  bool get requiresReboot => updates.any((update) => update.rebootLikely);
}

class PacmanUpgradeResult {
  const PacmanUpgradeResult({
    required this.command,
    required this.interactiveCommand,
    required this.exitCode,
    required this.requiresPassword,
    required this.output,
  });

  final String command;
  final String interactiveCommand;
  final int exitCode;
  final bool requiresPassword;
  final String output;

  bool get success => exitCode == 0;

  String get summaryMessage {
    if (success) {
      return 'System upgrade completed successfully';
    }
    if (requiresPassword) {
      return 'Authentication required. Run the interactive command in a terminal.';
    }
    return 'Upgrade failed (exit $exitCode). Check the command output for details.';
  }
}

class UpdateNotifier extends StateNotifier<AsyncValue<UpdateInfo>> {
  UpdateNotifier() : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    if (!state.isLoading) {
      state = const AsyncValue.loading();
    }
    try {
      final rawJson = NanookjaroBridge.instance.pacmanListUpdatesJson();
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      if (decoded.containsKey('error')) {
        throw StateError('pacman_list_updates: ${decoded['error']}');
      }

      final updates = (decoded['updates'] as List<dynamic>? ?? const [])
          .map((entry) => entry as Map<String, dynamic>)
          .map(
            (entry) => PackageUpdate(
              name: entry['name'] as String? ?? 'unknown',
              currentVersion: entry['current'] as String? ?? '0',
              nextVersion: entry['available'] as String? ?? '0',
            ),
          )
          .toList();

      final info = UpdateInfo(
        command: decoded['command'] as String? ?? 'pacman -Qu',
        exitCode: (decoded['exit_code'] as num? ?? -1).toInt(),
        fallbackUsed: decoded['fallback_used'] as bool? ?? false,
        output: decoded['output'] as String? ?? '',
        updates: updates,
      );

      state = AsyncValue.data(info);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<PacmanUpgradeResult> upgrade({bool assumeYes = false}) async {
    final rawJson = NanookjaroBridge.instance.pacmanSyncUpgradeJson(assumeYes: assumeYes);
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    if (decoded.containsKey('error')) {
      throw StateError('pacman_sync_upgrade: ${decoded['error']}');
    }

    final result = PacmanUpgradeResult(
      command: decoded['command'] as String? ?? 'pacman -Syu',
      interactiveCommand: decoded['interactive_command'] as String? ??
          (decoded['command'] as String? ?? 'pacman -Syu'),
      exitCode: (decoded['exit_code'] as num? ?? -1).toInt(),
      requiresPassword: decoded['requires_password'] as bool? ?? false,
      output: decoded['output'] as String? ?? '',
    );

    if (result.success) {
      await refresh();
    }

    return result;
  }
}

final updateProvider =
    StateNotifierProvider<UpdateNotifier, AsyncValue<UpdateInfo>>((ref) => UpdateNotifier());
