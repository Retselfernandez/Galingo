import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/audio_service.dart';
import 'data/models/settings_model.dart';
import 'data/repositories/hive_repository.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/widgets/gabi/gabi_widget.dart';

Future<bool> _initAppHelper() async {
  try {
    await HiveRepository.instance.initialize();
    // Inicializar reproductor de sonido
    await AudioService.instance.init();
    return true;
  } catch (e) {
    debugPrint("Hive initialization failed: $e");
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final success = await _initAppHelper();
  
  runApp(
    ProviderScope(
      child: success
          ? const GalingoApp()
          : const InitializationErrorApp(),
    ),
  );
}

/// Pantalla de recuperación visual en caso de fallo crítico de base de datos local.
class InitializationErrorApp extends StatelessWidget {
  const InitializationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF0F7FF),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(32),
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GabiWidget(
                      state: GabiState.happy,
                      size: 90,
                      showMessage: true,
                      message: '¡Vaites! Houbo un problema coa base de datos.',
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Erro de inicialización',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2744),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Non puideron cargarse os teus datos de progreso locais. Isto adoita pasar por un arquivo corrupto ou falta de permisos.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF546E88),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          // Intentar limpiar las cajas locales para autorecuperarse
                          try {
                            await HiveRepository.instance.resetProgress();
                          } catch (_) {}
                          final success = await _initAppHelper();
                          runApp(
                            ProviderScope(
                              child: success
                                  ? const GalingoApp()
                                  : const InitializationErrorApp(),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Restablecer e Reintentar',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GalingoApp extends ConsumerStatefulWidget {
  const GalingoApp({super.key});

  @override
  ConsumerState<GalingoApp> createState() => _GalingoAppState();
}

class _GalingoAppState extends ConsumerState<GalingoApp> {
  @override
  void dispose() {
    // L7: liberar recursos de AudioService al destruir el widget raíz
    AudioService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsProvider);

    // Tema con la tipografía elegida (sin escalar fontSize — se hace via textScaler)
    final textTheme = _buildTextTheme(settings.fontFamily);
    final dynamicLight = AppTheme.lightTheme.copyWith(textTheme: textTheme);
    final dynamicDark = AppTheme.darkTheme.copyWith(textTheme: textTheme);

    final themeMode = switch (settings.themeMode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: dynamicLight,
      darkTheme: dynamicDark,
      themeMode: themeMode,
      routerConfig: router,
      // Escalar texto globalmente + Directionality para árabe
      builder: (context, child) {
        final isRtl = settings.language.isRtl;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.fontSize.scale),
          ),
          child: Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
      },
    );
  }

  TextTheme _buildTextTheme(AppFontFamily family) {
    return switch (family) {
      AppFontFamily.nunito => GoogleFonts.nunitoTextTheme(),
      AppFontFamily.outfit => GoogleFonts.outfitTextTheme(),
      AppFontFamily.roboto => GoogleFonts.robotoTextTheme(),
      AppFontFamily.lato => GoogleFonts.latoTextTheme(),
    };
  }
}
