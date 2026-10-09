import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:galingo/l10n/app_localizations.dart';
import 'package:galingo/core/constants/app_constants.dart';
import 'package:galingo/core/services/voice_eval_service.dart';

/// Distancia Levenshtein normalizada → similitud 0..1 (fallback local).
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
          : 1 +
              [d[i - 1][j], d[i][j - 1], d[i - 1][j - 1]]
                  .reduce((v, e) => v < e ? v : e);
    }
  }
  final dist = d[m][n];
  return 1 - dist / (x.length > y.length ? x.length : y.length);
}

/// Ejercicio de voz: graba con el micrófono y evalúa contra el objetivo.
/// Intenta el backend (Whisper gallego); si no responde, usa ASR local.
class SpeechExercise extends StatefulWidget {
  final String targetText;
  final ValueChanged<String> onTranscribed;
  const SpeechExercise({
    super.key,
    required this.targetText,
    required this.onTranscribed,
  });

  @override
  State<SpeechExercise> createState() => _SpeechExerciseState();
}

class _SpeechExerciseState extends State<SpeechExercise> {
  // Backend (grabación → POST)
  final AudioRecorder _recorder = AudioRecorder();
  bool _recording = false;
  bool _busy = false;
  bool _backendDown = false;
  VoiceEvalResult? _result;
  String? _error;

  // Fallback local (speech_to_text)
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _localReady = false;
  bool _listening = false;
  String _localTranscript = '';
  double? _localSim;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  // ─── Backend ─────────────────────────────────────────────────────────────
  Future<void> _toggleRecord() async {
    if (_busy) return;
    if (_recording) {
      await _stopAndEval();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        setState(() => _error = 'Permiso de micrófono denegado');
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/galingo_rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      setState(() {
        _recording = true;
        _error = null;
        _result = null;
        _localTranscript = '';
        _localSim = null;
      });
    } catch (e) {
      setState(() => _error = 'Erro ao gravar: $e');
    }
  }

  Future<void> _stopAndEval() async {
    final path = await _recorder.stop();
    setState(() {
      _recording = false;
      _busy = true;
    });
    if (path == null) {
      setState(() => _busy = false);
      return;
    }
    final res = await VoiceEvalService.instance.evaluar(
      audioPath: path,
      target: widget.targetText,
      umbral: AppConstants.speechPassThreshold,
    );
    try {
      File(path).delete();
    } catch (_) {}
    if (!mounted) return;
    if (res != null) {
      widget.onTranscribed(res.transcript);
      setState(() {
        _result = res;
        _busy = false;
        _error = null;
      });
    } else {
      setState(() {
        _busy = false;
        _backendDown = true;
        _error = 'Servidor de voz non dispoñible; usando recoñecemento local';
      });
      await _initLocal();
    }
  }

  // ─── Fallback local ────────────────────────────────────────────────────────
  Future<void> _initLocal() async {
    if (_localReady) return;
    final ok = await _speech.initialize();
    if (!mounted) return;
    setState(() => _localReady = ok);
    if (!ok) setState(() => _error = 'Recoñecemento de voz non dispoñible');
  }

  Future<void> _toggleLocal() async {
    if (!_localReady) await _initLocal();
    if (!_localReady) return;
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() {
      _listening = true;
      _localTranscript = '';
      _localSim = null;
    });
    await _speech.listen(
      onResult: (r) {
        final text = r.recognizedWords;
        final sim = textSimilarity(text, widget.targetText);
        widget.onTranscribed(text);
        setState(() {
          _localTranscript = text;
          _localSim = sim;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          widget.targetText,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (_backendDown) _buildLocalMic(context, l) else _buildRecordMic(l),
        const SizedBox(height: 12),
        if (_busy)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
        if (_result != null) _buildResult(context, l, _result!),
        if (_localTranscript.isNotEmpty && _result == null)
          _buildLocalResult(context, l),
        if (_error != null && _result == null && _localTranscript.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.orange, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildRecordMic(AppLocalizations l) {
    return GestureDetector(
      onTap: _toggleRecord,
      child: CircleAvatar(
        radius: 36,
        backgroundColor: _recording ? Colors.red : Theme.of(context).primaryColor,
        child: Icon(
          _recording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildLocalMic(BuildContext context, AppLocalizations l) {
    return GestureDetector(
      onTap: _toggleLocal,
      child: CircleAvatar(
        radius: 36,
        backgroundColor: _listening ? Colors.red : Theme.of(context).primaryColor,
        child: const Icon(Icons.mic, color: Colors.white, size: 36),
      ),
    );
  }

  Widget _buildResult(
      BuildContext context, AppLocalizations l, VoiceEvalResult res) {
    final pct = (res.similitud * 100).round();
    final color = res.aprobado
        ? Colors.green
        : (res.similitud >= AppConstants.speechAlmostThreshold
            ? Colors.orange
            : Colors.red);
    return Column(
      children: [
        Text(
          res.transcript,
          style: const TextStyle(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          res.aprobado
              ? '${l.speakExcellent} ($pct%)'
              : '${l.speakKeepTrying} ($pct%)',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: res.palabras
              .map((w) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: w.acierto
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: w.acierto ? Colors.green : Colors.red),
                    ),
                    child: Text(
                      w.palabra,
                      style: TextStyle(
                        color: w.acierto ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLocalResult(BuildContext context, AppLocalizations l) {
    final sim = _localSim ?? 0.0;
    final pct = (sim * 100).round();
    return Column(
      children: [
        Text(
          _localTranscript,
          style: const TextStyle(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          sim >= AppConstants.speechPassThreshold
              ? '${l.speakExcellent} ($pct%)'
              : sim >= AppConstants.speechAlmostThreshold
                  ? '${l.speakAlmost} ($pct%) — ${l.speakRetry}'
                  : '${l.speakKeepTrying} ($pct%)',
          style: TextStyle(
            color: sim >= AppConstants.speechPassThreshold
                ? Colors.green
                : (sim >= AppConstants.speechAlmostThreshold
                    ? Colors.orange
                    : Colors.red),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
