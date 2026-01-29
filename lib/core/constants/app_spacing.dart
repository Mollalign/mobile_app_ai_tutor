import 'package:flutter/material.dart';

/// Design system spacing constants following 8px grid system.
class AppSpacing {
  AppSpacing._();

  /// Extra small spacing - 4px
  static const double xs = 4;

  /// Small spacing - 8px
  static const double sm = 8;

  /// Medium spacing - 16px
  static const double md = 16;

  /// Large spacing - 24px
  static const double lg = 24;

  /// Extra large spacing - 32px
  static const double xl = 32;

  /// Extra extra large spacing - 48px
  static const double xxl = 48;

  /// Extra extra extra large spacing - 64px
  static const double xxxl = 64;

  // EdgeInsets shortcuts
  static const EdgeInsets paddingAllXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
}

/// Design system border radius constants.
class AppRadius {
  AppRadius._();

  /// Small radius - 8px
  static const double sm = 8;

  /// Medium radius - 12px
  static const double md = 12;

  /// Large radius - 16px
  static const double lg = 16;

  /// Extra large radius - 24px
  static const double xl = 24;

  /// Full/circular radius
  static const double full = 9999;

  // BorderRadius shortcuts
  static BorderRadius get borderRadiusSm => BorderRadius.circular(sm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(md);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(lg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(xl);
}

/// Design system animation durations.
class AppDurations {
  AppDurations._();

  /// Fast animation - 150ms
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animation - 300ms
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow animation - 500ms
  static const Duration slow = Duration(milliseconds: 500);
}
