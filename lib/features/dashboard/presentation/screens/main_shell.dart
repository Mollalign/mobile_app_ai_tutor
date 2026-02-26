import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../core/services/tutorial_service.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../conversations/presentation/providers/providers.dart';
import '../../../projects/presentation/providers/providers.dart';
import '../providers/providers.dart';
import 'home_tab.dart';
import 'projects_tab.dart';
import 'chat_tab.dart';
import 'profile_tab.dart';

/// GlobalKeys exposed so the tutorial can target nav items.
final navHomeKey = GlobalKey();
final navProjectsKey = GlobalKey();
final navChatKey = GlobalKey();
final navProfileKey = GlobalKey();

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => MainShellState();
}

class MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  bool _tutorialTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  void _refreshData() {
    try {
      ref
          .read(projectsNotifierProvider.notifier)
          .loadProjects(refresh: true);
      ref.read(conversationsNotifierProvider).loadConversations(refresh: true);
    } catch (_) {}
  }

  Future<void> _maybeShowTutorial() async {
    if (_tutorialTriggered) return;
    _tutorialTriggered = true;

    final service = ref.read(tutorialServiceProvider);
    final shouldShow = await service.shouldShowTutorial();
    if (!shouldShow || !mounted) return;

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    _showTutorial();
  }

  void _showTutorial() {
    final colorScheme = Theme.of(context).colorScheme;
    final service = ref.read(tutorialServiceProvider);

    final targets = [
      buildTarget(
        key: navHomeKey,
        title: 'Dashboard',
        description:
            'Your home screen. See your stats, recent conversations, '
            'and projects at a glance.',
        icon: LucideIcons.home,
        color: colorScheme.primary,
        align: ContentAlign.top,
      ),
      buildTarget(
        key: navProjectsKey,
        title: 'Projects',
        description:
            'Create projects for each course or topic. Upload documents '
            'and the AI will learn from your materials.',
        icon: LucideIcons.folderOpen,
        color: colorScheme.secondary,
        align: ContentAlign.top,
      ),
      buildTarget(
        key: navChatKey,
        title: 'Chat with AI',
        description:
            'Ask questions, get explanations, and learn at your own pace. '
            'The AI adapts to your level.',
        icon: LucideIcons.messageCircle,
        color: colorScheme.tertiary,
        align: ContentAlign.top,
      ),
      buildTarget(
        key: navProfileKey,
        title: 'Your Profile',
        description:
            'Customize your learning preferences, change theme, '
            'and manage your account.',
        icon: LucideIcons.user,
        color: colorScheme.primary,
        align: ContentAlign.top,
      ),
    ];

    service.showCoachMark(
      context: context,
      targets: targets,
    );
  }

  /// Called from profile tab to replay the tutorial.
  void replayTutorial() {
    final service = ref.read(tutorialServiceProvider);
    service.resetTutorial().then((_) {
      ref.read(tabControllerProvider.notifier).goToHome();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showTutorial();
      });
    });
  }

  static const _navItems = [
    _NavItem(
        icon: LucideIcons.home,
        activeIcon: LucideIcons.home,
        label: 'Home'),
    _NavItem(
        icon: LucideIcons.folderOpen,
        activeIcon: LucideIcons.folder,
        label: 'Projects'),
    _NavItem(
        icon: LucideIcons.messageCircle,
        activeIcon: LucideIcons.messageSquare,
        label: 'Chat'),
    _NavItem(
        icon: LucideIcons.user,
        activeIcon: LucideIcons.userCircle,
        label: 'Profile'),
  ];

  static final _navKeys = [
    navHomeKey,
    navProjectsKey,
    navChatKey,
    navProfileKey,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = ref.watch(tabControllerProvider);

    const tabs = [
      HomeTab(),
      ProjectsTab(),
      ChatTab(),
      ProfileTab(),
    ];

    return Scaffold(
      body: OfflineAwareBody(
        child: IndexedStack(
          index: currentIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? colorScheme.outlineVariant.withAlpha(38)
                : colorScheme.outlineVariant.withAlpha(128),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 51 : 20),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = currentIndex == index;

                return Expanded(
                  child: _NavBarItem(
                    key: _navKeys[index],
                    item: item,
                    isSelected: isSelected,
                    onTap: () {
                      if (currentIndex != index) {
                        HapticFeedback.lightImpact();
                      }
                      ref.read(tabControllerProvider.notifier).setTab(index);
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: item.label,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 54,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withAlpha(26)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 22,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
