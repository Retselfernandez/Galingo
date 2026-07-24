/// Idiomas de interfaz disponibles en Galingo
enum AppLanguage {
  es('Español', '🇪🇸', false),
  pt('Português', '🇵🇹', false),
  en('English', '🇬🇧', false),
  fr('Français', '🇫🇷', false),
  ar('عربي', '🇸🇦', true), // RTL
  ro('Română', '🇷🇴', false),
  it('Italiano', '🇮🇹', false),
  de('Deutsch', '🇩🇪', false),
  zh('中文', '🇨🇳', false);

  final String displayName;
  final String flag;
  final bool isRtl;
  const AppLanguage(this.displayName, this.flag, this.isRtl);
}

/// Familias de tipografía disponibles en Galingo
enum AppFontFamily {
  nunito('Nunito', 'Redondeada e amigable'),
  outfit('Outfit', 'Moderna e limpa'),
  roboto('Roboto', 'Clásica e lexible'),
  lato('Lato', 'Elegante e neutra');

  final String displayName;
  final String description;
  const AppFontFamily(this.displayName, this.description);
}

/// Escala de tamaño de fuente
enum AppFontSize {
  small(0.85, 'Pequeno'),
  normal(1.0, 'Normal'),
  large(1.15, 'Grande'),
  xlarge(1.30, 'Moi grande');

  final double scale;
  final String displayName;
  const AppFontSize(this.scale, this.displayName);
}

/// Modo de tema
enum AppThemeMode {
  light('Claro', '☀️'),
  dark('Escuro', '🌙'),
  system('Sistema', '⚙️');

  final String displayName;
  final String icon;
  const AppThemeMode(this.displayName, this.icon);
}

/// Modelo de configuración del usuario
class SettingsModel {
  final AppFontFamily fontFamily;
  final AppFontSize fontSize;
  final AppThemeMode themeMode;
  final AppLanguage language;
  final bool soundEnabled;

  const SettingsModel({
    this.fontFamily = AppFontFamily.nunito,
    this.fontSize = AppFontSize.normal,
    this.themeMode = AppThemeMode.light,
    this.language = AppLanguage.es,
    this.soundEnabled = true,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      fontFamily: AppFontFamily.values.firstWhere(
        (e) => e.name == json['fontFamily'],
        orElse: () => AppFontFamily.nunito,
      ),
      fontSize: AppFontSize.values.firstWhere(
        (e) => e.name == json['fontSize'],
        orElse: () => AppFontSize.normal,
      ),
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.light,
      ),
      language: AppLanguage.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => AppLanguage.es,
      ),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'fontFamily': fontFamily.name,
        'fontSize': fontSize.name,
        'themeMode': themeMode.name,
        'language': language.name,
        'soundEnabled': soundEnabled,
      };

  SettingsModel copyWith({
    AppFontFamily? fontFamily,
    AppFontSize? fontSize,
    AppThemeMode? themeMode,
    AppLanguage? language,
    bool? soundEnabled,
  }) {
    return SettingsModel(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}
