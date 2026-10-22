import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/galingo_colors.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/models/user_progress_model.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/home/home_models.dart';

/// Pestana "Leccións": todas as paradas do Camiño coas súas leccións.
class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressNotifierProvider);
    final unitsAsync = ref.watch(unitsWithStatusProvider);

    return Scaffold(
      backgroundColor: context.pageBg,
      body: Column(
        children: [
          _Header(
            progress: progressAsync.valueOrNull,
            units: unitsAsync.valueOrNull,
          ),
          Expanded(
            child: unitsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (units) => progressAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro: $e')),
                data: (progress) => ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  itemCount: units.length,
                  itemBuilder: (context, i) => _UnitCard(
                    data: units[i],
                    index: i,
                    completedLessonIds: progress.completedLessonIds,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final UserProgressModel? progress;
  final List<UnitWithStatus>? units;

  const _Header({this.progress, this.units});

  @override
  Widget build(BuildContext context) {
    var doneUnits = 0;
    var totalUnits = 0;
    var doneLessons = 0;
    var totalLessons = 0;

    if (units != null) {
      totalUnits = units!.length;
      final completed = progress?.completedLessonIds ?? const <String>[];
      for (final s in units!) {
        if (s.isCompleted) doneUnits++;
        totalLessons += s.unit.lessons.length;
        doneLessons +=
            s.unit.lessons.where((l) => completed.contains(l.id)).length;
      }
    }

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
                const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 26),
                const SizedBox(width: 10),
                Text(
                  'Leccións',
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
              '$doneUnits de $totalUnits paradas · $doneLessons de $totalLessons leccións',
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

class _UnitCard extends StatelessWidget {
  final UnitWithStatus data;
  final int index;
  final List<String> completedLessonIds;

  const _UnitCard({
    required this.data,
    required this.index,
    required this.completedLessonIds,
  });

  @override
  Widget build(BuildContext context) {
    final unit = data.unit;
    final locked = !data.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: context.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: locked ? context.softBg : context.pageBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    unitEmoji(index),
                    style: TextStyle(
                      fontSize: 22,
                      color: locked ? Colors.grey : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.title,
                        style: GoogleFonts.nunito(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${unit.lessons.length} leccións · ${HomeUnitData.xpOf(unit)} XP',
                        style: GoogleFonts.nunito(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  completed: data.isCompleted,
                  locked: locked,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.softBg),
          for (final lesson in unit.lessons)
            _LessonRow(
              lesson: lesson,
              done: completedLessonIds.contains(lesson.id),
              locked: locked,
              onTap: locked
                  ? null
                  : () => context.push(AppRoutes.lessonPath(lesson.id)),
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool completed;
  final bool locked;

  const _StatusChip({required this.completed, required this.locked});

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? AppTheme.successGreen
        : locked
            ? const Color(0xFF9AA9BC)
            : context.accent;
    final label = completed
        ? 'Completada'
        : locked
            ? 'Bloqueada'
            : 'En curso';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final LessonModel lesson;
  final bool done;
  final bool locked;
  final VoidCallback? onTap;

  const _LessonRow({
    required this.lesson,
    required this.done,
    required this.locked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool available = !done && !locked;
    final Color bg = done
        ? AppTheme.successGreen
        : available
            ? AppTheme.primaryBlue.withValues(alpha: 0.12)
            : context.softBg;
    final Color fg = done
        ? Colors.white
        : available
            ? context.accent
            : const Color(0xFF9AA9BC);
    final IconData iconData = done
        ? Icons.check_rounded
        : available
            ? Icons.play_arrow_rounded
            : Icons.lock_rounded;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(iconData, size: 15, color: fg),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lesson.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 14.5,
                  fontWeight: done ? FontWeight.w700 : FontWeight.w600,
                  color: locked ? const Color(0xFF96A5B8) : context.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${lesson.estimatedMinutes} min',
              style: GoogleFonts.nunito(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
