import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Distancia Levenshtein normalizada → similitud 0..1
double textSimilarity(String a, String b) {
  String clean(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[.,;:!?¿¡"()\x27]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final x = clean(a);
  final y = clean(b);
  if (x.isEmpty || y.isEmpty) return 0.0;
  final m = x.length, n = y.length;
  final d = List.generate(m + 1, (_) => List.filled(n + 1, 0));
  for (var i = 0; i <= m; i++) d[i][0] = i;
  for (var j = 0; j <= n; j++) d[0][j] = j;
  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      d[i][j] = x[i - 1] == y[j - 1]
          ? d[i - 1][j - 1]
          : 1 + [d[i - 1][j], d[i][j - 1], d[i - 1][j - 1]].reduce((v, e) => v < e ? v : e);
    }
  }
  final dist = d[m][n];
  return 1 - dist / (x.length > y.length ? x.length : y.length);
}

/// Ejercicio de pronunciación: graba con ASR y compara con el objetivo.
class SpeechExercise extends StatefulWidget {
  final String targetText;
  final ValueChanged<String> onTranscribed;
  const SpeechExercise({super.key, required this.targetText, required this.onTranscribed});

  @override
  State<SpeechExercise> createState() => _SpeechExerciseState();
}

class _SpeechExerciseState extends State<SpeechExercise> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;
  bool _listening = false;
  String _transcription = '';

  @override
  void initState() {
    super.initState();
    _speech.initialize().then((ok) => setState(() => _available = ok));
  }

  Future<void> _listen() async {
    if (!_available) return;
    setState(() {
      _listening = true;
      _transcription = '';
    });
    await _speech.listen(
      localeId: 'gl_ES',
      onResult: (r) => setState(() {
        _transcription = r.recognizedWords;
        widget.onTranscribed(_transcription);
      }),
    );
  }

  Future<void> _stop() async {
    await _speech.stop();
    setState(() => _listening = false);
  }

  @override
  Widget build(BuildContext context) {
    final sim = _transcription.isEmpty ? null : textSimilarity(_transcription, widget.targetText);
    return Column(
      children: [
        Text(widget.targetText,
            style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        GestureDetector(
          onTapDown: (_) => _listen(),
          onTapUp: (_) => _stop(),
          onTapCancel: _stop,
          child: CircleAvatar(
            radius: 36,
            backgroundColor: _listening ? Colors.red : Theme.of(context).primaryColor,
            child: const Icon(Icons.mic, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 16),
        if (_transcription.isNotEmpty) ...[
          Text(_transcription, style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          if (sim != null)
            Text(
              sim >= 0.8
                  ? '¡Excelente! (${(sim * 100).round()}%)'
                  : sim >= 0.5
                      ? 'Casi… (${(sim * 100).round()}%) — inténtalo de nuevo'
                      : 'Sigue practicando (${(sim * 100).round()}%)',
              style: TextStyle(
                color: sim >= 0.8 ? Colors.green : (sim >= 0.5 ? Colors.orange : Colors.red),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ],
    );
  }
}
