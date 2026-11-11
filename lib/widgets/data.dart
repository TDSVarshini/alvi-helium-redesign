import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../services/wearable_service.dart';
import '../state/app_state.dart';
import 'buttons.dart';

/// Big numeral with a small unit, e.g. "68 bpm", "7 h 42 m".
class DisplayNumeral extends StatelessWidget {
  const DisplayNumeral(this.parts, {super.key, this.size = 88});

  /// Alternating value/unit pairs: ['7', 'h', '42', 'm'].
  final List<String> parts;
  final double size;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    for (var i = 0; i < parts.length; i++) {
      final isUnit = i.isOdd;
      spans.add(TextSpan(
        text: isUnit ? ' ${parts[i]} ' : parts[i],
        style: isUnit
            ? AlviType.insight(context, color: context.alvi.inkMuted)
            : AlviType.display(context, size: size),
      ));
    }
    return Semantics(
      label: parts.join(' '),
      child: ExcludeSemantics(child: Text.rich(TextSpan(children: spans))),
    );
  }
}

class CapsLabel extends StatelessWidget {
  const CapsLabel(this.text, {super.key, this.color, this.align});
  final String text;
  final Color? color;
  final TextAlign? align;
  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), textAlign: align, style: AlviType.label(context, color: color, text: text));
}

/// Label + value + unit cell used in stat grids.
class StatCell extends StatelessWidget {
  const StatCell(this.label, this.value, {super.key, this.unit = '', this.size = 28});
  final String label, value, unit;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$label $value $unit',
        child: ExcludeSemantics(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CapsLabel(label),
            const SizedBox(height: 6),
            Text.rich(TextSpan(children: [
              TextSpan(text: value, style: AlviType.stat(context, size: size)),
              if (unit.isNotEmpty) TextSpan(text: ' ${unit.toUpperCase()}', style: AlviType.label(context)),
            ])),
          ]),
        ),
      );
}

/// Grid of stats separated by hairline dividers (2 or 3 columns).
class StatGrid extends StatelessWidget {
  const StatGrid(this.cells, {super.key, this.columns = 3});
  final List<StatCell> cells;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += columns) {
      final slice = cells.sublist(i, (i + columns).clamp(0, cells.length));
      rows.add(Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.divider))),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var j = 0; j < columns; j++)
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(j == 0 ? 0 : 12, 14, 8, 14),
                  decoration: BoxDecoration(border: j == 0 ? null : Border(left: BorderSide(color: c.divider))),
                  child: j < slice.length ? slice[j] : const SizedBox.shrink(),
                ),
              ),
          ]),
        ),
      ));
    }
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.divider))),
      child: Column(children: rows),
    );
  }
}

Color toneColor(BuildContext context, String tone) {
  final c = context.alvi;
  switch (tone) {
    case 'good':
    case 'readiness':
      return c.readiness;
    case 'caution':
    case 'temp':
      return c.caution;
    case 'alert':
    case 'heart':
      return c.heart;
    case 'sleep':
      return c.sleep;
    case 'oxygen':
      return c.oxygen;
    case 'activity':
      return c.activity;
    default:
      return c.inkMuted;
  }
}

/// "What shaped it" bar: name and status word on top, thin track with filled portion and dot.
class ContributorBar extends StatelessWidget {
  const ContributorBar({super.key, required this.name, required this.word, required this.value, required this.color});
  final String name, word;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Semantics(
      label: '$name, $word',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.divider))),
          child: Column(children: [
            Row(children: [
              Expanded(child: Text(name, style: AlviType.body(context))),
              Text(word, style: AlviType.bodySmall(context, color: c.ink)),
            ]),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (context, box) {
              final w = box.maxWidth * value.clamp(0.0, 1.0);
              return SizedBox(
                height: 10,
                child: Stack(alignment: Alignment.centerLeft, children: [
                  Container(height: 3, decoration: BoxDecoration(color: c.lineStrong, borderRadius: BorderRadius.circular(2))),
                  Container(width: w, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                  Positioned(
                      left: (w - 5).clamp(0.0, box.maxWidth - 10).toDouble(),
                      child: Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color))),
                ]),
              );
            }),
          ]),
        ),
      ),
    );
  }
}

/// Status word with a small dot. Colour always paired with a word.
class StatusWord extends StatelessWidget {
  const StatusWord(this.word, {super.key, required this.color, this.center = false});
  final String word;
  final Color color;
  final bool center;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 8),
          Text(word.toUpperCase(), style: AlviType.label(context, color: context.alvi.ink, text: word)),
        ],
      );
}

/// Clearly identifies sample data. Never presented as live band data.
class SampleNotice extends StatelessWidget {
  const SampleNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s12),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Radii.tag), border: Border.all(color: c.borderControl)),
          child: Text('SAMPLE DATA', style: AlviType.data(context, size: 10, color: c.inkBody)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text('Not from a band. The ALVI SDK is not connected yet.', style: AlviType.fine(context))),
      ]),
    );
  }
}

/// Previous / next date stepper ("‹  2026-11-10  ›").
class DateStepper extends StatefulWidget {
  const DateStepper({super.key, this.period = 'Day'});
  final String period;

  @override
  State<DateStepper> createState() => _DateStepperState();
}

class _DateStepperState extends State<DateStepper> {
  int offset = 0;
  static const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  String _label() {
    final now = DateTime.now();
    switch (widget.period) {
      case 'Week':
        final start = now.subtract(Duration(days: now.weekday - 1 - offset * 7));
        final end = start.add(const Duration(days: 6));
        return '${start.day} ${months[start.month - 1]} — ${end.day} ${months[end.month - 1]}';
      case 'Month':
        final m = DateTime(now.year, now.month + offset);
        return '${months[m.month - 1]} ${m.year}';
      default:
        if (offset == 0) return 'Today';
        if (offset == -1) return 'Yesterday';
        final d = now.add(Duration(days: offset));
        return '${d.day} ${months[d.month - 1]} ${d.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(tooltip: 'Previous', icon: Icon(Icons.chevron_left, color: c.ink), onPressed: () => setState(() => offset--)),
      SizedBox(
          width: 180,
          child: Text(_label().toUpperCase(), textAlign: TextAlign.center, style: AlviType.label(context, color: c.ink))),
      IconButton(
          tooltip: 'Next',
          icon: Icon(Icons.chevron_right, color: offset < 0 ? c.ink : c.lineStrong),
          onPressed: offset < 0 ? () => setState(() => offset++) : null),
    ]);
  }
}

/// Empty state: concentric glyph, short title, one line of guidance, optional actions.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.body, this.icon, this.action, this.onAction, this.link, this.onLink});
  final String title, body;
  final IconData? icon;
  final String? action, link;
  final VoidCallback? onAction, onLink;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s32),
      child: Column(children: [
        Container(
          width: 136,
          height: 136,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.divider)),
          alignment: Alignment.center,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.lineStrong)),
            alignment: Alignment.center,
            child: icon == null
                ? Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.ink, width: 1.5)))
                : Icon(icon, color: c.ink, size: 28),
          ),
        ),
        const SizedBox(height: Space.s32),
        Text(title, textAlign: TextAlign.center, style: AlviType.headline(context, size: 26)),
        const SizedBox(height: Space.s12),
        Text(body, textAlign: TextAlign.center, style: AlviType.body(context, color: c.inkBody)),
        if (action != null) ...[const SizedBox(height: Space.s32), PrimaryButton(action!, onPressed: onAction)],
        if (link != null) ...[const SizedBox(height: Space.s8), AlviLink(link!, onTap: onLink)],
      ]),
    );
  }
}

/// Fine-print disclaimer at the bottom of health screens.
class Disclaimer extends StatelessWidget {
  const Disclaimer(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(top: Space.s24), child: Text(text, style: AlviType.fine(context)));
}

/// Body paragraph block.
class Para extends StatelessWidget {
  const Para(this.text, {super.key, this.muted = false, this.top = 12});
  final String text;
  final bool muted;
  final double top;
  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(text, style: AlviType.body(context, color: muted ? context.alvi.inkBody : null)));
}

class Headline extends StatelessWidget {
  const Headline(this.text, {super.key, this.eyebrow, this.sub, this.size = 30});
  final String text;
  final String? eyebrow, sub;
  final double size;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: Space.s8, bottom: Space.s8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (eyebrow != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: CapsLabel(eyebrow!)),
          Text(text, style: AlviType.headline(context, size: size)),
          if (sub != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(sub!, style: AlviType.body(context, color: context.alvi.inkBody))),
        ]),
      );
}

/// Banner shown on data screens when the band is not connected.
class DeviceStateBanner extends StatelessWidget {
  const DeviceStateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    String text;
    String route;
    Color dot;
    switch (app.connection) {
      case BandConnection.notPaired:
        text = 'NO BAND · PAIR HELIUM';
        route = '/pair';
        dot = c.inkMuted;
        break;
      case BandConnection.syncFailed:
        text = 'SYNC · NOT CONNECTED';
        route = '/sync-failed';
        dot = c.caution;
        break;
      case BandConnection.connecting:
      case BandConnection.searching:
        text = 'CONNECTING…';
        route = '/device';
        dot = c.caution;
        break;
      default:
        text = 'BAND DISCONNECTED · RECONNECT';
        route = '/sync-failed';
        dot = c.caution;
    }
    return Semantics(
      button: true,
      label: text,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(route),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: Space.side, vertical: 10),
          decoration: BoxDecoration(color: c.surfaceRaised, border: Border(bottom: BorderSide(color: c.divider))),
          child: SafeArea(
            bottom: false,
            child: Row(children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: dot)),
              const SizedBox(width: 8),
              Expanded(child: Text(text, style: AlviType.label(context, color: c.ink))),
              Icon(Icons.chevron_right, size: 18, color: c.inkMuted),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Shows [child] only when the band reports [capability]; otherwise an honest
/// not-available state. Developer › Device simulator can enable all capabilities.
class CapabilityGate extends StatelessWidget {
  const CapabilityGate({super.key, required this.capability, required this.featureName, required this.child, this.reason});
  final String capability;
  final String featureName;
  final Widget child;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    if (app.caps.has(capability)) return child;
    final c = context.alvi;
    return Scaffold(
      backgroundColor: c.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(color: c.surface, gradient: c.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.side),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    tooltip: 'Back',
                    icon: Icon(Icons.chevron_left, color: c.ink, size: 26),
                    onPressed: () => Navigator.of(context).maybePop()),
              ),
              const Spacer(),
              EmptyState(
                title: '$featureName is not on this band.',
                body: reason ?? 'Helium does not report this capability. It appears here when a compatible band is paired.',
                icon: Icons.block_outlined,
              ),
              const Spacer(),
              AlviLink('Preview with the device simulator', onTap: () => Navigator.of(context).pushNamed('/dev/device')),
              const SizedBox(height: Space.s24),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Raised card (8 pt radius) for grouped content.
class AlviCard extends StatelessWidget {
  const AlviCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Material(
      color: c.surfaceRaised,
      borderRadius: BorderRadius.circular(Radii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.card),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
