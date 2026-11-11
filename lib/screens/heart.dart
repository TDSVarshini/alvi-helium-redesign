import 'dart:async';

import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'home_shell.dart';
import 'templates.dart';

/// Heart tab (QWatch Pro "Data — Heart rate"), with entries to every body measure.
class HeartTab extends StatelessWidget {
  const HeartTab({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    final caps = app.caps;
    return TabPage(
      header: app.connected ? null : const DeviceStateBanner(),
      children: [
        Row(children: [
          const Expanded(child: CapsLabel('Heart')),
          Text('MEASURED 2 MIN AGO', style: AlviType.data(context, size: 11)),
        ]),
        const SizedBox(height: 12),
        const SampleNotice(),
        const DisplayNumeral(['${Sample.heartNow}', 'bpm'], size: 88),
        const SizedBox(height: 12),
        Text(Sample.heartInsight, style: AlviType.insight(context)),
        const SizedBox(height: 24),
        LineChartView(values: Sample.heartDay, color: c.heart, rangeLabel: Sample.heartRange),
        const SizedBox(height: 16),
        const StatGrid([StatCell('Resting', '${Sample.restingHr}', unit: 'bpm'), StatCell('HRV', '${Sample.hrv}', unit: 'ms')], columns: 2),
        ToggleRow('Continuous heart rate', subtitle: 'Helium measures every 5 minutes in the background.', value: app.toggle('monitor.heartRate'), onChanged: (v) => app.setToggle('monitor.heartRate', v)),
        NavRow('Zone minutes this week', value: '${Sample.zoneMinutesWeek}', onTap: () => Navigator.pushNamed(context, '/heart/zones/about')),
        NavRow('Oxygen and breathing', value: '${Sample.oxygen}%', onTap: () => Navigator.pushNamed(context, '/heart/oxygen')),
        NavRow('Skin temperature', value: Sample.skinTempDelta, onTap: () => Navigator.pushNamed(context, '/heart/temperature')),
        NavRow('HRV', value: '${Sample.hrv} ms', onTap: () => Navigator.pushNamed(context, '/heart/hrv')),
        NavRow('Stress', value: 'Low', onTap: () => Navigator.pushNamed(context, '/heart/stress')),
        NavRow('Spot check', subtitle: 'Measure now, sitting still', onTap: () => Navigator.pushNamed(context, '/heart/spot-check')),
        const SectionLabel('Other measures'),
        NavRow('ECG', value: caps.ecg ? null : 'Not on Helium', onTap: () => Navigator.pushNamed(context, '/heart/ecg')),
        NavRow('Blood pressure', value: caps.bloodPressure ? null : 'Not on Helium', onTap: () => Navigator.pushNamed(context, '/heart/blood-pressure')),
        NavRow('Glucose', value: caps.glucose ? null : 'Not on Helium', onTap: () => Navigator.pushNamed(context, '/heart/glucose')),
        NavRow('UV exposure', value: caps.uv ? null : 'Not on Helium', onTap: () => Navigator.pushNamed(context, '/body/uv')),
        const Disclaimer('General wellness guidance, not medical advice.'),
      ],
    );
  }
}

class OxygenScreen extends StatelessWidget {
  const OxygenScreen({super.key});
  @override
  Widget build(BuildContext context) => const MetricScreen(MetricConfig(
        label: 'Oxygen and breathing',
        numeral: ['${Sample.oxygen}', '%'],
        insight: 'Steady overnight, within your usual range.',
        toggleKey: 'monitor.oxygen',
        toggleTitle: 'Timed oxygen readings',
        toggleBody: 'Helium measures once an hour while you are still.',
        series: Sample.oxygenDay,
        tone: 'oxygen',
        rangeLabel: '95 — 98',
        stats: [('Average', '97 %'), ('Lowest', '95 %'), ('Highest', '98 %')],
        distribution: [('98% and up', '4 h', 0.33, 'good'), ('95–97%', '7 h 40 m', 0.64, 'oxygen'), ('Below 95%', '20 m', 0.03, 'caution')],
        aboutRoute: '/heart/oxygen/about',
        explainer: ['Oxygen saturation is the share of your blood\'s haemoglobin carrying oxygen. Most healthy adults read 95% or more at rest.'],
      ));
}

class OxygenAboutScreen extends StatelessWidget {
  const OxygenAboutScreen({super.key});
  @override
  Widget build(BuildContext context) => ArticleScreen(
        label: 'About oxygen readings',
        headline: 'Where the numbers come from.',
        illustration: const CoreIllustration(size: 160),
        sections: const [
          ('Source', 'Readings come from spot checks you start and from timed readings Helium takes while you are still.'),
          ('For a clean reading', 'Wear the band snug, sensor against your skin, one finger above the wrist bone. Stay still until it finishes.'),
        ],
      );
}

class GlucoseScreen extends StatelessWidget {
  const GlucoseScreen({super.key});
  @override
  Widget build(BuildContext context) => const CapabilityGate(
        capability: 'glucose',
        featureName: 'Glucose',
        child: MetricScreen(MetricConfig(
          label: 'Glucose (estimate)',
          numeral: ['5.4', 'mmol/L'],
          insight: 'A wellness estimate only. It cannot screen for or manage any condition.',
          series: [5.1, 5.0, 5.3, 6.4, 5.8, 5.4, 5.6, 6.1, 5.5, 5.4],
          tone: 'caution',
          rangeLabel: '5.0 — 6.4',
          stats: [('Average', '5.5'), ('Lowest', '5.0'), ('Highest', '6.4')],
          explainer: ['Glucose is the sugar carried in your blood. Fasting values for most adults sit around 3.9–6.1 mmol/L. Talk to a healthcare professional about any concern.'],
          disclaimer: 'Not intended for medical use. Never use it to make treatment decisions.',
        )),
      );
}

class BloodPressureScreen extends StatelessWidget {
  const BloodPressureScreen({super.key});
  @override
  Widget build(BuildContext context) => const CapabilityGate(
        capability: 'bloodPressure',
        featureName: 'Blood pressure',
        child: MetricScreen(MetricConfig(
          label: 'Blood pressure (estimate)',
          numeral: ['118', '/', '76', 'mmHg'],
          insight: 'Within the usual adult range today.',
          toggleKey: 'monitor.bloodPressure',
          toggleTitle: 'Timed readings',
          toggleBody: 'Helium estimates every hour while you are still.',
          series: [116, 118, 121, 125, 119, 117, 118],
          tone: 'heart',
          rangeLabel: 'SYS 116 — 125',
          stats: [('Systolic', '118'), ('Diastolic', '76'), ('Readings', '7')],
          explainer: [
            'Systolic is the pressure when your heart beats; diastolic is between beats.',
            'Usual adult range: systolic 90–140 mmHg and diastolic 60–90 mmHg.'
          ],
          disclaimer: 'Estimates from a wrist band are not a substitute for a cuff measurement or medical advice.',
        )),
      );
}

class HrvScreen extends StatelessWidget {
  const HrvScreen({super.key});
  @override
  Widget build(BuildContext context) => const MetricScreen(MetricConfig(
        label: 'HRV',
        numeral: ['${Sample.hrv}', 'ms'],
        insight: 'Higher than your weekly average. You recovered well.',
        toggleKey: 'monitor.hrv',
        toggleTitle: 'Scheduled HRV',
        toggleBody: 'Helium measures through the night and at rest.',
        series: Sample.hrvDay,
        tone: 'readiness',
        rangeLabel: '52 — 70',
        stats: [('Average', '59'), ('Lowest', '52'), ('Highest', '70')],
        distribution: [('Low <30', '0%', 0.0, 'caution'), ('Normal 30–60', '58%', 0.58, 'readiness'), ('Good 61–101', '42%', 0.42, 'good')],
        aboutRoute: '/heart/hrv/about',
        periods: true,
      ));
}

class HrvAboutScreen extends StatelessWidget {
  const HrvAboutScreen({super.key});
  @override
  Widget build(BuildContext context) => const ArticleBody(label: 'About HRV', headline: 'The small gaps between beats.', sections: [
        ('What it is', 'Heart-rate variability is how much the time between heartbeats changes. It reflects the balance of your nervous system.'),
        ('How to read it', 'Compare HRV with your own baseline, not with other people. Under stress, heart rate tends to rise and HRV falls. A rising trend usually means you are recovering well.'),
      ]);
}


class StressScreen extends StatelessWidget {
  const StressScreen({super.key});
  @override
  Widget build(BuildContext context) => const MetricScreen(MetricConfig(
        label: 'Stress',
        numeral: ['26', 'low'],
        insight: 'A busy midday, then calm. Most of today was relaxed.',
        toggleKey: 'monitor.stress',
        toggleTitle: 'All-day stress',
        toggleBody: 'Helium estimates every 30 minutes from HRV and heart rate.',
        series: Sample.stressDay,
        tone: 'caution',
        rangeLabel: '15 — 52',
        stats: [('Average', '31'), ('Lowest', '15'), ('Highest', '52')],
        distribution: [('Relaxed 0–29', '62%', 0.62, 'good'), ('Normal 30–59', '34%', 0.34, 'readiness'), ('Medium 60–79', '4%', 0.04, 'caution'), ('High 80–100', '0%', 0.0, 'alert')],
        periods: true,
        explainer: ['When stress looks high, Helium can offer a breathing break with a slow swell on your wrist.'],
      ));
}

class TemperatureScreen extends StatelessWidget {
  const TemperatureScreen({super.key});
  @override
  Widget build(BuildContext context) => const MetricScreen(MetricConfig(
        label: 'Skin temperature',
        numeral: ['+0.2', '°C'],
        insight: 'Close to your baseline. Nothing unusual tonight.',
        series: Sample.tempDay,
        tone: 'caution',
        rangeLabel: '-0.1 — +0.3',
        stats: [('Baseline', '33.9°'), ('Tonight', '34.1°'), ('Nights', '28')],
        distribution: [('Above +0.5', '0 nights', 0.0, 'alert'), ('Within ±0.5', '27 nights', 0.96, 'good'), ('Below -0.5', '1 night', 0.04, 'oxygen')],
        distributionTitle: 'Last 28 nights',
        explainer: ['Helium reads skin temperature, which differs from core body temperature. It shows the change against your own baseline, built over your first seven nights.'],
      ));
}

/// Spot check (QWatch Pro "One Key Measurement").
class SpotCheckScreen extends StatefulWidget {
  const SpotCheckScreen({super.key});
  @override
  State<SpotCheckScreen> createState() => _SpotCheckScreenState();
}

class _SpotCheckScreenState extends State<SpotCheckScreen> {
  StreamSubscription<int>? sub;
  int? bpm;
  int seconds = 0;
  bool measuring = false;

  void _start() {
    final app = context.appRead;
    if (!app.connected) {
      Navigator.pushNamed(context, '/sync-failed');
      return;
    }
    setState(() {
      measuring = true;
      seconds = 0;
      bpm = null;
    });
    sub = app.wearable.measureHeartRate(duration: const Duration(seconds: 15)).listen(
      (v) => setState(() {
        bpm = v;
        seconds++;
      }),
      onDone: () => setState(() => measuring = false),
    );
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlviPage(
        label: 'Spot check',
        sample: true,
        footer: [PrimaryButton(measuring ? 'Measuring… ${15 - seconds}s' : 'Measure now', onPressed: measuring ? null : _start)],
        children: [
          const SizedBox(height: Space.s24),
          Center(
            child: RingView(
              progress: measuring ? seconds / 15 : (bpm == null ? 0 : 1),
              color: context.alvi.heart,
              size: 220,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CapsLabel('Heart rate'),
                Text(bpm?.toString() ?? '—', style: AlviType.display(context, size: 72)),
                const CapsLabel('bpm'),
              ]),
            ),
          ),
          const SizedBox(height: Space.s32),
          Text(measuring ? 'Stay still. Keep your arm relaxed.' : 'Sit still for 15 seconds. Helium reads your heart rate and, when available, oxygen.',
              textAlign: TextAlign.center, style: AlviType.insight(context)),
          const Disclaimer('Results are for reference only and cannot replace a medical diagnosis.'),
        ],
      );
}

class ZonesAboutScreen extends StatelessWidget {
  const ZonesAboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return AlviPage(label: 'Heart-rate zones', children: [
      const Headline('Five zones, from easy to all-out.', sub: 'Zones use 220 minus your age as maximum heart rate. Sample for age 31.'),
      const SizedBox(height: 16),
      LabelledBars(rows: [
        ('Z5 Limit', '171+ bpm', 1.0, c.heart),
        ('Z4 Anaerobic', '152–170', 0.9, c.caution),
        ('Z3 Aerobic', '133–151', 0.8, c.activity),
        ('Z2 Fat burn', '114–132', 0.7, c.oxygen),
        ('Z1 Warm-up', '95–113', 0.6, c.inkMuted),
      ]),
      const SectionLabel('Z1 Warm-up · 50–60%'),
      const Para('Loosens body and mind before effort. Brisk walking.', muted: true, top: 0),
      const SectionLabel('Z2 Fat burn · 60–70%'),
      const Para('Builds base fitness and supports fat use. Easy jogging.', muted: true, top: 0),
      const SectionLabel('Z3 Aerobic · 70–80%'),
      const Para('Improves endurance, lung capacity and breathing rhythm. Steady running.', muted: true, top: 0),
      const SectionLabel('Z4 Anaerobic · 80–90%'),
      const Para('Raises speed. Keep time here controlled. Intervals and tempo runs.', muted: true, top: 0),
      const SectionLabel('Z5 Limit · 90–100%'),
      const Para('Short, explosive efforts only. Lactate builds quickly and injury risk rises.', muted: true, top: 0),
      const Disclaimer('One pulse on your wrist tells you when you enter your target zone.'),
    ]);
  }
}

// ---------------- ECG (capability-gated) ----------------

class EcgScreen extends StatelessWidget {
  const EcgScreen({super.key});
  @override
  Widget build(BuildContext context) => CapabilityGate(
        capability: 'ecg',
        featureName: 'ECG',
        child: AlviPage(
          label: 'ECG',
          sample: true,
          trailing: BarIcon(icon: Icons.help_outline, label: 'About ECG', onTap: () => Navigator.pushNamed(context, '/heart/ecg/about')),
          footer: [PrimaryButton('Start a 30-second ECG', onPressed: () => Navigator.pushNamed(context, '/heart/ecg/record'))],
          children: [
            const DisplayNumeral(['--', 'bpm'], size: 72),
            Row(children: [
              Text('QTC -- MS', style: AlviType.data(context, size: 11)),
              const SizedBox(width: 24),
              Text('HRV -- MS', style: AlviType.data(context, size: 11)),
            ]),
            const SizedBox(height: 16),
            const EcgTrace(flat: true),
            const SectionLabel('Latest record'),
            NavRow('Sinus rhythm', subtitle: 'Mon 13 Oct · 08:14 · sample', value: '62 bpm', onTap: () => Navigator.pushNamed(context, '/heart/ecg/record')),
            NavRow('All records', onTap: () => Navigator.pushNamed(context, '/heart/ecg/all')),
            NavRow('How to take an ECG', onTap: () => Navigator.pushNamed(context, '/heart/ecg/how')),
            NavRow('Analysis', onTap: () => Navigator.pushNamed(context, '/heart/ecg/risk')),
          ],
        ),
      );
}

class EcgRecordScreen extends StatelessWidget {
  const EcgRecordScreen({super.key});
  @override
  Widget build(BuildContext context) => CapabilityGate(
        capability: 'ecg',
        featureName: 'ECG',
        child: AlviPage(
          label: 'ECG record',
          sample: true,
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            BarIcon(icon: Icons.ios_share, label: 'Share', onTap: () => toast(context, 'Export prepared (sample)')),
            BarIcon(
                icon: Icons.delete_outline,
                label: 'Delete',
                onTap: () async {
                  if (await confirmAction(context, title: 'Delete this record?', body: 'It is removed from this phone and your account.', confirm: 'Delete', destructive: true)) {
                    if (context.mounted) Navigator.pop(context);
                  }
                }),
          ]),
          children: [
            const EcgTrace(),
            const SectionLabel('Heart rate'),
            const StatGrid([StatCell('Average', '62', unit: 'bpm'), StatCell('Highest', '71'), StatCell('Lowest', '56')]),
            const SectionLabel('HRV'),
            const StatGrid([StatCell('HRV', '48', unit: 'ms'), StatCell('SDNN', '51'), StatCell('RMSSD', '33')]),
            const SectionLabel('Reading'),
            StatusWord('Sinus rhythm · regular', color: context.alvi.good),
            const Para('A regular rhythm was recorded. This is not a diagnosis.', muted: true),
            const Disclaimer('ECG on a wellness band cannot detect a heart attack. If you feel unwell, contact emergency services.'),
          ],
        ),
      );
}

class EcgAboutScreen extends StatelessWidget {
  const EcgAboutScreen({super.key});
  @override
  Widget build(BuildContext context) => const CapabilityGate(
        capability: 'ecg',
        featureName: 'ECG',
        child: ArticleBody(label: 'About ECG', headline: 'A 30-second look at your rhythm.', sections: [
          ('What it is', 'An electrocardiogram records the electrical activity of your heart. ALVI shows whether the rhythm looked regular during the recording.'),
          ('How it works', 'Each heartbeat creates a small electrical change that reaches your skin. Touching the electrode closes the circuit so the band can record it.'),
          ('Results', 'Sinus rhythm means the heart beat in a regular pattern. Other results are shown as "irregular" or "inconclusive" and are not diagnoses.'),
        ]),
      );
}

class EcgHowScreen extends StatelessWidget {
  const EcgHowScreen({super.key});
  @override
  Widget build(BuildContext context) => const CapabilityGate(
        capability: 'ecg',
        featureName: 'ECG',
        child: ArticleScreen(
          label: 'How to take an ECG',
          headline: 'Sit, rest your arm, touch the core.',
          illustration: CoreIllustration(size: 150),
          steps: [
            'Rest your arm on a table or your thigh.',
            'Wear the band snug, sensor against your skin.',
            'Rest a finger of the other hand on the core electrode.',
            'Stay still and quiet for 30 seconds. Dry skin? Moisten your fingertip slightly.',
          ],
        ),
      );
}

class EcgAllScreen extends StatefulWidget {
  const EcgAllScreen({super.key});
  @override
  State<EcgAllScreen> createState() => _EcgAllScreenState();
}

class _EcgAllScreenState extends State<EcgAllScreen> {
  String filter = 'All';
  @override
  Widget build(BuildContext context) => CapabilityGate(
        capability: 'ecg',
        featureName: 'ECG',
        child: AlviPage(
          label: 'All ECG records',
          trailing: BarIcon(icon: Icons.calendar_today_outlined, label: 'Pick a date', onTap: () => showDatePicker(context: context, firstDate: DateTime(2024), lastDate: DateTime.now())),
          children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final f in ['All', 'Regular', 'Irregular', 'Inconclusive']) AlviChip(f, selected: filter == f, onTap: () => setState(() => filter = f)),
            ]),
            if (filter == 'All' || filter == 'Regular')
              NavRow('Sinus rhythm', subtitle: 'Mon 13 Oct · 08:14 · sample', value: '62 bpm', onTap: () => Navigator.pushNamed(context, '/heart/ecg/record'))
            else
              const EmptyState(title: 'No records yet.', body: 'Records with this result will appear here.'),
          ],
        ),
      );
}

/// Sign-in gate before analysis (QWatch Pro "ECG Risk Analysis").
class EcgRiskScreen extends StatelessWidget {
  const EcgRiskScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return CapabilityGate(
      capability: 'ecg',
      featureName: 'ECG',
      child: app.signedIn
          ? const ArticleBody(label: 'ECG analysis', headline: 'Your records, read together.', sections: [
              ('Last 30 days', '1 record. Regular rhythm. Not enough records for a trend yet.'),
              ('Reference', 'References use your age from your profile.'),
            ])
          : AlviPage(label: 'ECG analysis', footer: [
              PrimaryButton('Sign in', onPressed: () => Navigator.pushNamed(context, '/account/sign-in')),
              const SizedBox(height: 12),
              SecondaryButton('Cancel', onPressed: () => Navigator.pop(context)),
            ], children: const [
              EmptyState(title: 'Sign in required.', body: 'Sign in and add your birthday before analysis. Age is needed for the reference.', icon: Icons.lock_outline),
            ]),
    );
  }
}
