import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:galingo/core/services/telemetry_service.dart';
import 'package:galingo/presentation/providers/progress_provider.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});
  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  String _categoria = 'bug';
  final _controller = TextEditingController();
  bool _enviado = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final progress = ref.read(progressNotifierProvider).valueOrNull;
    final payload = {
      'report_id': const Uuid().v4(),
      'user_id': TelemetryService.instance.userId,
      'categoria': _categoria,
      'texto': _controller.text.trim(),
      'plataforma': Platform.operatingSystem,
      'version_app': '1.0.0',
      'pantalla': ModalRoute.of(context)?.settings.name ?? 'desconocida',
      'mae_hlr': progress?.hlrMae,
      'mae_sm2': progress?.sm2Mae,
      'eventos_recientes': (progress?.hlrEvents ?? const [])
          .take(20)
          .map((e) => e.toJson())
          .toList(),
    };
    TelemetryService.instance.enqueueFeedback(payload);
    await TelemetryService.instance.sync();
    if (mounted) setState(() => _enviado = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_enviado) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grazas!')),
        body: const Center(child: Text('Reporte enviado. ¡Grazas polo teu feedback!')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar un problema')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _categoria,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'bug', child: Text('🐛 Erro / Bug')),
                DropdownMenuItem(value: 'sugerencia', child: Text('💡 Suxerencia')),
                DropdownMenuItem(value: 'contenido', child: Text('📚 Contido')),
              ],
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Describe o problema ou suxerencia...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _controller.text.trim().isEmpty ? null : _enviar,
                child: const Text('Enviar reporte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
