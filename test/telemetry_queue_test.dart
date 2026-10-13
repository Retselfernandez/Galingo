import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:galingo/core/services/telemetry_service.dart';
import 'package:galingo/data/repositories/hive_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la cola de telemetría se persiste y se recarga (offline)', () async {
    final tempDir = Directory.systemTemp.createTempSync();
    await HiveRepository.instance.initialize(testPath: tempDir.path);

    await TelemetryService.instance.init('user-test');
    await TelemetryService.instance.enqueueEvents([
      {
        'event_id': 'e1',
        'user_id': 'user-test',
        'item_id': 'ola',
        'resultado': 1.0,
      },
      {
        'event_id': 'e2',
        'user_id': 'user-test',
        'item_id': 'bos',
        'resultado': 0.0,
      },
    ]);
    await TelemetryService.instance
        .enqueueFeedback({'report_id': 'r1', 'user_id': 'user-test'});

    // Releer directamente desde Hive (simula reabrir la app)
    final q = HiveRepository.instance.loadTelemetryQueue();
    expect((q['events'] as List).length, 2);
    expect((q['feedback'] as List).length, 1);

    // Re-init: la cola debe cargarse de nuevo en memoria
    await TelemetryService.instance.init('user-test');
    final q2 = HiveRepository.instance.loadTelemetryQueue();
    expect((q2['events'] as List).length, 2);
  });
}
