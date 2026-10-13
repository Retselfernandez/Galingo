import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:galingo/l10n/app_localizations.dart';
import 'package:galingo/core/constants/app_constants.dart';
import 'package:galingo/core/services/asr_service.dart';

/// Ejercicio de voz **offline**: graba con el micrófono y evalúa la pronuncia
/// contra la frase objetivo usando el ASR on-device (sherpa-onnx + Whisper gl).
/// El audio nunca sale del dispositivo.
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
  final AudioRecorder _recorder = AudioRecorder();
  bool _recording = false;
  bool _busy = false; // transcribiendo
  bool _preparing = false; // cargando/copiando el modelo
  double _prepProgress = 0.0;
  bool _modelReady = false;
  VoiceEvalResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Prepara el modelo en segundo plano (la 1ª vez copia ~370 MB).
    _prepareModel();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _prepareModel() async {
    if (_modelReady || _preparing) return;
    setState(() {
      _preparing = true;
      _prepProgress = 0.0;
      _error = null;
    });
    try {
      await AsrService.instance.ensureReady(onProgress: (p) {
        if (mounted) setState(() => _prepProgress = p);
      });
      if (mounted) {
        setState(() {
          _modelReady = true;
          _preparing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _preparing = false;
          _error = '${AppLocalizations.of(context)!.recordError}: $e';
        });
      }
    }
  }

  Future<void> _toggleRecord() async {
    if (_busy || _preparing) return;
    if (_recording) {
      await _stopAndEval();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!_modelReady) {
      await _prepareModel();
      if (!_modelReady) return;
    }
    try {
      if (!await _recorder.hasPermission()) {
        setState(
            () => _error = AppLocalizations.of(context)!.micPermissionDenied);
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/galingo_rec_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
      setState(() {
        _recording = true;
        _error = null;
        _result = null;
      });
    } catch (e) {
      setState(
          () => _error = '${AppLocalizations.of(context)!.recordError}: $e');
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
    try {
      final res = await AsrService.instance.evaluar(
        audioPath: path,
        target: widget.targetText,
        umbral: AppConstants.speechPassThreshold,
      );
      widget.onTranscribed(res.transcript);
      if (!mounted) return;
      setState(() {
        _result = res;
        _busy = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = '${AppLocalizations.of(context)!.recordError}: $e';
      });
    } finally {
      try {
        File(path).delete();
      } catch (_) {}
    }
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
        _buildMic(context),
        const SizedBox(height: 12),
        if (_preparing) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LinearProgressIndicator(
              value: _prepProgress == 0 ? null : _prepProgress,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.voiceModelLoading,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
        if (_busy)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(l.exSpeech,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        if (_result != null) _buildResult(context, l, _result!),
        if (_error != null && _result == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.orange, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        if (_modelReady && _result == null && !_busy)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.offline_bolt, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  l.voiceOnDevice,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMic(BuildContext context) {
    return GestureDetector(
      onTap: _toggleRecord,
      child: CircleAvatar(
        radius: 36,
        backgroundColor: _recording
            ? Colors.red
            : (_preparing
                ? Colors.grey
                : Theme.of(context).primaryColor),
        child: _preparing
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: Colors.white),
              )
            : Icon(
                _recording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 36,
              ),
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
              : (res.similitud >= AppConstants.speechAlmostThreshold
                  ? '${l.speakAlmost} ($pct%) — ${l.speakRetry}'
                  : '${l.speakKeepTrying} ($pct%)'),
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
}
