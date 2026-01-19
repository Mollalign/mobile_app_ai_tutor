import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

/// Reusable text field for authentication forms.
/// 
/// Uses theme colors for consistent styling across light/dark modes.
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: colorScheme.onSurfaceVariant) 
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}