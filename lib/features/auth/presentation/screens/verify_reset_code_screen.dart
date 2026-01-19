import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Screen for entering the 6-digit reset code.
class VerifyResetCodeScreen extends ConsumerStatefulWidget {
  const VerifyResetCodeScreen({super.key});

  @override
  ConsumerState<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends ConsumerState<VerifyResetCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleSubmit(String email) {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(passwordResetNotifierProvider.notifier).verifyCode(
        email: email,
        code: _codeController.text.trim(),
      );
    }
  }

  void _handleResend(String email) {
    ref.read(passwordResetNotifierProvider.notifier).requestCode(email: email);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('New code sent!'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetNotifierProvider);
    final isLoading = state is PasswordResetLoading;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get email from state using pattern matching
    final email = switch (state) {
      PasswordResetCodeSent(:final email) => email,
      PasswordResetCodeVerified(:final email, code: _) => email,
      _ => null,
    };

    // If no email, redirect back
    if (email == null && state is! PasswordResetLoading) {
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
      switch (next) {
        case PasswordResetCodeVerified():
          context.go(AppRoutes.resetPassword);
        case PasswordResetError(:final message, failedStep: _):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: colorScheme.error,
            ),
          );
        default:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(passwordResetNotifierProvider.notifier).goBack();
            context.go(AppRoutes.forgotPassword);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.secondary.withAlpha(15),
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
                      color: colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      size: 48,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Title
                  Text(
                    'Check Your Email',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Description
                  Text(
                    'We sent a 6-digit code to\n${email ?? "your email"}',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Code input field
                  AuthTextField(
                    controller: _codeController,
                    label: 'Verification Code',
                    hint: 'Enter 6-digit code',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.pin_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the code';
                      }
                      if (value.length != 6) {
                        return 'Code must be 6 digits';
                      }
                      if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                        return 'Code must contain only digits';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: email != null ? (_) => _handleSubmit(email) : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Verify button
                  AuthButton(
                    onPressed: isLoading || email == null
                        ? null
                        : () => _handleSubmit(email),
                    isLoading: isLoading,
                    label: 'Verify Code',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Resend link
                  Center(
                    child: TextButton(
                      onPressed: isLoading || email == null
                          ? null
                          : () => _handleResend(email),
                      child: Text(
                        "Didn't receive code? Resend",
                        style: TextStyle(
                          color: isLoading || email == null
                              ? colorScheme.onSurfaceVariant.withAlpha(128)
                              : colorScheme.primary,
                        ),
                      ),
                    ),
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