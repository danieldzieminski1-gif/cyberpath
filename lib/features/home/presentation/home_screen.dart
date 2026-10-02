import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/widgets.dart';
import '../../content/data/content_repository.dart';
import '../../progress/application/providers.dart';
import '../../progress/domain/progress.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    final due = ref.watch(dueCardsProvider).length;
    final next = nextLesson(p.completed);
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_greeting(), style: t.textTheme.bodyMedium),
                  Text('Ready to build real skills?', style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                ]),
              ),
              IconButton(tooltip: 'Search', icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
            ]),
            const SizedBox(height: 16),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('Level ${p.level}', style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('${p.xp} XP', style: t.textTheme.titleMedium?.copyWith(color: t.colorScheme.primary)),
                ]),
                const SizedBox(height: 10),
                Semantics(
                  label: 'Level progress',
                  value: '${(ProgressEngine.levelProgress(p.xp) * 100).round()} percent',
                  child: LinearProgressIndicator(value: ProgressEngine.levelProgress(p.xp), minHeight: 8, borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(height: 8),
                Text('${p.streak}-day streak · ${p.completed.length} lessons done', style: t.textTheme.bodySmall),
              ]),
            ),
            const SectionTitle('Continue'),
            if (next != null)
              AppCard(
                onTap: () => context.push('/lesson/${next.id}'),
                child: Row(children: [
                  Icon(Icons.play_circle_fill, size: 40, color: t.colorScheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(next.title, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text('${next.summary} · ${next.minutes} min', style: t.textTheme.bodySmall),
                    ]),
                  ),
                ]),
              )
            else
              const AppCard(child: Text('You finished every lesson. Keep sharp with Review and the Terminal Lab.')),
            const SectionTitle('Today'),
            AppCard(
              onTap: () => context.go('/review'),
              child: Row(children: [
                const Icon(Icons.replay_circle_filled_outlined),
                const SizedBox(width: 12),
                Expanded(child: Text(due == 0 ? 'No cards due. Nice work.' : '$due flashcards ready to review')),
                const Icon(Icons.chevron_right),
              ]),
            ),
            const SectionTitle('Quick actions'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _Action('Terminal Lab', Icons.terminal, () => context.push('/terminal')),
                _Action('Glossary', Icons.abc, () => context.push('/glossary')),
                _Action('Notes', Icons.sticky_note_2_outlined, () => context.push('/notes')),
                _Action('Quick Quiz', Icons.bolt, () => context.push('/lesson/quick')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 10), Expanded(child: Text(label))]),
      );
}
