import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';

/// ALVI toggle: pill track. On = ink track with surface knob; off = outline with muted knob.
class AlviSwitch extends StatelessWidget {
  const AlviSwitch({super.key, required this.value, this.onChanged, this.label});
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Semantics(
      toggled: value,
      label: label,
      enabled: onChanged != null,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: Sizes.touch + 8,
          height: Sizes.touch,
          child: Center(
            child: AnimatedContainer(
              duration: Motion.short,
              width: 46,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? c.ink : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.pill),
                border: Border.all(color: value ? c.ink : c.borderControl, width: 1.2),
              ),
              child: AnimatedAlign(
                duration: Motion.short,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: value ? c.surface : c.borderControl),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip: selected is filled ink, unselected is outline.
class AlviChip extends StatelessWidget {
  const AlviChip(this.text, {super.key, required this.selected, this.onTap});
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Semantics(
      selected: selected,
      button: true,
      label: text,
      child: Material(
        color: selected ? c.ink : Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: selected ? c.ink : c.borderControl)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40, minWidth: Sizes.touch),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: AlviType.bodySmall(context, color: selected ? c.surface : c.ink)
                      .copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented control (Day / Week / Month, Soft / Medium / Strong).
class AlviSegmented extends StatelessWidget {
  const AlviSegmented({super.key, required this.options, required this.selected, required this.onChanged});
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: c.borderControl),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: Semantics(
                selected: o == selected,
                button: true,
                label: o,
                child: GestureDetector(
                  onTap: () => onChanged(o),
                  child: AnimatedContainer(
                    duration: Motion.short,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: o == selected ? c.ink : Colors.transparent,
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                    child: Text(o,
                        style: AlviType.bodySmall(context, color: o == selected ? c.surface : c.ink)
                            .copyWith(fontWeight: o == selected ? FontWeight.w600 : FontWeight.w400)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small round choice (band size S / M / L).
class RoundChoice extends StatelessWidget {
  const RoundChoice(this.text, {super.key, required this.selected, this.onTap});
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Semantics(
      selected: selected,
      button: true,
      label: 'Size $text',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: Sizes.touch,
          height: Sizes.touch,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? c.ink : Colors.transparent,
            border: Border.all(color: selected ? c.ink : c.borderControl),
          ),
          child: Text(text,
              style: AlviType.bodySmall(context, color: selected ? c.surface : c.ink)
                  .copyWith(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

/// Radio indicator (outline ring, filled dot when selected).
class AlviRadio extends StatelessWidget {
  const AlviRadio({super.key, required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Container(
      width: 22,
      height: 22,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? c.ink : c.borderControl, width: 1.5)),
      child: selected ? DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: c.ink)) : null,
    );
  }
}

/// Underlined input with a caps label above it.
class AlviField extends StatefulWidget {
  const AlviField({
    super.key,
    required this.label,
    this.hint = '',
    this.controller,
    this.obscure = false,
    this.keyboard,
    this.trailing,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
  });
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboard;
  final Widget? trailing;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  @override
  State<AlviField> createState() => _AlviFieldState();
}

class _AlviFieldState extends State<AlviField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label.toUpperCase(), style: AlviType.label(context, text: widget.label)),
          TextField(
            controller: widget.controller,
            obscureText: _hidden,
            keyboardType: widget.keyboard,
            maxLines: widget.obscure ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            style: AlviType.body(context),
            cursorColor: c.ink,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AlviType.body(context, color: c.inkMuted),
              counterStyle: AlviType.fine(context),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.lineStrong)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.ink, width: 1.5)),
              suffixIcon: widget.obscure
                  ? IconButton(
                      tooltip: _hidden ? 'Show password' : 'Hide password',
                      icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: c.inkMuted, size: 20),
                      onPressed: () => setState(() => _hidden = !_hidden),
                    )
                  : widget.trailing,
            ),
          ),
        ],
      ),
    );
  }
}
