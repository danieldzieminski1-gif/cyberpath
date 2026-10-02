import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/widgets.dart';
import '../../content/data/content_repository.dart';
import '../../content/domain/models.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final challenges = <MapEntry<Lesson, LessonBlock>>[
      for (final l in kAllLessons)
        for (final b in l.blocks.where((b) => b.type == BlockType.challenge)) MapEntry(l, b),
    ];
    Widget tile(String title, String sub, IconData icon, String route) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: () => context.push(route),
            child: Row(children: [
              Icon(icon, color: t.colorScheme.primary, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text(sub, style: t.textTheme.bodySmall),
                ]),
              ),
              const Icon(Icons.chevron_right),
            ]),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          tile('Terminal Lab', 'A safe sandbox shell with explanations', Icons.terminal, '/terminal'),
          tile('Quick Quiz', 'Five mixed questions', Icons.bolt, '/lesson/quick'),
          tile('Flashcards', 'Drill commands and key terms', Icons.style_outlined, '/flashcards'),
          const SectionTitle('Challenges'),
          for (final e in challenges)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: () => context.push('/lesson/${e.key.id}'),
                child: Row(children: [
                  const Icon(Icons.flag_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.value.body), Text('In: ${e.key.title}', style: t.textTheme.bodySmall)])),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
