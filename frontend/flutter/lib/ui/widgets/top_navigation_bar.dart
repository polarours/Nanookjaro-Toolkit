import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class TopNavigationBar extends ConsumerWidget implements PreferredSizeWidget {
  const TopNavigationBar({super.key, this.onSearch});

  final void Function(String query)? onSearch;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final showSearch = width >= 600;
    final searchWidth = showSearch ? math.max(180.0, math.min(280.0, width * 0.4)) : 0.0;
    final localeMode = ref.watch(localeControllerProvider);
    final loc = AppLocalizations.of(context);
    return AppBar(
      titleSpacing: 24,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.ac_unit_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              loc.appTitle,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (showSearch)
          SizedBox(
            width: searchWidth,
            child: TextField(
              decoration: InputDecoration(
                hintText: loc.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.surface.withValues(alpha: 0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: onSearch,
            ),
          ),
        if (showSearch) const SizedBox(width: 16),
        PopupMenuButton<AppLocaleMode>(
          tooltip: loc.languageMenu,
          icon: const Icon(Icons.language_rounded),
          initialValue: localeMode,
          onSelected: (mode) => ref.read(localeControllerProvider.notifier).setMode(mode),
          itemBuilder: (context) => [
            PopupMenuItem<AppLocaleMode>(
              value: AppLocaleMode.system,
              child: Text(loc.languageSystem),
            ),
            PopupMenuItem<AppLocaleMode>(
              value: AppLocaleMode.english,
              child: Text(loc.languageEnglish),
            ),
            PopupMenuItem<AppLocaleMode>(
              value: AppLocaleMode.chinese,
              child: Text(loc.languageChinese),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.secondary,
          child: const Icon(Icons.person_outline, color: Colors.white),
        ),
        const SizedBox(width: 24),
      ],
    );
  }
}
