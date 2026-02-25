import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/providers.dart';
import '../features/auth/presentation/screens/screens.dart';
import '../features/conversations/presentation/screens/screens.dart';
import '../features/dashboard/presentation/screens/screens.dart';
import '../features/projects/presentation/screens/screens.dart';
import '../features/sharing/presentation/screens/screens.dart';

/// Fade-through page transition for top-level routes.
CustomTransitionPage<void> _fadeThroughPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
        child: child,
      );
    },
  );
}

/// Slide-up page transition for detail/push routes.
CustomTransitionPage<void> _slideUpPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        ),
      );
    },
  );
}

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
  static const String conversations = '/conversations';
  static const String chat = '/conversations/:id';
  
  // Sharing routes
  static const String myShares = '/my-shares';
  static const String sharedConversationPath = '/shared/:token';
  
  /// Generate shared conversation route with token
  static String sharedConversation(String token) => '/shared/$token';
}

/// Listenable adapter that bridges Riverpod state changes to GoRouter's
/// refreshListenable so the router can re-evaluate redirects without
/// being fully recreated.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (_, _) {
      notifyListeners();
    });
  }
}

/// Router provider -- creates the GoRouter once and uses refreshListenable
/// to re-evaluate redirects when auth state changes.
final routerProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authChangeNotifier,

    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      final isPasswordResetRoute = 
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.verifyResetCode ||
          state.matchedLocation == AppRoutes.resetPassword;

      final isOnAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          isPasswordResetRoute;
      final isOnSplash = state.matchedLocation == AppRoutes.splash;

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
      // Auth Routes
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _fadeThroughPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _fadeThroughPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => _fadeThroughPage(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => _slideUpPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.verifyResetCode,
        pageBuilder: (context, state) => _slideUpPage(
          key: state.pageKey,
          child: const VerifyResetCodeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        pageBuilder: (context, state) => _slideUpPage(
          key: state.pageKey,
          child: const ResetPasswordScreen(),
        ),
      ),
      
      // Main App Routes
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _fadeThroughPage(
          key: state.pageKey,
          child: const MainShell(),
        ),
      ),
      
      // Project Routes
      GoRoute(
        path: AppRoutes.projectDetail,
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return _slideUpPage(
            key: state.pageKey,
            child: ProjectDetailScreen(projectId: projectId),
          );
        },
      ),
      
      // Conversation Routes
      GoRoute(
        path: AppRoutes.chat,
        pageBuilder: (context, state) {
          final conversationId = state.pathParameters['id']!;
          return _slideUpPage(
            key: state.pageKey,
            child: ChatScreen(conversationId: conversationId),
          );
        },
      ),
      
      // Sharing Routes
      GoRoute(
        path: AppRoutes.myShares,
        pageBuilder: (context, state) => _slideUpPage(
          key: state.pageKey,
          child: const MySharesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.sharedConversationPath,
        pageBuilder: (context, state) {
          final token = state.pathParameters['token']!;
          return _slideUpPage(
            key: state.pageKey,
            child: SharedConversationScreen(shareToken: token),
          );
        },
      ),
    ],
  );
});
