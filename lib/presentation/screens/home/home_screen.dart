import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/galingo_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_progress_model.dart';
import '../../providers/progress_provider.dart';
import 'package:galingo/l10n/app_localizations.dart';

import '../../widgets/home/home_models.dart';
import '../../widgets/home/galingo_sidebar.dart';
import '../../widgets/home/camino_map.dart';
import '../../widgets/home/lessons_panel.dart';
import '../../widgets/home/progress_pill.dart';

/// HomeScreen — "O Camiño do Galego".
/// Rediseño con sidebar, mapa de paradas y panel de leccións (responsive).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(progressNotifierProvider);
    final unitsAsync = ref.watch(unitsWithStatusProvider);
    final strings = AppLocalizations.of(context)!;

    final due = ref.watch(dueReviewProvider);
    return Scaffold(
      backgroundColor: context.pageBg,
      floatingActionButton: due > 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.review),
              icon: const Icon(Icons.replay_rounded),
              label: Text('${strings.review} ($due)'),
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            )
          : null,
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${strings.errorLoading} $e')),
        data: (progress) => unitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${strings.errorLoading} $e')),
          data: (units) => _buildBody(context, progress, units, strings),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UserProgressModel progress,
    List<UnitWithStatus> units,
    AppLocalizations strings,
  ) {
    int currentIdx =
        units.indexWhere((s) => s.isUnlocked && !s.isCompleted);
    if (currentIdx < 0) currentIdx = units.length - 1;

    final data = <HomeUnitData>[
      for (var i = 0; i < units.length; i++)
        HomeUnitData(
          unit: units[i].unit,
          index: i,
          completed: units[i].isCompleted,
          unlocked: units[i].isUnlocked,
          isCurrent: i == currentIdx,
          xp: HomeUnitData.xpOf(units[i].unit),
          minutes: HomeUnitData.minutesOf(units[i].unit),
        ),
    ];

    final completedUnits = data.where((d) => d.completed).length;
    final a1LessonIds = <String>{
      for (final s in units) for (final l in s.unit.lessons) l.id,
    };
    final lessonsCompleted =
        progress.completedLessonIds.where(a1LessonIds.contains).length;

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1024;

    void open(HomeUnitData d) {
      if (!d.unlocked || d.unit.lessons.isEmpty) return;
      final completedIds = progress.completedLessonIds;
      final next = d.unit.lessons.firstWhere(
        (l) => !completedIds.contains(l.id),
        orElse: () => d.unit.lessons.first,
      );
      context.push(AppRoutes.lessonPath(next.id));
    }

    final sidebar = GalingoSidebar(
      userName: progress.userName,
      xp: progress.totalXp,
      streak: progress.streakDays,
      lessonsCompleted: lessonsCompleted,
      levelLabel: strings.levelA1,
      onLevelTap: () => _showLevelInfo(context, strings),
    );

    final header = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressPill(completed: completedUnits, total: data.length),
        const SizedBox(width: 12),
        SettingsButton(onTap: () => context.push(AppRoutes.settings)),
      ],
    );

    final pillOnly =
        ProgressPill(completed: completedUnits, total: data.length);

    CaminoMap buildMap(Widget? trailing) => CaminoMap(
          units: data,
          highlightedIndex: _hoveredIndex,
          onHover: (i) => setState(() => _hoveredIndex = i),
          onOpen: open,
          headerTrailing: trailing,
        );

    final panel = LessonsPanel(
      units: data,
      highlightedIndex: _hoveredIndex,
      onHover: (i) => setState(() => _hoveredIndex = i),
      onOpen: open,
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          sidebar,
          Expanded(child: buildMap(header)),
          SizedBox(width: 380, child: panel),
        ],
      );
    }

    // Layout estreito: barra superior + mapa + panel debajo.
    // En móbil nativo (iOS/Android) o header amosa o wordmark centrado.
    final isMobileNative = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);

    return Column(
      children: [
        Container(
          color: AppTheme.deepBlue,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SafeArea(
            bottom: false,
            child: isMobileNative
                ? SizedBox(
                    height: 48,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo_wordmark_navy.png',
                          height: 38,
                          filterQuality: FilterQuality.medium,
                          semanticLabel: 'Galingo',
                        ),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      const Text('🦅', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Galingo',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      SettingsButton(
                        onTap: () => context.push(AppRoutes.settings),
                      ),
                    ],
                  ),
          ),
        ),
        Expanded(child: buildMap(pillOnly)),
      ],
    );
  }

  void _showLevelInfo(BuildContext context, AppLocalizations strings) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            AppConstants.hasMultipleLevels
                ? strings.selectLevel
                : '${strings.levelA1} · ${strings.levelCovered}',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
