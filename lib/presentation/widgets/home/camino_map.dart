import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:galingo/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/galingo_colors.dart';
import 'home_models.dart';

/// Zona central: cabecera del mapa + ilustración + sendero punteado con paradas.
class CaminoMap extends StatefulWidget {
  final List<HomeUnitData> units;
  final void Function(HomeUnitData unit) onOpen;
  final int? highlightedIndex;
  final void Function(int? index)? onHover;
  final Widget? headerTrailing;

  const CaminoMap({
    super.key,
    required this.units,
    required this.onOpen,
    this.highlightedIndex,
    this.onHover,
    this.headerTrailing,
  });

  @override
  State<CaminoMap> createState() => _CaminoMapState();
}

class _CaminoMapState extends State<CaminoMap> {
  static const double _spacing = 168;
  static const double _topPad = 48;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.pageBg,
      child: LayoutBuilder(
        builder: (context, outer) {
          final narrow = outer.maxWidth < 700;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, narrow: narrow),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height =
                        _topPad * 2 + (widget.units.length - 1) * _spacing + 140;

                    final amp = width * (narrow ? 0.10 : 0.19);
                    final points = List.generate(widget.units.length, (i) {
                      final center = width / 2;
                      final x = center + math.sin(i * 1.05 + 0.6) * amp;
                      final y = _topPad + i * _spacing;
                      return Offset(x, y);
                    });

                    return Stack(
                      children: [
                        Positioned.fill(child: _background()),
                        SingleChildScrollView(
                          child: SizedBox(
                            height: height,
                            width: width,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _DottedPathPainter(points),
                                  ),
                                ),
                                for (var i = 0; i < widget.units.length; i++)
                                  _positionedNode(
                                      context, i, points[i], width, narrow),
                                Positioned(
                                  left: 16,
                                  bottom: 8,
                                  child: _milestone(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, {required bool narrow}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          narrow ? 16 : 24, narrow ? 12 : 18, narrow ? 16 : 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🗺️', style: TextStyle(fontSize: narrow ? 26 : 34)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'O Camiño do Galego',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.pacifico(
                        fontSize: narrow ? 22 : 30,
                        color: context.accent,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      'Nivel A1 — Iniciación',
                      style: GoogleFonts.nunito(
                        fontSize: narrow ? 13 : 15,
                        fontWeight: FontWeight.w800,
                        color: context.accent,
                      ),
                    ),
                  ],
                ),
              ),
              if (!narrow && widget.headerTrailing != null) ...[
                const SizedBox(width: 12),
                widget.headerTrailing!,
              ],
            ],
          ),
          if (narrow && widget.headerTrailing != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: widget.headerTrailing!,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Cada lección é unha parada no teu camiño.',
            style: GoogleFonts.nunito(
              fontSize: narrow ? 13 : 15,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          Text(
            'Completa as leccións e fai que o teu galego che leve máis lonxe.',
            style: GoogleFonts.nunito(
              fontSize: narrow ? 12 : 13.5,
              fontWeight: FontWeight.w500,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Fondo: ilustración costera si existe, si no un degradado placeholder.
  Widget _background() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFBFE3FF), Color(0xFF8FD0F5), Color(0xFF4FB0E8)],
            ),
          ),
        ),
        Image.asset(
          'assets/images/camino_bg.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        // No tema escuro atenuamos a foto para non deslumbrar.
        if (Theme.of(context).brightness == Brightness.dark)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
            ),
          ),
      ],
    );
  }

  Widget _positionedNode(
      BuildContext context, int i, Offset p, double width, bool narrow) {
    final data = widget.units[i];
    final nodeSize = narrow ? 52.0 : 64.0;
    final cardWidth = narrow ? 150.0 : 190.0;
    final toRight = p.dx < width / 2;
    final cardLeft =
        toRight ? p.dx + nodeSize / 2 + 6 : p.dx - nodeSize / 2 - 6 - cardWidth;

    return Stack(
      children: [
        Positioned(
          left: p.dx - nodeSize / 2,
          top: p.dy - nodeSize / 2,
          child: _MapNode(
            index: i,
            data: data,
            highlighted: widget.highlightedIndex == i,
            compact: narrow,
            onHover: (h) => widget.onHover?.call(h ? i : null),
            onTap: () => widget.onOpen(data),
          ),
        ),
        Positioned(
          left: cardLeft.clamp(8, width - cardWidth - 8),
          top: p.dy - (narrow ? 28 : 34),
          child: _MapCard(
            data: data,
            highlighted: widget.highlightedIndex == i,
            compact: narrow,
            onTap: () => widget.onOpen(data),
          ),
        ),
      ],
    );
  }

  Widget _milestone() {
    return Opacity(
      opacity: 0.9,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFCBB79A),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🐚', style: TextStyle(fontSize: 22)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Nodo del mapa ────────────────────────────────────────────────────────────

class _MapNode extends StatefulWidget {
  final int index;
  final HomeUnitData data;
  final bool highlighted;
  final bool compact;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  const _MapNode({
    required this.index,
    required this.data,
    required this.highlighted,
    this.compact = false,
    required this.onHover,
    required this.onTap,
  });

  @override
  State<_MapNode> createState() => _MapNodeState();
}

class _MapNodeState extends State<_MapNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final current = d.isCurrent;
    final completed = d.completed;
    final locked = !d.unlocked;

    final Color base = completed
        ? AppTheme.caminoGreen
        : current
            ? AppTheme.caminoGold
            : AppTheme.lockedGray;

    final double baseSize = widget.compact ? 52 : 64;

    return MouseRegion(
      cursor: locked ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (current)
                  Container(
                    width: baseSize + 16 * _pulse.value,
                    height: baseSize + 16 * _pulse.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.caminoGold
                          .withValues(alpha: 0.25 * (1 - _pulse.value)),
                    ),
                  ),
                child!,
              ],
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.highlighted ? baseSize + 6 : baseSize,
            height: widget.highlighted ? baseSize + 6 : baseSize,
            decoration: BoxDecoration(
              color: base,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: base.withValues(alpha: 0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: completed
                  ? Icon(Icons.check,
                      color: Colors.white, size: widget.compact ? 22 : 28)
                  : Text(
                      '${widget.index + 1}',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: widget.compact ? 18 : 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Card junto al nodo ────────────────────────────────────────────────────────

class _MapCard extends StatelessWidget {
  final HomeUnitData data;
  final bool highlighted;
  final bool compact;
  final VoidCallback onTap;

  const _MapCard({
    required this.data,
    required this.highlighted,
    this.compact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !data.unlocked;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: compact ? 150 : 190,
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14, vertical: compact ? 9 : 12),
        decoration: BoxDecoration(
          color: context.cardBg.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(compact ? 16 : 20),
          border: Border.all(
            color: highlighted
                ? context.accent
                : context.cardBg.withValues(alpha: 0.8),
            width: highlighted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepBlue.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.unit.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: compact ? 12.5 : 14,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: compact ? 6 : 8),
            Row(
              children: [
                Flexible(
                  child: Text('⭐ ${data.xp} XP',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          fontSize: compact ? 10.5 : 11.5,
                          fontWeight: FontWeight.w700,
                          color: context.textSecondary)),
                ),
                SizedBox(width: compact ? 6 : 10),
                Flexible(
                  child: Text('⏱ ${data.minutes} min',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          fontSize: compact ? 10.5 : 11.5,
                          fontWeight: FontWeight.w700,
                          color: context.textSecondary)),
                ),
              ],
            ),
            if (locked) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.lock, size: 12, color: AppTheme.lockedGray),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context)!.blockedLabel,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.lockedGray,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Sendero punteado ──────────────────────────────────────────────────────────

class _DottedPathPainter extends CustomPainter {
  final List<Offset> points;
  _DottedPathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      path.quadraticBezierTo(a.dx, a.dy + (b.dy - a.dy) * 0.35, mid.dx, mid.dy);
      path.quadraticBezierTo(
          b.dx, b.dy - (b.dy - a.dy) * 0.35, b.dx, b.dy);
    }

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Trazo discontinuo
    const dash = 10.0, gap = 8.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = math.min(dist + dash, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedPathPainter old) => old.points != points;
}
