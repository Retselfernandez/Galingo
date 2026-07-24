import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/gabi/gabi_widget.dart';

/// WelcomeScreen — primera bienvenida al usuario
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.sunsetGradient,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Animate(
                  effects: [
                    ScaleEffect(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      curve: Curves.elasticOut,
                      duration: const Duration(milliseconds: 800),
                    ),
                  ],
                  child: GabiWidget(
                    state: GabiState.happy,
                    size: 150,
                    showMessage: true,
                    message: strings.gabiWelcome,
                  ),
                ),

                const SizedBox(height: 40),

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
                    strings.tagline,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

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
                    strings.pathSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                Animate(
                  delay: const Duration(milliseconds: 700),
                  effects: [
                    const FadeEffect(duration: Duration(milliseconds: 400)),
                    SlideEffect(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 400),
                    ),
                  ],
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.go(AppRoutes.home),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        strings.startPath,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
