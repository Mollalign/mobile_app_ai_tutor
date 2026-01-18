import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
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
      const SnackBar(content: Text('New code sent!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetNotifierProvider);
    final isLoading = state is PasswordResetLoading;

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
              backgroundColor: Theme.of(context).colorScheme.error,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Icon
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Check Your Email',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  'We sent a 6-digit code to\n${email ?? "your email"}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

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
                ),
                const SizedBox(height: 24),

                // Verify button
                AuthButton(
                  onPressed: isLoading || email == null
                      ? null
                      : () => _handleSubmit(email),
                  isLoading: isLoading,
                  label: 'Verify Code',
                ),
                const SizedBox(height: 16),

                // Resend link
                Center(
                  child: TextButton(
                    onPressed: isLoading || email == null
                        ? null
                        : () => _handleResend(email),
                    child: const Text("Didn't receive code? Resend"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}