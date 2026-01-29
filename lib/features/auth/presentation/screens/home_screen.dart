import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../providers/providers.dart';

/// Home screen shown to authenticated users.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get user from authenticated state
    final user = authState.whenOrNull(
      authenticated: (user) => user,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Informatics Tutor'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              _showLogoutDialog(context, ref, colorScheme, textTheme);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withAlpha(10),
              colorScheme.surface,
            ],
            stops: const [0.0, 0.2],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.paddingAllLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingAllMd,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withAlpha(204),
                      ],
                    ),
                    borderRadius: AppRadius.borderRadiusLg,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(51),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.waving_hand,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withAlpha(204),
                                  ),
                                ),
                                Text(
                                  user?.firstName ?? 'User',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        user?.email ?? '',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(179),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Success placeholder content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: AppSpacing.paddingAllLg,
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.tertiary.withAlpha(51),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Authentication Complete!',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Padding(
                          padding: AppSpacing.paddingHorizontalLg,
                          child: Text(
                            'You have successfully set up\nFlutter authentication.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
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
            Icons.logout_rounded,
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}