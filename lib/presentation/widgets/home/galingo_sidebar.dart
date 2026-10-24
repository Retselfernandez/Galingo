import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/galingo_colors.dart';
import '../../../data/models/achievement.dart';
import '../../../data/models/user_progress_model.dart';
import '../progress/achievement_badge.dart';

/// Sidebar izquierdo del escritorio: wordmark, stats, insignias, nivel e
/// navegación inferior (Camiño · Leccións · Progreso · Axustes).
class GalingoSidebar extends StatelessWidget {
  final String userName;
  final int xp;
  final int streak;
  final int lessonsCompleted;
  final UserProgressModel progress;
  final String levelLabel;
  final VoidCallback onLevelTap;

  /// Rama activa do shell (0 = Camiño, 1 = Leccións, 2 = Progreso,
  /// 3 = Axustes).
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const GalingoSidebar({
    super.key,
    required this.userName,
    required this.xp,
    required this.streak,
    required this.lessonsCompleted,
    required this.progress,
    required this.levelLabel,
    required this.onLevelTap,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.deepBlue, context.accent],
        ),
      ),
      child: Stack(
        children: [
          // Olas sutiles abajo
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _WavesPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _wordmark(),
                        const SizedBox(height: 24),
                        _statsCard(context),
                        const SizedBox(height: 14),
                        _badges(context),
                        const SizedBox(height: 14),
                        _levelPill(context),
                      ],
                    ),
                  ),
                ),
                _navBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Wordmark oficial (co sombreiro), o mesmo da cabeceira móbil.
  Widget _wordmark() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo_wordmark_navy.png',
        height: 52,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'Galingo',
      ),
    );
  }

  Widget _statsCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.deepBlue.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _stat('⭐', '$xp', 'XP Total'),
                  _divider(),
                  _stat('🔥', '$streak', 'Racha'),
                  _divider(),
                  _stat('📚', '$lessonsCompleted', 'Leccións'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 34,
        color: Colors.white.withValues(alpha: 0.15),
      );

  Widget _stat(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badges(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insignias',
          style: GoogleFonts.nunito(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final achievement in appAchievements)
              AchievementBadge(
                achievement: achievement,
                unlocked: achievement.isUnlocked(progress),
              ),
          ],
        ),
      ],
    );
  }

  Widget _levelPill(BuildContext context) {
    return GestureDetector(
      onTap: onLevelTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.caminoGold, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🗺️', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                levelLabel,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppTheme.caminoGold, size: 20),
          ],
        ),
      ),
    );
  }

  /// Navegación inferior do sidebar: as mesmas pestanas que a barra móbil.
  Widget _navBar(BuildContext context) {
    const items = <({IconData icon, IconData active, String label})>[
      (icon: Icons.map_outlined, active: Icons.map_rounded, label: 'Camiño'),
      (
        icon: Icons.menu_book_outlined,
        active: Icons.menu_book_rounded,
        label: 'Leccións'
      ),
      (
        icon: Icons.insights_outlined,
        active: Icons.insights_rounded,
        label: 'Progreso'
      ),
      (
        icon: Icons.settings_outlined,
        active: Icons.settings_rounded,
        label: 'Axustes'
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(child: _navItem(items[i], index: i)),
        ],
      ),
    );
  }

  Widget _navItem(
    ({IconData icon, IconData active, String label}) item, {
    required int index,
  }) {
    final selected = currentIndex == index;
    final color = selected
        ? AppTheme.caminoGold
        : Colors.white.withValues(alpha: 0.72);

    return InkWell(
      onTap: () => onSelect(index),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? item.active : item.icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pinturas ────────────────────────────────────────────────────────────────

class _WavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    p.color = Colors.white.withValues(alpha: 0.06);
    final path1 = Path()..moveTo(0, size.height * 0.5);
    for (double x = 0; x <= size.width; x += 20) {
      path1.lineTo(x, size.height * 0.5 + 10 * (x % 60 == 0 ? 1 : 0.4));
    }
    path1
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, p);

    p.color = Colors.white.withValues(alpha: 0.08);
    final path2 = Path()..moveTo(0, size.height * 0.7);
    for (double x = 0; x <= size.width; x += 20) {
      path2.lineTo(x, size.height * 0.7 + 8 * (x % 40 == 0 ? 1 : 0.3));
    }
    path2
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

