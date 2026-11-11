import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import 'buttons.dart';
import 'controls.dart';
import 'rows.dart';

void toast(BuildContext context, String text) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
}

Future<bool> confirmAction(BuildContext context,
    {required String title, required String body, required String confirm, bool destructive = false}) async {
  final r = await showModalBottomSheet<bool>(
    context: context,
    builder: (ctx) => _SheetFrame(children: [
      Text(title, style: AlviType.headline(ctx, size: 24)),
      const SizedBox(height: 12),
      Text(body, style: AlviType.body(ctx, color: ctx.alvi.inkBody)),
      const SizedBox(height: 24),
      destructive
          ? SecondaryButton(confirm, destructive: true, onPressed: () => Navigator.pop(ctx, true))
          : PrimaryButton(confirm, onPressed: () => Navigator.pop(ctx, true)),
      const SizedBox(height: 8),
      AlviLink('Cancel', onTap: () => Navigator.pop(ctx, false)),
    ]),
  );
  return r ?? false;
}

Future<String?> pickOption(BuildContext context, {required String title, required List<String> options, String? selected}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _SheetFrame(children: [
      Text(title, style: AlviType.headline(ctx, size: 24)),
      const SizedBox(height: 8),
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.55),
        child: ListView(shrinkWrap: true, children: [
          for (final o in options) RadioRow(o, selected: o == selected, onTap: () => Navigator.pop(ctx, o)),
        ]),
      ),
    ]),
  );
}

Future<double?> pickNumber(BuildContext context,
    {required String title, required double value, required double step, required double min, required double max, required String unit}) {
  var v = value;
  return showModalBottomSheet<double>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => _SheetFrame(children: [
        Text(title, style: AlviType.headline(ctx, size: 24)),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleIconButton(icon: Icons.remove, label: 'Decrease', onTap: () => set(() => v = (v - step).clamp(min, max).toDouble())),
          SizedBox(
            width: 180,
            child: Column(children: [
              Text(step >= 1 ? v.round().toString() : v.toStringAsFixed(step < 0.5 ? 2 : 1),
                  textAlign: TextAlign.center, style: AlviType.display(ctx, size: 56)),
              Text(unit.toUpperCase(), style: AlviType.label(ctx)),
            ]),
          ),
          CircleIconButton(icon: Icons.add, label: 'Increase', onTap: () => set(() => v = (v + step).clamp(min, max).toDouble())),
        ]),
        const SizedBox(height: 32),
        PrimaryButton('Done', onPressed: () => Navigator.pop(ctx, v)),
      ]),
    ),
  );
}

Future<String?> askText(BuildContext context, {required String title, String initial = '', String hint = '', TextInputType? keyboard}) {
  final ctrl = TextEditingController(text: initial);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _SheetFrame(children: [
        Text(title, style: AlviType.headline(ctx, size: 24)),
        const SizedBox(height: 16),
        AlviField(label: title, hint: hint, controller: ctrl, keyboard: keyboard),
        PrimaryButton('Save', onPressed: () => Navigator.pop(ctx, ctrl.text.trim())),
      ]),
    ),
  );
}

Future<T?> showSheet<T>(BuildContext context, List<Widget> Function(BuildContext) children) => showModalBottomSheet<T>(
    context: context, isScrollControlled: true, builder: (ctx) => _SheetFrame(children: children(ctx)));

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.side, 12, Space.side, Space.s16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(
                child: Container(
                    width: 36, height: 4, margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: context.alvi.lineStrong, borderRadius: BorderRadius.circular(2)))),
            ...children,
          ]),
        ),
      );
}
