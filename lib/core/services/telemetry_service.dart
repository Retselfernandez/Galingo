import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../constants/app_constants.dart';
import '../../data/repositories/hive_repository.dart';

/// Cola offline **persistente** + sync de telemetría y feedback contra el backend.
///
/// La cola se guarda en Hive (`galingo_telemetry`) para no perder eventos si la
/// app se cierra o falla la red. Se sincroniza al arrancar y al recuperar conexión.
class TelemetryService {
  TelemetryService._();
  static final TelemetryService instance = TelemetryService._();

  String? _userId;
  String get userId => _userId ?? 'anonimo';

  final List<Map<String, dynamic>> _eventQueue = [];
  final List<Map<String, dynamic>> _feedbackQueue = [];

  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _syncing = false;

  String get baseUrl => AppConstants.apiBaseUrl;

  /// Inicializa el servicio: fija el user_id y **carga la cola persistida**.
  Future<void> init(String persistedUserId) async {
    _userId = persistedUserId;
    try {
      final q = HiveRepository.instance.loadTelemetryQueue();
      _eventQueue
        ..clear()
        ..addAll((q['events'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map)));
      _feedbackQueue
        ..clear()
        ..addAll((q['feedback'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map)));
      debugPrint(
          'Telemetría: cola cargada (${_eventQueue.length} ev, ${_feedbackQueue.length} fb)');
    } catch (e) {
      debugPrint('Telemetría: no se pudo cargar la cola: $e');
    }
  }

  Future<void> registerSession() async {
    if (_userId == null) return;
    final now = DateTime.now();
    final fecha =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      final client = http.Client();
      final r = await client
          .post(
            Uri.parse('$baseUrl/api/v1/sesion'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'fecha': fecha,
              'plataforma': defaultTargetPlatform.name,
            }),
          )
          .timeout(const Duration(seconds: 15));
      client.close();
      debugPrint('registerSession -> ${r.statusCode}');
    } catch (e) {
      debugPrint('registerSession error: $e');
    }
  }

  /// Escucha cambios de conectividad y sincroniza al recuperar red. Llama
  /// además a [sync] una vez al arrancar.
  void startSyncListener() {
    _connSub?.cancel();
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      if (_hasConnection(results)) sync();
    });
    unawaited(warmUp());
    sync();
  }

  /// "Despierta" el backend (si está dormido) con una petición ligera.
  /// Así el contenedor está caliente cuando el usuario llegue a un ejercicio
  /// de voz, evitando el arranque en frío en mitad de la lección.
  Future<void> warmUp() async {
    try {
      final client = http.Client();
      await client
          .get(Uri.parse('$baseUrl/api/v1/metricas'))
          .timeout(const Duration(seconds: 45));
      client.close();
    } catch (_) {}
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);

  Future<void> enqueueEvents(List<Map<String, dynamic>> events) async {
    if (events.isEmpty) return;
    _eventQueue.addAll(events);
    await _persist();
  }

  Future<void> enqueueFeedback(Map<String, dynamic> feedback) async {
    _feedbackQueue.add(feedback);
    await _persist();
  }

  Future<void> _persist() async {
    try {
      await HiveRepository.instance
          .saveTelemetryQueue(_eventQueue, _feedbackQueue);
    } catch (e) {
      debugPrint('Telemetría: no se pudo persistir la cola: $e');
    }
  }

  Future<void> sync() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final results = await Connectivity().checkConnectivity();
      if (!_hasConnection(results)) return;

      final client = http.Client();
      try {
        for (final ev in List.from(_eventQueue)) {
          final r = await client
              .post(
                Uri.parse('$baseUrl/api/v1/interaccion'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(ev),
              )
              .timeout(const Duration(seconds: 20));
          if (r.statusCode == 201) _eventQueue.remove(ev);
        }
        for (final fb in List.from(_feedbackQueue)) {
          final r = await client
              .post(
                Uri.parse('$baseUrl/api/v1/feedback'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(fb),
              )
              .timeout(const Duration(seconds: 20));
          if (r.statusCode == 201) _feedbackQueue.remove(fb);
        }
        await _persist();
        debugPrint(
            'Telemetría sincronizada. Pendiente: ${_eventQueue.length} ev, ${_feedbackQueue.length} fb');
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Telemetry sync error: $e');
    } finally {
      _syncing = false;
    }
  }

  Future<void> dispose() async {
    await _connSub?.cancel();
    _connSub = null;
  }
}
