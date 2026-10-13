import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Números en galego (para comparar "7" con "sete").
const Map<String, String> _numberWords = {
  '0': 'cero',
  '1': 'un',
  '2': 'dous',
  '3': 'tres',
  '4': 'catro',
  '5': 'cinco',
  '6': 'seis',
  '7': 'sete',
  '8': 'oito',
  '9': 'nove',
  '10': 'dez',
  '11': 'once',
  '12': 'doce',
  '13': 'trece',
  '14': 'catorce',
  '15': 'quince',
  '16': 'dezaseis',
  '17': 'dezasete',
  '18': 'dezaoito',
  '19': 'dezanove',
  '20': 'vinte',
  '30': 'trinta',
  '40': 'corenta',
  '50': 'cincuenta',
  '60': 'sesenta',
  '70': 'setenta',
  '80': 'oitenta',
  '90': 'noventa',
  '100': 'cen',
};

const Map<String, String> _fractions = {
  '1/2': 'medio',
  '1/4': 'un cuarto',
  '3/4': 'tres cuartos',
};

String _digitsToWords(String s) {
  var out = s;
  _fractions.forEach((k, v) {
    out = out.replaceAll(k, v);
  });
  return out.replaceAllMapped(RegExp(r'\d+'), (m) {
    final t = m.group(0)!;
    final direct = _numberWords[t];
    if (direct != null) return direct;
    return t.split('').map((c) => _numberWords[c] ?? c).join(' ');
  });
}

/// Normaliza a minúsculas, sen puntuación e con díxitos convertidos a palabra
/// (mantén os espazos, para poder dividir en palabras).
String normalizeText(String s) {
  var t = s.toLowerCase();
  t = _digitsToWords(t);
  t = t.replaceAll(RegExp(r'[.,;:!?¿¡"()\x27\u2018\u2019\u201C\u201D]'), '');
  return t.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _stripAccents(String s) {
  const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const to = 'aaaaaeeeeiiiiooooouuuunc';
  final b = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString();
}

/// Clave fonética tolerante ás variantes galego/portugués que produce o ASR
/// (p. ex. "miña"→"minha", "camiñar"→"caminhar") e á segmentación de palabras.
String _phonetic(String s) {
  var t = normalizeText(s);
  t = t
      .replaceAll('nh', 'ñ')
      .replaceAll('lh', 'll')
      .replaceAll('ç', 'z')
      .replaceAll('ss', 's')
      .replaceAll('y', 'i');
  t = _stripAccents(t);
  t = t.replaceAllMapped(RegExp(r'(.)\1+'), (m) => m.group(1)!);
  return t.replaceAll(' ', '');
}

/// Distancia Levenshtein normalizada → similitud 0..1.
double textSimilarity(String a, String b) {
  final x = _phonetic(a);
  final y = _phonetic(b);
  if (x.isEmpty || y.isEmpty) return 0.0;
  final m = x.length, n = y.length;
  final d = List.generate(m + 1, (_) => List.filled(n + 1, 0));
  for (var i = 0; i <= m; i++) {
    d[i][0] = i;
  }
  for (var j = 0; j <= n; j++) {
    d[0][j] = j;
  }
  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      d[i][j] = x[i - 1] == y[j - 1]
          ? d[i - 1][j - 1]
          : 1 +
              [d[i - 1][j], d[i][j - 1], d[i - 1][j - 1]]
                  .reduce((v, e) => v < e ? v : e);
    }
  }
  final dist = d[m][n];
  return 1 - dist / (x.length > y.length ? x.length : y.length);
}

/// Resultado de una palabra objetivo dentro de la evaluación.
class WordResult {
  final String palabra;
  final bool acierto;
  const WordResult({required this.palabra, required this.acierto});
}

/// Resultado de evaluar un audio contra una frase objetivo (todo local).
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
}

/// ASR **100 % en el dispositivo** con sherpa-onnx + Whisper (gallego).
///
/// El modelo va empaquetado en los assets de la app y, la primera vez, se
/// copia a un directorio interno accesible por la librería nativa. A partir de
/// ahí funciona **sin internet**: el audio nunca sale del dispositivo.
class AsrService {
  AsrService._();
  static final AsrService instance = AsrService._();

  static const String _assetDir = 'assets/models/whisper';
  static const List<String> _files = <String>[
    'encoder.int8.onnx',
    'decoder.int8.onnx',
    'tokens.txt',
  ];

  sherpa.OfflineRecognizer? _recognizer;
  Future<void>? _ready;

  bool get isReady => _recognizer != null;

  /// Prepara el reconocedor (copia el modelo la primera vez). Idempotente.
  ///
  /// [onProgress] recibe 0..1 mientras se copia el modelo.
  Future<void> ensureReady({ValueChanged<double>? onProgress}) {
    final existing = _ready;
    if (existing != null) return existing;
    final future = _init(onProgress);
    _ready = future;
    // Si falla, permitir reintentar más tarde.
    future.catchError((Object e) {
      _ready = null;
      throw e;
    });
    return future;
  }

  Future<void> _init(ValueChanged<double>? onProgress) async {
    await sherpa.initBindingsAsync();

    final dir = await getApplicationSupportDirectory();
    final modelDir = Directory('${dir.path}/whisper');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }

    for (var i = 0; i < _files.length; i++) {
      final name = _files[i];
      final dest = File('${modelDir.path}/$name');
      final asset = await rootBundle.load('$_assetDir/$name');
      final bytes = asset.buffer
          .asUint8List(asset.offsetInBytes, asset.lengthInBytes);
      if (!await dest.exists() || (await dest.length()) != bytes.length) {
        await dest.writeAsBytes(bytes, flush: true);
      }
      onProgress?.call((i + 1) / _files.length);
    }

    _recognizer = sherpa.OfflineRecognizer(
      sherpa.OfflineRecognizerConfig(
        model: sherpa.OfflineModelConfig(
          whisper: sherpa.OfflineWhisperModelConfig(
            encoder: '${modelDir.path}/encoder.int8.onnx',
            decoder: '${modelDir.path}/decoder.int8.onnx',
            language: 'gl',
            task: 'transcribe',
          ),
          tokens: '${modelDir.path}/tokens.txt',
          modelType: 'whisper',
          numThreads: 4,
          debug: false,
        ),
      ),
    );
  }

  /// Transcribe un fichero WAV (16 kHz mono) a texto en gallego.
  Future<String> transcribeFile(String wavPath) async {
    await ensureReady();
    final recognizer = _recognizer;
    if (recognizer == null) return '';
    final wave = sherpa.readWave(wavPath);
    if (wave.samples.isEmpty) return '';
    final stream = recognizer.createStream();
    try {
      stream.acceptWaveform(
        samples: wave.samples,
        sampleRate: wave.sampleRate == 0 ? 16000 : wave.sampleRate,
      );
      recognizer.decode(stream);
      return recognizer.getResult(stream).text.trim();
    } finally {
      stream.free();
    }
  }

  /// Evalúa un audio contra la frase objetivo y devuelve el resultado.
  Future<VoiceEvalResult> evaluar({
    required String audioPath,
    required String target,
    double umbral = 0.7,
  }) async {
    final transcript = _dedupeSentences(await transcribeFile(audioPath));
    final sim = textSimilarity(transcript, target);
    return VoiceEvalResult(
      transcript: transcript,
      similitud: sim,
      aprobado: sim >= umbral,
      palabras: _perWord(target, transcript),
    );
  }

  /// Quita repeticións consecutivas (artefacto dalgúns modelos Whisper).
  String _dedupeSentences(String s) {
    final cleaned = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return '';
    final parts = cleaned.split(RegExp(r'[.!?]+'));
    final out = <String>[];
    for (var p in parts) {
      p = p.trim();
      if (p.isEmpty) continue;
      if (out.isNotEmpty) {
        final last = out.last;
        if (p.contains(last) || last.contains(p)) {
          if (p.length <= last.length) continue;
          out[out.length - 1] = p;
          continue;
        }
      }
      out.add(p);
    }
    return out.join('. ');
  }

  List<WordResult> _perWord(String target, String transcript) {
    final displayWords =
        target.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final saidWords = normalizeText(transcript)
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    return displayWords.map((w) {
      var best = 0.0;
      for (final said in saidWords) {
        final s = textSimilarity(w, said);
        if (s > best) best = s;
      }
      return WordResult(palabra: w, acierto: best >= 0.7);
    }).toList();
  }
}
