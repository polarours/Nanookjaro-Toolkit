import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

class NanookjaroBridge {
  NanookjaroBridge._() : _library = _loadLibrary() {
    _getSystemSummary =
        _library.lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>('nj_get_system_summary');
    _freeString = _library.lookupFunction<Void Function(Pointer<Utf8>), void Function(Pointer<Utf8>)>('nj_free_string');
    _pacmanSyncUpgrade =
        _library.lookupFunction<Pointer<Utf8> Function(Int32), Pointer<Utf8> Function(int)>('nj_pacman_sync_upgrade');
    _pacmanListUpdates =
        _library.lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>('nj_pacman_list_updates');
    _setProxy = _library.lookupFunction<
        Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>),
        Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>)>('nj_set_proxy');
    _getCpuInfo =
        _library.lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>('nj_get_cpu_info');
    _getGpuInfo =
        _library.lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>('nj_get_gpu_info');
    _getMemoryInfo =
        _library.lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>('nj_get_memory_info');
    _getDiskInfo =
        _library.lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>('nj_get_disk_info');
    _getNetworkInfo =
        _library.lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>('nj_get_network_info');
    _getDriversInfo =
        _library.lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>('nj_get_drivers_info');
  }

  static final NanookjaroBridge instance = NanookjaroBridge._();

  final DynamicLibrary _library;
  late final Pointer<Utf8> Function() _getSystemSummary;
  late final void Function(Pointer<Utf8>) _freeString;
  late final Pointer<Utf8> Function(int) _pacmanSyncUpgrade;
  late final Pointer<Utf8> Function() _pacmanListUpdates;
  late final Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>) _setProxy;
  late final Pointer<Utf8> Function() _getCpuInfo;
  late final Pointer<Utf8> Function() _getGpuInfo;
  late final Pointer<Utf8> Function() _getMemoryInfo;
  late final Pointer<Utf8> Function() _getDiskInfo;
  late final Pointer<Utf8> Function() _getNetworkInfo;
  late final Pointer<Utf8> Function() _getDriversInfo;

  static DynamicLibrary _loadLibrary() {
    final envPath = Platform.environment['NANOOKJARO_CORE_PATH'];
    if (envPath != null && envPath.isNotEmpty) {
      final provided = File(envPath);
      if (!provided.existsSync()) {
        throw StateError(
          'NANOOKJARO_CORE_PATH is set to "$envPath" but no file exists at that path.',
        );
      }
      return DynamicLibrary.open(provided.path);
    }

    final searchRoots = _collectSearchRoots();
    const relativeCandidates = <String>{
      'libnanookjaro_core.so',
      'lib/libnanookjaro_core.so',
      'build/libnanookjaro_core.so',
      'build/backend/libnanookjaro_core.so',
      'backend/build/libnanookjaro_core.so',
      'backend/libnanookjaro_core.so',
      'linux/libnanookjaro_core.so',
    };

    final existingCandidates = <String>[];
    for (final root in searchRoots) {
      for (final relative in relativeCandidates) {
        final candidate = File(_joinPath(root, relative));
        if (!candidate.existsSync()) {
          continue;
        }
        if (!existingCandidates.contains(candidate.path)) {
          existingCandidates.add(candidate.path);
        }
      }
    }

    final attemptedPaths = <String>[];
    for (final candidate in existingCandidates) {
      attemptedPaths.add(candidate);
      try {
        return DynamicLibrary.open(candidate);
      } catch (_) {
        continue;
      }
    }

    attemptedPaths.add('libnanookjaro_core.so (system library paths)');
    try {
      return DynamicLibrary.open('libnanookjaro_core.so');
    } catch (_) {
    }

    final buffer = StringBuffer('Unable to locate libnanookjaro_core shared library.\n');
    buffer.writeln('Set NANOOKJARO_CORE_PATH to the absolute path of libnanookjaro_core.so, ');
    buffer.writeln('or build the native core via `cmake --build build --target nanookjaro_core`.');
    if (attemptedPaths.isNotEmpty) {
      buffer.writeln('Checked locations:');
      for (final path in attemptedPaths) {
        buffer.writeln('  • $path');
      }
    }
    throw StateError(buffer.toString());
  }

  static Set<String> _collectSearchRoots() {
    final roots = <String>{};

    void addPath(String? path) {
      if (path == null || path.isEmpty) {
        return;
      }
      _walkParents(Directory(path), roots);
    }

    addPath(Directory.current.path);
    try {
      addPath(File(Platform.resolvedExecutable).parent.path);
    } catch (_) {
    }
    if (Platform.script.scheme == 'file') {
      try {
        addPath(File(Platform.script.toFilePath()).parent.path);
      } catch (_) {
      }
    }

    return roots;
  }

  static void _walkParents(Directory directory, Set<String> accumulator) {
    var current = directory;
    while (true) {
      final path = current.path;
      if (!accumulator.add(path)) {
        break;
      }
      final parent = current.parent;
      if (parent.path == path) {
        break;
      }
      current = parent;
    }
  }

  static String _joinPath(String base, String relative) {
    if (relative.isEmpty) {
      return base;
    }
    if (relative.startsWith(Platform.pathSeparator) || relative.startsWith('/')) {
      return relative;
    }
    final needsSeparator = !base.endsWith(Platform.pathSeparator);
    final separator = needsSeparator ? Platform.pathSeparator : '';
    return '$base$separator$relative';
  }

  String getSystemSummaryJson() => _invokeString(_getSystemSummary);

  String pacmanSyncUpgradeJson({bool assumeYes = false}) {
    return _invokeString(() => _pacmanSyncUpgrade(assumeYes ? 1 : 0));
  }

  String pacmanListUpdatesJson() => _invokeString(_pacmanListUpdates);

  Map<String, dynamic> setProxy({String? http, String? https}) {
    final httpPtr = (http ?? '').toNativeUtf8();
    final httpsPtr = (https ?? '').toNativeUtf8();
    Pointer<Utf8>? response;
    try {
      response = _setProxy(httpPtr, httpsPtr);
      if (response == nullptr || response.address == 0) {
        return {'ok': false, 'error': 'null_pointer'};
      }
      final jsonString = response.toDartString();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } finally {
      malloc.free(httpPtr);
      malloc.free(httpsPtr);
      if (response != null && response != nullptr && response.address != 0) {
        _freeString(response);
      }
    }
  }

  String getCpuInfoJson() => _invokeString(_getCpuInfo);

  String getGpuInfoJson() => _invokeString(_getGpuInfo);

  String getMemoryInfoJson() => _invokeString(_getMemoryInfo);

  String getDiskInfoJson() => _invokeString(_getDiskInfo);

  String getNetworkInfoJson() => _invokeString(_getNetworkInfo);

  String getDriversInfoJson() => _invokeString(_getDriversInfo);

  String _invokeString(Pointer<Utf8> Function() fn) {
    final pointer = fn();
    try {
      if (pointer == nullptr || pointer.address == 0) {
        return jsonEncode({'error': 'null_pointer'});
      }
      return pointer.toDartString();
    } finally {
      if (pointer != nullptr && pointer.address != 0) {
        _freeString(pointer);
      }
    }
  }
}
