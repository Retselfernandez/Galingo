import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import 'home_models.dart';
import 'lesson_card.dart';

/// Panel derecho con la lista de paradas (leccións).
class LessonsPanel extends StatelessWidget {
  final List<HomeUnitData> units;
  final void Function(HomeUnitData unit) onOpen;
  final int? highlightedIndex;
  final void Function(int? index)? onHover;

  const LessonsPanel({
    super.key,
    required this.units,
    required this.onOpen,
    this.highlightedIndex,
    this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded,
                    color: AppTheme.mediumBlue, size: 26),
                const SizedBox(width: 10),
                Text(
                  'Leccións',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.mediumBlue,
                    side: const BorderSide(color: AppTheme.mediumBlue),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Ver todas ›',
                      style: GoogleFonts.nunito(
                          fontSize: 12.5, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 6),
            child: Transform.rotate(
              angle: -0.06,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Xuntos chegamos\nlonxe!',
                    style: GoogleFonts.caveat(
                      fontSize: 26,
                      height: 0.95,
                      color: AppTheme.mediumBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  CustomPaint(
                    size: const Size(120, 8),
                    painter: _WavyPainter(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              itemCount: units.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => LessonCard(
                data: units[i],
                highlighted: highlightedIndex == i,
                onHoverChanged: (h) => onHover?.call(h ? i : null),
                onOpen: () => onOpen(units[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.caminoGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(0, size.height / 2);
    final step = size.width / 6;
    for (double x = 0; x < size.width; x += step) {
      path.quadraticBezierTo(
        x + step / 2,
        size.height,
        x + step,
        size.height / 2,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
