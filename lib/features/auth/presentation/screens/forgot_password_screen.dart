import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Screen for entering email to request password reset.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(passwordResetNotifierProvider.notifier).requestCode(
        email: _emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetNotifierProvider);
    final isLoading = state is PasswordResetLoading;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Listen for state changes
    ref.listen<PasswordResetState>(passwordResetNotifierProvider, (previous, next) {
      next.whenOrNull(
        codeSent: (email) {
          // Navigate to verify code screen
          context.go(AppRoutes.verifyResetCode);
        },
        error: (message, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(passwordResetNotifierProvider.notifier).reset();
            context.go(AppRoutes.login);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withAlpha(15),
              colorScheme.surface,
            ],
            stops: const [0.0, 0.25],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.paddingAllLg,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // Icon
                  Container(
                    padding: AppSpacing.paddingAllMd,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Title
                  Text(
                    'Forgot Password?',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Description
                  Text(
                    "Enter your email address and we'll send you a code to reset your password.",
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: Validators.email,
                    enabled: !isLoading,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSubmit(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Submit button
                  AuthButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    isLoading: isLoading,
                    label: 'Send Reset Code',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}