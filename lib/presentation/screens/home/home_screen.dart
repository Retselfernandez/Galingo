import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_strings.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/gabi/gabi_widget.dart';
import '../../widgets/camino/unit_node_widget.dart';

/// HomeScreen — "O Camiño"
/// Pantalla principal con la progresión de unidades del curso
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressNotifierProvider);
    final unitsAsync = ref.watch(unitsWithStatusProvider);
    final strings = ref.watch(appStringsProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactScreen = screenWidth < 800;

    return Scaffold(
      drawer: isCompactScreen
          ? Drawer(
              width: AppConstants.sidebarWidth,
              child: _buildSidebar(context, ref, progressAsync, strings, isDrawer: true),
            )
          : null,
      body: Row(
        children: [
          // ── Sidebar fija (macOS de escritorio en pantalla ancha) ──────
          if (!isCompactScreen)
            _buildSidebar(context, ref, progressAsync, strings),

          // ── Contenido principal: El Camiño ───────────────────────────
          Expanded(
            child: _buildMainContent(
              context,
              ref,
              unitsAsync,
              progressAsync,
              strings,
              isCompactScreen: isCompactScreen,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sidebar ─────────────────────────────────────────────────────────────

  Widget _buildSidebar(
    BuildContext context,
    WidgetRef ref,
    AsyncValue progressAsync,
    AppStrings strings, {
    bool isDrawer = false,
  }) {
    final userName = progressAsync.valueOrNull?.userName ?? 'Estudante';
    final currentLevel = progressAsync.valueOrNull?.currentLevel ?? 'A1';
    final isA2 = currentLevel == 'A2';

    final sidebarContent = Container(
      width: AppConstants.sidebarWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isA2 ? AppTheme.accentCoral : AppTheme.primaryBlue,
            isA2 ? const Color(0xFFD84315) : AppTheme.primaryBlueDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isA2 ? AppTheme.accentCoral : AppTheme.primaryBlue).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 640;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: isCompact ? 12 : 20),
                        _buildAppHeader(context),
                        SizedBox(height: isCompact ? 12 : 16),
                        GabiWidget(
                          state: GabiState.pointing,
                          size: isCompact ? 80 : 100,
                          showMessage: !isCompact, // oculta la burbuja si hay poco espacio vertical
                          message: '${strings.greetingFor(userName)}\n${strings.nextLessonMessage}',
                        ),
                        SizedBox(height: isCompact ? 12 : 16),
                        progressAsync.when(
                          data: (progress) => _buildUserStats(context, progress),
                          loading: () => const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isCompact ? 8 : 16),
                  child: progressAsync.when(
                    data: (progress) => _buildLevelBadge(context, ref, progress, strings),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (isDrawer) {
      return sidebarContent;
    }

    return sidebarContent.animate().slideX(
          begin: -1.0,
          end: 0,
          curve: Curves.easeOutCubic,
          duration: 600.ms,
        );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Column(
      children: [
        // Logo circular premium con Gabi la Gaviota
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.accentGold, AppTheme.accentCoral],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGold.withValues(alpha: 0.5),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 2.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Nombre de la app con gradiente brillante y efecto glow
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, AppTheme.accentGold, AppTheme.accentCoral],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: AppTheme.accentGold.withValues(alpha: 0.8),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
          ),
        ),
        Text(
          AppConstants.appTagline,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserStats(BuildContext context, dynamic progress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            progress.userName ?? 'Estudante',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                icon: '⭐',
                value: '${progress.totalXp}',
                label: 'XP Total',
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                context,
                icon: '🔥',
                value: '${progress.streakDays}',
                label: 'Racha',
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                context,
                icon: '📚',
                value: '${progress.completedLessonIds.length}',
                label: 'Leccións',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  Widget _buildLevelBadge(
    BuildContext context,
    WidgetRef ref,
    dynamic progress,
    AppStrings strings,
  ) {
    final currentLevel = progress.currentLevel ?? 'A1';

    return GestureDetector(
      onTap: () => _showLevelSelectorDialog(context, ref, progress, strings),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎓',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                currentLevel == 'A1'
                    ? strings.levelA1
                    : currentLevel == 'A2'
                        ? strings.levelA2
                        : currentLevel == 'B1'
                            ? strings.levelB1
                            : strings.levelB2,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.swap_vert_rounded,
                color: AppTheme.accentGold,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Contenido principal: El Camiño ───────────────────────────────────────

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue unitsAsync,
    AsyncValue progressAsync,
    AppStrings strings, {
    required bool isCompactScreen,
  }) {
    final currentLevel = progressAsync.valueOrNull?.currentLevel ?? 'A1';

    return Column(
      children: [
        // Header
        _buildTopBar(context, currentLevel, strings, isCompactScreen: isCompactScreen),

        // Lista de unidades
        Expanded(
          child: unitsAsync.when(
            data: (units) => _buildCaminoList(context, ref, units, currentLevel, strings),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('Erro ao cargar o curso: $error'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.refresh(unitsWithStatusProvider),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    String currentLevel,
    AppStrings strings, {
    required bool isCompactScreen,
  }) {
    Color indicatorColor = AppTheme.primaryBlue;
    if (currentLevel == 'A2') {
      indicatorColor = AppTheme.accentCoral;
    } else if (currentLevel == 'B1') {
      indicatorColor = const Color(0xFF43A047);
    } else if (currentLevel == 'B2') {
      indicatorColor = const Color(0xFF8E24AA);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: indicatorColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (isCompactScreen) ...[
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Abrir menú',
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.pathTitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  currentLevel == 'A1'
                      ? strings.levelA1
                      : currentLevel == 'A2'
                          ? strings.levelA2
                          : currentLevel == 'B1'
                              ? strings.levelB1
                              : strings.levelB2,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_rounded),
            color: AppTheme.textSecondary,
            tooltip: strings.settings,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: -0.2,
          end: 0,
          curve: Curves.easeOut,
          duration: 400.ms,
        );
  }

  Widget _buildCaminoList(
    BuildContext context,
    WidgetRef ref,
    List<UnitWithStatus> units,
    String currentLevel,
    AppStrings strings,
  ) {
    final showNextLevelBanner = currentLevel != 'B2';

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      itemCount: units.length + (showNextLevelBanner ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < units.length) {
          final unitStatus = units[index];
          return UnitNodeWidget(
            unitStatus: unitStatus,
            index: index,
            isCurrentUnit: unitStatus.isUnlocked && !unitStatus.isCompleted,
            onTap: () {
              if (unitStatus.unit.lessons.isNotEmpty) {
                final progress = ref.read(progressNotifierProvider).valueOrNull;
                final completedIds = progress?.completedLessonIds ?? [];
                
                final nextLesson = unitStatus.unit.lessons.firstWhere(
                  (l) => !completedIds.contains(l.id),
                  orElse: () => unitStatus.unit.lessons.first,
                );
                
                context.push(AppRoutes.lessonPath(nextLesson.id));
              }
            },
          );
        } else {
          final String nextLvl;
          final String nextTitle;
          final String nextIcon;
          final Color nextColor;

          if (currentLevel == 'A1') {
            nextLvl = 'A2';
            nextTitle = strings.levelA2;
            nextIcon = '✈️';
            nextColor = AppTheme.accentCoral;
          } else if (currentLevel == 'A2') {
            nextLvl = 'B1';
            nextTitle = strings.levelB1;
            nextIcon = '💬';
            nextColor = const Color(0xFF43A047);
          } else {
            nextLvl = 'B2';
            nextTitle = strings.levelB2;
            nextIcon = '📚';
            nextColor = const Color(0xFF8E24AA);
          }

          return _buildNextLevelBanner(
            context,
            ref,
            nextLvl,
            nextTitle,
            nextIcon,
            nextColor,
            index,
            strings,
          );
        }
      },
    );
  }

  Widget _buildNextLevelBanner(
    BuildContext context,
    WidgetRef ref,
    String nextLvl,
    String nextTitle,
    String nextIcon,
    Color nextColor,
    int index,
    AppStrings strings,
  ) {
    return GestureDetector(
      onTap: () {
        final progress = ref.read(progressNotifierProvider).valueOrNull;
        if (progress != null) {
          _showLevelSelectorDialog(context, ref, progress, strings);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.only(top: 24, bottom: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                nextColor.withValues(alpha: 0.05),
                AppTheme.accentGold.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: nextColor.withValues(alpha: 0.4),
              width: 2,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: nextColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    nextIcon,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: nextColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      'Toca para cambiar de nivel e comezar o $nextLvl',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: nextColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 80).ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.2, end: 0, curve: Curves.easeOut, duration: 400.ms);
  }

  // ─── Diálogo Selector de Nivel Premium ─────────────────────────────────────

  void _showLevelSelectorDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic progress,
    AppStrings strings,
  ) {
    final currentLevel = progress.currentLevel ?? 'A1';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const GabiWidget(
                    state: GabiState.happy,
                    size: 72,
                    animate: false,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        strings.selectLevel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
          
              _LevelCardOption(
                icon: '👋',
                title: strings.levelA1,
                subtitle: strings.levelA1Subtitle,
                gradientColors: const [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
                isSelected: currentLevel == 'A1',
                onTap: () async {
                  await ref
                      .read(progressNotifierProvider.notifier)
                      .updateCurrentLevel('A1');
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 12),
          
              _LevelCardOption(
                icon: '✈️',
                title: strings.levelA2,
                subtitle: strings.levelA2Subtitle,
                gradientColors: const [AppTheme.accentCoral, Color(0xFFD84315)],
                isSelected: currentLevel == 'A2',
                onTap: () async {
                  await ref
                      .read(progressNotifierProvider.notifier)
                      .updateCurrentLevel('A2');
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 12),

              _LevelCardOption(
                icon: '💬',
                title: strings.levelB1,
                subtitle: strings.levelB1Subtitle,
                gradientColors: const [Color(0xFF43A047), Color(0xFF2E7D32)],
                isSelected: currentLevel == 'B1',
                onTap: () async {
                  await ref
                      .read(progressNotifierProvider.notifier)
                      .updateCurrentLevel('B1');
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 12),

              _LevelCardOption(
                icon: '📚',
                title: strings.levelB2,
                subtitle: strings.levelB2Subtitle,
                gradientColors: const [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
                isSelected: currentLevel == 'B2',
                onTap: () async {
                  await ref
                      .read(progressNotifierProvider.notifier)
                      .updateCurrentLevel('B2');
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
          
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  strings.cancel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Componentes del diálogo ─────────────────────────────────────────────────

class _LevelCardOption extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCardOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.accentGold : Colors.grey.shade200,
              width: isSelected ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? AppTheme.accentGold : Colors.black).withValues(alpha: isSelected ? 0.15 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono con el gradiente de fondo
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Títulos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),

              // Tick de seleccionado
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentGold,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
