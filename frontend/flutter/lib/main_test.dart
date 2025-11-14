import 'package:flutter/material.dart';
import 'package:nanookjaro_frontend/services/ffi_bridge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FFI Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('FFI Test')),
        body: const TestWidget(),
      ),
    );
  }
}

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  String _result = 'Testing...';

  @override
  void initState() {
    super.initState();
    _testFFI();
  }

  void _testFFI() async {
    try {
      print('Creating NanookjaroBridge instance...');
      final bridge = NanookjaroBridge.instance;
      print('Bridge created successfully');
      
      print('Calling getSystemSummaryJson...');
      final systemSummary = bridge.getSystemSummaryJson();
      print('System summary: $systemSummary');
      
      print('Calling getCpuInfoJson...');
      final cpuInfo = bridge.getCpuInfoJson();
      print('CPU info length: ${cpuInfo.length}');
      
      print('Calling getGpuInfoJson...');
      final gpuInfo = bridge.getGpuInfoJson();
      print('GPU info length: ${gpuInfo.length}');
      
      setState(() {
        _result = 'All tests passed!\nSystem summary length: ${systemSummary.length}\nCPU info length: ${cpuInfo.length}\nGPU info length: ${gpuInfo.length}';
      });
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(_result),
    );
  }
}