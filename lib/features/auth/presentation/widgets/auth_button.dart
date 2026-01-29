import 'package:flutter/material.dart';

/// Reusable button for authentication forms.
/// 
/// Uses theme colors for consistent styling across light/dark modes.
class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final bool isOutlined;

  const AuthButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    required this.label,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(theme),
      );
    }
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(theme),
    );
  }

  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.onPrimary,
          ),
        ),
      );
    }
    return Text(label);
  }
}