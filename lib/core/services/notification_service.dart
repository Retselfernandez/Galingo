import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/refran.dart';

/// Recordatorios diarios locais (sen servidor) cun refrán en galego.
///
/// Regras:
/// - Só se programa se o usuario activou os recordatorios.
/// - Se hoxe xa fixo unha lección, hoxe non se lle molesta.
/// - Emprégase alarma **inexacta** (Play-safe), así que pode chegar uns
///   minutos tarde; para un recordatorio é suficiente.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const int _baseId = 4200;
  static const int _daysAhead = 14;
  static const String _channelId = 'galingo_reminders';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> init() async {
    if (!isSupported) return;
    try {
      tzdata.initializeTimeZones();
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
    } catch (e) {
      debugPrint('NotificationService.init: $e');
    }
  }

  /// Pide permiso ao usuario (só cando activa os recordatorios).
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }
    return false;
  }

  /// Reprograma os próximos días (cancelando antes os pendentes).
  Future<void> reschedule({
    required bool enabled,
    required int hour,
    required int minute,
    required String userName,
    required bool alreadyDoneToday,
  }) async {
    if (!_ready) return;
    await cancelAll();
    if (!enabled) return;

    final now = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < _daysAhead; i++) {
      final day = now.add(Duration(days: i));
      final when =
          tz.TZDateTime(tz.local, day.year, day.month, day.day, hour, minute);
      if (!when.isAfter(now)) continue;
      if (i == 0 && alreadyDoneToday) continue;

      final refran = refranForDate(when);
      try {
        await _plugin.zonedSchedule(
          id: _baseId + i,
          title: '«${refran.gl}»',
          body: '$userName, fai a túa lección de hoxe.\n${refran.es}',
          scheduledDate: when,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              'Recordatorios',
              channelDescription: 'Lembretes diarios con refráns en galego',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (e) {
        debugPrint('NotificationService.schedule: $e');
      }
    }
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    for (var i = 0; i < _daysAhead; i++) {
      await _plugin.cancel(id: _baseId + i);
    }
  }
}
