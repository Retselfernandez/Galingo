import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Servicio de síntesis de voz (TTS) para el vocabulario de Galingo.
/// Configura locuciones en gallego, con fallback inteligente a español/portugués.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> _init() async {
    if (_isInitialized) return;
    try {
      // Configuración de gallego ("gl-ES")
      await _flutterTts.setLanguage("gl-ES");
      await _flutterTts.setSpeechRate(0.45); // Velocidad pausada idónea para aprendizaje
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint("TTS Initialization error: $e");
    }
  }

  /// Lee el texto indicado [text] en gallego de forma asíncrona.
  Future<void> speak(String text) async {
    await _init();
    try {
      // Comprobar disponibilidad de idioma gallego
      final isLanguageAvailable = await _flutterTts.isLanguageAvailable("gl-ES") as bool? ?? false;
      
      if (!isLanguageAvailable) {
        // Fallback a portugués (pt-PT) por similitud fonética estrecha al gallego
        // o español (es-ES) si el primero tampoco está disponible
        final isPtAvailable = await _flutterTts.isLanguageAvailable("pt-PT") as bool? ?? false;
        if (isPtAvailable) {
          await _flutterTts.setLanguage("pt-PT");
        } else {
          await _flutterTts.setLanguage("es-ES");
        }
      } else {
        await _flutterTts.setLanguage("gl-ES");
      }
      
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("TTS Speak failed: $e");
    }
  }

  /// Detiene cualquier lectura activa de voz.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
