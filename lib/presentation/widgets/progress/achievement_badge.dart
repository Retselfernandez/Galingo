import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/galingo_colors.dart';
import '../../../data/models/achievement.dart';

/// Insignia circular cun logro: amosa o estado e, ao premer, o detalle.
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${achievement.title}: ${achievement.description}',
      child: GestureDetector(
        onTap: () => _showDetail(context),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: unlocked ? 1.0 : 0.4,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked ? context.cardBg : context.softBg,
                border: Border.all(
                  color: unlocked ? Colors.amber.shade600 : Colors.grey.shade400,
                  width: unlocked ? 2.5 : 1.5,
                ),
                boxShadow: [
                  if (unlocked)
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                achievement.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(color: context.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: unlocked
                    ? AppTheme.successGreenLight
                    : AppTheme.errorRedLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unlocked ? '🔓 Desbloqueada' : '🔒 Bloqueada',
                style: TextStyle(
                  color: unlocked ? AppTheme.successGreen : AppTheme.errorRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
