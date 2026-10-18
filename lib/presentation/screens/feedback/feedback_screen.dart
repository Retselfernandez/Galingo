import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:galingo/core/router/app_router.dart';
import 'package:galingo/core/services/telemetry_service.dart';
import 'package:galingo/l10n/app_localizations.dart';
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
  void initState() {
    super.initState();
    // FIX: reconstruír ao escribir para que "Enviar reporte" se active só.
    // Antes só se activaba ao tocar noutro control (p. ex. o desplegable),
    // que era o que reportou o tester.
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
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
    await TelemetryService.instance.enqueueFeedback(payload);
    await TelemetryService.instance.sync();
    if (mounted) setState(() => _enviado = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_enviado) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l.reportThanks),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: l.backToHome,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.reportSent, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.home_outlined),
                  label: Text(l.backToHome),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.reportProblem),
        // FIX: a pantalla ábrese con `context.go` (substitúe a pila), polo que
        // o AppBar non amosaba frecha de volta. Engadímola explicitamente.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l.backToHome,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _categoria,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 'bug', child: Text(l.categoryBug)),
                DropdownMenuItem(
                    value: 'sugerencia', child: Text(l.categorySuggestion)),
                DropdownMenuItem(
                    value: 'contenido', child: Text(l.categoryContent)),
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
                decoration: InputDecoration(
                  hintText: l.reportDescribeHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _controller.text.trim().isEmpty ? null : _enviar,
                child: Text(l.reportSend),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
