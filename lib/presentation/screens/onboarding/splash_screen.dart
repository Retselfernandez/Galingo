import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/router/app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/hive_repository.dart';
import '../../widgets/gabi/gabi_widget.dart';

/// SplashScreen — pantalla de carga inicial
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    // Comprueba si el usuario ya introdujo su nombre
    final progress = HiveRepository.instance.getProgress();
    if (!mounted) return;

    if (progress.userName == 'Estudante') {
      // Primera vez — pedir nombre
      context.go(AppRoutes.name);
    } else {
      // Usuario ya registrado — ir directamente al home
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D4A8C),
              Color(0xFF1E6BB8),
              Color(0xFF5BB3F0),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gabi
              Animate(
                effects: [
                  ScaleEffect(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.elasticOut,
                    duration: const Duration(milliseconds: 800),
                  ),
                  const FadeEffect(duration: Duration(milliseconds: 400)),
                ],
                child: const GabiWidget(
                  state: GabiState.happy,
                  size: 140,
                  animate: false,
                ),
              ),

              const SizedBox(height: 24),

              // Nombre de la app
              Animate(
                delay: const Duration(milliseconds: 300),
                effects: [
                  const FadeEffect(duration: Duration(milliseconds: 500)),
                  SlideEffect(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 500),
                  ),
                ],
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                ),
              ),

              const SizedBox(height: 8),

              Animate(
                delay: const Duration(milliseconds: 500),
                effects: [
                  const FadeEffect(duration: Duration(milliseconds: 500)),
                  SlideEffect(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 500),
                  ),
                ],
                child: Text(
                  AppConstants.appTagline,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
              ),

              const SizedBox(height: 48),

              // Loader
              Animate(
                delay: const Duration(milliseconds: 700),
                effects: const [FadeEffect(duration: Duration(milliseconds: 400))],
                child: SizedBox(
                  width: 40,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
