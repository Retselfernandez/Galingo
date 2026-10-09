import 'package:audioplayers/audioplayers.dart';

enum SoundEffect { success, error, levelUp, streakKept, unitUnlocked }

class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final Map<SoundEffect, AudioPlayer> _players = {};
  AudioPlayer? _exercisePlayer;
  bool _soundEnabled = true;
  double _volume = 0.8;
  bool _initialized = false;

  static const Map<SoundEffect, String> _assetPaths = {
    SoundEffect.success: 'audio/success.mp3',
    SoundEffect.error: 'audio/error.mp3',
    SoundEffect.levelUp: 'audio/level_up.mp3',
    SoundEffect.streakKept: 'audio/streak.mp3',
    SoundEffect.unitUnlocked: 'audio/unlock.mp3',
  };

  /// Llamar una sola vez al arrancar la app (por ejemplo, en main() antes de runApp,
  /// o de forma diferida en el primer frame para no bloquear el arranque).
  Future<void> init() async {
    if (_initialized) return;
    for (final effect in SoundEffect.values) {
      final player = AudioPlayer(playerId: 'sfx_${effect.name}');
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(_volume);
      try {
        await player.setSource(AssetSource(_assetPaths[effect]!));
      } catch (_) {
        // Si falta el asset, no se bloquea el resto de la app.
      }
      _players[effect] = player;
    }
    _initialized = true;
  }

  /// Conectar esto al toggle de "Sonido" en Ajustes.
  void setEnabled(bool enabled) => _soundEnabled = enabled;
  bool get isEnabled => _soundEnabled;

  /// Conectar esto al slider de volumen en Ajustes. Rango 0.0–1.0.
  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0);
    for (final player in _players.values) {
      player.setVolume(_volume);
    }
    _exercisePlayer?.setVolume(_volume);
  }

  /// Reproduce un efecto. Nunca lanza excepción hacia arriba: un fallo de
  /// audio no debe interrumpir el flujo de la lección.
  Future<void> play(SoundEffect effect) async {
    if (!_soundEnabled || !_initialized) return;
    final player = _players[effect];
    if (player == null) return;
    try {
      await player.seek(Duration.zero);
      await player.resume();
    } catch (_) {
      // Fallo silencioso deliberado.
    }
  }

  /// Métodos de compatibilidad con llamadas anteriores
  Future<void> playSuccess() => play(SoundEffect.success);
  Future<void> playError() => play(SoundEffect.error);
  Future<void> playLevelUp() => play(SoundEffect.levelUp);

  /// Reproduce un audio de ejercicio (p. ej. `assets/audio/exercises/1E01.mp3`).
  /// Nunca lanza excepción: un fallo de audio no debe interrumpir la lección.
  Future<void> playAsset(String assetPath) async {
    if (!_soundEnabled) return;
    final src = assetPath.startsWith('assets/')
        ? assetPath.substring('assets/'.length)
        : assetPath;
    try {
      _exercisePlayer ??= AudioPlayer(playerId: 'exercise_audio');
      await _exercisePlayer!.stop();
      await _exercisePlayer!.setVolume(_volume);
      await _exercisePlayer!.play(AssetSource(src));
    } catch (_) {
      // Fallo silencioso deliberado.
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    await _exercisePlayer?.dispose();
    _exercisePlayer = null;
    _initialized = false;
  }
}
