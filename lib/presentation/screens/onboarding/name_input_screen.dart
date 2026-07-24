import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/gabi/gabi_widget.dart';

/// Pantalla de onboarding para introducir el nombre del usuario
class NameInputScreen extends ConsumerStatefulWidget {
  const NameInputScreen({super.key});

  @override
  ConsumerState<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends ConsumerState<NameInputScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
    // Auto-focus after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    await ref.read(progressNotifierProvider.notifier).updateUserName(name);

    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);

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
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gabi preguntando
                  Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 600)),
                      ScaleEffect(
                        begin: Offset(0.5, 0.5),
                        end: Offset(1.0, 1.0),
                        curve: Curves.elasticOut,
                        duration: Duration(milliseconds: 900),
                      ),
                    ],
                    child: GabiWidget(
                      state: GabiState.happy,
                      size: 160,
                      showMessage: true,
                      message: strings.nameQuestion,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Título
                  Animate(
                    delay: const Duration(milliseconds: 400),
                    effects: [
                      const FadeEffect(duration: Duration(milliseconds: 500)),
                      SlideEffect(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      ),
                    ],
                    child: Text(
                      strings.nameQuestion,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Animate(
                    delay: const Duration(milliseconds: 550),
                    effects: const [FadeEffect(duration: Duration(milliseconds: 400))],
                    child: Text(
                      strings.nameSubtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Campo de texto
                  Animate(
                    delay: const Duration(milliseconds: 650),
                    effects: [
                      const FadeEffect(duration: Duration(milliseconds: 500)),
                      SlideEffect(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      ),
                    ],
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: strings.nameHint,
                        hintStyle: TextStyle(
                          color: AppTheme.textHint,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF5BB3F0),
                            width: 3,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _saveName(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón continuar
                  Animate(
                    delay: const Duration(milliseconds: 800),
                    effects: [
                      const FadeEffect(duration: Duration(milliseconds: 400)),
                      SlideEffect(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      ),
                    ],
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hasText ? 1.0 : 0.5,
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _hasText && !_isLoading ? _saveName : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryBlue,
                            disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                )
                              : Text(
                                  strings.continueLabel,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
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
      ),
    );
  }
}
