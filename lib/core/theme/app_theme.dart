
import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Border Radius Tokens
// --radius: 0.625rem (10px) base → sm/md/lg/xl variants
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppRadius {
  static const double sm  = AppColors.radius - 4;   // 6px
  static const double md  = AppColors.radius - 2;   // 8px
  static const double lg  = AppColors.radius;        // 10px  (base)
  static const double xl  = AppColors.radius + 4;   // 14px
  static const double xl2 = AppColors.radius + 8;   // 18px
  static const double xl3 = AppColors.radius + 12;  // 22px
  static const double xl4 = AppColors.radius + 16;  // 26px

  static BorderRadius borderSm  = BorderRadius.circular(sm);
  static BorderRadius borderMd  = BorderRadius.circular(md);
  static BorderRadius borderLg  = BorderRadius.circular(lg);
  static BorderRadius borderXl  = BorderRadius.circular(xl);
  static BorderRadius borderXl2 = BorderRadius.circular(xl2);
  static BorderRadius borderXl3 = BorderRadius.circular(xl3);
  static BorderRadius borderXl4 = BorderRadius.circular(xl4);
}

// ─────────────────────────────────────────────────────────────────────────────
// App Theme
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppTheme {
  // ── Light Theme ──────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,

        colorScheme: const ColorScheme(
          brightness: Brightness.light,

          // Primary
          primary: AppColors.lightPrimary,
          onPrimary: AppColors.lightPrimaryForeground,
          primaryContainer: AppColors.lightSecondary,
          onPrimaryContainer: AppColors.lightSecondaryForeground,

          // Secondary
          secondary: AppColors.lightSecondary,
          onSecondary: AppColors.lightSecondaryForeground,
          secondaryContainer: AppColors.lightMuted,
          onSecondaryContainer: AppColors.lightMutedForeground,

          // Tertiary (accent)
          tertiary: AppColors.lightAccent,
          onTertiary: AppColors.lightAccentForeground,
          tertiaryContainer: AppColors.lightAccent,
          onTertiaryContainer: AppColors.lightAccentForeground,

          // Error (destructive)
          error: AppColors.lightDestructive,
          onError: AppColors.lightPrimaryForeground,
          errorContainer: Color(0xFFFEE2E2),
          onErrorContainer: AppColors.lightDestructive,

          // Surface (card / background)
          surface: AppColors.lightCard,
          onSurface: AppColors.lightCardForeground,
          surfaceContainerHighest: AppColors.lightMuted,
          onSurfaceVariant: AppColors.lightMutedForeground,

          // Outline (border)
          outline: AppColors.lightBorder,
          outlineVariant: AppColors.lightRing,

          // Inverse
          inverseSurface: AppColors.lightPrimary,
          onInverseSurface: AppColors.lightPrimaryForeground,
          inversePrimary: AppColors.lightMuted,

          // Scrim / shadow
          scrim: Color(0x40000000),
          shadow: Color(0x1F000000),
        ),

        // ── Card ────────────────────────────────────────────────────────────────
        // A whisper of elevation + a soft near-black shadow lifts white cards
        // off the tinted canvas so they read as distinct surfaces.
        cardTheme: CardThemeData(
          color: AppColors.lightCard,
          surfaceTintColor: Colors.transparent,
          shadowColor: AppColors.lightShadow,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderLg,
            side: const BorderSide(color: AppColors.lightBorder),
          ),
        ),

        // ── AppBar ──────────────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightForeground,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),

        // ── NavigationDrawer / Sidebar ──────────────────────────────────────────
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.lightSidebar,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),

        // ── NavigationBar ────────────────────────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.lightSidebar,
          indicatorColor: AppColors.lightSidebarAccent,
          iconTheme: const WidgetStatePropertyAll(
            IconThemeData(color: AppColors.lightSidebarForeground),
          ),
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(color: AppColors.lightSidebarForeground),
          ),
        ),

        // ── BottomNavigationBar ─────────────────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSidebar,
          selectedItemColor: AppColors.lightSidebarPrimary,
          unselectedItemColor: AppColors.lightSidebarAccentForeground,
        ),

        // ── Input / TextField ────────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightCard,
          hintStyle: const TextStyle(color: AppColors.lightMutedForeground),
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.lightInput),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.lightInput),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.lightRing, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.lightDestructive),
          ),
        ),

        // ── Buttons ─────────────────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: AppColors.lightPrimaryForeground,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.lightPrimary,
            side: const BorderSide(color: AppColors.lightBorder),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          ),
        ),

        // ── Chip ────────────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.lightSecondary,
          labelStyle: const TextStyle(color: AppColors.lightSecondaryForeground),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
          side: const BorderSide(color: AppColors.lightBorder),
        ),

        // ── Divider ─────────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.lightBorder,
          thickness: 1,
          space: 1,
        ),

        // ── Popup / Dialog ───────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.lightPopover,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.lightPopover,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          elevation: 4,
        ),

        // ── SnackBar ─────────────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.lightPrimary,
          contentTextStyle: const TextStyle(color: AppColors.lightPrimaryForeground),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          behavior: SnackBarBehavior.floating,
        ),

        // ── Switch / Checkbox / Radio ────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.lightPrimaryForeground;
            }
            return AppColors.lightMutedForeground;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.lightPrimary;
            }
            return AppColors.lightMuted;
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.lightPrimary;
            }
            return Colors.transparent;
          }),
          checkColor: const WidgetStatePropertyAll(AppColors.lightPrimaryForeground),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
          side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),

        // ── ListTile ─────────────────────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          selectedTileColor: AppColors.lightAccent,
          iconColor: AppColors.lightMutedForeground,
          textColor: AppColors.lightForeground,
          shape: RoundedRectangleBorder(),
        ),

        // ── Progress Indicator ───────────────────────────────────────────────────
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.lightPrimary,
          linearTrackColor: AppColors.lightMuted,
        ),

        // ── Floating Action Button ───────────────────────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightPrimaryForeground,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
          elevation: 2,
        ),
      );

  // ── Dark Theme ───────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,

        colorScheme: const ColorScheme(
          brightness: Brightness.dark,

          // Primary
          primary: AppColors.darkPrimary,
          onPrimary: AppColors.darkPrimaryForeground,
          primaryContainer: AppColors.darkSecondary,
          onPrimaryContainer: AppColors.darkSecondaryForeground,

          // Secondary
          secondary: AppColors.darkSecondary,
          onSecondary: AppColors.darkSecondaryForeground,
          secondaryContainer: AppColors.darkMuted,
          onSecondaryContainer: AppColors.darkMutedForeground,

          // Tertiary (accent)
          tertiary: AppColors.darkAccent,
          onTertiary: AppColors.darkAccentForeground,
          tertiaryContainer: AppColors.darkAccent,
          onTertiaryContainer: AppColors.darkAccentForeground,

          // Error (destructive)
          error: AppColors.darkDestructive,
          onError: AppColors.darkBackground,
          errorContainer: Color(0xFF450A0A),
          onErrorContainer: AppColors.darkDestructive,

          // Surface (card / background)
          surface: AppColors.darkCard,
          onSurface: AppColors.darkCardForeground,
          surfaceContainerHighest: AppColors.darkMuted,
          onSurfaceVariant: AppColors.darkMutedForeground,

          // Outline (border)
          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkRing,

          // Inverse
          inverseSurface: AppColors.darkPrimary,
          onInverseSurface: AppColors.darkPrimaryForeground,
          inversePrimary: AppColors.darkMuted,

          // Scrim / shadow
          scrim: Color(0x80000000),
          shadow: Color(0x4D000000),
        ),

        // ── Card ────────────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderLg,
            side: const BorderSide(color: AppColors.darkBorder),
          ),
        ),

        // ── AppBar ──────────────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkForeground,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),

        // ── NavigationDrawer / Sidebar ──────────────────────────────────────────
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.darkSidebar,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),

        // ── NavigationBar ────────────────────────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.darkSidebar,
          indicatorColor: AppColors.darkSidebarAccent,
          iconTheme: const WidgetStatePropertyAll(
            IconThemeData(color: AppColors.darkSidebarForeground),
          ),
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(color: AppColors.darkSidebarForeground),
          ),
        ),

        // ── BottomNavigationBar ─────────────────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSidebar,
          selectedItemColor: AppColors.darkSidebarPrimary,
          unselectedItemColor: AppColors.darkSidebarAccentForeground,
        ),

        // ── Input / TextField ────────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkCard,
          hintStyle: const TextStyle(color: AppColors.darkMutedForeground),
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.darkInput),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.darkInput),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.darkRing, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderMd,
            borderSide: const BorderSide(color: AppColors.darkDestructive),
          ),
        ),

        // ── Buttons ─────────────────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPrimary,
            foregroundColor: AppColors.darkPrimaryForeground,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.darkForeground,
            side: const BorderSide(color: AppColors.darkBorder),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.darkForeground,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          ),
        ),

        // ── Chip ────────────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkSecondary,
          labelStyle: const TextStyle(color: AppColors.darkSecondaryForeground),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
          side: const BorderSide(color: AppColors.darkBorder),
        ),

        // ── Divider ─────────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          thickness: 1,
          space: 1,
        ),

        // ── Popup / Dialog ───────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.darkPopover,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.darkPopover,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          elevation: 4,
        ),

        // ── SnackBar ─────────────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkCard,
          contentTextStyle: const TextStyle(color: AppColors.darkForeground),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          behavior: SnackBarBehavior.floating,
        ),

        // ── Switch / Checkbox / Radio ────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.darkPrimaryForeground;
            }
            return AppColors.darkMutedForeground;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.darkSidebarPrimary;
            }
            return AppColors.darkMuted;
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.darkSidebarPrimary;
            }
            return Colors.transparent;
          }),
          checkColor: const WidgetStatePropertyAll(AppColors.darkForeground),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),

        // ── ListTile ─────────────────────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          selectedTileColor: AppColors.darkAccent,
          iconColor: AppColors.darkMutedForeground,
          textColor: AppColors.darkForeground,
        ),

        // ── Progress Indicator ───────────────────────────────────────────────────
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.darkSidebarPrimary,
          linearTrackColor: AppColors.darkMuted,
        ),

        // ── Floating Action Button ───────────────────────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.darkSidebarPrimary,
          foregroundColor: AppColors.darkForeground,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
          elevation: 2,
        ),
      );
}
