import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:galingo/l10n/app_localizations.dart';

import '../../../core/services/review_service.dart';
import '../../../data/models/lesson_model.dart';
import '../../providers/progress_provider.dart';
import '../lesson/lesson_screen.dart';

/// Pantalla de **repaso espaciado**: construye una lección con los ítems que el
/// planificador SM-2 marca como vencidos y la presenta como una lección normal.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  LessonModel? _lesson;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    final progress = ref.read(progressNotifierProvider).valueOrNull;
    LessonModel? lesson;
    if (progress != null) {
      final due = ReviewService.instance.dueItems(progress);
      lesson = await ReviewService.instance.buildReviewLesson(due);
    }
    if (mounted) {
      setState(() {
        _lesson = lesson;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final lesson = _lesson;
    if (lesson == null) {
      final l = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: AppBar(title: Text(l.review)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.reviewNone, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    return LessonScreen(lessonId: lesson.id, overrideLesson: lesson);
  }
}
