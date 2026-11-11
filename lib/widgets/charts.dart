import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../services/wearable_service.dart';

/// Line chart per V1.1: 2 px stroke, 8 px end dot, optional mean band in chart-band. No gradients.
class LineChartView extends StatelessWidget {
  const LineChartView({
    super.key,
    required this.values,
    required this.color,
    this.xLabels = const ['00:00', '12:00', 'NOW'],
    this.rangeLabel,
    this.title = 'TODAY',
    this.height = 140,
    this.meanBand = true,
    this.semanticLabel,
  });
  final List<num> values;
  final Color color;
  final List<String> xLabels;
  final String? rangeLabel;
  final String title;
  final double height;
  final bool meanBand;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final lo = values.reduce(math.min).toDouble();
    final hi = values.reduce(math.max).toDouble();
    return Semantics(
      label: semanticLabel ?? '$title chart, range ${lo.round()} to ${hi.round()}',
      child: ExcludeSemantics(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(title, style: AlviType.label(context))),
            if (rangeLabel != null) Text(rangeLabel!, style: AlviType.data(context, size: 11)),
          ]),
          const SizedBox(height: 12),
          SizedBox(height: height, child: CustomPaint(painter: _LinePainter(values, color, c, meanBand))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (final l in xLabels) Text(l, style: AlviType.data(context, size: 10, color: c.inkMuted))],
          ),
        ]),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.values, this.color, this.c, this.meanBand);
  final List<num> values;
  final Color color;
  final AlviColors c;
  final bool meanBand;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final lo = values.reduce(math.min).toDouble();
    final hi = values.reduce(math.max).toDouble();
    final span = (hi - lo).abs() < 0.0001 ? 1.0 : hi - lo;
    double y(num v) => size.height - 8 - (v - lo) / span * (size.height - 16);
    final dash = Paint()
      ..color = c.divider
      ..strokeWidth = 1;
    for (final f in [0.0, 1.0]) {
      final yy = f == 0 ? 4.0 : size.height - 4;
      for (double x = 0; x < size.width; x += 6) {
        canvas.drawLine(Offset(x, yy), Offset(x + 2, yy), dash);
      }
    }
    if (meanBand) {
      final mean = values.fold<double>(0, (a, b) => a + b) / values.length;
      final bandH = size.height * 0.14;
      canvas.drawRect(Rect.fromLTWH(0, y(mean) - bandH / 2, size.width, bandH), Paint()..color = c.chartBand);
    }
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      i == 0 ? path.moveTo(x, y(values[i])) : path.lineTo(x, y(values[i]));
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round);
    canvas.drawCircle(Offset(size.width, y(values.last)), 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => old.values != values || old.c != c;
}

/// Thin vertical bars with day labels ("Last 7 days"). Tone colours paired with height.
class BarsView extends StatelessWidget {
  const BarsView({super.key, required this.values, required this.labels, required this.colors, this.height = 90, this.highlightLast = true, this.title});
  final List<num> values;
  final List<String> labels;
  final List<Color> colors;
  final double height;
  final bool highlightLast;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final hi = values.reduce(math.max).toDouble();
    return Semantics(
      label: '${title ?? 'Trend'}: ${[for (var i = 0; i < values.length; i++) '${labels[i]} ${values[i]}'].join(', ')}',
      child: ExcludeSemantics(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (title != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title!.toUpperCase(), style: AlviType.label(context))),
          SizedBox(
            height: height,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (var i = 0; i < values.length; i++)
                Expanded(
                  child: Center(
                    child: Container(
                      width: 3,
                      height: hi == 0 ? 2.0 : math.max(2.0, values[i] / hi * height),
                      decoration: BoxDecoration(color: colors[i % colors.length], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 8),
          Row(children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Text(labels[i],
                    textAlign: TextAlign.center,
                    style: AlviType.data(context, size: 10, color: (highlightLast && i == labels.length - 1) ? c.ink : c.inkMuted)),
              ),
          ]),
        ]),
      ),
    );
  }
}

/// Sleep stages: four labelled rows (awake dotted, REM, light, deep). Colour never the only cue.
class StageChart extends StatelessWidget {
  const StageChart({super.key, required this.segments, this.totalHours = 8.4});
  final List<SleepSegment> segments;
  final double totalHours;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    const rows = ['awake', 'rem', 'light', 'deep'];
    return Semantics(
      label: 'Sleep stages from 22:48 to 06:52',
      child: ExcludeSemantics(
        child: Column(children: [
          for (final r in rows)
            SizedBox(
              height: 28,
              child: Row(children: [
                SizedBox(width: 52, child: Text(r.toUpperCase(), style: AlviType.label(context))),
                Expanded(
                  child: LayoutBuilder(builder: (context, box) {
                    return Stack(alignment: Alignment.centerLeft, clipBehavior: Clip.none, children: [
                      SizedBox(width: box.maxWidth, height: 28),
                      CustomPaint(size: Size(box.maxWidth, 1), painter: _DotLine(c.divider)),
                      for (final s in segments.where((s) => s.stage == r))
                        Positioned(
                          left: s.startHour / totalHours * box.maxWidth,
                          width: math.max(4.0, (s.endHour - s.startHour) / totalHours * box.maxWidth - 2),
                          height: r == 'awake' ? 14 : 14,
                          child: r == 'awake'
                              ? Center(child: Container(width: 2, height: 14, color: c.inkMuted))
                              : Container(
                                  decoration: BoxDecoration(
                                    color: r == 'deep' ? c.sleep : (r == 'rem' ? c.sleepRem : c.sleepLight),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                        ),
                    ]);
                  }),
                ),
              ]),
            ),
          const SizedBox(height: 6),
          Row(children: [
            const SizedBox(width: 52),
            Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                for (final t in ['23:00', '03:00', '07:00']) Text(t, style: AlviType.data(context, size: 10, color: c.inkMuted)),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _DotLine extends CustomPainter {
  _DotLine(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (double x = 0; x < size.width; x += 5) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 2, 1), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ring with a start dot (readiness, widgets).
class RingView extends StatelessWidget {
  const RingView({super.key, required this.progress, required this.color, this.size = 200, this.stroke = 3, this.child, this.semanticLabel});
  final double progress;
  final Color color;
  final double size;
  final double stroke;
  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticLabel,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(progress, color, context.alvi.lineStrong, stroke),
            child: Center(child: child),
          ),
        ),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.p, this.color, this.track, this.stroke);
  final double p, stroke;
  final Color color, track;
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - math.max(stroke, 6.0);
    final center = size.center(Offset.zero);
    canvas.drawCircle(center, r, Paint()..color = track..style = PaintingStyle.stroke..strokeWidth = 1);
    const start = math.pi; // dot on the left like the sample design
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), start, 2 * math.pi * p, false,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round);
    canvas.drawCircle(center + Offset(math.cos(start) * r, math.sin(start) * r), math.max(stroke * 2, 5.0), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.p != p || old.color != color;
}

/// Step goal track: tick marks with filled progress and a dot (Activity).
class TickProgress extends StatelessWidget {
  const TickProgress({super.key, required this.progress, required this.color});
  final double progress;
  final Color color;
  @override
  Widget build(BuildContext context) => Semantics(
        label: '${(progress * 100).round()} percent of goal',
        child: SizedBox(height: 28, width: double.infinity, child: CustomPaint(painter: _TickPainter(progress, color, context.alvi))),
      );
}

class _TickPainter extends CustomPainter {
  _TickPainter(this.p, this.color, this.c);
  final double p;
  final Color color;
  final AlviColors c;
  @override
  void paint(Canvas canvas, Size size) {
    final tick = Paint()..color = c.lineStrong..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += size.width / 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, 14), tick);
    }
    final y = size.height - 6;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint()..color = c.lineStrong..strokeWidth = 2);
    canvas.drawLine(Offset(0, y), Offset(size.width * p, y), Paint()..color = color..strokeWidth = 2);
    canvas.drawCircle(Offset(size.width * p, y), 6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TickPainter old) => old.p != p;
}

/// Onboarding step segments ("STEP 5 OF 8").
class StepSegments extends StatelessWidget {
  const StepSegments({super.key, required this.step, required this.total});
  final int step, total;
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Semantics(
      label: 'Step $step of $total',
      child: Row(children: [
        for (var i = 1; i <= total; i++)
          Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.only(right: i == total ? 0 : 6),
              color: i <= step ? c.ink : c.lineStrong,
            ),
          ),
      ]),
    );
  }
}

/// Horizontal labelled bars for distributions and zones (replaces donuts).
class LabelledBars extends StatelessWidget {
  const LabelledBars({super.key, required this.rows});

  /// [label, valueText, fraction 0..1, Color]
  final List<(String, String, double, Color)> rows;

  @override
  Widget build(BuildContext context) => Column(children: [
        for (final r in rows)
          Semantics(
            label: '${r.$1} ${r.$2}',
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(children: [
                  SizedBox(width: 92, child: Text(r.$1, style: AlviType.data(context, size: 11))),
                  Expanded(
                    child: LayoutBuilder(builder: (context, box) => Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: math.max(4.0, box.maxWidth * r.$3.clamp(0.0, 1.0)),
                            height: 3,
                            decoration: BoxDecoration(color: r.$4, borderRadius: BorderRadius.circular(2)),
                          ),
                        )),
                  ),
                  SizedBox(width: 64, child: Text(r.$2, textAlign: TextAlign.right, style: AlviType.data(context, size: 11))),
                ]),
              ),
            ),
          ),
      ]);
}

/// ECG trace on a fine grid (sample waveform).
class EcgTrace extends StatelessWidget {
  const EcgTrace({super.key, this.height = 140, this.flat = false});
  final double height;
  final bool flat;
  @override
  Widget build(BuildContext context) => Semantics(
      label: flat ? 'ECG trace, waiting' : 'ECG trace, sample',
      child: SizedBox(height: height, width: double.infinity, child: CustomPaint(painter: _EcgPainter(context.alvi, flat))));
}

class _EcgPainter extends CustomPainter {
  _EcgPainter(this.c, this.flat);
  final AlviColors c;
  final bool flat;
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = c.divider..strokeWidth = 0.6;
    for (double x = 0; x <= size.width; x += 10) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += 10) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final mid = size.height * 0.6;
    final path = Path()..moveTo(0, mid);
    for (double x = 0; x <= size.width; x += 1) {
      double y = mid;
      if (!flat) {
        final t = (x % 70) / 70;
        if (t > 0.10 && t < 0.18) y -= math.sin((t - 0.10) / 0.08 * math.pi) * 6;
        if (t > 0.26 && t < 0.28) y += 8;
        if (t >= 0.28 && t < 0.31) y -= 46;
        if (t >= 0.31 && t < 0.33) y += 14;
        if (t > 0.45 && t < 0.60) y -= math.sin((t - 0.45) / 0.15 * math.pi) * 10;
      }
      path.lineTo(x, y);
    }
    canvas.drawPath(path, Paint()..color = c.heart..style = PaintingStyle.stroke..strokeWidth = 1.6);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter old) => old.flat != flat;
}

/// Compass with N/E/S/W ticks and a Qibla marker at [bearing] degrees.
class CompassView extends StatelessWidget {
  const CompassView({super.key, required this.bearing, this.heading = 0, this.size = 260});
  final double bearing, heading, size;
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Compass. Qibla bearing ${bearing.round()} degrees from north',
        child: SizedBox(width: size, height: size, child: CustomPaint(painter: _CompassPainter(context.alvi, bearing, heading))),
      );
}

class _CompassPainter extends CustomPainter {
  _CompassPainter(this.c, this.bearing, this.heading);
  final AlviColors c;
  final double bearing, heading;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 16;
    final tick = Paint()..color = c.lineStrong..strokeWidth = 1;
    for (var d = 0; d < 360; d += 6) {
      final a = (d - heading - 90) * math.pi / 180;
      final len = d % 90 == 0 ? 14.0 : 7.0;
      canvas.drawLine(center + Offset(math.cos(a) * r, math.sin(a) * r),
          center + Offset(math.cos(a) * (r - len), math.sin(a) * (r - len)), d % 90 == 0 ? (Paint()..color = c.ink..strokeWidth = 2) : tick);
    }
    const labels = {'N': 0, 'E': 90, 'S': 180, 'W': 270};
    labels.forEach((k, d) {
      final a = (d - heading - 90) * math.pi / 180;
      final tp = TextPainter(
          text: TextSpan(text: k, style: TextStyle(fontFamily: AlviType.mono, fontWeight: FontWeight.w700, fontSize: 12, color: c.ink)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, center + Offset(math.cos(a) * (r - 30), math.sin(a) * (r - 30)) - Offset(tp.width / 2, tp.height / 2));
    });
    final a = (bearing - heading - 90) * math.pi / 180;
    canvas.drawLine(center, center + Offset(math.cos(a) * (r - 44), math.sin(a) * (r - 44)),
        Paint()..color = c.readiness..strokeWidth = 2..strokeCap = StrokeCap.round);
    canvas.drawCircle(center + Offset(math.cos(a) * (r - 44), math.sin(a) * (r - 44)), 7, Paint()..color = c.readiness);
    canvas.drawCircle(center, 4, Paint()..color = c.ink);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) => old.bearing != bearing || old.heading != heading;
}

/// Deterministic block pattern standing in for a QR code (sample payload, not scannable).
class CodePattern extends StatelessWidget {
  const CodePattern({super.key, required this.seed, this.size = 220});
  final String seed;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
      label: 'Personal code (sample, not scannable)',
      child: SizedBox(width: size, height: size, child: CustomPaint(painter: _CodePainter(seed, context.alvi.ink))));
}

class _CodePainter extends CustomPainter {
  _CodePainter(this.seed, this.color);
  final String seed;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    const n = 25;
    final cell = size.width / n;
    final rng = math.Random(seed.hashCode);
    final p = Paint()..color = color;
    bool finder(int x, int y) {
      bool inBox(int ox, int oy) => x >= ox && x < ox + 7 && y >= oy && y < oy + 7;
      return inBox(0, 0) || inBox(n - 7, 0) || inBox(0, n - 7);
    }

    void drawFinder(int ox, int oy) {
      canvas.drawRect(Rect.fromLTWH(ox * cell, oy * cell, 7 * cell, 7 * cell), p);
      canvas.drawRect(Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell), Paint()..color = const Color(0x00000000)..blendMode = BlendMode.clear);
      canvas.drawRect(Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, 3 * cell, 3 * cell), p);
    }

    canvas.saveLayer(Offset.zero & size, Paint());
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (!finder(x, y) && rng.nextBool()) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), p);
      }
    }
    drawFinder(0, 0);
    drawFinder(n - 7, 0);
    drawFinder(0, n - 7);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CodePainter old) => old.seed != seed;
}

/// Haptic glyphs: one pulse (dot), two pulses, long pulse (bar), rising, swell, short+long, tick (ring).
class HapticGlyph extends StatelessWidget {
  const HapticGlyph(this.pattern, {super.key, this.color});
  final HapticPattern pattern;
  final Color? color;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
      child: SizedBox(width: 40, height: 20, child: CustomPaint(painter: _GlyphPainter(pattern, color ?? context.alvi.ink))));
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.p, this.color);
  final HapticPattern p;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final f = Paint()..color = color;
    final cy = size.height / 2;
    switch (p) {
      case HapticPattern.inZone:
        canvas.drawCircle(Offset(4, cy), 3.5, f);
        break;
      case HapticPattern.goal:
        canvas.drawCircle(Offset(4, cy), 3.5, f);
        canvas.drawCircle(Offset(13, cy), 3.5, f);
        break;
      case HapticPattern.move:
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, cy - 3, 30, 6), const Radius.circular(3)), f);
        break;
      case HapticPattern.silentAlarm:
        canvas.drawCircle(Offset(2, cy), 1.5, f);
        canvas.drawCircle(Offset(9, cy), 2.2, f);
        canvas.drawCircle(Offset(17, cy), 3, f);
        canvas.drawCircle(Offset(27, cy), 4, f);
        break;
      case HapticPattern.breathe:
        final path = Path()
          ..moveTo(0, cy + 5)
          ..quadraticBezierTo(15, cy - 10, 30, cy + 5);
        canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
        break;
      case HapticPattern.batteryLow:
        canvas.drawCircle(Offset(4, cy), 3.5, f);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(11, cy - 3, 18, 6), const Radius.circular(3)), f);
        break;
      case HapticPattern.tick:
        canvas.drawCircle(Offset(5, cy), 4, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.6);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) => old.p != p || old.color != color;
}

/// Line drawing of the Helium core (pill with a dot) inside concentric rings.
class CoreIllustration extends StatelessWidget {
  const CoreIllustration({super.key, this.size = 220, this.rings = true, this.pulsing = false});
  final double size;
  final bool rings;
  final bool pulsing;
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final core = Container(
      width: size * 0.5,
      height: size * 0.22,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Radii.pill), border: Border.all(color: c.ink, width: 2)),
      alignment: Alignment.center,
      child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: c.ink)),
    );
    if (!rings) return ExcludeSemantics(child: core);
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          _PulseRing(size: size, color: c.lineStrong, animate: pulsing),
          Container(width: size * 0.78, height: size * 0.78, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.divider))),
          core,
        ]),
      ),
    );
  }
}

class _PulseRing extends StatefulWidget {
  const _PulseRing({required this.size, required this.color, required this.animate});
  final double size;
  final Color color;
  final bool animate;
  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void initState() {
    super.initState();
    if (widget.animate && !WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
      _a.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _a,
        builder: (context, _) => Container(
          width: widget.size * (0.92 + 0.08 * _a.value),
          height: widget.size * (0.92 + 0.08 * _a.value),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.color)),
        ),
      );
}
