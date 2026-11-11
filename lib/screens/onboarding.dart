import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../services/wearable_service.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';

/// Header used in onboarding steps: back, "STEP n OF 8", segments.
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key, required this.step, this.total = 8});
  final int step, total;
  @override
  Widget build(BuildContext context) => Column(children: [
        AlviTopBar(label: 'Step $step of $total'),
        Padding(padding: const EdgeInsets.symmetric(horizontal: Space.side), child: StepSegments(step: step, total: total)),
      ]);
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.step, required this.children, this.footer});
  final int step;
  final List<Widget> children;
  final List<Widget>? footer;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: AlviBackground(
          child: SafeArea(
            child: Column(children: [
              OnboardingHeader(step: step),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(Space.side, Space.s16, Space.side, Space.s16), children: children),
              ),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(Space.side, 0, Space.side, Space.s16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: footer!),
                ),
            ]),
          ),
        ),
      );
}

/// ALVI mark: abstract wave with two dots, drawn as line art. Not a reproduction of any other brand.
class AlviMark extends StatelessWidget {
  const AlviMark({super.key, this.size = 224});
  final double size;
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.divider))),
          Container(width: size * 0.7, height: size * 0.7, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.lineStrong))),
          CustomPaint(size: Size(size * 0.5, size * 0.3), painter: _WavePainter(c.ink)),
        ]),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, s.height * 0.85)
      ..cubicTo(s.width * 0.15, 0, s.width * 0.3, 0, s.width * 0.45, s.height * 0.6)
      ..cubicTo(s.width * 0.6, s.height, s.width * 0.8, s.height, s.width * 0.92, s.height * 0.25);
    canvas.drawPath(path, p);
    canvas.drawCircle(Offset(s.width * 0.22, s.height * 0.7), 4, Paint()..color = color);
    canvas.drawCircle(Offset(s.width * 0.98, s.height * 0.05), 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlviBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.side),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                for (final l in ['EN', 'FR'])
                  TextButton(
                    onPressed: () => app.update(() => app.language = l),
                    child: Text(l, style: AlviType.label(context, color: app.language == l ? c.ink : c.inkMuted)),
                  ),
              ]),
              const Spacer(),
              const Center(child: AlviMark()),
              const SizedBox(height: Space.s48),
              Text('Wear less.\nKnow more.', textAlign: TextAlign.center, style: AlviType.headline(context, size: 32)),
              const SizedBox(height: Space.s16),
              Text('Nothing to look at.\nA touch when it matters.\nA morning brief that reads your night.',
                  textAlign: TextAlign.center, style: AlviType.body(context, color: c.inkBody)),
              const Spacer(),
              PrimaryButton('Get started', onPressed: () => Navigator.pushNamed(context, '/account/create')),
              const SizedBox(height: Space.s8),
              AlviLink('I already have an account', onTap: () => Navigator.pushNamed(context, '/account/sign-in')),
              const SizedBox(height: Space.s8),
              AlviLink('Explore with sample data', onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/today', (_) => false)),
              const SizedBox(height: Space.s16),
              Text('ALVI INTELLECTS INC. · ONTARIO', textAlign: TextAlign.center, style: AlviType.label(context)),
              const SizedBox(height: Space.s16),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Step 2: profile (from QWatch Pro "Profile Setup").
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return OnboardingPage(step: 2, footer: [
      PrimaryButton('Continue', onPressed: () {
        if (name.text.trim().isNotEmpty) app.update(() => app.nickname = name.text.trim());
        Navigator.pushNamed(context, '/permissions');
      }),
      AlviLink('Skip for now', onTap: () => Navigator.pushNamed(context, '/permissions')),
    ], children: [
      const Headline('What should we call you?', eyebrow: 'Profile', sub: 'Your baselines use age, height and weight. You can change these any time in You.'),
      const SizedBox(height: Space.s24),
      AlviField(label: 'Nickname', hint: 'Sam', controller: name),
      NavRow('Birthday', value: app.birthday, mono: true, onTap: () async {
        final d = await showDatePicker(context: context, firstDate: DateTime(1920), lastDate: DateTime.now(), initialDate: DateTime(1995));
        if (d != null) app.update(() => app.birthday = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
      }),
      NavRow('Height', value: '${app.heightCm} cm', onTap: () async {
        final v = await pickNumber(context, title: 'Height', value: app.heightCm.toDouble(), step: 1, min: 100, max: 230, unit: 'cm');
        if (v != null) app.update(() => app.heightCm = v.round());
      }),
      NavRow('Weight', value: '${app.weightKg} kg', onTap: () async {
        final v = await pickNumber(context, title: 'Weight', value: app.weightKg.toDouble(), step: 1, min: 30, max: 250, unit: 'kg');
        if (v != null) app.update(() => app.weightKg = v.round());
      }),
    ]);
  }
}

/// Step 3: permissions (from QWatch Pro first-launch permission prompt).
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Bluetooth and nearby devices', 'To find, pair and sync your band.'),
      ('Location', 'For outdoor workouts using your phone\'s GPS, and band discovery on older Android versions.'),
      ('Notifications', 'So the band can tap you for messages you choose.'),
      ('Contacts, calls and SMS', 'Only if you turn on call and message alerts. Never uploaded.'),
      ('Background activity', 'Keeps the band connected when ALVI is closed.'),
    ];
    return OnboardingPage(step: 3, footer: [
      PrimaryButton('Allow and continue', onPressed: () => Navigator.pushNamed(context, '/pair')),
      AlviLink('Not now', onTap: () => Navigator.pushNamed(context, '/pair')),
    ], children: [
      const Headline('A few permissions.', eyebrow: 'Permissions', sub: 'Each one has a single job. You can change them in your phone settings.'),
      const SizedBox(height: Space.s16),
      for (final r in rows) NavRow(r.$1, subtitle: r.$2, chevron: false),
    ]);
  }
}

/// Step 5: wake the core.
class PairIntroScreen extends StatelessWidget {
  const PairIntroScreen({super.key});
  @override
  Widget build(BuildContext context) => OnboardingPage(step: 5, footer: [
        PrimaryButton('I felt the pulse', onPressed: () => Navigator.pushNamed(context, '/pair/searching')),
        AlviLink('Need help?', onTap: () => Navigator.pushNamed(context, '/pair/trouble')),
      ], children: const [
        Center(child: CoreIllustration(size: 210, pulsing: true)),
        SizedBox(height: Space.s32),
        Headline('Wake the core.', eyebrow: 'Pair your band'),
        SizedBox(height: Space.s8),
        NumberedRow(1, 'Place the Helium core on its charger.'),
        NumberedRow(2, 'Wait for one soft pulse. It\'s awake.'),
        NumberedRow(3, 'Keep your phone within one metre.'),
      ]);
}

/// Searching for the band (from "Add: searching").
class PairSearchingScreen extends StatefulWidget {
  const PairSearchingScreen({super.key});
  @override
  State<PairSearchingScreen> createState() => _PairSearchingScreenState();
}

class _PairSearchingScreenState extends State<PairSearchingScreen> {
  List<DiscoveredBand>? found;
  bool pairing = false;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    final app = context.appRead;
    setState(() => found = null);
    final r = await app.wearable.scan();
    if (!mounted) return;
    if (r.isEmpty) {
      Navigator.pushReplacementNamed(context, '/pair/not-found');
    } else {
      setState(() => found = r);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return OnboardingPage(step: 6, footer: [
      if (found != null)
        PrimaryButton('Pair ${found!.first.name}', busy: pairing, onPressed: () async {
          setState(() => pairing = true);
          await app.wearable.pair(found!.first);
          if (context.mounted) Navigator.pushReplacementNamed(context, '/onboarding/wear');
        }),
      AlviLink('Problem with connection?', onTap: () => Navigator.pushNamed(context, '/pair/trouble')),
    ], children: [
      Center(child: CoreIllustration(size: 210, pulsing: found == null)),
      const SizedBox(height: Space.s32),
      Headline(found == null ? 'Looking for your band.' : 'Found your band.', eyebrow: 'Pair your band',
          sub: found == null ? 'Keep the core on its charger, close to your phone.' : 'Tap pair. The core answers with a tick.'),
      if (found != null) ...[
        const SizedBox(height: Space.s16),
        NavRow(found!.first.name, subtitle: 'Signal ${found!.first.signal} dBm · sample band', chevron: false),
      ],
    ]);
  }
}

/// Nothing found (from "Add: search again" and its help menu).
class PairNotFoundScreen extends StatelessWidget {
  const PairNotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(
        lead: TopBarLead.close,
        trailing: BarIcon(
          icon: Icons.help_outline,
          label: 'Connection help',
          onTap: () => showSheet<void>(context, (ctx) => [
                Text('Problem with connection?', style: AlviType.headline(ctx, size: 24)),
                const SizedBox(height: 16),
                NavRow('Connection help', onTap: () => Navigator.popAndPushNamed(ctx, '/pair/trouble')),
                NavRow('Wear calibration', onTap: () => Navigator.popAndPushNamed(ctx, '/device/calibration')),
                NavRow('Contact support', onTap: () => Navigator.popAndPushNamed(ctx, '/you/feedback')),
              ]),
        ),
        footer: [
          PrimaryButton('Search again', onPressed: () => Navigator.pushReplacementNamed(context, '/pair/searching')),
          const SizedBox(height: 12),
          SecondaryButton('Connection help', onPressed: () => Navigator.pushNamed(context, '/pair/trouble')),
        ],
        children: [
          StatusWord('Pair · not found', color: context.alvi.caution),
          const SizedBox(height: 12),
          const Headline('We could not find your band.', sub: 'Wake the core and try again.'),
          const NumberedRow(1, 'Place the core on its charger until it pulses.'),
          const NumberedRow(2, 'Check that Bluetooth is on.'),
          const NumberedRow(3, 'Keep your phone within one metre.'),
        ],
      );
}

/// Connection help (from "Having trouble connecting").
class ConnectionHelpScreen extends StatelessWidget {
  const ConnectionHelpScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(label: 'Connection help', children: [
        const Headline('Having trouble connecting?'),
        const NumberedRow(1, 'Check the core is charged and within one metre of your phone.'),
        const NumberedRow(2, 'Allow Bluetooth and nearby devices for ALVI. On older Android versions, allow location too.'),
        const NumberedRow(3, 'Turn Bluetooth off and on. If that fails, restart your phone.'),
        const NumberedRow(4, 'Still stuck? Reset the core and pair again. Your data stays on the band until it syncs.'),
        const SizedBox(height: Space.s24),
        NavRow('Keep ALVI connected in the background', onTap: () => Navigator.pushNamed(context, '/you/background')),
        NavRow('Send feedback', onTap: () => Navigator.pushNamed(context, '/you/feedback')),
      ]);
}

/// Step 7: where will you wear it.
class WearScreen extends StatelessWidget {
  const WearScreen({super.key, this.inSettings = false});
  final bool inSettings;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final band = app.wearable.band;
    final spot = band?.spot ?? WearSpot.wrist;
    final size = band?.size ?? 'M';
    final hand = band?.hand ?? 'Left';
    void set({WearSpot? s, String? z, String? h}) => app.update(() => app.wearable.setWear(spot: s, size: z, hand: h));

    final body = <Widget>[
      const Headline('Where will you wear it?', eyebrow: 'Wear', sub: 'We tune pulse strength to the spot. Move it any time.'),
      const SizedBox(height: Space.s24),
      Row(children: [
        Expanded(child: _SpotOption(title: 'Wrist', body: 'Everyday, knit or sport band', selected: spot == WearSpot.wrist, onTap: () => set(s: WearSpot.wrist))),
        const SizedBox(width: 16),
        Expanded(child: _SpotOption(title: 'Upper arm', body: 'Training, team sports and sleep', selected: spot == WearSpot.upperArm, onTap: () => set(s: WearSpot.upperArm))),
      ]),
      const SizedBox(height: Space.s24),
      Container(
        constraints: const BoxConstraints(minHeight: 64),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: context.alvi.divider), bottom: BorderSide(color: context.alvi.divider))),
        child: Row(children: [
          Expanded(child: Text('Band size', style: AlviType.body(context))),
          for (final z in ['S', 'M', 'L']) Padding(padding: const EdgeInsets.only(left: 8), child: RoundChoice(z, selected: size == z, onTap: () => set(z: z))),
        ]),
      ),
      Container(
        constraints: const BoxConstraints(minHeight: 64),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.alvi.divider))),
        child: Row(children: [
          Expanded(child: Text('Hand', style: AlviType.body(context))),
          for (final h in ['Left', 'Right']) Padding(padding: const EdgeInsets.only(left: 8), child: AlviChip(h, selected: hand == h, onTap: () => set(h: h))),
        ]),
      ),
      const SizedBox(height: Space.s24),
      Text('Snug, one finger of space. The sensor faces your skin.', style: AlviType.fine(context)),
    ];
    if (inSettings) return AlviPage(label: 'Wear', children: body);
    return OnboardingPage(step: 7, footer: [PrimaryButton('Continue', onPressed: () => Navigator.pushNamed(context, '/onboarding/haptics'))], children: body);
  }
}

class _SpotOption extends StatelessWidget {
  const _SpotOption({required this.title, required this.body, required this.selected, required this.onTap});
  final String title, body;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Semantics(
      selected: selected,
      button: true,
      label: '$title. $body',
      child: GestureDetector(
        onTap: onTap,
        child: Column(children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? c.ink : c.divider, width: selected ? 2 : 1)),
              alignment: Alignment.center,
              child: Icon(title == 'Wrist' ? Icons.watch_outlined : Icons.fitness_center, size: 36, color: selected ? c.ink : c.inkMuted),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            AlviRadio(selected: selected),
            const SizedBox(width: 8),
            Text(title, style: AlviType.body(context)),
          ]),
          const SizedBox(height: 4),
          Text(body, textAlign: TextAlign.center, style: AlviType.fine(context)),
        ]),
      ),
    );
  }
}

/// Step 8: the haptic language.
class HapticLanguageScreen extends StatelessWidget {
  const HapticLanguageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return OnboardingPage(step: 8, footer: [
      PrimaryButton('Finish setup', onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/today', (_) => false)),
    ], children: [
      const Headline('It speaks in touch.', eyebrow: 'The haptic language', sub: 'Tap play to feel each pattern on your wrist now.'),
      const SizedBox(height: Space.s16),
      for (final p in HapticPattern.values.where((p) => p != HapticPattern.tick))
        HapticRow(p, onPlay: () {
          app.wearable.playHaptic(p);
          toast(context, app.connected ? 'Playing ${p.title.toLowerCase()}' : 'Pair your band to feel it');
        }),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(width: 48, child: HapticGlyph(HapticPattern.tick)),
          Expanded(
            child: Text.rich(TextSpan(style: AlviType.bodySmall(context), children: const [
              TextSpan(text: 'And you can talk back: '),
              TextSpan(text: 'double-tap', style: TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: ' the core to start or end a workout. A tick says got it.'),
            ])),
          ),
        ]),
      ),
    ]);
  }
}

/// Sync failed (ALVI states page; reached from banners and Your Helium).
class SyncFailedScreen extends StatelessWidget {
  const SyncFailedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final last = app.wearable.band?.lastSync;
    final ago = last == null ? 'a while' : '${DateTime.now().difference(last).inHours} h';
    return AlviPage(
      lead: TopBarLead.close,
      footer: [
        PrimaryButton('Try again', onPressed: () async {
          if (app.wearable.band == null) {
            Navigator.pushNamed(context, '/pair');
            return;
          }
          await app.wearable.reconnect();
          await app.wearable.sync();
          if (context.mounted) {
            toast(context, app.connected ? 'Synced' : 'Still not connected');
            if (app.connected) Navigator.maybePop(context);
          }
        }),
        const SizedBox(height: 12),
        SecondaryButton('Find my band', onPressed: () {
          app.wearable.findBand();
          toast(context, 'Your band pulses for 10 seconds when in range');
        }),
        AlviLink('Need help?', onTap: () => Navigator.pushNamed(context, '/pair/trouble')),
      ],
      children: [
        StatusWord('Sync · not connected', color: context.alvi.caution),
        const SizedBox(height: 12),
        Headline('We could not reach your band.', sub: 'Your data is safe on the band. Last synced $ago ago.'),
        const NumberedRow(1, 'Keep your phone within one metre.'),
        const NumberedRow(2, 'Check that Bluetooth is on.'),
        const NumberedRow(3, 'Double-tap the core to wake it.'),
      ],
    );
  }
}
