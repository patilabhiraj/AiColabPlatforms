import 'package:flutter/material.dart';

/// A single radial-gradient glowing circle.
/// Used as a decorative floating orb on the splash screen.
class GlowOrb extends StatelessWidget {
  const GlowOrb({
    super.key,
    required this.radius,
    required this.color,
  });

  /// Circle radius in logical pixels
  final double radius;

  /// Center color of the radial gradient (fades to transparent at edges)
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}
