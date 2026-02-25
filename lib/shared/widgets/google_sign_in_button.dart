import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleSignInButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF131314) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(30)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CustomPaint(painter: _GoogleLogoPainter()),
              ),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: textTheme.titleSmall?.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pixel-accurate Google "G" logo using official SVG path data.
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 24.0;

    // Blue section
    final bluePath = Path()
      ..moveTo(23.745 * s, 12.27 * s)
      ..cubicTo(23.745 * s, 11.48 * s, 23.675 * s, 10.73 * s, 23.545 * s, 10.0 * s)
      ..lineTo(12.255 * s, 10.0 * s)
      ..lineTo(12.255 * s, 14.51 * s)
      ..lineTo(18.725 * s, 14.51 * s)
      ..cubicTo(18.435 * s, 15.99 * s, 17.585 * s, 17.24 * s, 16.325 * s, 18.09 * s)
      ..lineTo(16.325 * s, 21.09 * s)
      ..lineTo(20.19 * s, 21.09 * s)
      ..cubicTo(22.465 * s, 19.0 * s, 23.745 * s, 15.92 * s, 23.745 * s, 12.27 * s)
      ..close();
    canvas.drawPath(
      bluePath,
      Paint()..color = const Color(0xFF4285F4),
    );

    // Green section
    final greenPath = Path()
      ..moveTo(12.255 * s, 24.0 * s)
      ..cubicTo(15.495 * s, 24.0 * s, 18.205 * s, 22.92 * s, 20.19 * s, 21.09 * s)
      ..lineTo(16.325 * s, 18.09 * s)
      ..cubicTo(15.245 * s, 18.81 * s, 13.875 * s, 19.25 * s, 12.255 * s, 19.25 * s)
      ..cubicTo(9.125 * s, 19.25 * s, 6.475 * s, 17.14 * s, 5.525 * s, 14.29 * s)
      ..lineTo(1.545 * s, 14.29 * s)
      ..lineTo(1.545 * s, 17.38 * s)
      ..cubicTo(3.515 * s, 21.3 * s, 7.565 * s, 24.0 * s, 12.255 * s, 24.0 * s)
      ..close();
    canvas.drawPath(
      greenPath,
      Paint()..color = const Color(0xFF34A853),
    );

    // Yellow section
    final yellowPath = Path()
      ..moveTo(5.525 * s, 14.29 * s)
      ..cubicTo(5.025 * s, 12.81 * s, 5.025 * s, 11.19 * s, 5.525 * s, 9.71 * s)
      ..lineTo(5.525 * s, 6.62 * s)
      ..lineTo(1.545 * s, 6.62 * s)
      ..cubicTo(-0.185 * s, 10.0 * s, -0.185 * s, 14.0 * s, 1.545 * s, 17.38 * s)
      ..lineTo(5.525 * s, 14.29 * s)
      ..close();
    canvas.drawPath(
      yellowPath,
      Paint()..color = const Color(0xFFFBBC05),
    );

    // Red section
    final redPath = Path()
      ..moveTo(12.255 * s, 4.75 * s)
      ..cubicTo(13.985 * s, 4.72 * s, 15.655 * s, 5.36 * s, 16.925 * s, 6.55 * s)
      ..lineTo(20.275 * s, 3.2 * s)
      ..cubicTo(18.105 * s, 1.19 * s, 15.235 * s, 0.08 * s, 12.255 * s, 0.1 * s)
      ..cubicTo(7.565 * s, 0.1 * s, 3.515 * s, 2.7 * s, 1.545 * s, 6.62 * s)
      ..lineTo(5.525 * s, 9.71 * s)
      ..cubicTo(6.475 * s, 6.86 * s, 9.125 * s, 4.75 * s, 12.255 * s, 4.75 * s)
      ..close();
    canvas.drawPath(
      redPath,
      Paint()..color = const Color(0xFFEA4335),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
