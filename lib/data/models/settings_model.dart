/// Idiomas de interfaz disponibles en Galingo
enum AppLanguage {
  es('Español', '🇪🇸'),
  pt('Português', '🇵🇹'),
  en('English', '🇬🇧'),
  fr('Français', '🇫🇷'),
  ro('Română', '🇷🇴'),
  it('Italiano', '🇮🇹'),
  de('Deutsch', '🇩🇪'),
  zh('中文', '🇨🇳');

  final String displayName;
  final String flag;
  const AppLanguage(this.displayName, this.flag);
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
  final bool remindersEnabled;
  final int reminderHour;
  final int reminderMinute;

  const SettingsModel({
    this.fontFamily = AppFontFamily.nunito,
    this.fontSize = AppFontSize.normal,
    this.themeMode = AppThemeMode.light,
    this.language = AppLanguage.es,
    this.soundEnabled = true,
    this.remindersEnabled = false,
    this.reminderHour = 13,
    this.reminderMinute = 30,
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
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      reminderHour: json['reminderHour'] as int? ?? 13,
      reminderMinute: json['reminderMinute'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toJson() => {
        'fontFamily': fontFamily.name,
        'fontSize': fontSize.name,
        'themeMode': themeMode.name,
        'language': language.name,
        'soundEnabled': soundEnabled,
        'remindersEnabled': remindersEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
      };

  SettingsModel copyWith({
    AppFontFamily? fontFamily,
    AppFontSize? fontSize,
    AppThemeMode? themeMode,
    AppLanguage? language,
    bool? soundEnabled,
    bool? remindersEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return SettingsModel(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }
}
