import 'dart:async';

import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../services/wearable_service.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'home_shell.dart';

String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

/// Activity tab (ALVI p6).
class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    final goal = app.goals.firstWhere((g) => g.id == 'steps').value.round();
    return TabPage(
      header: app.connected ? null : const DeviceStateBanner(),
      children: [
        Row(children: [
          const Expanded(child: CapsLabel('Activity · today')),
          Text('GOAL ${_fmt(goal)}', style: AlviType.data(context, size: 11)),
        ]),
        const SizedBox(height: 12),
        const SampleNotice(),
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/activity/steps'),
          child: Text(_fmt(Sample.steps), style: AlviType.display(context, size: 88)),
        ),
        const SizedBox(height: 12),
        TickProgress(progress: (Sample.steps / goal).clamp(0, 1).toDouble(), color: c.activity),
        const SizedBox(height: 12),
        Text(Sample.activityInsight, style: AlviType.insight(context)),
        const SizedBox(height: 20),
        const StatGrid([
          StatCell('Active', '${Sample.activeMin}', unit: 'min'),
          StatCell('Distance', Sample.distanceKm, unit: 'km'),
          StatCell('Energy', '${Sample.energyKcal}', unit: 'kcal'),
        ]),
        SectionLabel('Recent', trailing: AlviLink('All', onTap: () => Navigator.pushNamed(context, '/activity/workouts'))),
        _WorkoutRow(Sample.run, onTap: () => Navigator.pushNamed(context, '/activity/summary')),
        _WorkoutRow(Sample.swim, onTap: () => Navigator.pushNamed(context, '/activity/summary/swim')),
        NavRow('Outdoor run with GPS', onTap: () => Navigator.pushNamed(context, '/activity/outdoor')),
        const SizedBox(height: Space.s32),
        PrimaryButton('Start workout', onPressed: () => Navigator.pushNamed(context, '/activity/start')),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const HapticGlyph(HapticPattern.tick),
          Text('Or double-tap your band', style: AlviType.fine(context)),
        ]),
      ],
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow(this.w, {this.onTap});
  final WorkoutRecord w;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => NavRow(
        w.type,
        leading: Icon(w.type.contains('swim') ? Icons.pool : Icons.directions_run, color: context.alvi.activity, size: 20),
        value: w.distance.isEmpty ? w.time : '${w.distance} KM · ${w.time}',
        mono: true,
        onTap: onTap,
      );
}

/// Steps (QWatch Pro "Data — Steps").
class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});
  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  String period = 'Day';
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final values = period == 'Day' ? Sample.stepsByHour : (period == 'Week' ? Sample.stepsWeek : [for (var i = 0; i < 30; i++) 5000 + (i * 1373) % 7000]);
    final labels = period == 'Day'
        ? [for (var i = 0; i < 24; i++) i % 6 == 0 ? i.toString().padLeft(2, '0') : '']
        : (period == 'Week' ? Sample.weekDays : [for (var i = 1; i <= 30; i++) i % 5 == 0 ? '$i' : '']);
    final total = values.reduce((a, b) => a + b);
    final avg = (total / (period == 'Day' ? 1 : values.length)).round();
    return AlviPage(label: 'Steps', sample: true, children: [
      AlviSegmented(options: const ['Day', 'Week', 'Month'], selected: period, onChanged: (v) => setState(() => period = v)),
      DateStepper(period: period),
      Text(_fmt(period == 'Day' ? total : avg), style: AlviType.display(context, size: 80)),
      CapsLabel(period == 'Day' ? 'Steps today' : 'Daily average'),
      const SizedBox(height: 24),
      BarsView(values: values, labels: labels, colors: [c.activity], height: 140, highlightLast: false),
      const SizedBox(height: 16),
      StatGrid([
        StatCell('Total', _fmt(total), size: 22),
        StatCell('Average', _fmt(avg), size: 22),
        StatCell('Distance', period == 'Day' ? '4.1' : '29.6', unit: 'km', size: 22),
        StatCell('Energy', period == 'Day' ? '412' : '2,870', unit: 'kcal', size: 22),
      ], columns: 2),
    ]);
  }
}

/// Workouts (QWatch Pro "Exercise record"). Shows the ALVI empty state when nothing is recorded.
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});
  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String period = 'Week';
  @override
  Widget build(BuildContext context) {
    final list = period == 'Day' ? <WorkoutRecord>[] : Sample.workouts;
    return AlviPage(label: 'Workouts', sample: list.isNotEmpty, children: [
      AlviSegmented(options: const ['Day', 'Week', 'Month'], selected: period, onChanged: (v) => setState(() => period = v)),
      DateStepper(period: period),
      if (list.isEmpty)
        EmptyState(
          title: 'No workouts yet.',
          body: 'Double-tap your band to start one. It will show up here when you finish.',
          action: 'Start a workout',
          onAction: () => Navigator.pushNamed(context, '/activity/start'),
          link: 'How double-tap works',
          onLink: () => Navigator.pushNamed(context, '/onboarding/haptics'),
        )
      else ...[
        const DisplayNumeral(['1', 'h', '16', 'm'], size: 72),
        const SizedBox(height: 12),
        const StatGrid([StatCell('Workouts', '2'), StatCell('Energy', '808', unit: 'kcal'), StatCell('Zone 3+', '35', unit: 'min')]),
        const SectionLabel('Recent'),
        for (final w in list)
          _WorkoutRow(w, onTap: () => Navigator.pushNamed(context, w.type.contains('swim') ? '/activity/summary/swim' : '/activity/summary')),
      ],
    ]);
  }
}

/// Start a workout (QWatch Pro "Sports Mode").
class StartWorkoutScreen extends StatelessWidget {
  const StartWorkoutScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(label: 'Start a workout', children: [
        const Headline('What are you doing?', sub: 'Or double-tap the core to start the last one. A tick says got it.'),
        const SizedBox(height: 8),
        for (final m in Sample.sportModes)
          NavRow(m, onTap: () => Navigator.pushNamed(context, m == 'Outdoor run' || m == 'Walk' || m == 'Hike' || m == 'Cycling' ? '/activity/outdoor' : '/activity/countdown')),
      ]);
}

/// Outdoor run (QWatch Pro "GPS Running").
class OutdoorScreen extends StatelessWidget {
  const OutdoorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return AlviPage(
      label: 'Outdoor run',
      footer: [
        PrimaryButton('Start', onPressed: () => Navigator.pushNamed(context, '/activity/countdown')),
        AlviLink('Run history', onTap: () => Navigator.pushNamed(context, '/activity/outdoor/history')),
      ],
      children: [
        const DisplayNumeral(['0.00', 'km'], size: 88),
        const CapsLabel('Today'),
        const SizedBox(height: 24),
        Container(
          height: 260,
          decoration: BoxDecoration(color: c.chartBand, borderRadius: BorderRadius.circular(Radii.card)),
          alignment: Alignment.center,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.map_outlined, color: c.inkMuted),
            const SizedBox(height: 8),
            Text('Map appears here when a map service is connected.', textAlign: TextAlign.center, style: AlviType.fine(context)),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          StatusWord('GPS · ready', color: c.good),
          const Spacer(),
          Text('Distance uses your phone\'s GPS.', style: AlviType.fine(context)),
        ]),
      ],
    );
  }
}

class OutdoorHistoryScreen extends StatelessWidget {
  const OutdoorHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(label: 'Run history', sample: true, children: [
        const DateStepper(period: 'Month'),
        const DisplayNumeral(['42:10'], size: 72),
        const SizedBox(height: 12),
        const StatGrid([StatCell('Distance', '8.20', unit: 'km'), StatCell('Energy', '512', unit: 'kcal'), StatCell('Runs', '1')]),
        const SectionLabel('Recent'),
        _WorkoutRow(Sample.run, onTap: () => Navigator.pushNamed(context, '/activity/summary')),
      ]);
}

/// 3-2-1 countdown (QWatch Pro "GPS Run Countdown").
class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});
  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int n = 3;
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (n <= 1) {
        timer.cancel();
        if (mounted) Navigator.pushReplacementNamed(context, '/activity/live');
      } else {
        setState(() => n--);
      }
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlviPage(lead: TopBarLead.close, scroll: false, children: [
        const Spacer(),
        Semantics(liveRegion: true, label: 'Starting in $n', child: Center(child: Text('$n', style: AlviType.display(context, size: 180)))),
        const SizedBox(height: 16),
        Center(child: Text('Your band ticks on go.', style: AlviType.insight(context))),
        const Spacer(),
      ]);
}

/// Live workout (QWatch Pro "GPS Run In Progress"; ALVI p6 Live workout).
class LiveWorkoutScreen extends StatefulWidget {
  const LiveWorkoutScreen({super.key});
  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  int seconds = 0;
  bool paused = false;
  bool locked = false;
  Timer? t;

  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!paused) setState(() => seconds++);
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  String get clock => '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final km = (seconds / 315).toStringAsFixed(2);
    return AlviPage(
      lead: TopBarLead.none,
      label: 'Outdoor run',
      trailing: Padding(padding: const EdgeInsets.only(right: 12), child: StatusWord(paused ? 'Paused' : 'Recording', color: paused ? c.inkMuted : c.heart)),
      sample: true,
      footer: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          CircleIconButton(icon: locked ? Icons.lock : Icons.lock_open, label: locked ? 'Unlock controls' : 'Lock controls', size: 56, onTap: () => setState(() => locked = !locked)),
          CircleIconButton(
              icon: paused ? Icons.play_arrow : Icons.pause,
              label: paused ? 'Resume' : 'Pause',
              filled: true,
              size: 84,
              onTap: locked ? null : () => setState(() => paused = !paused)),
          CircleIconButton(icon: Icons.stop, label: 'End workout', size: 56, onTap: locked ? null : () => Navigator.pushReplacementNamed(context, '/activity/summary')),
        ]),
        const SizedBox(height: 12),
        Text('Double-tap the core to end. Distance uses your phone\'s GPS.', textAlign: TextAlign.center, style: AlviType.fine(context)),
      ],
      children: [
        const SizedBox(height: 16),
        Center(child: Text(clock, style: AlviType.display(context, size: 96))),
        const Center(child: CapsLabel('Elapsed · started by double tap')),
        const SizedBox(height: 32),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Expanded(child: CapsLabel('Heart · zone 3 · target')),
          Text('146', style: AlviType.stat(context, size: 36)),
          Text(' BPM', style: AlviType.label(context)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          for (final col in [c.inkMuted, c.oxygen, c.activity, c.lineStrong, c.lineStrong])
            Expanded(child: Container(height: 3, margin: const EdgeInsets.only(right: 4), color: col)),
        ]),
        const SizedBox(height: 8),
        Text('One pulse when you enter your target zone.', style: AlviType.fine(context)),
        const SizedBox(height: 16),
        StatGrid([
          StatCell('Distance', km, unit: 'km'),
          const StatCell('Pace', '5:15', unit: '/km'),
          StatCell('Energy', '${(seconds * 0.2).round()}', unit: 'kcal'),
          const StatCell('Cadence', '168', unit: 'spm'),
        ], columns: 2),
      ],
    );
  }
}

/// Run summary (QWatch Pro "Exercise Detail – Distance"; ALVI p6).
class RunSummaryScreen extends StatelessWidget {
  const RunSummaryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    const w = Sample.run;
    return AlviPage(
      label: '${w.type} · ${w.date}',
      sample: true,
      trailing: BarIcon(icon: Icons.ios_share, label: 'Share', onTap: () => toast(context, 'Summary image prepared (sample)')),
      footer: [PrimaryButton('Done', onPressed: () => Navigator.popUntil(context, (r) => r.isFirst))],
      children: [
        DisplayNumeral([w.distance, 'km'], size: 88),
        const SizedBox(height: 8),
        Text(w.insight, style: AlviType.insight(context)),
        const SizedBox(height: 16),
        StatGrid([
          StatCell('Time', w.time),
          StatCell('Pace', w.pace, unit: '/km'),
          StatCell('Energy', w.energy, unit: 'kcal'),
          StatCell('Avg HR', w.avgHr),
          StatCell('Max HR', w.maxHr),
          StatCell('Effort', w.effort),
          StatCell('Cadence', w.cadence, unit: 'spm'),
          const StatCell('Stride', '118', unit: 'cm'),
          const StatCell('Steps', '7,084'),
        ]),
        const SectionLabel('Time in zones'),
        LabelledBars(rows: [
          ('Z5', '${w.zoneMinutes[0]} MIN', w.zoneMinutes[0] / 22, c.heart),
          ('Z4', '${w.zoneMinutes[1]} MIN', w.zoneMinutes[1] / 22, c.caution),
          ('Z3', '${w.zoneMinutes[2]} MIN', w.zoneMinutes[2] / 22, c.activity),
          ('Z2', '${w.zoneMinutes[3]} MIN', w.zoneMinutes[3] / 22, c.oxygen),
        ]),
        const SectionLabel('What your band told you'),
        _told(context, HapticPattern.inZone, 'In your zone', '06:12'),
        _told(context, HapticPattern.goal, 'Goal reached · 8 km', '40:54'),
      ],
    );
  }

  Widget _told(BuildContext context, HapticPattern p, String text, String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          SizedBox(width: 48, child: HapticGlyph(p)),
          Expanded(child: Text(text, style: AlviType.body(context))),
          Text(t, style: AlviType.data(context, size: 11)),
        ]),
      );
}

/// Time-and-energy summary (QWatch Pro "Exercise Detail – Calories"), also used for pool swims.
class SimpleSummaryScreen extends StatelessWidget {
  const SimpleSummaryScreen({super.key, this.swim = false});
  final bool swim;
  @override
  Widget build(BuildContext context) {
    final w = swim ? Sample.swim : const WorkoutRecord(id: 'yoga', type: 'Yoga', date: 'SAT 11 OCT', title: '28:00', insight: 'A calm half hour.', time: '28:00', energy: '96');
    return AlviPage(
      label: '${w.type} · ${w.date}',
      sample: true,
      footer: [
        if (swim) Text('Water resistance is a design target. ALVI Helium is in development.', style: AlviType.fine(context)),
        const SizedBox(height: 12),
        PrimaryButton('Done', onPressed: () => Navigator.pop(context)),
      ],
      children: [
        DisplayNumeral([w.time], size: 88),
        const SizedBox(height: 8),
        Text(w.insight, style: AlviType.insight(context)),
        const SizedBox(height: 16),
        StatGrid([
          StatCell('Active', swim ? '31:40' : w.time),
          StatCell('Rest', swim ? '2:25' : '0:00'),
          StatCell('Energy', w.energy, unit: 'kcal'),
        ]),
        const SectionLabel('How it was recorded'),
        Row(children: [
          const SizedBox(width: 48, child: HapticGlyph(HapticPattern.tick)),
          Expanded(child: Text('Started with a double tap', style: AlviType.body(context))),
          Text('00:00', style: AlviType.data(context, size: 11)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          const SizedBox(width: 48, child: HapticGlyph(HapticPattern.tick)),
          Expanded(child: Text('Ended with a double tap', style: AlviType.body(context))),
          Text(w.time, style: AlviType.data(context, size: 11)),
        ]),
        if (swim) ...[
          const SectionLabel('Lengths and pace: coming soon'),
          Text('Lap counting arrives in a later update. Heart rate isn\'t recorded in the water.', style: AlviType.bodySmall(context)),
        ],
      ],
    );
  }
}
