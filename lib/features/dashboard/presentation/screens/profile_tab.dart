import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/router.dart';
import '../../../../app/theme_provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/providers/providers.dart';

/// Profile tab - shows user settings and account info.
/// 
/// Features:
/// - User info display
/// - Settings options
/// - Logout
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final user = authState.whenOrNull(
      authenticated: (user) => user,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient header with user info
          SliverAppBar(
            expandedHeight: 260,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      Color.lerp(colorScheme.primary, colorScheme.secondary, 0.6)!,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Avatar
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(38),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withAlpha(77),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user?.initials ?? '?',
                              style: textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          user?.fullName ?? 'User',
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          user?.email ?? '',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha(204),
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Settings list
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Settings Section
                Text(
                  'Settings',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

          _buildSettingsTile(
            context,
            icon: LucideIcons.share2,
            title: 'My Shared Links',
            subtitle: 'Manage your shared conversations',
            onTap: () {
              context.push(AppRoutes.myShares);
            },
          ),

          _buildSettingsTile(
            context,
            icon: LucideIcons.search,
            title: 'Browse Shared',
            subtitle: 'View a shared conversation by code',
            onTap: () {
              _showEnterShareCodeDialog(context);
            },
          ),

          _buildSettingsTile(
            context,
            icon: LucideIcons.brain,
            title: 'Learning Preferences',
            subtitle: 'Socratic mode, difficulty level',
            onTap: () {
              // TODO: Learning preferences
            },
          ),

          _buildSettingsTile(
            context,
            icon: LucideIcons.bell,
            title: 'Notifications',
            subtitle: 'Reminders and alerts',
            onTap: () {
              // TODO: Notifications settings
            },
          ),

          _buildThemeTile(context, ref),

          _buildSettingsTile(
            context,
            icon: LucideIcons.shield,
            title: 'Privacy & Security',
            subtitle: 'Password, data',
            onTap: () {
              // TODO: Privacy settings
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // Support Section
          Text(
            'Support',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          _buildSettingsTile(
            context,
            icon: LucideIcons.helpCircle,
            title: 'Help & FAQ',
            subtitle: 'Get help using the app',
            onTap: () {
              // TODO: Help screen
            },
          ),

          _buildSettingsTile(
            context,
            icon: LucideIcons.messageSquare,
            title: 'Send Feedback',
            subtitle: 'Tell us what you think',
            onTap: () {
              // TODO: Feedback
            },
          ),

          _buildSettingsTile(
            context,
            icon: LucideIcons.info,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {
              // TODO: About screen
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // Logout Button
          OutlinedButton.icon(
            onPressed: () => _showLogoutDialog(context, ref),
            icon: Icon(
              LucideIcons.logOut,
              color: colorScheme.error,
            ),
            label: Text(
              'Logout',
              style: TextStyle(color: colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.error.withAlpha(100)),
            ),
          ),

                const SizedBox(height: AppSpacing.xl + 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: Icon(
          icon,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodySmall,
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildThemeTile(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeMode = ref.watch(themeModeProvider);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: Icon(
          themeMode.icon,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        'Appearance',
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        themeMode.displayName,
        style: textTheme.bodySmall,
      ),
      trailing: _ThemeModeSelector(
        currentMode: themeMode,
        onChanged: (mode) {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
        },
      ),
      onTap: () => _showThemeBottomSheet(context, ref),
    );
  }

  void _showThemeBottomSheet(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentMode = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Choose Theme',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ...ThemeMode.values.map((mode) => RadioListTile<ThemeMode>(
              value: mode,
              // ignore: deprecated_member_use
              groupValue: currentMode,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
              title: Text(mode.displayName),
              secondary: Icon(mode.icon),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusMd,
              ),
            )),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Container(
          padding: AppSpacing.paddingAllMd,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.logOut,
            color: colorScheme.error,
            size: 28,
          ),
        ),
        title: const Text('Logout'),
        content: Text(
          'Are you sure you want to logout?',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  
  void _showEnterShareCodeDialog(BuildContext context) {
    final controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.search, color: colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            const Text('Browse Shared'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the share code to view a shared conversation:',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Paste share code here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(LucideIcons.key),
              ),
              textInputAction: TextInputAction.go,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.pop(context);
                  context.push(AppRoutes.sharedConversation(value.trim()));
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                context.push(AppRoutes.sharedConversation(code));
              }
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}

/// Compact theme mode selector widget.
class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderRadiusSm,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ThemeMode.values.map((mode) {
          final isSelected = mode == currentMode;
          return GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? colorScheme.primary 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                mode.icon,
                size: 16,
                color: isSelected 
                    ? colorScheme.onPrimary 
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
