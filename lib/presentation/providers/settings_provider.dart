import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/services/audio_service.dart';
import '../../data/models/settings_model.dart';
import '../../data/repositories/hive_repository.dart';
import '../../data/repositories/memory_repository.dart';

/// Notifier para la configuración de la app
class SettingsNotifier extends Notifier<SettingsModel> {
  MemoryRepository get _repo => ref.read(repositoryProvider);

  @override
  SettingsModel build() {
    return _loadFromRepository();
  }

  SettingsModel _loadFromRepository() {
    try {
      return _repo.getSettings();
    } catch (_) {
      // Si no existe, detectar el idioma del sistema operativo
      final String systemLanguageCode = ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      
      AppLanguage defaultLanguage = AppLanguage.es; // Fallback si no está soportado
      for (final lang in AppLanguage.values) {
        if (lang.name == systemLanguageCode) {
          defaultLanguage = lang;
          break;
        }
      }
      
      return SettingsModel(language: defaultLanguage);
    }
  }

  Future<void> _save(SettingsModel settings) async {
    await _repo.saveSettings(settings);
    state = settings;
  }

  Future<void> setFontFamily(AppFontFamily family) async =>
      _save(state.copyWith(fontFamily: family));

  Future<void> setFontSize(AppFontSize size) async =>
      _save(state.copyWith(fontSize: size));

  Future<void> setThemeMode(AppThemeMode mode) async =>
      _save(state.copyWith(themeMode: mode));

  Future<void> setLanguage(AppLanguage language) async =>
      _save(state.copyWith(language: language));

  Future<void> toggleSound(bool enabled) async {
    AudioService.instance.setEnabled(enabled);
    await _save(state.copyWith(soundEnabled: enabled));
  }

  Future<void> resetToDefaults() async => _save(const SettingsModel());
}

/// Provider global de configuración
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsModel>(
  SettingsNotifier.new,
);

/// Provider de strings localizados — se actualiza al cambiar idioma
final appStringsProvider = Provider<AppStrings>((ref) {
  final language = ref.watch(settingsProvider.select((s) => s.language));
  return AppStrings.of(language);
});

/// Provider para conectar el toggle de sonido en Ajustes
final soundEnabledProvider = StateProvider<bool>((ref) {
  final enabled = ref.watch(settingsProvider.select((s) => s.soundEnabled));
  AudioService.instance.setEnabled(enabled);
  return enabled;
});
