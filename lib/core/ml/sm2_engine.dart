/// Motor de repetición espaciada clásico basado en el algoritmo SM-2 (SuperMemo-2).
/// Utilizado para la comparativa y telemetría de rendimiento frente al modelo HLR.
class Sm2Engine {
  Sm2Engine._();

  /// Actualiza las variables de estado de SM-2 tras una sesión de repaso.
  /// 
  /// Recibe las repeticiones consecutivas correctas [repetitions], el factor
  /// de facilidad [easinessFactor], el intervalo de repaso actual en días [intervalDays]
  /// y el resultado del repaso [p] (1.0 = acierto, 0.0 = fallo).
  static Map<String, dynamic> updateSm2State({
    required int repetitions,
    required double easinessFactor,
    required int intervalDays,
    required double p,
  }) {
    // Mapear el resultado binario (0.0 o 1.0) al rango de calidad de SM-2 (0 a 5)
    // 1.0 acierto -> grado 4 (correcto con duda/hesitación)
    // 0.0 fallo -> grado 1 (incorrecto, se le recuerda la respuesta)
    final int q = p == 1.0 ? 4 : 1;

    int newRepetitions;
    int newInterval;
    double newEF;

    if (q >= 3) {
      if (repetitions == 0) {
        newInterval = 1;
      } else if (repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (intervalDays * easinessFactor).round();
      }
      newRepetitions = repetitions + 1;
    } else {
      newRepetitions = 0;
      newInterval = 1;
    }

    // Actualización del factor de facilidad (Easiness Factor)
    newEF = easinessFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (newEF < 1.3) {
      newEF = 1.3;
    }

    return {
      'repetitions': newRepetitions,
      'intervalDays': newInterval,
      'easinessFactor': newEF,
    };
  }
}
