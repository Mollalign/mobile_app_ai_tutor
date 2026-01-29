import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.borderRadiusLg,
              border: Border.all(
                color: colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withAlpha(180),
                      ],
                    ),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Center(
                    child: Text(
                      user?.initials ?? '?',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'User',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        user?.email ?? '',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Edit profile
                  },
                  icon: const Icon(LucideIcons.pencil),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

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

          _buildSettingsTile(
            context,
            icon: LucideIcons.palette,
            title: 'Appearance',
            subtitle: 'Theme, colors',
            onTap: () {
              // TODO: Appearance settings
            },
          ),

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

          const SizedBox(height: AppSpacing.xl),
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
}
