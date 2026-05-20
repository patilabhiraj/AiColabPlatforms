import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: cs.surface,
          side: BorderSide(color: cs.outline),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleLogo(size: 22),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google G logo drawn with CustomPainter using the 4 official brand colors.
// ─────────────────────────────────────────────────────────────────────────────
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _GoogleLogoPainter());
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.width * 0.155;
    final r = size.width / 2 - sw / 2;
    final c = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: c, radius: r);
    const p = math.pi;

    Paint s(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, 7 * p / 6, 2 * p / 3, false, s(_red));
    canvas.drawArc(rect, 5 * p / 6, p / 3, false, s(_yellow));
    canvas.drawArc(rect, p / 6, 2 * p / 3, false, s(_green));
    canvas.drawArc(rect, 0, p / 6, false, s(_blue));
    canvas.drawLine(
      Offset(c.dx, c.dy),
      Offset(c.dx + r, c.dy),
      Paint()
        ..color = _blue
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.square,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter old) => false;
}
