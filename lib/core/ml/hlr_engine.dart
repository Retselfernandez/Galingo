import 'dart:math' as math;

/// Representa un evento individual de repaso de un ítem léxico para el modelo HLR.
class HlrEvent {
  final String wordId;
  final double d; // Dificultad léxica del ítem (0.0 a 1.0)
  final int s;    // Número de aciertos acumulados antes del repaso actual
  final int f;    // Número de fallos acumulados antes del repaso actual
  final double t; // Tiempo transcurrido en días desde el último repaso
  final double p; // Resultado del repaso actual (1.0 = acierto, 0.0 = fallo)

  const HlrEvent({
    required this.wordId,
    required this.d,
    required this.s,
    required this.f,
    required this.t,
    required this.p,
  });

  Map<String, dynamic> toJson() => {
        'wordId': wordId,
        'd': d,
        's': s,
        'f': f,
        't': t,
        'p': p,
      };

  factory HlrEvent.fromJson(Map<String, dynamic> json) => HlrEvent(
        wordId: json['wordId'] as String,
        d: (json['d'] as num).toDouble(),
        s: json['s'] as int,
        f: json['f'] as int,
        t: (json['t'] as num).toDouble(),
        p: (json['p'] as num).toDouble(),
      );
}

/// Motor de aprendizaje basado en la regresión de vida media (Half-Life Regression)
/// y optimizador de descenso de gradiente para la personalización on-device.
class HlrEngine {
  HlrEngine._();

  // Constantes matemáticas
  static final double _ln2 = math.log(2);
  static final double _ln2Sq = _ln2 * _ln2;

  // Parámetros por defecto entrenados offline
  // bias (sesgo), aciertos (s), fallos (f), dificultad léxica (d)
  static const List<double> defaultTheta = [0.5, 0.35, -0.45, -0.25];

  /// Calcula la vida media estimada (en días) para un ítem léxico.
  /// formula: ĥ = 2^(θ_0 + θ_1 * sqrt(1+s) + θ_2 * sqrt(1+f) + θ_3 * d)
  static double estimateHalfLife({
    required List<double> theta,
    required int s,
    required int f,
    required double d,
  }) {
    final sTerm = math.sqrt(1.0 + s);
    final fTerm = math.sqrt(1.0 + f);
    final power = theta[0] + (theta[1] * sTerm) + (theta[2] * fTerm) + (theta[3] * d);
    // Acotar la potencia para evitar desbordamiento numérico
    final cleanPower = power.clamp(-10.0, 15.0);
    return math.pow(2.0, cleanPower).toDouble();
  }

  /// Calcula la probabilidad estimada de recuerdo del ítem.
  /// formula: p̂ = 2^(-t / ĥ)
  static double estimateRecallProbability({
    required double halfLife,
    required double t,
  }) {
    if (halfLife <= 0.001) return 0.0;
    final exponent = -t / halfLife;
    final cleanExponent = exponent.clamp(-20.0, 0.0);
    return math.pow(2.0, cleanExponent).toDouble();
  }

  /// Ejecuta el entrenamiento incremental de los pesos Theta locales utilizando
  /// descenso de gradiente sobre un lote de eventos de estudio con Gradient Clipping.
  ///
  /// Minimiza: L(Θ) = Σ [ (p - p̂)² + α * (h - ĥ)² ] + λ * ‖Θ‖²
  static List<double> trainLocalTheta({
    required List<double> currentTheta,
    required List<HlrEvent> events,
    double alpha = 0.05,     // Peso del error de vida media reducido para estabilidad
    double lambda = 0.01,     // Coeficiente de regularización L2
    double learningRate = 0.005, // Learning rate más conservador para evitar oscilaciones
    int epochs = 20,
  }) {
    if (events.isEmpty) return List.from(currentTheta);

    List<double> theta = List.from(currentTheta);

    for (int epoch = 0; epoch < epochs; epoch++) {
      List<double> gradients = List.filled(theta.length, 0.0);

      for (final event in events) {
        final double d = event.d;
        final double sTerm = math.sqrt(1.0 + event.s);
        final double fTerm = math.sqrt(1.0 + event.f);
        final double t = event.t;
        final double p = event.p;

        final double hHat = estimateHalfLife(theta: theta, s: event.s, f: event.f, d: d);
        final double pHat = estimateRecallProbability(halfLife: hHat, t: t);

        final double pObs = p == 1.0 ? 0.95 : 0.05;
        final double hObs = -t / (math.log(pObs) / _ln2);
        final double cleanHObs = hObs.clamp(0.1, 10.0); // Acotamos a un rango más estrecho para evitar derivadas gigantes

        final List<double> x = [1.0, sTerm, fTerm, d];

        final double dpCommon = pHat * _ln2Sq * (t / (hHat + 0.001));
        final double dhCommon = hHat * _ln2;

        for (int j = 0; j < theta.length; j++) {
          final double dpDThetaJ = dpCommon * x[j];
          final double dhDThetaJ = dhCommon * x[j];

          final double gradP = -2.0 * (p - pHat) * dpDThetaJ;
          final double gradH = -2.0 * alpha * (cleanHObs - hHat) * dhDThetaJ;

          // Acotar individualmente el gradiente por muestra para robustez
          final double sampleGrad = (gradP + gradH).clamp(-5.0, 5.0);
          gradients[j] += sampleGrad;
        }
      }

      // 4. Actualizar pesos Theta añadiendo regularización L2 y Gradient Clipping general
      for (int j = 0; j < theta.length; j++) {
        final double rawGrad = gradients[j] / events.length;
        final double clippedGrad = rawGrad.clamp(-1.5, 1.5);
        final double reg = lambda * theta[j];
        
        theta[j] -= learningRate * (clippedGrad + reg);
        // Opcional: Acotar el peso Theta final para evitar valores disparatados
        theta[j] = theta[j].clamp(-5.0, 5.0);
      }
    }

    return theta;
  }
}
