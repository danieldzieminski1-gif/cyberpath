import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';
import '../../content/domain/models.dart';

/// Renders any LessonBlock. Interactive blocks report correctness via onAnswered.
class BlockView extends StatelessWidget {
  const BlockView({super.key, required this.block, required this.onAnswered});
  final LessonBlock block;
  final ValueChanged<bool> onAnswered;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final header = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(block.type.label.toUpperCase(), style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.primary, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
      if (block.title.isNotEmpty) ...[
        const SizedBox(height: 4),
        Semantics(header: true, child: Text(block.title, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
      ],
      const SizedBox(height: 16),
    ]);
    Widget body;
    switch (block.type) {
      case BlockType.explanation:
        body = Text(block.body, style: t.textTheme.bodyLarge?.copyWith(height: 1.55));
        break;
      case BlockType.diagram:
        body = MonoBox(block.body);
        break;
      case BlockType.code:
        body = MonoBox(block.body, copyable: true);
        break;
      case BlockType.terminal:
        body = MonoBox(block.body);
        break;
      case BlockType.checkpoint:
        body = AppCard(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.verified_outlined, color: t.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(block.body, style: t.textTheme.bodyLarge?.copyWith(height: 1.5))),
          ]),
        );
        break;
      case BlockType.multipleChoice:
        body = McView(block: block, onAnswered: onAnswered);
        break;
      case BlockType.fillBlank:
        body = TextAnswerView(block: block, onAnswered: onAnswered, terminal: false);
        break;
      case BlockType.challenge:
        body = TextAnswerView(block: block, onAnswered: onAnswered, terminal: true);
        break;
      case BlockType.ordering:
        body = OrderingView(block: block, onAnswered: onAnswered);
        break;
      case BlockType.matching:
        body = MatchingView(block: block, onAnswered: onAnswered);
        break;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [header, body]);
  }
}

class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({super.key, required this.ok, required this.text});
  final bool ok;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = ok ? const Color(0xFF1FB57A) : const Color(0xFFE5534B);
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withAlpha(35), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withAlpha(140))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(ok ? Icons.check_circle : Icons.info_outline, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text('${ok ? 'Correct. ' : 'Not quite. '}$text')),
        ]),
      ),
    );
  }
}

enum OptState { idle, selected, correct, wrong }

class OptionTile extends StatelessWidget {
  const OptionTile({super.key, required this.label, required this.state, this.onTap});
  final String label;
  final OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color border = scheme.outlineVariant;
    Color? fill;
    IconData? icon;
    switch (state) {
      case OptState.idle:
        break;
      case OptState.selected:
        border = scheme.primary;
        fill = scheme.primary.withAlpha(30);
        break;
      case OptState.correct:
        border = const Color(0xFF1FB57A);
        fill = const Color(0xFF1FB57A).withAlpha(35);
        icon = Icons.check_circle;
        break;
      case OptState.wrong:
        border = const Color(0xFFE5534B);
        fill = const Color(0xFFE5534B).withAlpha(35);
        icon = Icons.cancel;
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        selected: state != OptState.idle,
        child: Material(
          color: fill ?? Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: border, width: 1.5)),
          child: InkWell(
            customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [Expanded(child: Text(label)), if (icon != null) Icon(icon, color: border)]),
            ),
          ),
        ),
      ),
    );
  }
}

class McView extends StatefulWidget {
  const McView({super.key, required this.block, required this.onAnswered});
  final LessonBlock block;
  final ValueChanged<bool> onAnswered;
  @override
  State<McView> createState() => _McViewState();
}

class _McViewState extends State<McView> {
  int? selected;
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.block;
    OptState stateFor(int i) {
      if (!checked) return selected == i ? OptState.selected : OptState.idle;
      if (i == b.answerIndex) return OptState.correct;
      if (i == selected) return OptState.wrong;
      return OptState.idle;
    }

    final ok = selected == b.answerIndex;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(b.body, style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.4)),
      const SizedBox(height: 16),
      for (var i = 0; i < b.options.length; i++)
        OptionTile(label: b.options[i], state: stateFor(i), onTap: checked ? null : () => setState(() => selected = i)),
      const SizedBox(height: 6),
      FilledButton(
        onPressed: checked || selected == null
            ? null
            : () {
                setState(() => checked = true);
                widget.onAnswered(selected == b.answerIndex);
              },
        child: const Text('Check'),
      ),
      if (checked) FeedbackBanner(ok: ok, text: b.explanation),
    ]);
  }
}

class TextAnswerView extends StatefulWidget {
  const TextAnswerView({super.key, required this.block, required this.onAnswered, required this.terminal});
  final LessonBlock block;
  final ValueChanged<bool> onAnswered;
  final bool terminal;
  @override
  State<TextAnswerView> createState() => _TextAnswerViewState();
}

class _TextAnswerViewState extends State<TextAnswerView> {
  final controller = TextEditingController();
  bool checked = false;
  bool ok = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _check() {
    if (controller.text.trim().isEmpty || checked) return;
    final r = AnswerChecker.matches(controller.text, widget.block.answer);
    setState(() {
      checked = true;
      ok = r;
    });
    widget.onAnswered(r);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.block;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(b.body, style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.4)),
      const SizedBox(height: 16),
      TextField(
        controller: controller,
        enabled: !checked,
        autocorrect: false,
        enableSuggestions: false,
        style: const TextStyle(fontFamily: 'monospace'),
        decoration: InputDecoration(prefixText: widget.terminal ? '\$ ' : null, hintText: widget.terminal ? 'type a command' : 'type your answer'),
        onSubmitted: (_) => _check(),
      ),
      const SizedBox(height: 12),
      FilledButton(onPressed: checked ? null : _check, child: const Text('Check')),
      if (checked) FeedbackBanner(ok: ok, text: ok ? b.explanation : 'Expected: ${b.answer.split('|').first}. ${b.explanation}'),
    ]);
  }
}

class OrderingView extends StatefulWidget {
  const OrderingView({super.key, required this.block, required this.onAnswered});
  final LessonBlock block;
  final ValueChanged<bool> onAnswered;
  @override
  State<OrderingView> createState() => _OrderingViewState();
}

class _OrderingViewState extends State<OrderingView> {
  late List<String> order;
  bool checked = false;
  bool ok = false;

  @override
  void initState() {
    super.initState();
    order = List<String>.from(widget.block.items)..shuffle(Random(widget.block.id.hashCode));
    if (_same(order, widget.block.items) && order.length > 1) order.add(order.removeAt(0));
  }

  bool _same(List<String> a, List<String> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return a.length == b.length;
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.block;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(b.body, style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.4)),
      const SizedBox(height: 4),
      Text('Drag the handles to reorder.', style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 12),
      ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: !checked,
        onReorder: (o, n) {
          if (checked) return;
          setState(() {
            if (n > o) n -= 1;
            order.insert(n, order.removeAt(o));
          });
        },
        children: [
          for (var i = 0; i < order.length; i++)
            Card(
              key: ValueKey(order[i]),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
                title: Text(order[i], style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                trailing: checked ? null : const Icon(Icons.drag_handle),
              ),
            ),
        ],
      ),
      const SizedBox(height: 8),
      FilledButton(
        onPressed: checked
            ? null
            : () {
                final r = _same(order, b.items);
                setState(() {
                  checked = true;
                  ok = r;
                });
                widget.onAnswered(r);
              },
        child: const Text('Check'),
      ),
      if (checked) FeedbackBanner(ok: ok, text: ok ? b.explanation : 'Correct order: ${b.items.join(' → ')}. ${b.explanation}'),
    ]);
  }
}

class MatchingView extends StatefulWidget {
  const MatchingView({super.key, required this.block, required this.onAnswered});
  final LessonBlock block;
  final ValueChanged<bool> onAnswered;
  @override
  State<MatchingView> createState() => _MatchingViewState();
}

class _MatchingViewState extends State<MatchingView> {
  late List<String> rights;
  final Map<String, String> chosen = {};
  bool checked = false;
  bool ok = false;

  @override
  void initState() {
    super.initState();
    rights = widget.block.pairs.values.toList()..shuffle(Random(widget.block.id.hashCode));
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.block;
    final t = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(b.body, style: t.textTheme.titleMedium?.copyWith(height: 1.4)),
      const SizedBox(height: 16),
      for (final left in b.pairs.keys)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(left, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: chosen[left],
              hint: const Text('Choose a match'),
              items: [for (final r in rights) DropdownMenuItem(value: r, child: Text(r, overflow: TextOverflow.ellipsis))],
              onChanged: checked ? null : (v) => setState(() => v == null ? chosen.remove(left) : chosen[left] = v),
            ),
          ]),
        ),
      FilledButton(
        onPressed: checked || chosen.length < b.pairs.length
            ? null
            : () {
                final r = b.pairs.entries.every((e) => chosen[e.key] == e.value);
                setState(() {
                  checked = true;
                  ok = r;
                });
                widget.onAnswered(r);
              },
        child: const Text('Check'),
      ),
      if (checked) FeedbackBanner(ok: ok, text: ok ? b.explanation : 'Review the pairs and try the lesson again. ${b.explanation}'),
    ]);
  }
}
