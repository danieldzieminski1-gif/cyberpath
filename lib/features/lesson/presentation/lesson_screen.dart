import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/data/content_repository.dart';
import '../../content/domain/models.dart';
import '../../progress/application/providers.dart';
import '../../progress/domain/progress.dart';
import 'blocks.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lessonId});
  final String lessonId;
  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  Lesson? lesson;
  int index = 0;
  bool answered = true;
  int correct = 0;
  int total = 0;

  @override
  void initState() {
    super.initState();
    lesson = widget.lessonId == 'quick' ? buildQuickQuiz() : lessonById(widget.lessonId);
    final l = lesson;
    if (l != null && l.blocks.isNotEmpty) {
      total = l.interactiveCount;
      answered = !l.blocks.first.type.isInteractive;
    }
  }

  void _onAnswered(bool ok) {
    if (answered) return;
    setState(() {
      answered = true;
      if (ok) correct++;
    });
  }

  void _next() {
    final l = lesson!;
    if (index < l.blocks.length - 1) {
      setState(() {
        index++;
        answered = !l.blocks[index].type.isInteractive;
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final l = lesson!;
    final LessonOutcome o = ref.read(progressProvider.notifier).completeLesson(l.id, correct: correct, total: total);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Lesson complete'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('+${o.xpGained} XP', style: Theme.of(ctx).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Accuracy: ${ProgressEngine.accuracyPercent(correct, total)}%  ($correct of $total)'),
          for (final a in o.unlocked) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Achievement unlocked: ${a.title}')),
        ]),
        actions: [FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Continue'))],
      ),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = lesson;
    if (l == null || l.blocks.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('This lesson could not be loaded.')));
    }
    final block = l.blocks[index];
    final last = index == l.blocks.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (index + (answered ? 1 : 0)) / l.blocks.length, minHeight: 4),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: BlockView(key: ValueKey(block.id), block: block, onAnswered: _onAnswered),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(onPressed: answered ? _next : null, child: Text(last ? 'Finish' : 'Continue')),
        ),
      ),
    );
  }
}
