import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unit_model.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/home/home_models.dart';

/// Pestana "Progreso": XP, racha, paradas, leccións e avance por parada.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressNotifierProvider);
    final unitsAsync = ref.watch(unitsWithStatusProvider);
    final due = ref.watch(dueReviewProvider);

    return Scaffold(
      backgroundColor: AppTheme.skyBlue,
      body: Column(
        children: [
          _Header(name: progressAsync.valueOrNull?.userName),
          Expanded(
            child: progressAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (progress) => unitsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro: $e')),
                data: (units) {
                  final completed = progress.completedLessonIds;
                  var doneUnits = 0;
                  var totalLessons = 0;
                  var doneLessons = 0;
                  for (final s in units) {
                    if (s.isCompleted) doneUnits++;
                    totalLessons += s.unit.lessons.length;
                    doneLessons += s.unit.lessons
                        .where((l) => completed.contains(l.id))
                        .length;
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              emoji: '⭐',
                              value: '${progress.totalXp}',
                              label: 'XP total',
                              color: AppTheme.accentGold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              emoji: '🔥',
                              value: '${progress.streakDays}',
                              label: 'Racha (días)',
                              color: AppTheme.accentCoral,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              emoji: '🚩',
                              value: '$doneUnits/${units.length}',
                              label: 'Paradas',
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              emoji: '📖',
                              value: '$doneLessons/$totalLessons',
                              label: 'Leccións',
                              color: AppTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                      if (due > 0) ...[
                        const SizedBox(height: 16),
                        _ReviewCard(due: due),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Por parada',
                        style: GoogleFonts.nunito(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'O teu avance en cada parada do Camiño.',
                        style: GoogleFonts.nunito(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < units.length; i++)
                        _UnitProgress(
                          unit: units[i].unit,
                          index: i,
                          completedLessonIds: completed,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? name;

  const _Header({this.name});

  @override
  Widget build(BuildContext context) {
    final greeting = (name == null || name!.trim().isEmpty)
        ? 'O teu progreso'
        : 'Ola, ${name!.trim()}!';

    return Container(
      width: double.infinity,
      color: AppTheme.deepBlue,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights_rounded,
                    color: Colors.white, size: 26),
                const SizedBox(width: 10),
                Text(
                  'Progreso',
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              greeting,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepBlue.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 17)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int due;

  const _ReviewCard({required this.due});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push(AppRoutes.review),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryBlue.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.replay_rounded,
                    color: AppTheme.primaryBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Repaso pendente',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '$due ${due == 1 ? 'palabra' : 'palabras'} para repasar hoxe',
                      style: GoogleFonts.nunito(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.primaryBlue),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitProgress extends StatelessWidget {
  final UnitModel unit;
  final int index;
  final List<String> completedLessonIds;

  const _UnitProgress({
    required this.unit,
    required this.index,
    required this.completedLessonIds,
  });

  @override
  Widget build(BuildContext context) {
    final total = unit.lessons.length;
    final done =
        unit.lessons.where((l) => completedLessonIds.contains(l.id)).length;
    final ratio = total == 0 ? 0.0 : done / total;
    final completed = total > 0 && done == total;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepBlue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(unitEmoji(index), style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  unit.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$done/$total',
                style: GoogleFonts.nunito(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: completed
                      ? AppTheme.successGreen
                      : AppTheme.textSecondary,
                ),
              ),
              if (completed) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: AppTheme.successGreen),
              ],
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: const Color(0xFFEDF3FA),
              valueColor: AlwaysStoppedAnimation(
                completed ? AppTheme.successGreen : AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
