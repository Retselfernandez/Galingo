import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:galingo/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_progress_model.dart';
import '../../providers/progress_provider.dart';
import 'galingo_sidebar.dart';

/// Sidebar de escritorio conectado aos providers.
///
/// A diferenza de [GalingoSidebar] (puramente visual), este widget le o
/// progreso e constrúe a navegación entre as pestanas do shell.
class DesktopSidebar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressNotifierProvider).valueOrNull;
    final units = ref.watch(unitsWithStatusProvider).valueOrNull;
    final strings = AppLocalizations.of(context)!;
    final data = progress ?? UserProgressModel.initial();

    final a1LessonIds = <String>{
      for (final s in units ?? const <UnitWithStatus>[])
        for (final l in s.unit.lessons) l.id,
    };
    final lessonsCompleted =
        data.completedLessonIds.where(a1LessonIds.contains).length;

    return GalingoSidebar(
      userName: data.userName,
      xp: data.totalXp,
      streak: data.streakDays,
      lessonsCompleted: lessonsCompleted,
      progress: data,
      levelLabel: 'Nivel A1 — Iniciación',
      onLevelTap: () => _showLevelInfo(context, strings),
      currentIndex: currentIndex,
      onSelect: onSelect,
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
