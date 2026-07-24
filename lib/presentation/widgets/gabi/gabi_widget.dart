import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../../../data/models/settings_model.dart';

/// Estados posibles de la mascota Gabi
enum GabiState {
  happy,    // Respuesta correcta / bienvenida
  thinking, // Respuesta incorrecta / duda
  pointing, // Guiando al siguiente paso
  sleeping, // Fin de sesión
}

/// Widget de la mascota Gabi con animación de vuelo completa
class GabiWidget extends ConsumerStatefulWidget {
  final GabiState state;
  final double size;
  final String? message;
  final bool showMessage;
  final bool animate;

  const GabiWidget({
    super.key,
    this.state = GabiState.happy,
    this.size = 120,
    this.message,
    this.showMessage = false,
    this.animate = true,
  });

  @override
  ConsumerState<GabiWidget> createState() => _GabiWidgetState();
}

class _GabiWidgetState extends ConsumerState<GabiWidget>
    with TickerProviderStateMixin {

  // ── Controladores de animación ───────────────────────────────────────────

  /// Movimiento vertical suave (ascenso/descenso)
  late final AnimationController _bobController;

  /// Deriva horizontal lenta (como si planeara con la brisa)
  late final AnimationController _driftController;

  /// Aleteo de las alas (ciclo rápido)
  late final AnimationController _flapController;

  /// Inclinación / banking al moverse
  late final AnimationController _tiltController;

  // Animaciones derivadas
  late final Animation<double> _bobAnim;
  late final Animation<double> _driftAnim;
  late final Animation<double> _flapAnim;   // escala vertical (alas)
  late final Animation<double> _tiltAnim;   // rotación Z

  @override
  void initState() {
    super.initState();

    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    final shouldAnimate = widget.animate && !isTest;

    if (!shouldAnimate) return;

    // 1. BOB — sube y baja (3.2 s, asimétrico)
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _bobAnim = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );

    // 2. DRIFT — deriva horizontal (4.5 s, desfasado)
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);

    _driftAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _driftController, curve: Curves.easeInOut),
    );

    // 3. FLAP — aleteo: squish vertical rápido (0.55 s)
    _flapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);

    _flapAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _flapController, curve: Curves.easeInOut),
    );

    // 4. TILT — leve inclinación ligada a la deriva (mismo período)
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);

    _tiltAnim = Tween<double>(begin: -0.07, end: 0.07).animate(
      CurvedAnimation(parent: _tiltController, curve: Curves.easeInOut),
    );

    // Desfasar ligeramente bob y drift para que no sean sincronizados
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _driftController.forward(from: 0.3);
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _tiltController.forward(from: 0.3);
    });
    
    _isAnimationInitialized = true;
  }

  bool _isAnimationInitialized = false;

  @override
  void dispose() {
    if (_isAnimationInitialized) {
      _bobController.dispose();
      _driftController.dispose();
      _flapController.dispose();
      _tiltController.dispose();
    }
    super.dispose();
  }

  String get _stateLabel {
    return switch (widget.state) {
      GabiState.happy    => '😄',
      GabiState.thinking => '🤔',
      GabiState.pointing => '👉',
      GabiState.sleeping => '😴',
    };
  }

  String _getDefaultMessage(AppLanguage language) {
    return switch (language) {
      AppLanguage.es => switch (widget.state) {
          GabiState.happy    => '¡Muy bien! ¡Sigue así! 🌟',
          GabiState.thinking => 'Hmm... ¡inténtalo de nuevo!',
          GabiState.pointing => '¡Tu próxima lección te espera!',
          GabiState.sleeping => '¡Hasta mañana! Descansa bien. 💤',
        },
      _ => switch (widget.state) { // Fallback en inglés y otros
          GabiState.happy    => 'Great job! Keep it up! 🌟',
          GabiState.thinking => 'Hmm... try again!',
          GabiState.pointing => 'Your next lesson is waiting!',
          GabiState.sleeping => 'See you tomorrow! Rest well. 💤',
        },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedGabi(),
        if (widget.showMessage) ...[
          const SizedBox(height: 12),
          _buildSpeechBubble(),
        ],
      ],
    );
  }

  Widget _buildAnimatedGabi() {
    if (!_isAnimationInitialized) {
      return _buildGabiImage(flapScale: 1.0);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _bobController,
        _driftController,
        _flapController,
        _tiltController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          // Bob vertical + deriva horizontal
          offset: Offset(_driftAnim.value, _bobAnim.value),
          child: Transform.rotate(
            // Inclinación natural al virar
            angle: _tiltAnim.value,
            child: Transform.scale(
              // Aleteo: squish vertical simula alas arriba/abajo
              scaleX: 1.0 + (1.0 - _flapAnim.value) * 0.06,
              scaleY: _flapAnim.value,
              child: child,
            ),
          ),
        );
      },
      child: _buildGabiImage(flapScale: 1.0),
    );
  }

  Widget _buildGabiImage({required double flapScale}) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 1.1,
      child: Image.asset(
        AppConstants.gabiHappyImage,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => _buildFallbackGabi(),
      ),
    )
        .animate()
        .scaleXY(
          begin: 0.7,
          end: 1.0,
          curve: Curves.elasticOut,
          duration: 700.ms,
        );
  }

  Widget _buildFallbackGabi() {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Text(
          _stateLabel,
          style: TextStyle(fontSize: widget.size * 0.55),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    final language = ref.watch(settingsProvider.select((s) => s.language));
    final message = widget.message ?? _getDefaultMessage(language);
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut, duration: 400.ms);
  }
}
