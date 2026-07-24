import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema principal de Galingo
/// Paleta inspirada en el océano gallego: azules, blancos y toques dorados
class AppTheme {
  AppTheme._();

  // ─── Paleta de colores principal ──────────────────────────────────────────

  /// Azul océano primario (inspirado en las rías gallegas)
  static const Color primaryBlue = Color(0xFF1E6BB8);
  static const Color primaryBlueLight = Color(0xFF5BB3F0);
  static const Color primaryBlueDark = Color(0xFF0D4A8C);

  /// Acento: coral atlántico
  static const Color accentCoral = Color(0xFFFF7043);
  static const Color accentGold = Color(0xFFFFB300);

  /// Verdes (correcto / éxito)
  static const Color successGreen = Color(0xFF43A047);
  static const Color successGreenLight = Color(0xFFE8F5E9);

  /// Rojos (error / incorrecto)
  static const Color errorRed = Color(0xFFE53935);
  static const Color errorRedLight = Color(0xFFFFEBEE);

  /// Fondos
  static const Color backgroundLight = Color(0xFFF0F7FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceBlue = Color(0xFFE3F2FD);

  /// Texto
  static const Color textPrimary = Color(0xFF1A2744);
  static const Color textSecondary = Color(0xFF546E88);
  static const Color textHint = Color(0xFF90A4AE);

  /// Modo oscuro
  static const Color backgroundDark = Color(0xFF0D1B2A);
  static const Color surfaceDark = Color(0xFF1A2F45);
  static const Color surfaceDark2 = Color(0xFF243B55);

  // ─── Gradientes ───────────────────────────────────────────────────────────

  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E6BB8), Color(0xFF5BB3F0)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5BB3F0), Color(0xFFE3F2FD)],
  );

  // ─── Temas ─────────────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: accentCoral,
        surface: surfaceLight,
        error: errorRed,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: backgroundLight,
      textTheme: _buildTextTheme(base.textTheme, textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: primaryBlue.withOpacity(0.1),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceBlue,
        selectedColor: primaryBlue,
        labelStyle: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryBlue,
        linearTrackColor: surfaceBlue,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        hintStyle: GoogleFonts.nunito(
          color: textHint,
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlueLight,
        secondary: accentCoral,
        surface: surfaceDark,
        error: errorRed,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: backgroundDark,
      textTheme: _buildTextTheme(base.textTheme, Colors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlueLight,
          foregroundColor: backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlueLight,
          foregroundColor: backgroundDark,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlueLight,
          side: const BorderSide(color: primaryBlueLight, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark2,
        selectedColor: primaryBlueLight,
        labelStyle: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryBlueLight,
        linearTrackColor: surfaceDark2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlueLight, width: 2),
        ),
        hintStyle: GoogleFonts.nunito(
          color: textHint,
          fontSize: 14,
        ),
      ),
    );
  }

  static List<String> get _fallbacks => [
    GoogleFonts.notoSansArabic().fontFamily!,
    GoogleFonts.notoSansSc().fontFamily!,
  ];

  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    TextStyle style(double size, FontWeight weight, {double? spacing, double? opacity}) {
      return GoogleFonts.nunito(
        fontSize: size,
        fontWeight: weight,
        color: opacity != null ? textColor.withValues(alpha: opacity) : textColor,
        letterSpacing: spacing,
      ).copyWith(
        fontFamilyFallback: _fallbacks,
      );
    }

    return base.copyWith(
      displayLarge: style(57, FontWeight.w800, spacing: -0.25),
      displayMedium: style(45, FontWeight.w800),
      displaySmall: style(36, FontWeight.w700),
      headlineLarge: style(32, FontWeight.w700),
      headlineMedium: style(28, FontWeight.w700),
      headlineSmall: style(24, FontWeight.w700),
      titleLarge: style(22, FontWeight.w700),
      titleMedium: style(16, FontWeight.w600, spacing: 0.15),
      titleSmall: style(14, FontWeight.w600, spacing: 0.1),
      bodyLarge: style(16, FontWeight.w400, spacing: 0.5),
      bodyMedium: style(14, FontWeight.w400, spacing: 0.25),
      bodySmall: style(12, FontWeight.w400, spacing: 0.4, opacity: 0.7),
      labelLarge: style(14, FontWeight.w700, spacing: 0.1),
      labelMedium: style(12, FontWeight.w600, spacing: 0.5),
      labelSmall: style(11, FontWeight.w500, spacing: 0.5, opacity: 0.7),
    );
  }
}
