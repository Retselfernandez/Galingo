// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

void main(List<String> args) {
  final dir = Platform.environment['ASR_MODEL_DIR'] ??
      'assets/models/whisper-medium';
  final enc = Platform.environment['ASR_ENCODER'] ?? 'medium-encoder.int8.onnx';
  final dec = Platform.environment['ASR_DECODER'] ?? 'medium-decoder.int8.onnx';
  final tok = Platform.environment['ASR_TOKENS'] ?? 'medium-tokens.txt';
  sherpa.initBindings();
  final recognizer = sherpa.OfflineRecognizer(sherpa.OfflineRecognizerConfig(
    model: sherpa.OfflineModelConfig(
      whisper: sherpa.OfflineWhisperModelConfig(
        encoder: '$dir/$enc',
        decoder: '$dir/$dec',
        language: 'gl',
        task: 'transcribe',
      ),
      tokens: '$dir/$tok',
      modelType: 'whisper',
      numThreads: 4,
      debug: false,
    ),
  ));
  final out = File(args[0]).openWrite();
  for (final path in args.skip(1)) {
    final wave = sherpa.readWave(path);
    final stream = recognizer.createStream();
    stream.acceptWaveform(samples: wave.samples, sampleRate: wave.sampleRate);
    recognizer.decode(stream);
    out.writeln('${File(path).uri.pathSegments.last}\t${recognizer.getResult(stream).text}');
    stream.free();
  }
  out.close();
  recognizer.free();
}
