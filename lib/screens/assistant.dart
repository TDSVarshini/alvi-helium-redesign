import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';

/// Ask ALVI (ALVI p7). Answers here are canned sample responses; the assistant service is not connected.
class AskAlviScreen extends StatefulWidget {
  const AskAlviScreen({super.key});
  @override
  State<AskAlviScreen> createState() => _AskAlviScreenState();
}

class _AskAlviScreenState extends State<AskAlviScreen> {
  final input = TextEditingController();
  static const canned = {
    'What should I do today?':
        'Readiness is 78 and you slept 7h 42m, so effort should feel easier today.\n\nA moderate 40-minute workout suits you, then ten minutes of stretching. You have about 4,400 steps left to reach 10,000.',
    'Why is my readiness 78?': 'Your HRV rose overnight and sleep was good. Recent training load is fair, which held the score back a little.',
    'How was my sleep?': '7h 42m, score 84. Your longest deep sleep this month, mostly before 02:00.',
    'Plan my week': 'Three moderate sessions, one longer easy run at the weekend, and two rest days after your hardest efforts.',
  };

  void _ask(String q) {
    final app = context.appRead;
    app.update(() {
      app.chat.add('Q:$q');
      app.chat.add('A:${canned[q] ?? 'The assistant service is not connected in this build. Sample answers cover the suggested questions.'}');
    });
    input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    return AlviPage(
      label: 'Ask ALVI',
      sample: true,
      trailing: BarIcon(icon: Icons.settings_outlined, label: 'Ask ALVI settings', onTap: () => Navigator.pushNamed(context, '/assistant/settings')),
      footer: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final q in canned.keys.where((q) => !app.chat.contains('Q:$q')).take(3)) AlviChip(q, selected: false, onTap: () => _ask(q)),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Radii.pill), border: Border.all(color: c.borderControl)),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: input,
                style: AlviType.body(context),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) _ask(v.trim());
                },
                decoration: InputDecoration(border: InputBorder.none, hintText: 'Ask about your data', hintStyle: AlviType.body(context, color: c.inkMuted)),
              ),
            ),
            CircleIconButton(icon: Icons.arrow_upward, label: 'Send', filled: true, onTap: () {
              if (input.text.trim().isNotEmpty) _ask(input.text.trim());
            }),
          ]),
        ),
        const SizedBox(height: 8),
        Text('Answers use only the data you have allowed. General wellness, not medical advice.', textAlign: TextAlign.center, style: AlviType.fine(context)),
      ],
      children: [
        if (app.chat.isEmpty) const Headline('Ask about your sleep, readiness or training.'),
        for (final m in app.chat)
          m.startsWith('Q:')
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 8, left: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: c.surfaceRaised, borderRadius: BorderRadius.circular(20)),
                    child: Text(m.substring(2), style: AlviType.body(context)),
                  ),
                )
              : Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(m.substring(2), style: AlviType.insight(context))),
        if (app.chat.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('BASED ON SLEEP, HRV AND RECENT ACTIVITY', style: AlviType.label(context)),
          AlviLink('See your plan', center: false, onTap: () => Navigator.pushNamed(context, '/plan')),
        ],
      ],
    );
  }
}

/// ALVI Intelligence coaching (ALVI p7). Locked state when the trial ends.
class CoachingScreen extends StatelessWidget {
  const CoachingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    if (!app.coachingTrial) {
      return AlviPage(label: 'ALVI Intelligence', footer: [
        PrimaryButton('Continue coaching · [PRICE]', onPressed: () => toast(context, 'Purchase flow opens here')),
        AlviLink('Restore purchase', onTap: () => toast(context, 'Restore opens here')),
      ], children: const [
        SizedBox(height: 48),
        EmptyState(title: 'Your trial has ended.', body: 'Today, sleep and heart stay free. Coaching shapes a plan around them each morning.', icon: Icons.lock_outline),
      ]);
    }
    return AlviPage(
      label: 'ALVI Intelligence',
      sample: true,
      footer: [
        Text('COACHING TRIAL · ${app.coachingDaysLeft} DAYS LEFT', style: AlviType.data(context, size: 11)),
        const SizedBox(height: 4),
        Text('Coaching is general wellness guidance, not medical advice. Check with a professional before big changes to your training.', style: AlviType.fine(context)),
        AlviLink('See your full plan', onTap: () => Navigator.pushNamed(context, '/plan')),
        PrimaryButton('Start the run', onPressed: () => Navigator.pushNamed(context, '/activity/outdoor')),
        AlviLink('Preview locked state', onTap: () => app.update(() => app.coachingTrial = false)),
      ],
      children: const [
        Headline('Push a little today. Rest well tonight.', eyebrow: 'Your plan for today'),
        _CoachItem(1, 'A 40-minute run, mostly zone 3', 'Your HRV rose overnight and your legs had a light weekend. One pulse will tell you when you\'re in.'),
        _CoachItem(2, 'A short walk after lunch', 'You\'ve sat for long stretches this week. Aim for 15 minutes.'),
        _CoachItem(3, 'Lights out by 22:45', 'Your best nights this month started before 23:00. Your silent alarm is set for 06:30–07:00.'),
      ],
    );
  }
}

class _CoachItem extends StatelessWidget {
  const _CoachItem(this.n, this.title, this.body);
  final int n;
  final String title, body;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.alvi.divider))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 30, child: Text(n.toString().padLeft(2, '0'), style: AlviType.data(context, size: 11, color: context.alvi.inkMuted))),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AlviType.body(context, weight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(body, style: AlviType.bodySmall(context)),
            ]),
          ),
        ]),
      );
}

/// Reports (QWatch Pro "AI Analysis History").
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String period = 'Week';
  @override
  Widget build(BuildContext context) => AlviPage(label: 'Reports', sample: period == 'Week', children: [
        AlviSegmented(options: const ['Day', 'Week', 'Month'], selected: period, onChanged: (v) => setState(() => period = v)),
        const SizedBox(height: 16),
        if (period == 'Week')
          NavRow('Week of 3 Nov', subtitle: 'Readiness steady, sleep up 18 min', value: '81', onTap: () => Navigator.pushNamed(context, '/assistant/report'))
        else
          const EmptyState(title: 'No reports yet.', body: 'Reports appear after a full period of wearing Helium.', icon: Icons.description_outlined),
      ]);
}

/// Weekly report (QWatch Pro "AI Health Analysis Report").
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return AlviPage(label: 'Weekly report', sample: true, children: [
      Center(
        child: RingView(
          progress: 0.81,
          color: c.readiness,
          size: 200,
          child: Column(mainAxisSize: MainAxisSize.min, children: [const CapsLabel('Wellness score'), Text('81', style: AlviType.display(context, size: 72))]),
        ),
      ),
      const SizedBox(height: 24),
      Text('A steady week. Sleep improved and readiness held above 70 on five days.', style: AlviType.insight(context)),
      const SectionLabel('What shaped it'),
      ContributorBar(name: 'Sleep', word: 'Better', value: 0.84, color: c.sleep),
      ContributorBar(name: 'Readiness', word: 'Steady', value: 0.72, color: c.readiness),
      ContributorBar(name: 'Activity', word: 'Fair', value: 0.56, color: c.caution),
      const SectionLabel('Next week'),
      const Para('Keep bedtime before 23:00. Add one easy walk on rest days.', muted: true, top: 0),
      const Disclaimer('General wellness guidance, not medical advice.'),
    ]);
  }
}

/// Ask ALVI settings (QWatch Pro "Chat Settings").
class AssistantSettingsScreen extends StatelessWidget {
  const AssistantSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(label: 'Ask ALVI settings', children: [
      NavRow('Clear chat history on this phone', danger: true, onTap: () async {
        if (await confirmAction(context, title: 'Clear chat history?', body: 'Conversations on this phone are deleted.', confirm: 'Clear', destructive: true)) {
          app.update(app.chat.clear);
          if (context.mounted) toast(context, 'Chat history cleared');
        }
      }),
      const NavRow('Data Ask ALVI can use', subtitle: 'Sleep, readiness, heart and activity you have allowed', chevron: false),
    ]);
  }
}
