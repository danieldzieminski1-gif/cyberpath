import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/widgets.dart';
import '../../content/data/content_repository.dart';
import '../../progress/application/providers.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(progressProvider.select((p) => p.completed));
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: kCourses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final c = kCourses[i];
          final total = c.lessons.length;
          final n = c.lessons.where((l) => done.contains(l.id)).length;
          return AppCard(
            onTap: () => context.push('/course/${c.id}'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(courseIcon(c.icon), color: t.colorScheme.primary, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.title, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text('${c.subtitle} · ${c.level}', style: t.textTheme.bodySmall),
                  ]),
                ),
              ]),
              const SizedBox(height: 14),
              LinearProgressIndicator(value: total == 0 ? 0 : n / total, minHeight: 6, borderRadius: BorderRadius.circular(6)),
              const SizedBox(height: 6),
              Text('$n of $total lessons', style: t.textTheme.bodySmall),
            ]),
          );
        },
      ),
    );
  }
}

class CourseScreen extends ConsumerWidget {
  const CourseScreen({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = courseById(courseId);
    if (course == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Course not found.')));
    final p = ref.watch(progressProvider);
    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final m in course.modules) ...[
            SectionTitle(m.title),
            for (final l in m.lessons)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => context.push('/lesson/${l.id}'),
                  child: Row(children: [
                    Icon(p.completed.contains(l.id) ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: p.completed.contains(l.id) ? Theme.of(context).colorScheme.primary : null),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text('${l.summary} · ${l.minutes} min', style: Theme.of(context).textTheme.bodySmall),
                      ]),
                    ),
                    if (p.lessonScores[l.id] != null) Text('${p.lessonScores[l.id]}%'),
                  ]),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
