import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';

/// Application theme configuration with Material 3 design system.
/// 
/// Primary: Indigo/Royal Blue - Professional, trustworthy AI-education aesthetic
/// Secondary: Teal/Emerald - Fresh, growth-oriented accent
class AppTheme {
  AppTheme._();

  // ============================================
  // BRAND COLORS
  // ============================================

  // Primary - Indigo/Royal Blue
  static const Color _primaryLight = Color(0xFF4F46E5);
  static const Color _primaryDark = Color(0xFF818CF8);

  // Secondary - Teal/Emerald  
  static const Color _secondaryLight = Color(0xFF14B8A6);
  static const Color _secondaryDark = Color(0xFF2DD4BF);

  // Tertiary - Success/Positive actions
  static const Color _tertiaryLight = Color(0xFF10B981);
  static const Color _tertiaryDark = Color(0xFF34D399);

  // Error
  static const Color _errorLight = Color(0xFFDC2626);
  static const Color _errorDark = Color(0xFFF87171);

  // ============================================
  // COLOR SCHEMES
  // ============================================

  static ColorScheme get _lightColorScheme => ColorScheme(
        brightness: Brightness.light,
        // Primary
        primary: _primaryLight,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE0E7FF),
        onPrimaryContainer: const Color(0xFF1E1B4B),
        // Secondary
        secondary: _secondaryLight,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFCCFBF1),
        onSecondaryContainer: const Color(0xFF134E4A),
        // Tertiary (Success)
        tertiary: _tertiaryLight,
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFD1FAE5),
        onTertiaryContainer: const Color(0xFF064E3B),
        // Error
        error: _errorLight,
        onError: Colors.white,
        errorContainer: const Color(0xFFFEE2E2),
        onErrorContainer: const Color(0xFF7F1D1D),
        // Background & Surface
        surface: const Color(0xFFFAFAFA),
        onSurface: const Color(0xFF1F2937),
        surfaceContainerHighest: const Color(0xFFF3F4F6),
        onSurfaceVariant: const Color(0xFF6B7280),
        // Outline
        outline: const Color(0xFFD1D5DB),
        outlineVariant: const Color(0xFFE5E7EB),
        // Inverse
        inverseSurface: const Color(0xFF1F2937),
        onInverseSurface: const Color(0xFFF9FAFB),
        inversePrimary: _primaryDark,
        // Shadow & Scrim
        shadow: Colors.black,
        scrim: Colors.black,
      );

  static ColorScheme get _darkColorScheme => ColorScheme(
        brightness: Brightness.dark,
        // Primary
        primary: _primaryDark,
        onPrimary: const Color(0xFF1E1B4B),
        primaryContainer: const Color(0xFF3730A3),
        onPrimaryContainer: const Color(0xFFE0E7FF),
        // Secondary
        secondary: _secondaryDark,
        onSecondary: const Color(0xFF134E4A),
        secondaryContainer: const Color(0xFF0F766E),
        onSecondaryContainer: const Color(0xFFCCFBF1),
        // Tertiary (Success)
        tertiary: _tertiaryDark,
        onTertiary: const Color(0xFF064E3B),
        tertiaryContainer: const Color(0xFF047857),
        onTertiaryContainer: const Color(0xFFD1FAE5),
        // Error
        error: _errorDark,
        onError: const Color(0xFF7F1D1D),
        errorContainer: const Color(0xFFB91C1C),
        onErrorContainer: const Color(0xFFFEE2E2),
        // Background & Surface
        surface: const Color(0xFF111827),
        onSurface: const Color(0xFFF9FAFB),
        surfaceContainerHighest: const Color(0xFF1F2937),
        onSurfaceVariant: const Color(0xFF9CA3AF),
        // Outline
        outline: const Color(0xFF4B5563),
        outlineVariant: const Color(0xFF374151),
        // Inverse
        inverseSurface: const Color(0xFFF9FAFB),
        onInverseSurface: const Color(0xFF1F2937),
        inversePrimary: _primaryLight,
        // Shadow & Scrim
        shadow: Colors.black,
        scrim: Colors.black,
      );

  // ============================================
  // LIGHT THEME
  // ============================================

  static ThemeData get light {
    final colorScheme = _lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      // Scaffold
      scaffoldBackgroundColor: colorScheme.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLg,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        color: colorScheme.surface,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: AppSpacing.md,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 56),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLg,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXl,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        actionTextColor: colorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusMd,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusSm,
        ),
      ),
    );
  }

  // ============================================
  // DARK THEME
  // ============================================

  static ThemeData get dark {
    final colorScheme = _darkColorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      // Scaffold
      scaffoldBackgroundColor: colorScheme.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLg,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        color: colorScheme.surfaceContainerHighest,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: AppSpacing.md,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 56),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLg,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXl,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        actionTextColor: colorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusMd,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusSm,
        ),
      ),
    );
  }
}