import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

const _kTutorialCompleteKey = 'app_tutorial_complete';
const _kTipPrefix = 'tip_seen_';

final tutorialServiceProvider = Provider<TutorialService>((ref) {
  return TutorialService();
});

class TutorialService {
  Future<bool> shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_kTutorialCompleteKey) ?? false);
  }

  Future<void> markTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTutorialCompleteKey, true);
  }

  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTutorialCompleteKey, false);
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_kTipPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  Future<bool> shouldShowTip(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('$_kTipPrefix$tipId') ?? false);
  }

  Future<void> markTipSeen(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kTipPrefix$tipId', true);
  }

  void showCoachMark({
    required BuildContext context,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    TutorialCoachMark(
      targets: targets,
      colorShadow: colorScheme.inverseSurface,
      opacityShadow: 0.85,
      textSkip: 'SKIP',
      textStyleSkip: TextStyle(
        color: colorScheme.onInverseSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 400),
      unFocusAnimationDuration: const Duration(milliseconds: 350),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      onFinish: () {
        markTutorialComplete();
        onFinish?.call();
      },
      onSkip: () {
        markTutorialComplete();
        onFinish?.call();
        return true;
      },
    ).show(context: context);
  }
}

TargetFocus buildTarget({
  required GlobalKey key,
  required String title,
  required String description,
  required IconData icon,
  required Color color,
  ContentAlign align = ContentAlign.bottom,
  ShapeLightFocus shape = ShapeLightFocus.RRect,
}) {
  return TargetFocus(
    identify: key.toString(),
    keyTarget: key,
    alignSkip: Alignment.topRight,
    shape: shape,
    radius: 12,
    contents: [
      TargetContent(
        align: align,
        builder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(210),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Tap anywhere to continue',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(120),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}
