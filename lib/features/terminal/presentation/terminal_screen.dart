import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../progress/application/providers.dart';
import '../domain/terminal_engine.dart';

class _Entry {
  _Entry(this.prompt, this.command, this.result);
  final String prompt;
  final String command;
  final TerminalResult result;
}

class TerminalScreen extends ConsumerStatefulWidget {
  const TerminalScreen({super.key});
  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  final engine = TerminalEngine();
  final controller = TextEditingController();
  final scroll = ScrollController();
  final focus = FocusNode();
  final List<_Entry> history = [];

  @override
  void dispose() {
    controller.dispose();
    scroll.dispose();
    focus.dispose();
    super.dispose();
  }

  void _run(String line) {
    if (line.trim().isEmpty) return;
    final prompt = engine.prompt;
    final r = engine.run(line);
    setState(() {
      if (r.clear) {
        history.clear();
      } else {
        history.add(_Entry(prompt, line, r));
      }
    });
    ref.read(progressProvider.notifier).recordCommand();
    controller.clear();
    focus.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.jumpTo(scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.45, color: Color(0xFFC9D1D9));
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        foregroundColor: Colors.white,
        title: const Text('Terminal Lab'),
        actions: [
          IconButton(
            tooltip: 'Show commands',
            icon: const Icon(Icons.help_outline),
            onPressed: () => _run('help'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF161B22),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text('Sandbox only. Nothing here touches your real device.', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
          ),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.all(16),
              children: [
                if (history.isEmpty) const Text('Try: pwd, ls, cd projects, cat notes.txt, grep Failed logs/auth.log', style: mono),
                for (final e in history)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SelectableText('${e.prompt}${e.command}', style: mono.copyWith(color: const Color(0xFF00E5A8))),
                      if (e.result.output.isNotEmpty) SelectableText(e.result.output, style: mono),
                      if (e.result.explanation.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('ℹ ${e.result.explanation}', style: mono.copyWith(color: const Color(0xFF8B949E), fontSize: 12)),
                        ),
                    ]),
                  ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF161B22),
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
            child: Row(children: [
              Text(engine.prompt, style: mono.copyWith(color: const Color(0xFF00E5A8))),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focus,
                  autofocus: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: mono,
                  cursorColor: const Color(0xFF00E5A8),
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'type a command', hintStyle: TextStyle(color: Color(0xFF6E7681))),
                  onSubmitted: _run,
                ),
              ),
              IconButton(tooltip: 'Run command', icon: const Icon(Icons.keyboard_return, color: Color(0xFF00E5A8)), onPressed: () => _run(controller.text)),
            ]),
          ),
        ]),
      ),
    );
  }
}
