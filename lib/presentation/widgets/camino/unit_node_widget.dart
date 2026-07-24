import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/progress_provider.dart';

/// Nodo individual del Camiño — representa una Unidad
class UnitNodeWidget extends StatelessWidget {
  final UnitWithStatus unitStatus;
  final bool isCurrentUnit;
  final VoidCallback? onTap;
  final int index;

  const UnitNodeWidget({
    super.key,
    required this.unitStatus,
    required this.index,
    this.isCurrentUnit = false,
    this.onTap,
  });

  Color get _accentColor {
    try {
      final hex = unitStatus.unit.accentColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = unitStatus.unit;
    final isLocked = !unitStatus.isUnlocked;
    final isCompleted = unitStatus.isCompleted;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // ── Línea conectora izquierda ──────────────────────────────
            if (index > 0)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 28),
                child: Column(
                  children: [
                    Container(
                      width: 3,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isLocked
                            ? Colors.grey.shade300
                            : _accentColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Card de la unidad ──────────────────────────────────────
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.shade100
                      : (isCompleted
                          ? _accentColor.withValues(alpha: 0.08)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCurrentUnit
                        ? _accentColor
                        : (isLocked
                            ? Colors.grey.shade200
                            : _accentColor.withValues(alpha: 0.3)),
                    width: isCurrentUnit ? 2.5 : 1.5,
                  ),
                  boxShadow: isLocked
                      ? null
                      : [
                          BoxShadow(
                            color: _accentColor.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    // Icono de la unidad
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isLocked
                            ? Colors.grey.shade200
                            : _accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: isLocked
                            ? const Icon(
                                Icons.lock_rounded,
                                color: Colors.grey,
                                size: 24,
                              )
                            : Text(
                                unit.icon,
                                style: const TextStyle(fontSize: 28),
                              ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Info de la unidad
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  unit.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: isLocked
                                            ? Colors.grey
                                            : Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successGreenLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppTheme.successGreen,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Feita',
                                        style: TextStyle(
                                          color: AppTheme.successGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unit.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: isLocked
                                      ? Colors.grey.shade400
                                      : AppTheme.textSecondary,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Lecciones info
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 13,
                                color: isLocked
                                    ? Colors.grey
                                    : _accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${unit.lessons.length} leccións',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isLocked ? Colors.grey : _accentColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: isLocked
                                    ? Colors.grey
                                    : AppTheme.accentGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${unit.lessons.fold(0, (sum, l) => sum + l.xpReward)} XP',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isLocked
                                      ? Colors.grey
                                      : AppTheme.accentGold,
                                ),
                              ),
                              // L3: badge de tiempo estimado total de la unidad
                              const SizedBox(width: 12),
                              Icon(
                                Icons.timer_outlined,
                                size: 13,
                                color: isLocked
                                    ? Colors.grey
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${unit.lessons.fold(0, (sum, l) => sum + l.estimatedMinutes)} min',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isLocked
                                      ? Colors.grey
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Flecha o candado
                    if (!isLocked)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: _accentColor,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          .animate(delay: (index * 80).ms)
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.2, end: 0, curve: Curves.easeOut, duration: 400.ms),
    );
  }
}
