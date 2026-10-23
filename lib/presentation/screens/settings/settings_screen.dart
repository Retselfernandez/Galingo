import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/galingo_colors.dart';
import '../../../data/models/settings_model.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_progress_model.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import 'package:galingo/l10n/app_localizations.dart';

/// Pantalla de configuración de Galingo
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final strings = AppLocalizations.of(context)!;
    final progressAsync = ref.watch(progressNotifierProvider);
    final userName = progressAsync.valueOrNull?.userName ?? 'Estudante';

    return Scaffold(
      // Cabecera propia, igual ca nas outras pestanas (Camiño, Leccións,
      // Progreso): mesma franxa deepBlue, icono e tipografía.
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.deepBlue,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (Navigator.of(context).canPop()) ...[
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 22),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: 10),
                      ],
                      const Icon(Icons.settings_rounded,
                          color: Colors.white, size: 26),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Axustes',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Perfil, idioma, tema e datos',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
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

                    // ── Lembretes ────────────────────────────────────────────────
                    _buildSectionHeader(context, strings.reminders, 3),
                    const SizedBox(height: 12),
                    _buildRemindersCard(context, ref, settings, strings),
                    const SizedBox(height: 16),

                    // ── Tipografía ───────────────────────────────────────────────
                    _buildSectionHeader(context, strings.typography, 4),
                    const SizedBox(height: 12),
                    _buildFontFamilySelector(context, ref, settings),
                    const SizedBox(height: 16),
                    _buildFontSizeSelector(context, ref, settings, strings),
                    const SizedBox(height: 16),
                    _buildFontPreview(context, settings, strings),
                    const SizedBox(height: 24),

                    // ── Información ──────────────────────────────────────────────
                    _buildSectionHeader(context, strings.information, 5),
                    const SizedBox(height: 12),
                    _buildInfoCard(context, strings),
                    const SizedBox(height: 16),
                    _SettingsCard(
                      child: ListTile(
                        leading: const Icon(Icons.bug_report_rounded),
                        title: const Text('Reportar un problema'),
                        subtitle: const Text(
                            'O agita el dispositivo en cualquier pantalla'),
                        onTap: () => context.go(AppRoutes.feedback),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTelemetryCard(context, ref, strings),
                    const SizedBox(height: 16),
                    _SettingsCard(
                      child: ListTile(
                        leading: const Icon(Icons.refresh_rounded,
                            color: AppTheme.errorRed),
                        title: Text(
                          strings.reset,
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: const Text(
                            'Borra o progreso local e comeza de cero.'),
                        onTap: () => _showResetDialog(context, ref, strings),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    AppLocalizations strings,
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [context.accent, AppTheme.primaryBlueLight],
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
                onPressed: () =>
                    _showEditNameDialog(context, ref, strings, userName),
                icon: const Icon(Icons.edit_rounded, size: 20),
                color: context.accent,
                tooltip: strings.editName,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersCard(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
    AppLocalizations strings,
  ) {
    final time = TimeOfDay(
      hour: settings.reminderHour,
      minute: settings.reminderMinute,
    );

    return _SettingsCard(
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.notifications_active_rounded),
            title: Text(
              strings.dailyReminder,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(strings.dailyReminderSubtitle),
            value: settings.remindersEnabled,
            onChanged: (value) async {
              final ok = await ref
                  .read(settingsProvider.notifier)
                  .setRemindersEnabled(value);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.notificationsDenied)),
                );
              }
            },
          ),
          if (settings.remindersEnabled) ...[
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_rounded),
              title: Text(strings.reminderTime),
              trailing: Text(
                time.format(context),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                );
                if (picked != null) {
                  await ref
                      .read(settingsProvider.notifier)
                      .setReminderTime(picked.hour, picked.minute);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
    AppLocalizations strings,
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
                onTap: () =>
                    ref.read(settingsProvider.notifier).setLanguage(lang),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.accent
                        : (Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.surfaceDark2
                            : Theme.of(context).cardTheme.color ??
                                Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? context.accent
                          : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    lang.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
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
    AppLocalizations strings,
  ) {
    final themeLabels = [
      strings.lightTheme,
      strings.darkTheme,
      strings.systemTheme
    ];
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.theme,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.textSecondary,
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
                    onTap: () =>
                        ref.read(settingsProvider.notifier).setThemeMode(mode),
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
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ...AppFontFamily.values.map((font) {
            final isSelected = settings.fontFamily == font;
            return _FontOption(
              font: font,
              isSelected: isSelected,
              onTap: () =>
                  ref.read(settingsProvider.notifier).setFontFamily(font),
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
    AppLocalizations strings,
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
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  settings.fontSize.displayName,
                  style: TextStyle(
                    color: context.accent,
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
                  onTap: () =>
                      ref.read(settingsProvider.notifier).setFontSize(size),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.accent
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 12 + (AppFontSize.values.indexOf(size) * 4),
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w400,
                          color: isSelected
                              ? context.accent
                              : context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        size.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          color:
                              isSelected ? context.accent : context.textMuted,
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
    AppLocalizations strings,
  ) {
    final fontStyle = _getTextStyle(settings);
    return _SettingsCard(
      backgroundColor: context.accentSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.preview,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ola! Chámome Gabi.',
            style: fontStyle.copyWith(
              fontSize: 22 * settings.fontSize.scale,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aprende galego paso a paso comigo.',
            style: fontStyle.copyWith(
              fontSize: 14 * settings.fontSize.scale,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${settings.fontFamily.displayName} · ${settings.fontSize.displayName}',
            style: fontStyle.copyWith(
              fontSize: 11 * settings.fontSize.scale,
              color: context.textMuted,
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

  Widget _buildInfoCard(BuildContext context, AppLocalizations strings) {
    return _SettingsCard(
      child: Column(
        children: [
          _InfoRow(
              icon: Icons.apps_rounded,
              label: strings.application,
              value: 'Galingo'),
          const Divider(height: 24),
          _InfoRow(
              icon: Icons.tag_rounded,
              label: strings.version,
              value: '2.0.0 (TFM Master Edition)'),
          const Divider(height: 24),
          _InfoRow(
              icon: Icons.school_rounded,
              label: strings.levelCovered,
              value: strings.levelA1),
          const Divider(height: 24),
          _InfoRow(
              icon: Icons.translate_rounded,
              label: strings.targetLanguage,
              value: 'Galego'),
          const Divider(height: 24),
          _InfoRow(
              icon: Icons.person_rounded,
              label: strings.developedBy,
              value: 'TFM · Lester Fernández'),
          const Divider(height: 24),
          _InfoRow(
              icon: Icons.code_rounded,
              label: strings.technology,
              value: 'Flutter 3.44 · Dart 3'),
          const Divider(height: 24),
          _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: strings.year,
              value: '2026'),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations strings,
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
                child: Icon(Icons.analytics_rounded,
                    color: context.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Telemetría de Modelado (Capítulo 7)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (hasData)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          Text(
            'Comparación en tempo real de erro absoluto medio (MAE) entre o motor HLR do TFM e o algoritmo clásico de espaciado SM-2:',
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.accentSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🦉', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gabi di: "Completa a túa primeira lección para recoller os primeiros datos de telemetría predictiva!"',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: context.accent,
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
                _buildTelemetryBox(context, 'Predicións', '$count reviews',
                    'Muestras evaluadas'),
                _buildTelemetryBox(context, 'MAE HLR',
                    hlrMaeVal.toStringAsFixed(4), 'Erro predictivo HLR'),
                _buildTelemetryBox(context, 'MAE SM-2',
                    sm2MaeVal.toStringAsFixed(4), 'Erro predictivo SM-2'),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Comparativa de Error Predictivo (Menor MAE = Maior Precisión):',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: context.textSecondary),
            ),
            const SizedBox(height: 8),
            _buildMaeBar(
              label: 'HLR Engine (TFM)',
              value: hlrMaeVal,
              color: context.accent,
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

  Widget _buildTelemetryBox(
      BuildContext context, String label, String value, String description) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(fontSize: 9, color: context.textSecondary),
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
    final double pct =
        maxValue == 0.0 ? 0.0 : (value / maxValue).clamp(0.05, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            Text(value.toStringAsFixed(4),
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
    AppLocalizations strings,
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

  void _showResetDialog(
      BuildContext context, WidgetRef ref, AppLocalizations strings) {
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
        color: backgroundColor ??
            Theme.of(context).cardTheme.color ??
            Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Material transparente: os ListTile/ink precisan un Material próximo
      // e o Container (DecoratedBox) agocharíaos.
      child: Material(type: MaterialType.transparency, child: child),
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
              ? context.accent
              : (isDark ? AppTheme.surfaceDark2 : context.accentSoft),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? context.accent
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade200),
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
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
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
      AppFontFamily.nunito =>
        GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
      AppFontFamily.outfit =>
        GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
      AppFontFamily.roboto =>
        GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
      AppFontFamily.lato =>
        GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
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
                ? context.accent
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade200),
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
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.primaryBlueLight
                              : context.accent)
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    font.description,
                    style: TextStyle(fontSize: 11, color: context.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              'Ola!',
              style: _previewStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? context.accent : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? context.accent
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.grey.shade300),
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
            color: isDark ? AppTheme.surfaceDark2 : context.accentSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: isDark ? AppTheme.primaryBlueLight : context.accent,
              size: 18),
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
