import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/widgets.dart';
import '../../content/data/content_repository.dart';
import '../../progress/application/providers.dart';
import '../../progress/domain/progress.dart';

IconData _achIcon(String k) {
  switch (k) {
    case 'flag':
      return Icons.flag;
    case 'school':
      return Icons.school;
    case 'star':
      return Icons.star;
    case 'bolt':
      return Icons.bolt;
    case 'fire':
      return Icons.local_fire_department;
    case 'memory':
      return Icons.psychology;
    default:
      return Icons.terminal;
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
        AppCard(
          child: Row(children: [
            CircleAvatar(radius: 28, backgroundColor: t.colorScheme.primary.withAlpha(40), child: Text('${p.level}', style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Level ${p.level} learner', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: ProgressEngine.levelProgress(p.xp), borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 4),
                Text('${p.xp} XP total', style: t.textTheme.bodySmall),
              ]),
            ),
          ]),
        ),
        const SectionTitle('Analytics'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: [
            StatTile(label: 'Day streak', value: '${p.streak}', icon: Icons.local_fire_department_outlined),
            StatTile(label: 'Lessons done', value: '${p.completed.length}/${kAllLessons.length}', icon: Icons.menu_book_outlined),
            StatTile(label: 'Quiz accuracy', value: '${p.accuracy}%', icon: Icons.track_changes),
            StatTile(label: 'Commands run', value: '${p.commandsRun}', icon: Icons.terminal),
            StatTile(label: 'Cards reviewed', value: '${p.reviewsDone}', icon: Icons.style_outlined),
            StatTile(label: 'Active days', value: '${p.activeDays}', icon: Icons.calendar_today_outlined),
          ],
        ),
        const SectionTitle('Skill tree'),
        for (final s in kSkills)
          Builder(builder: (context) {
            final n = s.lessonIds.where(p.completed.contains).length;
            final unlocked = n == s.lessonIds.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(children: [
                  Icon(unlocked ? Icons.verified : Icons.lock_outline, color: unlocked ? t.colorScheme.primary : t.disabledColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.name, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      Text(s.description, style: t.textTheme.bodySmall),
                    ]),
                  ),
                  Text('$n/${s.lessonIds.length}'),
                ]),
              ),
            );
          }),
        const SectionTitle('Achievements'),
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final a in allAchievements)
            Builder(builder: (context) {
              final on = p.achievements.contains(a.id);
              return Semantics(
                label: '${a.title}. ${a.description} ${on ? 'Unlocked' : 'Locked'}',
                child: SizedBox(
                  width: (MediaQuery.of(context).size.width - 50) / 2,
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Opacity(
                      opacity: on ? 1 : 0.45,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(_achIcon(a.iconKey), color: t.colorScheme.primary),
                        const SizedBox(height: 6),
                        Text(a.title, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text(a.description, style: t.textTheme.bodySmall),
                      ]),
                    ),
                  ),
                ),
              );
            }),
        ]),
        const SectionTitle('Appearance'),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'system', label: Text('System')),
            ButtonSegment(value: 'dark', label: Text('Dark')),
            ButtonSegment(value: 'light', label: Text('Light')),
          ],
          selected: {p.themeMode},
          onSelectionChanged: (s) => notifier.setTheme(s.first),
        ),
        const SectionTitle('More'),
        ListTile(leading: const Icon(Icons.sticky_note_2_outlined), title: const Text('My notes'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/notes')),
        ListTile(leading: const Icon(Icons.abc), title: const Text('Glossary'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/glossary')),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('Reset progress'),
          onTap: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Reset all progress?'),
                content: const Text('This erases XP, streaks, achievements, reviews and notes on this device.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
                ],
              ),
            );
            if (ok == true) await notifier.reset();
          },
        ),
      ]),
    );
  }
}
