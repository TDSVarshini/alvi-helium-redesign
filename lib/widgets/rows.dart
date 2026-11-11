import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../services/wearable_service.dart';
import 'buttons.dart';
import 'charts.dart';
import 'controls.dart';

class AlviDivider extends StatelessWidget {
  const AlviDivider({super.key, this.indent = 0});
  final double indent;
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, margin: EdgeInsets.only(left: indent), color: context.alvi.divider);
}

/// Caps section label with breathing room above.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing, this.top = Space.s24});
  final String text;
  final Widget? trailing;
  final double top;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: top, bottom: Space.s8),
        child: Row(children: [
          Expanded(child: Text(text.toUpperCase(), style: AlviType.label(context, text: text))),
          if (trailing != null) trailing!,
        ]),
      );
}

/// Navigation row, min 56 pt: title, optional supporting text, value and chevron.
class NavRow extends StatelessWidget {
  const NavRow(this.title, {super.key, this.subtitle, this.value, this.onTap, this.leading, this.mono = false, this.chevron = true, this.divider = true, this.danger = false});
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool mono;
  final bool chevron;
  final bool divider;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Semantics(
      button: onTap != null,
      label: [title, if (value != null) value!].join(', '),
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: Sizes.listRowMin + 8),
          decoration: BoxDecoration(border: divider ? Border(bottom: BorderSide(color: c.divider)) : null),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            if (leading != null) ...[SizedBox(width: 32, child: leading), const SizedBox(width: 12)],
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(title, style: AlviType.body(context, color: danger ? c.alert : c.ink)),
                if (subtitle != null) Text(subtitle!, style: AlviType.fine(context)),
              ]),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(value!, style: mono ? AlviType.data(context) : AlviType.bodySmall(context)),
              ),
            if (chevron && onTap != null)
              Padding(padding: const EdgeInsets.only(left: 6), child: Icon(Icons.chevron_right, size: 20, color: c.inkMuted)),
          ]),
        ),
      ),
    );
  }
}

/// Toggle row, min 56 pt.
class ToggleRow extends StatelessWidget {
  const ToggleRow(this.title, {super.key, this.subtitle, required this.value, required this.onChanged, this.leading, this.trailingText});
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Container(
      constraints: const BoxConstraints(minHeight: Sizes.listRowMin + 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.divider))),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        if (leading != null) ...[SizedBox(width: 40, child: leading), const SizedBox(width: 12)],
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: AlviType.body(context)),
            if (subtitle != null) Text(subtitle!, style: AlviType.fine(context)),
          ]),
        ),
        if (trailingText != null)
          Text(trailingText!, style: AlviType.fine(context))
        else
          AlviSwitch(value: value, onChanged: onChanged, label: title),
      ]),
    );
  }
}

/// Numbered instruction row ("01  Place the Helium core on its charger.").
class NumberedRow extends StatelessWidget {
  const NumberedRow(this.index, this.text, {super.key});
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.alvi.divider))),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 32, child: Text(index.toString().padLeft(2, '0'), style: AlviType.data(context, size: 11, color: context.alvi.inkMuted))),
          Expanded(child: Text(text, style: AlviType.body(context))),
        ]),
      );
}

/// Radio row for single-choice lists.
class RadioRow extends StatelessWidget {
  const RadioRow(this.title, {super.key, this.subtitle, required this.selected, required this.onTap});
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        label: title,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: Sizes.listRowMin + 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.alvi.divider))),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: AlviType.body(context)),
                  if (subtitle != null) Text(subtitle!, style: AlviType.fine(context)),
                ]),
              ),
              AlviRadio(selected: selected),
            ]),
          ),
        ),
      );
}

/// Haptic pattern row with glyph and play control.
class HapticRow extends StatelessWidget {
  const HapticRow(this.pattern, {super.key, this.onPlay, this.trailing, this.subtitle});
  final HapticPattern pattern;
  final VoidCallback? onPlay;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: Sizes.listRowMin + 4),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.alvi.divider))),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          SizedBox(width: 48, child: HapticGlyph(pattern)),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pattern.title, style: AlviType.body(context)),
              Text(subtitle ?? pattern.meaning, style: AlviType.fine(context)),
            ]),
          ),
          trailing ?? CircleIconButton(icon: Icons.play_arrow, label: 'Play ${pattern.title}', onTap: onPlay),
        ]),
      );
}
