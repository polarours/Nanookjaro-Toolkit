import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLocaleMode { system, english, chinese }

class LocaleController extends StateNotifier<AppLocaleMode> {
  LocaleController() : super(AppLocaleMode.system);

  void setMode(AppLocaleMode mode) {
    state = mode;
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, AppLocaleMode>((ref) => LocaleController());

Locale? mapLocaleMode(AppLocaleMode mode) {
  switch (mode) {
    case AppLocaleMode.system:
      return null;
    case AppLocaleMode.english:
      return const Locale('en');
    case AppLocaleMode.chinese:
      return const Locale('zh');
  }
}
