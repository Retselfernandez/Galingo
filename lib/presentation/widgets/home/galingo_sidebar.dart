import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

/// Sidebar izquierdo del HOME: avatar, logo, bocadillo, mascota, stats y nivel.
class GalingoSidebar extends StatelessWidget {
  final String userName;
  final int xp;
  final int streak;
  final int lessonsCompleted;
  final String levelLabel;
  final VoidCallback onLevelTap;

  const GalingoSidebar({
    super.key,
    required this.userName,
    required this.xp,
    required this.streak,
    required this.lessonsCompleted,
    required this.levelLabel,
    required this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.deepBlue, AppTheme.mediumBlue],
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _avatar(),
                  const SizedBox(height: 12),
                  _logo(context),
                  const SizedBox(height: 4),
                  Text(
                    'Aprende galego, paso a paso',
                    style: GoogleFonts.nunito(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _speechBubble(context),
                  const SizedBox(height: 12),
                  _mascot(),
                  const SizedBox(height: 18),
                  _statsCard(context),
                  const SizedBox(height: 14),
                  _levelPill(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/app_icon.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Text('🦅', style: TextStyle(fontSize: 44)),
          ),
        ),
      ),
    );
  }

  Widget _logo(BuildContext context) {
    final base = GoogleFonts.nunito(
      fontSize: 40,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      letterSpacing: -1,
    );
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('Gal', style: base),
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [AppTheme.caminoGold, AppTheme.caminoOrange],
              ).createShader(r),
              child: Text(
                'ingo',
                style: base.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        CustomPaint(
          size: const Size(150, 8),
          painter: _WavyUnderlinePainter(),
        ),
      ],
    );
  }

  Widget _speechBubble(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '¡Ola, $userName! 👋\nTodo gran camiño comeza cun primeiro paso.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: AppTheme.deepBlue,
              fontSize: 13.5,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(22, 10),
          painter: _BubbleTailPainter(),
        ),
      ],
    );
  }

  Widget _mascot() {
    return SizedBox(
      height: 150,
      child: Image.asset(
        'assets/images/gabi_happy.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
          child: Text('🦅', style: TextStyle(fontSize: 90)),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
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

class _WavyUnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.caminoGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(0, size.height / 2);
    for (double x = 0; x < size.width; x += size.width / 6) {
      path.quadraticBezierTo(
        x + size.width / 12,
        x % (size.width / 3) == 0 ? 0 : size.height,
        x + size.width / 6,
        size.height / 2,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
