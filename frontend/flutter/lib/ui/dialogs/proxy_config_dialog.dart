import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/ffi_bridge.dart';

class ProxyConfigResult {
  const ProxyConfigResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class ProxyConfigDialog extends StatefulWidget {
  const ProxyConfigDialog({super.key, required this.initialHttp, required this.initialHttps});

  final String initialHttp;
  final String initialHttps;

  @override
  State<ProxyConfigDialog> createState() => _ProxyConfigDialogState();
}

class _ProxyConfigDialogState extends State<ProxyConfigDialog> {
  late final TextEditingController _httpController;
  late final TextEditingController _httpsController;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _httpController = TextEditingController(text: widget.initialHttp);
    _httpsController = TextEditingController(text: widget.initialHttps);
  }

  @override
  void dispose() {
    _httpController.dispose();
    _httpsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(loc.proxyDialogTitle),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.proxyDialogDescription),
            const SizedBox(height: 16),
            TextField(
              controller: _httpController,
              decoration: InputDecoration(
                labelText: loc.proxyFieldHttp,
                hintText: loc.proxyHint,
              ),
              enabled: !_busy,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _httpsController,
              decoration: InputDecoration(
                labelText: loc.proxyFieldHttps,
                hintText: loc.proxyHint,
              ),
              enabled: !_busy,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(loc.cancel),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _submit,
          icon: _busy
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.cloud_sync),
          label: Text(loc.apply),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final httpValue = _httpController.text.trim();
    final httpsValue = _httpsController.text.trim();
    bool success = false;
    late String message;
    try {
      final result = NanookjaroBridge.instance.setProxy(http: httpValue, https: httpsValue);
      success = result['ok'] == true;
      if (success) {
        message = (httpValue.isEmpty && httpsValue.isEmpty)
            ? AppLocalizations.of(context).proxyApplyCleared
            : AppLocalizations.of(context).proxyApplySuccess;
      } else {
        message = AppLocalizations.of(context)
            .proxyApplyFailed(result['error'] as String? ?? 'unknown');
      }
    } catch (error) {
      success = false;
      message = AppLocalizations.of(context).proxyApplyFailed(error);
    }
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    Navigator.of(context).pop(ProxyConfigResult(success: success, message: message));
  }
}
