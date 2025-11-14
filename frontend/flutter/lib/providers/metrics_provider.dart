import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ffi_bridge.dart';

class NetworkInterface {
  NetworkInterface({
    required this.name,
    required this.macAddress,
    required this.ipv4Address,
    required this.ipv6Address,
    required this.rxRateKbps,
    required this.txRateKbps,
    required this.isUp,
  });

  final String name;
  final String macAddress;
  final String ipv4Address;
  final String ipv6Address;
  final double rxRateKbps;
  final double txRateKbps;
  final bool isUp;
}

class FilesystemUsage {
  FilesystemUsage({
    required this.mountPoint,
    required this.totalBytes,
    required this.availableBytes,
  });

  final String mountPoint;
  final int totalBytes;
  final int availableBytes;

  double get usedPercent {
    if (totalBytes == 0) {
      return 0.0;
    }
    final used = totalBytes - availableBytes;
    return used / totalBytes;
  }
}

class SystemSummary {
  SystemSummary({
    required this.timestamp,
    required this.cpuModel,
    required this.cpuCores,
    required this.cpuUsagePercent,
    required this.memoryTotalKb,
    required this.memoryAvailableKb,
    required this.memoryUsedKb,
    required this.memoryUsagePercent,
    required this.swapTotalKb,
    required this.swapFreeKb,
    required this.swapUsedKb,
    required this.swapUsagePercent,
    required this.loadAverage,
    required this.filesystems,
    required this.gpus,
    required this.httpProxy,
    required this.httpsProxy,
    required this.cpuUsageHistory,
    required this.memoryUsageHistory,
    required this.networkInterfaces,
  });

  final DateTime timestamp;
  final String cpuModel;
  final int cpuCores;
  final double cpuUsagePercent;
  final int memoryTotalKb;
  final int memoryAvailableKb;
  final int memoryUsedKb;
  final double memoryUsagePercent;
  final int swapTotalKb;
  final int swapFreeKb;
  final int swapUsedKb;
  final double swapUsagePercent;
  final List<double> loadAverage;
  final List<FilesystemUsage> filesystems;
  final List<String> gpus;
  final String httpProxy;
  final String httpsProxy;
  final List<double> cpuUsageHistory;
  final List<double> memoryUsageHistory;
  final List<NetworkInterface> networkInterfaces;
}

class MetricsNotifier extends StateNotifier<AsyncValue<SystemSummary>> {
  MetricsNotifier() : super(const AsyncValue.loading()) {
    _loadInitial();
  }

  Timer? _timer;
  final List<double> _cpuHistory = <double>[];
  final List<double> _memoryHistory = <double>[];

  Future<void> _loadInitial() async {
    await refresh();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      refresh();
    });
  }

  Future<void> refresh() async {
    final previous = state;
    state = const AsyncValue.loading();
    try {
      final rawJson = NanookjaroBridge.instance.getSystemSummaryJson();
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      if (decoded.containsKey('error')) {
        throw StateError('system_summary: ${decoded['error']}');
      }

      final cpu = decoded['cpu'] as Map<String, dynamic>? ?? {};
      final memory = decoded['memory'] as Map<String, dynamic>? ?? {};
      final loadAverageRaw = decoded['load_average'] as List<dynamic>? ?? const [];
      final fsRaw = decoded['filesystems'] as List<dynamic>? ?? const [];
      final gpuRaw = decoded['gpu'] as List<dynamic>? ?? const [];
      final proxyRaw = decoded['proxy'] as Map<String, dynamic>? ?? const {};
      final networkRaw = decoded['network'] as List<dynamic>? ?? const [];

      final rawCpuUsage = (cpu['usage_percent'] as num? ?? 0).toDouble();
      final cpuUsagePercent = rawCpuUsage.clamp(0.0, 100.0).toDouble();
      _pushHistoryPoint(_cpuHistory, cpuUsagePercent);

      final rawMemoryUsage = (memory['usage_percent'] as num? ?? 0).toDouble();
      final memoryUsagePercent = rawMemoryUsage.clamp(0.0, 100.0).toDouble();
      _pushHistoryPoint(_memoryHistory, memoryUsagePercent);

      final summary = SystemSummary(
        timestamp: DateTime.tryParse(decoded['timestamp'] as String? ?? '') ??
            DateTime.now().toUtc(),
        cpuModel: (cpu['model'] as String? ?? 'unknown').trim(),
        cpuCores: (cpu['cores'] as num? ?? 0).toInt(),
        cpuUsagePercent: cpuUsagePercent,
        memoryTotalKb: (memory['total_kb'] as num? ?? 0).toInt(),
        memoryAvailableKb: (memory['available_kb'] as num? ?? 0).toInt(),
        memoryUsedKb: (memory['used_kb'] as num? ?? 0).toInt(),
        memoryUsagePercent: memoryUsagePercent,
        swapTotalKb: (memory['swap_total_kb'] as num? ?? 0).toInt(),
        swapFreeKb: (memory['swap_free_kb'] as num? ?? 0).toInt(),
        swapUsedKb: (memory['swap_used_kb'] as num? ?? 0).toInt(),
        swapUsagePercent: (memory['swap_usage_percent'] as num? ?? 0).toDouble(),
        loadAverage: loadAverageRaw.map((value) => (value as num).toDouble()).toList(),
        filesystems: fsRaw
            .map((raw) => raw as Map<String, dynamic>)
            .map(
              (fs) => FilesystemUsage(
                mountPoint: fs['mount'] as String? ?? '?',
                totalBytes: (fs['total_bytes'] as num? ?? 0).toInt(),
                availableBytes: (fs['available_bytes'] as num? ?? 0).toInt(),
              ),
            )
            .toList(),
        gpus: gpuRaw
            .map((raw) => raw as Map<String, dynamic>)
            .map((gpu) => gpu['name'] as String? ?? 'Unknown GPU')
            .toList(),
        httpProxy: (proxyRaw['http'] as String? ?? '').trim(),
        httpsProxy: (proxyRaw['https'] as String? ?? '').trim(),
        cpuUsageHistory: List<double>.unmodifiable(_cpuHistory),
        memoryUsageHistory: List<double>.unmodifiable(_memoryHistory),
        networkInterfaces: networkRaw
            .map((raw) => raw as Map<String, dynamic>)
            .map(
              (net) => NetworkInterface(
                name: net['name'] as String? ?? 'unknown',
                macAddress: net['mac_address'] as String? ?? 'N/A',
                ipv4Address: net['ipv4_address'] as String? ?? 'N/A',
                ipv6Address: net['ipv6_address'] as String? ?? 'N/A',
                rxRateKbps: (net['rx_rate_kbps'] as num? ?? 0).toDouble(),
                txRateKbps: (net['tx_rate_kbps'] as num? ?? 0).toDouble(),
                isUp: net['is_up'] as bool? ?? false,
              ),
            )
            .toList(),
      );
      state = AsyncValue.data(summary);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _pushHistoryPoint(List<double> history, double value) {
    if (!value.isFinite) {
      return;
    }
    const maxSamples = 90;
    history.add(value);
    if (history.length > maxSamples) {
      history.removeAt(0);
    }
  }
}

final metricsProvider = StateNotifierProvider<MetricsNotifier, AsyncValue<SystemSummary>>((ref) {
  return MetricsNotifier();
});