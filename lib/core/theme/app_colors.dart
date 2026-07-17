
import 'package:flutter/material.dart';

/// Quick theme-aware color helpers for chat widgets.
extension AppThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get cBg     => isDark ? AppColors.darkBackground      : AppColors.lightBackground;
  Color get cFg     => isDark ? AppColors.darkForeground      : AppColors.lightForeground;
  Color get cCard   => isDark ? AppColors.darkCard            : AppColors.lightCard;
  Color get cBorder => isDark ? AppColors.darkBorder          : AppColors.lightBorder;
  Color get cMuted  => isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground;
  Color get cError  => isDark ? AppColors.darkDestructive     : AppColors.lightDestructive;
  Color get cSidebar=> isDark ? AppColors.darkSidebar         : AppColors.lightSidebar;

  /// A soft, theme-appropriate ambient shadow colour. In light mode this lifts
  /// white cards off the tinted canvas; in dark mode a deeper black adds depth.
  Color get cShadow => isDark
      ? const Color(0x33000000) // 20% black
      : AppColors.lightShadow;  // ~8% near-black

  /// A ready-to-use soft card shadow, tuned per theme. Spread across a couple
  /// of layers for a natural, non-harsh lift.
  List<BoxShadow> get softShadow => isDark
      ? const [
          BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4)),
        ]
      : const [
          BoxShadow(color: Color(0x0F121114), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x14121114), blurRadius: 16, offset: Offset(0, 6)),
        ];
}

// ─────────────────────────────────────────────────────────────────────────────
// App Color Tokens
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppColors {
  // ── Radius ──────────────────────────────────────────────────────────────────
  // --radius: 0.625rem → 10px
  static const double radius = 10.0;

  // ── Landing Brand Colors ─────────────────────────────────────────────────────
  // --landing-primary-color: #861043
  static const Color landingPrimary = Color(0xFF861043);
  // --landing-primary-hover-color: #530929
  static const Color landingPrimaryHover = Color(0xFF530929);

  // ─────────────────────────────────────────────────────────────────────────────
  // LIGHT MODE TOKENS - Beautiful & Professional 🎨
  // ─────────────────────────────────────────────────────────────────────────────

  // Soft neutral canvas with a barely-there warm tint. A touch cooler/deeper
  // than pure white so pure-white cards visibly lift off it.
  static const Color lightBackground = Color(0xFFF4F2F4);

  // Deep rich near-black for excellent readability
  static const Color lightForeground = Color(0xFF121114);

  // Pure white cards that really pop from the tinted background
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardForeground = Color(0xFF121114);

  // Pure white popovers
  static const Color lightPopover = Color(0xFFFFFFFF);
  static const Color lightPopoverForeground = Color(0xFF121114);

  // Brand primary color - matches landing page
  static const Color lightPrimary = landingPrimary;
  // White text on primary
  static const Color lightPrimaryForeground = Color(0xFFFFFFFF);

  // Light gray-pink for secondary elements
  static const Color lightSecondary = Color(0xFFEDEAED);
  static const Color lightSecondaryForeground = Color(0xFF121114);

  // Visible muted background
  static const Color lightMuted = Color(0xFFE7E3E7);
  // Muted text - clearly readable, softer than the foreground
  static const Color lightMutedForeground = Color(0xFF6B6870);

  // Accent - soft pink/purple tint
  static const Color lightAccent = Color(0xFFFCE7F0);
  static const Color lightAccentForeground = Color(0xFF121114);

  // Destructive red - clearly visible
  static const Color lightDestructive = Color(0xFFDC2626);

  // Borders - visible but soft, with a hint of the warm background tint
  static const Color lightBorder = Color(0xFFE2DDE2);
  static const Color lightInput = Color(0xFFDDD7DD);

  // Focus ring - brand color
  static const Color lightRing = landingPrimary;

  // Sidebar (Light) - Clean near-white, a hair brighter than the canvas
  static const Color lightSidebar = Color(0xFFFCFBFC);
  static const Color lightSidebarForeground = Color(0xFF121114);
  static const Color lightSidebarPrimary = landingPrimary;
  static const Color lightSidebarPrimaryForeground = Color(0xFFFFFFFF);
  static const Color lightSidebarAccent = Color(0xFFFCE7F0);
  static const Color lightSidebarAccentForeground = Color(0xFF121114);
  static const Color lightSidebarBorder = Color(0xFFE2DDE2);
  static const Color lightSidebarRing = landingPrimary;

  // Soft ambient shadow for lifting light-mode cards off the canvas.
  static const Color lightShadow = Color(0x14121114); // ~8% near-black

  // Charts (Light)
  // oklch(0.646 0.222 41.116) → vivid orange
  static const Color lightChart1 = Color(0xFFF97316);
  // oklch(0.6 0.118 184.704) → sky / cyan
  static const Color lightChart2 = Color(0xFF0EA5B0);
  // oklch(0.398 0.07 227.392) → deep slate blue
  static const Color lightChart3 = Color(0xFF2E4F78);
  // oklch(0.828 0.189 84.429) → vivid yellow
  static const Color lightChart4 = Color(0xFFF9D60F);
  // oklch(0.769 0.188 70.08) → amber
  static const Color lightChart5 = Color(0xFFEAB308);

  // ─────────────────────────────────────────────────────────────────────────────
  // DARK MODE TOKENS
  // ─────────────────────────────────────────────────────────────────────────────

  // oklch(0.141 0.005 285.823) → near-black with cool tint
  static const Color darkBackground = Color(0xFF0F0F13);

  // oklch(0.985 0 0) → near white
  static const Color darkForeground = Color(0xFFFAFAFA);

  // oklch(0.21 0.006 285.885) → very dark navy
  static const Color darkCard = Color(0xFF1C1C27);
  static const Color darkCardForeground = Color(0xFFFAFAFA);

  static const Color darkPopover = Color(0xFF1C1C27);
  static const Color darkPopoverForeground = Color(0xFFFAFAFA);

  // oklch(0.92 0.004 286.32) → light gray (used as primary in dark)
  static const Color darkPrimary = Color(0xFFE8E8ED);
  static const Color darkPrimaryForeground = Color(0xFF1C1C27);

  // oklch(0.274 0.006 286.033) → dark muted gray
  static const Color darkSecondary = Color(0xFF27272F);
  static const Color darkSecondaryForeground = Color(0xFFFAFAFA);

  static const Color darkMuted = Color(0xFF27272F);
  // oklch(0.705 0.015 286.067) → medium gray
  static const Color darkMutedForeground = Color(0xFF9393A5);

  static const Color darkAccent = Color(0xFF27272F);
  static const Color darkAccentForeground = Color(0xFFFAFAFA);

  // oklch(0.704 0.191 22.216) → lighter red for dark bg
  static const Color darkDestructive = Color(0xFFF87171);

  // oklch(1 0 0 / 10%) → white 10%
  static const Color darkBorder = Color(0x1AFFFFFF);
  // oklch(1 0 0 / 15%) → white 15%
  static const Color darkInput = Color(0x26FFFFFF);

  // oklch(0.552 0.016 285.938) → muted ring
  static const Color darkRing = Color(0xFF52525B);

  // Sidebar (Dark)
  static const Color darkSidebar = Color(0xFF1C1C27);
  static const Color darkSidebarForeground = Color(0xFFFAFAFA);
  // oklch(0.488 0.243 264.376) → indigo/violet
  static const Color darkSidebarPrimary = Color(0xFF6366F1);
  static const Color darkSidebarPrimaryForeground = Color(0xFFFAFAFA);
  static const Color darkSidebarAccent = Color(0xFF27272F);
  static const Color darkSidebarAccentForeground = Color(0xFFFAFAFA);
  static const Color darkSidebarBorder = Color(0x1AFFFFFF);
  static const Color darkSidebarRing = Color(0xFF52525B);

  // Charts (Dark)
  // oklch(0.488 0.243 264.376) → indigo
  static const Color darkChart1 = Color(0xFF6366F1);
  // oklch(0.696 0.17 162.48) → emerald green
  static const Color darkChart2 = Color(0xFF34D399);
  // oklch(0.769 0.188 70.08) → amber
  static const Color darkChart3 = Color(0xFFEAB308);
  // oklch(0.627 0.265 303.9) → purple
  static const Color darkChart4 = Color(0xFFA855F7);
  // oklch(0.645 0.246 16.439) → coral red
  static const Color darkChart5 = Color(0xFFF87171);
}
