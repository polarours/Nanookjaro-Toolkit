import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';
import 'pages/dashboard_page.dart';
import 'widgets/aurora_background.dart';
import 'widgets/log_drawer.dart';
import 'widgets/top_navigation_bar.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _drawerExpanded = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeControllerProvider);
    final loc = AppLocalizations.of(context);
    return Stack(
      children: [
        const Positioned.fill(child: AuroraBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: TopNavigationBar(
            onSearch: (query) {
            },
          ),
          body: const DashboardPage(),
          bottomSheet: AnimatedSlide(
            duration: const Duration(milliseconds: 260),
            offset: _drawerExpanded ? Offset.zero : const Offset(0, 1),
            curve: Curves.easeOutCubic,
            child: const LogDrawer(),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _drawerExpanded = !_drawerExpanded;
              });
            },
            icon: Icon(_drawerExpanded ? Icons.keyboard_arrow_down : Icons.subject_rounded),
            label: Text(_drawerExpanded ? loc.floatingButtonHide : loc.floatingButtonShow),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ],
    );
  }
}
