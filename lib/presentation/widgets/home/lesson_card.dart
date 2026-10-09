import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import 'home_models.dart';

/// Card de lección (parada) del panel derecho.
class LessonCard extends StatefulWidget {
  final HomeUnitData data;
  final VoidCallback onOpen;
  final ValueChanged<bool>? onHoverChanged;
  final bool highlighted;

  const LessonCard({
    super.key,
    required this.data,
    required this.onOpen,
    this.onHoverChanged,
    this.highlighted = false,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.data.unlocked) {
      widget.onOpen();
    } else {
      _shake.forward(from: 0);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Completa a lección anterior'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final completed = d.completed;
    final locked = !d.unlocked;

    final borderColor = completed
        ? AppTheme.caminoGreen
        : (widget.highlighted || _hover
            ? AppTheme.mediumBlue.withValues(alpha: 0.5)
            : Colors.transparent);
    final bg = completed
        ? AppTheme.caminoGreen.withValues(alpha: 0.10)
        : Colors.white;

    return MouseRegion(
      cursor: locked ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hover = true);
        widget.onHoverChanged?.call(true);
      },
      onExit: (_) {
        setState(() => _hover = false);
        widget.onHoverChanged?.call(false);
      },
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) {
          final t = _shake.value;
          final dx = t == 0 ? 0.0 : 8 * (1 - t) * ((t * 8).floor().isEven ? 1 : -1);
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedScale(
            scale: _hover ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepBlue
                        .withValues(alpha: _hover ? 0.16 : 0.07),
                    blurRadius: _hover ? 18 : 10,
                    offset: Offset(0, _hover ? 8 : 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.skyBlue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.mediumBlue.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unitEmoji(d.index),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.unit.title,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${d.lessonCount} leccións · ${d.unit.level}',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _chip('⭐', '${d.xp} XP'),
                            const SizedBox(width: 8),
                            _chip('⏱', '${d.minutes} min'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _trailing(completed, locked),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.skyBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trailing(bool completed, bool locked) {
    if (completed) {
      return Semantics(
        label: 'Lección completada',
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppTheme.caminoGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 18),
        ),
      );
    }
    if (locked) {
      return Semantics(
        label: 'Lección bloqueada',
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppTheme.lockedGray.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock, color: AppTheme.lockedGray, size: 16),
        ),
      );
    }
    return Semantics(
      label: 'Lección dispoñible',
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppTheme.caminoGold.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.play_arrow, color: AppTheme.caminoGold, size: 18),
      ),
    );
  }
}
