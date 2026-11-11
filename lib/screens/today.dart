import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'home_shell.dart';
import 'templates.dart';

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 18) return 'Good afternoon';
  return 'Good evening';
}

const _days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
const _months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];

/// Today (QWatch Pro "Data — Home").
class TodayTab extends StatelessWidget {
  const TodayTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    final now = DateTime.now();
    final battery = app.wearable.band?.batteryPercent;
    return TabPage(
      header: app.connected ? null : const DeviceStateBanner(),
      children: [
        Row(children: [
          Expanded(child: CapsLabel('${_days[now.weekday - 1]} · ${now.day} ${_months[now.month - 1]}')),
          if (battery != null)
            Semantics(
              button: true,
              label: 'Band battery $battery percent',
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/device'),
                child: Row(children: [
                  Icon(Icons.battery_5_bar, size: 16, color: c.ink),
                  const SizedBox(width: 4),
                  Text('$battery%', style: AlviType.data(context, size: 11)),
                ]),
              ),
            ),
          IconButton(tooltip: 'Edit Today', icon: Icon(Icons.tune, size: 20, color: c.inkMuted), onPressed: () => Navigator.pushNamed(context, '/today/edit')),
        ]),
        const SampleNotice(),
        Text('${_greeting()}, ${app.nickname}.', textAlign: TextAlign.center, style: AlviType.headline(context, size: 28)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.wb_sunny_outlined, size: 16, color: c.tempWeather),
          const SizedBox(width: 6),
          Text(Sample.weather, style: AlviType.bodySmall(context)),
        ]),
        Text(Sample.weatherLine, textAlign: TextAlign.center, style: AlviType.fine(context)),
        for (final card in app.todayCards.where((c) => c.enabled)) _card(context, card.id),
        const SizedBox(height: Space.s24),
        _CoachingEntry(),
      ],
    );
  }

  Widget _card(BuildContext context, String id) {
    final c = context.alvi;
    switch (id) {
      case 'readiness':
        return Column(children: [
          const SizedBox(height: Space.s24),
          Center(
            child: RingView(
              progress: Sample.readiness / 100,
              color: c.readiness,
              size: 220,
              semanticLabel: 'Readiness ${Sample.readiness}',
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CapsLabel('Readiness'),
                Text('${Sample.readiness}', style: AlviType.display(context, size: 80)),
                AlviLink('See why', onTap: () => Navigator.pushNamed(context, '/today/readiness')),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          StatusWord(Sample.readinessWord, color: c.readiness, center: true),
          const SizedBox(height: 8),
          Text(Sample.readinessInsight, textAlign: TextAlign.center, style: AlviType.insight(context)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            AlviLink('Your plan', onTap: () => Navigator.pushNamed(context, '/plan')),
            const SizedBox(width: 20),
            AlviLink('Ask ALVI', onTap: () => Navigator.pushNamed(context, '/assistant/ask')),
          ]),
          const SizedBox(height: 16),
          StatGrid(const [
            StatCell('Sleep', '7:42', size: 22),
            StatCell('HRV', '62', size: 22),
            StatCell('Steps', '5.6k', size: 22),
            StatCell('Skin', '+0.2°', size: 22),
          ], columns: 4),
        ]);
      case 'sleep':
        return _SummaryRow(label: 'Last night', value: '7 h 42 m', detail: Sample.sleepHeadline, route: '/sleep-tab', color: c.sleep);
      case 'heart':
        return _SummaryRow(label: 'Heart', value: '${Sample.heartNow} bpm', detail: 'Resting ${Sample.restingHr} · HRV ${Sample.hrv} ms', route: '/heart-tab', color: c.heart);
      case 'activity':
        return _SummaryRow(label: 'Activity', value: '5,620 steps', detail: Sample.activityInsight, route: '/activity/steps', color: c.activity);
      case 'workouts':
        return _SummaryRow(label: 'Workouts', value: 'Run · 8.2 km', detail: 'Yesterday, 42:10', route: '/activity/workouts', color: c.activity);
      case 'outdoor':
        return _SummaryRow(label: 'Outdoor run', value: '0.00 km today', detail: 'Uses your phone\'s GPS', route: '/activity/outdoor', color: c.activity);
    }
    return const SizedBox.shrink();
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, required this.detail, required this.route, required this.color});
  final String label, value, detail, route;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Semantics(
      button: true,
      label: '$label, $value. $detail',
      child: InkWell(
        onTap: () {
          if (route == '/sleep-tab') return _goTab(context, 1);
          if (route == '/heart-tab') return _goTab(context, 2);
          Navigator.pushNamed(context, route);
        },
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.divider))),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CapsLabel(label),
                  const SizedBox(height: 4),
                  Text(value, style: AlviType.stat(context, size: 22)),
                  Text(detail, style: AlviType.fine(context)),
                ]),
              ),
              Icon(Icons.chevron_right, color: c.inkMuted, size: 20),
            ]),
          ),
        ),
      ),
    );
  }

  void _goTab(BuildContext context, int i) =>
      Navigator.pushNamedAndRemoveUntil(context, i == 1 ? '/sleep' : '/heart', (_) => false);
}

class _CoachingEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviCard(
      onTap: () => Navigator.pushNamed(context, '/assistant/coaching'),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CapsLabel(app.coachingTrial ? 'ALVI Intelligence · ${app.coachingDaysLeft} days left in trial' : 'ALVI Intelligence · locked'),
            const SizedBox(height: 6),
            Text('Push a little today. Rest well tonight.', style: AlviType.body(context, weight: FontWeight.w600)),
          ]),
        ),
        Icon(app.coachingTrial ? Icons.chevron_right : Icons.lock_outline, color: context.alvi.inkMuted),
      ]),
    );
  }
}

/// Edit Today (QWatch Pro "Edit card"): drag to reorder, toggle each card.
class EditTodayScreen extends StatelessWidget {
  const EditTodayScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    return AlviPage(label: 'Edit Today', scroll: false, children: [
      const Headline('Choose what Today shows.', sub: 'Drag the handle to change the order.'),
      const SizedBox(height: 16),
      Expanded(
        child: ReorderableListView(
          buildDefaultDragHandles: false,
          onReorder: app.reorderCards,
          children: [
            for (var i = 0; i < app.todayCards.length; i++)
              Container(
                key: ValueKey(app.todayCards[i].id),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.divider))),
                child: Row(children: [
                  ReorderableDragStartListener(
                    index: i,
                    child: Semantics(
                        label: 'Reorder ${app.todayCards[i].title}',
                        child: SizedBox(width: 44, height: 64, child: Icon(Icons.drag_handle, color: c.inkMuted))),
                  ),
                  Expanded(child: Text(app.todayCards[i].title, style: AlviType.body(context))),
                  AlviSwitch(
                    value: app.todayCards[i].enabled,
                    label: app.todayCards[i].title,
                    onChanged: (v) => app.update(() => app.todayCards[i].enabled = v),
                  ),
                ]),
              ),
          ],
        ),
      ),
    ]);
  }
}

/// Readiness (QWatch Pro "Energy Score"): score, what shaped it, energy through the day, last 7 days.
class ReadinessScreen extends StatelessWidget {
  const ReadinessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return AlviPage(
      label: 'Readiness',
      sample: true,
      trailing: BarIcon(icon: Icons.info_outline, label: 'About readiness', onTap: () => Navigator.pushNamed(context, '/today/readiness/about')),
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${Sample.readiness}', style: AlviType.display(context, size: 96)),
          const Spacer(),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(Sample.readinessDelta, style: AlviType.data(context, size: 11))),
        ]),
        const SizedBox(height: 12),
        Text(Sample.readinessLong, style: AlviType.insight(context)),
        const SectionLabel('What shaped it'),
        for (final k in Sample.contributors) ContributorBar(name: k.name, word: k.word, value: k.value, color: toneColor(context, k.tone)),
        const SizedBox(height: 24),
        LineChartView(values: Sample.energyByHour, color: c.readiness, title: 'ENERGY THROUGH THE DAY', xLabels: const ['06:00', '12:00', 'NOW'], meanBand: false),
        const SizedBox(height: 8),
        StatGrid(const [StatCell('Charged', Sample.energyCharged, size: 22), StatCell('Used', Sample.energyConsumed, size: 22), StatCell('Morning', '78', size: 22)]),
        NavRow('Hourly data', onTap: () => Navigator.pushNamed(context, '/today/readiness/data')),
        NavRow('Week and month', onTap: () => Navigator.pushNamed(context, '/today/readiness/trends')),
        const SizedBox(height: 24),
        BarsView(
          title: 'Last 7 days',
          values: Sample.readinessWeek,
          labels: Sample.weekDays,
          colors: [for (final t in Sample.readinessWeekTone) toneColor(context, t)],
        ),
        const Disclaimer('Readiness is general wellness guidance, not medical advice.'),
      ],
    );
  }
}

class ReadinessAboutScreen extends StatelessWidget {
  const ReadinessAboutScreen({super.key});
  @override
  Widget build(BuildContext context) => const ArticleBody(label: 'About readiness', headline: 'How ready you are for effort.', sections: [
        ('What it is', 'Readiness is a 0–100 read of how recovered you are, from last night\'s sleep, HRV, resting heart rate, recent training and skin temperature.'),
        ('How to raise it', 'Wear Helium to sleep. Keep a steady bedtime. Deep sleep and naps recharge you; long, intense effort and stress draw it down. Caffeine does not change it directly.'),
        ('Charge and use', 'Sleep and rest add to your energy through the day. Activity, sustained high heart rate and stress use it. When the band is off your wrist, ALVI pauses the estimate rather than guessing.'),
        ('Reading the number', '70 and above: a good day for hard training. 30 to 70: moderate effort suits you. Below 30: rest, or keep it light.'),
        ('Morning readiness', 'Your score when you wake, after the night\'s recovery. It sets the tone for your plan.'),
      ]);
}


/// Readiness data (QWatch Pro "Energy Score – More Data").
class ReadinessDataScreen extends StatelessWidget {
  const ReadinessDataScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final values = Sample.energyByHour;
    return AlviPage(label: 'Readiness data', sample: true, trailing: BarIcon(icon: Icons.sync, label: 'Sync now', onTap: () => context.appRead.wearable.sync()), children: [
      const DateStepper(),
      for (var i = values.length - 1; i >= 0; i--)
        NavRow('${(6 + i).toString().padLeft(2, '0')}:00', value: '${values[i]}', mono: true, chevron: false),
    ]);
  }
}

/// Readiness trends (QWatch Pro "Energy Score – Week/Month").
class ReadinessTrendsScreen extends StatefulWidget {
  const ReadinessTrendsScreen({super.key});
  @override
  State<ReadinessTrendsScreen> createState() => _ReadinessTrendsScreenState();
}

class _ReadinessTrendsScreenState extends State<ReadinessTrendsScreen> {
  String period = 'Week';
  @override
  Widget build(BuildContext context) {
    final month = [for (var i = 0; i < 30; i++) 55 + (i * 7) % 30];
    final values = period == 'Week' ? Sample.readinessWeek : month;
    final avg = (values.reduce((a, b) => a + b) / values.length).round();
    return AlviPage(label: 'Readiness trends', sample: true, children: [
      AlviSegmented(options: const ['Week', 'Month'], selected: period, onChanged: (v) => setState(() => period = v)),
      DateStepper(period: period),
      DisplayNumeral(['$avg', 'avg'], size: 72),
      const SizedBox(height: 24),
      BarsView(
        values: values,
        labels: period == 'Week' ? Sample.weekDays : [for (var i = 1; i <= 30; i++) i % 5 == 0 ? '$i' : ''],
        colors: [for (final v in values) toneColor(context, v >= 70 ? 'good' : 'caution')],
        height: 140,
      ),
      const SizedBox(height: 16),
      StatGrid([StatCell('Highest', '${values.reduce((a, b) => a > b ? a : b)}'), StatCell('Lowest', '${values.reduce((a, b) => a < b ? a : b)}'), StatCell('Days 70+', '${values.where((v) => v >= 70).length}')]),
    ]);
  }
}

/// Your plan (ALVI daily plan).
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    final done = app.plan.where((p) => p.done).length;
    return AlviPage(
      label: 'Your plan',
      sample: true,
      trailing: Padding(padding: const EdgeInsets.only(right: 12), child: Text('$done OF ${app.plan.length}', style: AlviType.data(context, size: 11))),
      footer: [
        Text('COACHING TRIAL · ${app.coachingDaysLeft} DAYS LEFT', style: AlviType.data(context, size: 11)),
        const SizedBox(height: 4),
        Text('General wellness guidance, not medical advice. Check with a professional before big changes to your training.', style: AlviType.fine(context)),
        const SizedBox(height: 16),
        PrimaryButton('Start the workout', onPressed: () => Navigator.pushNamed(context, '/activity/start')),
      ],
      children: [
        const Headline('Today, at a steady pace.', sub: 'Shaped by readiness 78 and 7h 42m of sleep. It updates as your day changes.'),
        const SizedBox(height: 8),
        for (final p in app.plan)
          Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.divider))),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: toneColor(context, p.tone))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.title, style: AlviType.body(context)),
                  Text(p.detail, style: AlviType.fine(context)),
                ]),
              ),
              Text(p.amount, style: AlviType.data(context, size: 11)),
              const SizedBox(width: 8),
              Semantics(
                checked: p.done,
                label: 'Mark ${p.title} done',
                child: InkResponse(
                  onTap: () => app.update(() => p.done = !p.done),
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: p.done ? c.ink : null, border: Border.all(color: p.done ? c.ink : c.borderControl)),
                    child: p.done ? Icon(Icons.check, size: 16, color: c.surface) : null,
                  ),
                ),
              ),
            ]),
          ),
        NavRow('Why this plan', onTap: () => Navigator.pushNamed(context, '/assistant/coaching')),
      ],
    );
  }
}
