import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/providers.dart';
import 'onboarding_screen.dart';

const _kOnboardingKey = 'onboarding_complete';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _showOnboarding = false;
  String _statusText = 'Loading...';

  @override
  void initState() {
    super.initState();
    _init();
    _scheduleStatusUpdates();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(_kOnboardingKey) ?? false;

    if (!onboardingDone) {
      if (mounted) setState(() => _showOnboarding = true);
      return;
    }

    _startAuthCheck();
  }

  void _startAuthCheck() {
    ref.read(authNotifierProvider.notifier).checkAuthStatus();
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kOnboardingKey, true);
    } catch (_) {}
    if (mounted) {
      setState(() => _showOnboarding = false);
      _startAuthCheck();
    }
  }

  void _scheduleStatusUpdates() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _statusText = 'Checking your session...');
    });
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() => _statusText = 'Taking longer than expected...');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

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
                const AppLogo(size: 96)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .then()
                    .shimmer(
                      duration: 1500.ms,
                      color: colorScheme.primary.withAlpha(51),
                    ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'AI Tutor',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your personalized learning companion',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                const SizedBox(height: AppSpacing.xxl),
                authState.when(
                  initial: () => _buildLoadingState(colorScheme, textTheme),
                  loading: () => _buildLoadingState(colorScheme, textTheme),
                  authenticated: (_) =>
                      _buildLoadingState(colorScheme, textTheme),
                  unauthenticated: () =>
                      _buildLoadingState(colorScheme, textTheme),
                  error: (message) => _buildErrorState(
                    context, ref, message, colorScheme, textTheme,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _statusText,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withAlpha(140),
            fontSize: 12,
          ),
        ).animate().fadeIn(duration: 300.ms),
      ],
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              LucideIcons.alertTriangle,
              color: colorScheme.error,
              size: 24,
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
              onPressed: () =>
                  ref.read(authNotifierProvider.notifier).checkAuthStatus(),
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}
