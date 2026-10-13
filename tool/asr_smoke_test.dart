// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

void main(List<String> args) {
  sherpa.initBindings();
  final recognizer = sherpa.OfflineRecognizer(sherpa.OfflineRecognizerConfig(
    model: sherpa.OfflineModelConfig(
      whisper: sherpa.OfflineWhisperModelConfig(
        encoder: 'assets/models/whisper-small/small-encoder.int8.onnx',
        decoder: 'assets/models/whisper-small/small-decoder.int8.onnx',
        language: 'gl',
        task: 'transcribe',
      ),
      tokens: 'assets/models/whisper-small/small-tokens.txt',
      modelType: 'whisper',
      numThreads: 2,
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
