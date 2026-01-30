import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'home_tab.dart';
import 'projects_tab.dart';
import 'chat_tab.dart';
import 'profile_tab.dart';

/// Main shell with bottom navigation.
/// 
/// This is the primary scaffold that contains all authenticated screens.
/// Uses IndexedStack to preserve state when switching tabs.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  // Tabs are kept in memory via IndexedStack to preserve state
  final List<Widget> _tabs = const [
    HomeTab(),
    ProjectsTab(),
    ChatTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
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
