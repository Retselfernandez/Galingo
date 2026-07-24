import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../data/models/settings_model.dart';
import '../../../data/models/user_progress_model.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';

/// Pantalla de configuración de Galingo
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final strings = ref.watch(appStringsProvider);
    final progressAsync = ref.watch(progressNotifierProvider);
    final userName = progressAsync.valueOrNull?.userName ?? 'Estudante';

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settings),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showResetDialog(context, ref, strings),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 18),
            label: Text(
              strings.reset,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ── Perfil / Nombre ──────────────────────────────────────────
              _buildSectionHeader(context, strings.editName, 0),
              const SizedBox(height: 12),
              _buildProfileCard(context, ref, strings, userName),
              const SizedBox(height: 16),

              // ── Idioma ───────────────────────────────────────────────────
              _buildSectionHeader(context, strings.interfaceLanguage, 1),
              const SizedBox(height: 12),
              _buildLanguageSelector(context, ref, settings, strings),
              const SizedBox(height: 16),

              // ── Apariencia ───────────────────────────────────────────────
              _buildSectionHeader(context, strings.appearance, 2),
              const SizedBox(height: 12),
              _buildThemeSelector(context, ref, settings, strings),
              const SizedBox(height: 16),

              // ── Tipografía ───────────────────────────────────────────────
              _buildSectionHeader(context, strings.typography, 3),
              const SizedBox(height: 12),
              _buildFontFamilySelector(context, ref, settings),
              const SizedBox(height: 16),
              _buildFontSizeSelector(context, ref, settings, strings),
              const SizedBox(height: 16),
              _buildFontPreview(context, settings, strings),
              const SizedBox(height: 24),

              // ── Información ──────────────────────────────────────────────
              _buildSectionHeader(context, strings.information, 4),
              const SizedBox(height: 12),
              _buildInfoCard(context, strings),
              const SizedBox(height: 16),
              _buildTelemetryCard(context, ref, strings),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int index) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    )
        .animate(delay: (index * 60).ms)
        .fadeIn(duration: 350.ms)
        .slideX(begin: -0.1, end: 0, curve: Curves.easeOut, duration: 350.ms);
  }

  Widget _buildProfileCard(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    String userName,
  ) {
    final progressAsync = ref.watch(progressNotifierProvider);
    final progress = progressAsync.valueOrNull ?? UserProgressModel.initial();

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryBlueLight],
                  ),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      '${strings.levelA1} / Nivel actual: ${progress.currentLevel}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showEditNameDialog(context, ref, strings, userName),
                icon: const Icon(Icons.edit_rounded, size: 20),
                color: AppTheme.primaryBlue,
                tooltip: strings.editName,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox('⭐', '${progress.totalXp} XP', 'Experiencia total'),
              _buildStatBox('🔥', '${progress.streakDays} días', 'Racha de estudio'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),
          Text(
            'Insignias académicas:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: appAchievements.map((achievement) {
              final isUnlocked = achievement.isUnlocked(progress);
              return _buildAchievementBadge(context, achievement, isUnlocked);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(
    BuildContext context,
    Achievement achievement,
    bool isUnlocked,
  ) {
    return Tooltip(
      message: '${achievement.title}: ${achievement.description}',
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
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
                    style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AppTheme.successGreenLight
                          : AppTheme.errorRedLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isUnlocked ? '🔓 Desbloqueada' : '🔒 Bloqueada',
                      style: TextStyle(
                        color: isUnlocked ? AppTheme.successGreen : AppTheme.errorRed,
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
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isUnlocked ? 1.0 : 0.4,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked ? Colors.white : Colors.grey.shade200,
                border: Border.all(
                  color: isUnlocked ? Colors.amber.shade600 : Colors.grey.shade400,
                  width: isUnlocked ? 2.5 : 1.5,
                ),
                boxShadow: [
                  if (isUnlocked)
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

  Widget _buildLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
    AppStrings strings,
  ) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppLanguage.values.map((lang) {
              final isSelected = settings.language == lang;
              return GestureDetector(
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setLanguage(lang),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryBlue
                        : (Theme.of(context).brightness == Brightness.dark ? AppTheme.surfaceDark2 : Theme.of(context).cardTheme.color ?? Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    lang.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Tema ─────────────────────────────────────────────────────────────────

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
    AppStrings strings,
  ) {
    final themeLabels = [strings.lightTheme, strings.darkTheme, strings.systemTheme];
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.theme,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: AppThemeMode.values.asMap().entries.map((entry) {
              final mode = entry.value;
              final label = themeLabels[entry.key];
              final isSelected = settings.themeMode == mode;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: _ThemeOptionButton(
                    icon: mode.icon,
                    label: label,
                    isSelected: isSelected,
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .setThemeMode(mode),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Familia de fuente ────────────────────────────────────────────────────

  Widget _buildFontFamilySelector(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
  ) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Familia tipográfica',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ...AppFontFamily.values.map((font) {
            final isSelected = settings.fontFamily == font;
            return _FontOption(
              font: font,
              isSelected: isSelected,
              onTap: () => ref
                  .read(settingsProvider.notifier)
                  .setFontFamily(font),
            );
          }),
        ],
      ),
    );
  }

  // ─── Tamaño de fuente ─────────────────────────────────────────────────────

  Widget _buildFontSizeSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
    AppStrings strings,
  ) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.textSize,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  settings.fontSize.displayName,
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: AppFontSize.values.map((size) {
              final isSelected = settings.fontSize == size;
              return Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(settingsProvider.notifier).setFontSize(size),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 12 + (AppFontSize.values.indexOf(size) * 4),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        size.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.textHint,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Preview ──────────────────────────────────────────────────────────────

  Widget _buildFontPreview(
    BuildContext context,
    SettingsModel settings,
    AppStrings strings,
  ) {
    final fontStyle = _getTextStyle(settings);
    return _SettingsCard(
      backgroundColor: AppTheme.surfaceBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.preview,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ola! Chámome Gabi.',
            style: fontStyle.copyWith(
              fontSize: 22 * settings.fontSize.scale,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aprende galego paso a paso comigo.',
            style: fontStyle.copyWith(
              fontSize: 14 * settings.fontSize.scale,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${settings.fontFamily.displayName} · ${settings.fontSize.displayName}',
            style: fontStyle.copyWith(
              fontSize: 11 * settings.fontSize.scale,
              color: AppTheme.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _getTextStyle(SettingsModel settings) {
    return switch (settings.fontFamily) {
      AppFontFamily.nunito => GoogleFonts.nunito(),
      AppFontFamily.outfit => GoogleFonts.outfit(),
      AppFontFamily.roboto => GoogleFonts.roboto(),
      AppFontFamily.lato => GoogleFonts.lato(),
    };
  }

  // ─── Información ──────────────────────────────────────────────────────────

  Widget _buildInfoCard(BuildContext context, AppStrings strings) {
    return _SettingsCard(
      child: Column(
        children: [
          _InfoRow(icon: Icons.apps_rounded, label: strings.application, value: 'Galingo'),
          const Divider(height: 24),
          _InfoRow(icon: Icons.tag_rounded, label: strings.version, value: '2.0.0 (TFM Master Edition)'),
          const Divider(height: 24),
          _InfoRow(icon: Icons.school_rounded, label: strings.levelCovered, value: strings.levelA1),
          const Divider(height: 24),
          _InfoRow(icon: Icons.translate_rounded, label: strings.targetLanguage, value: 'Galego'),
          const Divider(height: 24),
          _InfoRow(icon: Icons.person_rounded, label: strings.developedBy, value: 'TFM · Lester Fernández'),
          const Divider(height: 24),
          _InfoRow(icon: Icons.code_rounded, label: strings.technology, value: 'Flutter 3.44 · Dart 3'),
          const Divider(height: 24),
          _InfoRow(icon: Icons.calendar_today_rounded, label: strings.year, value: '2026'),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) {
    final progressAsync = ref.watch(progressNotifierProvider);
    final progress = progressAsync.valueOrNull ?? UserProgressModel.initial();

    final count = progress.telemetryCount;
    final hlrMaeVal = progress.hlrMae;
    final sm2MaeVal = progress.sm2Mae;
    final improvement = progress.maeImprovementPercent;

    final bool hasData = count > 0;

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_rounded, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Telemetría de Modelado (Capítulo 7)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (hasData)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreenLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${improvement.toStringAsFixed(1)}% Mellor',
                    style: const TextStyle(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Comparación en tempo real de erro absoluto medio (MAE) entre o motor HLR do TFM e o algoritmo clásico de espaciado SM-2:',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('🦉', style: TextStyle(fontSize: 26)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gabi di: "Completa a túa primeira lección para recoller os primeiros datos de telemetría predictiva!"',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTelemetryBox('Predicións', '$count reviews', 'Muestras evaluadas'),
                _buildTelemetryBox('MAE HLR', hlrMaeVal.toStringAsFixed(4), 'Erro predictivo HLR'),
                _buildTelemetryBox('MAE SM-2', sm2MaeVal.toStringAsFixed(4), 'Erro predictivo SM-2'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Comparativa de Error Predictivo (Menor MAE = Maior Precisión):',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            _buildMaeBar(
              label: 'HLR Engine (TFM)',
              value: hlrMaeVal,
              color: AppTheme.primaryBlue,
              maxValue: hlrMaeVal > sm2MaeVal ? hlrMaeVal : sm2MaeVal,
            ),
            const SizedBox(height: 8),
            _buildMaeBar(
              label: 'SM-2 Clásico (SuperMemo)',
              value: sm2MaeVal,
              color: Colors.grey.shade400,
              maxValue: hlrMaeVal > sm2MaeVal ? hlrMaeVal : sm2MaeVal,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelemetryBox(String label, String value, String description) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textHint),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMaeBar({
    required String label,
    required double value,
    required Color color,
    required double maxValue,
  }) {
    final double pct = maxValue == 0.0 ? 0.0 : (value / maxValue).clamp(0.05, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            Text(value.toStringAsFixed(4), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: pct,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Diálogos ─────────────────────────────────────────────────────────────

  void _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(strings.editName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: strings.nameLabel,
            hintText: strings.nameHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref
                    .read(progressNotifierProvider.notifier)
                    .updateUserName(name);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(strings.save),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(strings.resetTitle),
        content: Text(strings.resetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ ${strings.reset}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(strings.reset),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const _SettingsCard({required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut, duration: 400.ms);
  }
}

class _ThemeOptionButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue
              : (isDark ? AppTheme.surfaceDark2 : AppTheme.surfaceBlue),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FontOption extends StatelessWidget {
  final AppFontFamily font;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontOption({
    required this.font,
    required this.isSelected,
    required this.onTap,
  });

  TextStyle get _previewStyle {
    return switch (font) {
      AppFontFamily.nunito => GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
      AppFontFamily.outfit => GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
      AppFontFamily.roboto => GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
      AppFontFamily.lato => GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    font.displayName,
                    style: _previewStyle.copyWith(
                      color: isSelected
                          ? (Theme.of(context).brightness == Brightness.dark ? AppTheme.primaryBlueLight : AppTheme.primaryBlue)
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    font.description,
                    style: TextStyle(fontSize: 11, color: AppTheme.textHint),
                  ),
                ],
              ),
            ),
            Text(
              'Ola!',
              style: _previewStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade300),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark2 : AppTheme.surfaceBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isDark ? AppTheme.primaryBlueLight : AppTheme.primaryBlue, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

// ─── Clase Logro e Insignias ────────────────────────────────────────────────

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool Function(UserProgressModel) isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}

final List<Achievement> appAchievements = [
  Achievement(
    id: 'first_step',
    title: 'Primeiro Paso',
    description: 'Completa a túa primeira lección en Galingo.',
    icon: '👋',
    isUnlocked: (p) => p.completedLessonIds.isNotEmpty,
  ),
  Achievement(
    id: 'streak_3',
    title: 'Racha Inicial',
    description: 'Mantén unha racha de estudo de polo menos 3 días.',
    icon: '🔥',
    isUnlocked: (p) => p.streakDays >= 3,
  ),
  Achievement(
    id: 'xp_100',
    title: 'Superestrela',
    description: 'Consigue un total de 100 puntos de experiencia (XP).',
    icon: '⭐',
    isUnlocked: (p) => p.totalXp >= 100,
  ),
  Achievement(
    id: 'xp_500',
    title: 'Sabio do Galego',
    description: 'Consigue un total de 500 puntos de experiencia (XP).',
    icon: '🧠',
    isUnlocked: (p) => p.totalXp >= 500,
  ),
  Achievement(
    id: 'polyglot',
    title: 'Políglota A2',
    description: 'Comeza o camiño de nivel intermedio A2.',
    icon: '🎓',
    // L4: comparación robusta con el nivel del usuario, no con el ID de lección
    isUnlocked: (p) => p.currentLevel == 'A2' || p.currentLevel == 'B1' || p.currentLevel == 'B2',
  ),
];
