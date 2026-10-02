import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/data/content_repository.dart';
import '../../progress/application/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  static const pages = [
    (Icons.shield_outlined, 'Learn Cybersecurity.', 'Short, hands-on lessons that take you from your first command to real defensive skills.'),
    (Icons.terminal, 'Build Real Skills.', 'Practise in a safe terminal sandbox. Nothing you type ever touches your device.'),
    (Icons.verified_user_outlined, 'Hack responsibly.', 'Everything here is for learning and defending. Only test systems you own or have written permission to test.'),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _next() {
    if (page < pages.length - 1) {
      controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      ref.read(progressProvider.notifier).finishOnboarding();
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView(
              controller: controller,
              onPageChanged: (i) => setState(() => page = i),
              children: [
                for (final p in pages)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(p.$1, size: 96, color: t.colorScheme.primary),
                      const SizedBox(height: 32),
                      Text(p.$2, textAlign: TextAlign.center, style: t.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Text(p.$3, textAlign: TextAlign.center, style: t.textTheme.bodyLarge),
                    ]),
                  ),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < pages.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                width: i == page ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(color: i == page ? t.colorScheme.primary : t.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(8)),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: FilledButton(onPressed: _next, child: Text(page == pages.length - 1 ? 'Get started' : 'Next')),
          ),
        ]),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  List<SearchHit> hits = const [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search lessons and terms'),
          onChanged: (v) => setState(() => hits = searchContent(v)),
        ),
      ),
      body: hits.isEmpty
          ? Center(child: Text(controller.text.isEmpty ? 'Type to search.' : 'No matches. Try another word.'))
          : ListView.builder(
              itemCount: hits.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(hits[i].title),
                subtitle: Text(hits[i].subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => context.push(hits[i].route),
              ),
            ),
    );
  }
}

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});
  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final items = kGlossary.where((g) => '${g.term} ${g.definition}'.toLowerCase().contains(q.toLowerCase())).toList()..sort((a, b) => a.term.compareTo(b.term));
    return Scaffold(
      appBar: AppBar(title: const Text('Glossary')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Filter terms'), onChanged: (v) => setState(() => q = v)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) => ListTile(title: Text(items[i].term), subtitle: Text('${items[i].definition}\n${items[i].topic}'), isThreeLine: true),
          ),
        ),
      ]),
    );
  }
}

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final body = TextEditingController();
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New note'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: body, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Note')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (save == true && (title.text.trim().isNotEmpty || body.text.trim().isNotEmpty)) {
      ref.read(progressProvider.notifier).addNote(title.text.trim().isEmpty ? 'Untitled' : title.text.trim(), body.text.trim());
    }
    title.dispose();
    body.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(progressProvider.select((p) => p.notes));
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _add(context, ref), icon: const Icon(Icons.add), label: const Text('New note')),
      body: notes.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No notes yet. Jot down commands and ideas as you learn.', textAlign: TextAlign.center)))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: notes.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(notes[i].title),
                subtitle: Text(notes[i].body, maxLines: 3, overflow: TextOverflow.ellipsis),
                trailing: IconButton(tooltip: 'Delete note', icon: const Icon(Icons.delete_outline), onPressed: () => ref.read(progressProvider.notifier).deleteNote(notes[i].id)),
              ),
            ),
    );
  }
}
