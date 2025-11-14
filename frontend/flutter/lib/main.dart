import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/app_shell.dart';
import 'ui/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: NanookjaroApp()));
}

class NanookjaroApp extends ConsumerWidget {
  const NanookjaroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final localeMode = ref.watch(localeControllerProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mapThemeMode(mode),
      locale: mapLocaleMode(localeMode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}