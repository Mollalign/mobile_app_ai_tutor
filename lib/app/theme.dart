import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


/// Application theme configuration - "Academic Zen" aesthetic.
/// 
/// Design Philosophy:
/// - Obsidian Intelligence palette for dark mode
/// - Clean, calm, and limitless feel
/// - Typography: Inter (precise, readable)
/// - Teal accent for brand identity (Informatics/growth)
class AppTheme {
  AppTheme._();

  // ============================================
  // OBSIDIAN INTELLIGENCE PALETTE
  // ============================================

  // Background tones
  static const Color _bgDark = Color(0xFF09090B);        // Rich deep charcoal
  static const Color _surfaceDark = Color(0xFF18181B);   // Slightly lighter
  static const Color _surfaceElevatedDark = Color(0xFF27272A);  // Cards/elevated
  
  // Light mode backgrounds
  static const Color _bgLight = Color(0xFFFAFAFA);       // Off-white
  static const Color _surfaceLight = Color(0xFFFFFFFF);  // Pure white
  static const Color _surfaceElevatedLight = Color(0xFFF4F4F5);  // Light gray

  // Primary - Teal (Brand identity: science, growth, intelligence)
  static const Color _primaryLight = Color(0xFF0D9488);  // Teal 600
  static const Color _primaryDark = Color(0xFF14B8A6);   // Teal 500

  // Secondary - Indigo (Depth, wisdom, AI)
  static const Color _secondaryLight = Color(0xFF4F46E5);  // Indigo 600
  static const Color _secondaryDark = Color(0xFF6366F1);   // Indigo 500

  // Tertiary - Amber/Gold (Highlights, Socratic mode, achievement)
  static const Color _tertiaryLight = Color(0xFFD97706);   // Amber 600
  static const Color _tertiaryDark = Color(0xFFFBBF24);    // Amber 400

  // Text colors
  static const Color _textPrimaryDark = Color(0xFFF4F4F5);   // Off-white
  static const Color _textSecondaryDark = Color(0xFFA1A1AA); // Cool grey
  static const Color _textPrimaryLight = Color(0xFF09090B);  // Rich black
  static const Color _textSecondaryLight = Color(0xFF71717A); // Zinc 500

  // Error
  static const Color _errorLight = Color(0xFFDC2626);  // Red 600
  static const Color _errorDark = Color(0xFFF87171);   // Red 400

  // Borders/outlines
  static const Color _borderDark = Color(0xFF27272A);    // Zinc 800
  static const Color _borderLight = Color(0xFFE4E4E7);   // Zinc 200
  
  // ============================================
  // TEXT THEME - Inter (Precision & Clarity)
  // ============================================

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final headingColor = colorScheme.onSurface;
    final bodyColor = colorScheme.onSurface;
    final mutedColor = colorScheme.onSurfaceVariant;

    return TextTheme(
      // Display styles - Large, impactful
      displayLarge: GoogleFonts.inter(
        fontSize: 56,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.5,
        height: 1.1,
        color: headingColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 44,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.15,
        color: headingColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.2,
        color: headingColor,
      ),
      
      // Headline styles - Section headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.25,
        color: headingColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.3,
        color: headingColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
        color: headingColor,
      ),
      
      // Title styles - Cards, dialogs
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: headingColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.5,
        color: headingColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
        color: headingColor,
      ),
      
      // Body styles - Main content, chat messages
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.6,
        color: bodyColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.55,
        color: bodyColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.5,
        color: mutedColor,
      ),
      
      // Label styles - Buttons, chips, tags
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: bodyColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        height: 1.35,
        color: bodyColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        height: 1.3,
        color: mutedColor,
      ),
    );
  }

  // ============================================
  // LIGHT COLOR SCHEME
  // ============================================

  static ColorScheme get _lightColorScheme => ColorScheme(
    brightness: Brightness.light,
    // Primary - Teal
    primary: _primaryLight,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFCCFBF1),    // Teal 100
    onPrimaryContainer: const Color(0xFF042F2E),  // Teal 950
    // Secondary - Indigo
    secondary: _secondaryLight,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFE0E7FF),  // Indigo 100
    onSecondaryContainer: const Color(0xFF1E1B4B), // Indigo 950
    // Tertiary - Amber
    tertiary: _tertiaryLight,
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFFEF3C7),   // Amber 100
    onTertiaryContainer: const Color(0xFF451A03), // Amber 950
    // Error
    error: _errorLight,
    onError: Colors.white,
    errorContainer: const Color(0xFFFEE2E2),      // Red 100
    onErrorContainer: const Color(0xFF7F1D1D),    // Red 900
    // Surface
    surface: _surfaceLight,
    onSurface: _textPrimaryLight,
    surfaceContainerHighest: _surfaceElevatedLight,
    onSurfaceVariant: _textSecondaryLight,
    // Outline
    outline: _borderLight,
    outlineVariant: const Color(0xFFF4F4F5),      // Zinc 100
    // Inverse
    inverseSurface: _bgDark,
    onInverseSurface: _textPrimaryDark,
    inversePrimary: _primaryDark,
    // Shadow & Scrim
    shadow: Colors.black.withAlpha(13),
    scrim: Colors.black.withAlpha(51),
  );

  // ============================================
  // DARK COLOR SCHEME - Obsidian Intelligence
  // ============================================

  static ColorScheme get _darkColorScheme => ColorScheme(
    brightness: Brightness.dark,
    // Primary - Teal
    primary: _primaryDark,
    onPrimary: const Color(0xFF042F2E),
    primaryContainer: const Color(0xFF115E59),    // Teal 800
    onPrimaryContainer: const Color(0xFF99F6E4),  // Teal 200
    // Secondary - Indigo
    secondary: _secondaryDark,
    onSecondary: const Color(0xFF1E1B4B),
    secondaryContainer: const Color(0xFF3730A3),  // Indigo 800
    onSecondaryContainer: const Color(0xFFC7D2FE), // Indigo 200
    // Tertiary - Amber
    tertiary: _tertiaryDark,
    onTertiary: const Color(0xFF451A03),
    tertiaryContainer: const Color(0xFF92400E),   // Amber 800
    onTertiaryContainer: const Color(0xFFFDE68A), // Amber 200
    // Error
    error: _errorDark,
    onError: const Color(0xFF7F1D1D),
    errorContainer: const Color(0xFF991B1B),      // Red 800
    onErrorContainer: const Color(0xFFFECACA),    // Red 200
    // Surface - Obsidian palette
    surface: _bgDark,
    onSurface: _textPrimaryDark,
    surfaceContainerHighest: _surfaceElevatedDark,
    onSurfaceVariant: _textSecondaryDark,
    // Outline
    outline: _borderDark,
    outlineVariant: const Color(0xFF3F3F46),      // Zinc 700
    // Inverse
    inverseSurface: _bgLight,
    onInverseSurface: _textPrimaryLight,
    inversePrimary: _primaryLight,
    // Shadow & Scrim
    shadow: Colors.black,
    scrim: Colors.black.withAlpha(128),
  );

  // ============================================
  // LIGHT THEME
  // ============================================

  static ThemeData get light {
    final colorScheme = _lightColorScheme;
    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Scaffold
      scaffoldBackgroundColor: _bgLight,

      // AppBar - Clean, minimal
      appBarTheme: AppBarTheme(
        backgroundColor: _bgLight,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card - Subtle elevation with soft shadow
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _surfaceLight,
      ),

      // Divider - Invisible, use spacing instead
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Input - Pill-shaped, modern
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceElevatedLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),

      // Elevated Button - Rounded, bold
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: _surfaceElevatedLight,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _surfaceLight,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _bgDark,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: _textPrimaryDark,
        ),
        actionTextColor: _primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceLight,
        elevation: 0,
        height: 64,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceElevatedLight,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide.none,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================
  // DARK THEME - Obsidian Intelligence
  // ============================================

  static ThemeData get dark {
    final colorScheme = _darkColorScheme;
    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Scaffold - Deep obsidian
      scaffoldBackgroundColor: _bgDark,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: _bgDark,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card - Elevated surface
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _surfaceDark,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: _surfaceDark,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _surfaceDark,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceElevatedDark,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: _textPrimaryDark,
        ),
        actionTextColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Navigation Bar - Subtle, blends with background
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _bgDark,
        elevation: 0,
        height: 64,
        indicatorColor: colorScheme.primary.withAlpha(51),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer.withAlpha(77),
        circularTrackColor: colorScheme.primaryContainer.withAlpha(77),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceDark,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide.none,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}

// ============================================
// THEME EXTENSIONS
// ============================================

/// Extension for quick access to common colors
extension ThemeExtensions on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // Brand colors
  Color get primaryColor => colorScheme.primary;
  Color get secondaryColor => colorScheme.secondary;
  Color get tertiaryColor => colorScheme.tertiary;
  
  // Surface colors
  Color get surfaceColor => colorScheme.surface;
  Color get cardColor => colorScheme.surfaceContainerHighest;
  
  // Text colors
  Color get textPrimary => colorScheme.onSurface;
  Color get textSecondary => colorScheme.onSurfaceVariant;
  
  // Status colors
  Color get successColor => colorScheme.primary;
  Color get errorColor => colorScheme.error;
  Color get warningColor => colorScheme.tertiary;
  
  // Is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
