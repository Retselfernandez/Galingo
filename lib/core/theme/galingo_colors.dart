import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Paleta semántica de Galingo: os mesmos nomes para claro e escuro.
///
/// As pantallas usan estes tokens (nunca cores fixas) para que todo sexa
/// lexible en ambos temas. As cores de marca (deepBlue, gold, green...) seguen
/// a ser constantes de [AppTheme] porque funcionan nos dous.
@immutable
class GalingoColors extends ThemeExtension<GalingoColors> {
  final Color pageBg;
  final Color cardBg;
  final Color softBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color divider;
  final Color accent;
  final Color accentSoft;
  final Color shadow;

  const GalingoColors({
    required this.pageBg,
    required this.cardBg,
    required this.softBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.accent,
    required this.accentSoft,
    required this.shadow,
  });

  static const light = GalingoColors(
    pageBg: AppTheme.skyBlue,
    cardBg: Colors.white,
    softBg: Color(0xFFEDF3FA),
    textPrimary: AppTheme.textPrimary,
    textSecondary: AppTheme.textSecondary,
    textMuted: AppTheme.textHint,
    divider: Color(0xFFE3EDF8),
    accent: AppTheme.primaryBlue,
    accentSoft: AppTheme.surfaceBlue,
    shadow: Color(0x120B3C7A),
  );

  static const dark = GalingoColors(
    pageBg: AppTheme.backgroundDark,
    cardBg: AppTheme.surfaceDark,
    softBg: AppTheme.surfaceDark2,
    textPrimary: Color(0xFFEAF2FB),
    textSecondary: Color(0xFFA9BED6),
    textMuted: Color(0xFF7E93AB),
    divider: Color(0xFF2A4059),
    accent: AppTheme.primaryBlueLight,
    accentSoft: Color(0xFF1B3552),
    shadow: Color(0x40000000),
  );

  @override
  GalingoColors copyWith({
    Color? pageBg,
    Color? cardBg,
    Color? softBg,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? divider,
    Color? accent,
    Color? accentSoft,
    Color? shadow,
  }) {
    return GalingoColors(
      pageBg: pageBg ?? this.pageBg,
      cardBg: cardBg ?? this.cardBg,
      softBg: softBg ?? this.softBg,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      divider: divider ?? this.divider,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  GalingoColors lerp(ThemeExtension<GalingoColors>? other, double t) {
    if (other is! GalingoColors) return this;
    return GalingoColors(
      pageBg: Color.lerp(pageBg, other.pageBg, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      softBg: Color.lerp(softBg, other.softBg, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Atallos para ler a paleta dende calquera widget con `context`.
extension GalingoColorsContext on BuildContext {
  GalingoColors get palette =>
      Theme.of(this).extension<GalingoColors>() ?? GalingoColors.light;

  Color get pageBg => palette.pageBg;
  Color get cardBg => palette.cardBg;
  Color get softBg => palette.softBg;
  Color get textPrimary => palette.textPrimary;
  Color get textSecondary => palette.textSecondary;
  Color get textMuted => palette.textMuted;
  Color get divider => palette.divider;
  Color get accent => palette.accent;
  Color get accentSoft => palette.accentSoft;
  Color get shadow => palette.shadow;
}
