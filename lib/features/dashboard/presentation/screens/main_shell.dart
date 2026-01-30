import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/providers.dart';
import 'home_tab.dart';
import 'projects_tab.dart';
import 'chat_tab.dart';
import 'profile_tab.dart';

/// Main shell with bottom navigation.
/// 
/// This is the primary scaffold that contains all authenticated screens.
/// Uses IndexedStack to preserve state when switching tabs.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = ref.watch(tabControllerProvider);

    // Tabs are kept in memory via IndexedStack to preserve state
    const tabs = [
      HomeTab(),
      ProjectsTab(),
      ChatTab(),
      ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: isDark 
                  ? colorScheme.outlineVariant.withAlpha(51)
                  : colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            ref.read(tabControllerProvider.notifier).setTab(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.home),
              selectedIcon: Icon(LucideIcons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.folderOpen),
              selectedIcon: Icon(LucideIcons.folderOpen),
              label: 'Projects',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.messageCircle),
              selectedIcon: Icon(LucideIcons.messageCircle),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.user),
              selectedIcon: Icon(LucideIcons.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
