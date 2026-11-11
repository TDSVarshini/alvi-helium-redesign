import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'home_shell.dart';

/// You tab (QWatch Pro "My — Home").
class YouTab extends StatelessWidget {
  const YouTab({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    final band = app.wearable.band;
    return TabPage(children: [
      const CapsLabel('You'),
      const SizedBox(height: 16),
      if (app.signedIn)
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/you/profile'),
          child: Row(children: [
            CircleAvatar(radius: 28, backgroundColor: c.surfaceRaised, child: Text(app.nickname.characters.first, style: AlviType.headline(context, size: 22))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(app.nickname, style: AlviType.headline(context, size: 24)),
                Text(app.email, style: AlviType.fine(context)),
              ]),
            ),
            Icon(Icons.chevron_right, color: c.inkMuted),
          ]),
        )
      else ...[
        Text('Sign in to keep your data.', style: AlviType.headline(context, size: 24)),
        const SizedBox(height: 8),
        Text('Your baselines, plan and history follow your account to a new phone.', style: AlviType.bodySmall(context)),
        const SizedBox(height: 16),
        PrimaryButton('Sign in or create account', onPressed: () => Navigator.pushNamed(context, '/account/sign-in')),
      ],
      const SectionLabel('Your Helium'),
      NavRow(band == null ? 'Pair your band' : band.name,
          subtitle: band == null ? 'No band paired' : '${app.connected ? 'Connected' : 'Not connected'} · ${band.batteryPercent}%',
          onTap: () => Navigator.pushNamed(context, '/device')),
      NavRow('Haptics', value: app.values['hapticStrength'], onTap: () => Navigator.pushNamed(context, '/device/haptics')),
      NavRow('Keep ALVI connected', subtitle: 'If alerts stop or the band disconnects, check these settings.', onTap: () => Navigator.pushNamed(context, '/you/background')),
      const SectionLabel('Settings'),
      NavRow('Profile', onTap: () => Navigator.pushNamed(context, '/you/profile')),
      NavRow('Goals', onTap: () => Navigator.pushNamed(context, '/you/goals')),
      NavRow('Appearance', value: switch (app.themeMode) { ThemeMode.dark => 'Dark', ThemeMode.light => 'Light', _ => 'System' }, onTap: () => Navigator.pushNamed(context, '/you/appearance')),
      NavRow('Units', value: app.metric ? 'Metric' : 'Imperial', onTap: () => app.update(() => app.metric = !app.metric)),
      NavRow('Time format', value: app.clock24 ? '24-hour' : '12-hour', onTap: () => app.update(() => app.clock24 = !app.clock24)),
      NavRow('Widgets', onTap: () => Navigator.pushNamed(context, '/you/widgets')),
      NavRow('Connected services', onTap: () => Navigator.pushNamed(context, '/you/connections')),
      const SectionLabel('More features'),
      NavRow('Plan and coaching', onTap: () => Navigator.pushNamed(context, '/plan')),
      NavRow('Ask ALVI', onTap: () => Navigator.pushNamed(context, '/assistant/ask')),
      NavRow('All features', subtitle: 'Circle, cycle, body goal, faith, recordings', onTap: () => Navigator.pushNamed(context, '/you/more')),
      const SectionLabel('Help'),
      NavRow('Help and FAQ', onTap: () => Navigator.pushNamed(context, '/you/faq')),
      NavRow('Feedback', onTap: () => Navigator.pushNamed(context, '/you/feedback')),
      NavRow('About', onTap: () => Navigator.pushNamed(context, '/you/about')),
      const SectionLabel('Developer'),
      NavRow('Screen index', subtitle: 'Every QWatch Pro screen and its ALVI redesign', onTap: () => Navigator.pushNamed(context, '/dev/screens')),
      NavRow('Device simulator', subtitle: 'Sample band states and capabilities', onTap: () => Navigator.pushNamed(context, '/dev/device')),
      if (app.signedIn) NavRow('Sign out', danger: true, chevron: false, onTap: app.signOut),
    ]);
  }
}

class MoreFeaturesScreen extends StatelessWidget {
  const MoreFeaturesScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(label: 'All features', children: [
        const SectionLabel('People', top: 0),
        NavRow('Partner', subtitle: 'Send a touch, share your day', onTap: () => Navigator.pushNamed(context, '/circle/partner')),
        NavRow('Family', subtitle: 'Steps together', onTap: () => Navigator.pushNamed(context, '/circle/family')),
        NavRow('My code', onTap: () => Navigator.pushNamed(context, '/circle/my-code')),
        const SectionLabel('Body'),
        NavRow('Cycle', onTap: () => Navigator.pushNamed(context, '/body/cycle')),
        NavRow('Body goal', onTap: () => Navigator.pushNamed(context, '/body/goal')),
        NavRow('UV exposure', onTap: () => Navigator.pushNamed(context, '/body/uv')),
        const SectionLabel('Assistant'),
        NavRow('Weekly reports', onTap: () => Navigator.pushNamed(context, '/assistant/reports')),
        NavRow('Coaching', onTap: () => Navigator.pushNamed(context, '/assistant/coaching')),
        const SectionLabel('Faith'),
        NavRow('Prayer times, Qibla and tasbih', onTap: () => Navigator.pushNamed(context, '/faith')),
        const SectionLabel('Needs band hardware Helium does not have'),
        NavRow('Recordings and minutes', subtitle: 'Microphone', onTap: () => Navigator.pushNamed(context, '/recordings')),
        NavRow('Photos, books, music, faces', subtitle: 'Display', onTap: () => Navigator.pushNamed(context, '/device/media/album')),
        NavRow('Card on band', subtitle: 'Display', onTap: () => Navigator.pushNamed(context, '/device/card')),
        NavRow('Call forwarding', subtitle: 'Cellular', onTap: () => Navigator.pushNamed(context, '/device/call-forwarding')),
      ]);
}

/// Profile (QWatch Pro "User Profile").
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    return AlviPage(label: 'Profile', children: [
      Center(
        child: Semantics(
          button: true,
          label: 'Change photo',
          child: InkWell(
            onTap: () => toast(context, 'Photo picker opens here'),
            child: CircleAvatar(radius: 44, backgroundColor: c.surfaceRaised, child: Text(app.nickname.characters.first, style: AlviType.headline(context, size: 34))),
          ),
        ),
      ),
      const SizedBox(height: 24),
      NavRow('Nickname', value: app.nickname, onTap: () async {
        final v = await askText(context, title: 'Nickname', initial: app.nickname);
        if (v != null && v.isNotEmpty) app.update(() => app.nickname = v);
      }),
      NavRow('Email', value: app.email.isEmpty ? 'Not signed in' : app.email, chevron: false),
      NavRow('Gender', value: app.gender, onTap: () async {
        final v = await pickOption(context, title: 'Gender', options: const ['Female', 'Male', 'Non-binary', 'Prefer not to say'], selected: app.gender);
        if (v != null) app.update(() => app.gender = v);
      }),
      NavRow('Birthday', value: app.birthday, mono: true, onTap: () async {
        final d = await showDatePicker(context: context, firstDate: DateTime(1920), lastDate: DateTime.now(), initialDate: DateTime.tryParse(app.birthday) ?? DateTime(1995));
        if (d != null) app.update(() => app.birthday = d.toIso8601String().substring(0, 10));
      }),
      NavRow('Height', value: '${app.heightCm} cm', onTap: () async {
        final v = await pickNumber(context, title: 'Height', value: app.heightCm.toDouble(), step: 1, min: 100, max: 230, unit: 'cm');
        if (v != null) app.update(() => app.heightCm = v.round());
      }),
      NavRow('Weight', value: '${app.weightKg} kg', onTap: () async {
        final v = await pickNumber(context, title: 'Weight', value: app.weightKg.toDouble(), step: 1, min: 30, max: 250, unit: 'kg');
        if (v != null) app.update(() => app.weightKg = v.round());
      }),
      const SizedBox(height: 24),
      NavRow('Delete account', danger: true, onTap: () async {
        final ok = await confirmAction(context,
            title: 'Delete your account?', body: 'Your profile and synced history are deleted. Data still on the band stays until you reset it.', confirm: 'Delete account', destructive: true);
        if (ok) {
          app.signOut();
          if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        }
      }),
    ]);
  }
}

/// Goals (QWatch Pro "Goal").
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(label: 'Goals', children: [
      const Headline('Your daily goals.', sub: 'Two pulses on your wrist when you reach one.'),
      const SizedBox(height: 16),
      for (final g in app.goals)
        NavRow(g.label, value: g.display, onTap: () async {
          final v = await pickNumber(context, title: g.label, value: g.value, step: g.step, min: g.min, max: g.max, unit: g.unit);
          if (v != null) app.update(() => g.value = v);
        }),
    ]);
  }
}

/// Appearance (QWatch Pro "Theme style").
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(label: 'Appearance', children: [
      const Headline('Dark or light.', sub: 'ALVI uses two quiet themes. Colour is kept for your data.'),
      const SizedBox(height: 16),
      RadioRow('Dark', selected: app.themeMode == ThemeMode.dark, onTap: () => app.setTheme(ThemeMode.dark)),
      RadioRow('Light', selected: app.themeMode == ThemeMode.light, onTap: () => app.setTheme(ThemeMode.light)),
      RadioRow('Match my phone', selected: app.themeMode == ThemeMode.system, onTap: () => app.setTheme(ThemeMode.system)),
    ]);
  }
}

/// Connected services (QWatch Pro "Third-party services").
class ConnectionsScreen extends StatelessWidget {
  const ConnectionsScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(label: 'Connected services', children: [
        const Headline('Share with other apps.', sub: 'You choose what goes out. Nothing is shared until you connect.'),
        const SizedBox(height: 16),
        NavRow('Health Connect / Google Fit', value: 'Not connected', onTap: () => toast(context, 'Opens the system permission screen')),
        NavRow('Strava', value: 'Not connected', onTap: () => Navigator.pushNamed(context, '/you/connections/strava')),
      ]);
}

class StravaScreen extends StatelessWidget {
  const StravaScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(
        label: 'Strava',
        footer: [PrimaryButton('Connect', onPressed: () => toast(context, 'Strava sign-in opens in the browser (not configured in this build)'))],
        children: const [
          Headline('Send workouts to Strava.', sub: 'Once connected, finished workouts sync to your Strava account. Daily wellness data stays in ALVI.'),
        ],
      );
}

/// Help and FAQ (QWatch Pro FAQ web view was blank offline; these are placeholders for approved copy).
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const qa = [
      ('My band will not pair.', 'Charge the core until it pulses, keep your phone within one metre and turn Bluetooth on. See Connection help.'),
      ('Alerts stopped arriving.', 'Your phone may have closed ALVI in the background. Follow Keep ALVI connected.'),
      ('Why is readiness missing?', 'Readiness needs a night of sleep with the band on. Your baselines form over seven nights.'),
      ('How do I start a workout without my phone?', 'Double-tap the core. A tick says got it. Double-tap again to end.'),
      ('Is ALVI a medical device?', 'No. ALVI gives general wellness guidance, not medical advice.'),
    ];
    return AlviPage(label: 'Help and FAQ', children: [
      const Headline('Help.'),
      for (final q in qa)
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            iconColor: context.alvi.ink,
            collapsedIconColor: context.alvi.inkMuted,
            title: Text(q.$1, style: AlviType.body(context)),
            childrenPadding: const EdgeInsets.only(bottom: 16),
            expandedAlignment: Alignment.centerLeft,
            children: [Text(q.$2, style: AlviType.bodySmall(context))],
          ),
        ),
      NavRow('Connection help', onTap: () => Navigator.pushNamed(context, '/pair/trouble')),
      const Disclaimer('Placeholder answers. Final help copy is supplied by ALVI support.'),
    ]);
  }
}

/// Feedback categories (QWatch Pro "problem feedback").
class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});
  @override
  Widget build(BuildContext context) {
    void open(String cat) => Navigator.pushNamed(context, '/you/feedback/new', arguments: cat);
    return AlviPage(label: 'Feedback', children: [
      const Headline('What happened?'),
      const SectionLabel('Ideas'),
      NavRow('Suggestion', onTap: () => open('Suggestion')),
      const SectionLabel('App'),
      for (final s in ['Pairing failed', 'Sync failed', 'Activity looks wrong', 'Sleep looks wrong', 'Heart rate looks wrong', 'Workout problem'])
        NavRow(s, onTap: () => open(s)),
      const SectionLabel('Band'),
      for (final s in ['Silent alarm problem', 'Haptics feel wrong', 'Double-tap not recognised', 'Call alert problem', 'Notification problem'])
        NavRow(s, onTap: () => open(s)),
      const SectionLabel('Hardware'),
      NavRow('Band will not charge', onTap: () => open('Band will not charge')),
    ]);
  }
}

/// Send feedback (QWatch Pro "Submit Feedback").
class FeedbackNewScreen extends StatefulWidget {
  const FeedbackNewScreen({super.key});
  @override
  State<FeedbackNewScreen> createState() => _FeedbackNewScreenState();
}

class _FeedbackNewScreenState extends State<FeedbackNewScreen> {
  final text = TextEditingController();
  final contact = TextEditingController();
  int photos = 0;
  @override
  Widget build(BuildContext context) {
    final cat = ModalRoute.of(context)?.settings.arguments as String? ?? 'Feedback';
    final c = context.alvi;
    return AlviPage(
      label: 'Send feedback',
      footer: [
        PrimaryButton('Send', onPressed: () {
          if (text.text.trim().isEmpty) return toast(context, 'Describe the problem first');
          toast(context, 'Thanks. We read every message.');
          Navigator.pop(context);
        }),
      ],
      children: [
        Headline(cat),
        const SizedBox(height: 16),
        AlviField(label: 'What happened', hint: 'Describe the problem or idea', controller: text, maxLines: 5, maxLength: 200),
        AlviField(label: 'Email for a reply', hint: 'you@example.com', controller: contact, keyboard: TextInputType.emailAddress),
        Row(children: [
          const Expanded(child: CapsLabel('Screenshots')),
          Text('$photos/3', style: AlviType.data(context, size: 11)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          for (var i = 0; i < photos; i++)
            Container(width: 72, height: 72, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: c.surfaceRaised, borderRadius: BorderRadius.circular(Radii.card)), child: Icon(Icons.image_outlined, color: c.inkMuted)),
          if (photos < 3)
            Semantics(
              button: true,
              label: 'Add screenshot',
              child: InkWell(
                onTap: () => setState(() => photos++),
                child: Container(width: 72, height: 72, decoration: BoxDecoration(border: Border.all(color: c.borderControl), borderRadius: BorderRadius.circular(Radii.card)), child: Icon(Icons.add, color: c.ink)),
              ),
            ),
        ]),
        const Disclaimer('Diagnostic logs from the app and band are attached so we can help faster.'),
      ],
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(label: 'About', children: [
        const SizedBox(height: 24),
        const Center(child: CoreIllustration(size: 120, rings: false)),
        const SizedBox(height: 24),
        Center(child: Text('ALVI Helium', style: AlviType.headline(context, size: 26))),
        Center(child: Text('VERSION 0.1.0 · DESIGN SYSTEM V1.2', style: AlviType.data(context, size: 11))),
        const SizedBox(height: 32),
        NavRow('Clear app cache', onTap: () async {
          if (await confirmAction(context, title: 'Clear cache?', body: 'Downloaded charts and images are removed. Your data is not affected.', confirm: 'Clear')) {
            if (context.mounted) toast(context, 'Cache cleared');
          }
        }),
        NavRow('Privacy', onTap: () => Navigator.pushNamed(context, '/you/privacy')),
        NavRow('Open-source licences', onTap: () => showLicensePage(context: context, applicationName: 'ALVI Helium')),
        const Disclaimer('ALVI INTELLECTS INC. · ONTARIO. Wellness guidance only, not medical advice.'),
      ]);
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) => const ArticleBodyLite(label: 'Privacy', headline: 'Your data, your call.', sections: [
        ('What we collect', 'Readings from your band, the profile you enter and the settings you choose.'),
        ('Where it lives', 'On your band until it syncs, then on your phone and, if you sign in, your ALVI account.'),
        ('Sharing', 'Nothing leaves ALVI unless you connect a service or share with someone in Circle.'),
        ('Contact', '[PRIVACY CONTACT PLACEHOLDER] — supplied by ALVI before release.'),
      ]);
}

class ArticleBodyLite extends StatelessWidget {
  const ArticleBodyLite({super.key, required this.label, required this.headline, required this.sections});
  final String label, headline;
  final List<(String, String)> sections;
  @override
  Widget build(BuildContext context) => AlviPage(label: label, children: [
        Headline(headline),
        for (final s in sections) ...[SectionLabel(s.$1), Text(s.$2, style: AlviType.body(context, color: context.alvi.inkBody))],
      ]);
}

/// Keep ALVI connected (QWatch Pro "Background protection guide 1").
class BackgroundScreen extends StatelessWidget {
  const BackgroundScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(
        label: 'Keep ALVI connected',
        footer: [
          PrimaryButton('Check my settings', onPressed: () => Navigator.pushNamed(context, '/you/background/checklist')),
          AlviLink('Guides for my phone', onTap: () => Navigator.pushNamed(context, '/you/background/phones')),
        ],
        children: [
          const Headline('Keep the band and phone talking.', sub: 'Some phones close apps in the background. When ALVI is closed:'),
          const SizedBox(height: 16),
          NavRow('Message alerts stop', subtitle: 'WhatsApp, Messages and other apps you chose', leading: Icon(Icons.notifications_off_outlined, color: context.alvi.caution), chevron: false),
          NavRow('Call alerts stop', subtitle: 'The band no longer taps you for calls', leading: Icon(Icons.phone_disabled_outlined, color: context.alvi.caution), chevron: false),
          NavRow('Sync waits', subtitle: 'Data stays safe on the band until ALVI opens', leading: Icon(Icons.sync_disabled, color: context.alvi.caution), chevron: false),
        ],
      );
}

/// Connection checklist (QWatch Pro "Background protection guide 2").
class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    const items = [
      ('Notification access', 'Lets the band tap you for messages.'),
      ('Unrestricted battery', 'Choose "Unrestricted" so ALVI is not stopped.'),
      ('Allow auto-start', 'Lets ALVI reconnect after your phone restarts.'),
      ('Lock ALVI in recent apps', 'Prevents clearing it by mistake.'),
      ('Background power protection', 'Stops battery managers closing ALVI.'),
    ];
    return AlviPage(label: 'Connection checklist', children: [
      const Headline('Five settings.', sub: 'Open each one, then mark it done.'),
      const SizedBox(height: 8),
      for (final i in items)
        Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.divider))),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(i.$1, style: AlviType.body(context)),
                Text(i.$2, style: AlviType.fine(context)),
                const SizedBox(height: 8),
                StatusWord(app.checklistDone.contains(i.$1) ? 'Done' : 'To do', color: app.checklistDone.contains(i.$1) ? c.good : c.caution),
              ]),
            ),
            AlviChip(app.checklistDone.contains(i.$1) ? 'Undo' : 'Mark done', selected: false, onTap: () {
              app.update(() {
                if (!app.checklistDone.remove(i.$1)) app.checklistDone.add(i.$1);
              });
            }),
          ]),
        ),
      const Disclaimer('Setting names differ by phone maker. See Guides for my phone.'),
    ]);
  }
}

/// Phone settings guide (QWatch Pro "Background Running Guide").
class PhoneGuideScreen extends StatelessWidget {
  const PhoneGuideScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(label: 'Phone settings guide', children: [
        const Headline('Pick your phone.', sub: 'If you use a security or cleaner app, add ALVI to its allow list too.'),
        const SizedBox(height: 8),
        for (final p in ['Samsung One UI', 'Google Pixel', 'Xiaomi HyperOS / MIUI', 'OPPO ColorOS', 'OnePlus OxygenOS', 'vivo OriginOS / Funtouch OS', 'Huawei EMUI', 'iPhone', 'Other phones'])
          NavRow(p, value: 'Guide', onTap: () => toast(context, 'Step-by-step guide for $p opens here')),
      ]);
}

/// Widgets (ALVI p7).
class WidgetsScreen extends StatelessWidget {
  const WidgetsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    Widget tile(Widget child) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: c.surfaceRaised, borderRadius: BorderRadius.circular(Radii.card * 2)), child: child);
    Widget ring(String v, String l, Color col, double p, {double size = 76}) => Column(mainAxisSize: MainAxisSize.min, children: [
          RingView(progress: p, color: col, size: size, stroke: 4, child: Text(v, style: AlviType.stat(context, size: size * 0.3))),
          const SizedBox(height: 6),
          CapsLabel(l),
        ]);
    return AlviPage(label: 'Widgets', sample: true, children: [
      const Headline('Glance, don\'t open.', eyebrow: 'Home and lock screen', sub: 'Your night and your readiness, on the home screen and the lock screen.'),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: tile(ring('78', 'Readiness', c.readiness, 0.78, size: 96))),
        const SizedBox(width: 12),
        Expanded(child: tile(ring('84', 'Sleep', c.sleep, 0.84, size: 96))),
      ]),
      const SizedBox(height: 12),
      tile(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        ring('84', 'Sleep', c.sleep, 0.84),
        ring('78', 'Ready', c.readiness, 0.78),
        ring('56%', 'Active', c.activity, 0.56),
      ])),
      const SectionLabel('Lock screen'),
      Row(children: [
        RingView(progress: 0.78, color: c.readiness, size: 64, stroke: 3, child: Text('78', style: AlviType.stat(context, size: 18))),
        const SizedBox(width: 12),
        tile(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const CapsLabel('Sleep'), Text('7h 42m', style: AlviType.stat(context, size: 22))])),
      ]),
      const Disclaimer('Widgets show wellness data only, never health alerts. Add them from your phone\'s widget picker.'),
    ]);
  }
}
