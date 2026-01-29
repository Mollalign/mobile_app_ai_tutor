import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Screen for entering new password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit(String email, String code) {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(passwordResetNotifierProvider.notifier).resetPassword(
        email: email,
        code: code,
        newPassword: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetNotifierProvider);
    final isLoading = state is PasswordResetLoading;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get email and code from state
    String? email;
    String? code;
    
    state.whenOrNull(
      codeVerified: (e, c) {
        email = e;
        code = c;
      },
    );

    // If no email/code, redirect back
    if ((email == null || code == null) && state is! PasswordResetLoading && state is! PasswordResetSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.forgotPassword);
      });
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: colorScheme.primary,
          ),
        ),
      );
    }

    // Listen for state changes
    ref.listen<PasswordResetState>(passwordResetNotifierProvider, (previous, next) {
      next.whenOrNull(
        success: () {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              icon: Container(
                padding: AppSpacing.paddingAllMd,
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: colorScheme.tertiary,
                  size: 48,
                ),
              ),
              title: const Text('Password Reset!'),
              content: Text(
                'Your password has been successfully reset. You can now log in with your new password.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(passwordResetNotifierProvider.notifier).reset();
                      context.go(AppRoutes.login);
                    },
                    child: const Text('Go to Login'),
                  ),
                ),
              ],
            ),
          );
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
            ref.read(passwordResetNotifierProvider.notifier).goBack();
            context.go(AppRoutes.verifyResetCode);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.tertiary.withAlpha(15),
              colorScheme.surface,
            ],
            stops: const [0.0, 0.25],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
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
                      color: colorScheme.tertiaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Title
                  Text(
                    'Create New Password',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Description
                  Text(
                    'Your new password must be different from previously used passwords.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // New password field
                  AuthTextField(
                    controller: _passwordController,
                    label: 'New Password',
                    hint: 'Enter new password',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: Validators.password,
                    enabled: !isLoading,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Confirm password field
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm new password',
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    enabled: !isLoading,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: email != null && code != null 
                        ? (_) => _handleSubmit(email!, code!) 
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Submit button
                  AuthButton(
                    onPressed: isLoading || email == null || code == null
                        ? null
                        : () => _handleSubmit(email!, code!),
                    isLoading: isLoading,
                    label: 'Reset Password',
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