import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

/// Resultado de evaluar un audio contra una frase objetivo (backend Whisper gl).
class WordResult {
  final String palabra;
  final bool acierto;
  const WordResult({required this.palabra, required this.acierto});

  factory WordResult.fromJson(Map<String, dynamic> j) => WordResult(
        palabra: j['palabra'] as String? ?? '',
        acierto: j['acierto'] as bool? ?? false,
      );
}

class VoiceEvalResult {
  final String transcript;
  final double similitud;
  final bool aprobado;
  final List<WordResult> palabras;

  const VoiceEvalResult({
    required this.transcript,
    required this.similitud,
    required this.aprobado,
    required this.palabras,
  });

  factory VoiceEvalResult.fromJson(Map<String, dynamic> j) => VoiceEvalResult(
        transcript: j['transcript'] as String? ?? '',
        similitud: (j['similitud'] as num?)?.toDouble() ?? 0.0,
        aprobado: j['aprobado'] as bool? ?? false,
        palabras: ((j['palabras'] as List?) ?? [])
            .map((e) => WordResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Cliente del endpoint de evaluación de voz (ASR gallego en el backend).
class VoiceEvalService {
  VoiceEvalService._();
  static final VoiceEvalService instance = VoiceEvalService._();

  String get baseUrl => AppConstants.apiBaseUrl;

  /// Sube el audio y devuelve la evaluación, o null si el backend no responde.
  Future<VoiceEvalResult?> evaluar({
    required String audioPath,
    required String target,
    double umbral = 0.7,
  }) async {
    try {
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/voz/avaliar'),
      );
      req.fields['target'] = target;
      req.fields['umbral'] = umbral.toString();
      req.files.add(await http.MultipartFile.fromPath('audio', audioPath));

      final streamed = await req.send().timeout(const Duration(seconds: 45));
      final resp = await http.Response.fromStream(streamed);
      if (resp.statusCode != 200) {
        debugPrint('VoiceEval HTTP ${resp.statusCode}: ${resp.body}');
        return null;
      }
      return VoiceEvalResult.fromJson(
        jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('VoiceEval error: $e');
      return null;
    }
  }
}
