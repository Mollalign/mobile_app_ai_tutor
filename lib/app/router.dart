import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/providers.dart';
import '../features/auth/presentation/screens/screens.dart';
import '../features/dashboard/presentation/screens/screens.dart';
import '../features/projects/presentation/screens/screens.dart';

/// App route paths.
class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyResetCode = '/verify-reset-code';
  static const String resetPassword = '/reset-password';
  
  // Main app routes
  static const String home = '/home';
  static const String projectDetail = '/projects/:id';
  
  // Future routes (will be added as features are built)
  // static const String conversation = '/conversations/:id';
}

/// Router provider.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Redirect based on auth state
    redirect: (context, state) {
      // Password reset routes don't need auth
      final isPasswordResetRoute = 
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.verifyResetCode ||
          state.matchedLocation == AppRoutes.resetPassword;

      final isOnAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          isPasswordResetRoute;
      final isOnSplash = state.matchedLocation == AppRoutes.splash;

      // Handle different auth states
      return authState.when(
        initial: () => null,
        loading: () => null,
        authenticated: (_) {
          if (isOnAuthPage || isOnSplash) {
            return AppRoutes.home;
          }
          return null;
        },
        unauthenticated: () {
          if (!isOnAuthPage && !isOnSplash) {
            return AppRoutes.login;
          }
          if (isOnSplash) {
            return AppRoutes.login;
          }
          return null;
        },
        error: (_) {
          if (!isOnAuthPage) {
            return AppRoutes.login;
          }
          return null;
        },
      );
    },

    routes: [
      // ============================================
      // Auth Routes
      // ============================================
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyResetCode,
        builder: (context, state) => const VerifyResetCodeScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      
      // ============================================
      // Main App Routes (with bottom navigation)
      // ============================================
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainShell(),
      ),
      
      // ============================================
      // Project Routes
      // ============================================
      GoRoute(
        path: AppRoutes.projectDetail,
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return ProjectDetailScreen(projectId: projectId);
        },
      ),
    ],
  );
});
