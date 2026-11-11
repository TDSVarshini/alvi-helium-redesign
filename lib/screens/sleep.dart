import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'home_shell.dart';

/// Sleep tab (QWatch Pro "Data — Sleep"): night, stages, totals, percentages, trends.
class SleepTab extends StatefulWidget {
  const SleepTab({super.key});
  @override
  State<SleepTab> createState() => _SleepTabState();
}

class _SleepTabState extends State<SleepTab> {
  String period = 'Day';

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return TabPage(
      header: app.connected ? null : const DeviceStateBanner(),
      children: [
        Row(children: [
          const Expanded(child: CapsLabel('Last night')),
          Text(Sample.sleepWindow, style: AlviType.data(context, size: 11)),
        ]),
        const SizedBox(height: 12),
        const SampleNotice(),
        AlviSegmented(options: const ['Day', 'Week', 'Month'], selected: period, onChanged: (v) => setState(() => period = v)),
        if (period != 'Day') DateStepper(period: period),
        const SizedBox(height: 16),
        if (period == 'Day') ..._night(context) else ..._trend(context),
        const SectionLabel('How Helium reads sleep'),
        Text('The band reads movement, heart rate and HRV through the night to estimate when you slept and which stage you were in. Stages are estimates, not a clinical sleep study.',
            style: AlviType.bodySmall(context)),
        const Disclaimer('General wellness guidance, not medical advice.'),
      ],
    );
  }

  List<Widget> _night(BuildContext context) => [
        const DisplayNumeral(['${Sample.sleepHours}', 'h', '${Sample.sleepMinutes}', 'm'], size: 88),
        const SizedBox(height: 12),
        Text(Sample.sleepHeadline, style: AlviType.headline(context, size: 24)),
        const SizedBox(height: 6),
        Text(Sample.sleepInsight, style: AlviType.bodySmall(context)),
        const SizedBox(height: 24),
        const StageChart(segments: Sample.sleepSegments),
        const SizedBox(height: 16),
        const StatGrid([
          StatCell('Score', '${Sample.sleepScore}'),
          StatCell('Deep', Sample.sleepDeep),
          StatCell('REM', Sample.sleepRem),
          StatCell('Light', Sample.sleepLight),
          StatCell('Awake', Sample.sleepAwake),
          StatCell('Deep share', '21', unit: '%'),
        ]),
        const SectionLabel('Against your reference'),
        LabelledBars(rows: [
          ('Total', '7:42 / 6–10 h', 0.77, context.alvi.sleep),
          ('Deep', '21% / 20–60%', 0.21, context.alvi.sleep),
          ('Light', '52% / <55%', 0.52, context.alvi.sleepRem),
          ('Continuity', '88 / 70–100', 0.88, context.alvi.readiness),
        ]),
        NavRow('Silent alarm', value: context.app.values['silentAlarm'], mono: true, onTap: () => Navigator.pushNamed(context, '/device/haptics')),
      ];

  List<Widget> _trend(BuildContext context) {
    final values = period == 'Week' ? Sample.sleepWeek : [for (var i = 0; i < 30; i++) 6.2 + (i * 3 % 20) / 10];
    final avg = values.reduce((a, b) => a + b) / values.length;
    return [
      DisplayNumeral(['${avg.floor()}', 'h', '${((avg - avg.floor()) * 60).round()}', 'm avg'], size: 72),
      const SizedBox(height: 24),
      BarsView(
        values: values,
        labels: period == 'Week' ? Sample.weekDays : [for (var i = 1; i <= 30; i++) i % 5 == 0 ? '$i' : ''],
        colors: [context.alvi.sleep],
        height: 140,
      ),
      const SizedBox(height: 16),
      StatGrid(const [StatCell('Bedtime', '22:51'), StatCell('Wake', '06:47'), StatCell('Score', '81')]),
    ];
  }
}
