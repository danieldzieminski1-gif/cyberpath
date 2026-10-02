import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerHigh.withAlpha(140),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant.withAlpha(120)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class MonoBox extends StatelessWidget {
  const MonoBox(this.text, {super.key, this.copyable = false});
  final String text;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Stack(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: EdgeInsets.only(right: copyable ? 36 : 0),
            child: SelectableText(
              text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5, color: Color(0xFFC9D1D9)),
            ),
          ),
        ),
        if (copyable)
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              tooltip: 'Copy code',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy, size: 18, color: Color(0xFF8B949E)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
              },
            ),
          ),
      ]),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Semantics(
      label: '$label: $value',
      child: ExcludeSemantics(
        child: AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: t.colorScheme.primary, size: 22),
            const SizedBox(height: 8),
            Text(value, style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            Text(label, style: t.textTheme.bodySmall),
          ]),
        ),
      ),
    );
  }
}

IconData courseIcon(String key) {
  switch (key) {
    case 'terminal':
      return Icons.terminal;
    case 'lan':
      return Icons.lan_outlined;
    case 'code':
      return Icons.code;
    default:
      return Icons.shield_outlined;
  }
}
