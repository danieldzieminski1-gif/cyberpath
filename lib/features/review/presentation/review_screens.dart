import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/widgets.dart';
import '../../content/data/content_repository.dart';
import '../../content/domain/models.dart';
import '../../progress/application/providers.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    final due = ref.watch(dueCardsProvider).length;
    final mastered = p.reviews.values.where((r) => r.reps >= 3).length;
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$due', style: t.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800, color: t.colorScheme.primary)),
            Text(due == 0 ? 'cards due. Come back later, or practise anyway.' : 'cards due today', style: t.textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => context.push('/flashcards'), child: Text(due == 0 ? 'Practice anyway' : 'Start review')),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: StatTile(label: 'Cards seen', value: '${p.reviews.length}', icon: Icons.style_outlined)),
          const SizedBox(width: 12),
          Expanded(child: StatTile(label: 'Mastered', value: '$mastered', icon: Icons.workspace_premium_outlined)),
        ]),
        const SizedBox(height: 12),
        Text('Smart Review brings back cards just before you would forget them. Rate honestly: "Again" returns in 10 minutes, "Easy" pushes it days out.', style: t.textTheme.bodySmall),
      ]),
    );
  }
}

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});
  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  late final List<Flashcard> session;
  int index = 0;
  bool flipped = false;

  @override
  void initState() {
    super.initState();
    final due = ref.read(dueCardsProvider);
    session = due.isNotEmpty ? due.take(15).toList() : (List<Flashcard>.from(kFlashcards)..shuffle()).take(10).toList();
  }

  void _rate(int q) {
    ref.read(progressProvider.notifier).recordReview(session[index].id, q);
    setState(() {
      index++;
      flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    if (index >= session.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.celebration_outlined, size: 56, color: t.colorScheme.primary),
              const SizedBox(height: 12),
              Text('Session complete', style: t.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('You reviewed ${session.length} cards.'),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => context.pop(), child: const Text('Done')),
            ]),
          ),
        ),
      );
    }
    final c = session[index];
    return Scaffold(
      appBar: AppBar(title: Text('Card ${index + 1} of ${session.length}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          LinearProgressIndicator(value: index / session.length, borderRadius: BorderRadius.circular(6)),
          const SizedBox(height: 20),
          Expanded(
            child: Semantics(
              button: true,
              label: flipped ? 'Answer: ${c.back}. Double tap to hide.' : 'Question: ${c.front}. Double tap to reveal the answer.',
              child: AppCard(
                onTap: () => setState(() => flipped = !flipped),
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(c.topic.toUpperCase(), style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.primary, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        flipped ? c.back : c.front,
                        key: ValueKey(flipped),
                        textAlign: TextAlign.center,
                        style: flipped ? t.textTheme.titleLarge : t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!flipped) Text('Tap to reveal', style: t.textTheme.bodySmall),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (flipped)
            Row(children: [
              for (final r in const [('Again', 1), ('Hard', 3), ('Good', 4), ('Easy', 5)])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(onPressed: () => _rate(r.$2), child: Text(r.$1)),
                  ),
                ),
            ])
          else
            FilledButton(onPressed: () => setState(() => flipped = true), child: const Text('Show answer')),
        ]),
      ),
    );
  }
}
