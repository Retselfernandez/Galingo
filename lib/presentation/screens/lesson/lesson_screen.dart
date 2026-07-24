import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/ml/hlr_engine.dart';
import '../../../core/services/audio_service.dart';
import '../../../data/datasources/mock/content_service.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/lesson_model.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/gabi/gabi_widget.dart';

/// LessonScreen — pantalla de lección con ejercicios progresivos
class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  LessonModel? _lesson;
  String _unitLevel = 'A1'; // L4: nivel real de la unidad padre (evita startsWith mágico)
  int _currentExerciseIndex = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  int _xpEarned = 0;
  int _lives = 5;
  int _consecutiveFailures = 0;
  bool _isLoading = true;
  List<String> _shuffledOptions = [];

  final TextEditingController _translationController = TextEditingController();
  // Registra el resultado del primer intento de cada ejercicio: { exerciseId: isCorrect }
  final Map<String, bool> _firstAttemptResults = {};
  
  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }

  void _prepareCurrentExerciseOptions() {
    if (_lesson == null) return;
    final exercise = _lesson!.exercises[_currentExerciseIndex];
    _shuffledOptions = List<String>.from(exercise.options)..shuffle();
  }

  Future<void> _loadLesson() async {
    final lesson = await ContentService.instance.findLessonById(widget.lessonId);
    // L4: determinar el nivel real de la unidad que contiene esta lección
    final parentUnit = await ContentService.instance.findUnitForLesson(widget.lessonId);
    if (lesson != null) {
      final language = ref.read(settingsProvider).language;
      final localizedExercises = lesson.exercises.map<ExerciseModel>((e) {
        return (e as ExerciseModel).localize(language.name);
      }).toList();

      setState(() {
        _lesson = lesson.copyWith(exercises: localizedExercises);
        _unitLevel = parentUnit?.level ?? 'A1'; // L4: nivel real
        _isLoading = false;
        _prepareCurrentExerciseOptions();
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool get _isLastExercise =>
      _lesson != null &&
      _currentExerciseIndex >= _lesson!.exercises.length - 1;

  bool _isFuzzyEqual(String userText, String targetText) {
    String clean(String str) {
      return str
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'[áàâãä]'), 'a')
          .replaceAll(RegExp(r'[éèêë]'), 'e')
          .replaceAll(RegExp(r'[íìîï]'), 'i')
          .replaceAll(RegExp(r'[óòôõö]'), 'o')
          .replaceAll(RegExp(r'[úùûü]'), 'u')
          .replaceAll(RegExp(r'[ñ]'), 'n')
          .replaceAll(RegExp(r'[ç]'), 'c')
          .replaceAll(RegExp(r'[.,;:!?¡¿"()]'), '');
    }
    return clean(userText) == clean(targetText);
  }

  int _calculateVariableXp(dynamic exercise) {
    double difficulty = 0.2; // Dificultad base A1
    
    // Aumentar dificultad por tipo de ejercicio
    if (exercise.type == ExerciseType.translation) {
      difficulty += 0.4;
    } else if (exercise.type == ExerciseType.matching) {
      difficulty += 0.2;
    } else if (exercise.type == ExerciseType.fillBlank) {
      difficulty += 0.1;
    }

    // L4: usar _unitLevel en lugar de startsWith('a2') para determinar dificultad
    final isA2orAbove = _unitLevel == 'A2' || _unitLevel == 'B1' || _unitLevel == 'B2';
    if (isA2orAbove) {
      difficulty += 0.3;
    }

    final double cleanDifficulty = difficulty.clamp(0.1, 1.0);
    return (exercise.xpReward * (1.0 + cleanDifficulty)).round();
  }

  double _getExerciseDifficulty(dynamic exercise) {
    double d = 0.2;
    if (exercise.type == ExerciseType.translation) d += 0.4;
    if (exercise.type == ExerciseType.matching) d += 0.2;
    if (exercise.type == ExerciseType.fillBlank) d += 0.1;
    // L4: usar _unitLevel en lugar de startsWith('a2')
    if (_unitLevel == 'A2' || _unitLevel == 'B1' || _unitLevel == 'B2') d += 0.3;
    return d.clamp(0.1, 1.0);
  }

  void _checkAnswer(String answer) {
    if (_isAnswered) return;
    final exercise = _lesson!.exercises[_currentExerciseIndex];
    
    final bool correct = exercise.type == ExerciseType.translation
        ? _isFuzzyEqual(answer, exercise.correctAnswer)
        : answer == exercise.correctAnswer;

    // Registrar resultado del primer intento
    if (!_firstAttemptResults.containsKey(exercise.id)) {
      _firstAttemptResults[exercise.id] = correct;
    }

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      _isCorrect = correct;
      if (correct) {
        _xpEarned += _calculateVariableXp(exercise);
        _consecutiveFailures = 0;
        HapticFeedback.lightImpact();
        AudioService.instance.playSuccess();
      } else {
        _lives--;
        _consecutiveFailures++;
        HapticFeedback.vibrate();
        AudioService.instance.playError();
      }
    });
  }

  Future<void> _nextExercise() async {
    if (_lives <= 0) {
      _showNoLivesDialog();
      return;
    }
    if (_isLastExercise) {
      await _completeLesson();
      return;
    }
    _translationController.clear();
    setState(() {
      _currentExerciseIndex++;
      _selectedAnswer = null;
      _isAnswered = false;
      _isCorrect = false;
      _consecutiveFailures = 0;
      _prepareCurrentExerciseOptions();
    });
  }

  Future<void> _completeLesson() async {
    final lesson = _lesson!;
    
    // Obtener el nivel de progreso del usuario de forma dinámica
    final progress = ref.read(progressNotifierProvider).valueOrNull;
    final level = progress?.currentLevel ?? 'A1';
    
    // Obtener todas las lecciones del nivel actual
    final units = await ContentService.instance.loadUnitsForLevel(level);
    final parentUnit = units.firstWhere(
      (u) => u.lessons.any((l) => l.id == lesson.id),
      orElse: () => units.first,
    );

    // ─── Generación de Eventos HLR de la Sesión ───
    final List<HlrEvent> sessionEvents = [];
    if (progress != null) {
      for (final exercise in lesson.exercises) {
        final wasPracticed = _firstAttemptResults.containsKey(exercise.id);
        if (!wasPracticed) continue;

        // Se usa correctAnswer como ID único de la palabra/concepto léxico
        final wordId = exercise.correctAnswer;
        final stats = progress.wordRepetitionHistory[wordId];
        
        final s = stats != null ? (stats['s'] as int? ?? 0) : 0;
        final f = stats != null ? (stats['f'] as int? ?? 0) : 0;

        double t = 1.0; // 1 día por defecto
        if (stats != null && stats['lastPracticed'] != null) {
          final lastPracticed = DateTime.parse(stats['lastPracticed'] as String);
          final diff = DateTime.now().difference(lastPracticed).inMinutes;
          // Pasar a fracción de días (mínimo 0.001 días)
          t = (diff / 1440.0).clamp(0.001, 30.0);
        }

        final event = HlrEvent(
          wordId: wordId,
          d: _getExerciseDifficulty(exercise),
          s: s,
          f: f,
          t: t,
          p: _firstAttemptResults[exercise.id] == true ? 1.0 : 0.0,
        );
        sessionEvents.add(event);
      }
    }

    await ref.read(progressNotifierProvider.notifier).completeLesson(
      lessonId: lesson.id,
      unitId: parentUnit.id,
      xpEarned: _xpEarned,
      allLessonIdsInUnit: parentUnit.lessons.map((l) => l.id).toList(),
      sessionEvents: sessionEvents,
    );

    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _showNoLivesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('💔', style: TextStyle(fontSize: 28)),
            SizedBox(width: 10),
            Text(
              'Sen vidas!',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Oh non! Cometaches demasiados erros e quedaches sen corazóns para esta lección.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'Gabi di: "Non te preocupes! Recomenza a lección para tentalo de novo e seguir aprendendo."',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.home);
            },
            child: const Text('Volver ao Camiño'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    AudioService.instance.playLevelUp();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LessonCompletedDialog(
        xpEarned: _xpEarned,
        lessonTitle: _lesson?.title ?? '',
        onContinue: () {
          Navigator.of(context).pop();
          context.go(AppRoutes.home);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_lesson == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('❌', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Lección non atopada: ${widget.lessonId}'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Volver ao inicio'),
              ),
            ],
          ),
        ),
      );
    }

    final lesson = _lesson!;
    final exercise = lesson.exercises[_currentExerciseIndex];
    final totalExercises = lesson.exercises.length;
    final progress = (_currentExerciseIndex + 1) / totalExercises;

    return Scaffold(
      body: Column(
        children: [
          // ── Header con progress bar ──────────────────────────────────
          _buildHeader(context, lesson, progress),

          // ── Contenido del ejercicio ──────────────────────────────────
          Expanded(
            child: Center(
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gabi feedback
                      if (_isAnswered) ...[
                        GabiWidget(
                          state: _isCorrect ? GabiState.happy : GabiState.thinking,
                          size: 80,
                          showMessage: true,
                          message: _isCorrect
                              ? '¡Excelente! +${exercise.xpReward} XP 🌟'
                              : _consecutiveFailures >= 2
                                  ? 'Non te preocupes polo erro! Gabi di: ¡Cada fallo achégate máis a dominar o galego! 💪\nA resposta correcta é: ${exercise.correctAnswer}'
                                  : 'Case! A resposta correcta é: ${exercise.correctAnswer}',
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Pregunta
                      _buildExerciseCard(context, exercise),

                      const SizedBox(height: 16),

                      // Feedback de respuesta correcta/incorrecta
                      if (_isAnswered) ...[
                        _buildAnswerFeedback(context, exercise.explanation),
                        const SizedBox(height: 16),
                      ],

                      // Botón siguiente / confirmar
                      _buildActionButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LessonModel lesson, double progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              color: AppTheme.textSecondary,
              onPressed: () => context.go(AppRoutes.home),
              tooltip: 'Saír da lección',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      color: AppTheme.primaryBlue,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // XP actual — Se oculta en pantallas muy estrechas
            if (MediaQuery.of(context).size.width > 480) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '$_xpEarned XP',
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('❤️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '$_lives',
                    style: const TextStyle(
                      color: AppTheme.errorRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_currentExerciseIndex + 1}/${lesson.exercises.length}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionText(BuildContext context, dynamic exercise) {
    final text = exercise.question;
    if (exercise.type == ExerciseType.fillBlank && text.contains('_____')) {
      final answerToShow = _selectedAnswer ?? '_____';
      final parts = text.split('_____');
      return RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
          children: [
            TextSpan(text: parts[0]),
            TextSpan(
              text: ' $answerToShow ',
              style: TextStyle(
                color: _isAnswered
                    ? (_isCorrect ? AppTheme.successGreen : AppTheme.errorRed)
                    : AppTheme.primaryBlue,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      );
    }
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, dynamic exercise) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de ejercicio
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _exerciseTypeLabel(exercise.type),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 20),

            // Pregunta
            _buildQuestionText(context, exercise),
            const SizedBox(height: 24),

            // Opciones (multiple choice / fill blank)
            if (_shuffledOptions.isNotEmpty && exercise.type != ExerciseType.matching)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                itemCount: _shuffledOptions.length,
                itemBuilder: (context, i) =>
                    _buildOptionButton(context, _shuffledOptions[i], exercise.correctAnswer),
              ),

            // Translation exercise (caja de texto)
            if (exercise.type == ExerciseType.translation)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _translationController,
                      enabled: !_isAnswered,
                      maxLines: 3,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Escribe a túa tradución aquí...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                        ),
                        filled: true,
                        fillColor: _isAnswered
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100)
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white),
                      ),
                      onChanged: (text) {
                        // Forzar reconstrucción de botón de validar
                        setState(() {});
                      },
                    ),
                    if (_isAnswered && !_isCorrect) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.successGreenLight.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tradución correcta:',
                              style: TextStyle(
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercise.correctAnswer,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Matching exercise
            if (exercise.type == ExerciseType.matching)
              SizedBox(
                height: 280,
                child: _buildMatchingWidget(context, exercise),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut, duration: 300.ms);
  }

  Widget _buildOptionButton(
    BuildContext context,
    String option,
    String correctAnswer,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor = isDark ? Colors.white.withValues(alpha: 0.15) : AppTheme.primaryBlue.withOpacity(0.2);
    Color bgColor = isDark ? AppTheme.surfaceDark2 : AppTheme.surfaceBlue;
    Color textColor = isDark ? Colors.white : AppTheme.textPrimary;

    if (_isAnswered && _selectedAnswer == option) {
      if (_isCorrect) {
        borderColor = AppTheme.successGreen;
        bgColor = AppTheme.successGreenLight;
        textColor = AppTheme.successGreen;
      } else {
        borderColor = AppTheme.errorRed;
        bgColor = AppTheme.errorRedLight;
        textColor = AppTheme.errorRed;
      }
    } else if (_isAnswered && option == correctAnswer) {
      borderColor = AppTheme.successGreen;
      bgColor = AppTheme.successGreenLight;
      textColor = AppTheme.successGreen;
    }

    return GestureDetector(
      onTap: () => _checkAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: Text(
            option,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchingWidget(BuildContext context, dynamic exercise) {
    // Convertir a lista tipada
    final rawPairs = exercise.matchingPairs as List;
    final List<Map<String, String>> pairs = rawPairs.map((e) {
      final m = e as Map;
      return {
        'left': m['left']?.toString() ?? '',
        'right': m['right']?.toString() ?? '',
      };
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InteractiveMatchingWidget(
            matchingPairs: pairs,
            onCompleted: () => _checkAnswer('matched'),
            isAnswered: _isAnswered,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerFeedback(BuildContext context, String? explanation) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? AppTheme.successGreenLight : AppTheme.errorRedLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCorrect
              ? AppTheme.successGreen.withOpacity(0.3)
              : AppTheme.errorRed.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isCorrect
                  ? AppTheme.successGreen.withOpacity(0.2)
                  : AppTheme.errorRed.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: _isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isCorrect ? '¡Moi ben!' : 'Incorrecto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (explanation != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    explanation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _isCorrect
                              ? AppTheme.successGreen.withOpacity(0.8)
                              : AppTheme.errorRed.withOpacity(0.8),
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final exercise = _lesson?.exercises[_currentExerciseIndex];

    if (!_isAnswered) {
      if (exercise != null && exercise.type == ExerciseType.translation) {
        final textInput = _translationController.text.trim();
        final hasInput = textInput.isNotEmpty;
        
        return SizedBox(
          width: double.infinity,
          child: Semantics(
            button: true,
            label: 'Verificar a túa tradución introducida',
            child: FilledButton(
              onPressed: hasInput ? () => _checkAnswer(textInput) : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Verificar tradución',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: Semantics(
        button: true,
        label: _isLastExercise ? 'Rematar lección e gardar progreso' : 'Avanzar ao seguinte exercicio',
        child: FilledButton(
          onPressed: _nextExercise,
          style: FilledButton.styleFrom(
            backgroundColor:
                _isCorrect ? AppTheme.successGreen : AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            _isLastExercise ? 'Rematar lección 🎉' : 'Seguir →',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut, duration: 300.ms);
  }

  String _exerciseTypeLabel(ExerciseType type) {
    return switch (type) {
      ExerciseType.multipleChoice => '🔘 Elección múltiple',
      ExerciseType.fillBlank => '✏️ Completar',
      ExerciseType.matching => '🔗 Emparellar',
      ExerciseType.audio => '🔊 Audio',
      ExerciseType.translation => '🌐 Tradución',
    };
  }
}

// ─── Diálogo de lección completada ──────────────────────────────────────────

class _LessonCompletedDialog extends StatelessWidget {
  final int xpEarned;
  final String lessonTitle;
  final VoidCallback onContinue;

  const _LessonCompletedDialog({
    required this.xpEarned,
    required this.lessonTitle,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GabiWidget(
              state: GabiState.happy,
              size: 110,
              showMessage: true,
              message: '¡Parabéns! Completaches a lección! 🎊',
            ),
            const SizedBox(height: 24),
            Text(
              '¡Lección Completada!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              lessonTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppTheme.oceanGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    '+$xpEarned XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continuar o Camiño →',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .scaleXY(begin: 0.8, end: 1.0, curve: Curves.elasticOut, duration: 600.ms)
        .fadeIn(duration: 300.ms);
  }
}

// ─── Widget de Emparejamiento Interactivo Premium ─────────────────────────────

class InteractiveMatchingWidget extends StatefulWidget {
  final List<Map<String, String>> matchingPairs;
  final VoidCallback onCompleted;
  final bool isAnswered;

  const InteractiveMatchingWidget({
    super.key,
    required this.matchingPairs,
    required this.onCompleted,
    required this.isAnswered,
  });

  @override
  State<InteractiveMatchingWidget> createState() => _InteractiveMatchingWidgetState();
}

class _InteractiveMatchingWidgetState extends State<InteractiveMatchingWidget> {
  late List<String> _leftItems;
  late List<String> _rightItems;
  
  String? _selectedLeft;
  String? _selectedRight;
  
  final Map<String, String> _matches = {};
  
  String? _errorLeft;
  String? _errorRight;

  @override
  void initState() {
    super.initState();
    _initializePairs();
  }

  @override
  void didUpdateWidget(covariant InteractiveMatchingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matchingPairs != widget.matchingPairs) {
      _initializePairs();
    }
  }

  void _initializePairs() {
    _matches.clear();
    _selectedLeft = null;
    _selectedRight = null;
    _errorLeft = null;
    _errorRight = null;

    _leftItems = widget.matchingPairs.map((p) => p['left']!).toList();
    _rightItems = widget.matchingPairs.map((p) => p['right']!).toList();
    
    // Barajar de forma aleatoria
    _leftItems.shuffle();
    _rightItems.shuffle();
  }

  void _onLeftSelected(String item) {
    if (widget.isAnswered || _matches.containsKey(item)) return;
    
    setState(() {
      _errorLeft = null;
      _errorRight = null;
      
      if (_selectedLeft == item) {
        _selectedLeft = null;
      } else {
        _selectedLeft = item;
        _checkMatch();
      }
    });
  }

  void _onRightSelected(String item) {
    if (widget.isAnswered || _matches.containsValue(item)) return;
    
    setState(() {
      _errorLeft = null;
      _errorRight = null;
      
      if (_selectedRight == item) {
        _selectedRight = null;
      } else {
        _selectedRight = item;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    if (_selectedLeft == null || _selectedRight == null) return;
   
    final isValid = widget.matchingPairs.any(
      (p) => p['left'] == _selectedLeft && p['right'] == _selectedRight,
    );
   
    if (isValid) {
      AudioService.instance.play(SoundEffect.success);
      HapticFeedback.lightImpact();
      setState(() {
        _matches[_selectedLeft!] = _selectedRight!;
        _selectedLeft = null;
        _selectedRight = null;
      });
      if (_matches.length == widget.matchingPairs.length) {
        widget.onCompleted();
      }
    } else {
      AudioService.instance.play(SoundEffect.error);
      HapticFeedback.vibrate();
      setState(() {
        _errorLeft = _selectedLeft;
        _errorRight = _selectedRight;
        _selectedLeft = null;
        _selectedRight = null;
      });
   
      final errL = _errorLeft;
      final errR = _errorRight;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _errorLeft == errL && _errorRight == errR) {
          setState(() {
            _errorLeft = null;
            _errorRight = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Columna Izquierda (Gallego)
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _leftItems.map((item) {
              final isMatched = _matches.containsKey(item);
              final isSelected = _selectedLeft == item;
              final isError = _errorLeft == item;
              
              return _buildMatchingCard(
                text: item,
                isSelected: isSelected,
                isMatched: isMatched,
                isError: isError,
                onTap: () => _onLeftSelected(item),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 20),
        // Columna Derecha (Traducción)
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _rightItems.map((item) {
              final isMatched = _matches.containsValue(item);
              final isSelected = _selectedRight == item;
              final isError = _errorRight == item;
              
              return _buildMatchingCard(
                text: item,
                isSelected: isSelected,
                isMatched: isMatched,
                isError: isError,
                onTap: () => _onRightSelected(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingCard({
    required String text,
    required bool isSelected,
    required bool isMatched,
    required bool isError,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300;
    Color bgColor = isDark ? AppTheme.surfaceDark : Colors.white;
    Color textColor = isDark ? Colors.white : AppTheme.textPrimary;

    if (isMatched) {
      borderColor = AppTheme.successGreen.withOpacity(0.4);
      bgColor = AppTheme.successGreenLight.withOpacity(0.5);
      textColor = AppTheme.textSecondary.withOpacity(0.5);
    } else if (isError) {
      borderColor = AppTheme.errorRed;
      bgColor = AppTheme.errorRedLight;
      textColor = AppTheme.errorRed;
    } else if (isSelected) {
      borderColor = AppTheme.primaryBlue;
      bgColor = isDark ? AppTheme.surfaceDark2 : AppTheme.surfaceBlue;
      textColor = isDark ? AppTheme.primaryBlueLight : AppTheme.primaryBlue;
    }

    return GestureDetector(
      onTap: isMatched ? null : onTap,
      child: MouseRegion(
        cursor: isMatched ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: (isSelected || isError || isMatched) ? 2.5 : 1.5,
            ),
            boxShadow: [
              if (!isMatched)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    decoration: isMatched ? TextDecoration.lineThrough : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (isMatched) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.successGreen,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
