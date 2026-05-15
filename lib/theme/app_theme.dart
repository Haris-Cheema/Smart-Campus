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

  static ThemeData get lightTheme {
    final lexend = GoogleFonts.lexendTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        errorContainer: errorContainer,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        surfaceContainerHighest: surfaceContainerHighest,
      ),
      scaffoldBackgroundColor: background,

      // Typography
      textTheme: lexend.copyWith(
        displayLarge: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w700, color: onSurface),
        displayMedium: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w600, color: onSurface),
        displaySmall: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
        bodyLarge: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
        bodyMedium: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVariant),
        labelLarge: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),
        labelSmall: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.lexend(color: onSurface, fontSize: 18, fontWeight: FontWeight.w600),
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
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        surfaceTintColor: Colors.transparent,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: error, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: error, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.lexend(color: onSurfaceVariant),
      ),

      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.all(GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500)),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainer,
        selectedColor: primary.withOpacity(0.15),
        labelStyle: GoogleFonts.lexend(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        side: BorderSide.none,
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
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
      dividerTheme: DividerThemeData(color: surfaceContainerHighest.withOpacity(0.7)),
    );
  }

  static ThemeData get darkTheme {
    final lexend = GoogleFonts.lexendTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryDark,
        surface: surfaceDark,
        error: error,
        onPrimary: const Color(0xFF002F66),
        onSecondary: const Color(0xFF003450),
        onSurface: onSurfaceDark,
        onSurfaceVariant: onSurfaceVariantDark,
        surfaceContainerHighest: surfaceContainerHighestDark,
      ),
      scaffoldBackgroundColor: backgroundDark,

      // Typography
      textTheme: lexend.copyWith(
        displayLarge: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w700, color: onSurfaceDark),
        displayMedium: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w600, color: onSurfaceDark),
        displaySmall: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w600, color: onSurfaceDark),
        bodyLarge: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w400, color: onSurfaceDark),
        bodyMedium: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVariantDark),
        labelLarge: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: onSurfaceDark),
        labelSmall: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariantDark),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryDark),
        titleTextStyle: GoogleFonts.lexend(color: onSurfaceDark, fontSize: 18, fontWeight: FontWeight.w600),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: const Color(0xFF002F66),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: surfaceContainerDark,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        surfaceTintColor: Colors.transparent,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHighestDark.withOpacity(0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primaryDark, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: error, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: error, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.lexend(color: onSurfaceVariantDark),
      ),

      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: primaryDark.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.all(GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceDark)),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const IconThemeData(color: primaryDark);
          return IconThemeData(color: onSurfaceVariantDark);
        }),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerDark,
        selectedColor: primaryDark.withOpacity(0.15),
        labelStyle: GoogleFonts.lexend(fontSize: 13, color: onSurfaceDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        side: BorderSide.none,
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceContainerDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: Color(0xFF002F66),
        elevation: 4,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceContainerDark,
        contentTextStyle: GoogleFonts.lexend(color: onSurfaceDark),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Divider
      dividerTheme: DividerThemeData(color: surfaceContainerHighestDark.withOpacity(0.5)),
    );
  }
}
