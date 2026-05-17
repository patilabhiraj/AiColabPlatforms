import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.darkCard,
          side: const BorderSide(color: AppColors.darkInput),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GoogleLogo(size: 22),
            SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: TextStyle(
                color: AppColors.darkForeground,
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
//
// Layout (Flutter angles: 0 = right, clockwise positive):
//   Gap  : 330° → 0°   (30° at upper-right — the G's opening)
//   Blue arc : 0° → 30°   (30°, right side going down to bar)
//   Green    : 30° → 150° (120°, bottom + lower-right)
//   Yellow   : 150° → 210° (60°, lower-left)
//   Red      : 210° → 330° (120°, left + top + upper-right)
//   Blue bar : center → right edge at center height
// ─────────────────────────────────────────────────────────────────────────────
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue   = Color(0xFF4285F4);
  static const _red    = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green  = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final sw   = size.width * 0.155;           // arc stroke width
    final r    = size.width / 2 - sw / 2;      // arc radius (centre of stroke)
    final c    = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: c, radius: r);

    const p = math.pi;

    // Stroke paint factory — butt caps keep colour boundaries crisp
    Paint s(Color color) => Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap   = StrokeCap.butt;

    // Red  — 210° → 330°  (left + top + upper-right)
    canvas.drawArc(rect, 7 * p / 6, 2 * p / 3, false, s(_red));

    // Yellow — 150° → 210°  (lower-left)
    canvas.drawArc(rect, 5 * p / 6, p / 3, false, s(_yellow));

    // Green — 30° → 150°  (bottom + lower-right)
    canvas.drawArc(rect, p / 6, 2 * p / 3, false, s(_green));

    // Blue arc — 0° → 30°  (right side, connects bar to green)
    canvas.drawArc(rect, 0, p / 6, false, s(_blue));

    // Blue horizontal bar — center → right edge at center height
    // StrokeCap.square extends sw/2 beyond each endpoint, so the right end
    // lands exactly on the outer edge of the arc circle (r + sw/2).
    canvas.drawLine(
      Offset(c.dx, c.dy),
      Offset(c.dx + r, c.dy),
      Paint()
        ..color       = _blue
        ..strokeWidth = sw
        ..strokeCap   = StrokeCap.square,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter old) => false;
}
