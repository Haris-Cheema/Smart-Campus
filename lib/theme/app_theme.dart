import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Tokens ────────────────────────────────────────────────
  static const Color primary = Color(0xFF004AAD);
  static const Color secondary = Color(0xFF006397);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAF8FF);
  static const Color surfaceContainer = Color(0xFFEDEDF6);
  static const Color surfaceContainerHighest = Color(0xFFE2E2EB);
  static const Color onSurface = Color(0xFF191B22);
  static const Color onSurfaceVariant = Color(0xFF434653);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // ── Dark Color Tokens ───────────────────────────────────────────
  static const Color primaryDark = Color(0xFFADC6FF);
  static const Color secondaryDark = Color(0xFF91CDFF);
  static const Color surfaceDark = Color(0xFF111318);
  static const Color backgroundDark = Color(0xFF111318);
  static const Color surfaceContainerDark = Color(0xFF1E2025);
  static const Color surfaceContainerHighestDark = Color(0xFF33353A);
  static const Color onSurfaceDark = Color(0xFFE2E2E9);
  static const Color onSurfaceVariantDark = Color(0xFFC4C6D0);

  static ThemeData get lightTheme => _themeData(Brightness.light);
  static ThemeData get darkTheme => _themeData(Brightness.dark);

  static ThemeData _themeData(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final lexend = GoogleFonts.lexendTextTheme();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: isDark ? const Color(0xFF111318) : surface,
      onSurface: isDark ? const Color(0xFFE2E2EB) : onSurface,
      surfaceContainerHighest: isDark ? const Color(0xFF30343D) : surfaceContainerHighest,
      background: isDark ? const Color(0xFF0D0E11) : background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // Typography
      textTheme: lexend.copyWith(
        displayLarge: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
        displayMedium: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        displaySmall: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        bodyLarge: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w400, color: colorScheme.onSurface),
        bodyMedium: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w400, color: colorScheme.onSurfaceVariant),
        labelLarge: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
        labelSmall: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : primary),
        titleTextStyle: GoogleFonts.lexend(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        surfaceTintColor: Colors.transparent,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: error, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: error, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.lexend(color: colorScheme.onSurfaceVariant),
      ),

      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.all(GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500)),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainer,
        selectedColor: primary.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.lexend(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        side: BorderSide.none,
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? colorScheme.surface : surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Divider
      dividerTheme: DividerThemeData(color: surfaceContainerHighest.withValues(alpha: 0.7)),
    );
  }
}
