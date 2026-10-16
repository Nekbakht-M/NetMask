import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../settings.dart';
import 'theme.dart';

/// Gives every widget below access to [Settings] and rebuilds on change.
class SettingsScope extends InheritedNotifier<Settings> {
  const SettingsScope({super.key, required Settings settings, required super.child})
      : super(notifier: settings);

  static Settings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;

  /// Reads settings without subscribing (safe in initState and callbacks).
  static Settings read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: TextStyle(fontSize: 13, color: context.c.fg2)),
      );
}

void showToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 1400)));
}

Future<void> copyText(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) showToast(context, SettingsScope.read(context).s['copied']);
}

final _letters = RegExp('[А-Яа-яЁёҶҷҲҳӮӯӢӣҚқҒғ]');

/// One label/value line of a result; tap copies the value.
/// Long values go under the label so nothing overlaps on narrow screens.
class ResultRow extends StatelessWidget {
  const ResultRow(this.label, this.value, {super.key, this.highlight = false, this.last = false});

  final String label;
  final String value;
  final bool highlight;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final stack = value.length > 22;
    // Words (e.g. "Хусусӣ") use the sans face: the mono font has no Tajik letters.
    final isWord = _letters.hasMatch(value);
    final v = Text(
      value,
      textAlign: stack ? TextAlign.start : TextAlign.end,
      style: TextStyle(
        fontFamily: isWord ? kSans : kMono,
        fontFamilyFallback: kMonoFallback,
        fontWeight: FontWeight.w500,
        fontSize: stack ? 13 : 14,
        color: highlight ? c.accent : c.fg,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final k = Text(label, style: TextStyle(color: c.fg2, fontSize: 13.5));
    return Semantics(
      button: true,
      label: '$label: $value',
      child: InkWell(
        onTap: () => copyText(context, value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          decoration: BoxDecoration(
            border: last ? null : Border(bottom: BorderSide(color: c.line)),
          ),
          child: stack
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [k, const SizedBox(height: 2), v],
                )
              : Row(
                  children: [
                    Expanded(child: k),
                    const SizedBox(width: 12),
                    v,
                  ],
                ),
        ),
      ),
    );
  }
}

/// Full-width segmented control (used for IPv4/IPv6 tabs and settings).
class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.height = 40,
    this.mono = false,
  });

  final List<(T, String)> items;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: mono ? c.surface : c.raised,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final (v, label) in items)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Semantics(
                  selected: v == value,
                  button: true,
                  child: GestureDetector(
                    onTap: () => onChanged(v),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: height,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: v == value ? (mono ? c.raised : c.surface) : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        border: v == value
                            ? Border(bottom: BorderSide(color: c.accent, width: 2))
                            : null,
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: mono ? kMono : kSans,
                          fontFamilyFallback: kMonoFallback,
                          fontWeight: mono ? FontWeight.w600 : FontWeight.w500,
                          fontSize: mono ? 15 : 14,
                          color: v == value ? c.fg : c.fg2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 50,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: kSans, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        onPressed: onPressed,
        child: FittedBox(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label),
            if (icon != null) ...[const SizedBox(width: 6), Icon(icon, size: 20)],
          ]),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.onPressed, this.height = 50});
  final String label;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.fg2,
          side: BorderSide(color: c.line),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: kSans, fontWeight: FontWeight.w500, fontSize: 15),
        ),
        onPressed: onPressed,
        child: FittedBox(child: Text(label)),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 46,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: c.raised,
          foregroundColor: c.fg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), side: BorderSide(color: c.line)),
          textStyle: const TextStyle(fontFamily: kSans, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        onPressed: onPressed,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 6)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

/// Square header button (back, settings, share).
class IconSquare extends StatelessWidget {
  const IconSquare({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.background,
    this.foreground,
  });
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background ?? c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: background ?? c.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 22, color: foreground ?? c.fg),
          ),
        ),
      ),
    );
  }
}

/// Telegram paper-plane mark drawn in code (no extra asset).
class TelegramIcon extends StatelessWidget {
  const TelegramIcon({super.key, this.size = 20, this.color = Colors.white});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _TgPainter(color));
}

class _TgPainter extends CustomPainter {
  _TgPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = Path()
      ..moveTo(21.9 * s, 4.3 * s)
      ..lineTo(18.7 * s, 19.4 * s)
      ..cubicTo(18.5 * s, 20.4 * s, 17.8 * s, 20.7 * s, 17.0 * s, 20.2 * s)
      ..lineTo(12.2 * s, 16.7 * s)
      ..lineTo(9.9 * s, 18.9 * s)
      ..cubicTo(9.6 * s, 19.2 * s, 9.4 * s, 19.4 * s, 8.9 * s, 19.4 * s)
      ..lineTo(9.2 * s, 14.5 * s)
      ..lineTo(18.1 * s, 6.5 * s)
      ..cubicTo(18.5 * s, 6.2 * s, 18.0 * s, 6.0 * s, 17.5 * s, 6.3 * s)
      ..lineTo(6.5 * s, 13.2 * s)
      ..lineTo(1.8 * s, 11.7 * s)
      ..cubicTo(0.8 * s, 11.4 * s, 0.8 * s, 10.7 * s, 2.0 * s, 10.2 * s)
      ..lineTo(20.5 * s, 3.1 * s)
      ..cubicTo(21.4 * s, 2.8 * s, 22.1 * s, 3.3 * s, 21.9 * s, 4.3 * s)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TgPainter old) => old.color != color;
}
