import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../widgets/widgets.dart';
import 'templates.dart';

/// Cycle (QWatch Pro "Menstrual Cycle"). Phase shown by label and pattern, not colour alone.
class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});
  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  int cycleLength = 28, periodLength = 5, lastStart = 3; // sample settings: last period began on day 3
  int monthOffset = 0;

  String phaseFor(int day) {
    final d = (day - lastStart) % cycleLength;
    if (d >= 0 && d < periodLength) return 'period';
    if (d >= 9 && d <= 15) return 'fertile';
    return 'other';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final now = DateTime.now();
    final month = DateTime(now.year, now.month + monthOffset);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final lead = DateTime(month.year, month.month, 1).weekday % 7; // Sunday first
    final todayPhase = phaseFor(now.day);
    const names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return AlviPage(
      label: 'Cycle',
      sample: true,
      trailing: BarText('Settings', onTap: () async {
        final v = await pickNumber(context, title: 'Cycle length', value: cycleLength.toDouble(), step: 1, min: 21, max: 40, unit: 'days');
        if (v != null) setState(() => cycleLength = v.round());
      }),
      children: [
        Text(todayPhase == 'period' ? 'Period, day ${(now.day - lastStart) % cycleLength + 1}.' : (todayPhase == 'fertile' ? 'Likely fertile window.' : 'Between phases.'),
            style: AlviType.headline(context, size: 28)),
        const SizedBox(height: 8),
        Text('Predictions improve as you log periods and Helium learns your skin temperature.', style: AlviType.bodySmall(context)),
        const SizedBox(height: 16),
        Row(children: [
          IconButton(tooltip: 'Previous month', onPressed: () => setState(() => monthOffset--), icon: Icon(Icons.chevron_left, color: c.ink)),
          Expanded(child: Text('${names[month.month - 1]} ${month.year}'.toUpperCase(), textAlign: TextAlign.center, style: AlviType.label(context, color: c.ink))),
          IconButton(tooltip: 'Next month', onPressed: () => setState(() => monthOffset++), icon: Icon(Icons.chevron_right, color: c.ink)),
        ]),
        Row(children: [for (final d in ['S', 'M', 'T', 'W', 'T', 'F', 'S']) Expanded(child: Text(d, textAlign: TextAlign.center, style: AlviType.label(context)))]),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < lead; i++) const SizedBox.shrink(),
            for (var d = 1; d <= days; d++) _DayCell(day: d, phase: phaseFor(d), today: monthOffset == 0 && d == now.day),
          ],
        ),
        const SizedBox(height: 16),
        Row(children: [
          const _Legend(kind: 'period', text: 'Period'),
          const SizedBox(width: 16),
          const _Legend(kind: 'fertile', text: 'Fertile window'),
          const SizedBox(width: 16),
          Text('Ring = today', style: AlviType.fine(context)),
        ]),
        const SizedBox(height: 16),
        NavRow('Period length', value: '$periodLength days', onTap: () async {
          final v = await pickNumber(context, title: 'Period length', value: periodLength.toDouble(), step: 1, min: 2, max: 10, unit: 'days');
          if (v != null) setState(() => periodLength = v.round());
        }),
        NavRow('Log period start', onTap: () => setState(() => lastStart = now.day)),
        const Disclaimer('Predictions are estimates for wellness, not contraception or diagnosis.'),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.phase, required this.today});
  final int day;
  final String phase;
  final bool today;
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Semantics(
      label: 'Day $day${phase == 'period' ? ', period' : phase == 'fertile' ? ', fertile window' : ''}${today ? ', today' : ''}',
      child: ExcludeSemantics(
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: phase == 'period' ? c.heart : null,
              border: today ? Border.all(color: c.ink, width: 2) : (phase == 'fertile' ? Border.all(color: c.readiness, width: 1.5) : null),
            ),
            child: Text('$day', style: AlviType.bodySmall(context, color: phase == 'period' ? c.surface : c.ink)),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.kind, required this.text});
  final String kind, text;
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Row(children: [
      Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: kind == 'period' ? c.heart : null, border: kind == 'fertile' ? Border.all(color: c.readiness, width: 1.5) : null)),
      const SizedBox(width: 6),
      Text(text, style: AlviType.fine(context)),
    ]);
  }
}

/// Body goal (QWatch Pro "AI Body Reshaping").
class BodyGoalScreen extends StatelessWidget {
  const BodyGoalScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(
        label: 'Body goal',
        footer: [
          PrimaryButton('Set a body goal', onPressed: () => Navigator.pushNamed(context, '/body/goal/new')),
          AlviLink('Progress calendar', onTap: () => Navigator.pushNamed(context, '/body/goal/progress')),
        ],
        children: [
          const SizedBox(height: 24),
          EmptyState(title: 'No body goal yet.', body: 'Set a fat-loss or muscle-gain goal. ALVI shapes your plan around it.', icon: Icons.accessibility_new),
          AlviCard(child: Text('Goal previews are generated by an ALVI service that is not connected in this build. Three previews per month.', style: AlviType.bodySmall(context))),
        ],
      );
}

class NewBodyGoalScreen extends StatefulWidget {
  const NewBodyGoalScreen({super.key});
  @override
  State<NewBodyGoalScreen> createState() => _NewBodyGoalScreenState();
}

class _NewBodyGoalScreenState extends State<NewBodyGoalScreen> {
  String kind = 'Fat loss';
  double target = 5;
  double months = 3;
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return AlviPage(
      label: 'New body goal',
      footer: [
        PrimaryButton('Create goal', onPressed: () {
          toast(context, 'Goal saved. Preview generation needs the ALVI service.');
          Navigator.pop(context);
        }),
      ],
      children: [
        const SectionLabel('1 · Photo (optional)', top: 0),
        Text('Fitted clothing, plain evenly lit background, facing the camera. The photo stays on your phone.', style: AlviType.bodySmall(context)),
        const SizedBox(height: 12),
        Semantics(
          button: true,
          label: 'Add photo',
          child: InkWell(
            onTap: () => toast(context, 'Camera or photo picker opens here'),
            child: Container(
              height: 140,
              decoration: BoxDecoration(border: Border.all(color: c.borderControl), borderRadius: BorderRadius.circular(Radii.card)),
              child: Center(child: Icon(Icons.add_a_photo_outlined, color: c.ink)),
            ),
          ),
        ),
        const SectionLabel('2 · Goal'),
        Row(children: [
          for (final k in ['Fat loss', 'Muscle gain']) Padding(padding: const EdgeInsets.only(right: 8), child: AlviChip(k, selected: kind == k, onTap: () => setState(() => kind = k))),
        ]),
        NavRow(kind == 'Fat loss' ? 'Weight to lose' : 'Weight to gain', value: '${target.toStringAsFixed(1)} kg', onTap: () async {
          final v = await pickNumber(context, title: 'Target', value: target, step: 0.5, min: 0.5, max: 30, unit: 'kg');
          if (v != null) setState(() => target = v);
        }),
        NavRow('Time to reach it', value: '${months.round()} months', onTap: () async {
          final v = await pickNumber(context, title: 'Months', value: months, step: 1, min: 1, max: 12, unit: 'months');
          if (v != null) setState(() => months = v);
        }),
        const SectionLabel('Uses your profile'),
        Text('Height, weight, age and gender come from Profile.', style: AlviType.fine(context)),
        const Disclaimer('Aim for gradual change. Check with a professional before big changes to diet or training.'),
      ],
    );
  }
}

class GoalProgressScreen extends StatelessWidget {
  const GoalProgressScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final now = DateTime.now();
    final days = DateTime(now.year, now.month + 1, 0).day;
    final lead = DateTime(now.year, now.month, 1).weekday % 7;
    return AlviPage(label: 'Goal progress', sample: true, children: [
      const Headline('Days on plan.', sub: 'A filled day means you met your plan.'),
      const SizedBox(height: 16),
      Row(children: [for (final d in ['S', 'M', 'T', 'W', 'T', 'F', 'S']) Expanded(child: Text(d, textAlign: TextAlign.center, style: AlviType.label(context)))]),
      GridView.count(crossAxisCount: 7, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: [
        for (var i = 0; i < lead; i++) const SizedBox.shrink(),
        for (var d = 1; d <= days; d++)
          Center(
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: d < now.day && d % 3 != 0 ? c.activity : null, border: Border.all(color: c.divider)),
              child: Text('$d', style: AlviType.bodySmall(context, color: d < now.day && d % 3 != 0 ? c.surface : c.ink)),
            ),
          ),
      ]),
    ]);
  }
}

/// UV exposure (QWatch Pro "Ultraviolet"), capability-gated.
class UvScreen extends StatelessWidget {
  const UvScreen({super.key});
  @override
  Widget build(BuildContext context) => const CapabilityGate(
        capability: 'uv',
        featureName: 'UV exposure',
        child: MetricScreen(MetricConfig(
          label: 'UV exposure',
          numeral: ['3', 'moderate'],
          insight: 'Moderate around midday. Shade and sunscreen if you are out long.',
          toggleKey: 'monitor.uv',
          toggleTitle: 'Timed UV readings',
          toggleBody: 'Every 30 minutes in daylight.',
          series: [0, 0, 1, 2, 3, 4, 3, 2, 1, 0],
          tone: 'caution',
          rangeLabel: '0 — 4',
          stats: [('Average', '1.6'), ('Lowest', '0'), ('Highest', '4')],
          distribution: [('Low 0–2', '62%', 0.62, 'good'), ('Moderate 3–5', '38%', 0.38, 'caution'), ('High 6–7', '0%', 0.0, 'alert'), ('Very high 8+', '0%', 0.0, 'alert')],
        )),
      );
}
