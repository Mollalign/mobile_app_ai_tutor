import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../providers/providers.dart';

/// Splash screen shown while checking authentication status.
/// 
/// Features a gradient background and animated logo for a premium feel.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withAlpha(25),
              colorScheme.surface,
              colorScheme.secondary.withAlpha(15),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo container with subtle shadow
                Container(
                  padding: AppSpacing.paddingAllLg,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(51),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // App name
                Text(
                  'Learn With AI-Tutor',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Tagline
                Text(
                  'Your personalized learning companion',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Loading indicator or error
                authState.when(
                  initial: () => _buildLoadingIndicator(colorScheme),
                  loading: () => _buildLoadingIndicator(colorScheme),
                  authenticated: (_) => _buildLoadingIndicator(colorScheme),
                  unauthenticated: () => _buildLoadingIndicator(colorScheme),
                  error: (message) => _buildErrorState(
                    context,
                    ref,
                    message,
                    colorScheme,
                    textTheme,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String message,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: AppSpacing.paddingHorizontalLg,
      child: Column(
        children: [
          Container(
            padding: AppSpacing.paddingAllMd,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: colorScheme.error,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).checkAuthStatus();
              },
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}