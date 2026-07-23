// import 'package:flutter/material.dart';

// import '../../domain/entities/assistant.dart';

// /// Visual helpers for models, capabilities and assistants.
// ///
// /// The web app ships per-provider PNG logos; on Flutter we render a tinted
// /// avatar (brand colour + icon) derived from the model's `externalId`, so the
// /// picker stays recognisable without bundling image assets.
// class CatalogVisuals {
//   const CatalogVisuals._();

//   // ── Model provider colours (keyed by externalId prefix) ───────────────────
//   static const Map<String, Color> _providerColors = {
//     'openai': Color(0xFF10A37F),
//     'anthropic': Color(0xFFD97757),
//     'google': Color(0xFF4285F4),
//     'deepseek': Color(0xFF4D6BFE),
//     'moonshotai': Color(0xFF6E56CF),
//     'perplexity': Color(0xFF20B8CD),
//     'x-ai': Color(0xFF111111),
//   };

//   static String _providerKey(String externalId) {
//     final lower = externalId.toLowerCase();
//     for (final key in _providerColors.keys) {
//       if (lower.startsWith(key)) return key;
//     }
//     return '';
//   }

//   static Color modelColor(String externalId) {
//     return _providerColors[_providerKey(externalId)] ?? const Color(0xFF6366F1);
//   }

//   static IconData modelIcon(String externalId) {
//     switch (_providerKey(externalId)) {
//       case 'openai':
//         return Icons.bubble_chart_rounded;
//       case 'anthropic':
//         return Icons.auto_awesome_rounded;
//       case 'google':
//         return Icons.stars_rounded;
//       case 'deepseek':
//         return Icons.psychology_rounded;
//       case 'moonshotai':
//         return Icons.nightlight_round;
//       case 'perplexity':
//         return Icons.travel_explore_rounded;
//       case 'x-ai':
//         return Icons.bolt_rounded;
//       default:
//         return Icons.smart_toy_rounded;
//     }
//   }

//   // ── Capabilities ──────────────────────────────────────────────────────────
//   static IconData capabilityIcon(String capability) {
//     switch (capability) {
//       case 'WEB_SEARCH':
//         return Icons.search_rounded;
//       case 'IMAGE_GENERATION':
//         return Icons.image_rounded;
//       case 'STANDARD':
//       default:
//         return Icons.chat_bubble_outline_rounded;
//     }
//   }

//   static String capabilityLabel(String capability) {
//     switch (capability) {
//       case 'WEB_SEARCH':
//         return 'Web Search';
//       case 'IMAGE_GENERATION':
//         return 'Image Generation';
//       case 'STANDARD':
//       default:
//         return 'Standard Chat';
//     }
//   }

//   // ── Assistants ──────────────────────────────────────────────────────────--
//   /// Maps the backend's Lucide icon name to a Material icon.
//   static IconData assistantIcon(String lucideName) {
//     switch (lucideName.toLowerCase()) {
//       case 'code':
//       case 'code2':
//       case 'terminal':
//       case 'braces':
//         return Icons.code_rounded;
//       case 'penline':
//       case 'pen':
//       case 'pentool':
//       case 'edit':
//       case 'edit3':
//       case 'feather':
//         return Icons.edit_rounded;
//       case 'scale':
//       case 'gavel':
//       case 'landmark':
//         return Icons.gavel_rounded;
//       case 'megaphone':
//       case 'speaker':
//       case 'trendingup':
//         return Icons.campaign_rounded;
//       case 'palette':
//       case 'paintbrush':
//       case 'paintbucket':
//       case 'brush':
//       case 'figma':
//         return Icons.palette_rounded;
//       case 'globe':
//       case 'languages':
//         return Icons.public_rounded;
//       case 'briefcase':
//         return Icons.work_rounded;
//       case 'graduationcap':
//       case 'book':
//       case 'bookopen':
//         return Icons.school_rounded;
//       case 'sparkles':
//       case 'wand':
//       case 'wand2':
//         return Icons.auto_awesome_rounded;
//       case 'heart':
//       case 'stethoscope':
//         return Icons.favorite_rounded;
//       case 'calculator':
//       case 'sigma':
//         return Icons.calculate_rounded;
//       default:
//         return Icons.smart_toy_rounded;
//     }
//   }

//   /// Parses a hex colour string like `#f3e8ff` (or `f3e8ff`) into a [Color].
//   static Color? parseHex(String? hex) {
//     if (hex == null) return null;
//     var value = hex.trim().replaceAll('#', '');
//     if (value.length == 6) value = 'FF$value';
//     if (value.length != 8) return null;
//     final parsed = int.tryParse(value, radix: 16);
//     return parsed == null ? null : Color(parsed);
//   }

//   /// Gradient colours for an assistant, respecting the active brightness.
//   /// Falls back to a soft violet gradient when the assistant has none set.
//   static List<Color> assistantGradient(Assistant a, {required bool isDark}) {
//     final from = parseHex(isDark ? a.bgFromDark : a.bgFrom);
//     final via = parseHex(isDark ? a.bgViaDark : a.bgVia);
//     final to = parseHex(isDark ? a.bgToDark : a.bgTo);

//     final fallback = isDark
//         ? const [Color(0xFF312E81), Color(0xFF3B0764), Color(0xFF4C1D95)]
//         : const [Color(0xFFF3E8FF), Color(0xFFE9D5FF), Color(0xFFFCE7F3)];

//     final colors = <Color>[
//       from ?? fallback[0],
//       via ?? from ?? fallback[1],
//       to ?? fallback[2],
//     ];
//     return colors;
//   }

//   /// The dominant accent colour for an assistant (its `from` colour).
//   static Color assistantAccent(Assistant a, {required bool isDark}) {
//     return parseHex(isDark ? a.bgFromDark : a.bgFrom) ??
//         (isDark ? const Color(0xFF4C1D95) : const Color(0xFFC084FC));
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/assistant.dart';

class CatalogVisuals {
  const CatalogVisuals._();

  // Provider Colors
  //
  // xAI's brand mark is pure black, which all but disappears against this
  // app's dark surfaces — lightened here so the Grok icon stays visible
  // instead of matching the brand guide exactly.
  static const Map<String, Color> _providerColors = {
    'openai': Color(0xFF10A37F),
    'anthropic': Color(0xFFD97757),
    'google': Color(0xFF4285F4),
    'deepseek': Color(0xFF4D6BFE),
    'moonshotai': Color(0xFF6E56CF),
    'perplexity': Color(0xFF20B8CD),
    'x-ai': Color(0xFFD4D4D8),
    'poolside': Color(0xFF6366F1),
    'cohere': Color(0xFFD18EE2),
    'nvidia': Color(0xFF76B900),
  };

  static String _providerKey(String externalId) {
    final lower = externalId.toLowerCase();

    for (final key in _providerColors.keys) {
      if (lower.startsWith(key)) {
        return key;
      }
    }

    return '';
  }

  static Color modelColor(String externalId) {
    return _providerColors[_providerKey(externalId)] ?? const Color(0xFF6366F1);
  }

  // Fallback Material Icons
  static IconData modelIcon(String externalId) {
    switch (_providerKey(externalId)) {
      case 'openai':
        return Icons.bubble_chart_rounded;

      case 'anthropic':
        return Icons.auto_awesome_rounded;

      case 'google':
        return Icons.stars_rounded;

      case 'deepseek':
        return Icons.psychology_rounded;

      case 'moonshotai':
        return Icons.nightlight_round;

      case 'perplexity':
        return Icons.travel_explore_rounded;

      case 'x-ai':
        return Icons.bolt_rounded;

      case 'poolside':
        return Icons.pool_rounded;

      case 'cohere':
        return Icons.hub_rounded;

      case 'nvidia':
        return Icons.memory_rounded;

      default:
        return Icons.smart_toy_rounded;
    }
  }

  // SVG Logo Path
  static String? modelLogo(String externalId) {
    final lower = externalId.toLowerCase();

    if (lower.startsWith('openai')) {
      return 'assets/modeIcons/openai.svg';
    }

    if (lower.startsWith('anthropic')) {
      return 'assets/modeIcons/anthropic.svg';
    }

    if (lower.startsWith('google')) {
      return 'assets/modeIcons/google.svg';
    }

    if (lower.startsWith('deepseek')) {
      return 'assets/modeIcons/deepseek.svg';
    }

    if (lower.startsWith('moonshotai')) {
      return 'assets/modeIcons/moonshot.svg';
    }

    if (lower.startsWith('perplexity')) {
      return 'assets/modeIcons/perplexity.svg';
    }

    if (lower.startsWith('x-ai')) {
      return 'assets/modeIcons/xai.svg';
    }

    if (lower.startsWith('poolside')) {
      return 'assets/modeIcons/poolside.svg';
    }

    if (lower.startsWith('cohere')) {
      return 'assets/modeIcons/cohere.svg';
    }

    if (lower.startsWith('nvidia')) {
      return 'assets/modeIcons/nvidia.svg';
    }

    return null;
  }

  // Widget for Model Logo
  //
  // Falls back to the tinted Material icon whenever there's no SVG mapped for
  // this provider, or the mapped file is missing/empty/unparsable — so a
  // placeholder asset (e.g. still being replaced with real artwork) degrades
  // gracefully instead of crashing or rendering blank.
  //
  // Most provider marks are monochrome (drawn with `fill="currentColor"`), so
  // we tint them with the provider's brand colour via [ColorFilter] — SVG's
  // `currentColor` isn't picked up automatically by [SvgPicture]. Google's
  // mark is intentionally left untinted since its multi-colour "G" is the
  // recognisable brand asset.
  static const Set<String> _multicolorLogos = {'google'};

  static Widget modelAvatar(String externalId, {double size = 24}) {
    final logo = modelLogo(externalId);
    final color = modelColor(externalId);
    final fallback = Icon(modelIcon(externalId), size: size, color: color);

    if (logo == null) return fallback;

    final tint = _multicolorLogos.contains(_providerKey(externalId))
        ? null
        : color;

    return SvgPicture.asset(
      logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
      placeholderBuilder: (_) => fallback,
      // ignore: deprecated_member_use
      errorBuilder: (_, _, _) => fallback,
    );
  }

  // Capabilities

  static IconData capabilityIcon(String capability) {
    switch (capability) {
      case 'WEB_SEARCH':
        return Icons.search_rounded;

      case 'IMAGE_GENERATION':
        return Icons.image_rounded;

      case 'STANDARD':
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  static String capabilityLabel(String capability) {
    switch (capability) {
      case 'WEB_SEARCH':
        return 'Web Search';

      case 'IMAGE_GENERATION':
        return 'Image Generation';

      case 'STANDARD':
      default:
        return 'Standard Chat';
    }
  }

  // Assistant Icons

  static IconData assistantIcon(String lucideName) {
    switch (lucideName.toLowerCase()) {
      case 'code':
      case 'code2':
      case 'terminal':
      case 'braces':
        return Icons.code_rounded;

      case 'penline':
      case 'pen':
      case 'pentool':
      case 'edit':
      case 'edit3':
      case 'feather':
        return Icons.edit_rounded;

      case 'scale':
      case 'gavel':
      case 'landmark':
        return Icons.gavel_rounded;

      case 'megaphone':
      case 'speaker':
      case 'trendingup':
        return Icons.campaign_rounded;

      case 'palette':
      case 'paintbrush':
      case 'paintbucket':
      case 'brush':
      case 'figma':
        return Icons.palette_rounded;

      case 'globe':
      case 'languages':
        return Icons.public_rounded;

      case 'briefcase':
        return Icons.work_rounded;

      case 'graduationcap':
      case 'book':
      case 'bookopen':
        return Icons.school_rounded;

      case 'sparkles':
      case 'wand':
      case 'wand2':
        return Icons.auto_awesome_rounded;

      case 'heart':
      case 'stethoscope':
        return Icons.favorite_rounded;

      case 'calculator':
      case 'sigma':
        return Icons.calculate_rounded;

      default:
        return Icons.smart_toy_rounded;
    }
  }

  static Color? parseHex(String? hex) {
    if (hex == null) return null;

    var value = hex.trim().replaceAll('#', '');

    if (value.length == 6) {
      value = 'FF$value';
    }

    if (value.length != 8) {
      return null;
    }

    final parsed = int.tryParse(value, radix: 16);

    return parsed == null ? null : Color(parsed);
  }

  static List<Color> assistantGradient(Assistant a, {required bool isDark}) {
    final from = parseHex(isDark ? a.bgFromDark : a.bgFrom);
    final via = parseHex(isDark ? a.bgViaDark : a.bgVia);
    final to = parseHex(isDark ? a.bgToDark : a.bgTo);

    final fallback = isDark
        ? const [Color(0xFF312E81), Color(0xFF3B0764), Color(0xFF4C1D95)]
        : const [Color(0xFFF3E8FF), Color(0xFFE9D5FF), Color(0xFFFCE7F3)];

    return [from ?? fallback[0], via ?? from ?? fallback[1], to ?? fallback[2]];
  }

  static Color assistantAccent(Assistant a, {required bool isDark}) {
    return parseHex(isDark ? a.bgFromDark : a.bgFrom) ??
        (isDark ? const Color(0xFF4C1D95) : const Color(0xFFC084FC));
  }
}
