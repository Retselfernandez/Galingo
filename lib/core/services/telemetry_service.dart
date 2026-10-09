import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../constants/app_constants.dart';

/// Cola offline + sync de telemetría y feedback contra el backend Galingo.
class TelemetryService {
  TelemetryService._();
  static final TelemetryService instance = TelemetryService._();

  String? _userId;
  String get userId => _userId!;
  void init(String persistedUserId) => _userId = persistedUserId;

  Future<void> registerSession() async {
    if (_userId == null) return;
    final now = DateTime.now();
    final fecha = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      final client = http.Client();
      await client.post(
        Uri.parse('$baseUrl/api/v1/sesion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'fecha': fecha}),
      );
      client.close();
    } catch (e) {
      debugPrint('registerSession error: $e');
    }
  }

  String get baseUrl => AppConstants.apiBaseUrl;

  final List<Map<String, dynamic>> _eventQueue = [];
  final List<Map<String, dynamic>> _feedbackQueue = [];

  void enqueueEvents(List<Map<String, dynamic>> events) {
    _eventQueue.addAll(events);
  }

  void enqueueFeedback(Map<String, dynamic> feedback) {
    _feedbackQueue.add(feedback);
  }

  Future<void> sync() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final client = http.Client();
    try {
      for (final ev in List.from(_eventQueue)) {
        final r = await client.post(
          Uri.parse('$baseUrl/api/v1/interaccion'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(ev),
        );
        if (r.statusCode == 201) _eventQueue.remove(ev);
      }
      for (final fb in List.from(_feedbackQueue)) {
        final r = await client.post(
          Uri.parse('$baseUrl/api/v1/feedback'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(fb),
        );
        if (r.statusCode == 201) _feedbackQueue.remove(fb);
      }
    } catch (e) {
      debugPrint('Telemetry sync error: $e');
    } finally {
      client.close();
    }
  }
}
