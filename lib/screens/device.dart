import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../services/wearable_service.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'templates.dart';

/// Your Helium (QWatch Pro "Device — Home"). Not-paired, connected and disconnected states.
class DeviceHomeScreen extends StatelessWidget {
  const DeviceHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    final band = app.wearable.band;
    if (band == null) {
      return AlviPage(
        label: 'Your Helium',
        footer: [
          PrimaryButton('Pair your band', onPressed: () => Navigator.pushNamed(context, '/pair')),
          AlviLink('Connection help', onTap: () => Navigator.pushNamed(context, '/pair/trouble')),
        ],
        children: const [
          SizedBox(height: Space.s24),
          Center(child: CoreIllustration(size: 200)),
          SizedBox(height: Space.s32),
          Headline('No band paired.', sub: 'Pair Helium to read your night, readiness and heart. Until then, ALVI shows sample data.'),
        ],
      );
    }
    final connected = app.connected;
    return AlviPage(
      label: 'Your Helium',
      footer: [
        if (!connected) ...[
          PrimaryButton('Reconnect', onPressed: () => Navigator.pushNamed(context, '/sync-failed')),
          const SizedBox(height: 12),
        ],
        SecondaryButton('Unpair', onPressed: () async {
          if (await confirmAction(context,
              title: 'Unpair ${band.name}?', body: 'Data not yet synced stays on the band. You can pair again any time.', confirm: 'Unpair', destructive: true)) {
            await app.wearable.unpair();
          }
        }),
      ],
      children: [
        const SampleNotice(),
        const SizedBox(height: 8),
        const Center(child: CoreIllustration(size: 150, rings: false)),
        const SizedBox(height: 16),
        Center(
            child: StatusWord(connected ? 'Connected · ${band.spot == WearSpot.wrist ? 'Wrist' : 'Upper arm'}' : 'Not connected',
                color: connected ? c.good : c.caution)),
        const SizedBox(height: 24),
        const CapsLabel('Battery'),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          DisplayNumeral(['${band.batteryPercent}', '%'], size: 80),
          const Spacer(),
          Padding(padding: const EdgeInsets.only(bottom: 10), child: Text('ABOUT ${band.daysLeft} DAYS LEFT*', style: AlviType.data(context, size: 11))),
        ]),
        const SizedBox(height: 8),
        LayoutBuilder(
            builder: (_, b) => Stack(children: [
                  Container(height: 2, color: c.lineStrong),
                  Container(height: 2, width: b.maxWidth * band.batteryPercent / 100, color: c.ink),
                ])),
        const SizedBox(height: 8),
        NavRow('Haptics', value: app.values['hapticStrength'], onTap: () => Navigator.pushNamed(context, '/device/haptics')),
        NavRow('Wear', value: '${band.spot == WearSpot.wrist ? 'Wrist' : 'Upper arm'} · ${band.size}', onTap: () => Navigator.pushNamed(context, '/device/wear')),
        Semantics(
          button: true,
          label: 'Find my band. It pulses for 10 seconds',
          child: InkWell(
            onTap: () {
              app.wearable.findBand();
              toast(context, connected ? 'Your band is pulsing' : 'Connect your band first');
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.divider))),
              child: Row(children: [
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Find my band', style: AlviType.body(context)),
                  Text('It pulses for 10 seconds', style: AlviType.fine(context)),
                ])),
                const HapticGlyph(HapticPattern.silentAlarm),
              ]),
            ),
          ),
        ),
        ToggleRow('Share heart rate', subtitle: 'Broadcast to gym equipment', value: app.toggle('shareHeartRate'), onChanged: (v) => app.setToggle('shareHeartRate', v)),
        NavRow('Background monitoring', onTap: () => Navigator.pushNamed(context, '/device/monitoring')),
        NavRow('Reminders', onTap: () => Navigator.pushNamed(context, '/device/reminders')),
        NavRow('Notifications', onTap: () => Navigator.pushNamed(context, '/device/notifications')),
        NavRow('Quiet hours', value: app.toggle('quietHours') ? app.values['quietHours'] : 'Off', mono: true, onTap: () => Navigator.pushNamed(context, '/device/quiet-hours')),
        NavRow('Wear calibration', onTap: () => Navigator.pushNamed(context, '/device/calibration')),
        NavRow('Firmware', value: '${band.firmware} · ${band.firmwareUpToDate ? 'UP TO DATE' : 'UPDATE'}', mono: true, chevron: false),
        NavRow('Band maintenance', subtitle: 'Restart, reset', onTap: () => Navigator.pushNamed(context, '/device/advanced')),
        const Disclaimer('* Design target. ALVI Helium is in development.'),
      ],
    );
  }
}

/// Haptics (ALVI p8).
class HapticsScreen extends StatelessWidget {
  const HapticsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final rows = [
      (HapticPattern.inZone, 'haptic.zone', 'Zone cues', 'When you enter your target zone'),
      (HapticPattern.goal, 'haptic.goal', 'Goal reached', 'Steps and workout goals'),
      (HapticPattern.move, 'reminder.move', 'Move nudges', 'After ${app.values['moveAfter']} sitting'),
      (HapticPattern.silentAlarm, 'haptic.alarm', 'Silent alarm', 'Inside your wake window'),
      (HapticPattern.breathe, 'haptic.breathe', 'Breathing breaks', 'When stress looks high'),
    ];
    return AlviPage(
      label: 'Haptics',
      footer: [
        PrimaryButton('Feel them again', onPressed: () async {
          for (final r in rows) {
            await app.wearable.playHaptic(r.$1);
          }
          if (context.mounted) toast(context, app.connected ? 'Playing each pattern' : 'Pair your band to feel them');
        }),
      ],
      children: [
        const Headline('Tune how Helium speaks to you.'),
        const SectionLabel('Strength'),
        AlviSegmented(options: const ['Soft', 'Medium', 'Strong'], selected: app.values['hapticStrength']!, onChanged: (v) => app.setValue('hapticStrength', v)),
        const SizedBox(height: 12),
        for (final r in rows)
          HapticRow(r.$1, subtitle: r.$4, trailing: AlviSwitch(value: app.toggle(r.$2), label: r.$3, onChanged: (v) => app.setToggle(r.$2, v))),
        HapticRow(HapticPattern.batteryLow, subtitle: 'Below 15%', trailing: Text('Always on', style: AlviType.fine(context))),
        NavRow('Silent alarm window', value: app.values['silentAlarm'], mono: true, onTap: () async {
          final v = await pickOption(context, title: 'Wake window', options: const ['06:00 — 06:30', '06:30 — 07:00', '07:00 — 07:30', '07:30 — 08:00'], selected: app.values['silentAlarm']);
          if (v != null) app.setValue('silentAlarm', v);
        }),
        NavRow('Quiet hours', value: app.values['quietHours'], mono: true, onTap: () => Navigator.pushNamed(context, '/device/quiet-hours')),
      ],
    );
  }
}

/// Background monitoring (QWatch Pro "Health Monitoring").
class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final caps = context.app.caps;
    return ToggleSettingsScreen(
      label: 'Background monitoring',
      headline: 'What Helium measures on its own.',
      intro: 'More frequent readings use more battery.',
      toggles: [
        ('monitor.heartRate', 'Heart rate', 'Every 5 minutes'),
        if (caps.oxygen) ('monitor.oxygen', 'Oxygen', 'Once an hour while still'),
        if (caps.stress) ('monitor.stress', 'All-day stress', 'Every 30 minutes'),
        if (caps.hrv) ('monitor.hrv', 'HRV', 'Overnight and at rest'),
        if (caps.uv) ('monitor.uv', 'UV exposure', 'Every 30 minutes'),
        if (caps.bloodPressure) ('monitor.bloodPressure', 'Blood pressure estimate', 'Every hour'),
      ],
      note: 'Sleep, steps and skin temperature are always measured.',
    );
  }
}

/// Reminders (QWatch Pro "Smart Reminder").
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(label: 'Reminders', children: [
      const Headline('Gentle nudges.', sub: 'Each one arrives as its own pattern on your wrist.'),
      const SectionLabel('Health'),
      NavRow('Move nudges', value: app.toggle('reminder.move') ? 'After ${app.values['moveAfter']}' : 'Off', onTap: () => Navigator.pushNamed(context, '/device/reminders/move')),
      NavRow('Hydration nudges', value: app.toggle('reminder.water') ? 'Every ${app.values['waterEvery']}' : 'Off', onTap: () => Navigator.pushNamed(context, '/device/reminders/water')),
      const SectionLabel('Alarm'),
      NavRow('Silent alarm', subtitle: 'Wakes you in light sleep inside the window', value: app.values['silentAlarm'], mono: true, onTap: () => Navigator.pushNamed(context, '/device/haptics')),
      const SectionLabel('Faith'),
      NavRow('Prayer reminders', value: app.toggle('prayer.reminders') ? 'On' : 'Off', onTap: () => Navigator.pushNamed(context, '/faith/reminders')),
    ]);
  }
}

class MoveNudgesScreen extends StatelessWidget {
  const MoveNudgesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return ToggleSettingsScreen(
      label: 'Move nudges',
      headline: 'One long pulse when it\'s time to move.',
      toggles: const [('reminder.move', 'Move nudges', 'Between 09:00 and 21:00, not during quiet hours')],
      extra: [
        NavRow('After sitting for', value: app.values['moveAfter'], onTap: () async {
          final v = await pickOption(context, title: 'After sitting for', options: const ['30 min', '45 min', '60 min', '90 min', '120 min'], selected: app.values['moveAfter']);
          if (v != null) app.setValue('moveAfter', v);
        }),
      ],
    );
  }
}

class WaterNudgesScreen extends StatelessWidget {
  const WaterNudgesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return ToggleSettingsScreen(
      label: 'Hydration nudges',
      headline: 'A reminder to drink.',
      toggles: const [('reminder.water', 'Hydration nudges', 'During the day, never in quiet hours')],
      extra: [
        NavRow('Every', value: app.values['waterEvery'], onTap: () async {
          final v = await pickOption(context, title: 'Remind me every', options: const ['1 h', '1.5 h', '2 h', '3 h'], selected: app.values['waterEvery']);
          if (v != null) app.setValue('waterEvery', v);
        }),
      ],
    );
  }
}

/// Quiet hours (QWatch Pro "Do-Not-Disturb Mode").
class QuietHoursScreen extends StatelessWidget {
  const QuietHoursScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return ToggleSettingsScreen(
      label: 'Quiet hours',
      headline: 'No taps while you rest.',
      intro: 'Alerts and nudges wait. Your silent alarm and battery-low pattern still come through.',
      toggles: const [('quietHours', 'Quiet hours', null)],
      extra: [
        NavRow('Hours', value: app.values['quietHours'], mono: true, onTap: () async {
          final v = await pickOption(context, title: 'Quiet hours', options: const ['21:00 — 06:00', '22:00 — 06:30', '23:00 — 07:00', '00:00 — 08:00'], selected: app.values['quietHours']);
          if (v != null) app.setValue('quietHours', v);
        }),
      ],
    );
  }
}

/// Notifications (QWatch Pro "Notification").
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final all = app.toggle('notify.all');
    return AlviPage(label: 'Notifications', children: [
      const Headline('Which alerts tap your wrist?', sub: 'Helium has no screen. An alert is one short tap; open your phone to read it.'),
      const SizedBox(height: 8),
      ToggleRow('Allow alerts', value: all, onChanged: (v) => app.setToggle('notify.all', v)),
      if (all) ...[
        ToggleRow('Calls', value: app.toggle('notify.calls'), onChanged: (v) => app.setToggle('notify.calls', v)),
        ToggleRow('SMS', value: app.toggle('notify.sms'), onChanged: (v) => app.setToggle('notify.sms', v)),
        const SectionLabel('Apps'),
        for (final e in app.notifyApps.entries)
          ToggleRow(e.key, value: e.value == 'on', onChanged: (v) => app.update(() => app.notifyApps[e.key] = v ? 'on' : 'off')),
        NavRow('Other apps', onTap: () => Navigator.pushNamed(context, '/device/notifications/other')),
      ],
      NavRow('Alerts stopped arriving?', onTap: () => Navigator.pushNamed(context, '/you/background')),
    ]);
  }
}

/// Other app alerts (QWatch Pro "Other Software").
class OtherAppsScreen extends StatefulWidget {
  const OtherAppsScreen({super.key});
  @override
  State<OtherAppsScreen> createState() => _OtherAppsScreenState();
}

class _OtherAppsScreenState extends State<OtherAppsScreen> {
  final apps = {'Camera': false, 'Maps': false, 'Play Store': false, 'Settings': false, 'Phone carrier app': false, 'Banking app': false};
  @override
  Widget build(BuildContext context) => AlviPage(label: 'Other app alerts', children: [
        const Headline('Everything else on your phone.', sub: 'Installed apps appear here. Sample list shown.'),
        const SizedBox(height: 8),
        for (final e in apps.entries) ToggleRow(e.key, value: e.value, onChanged: (v) => setState(() => apps[e.key] = v)),
      ]);
}

/// Wear calibration (QWatch Pro "Wearing Calibration").
class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});
  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  int step = 0;
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(
      label: 'Wear calibration',
      footer: [
        PrimaryButton(step == 0 ? 'Start calibration' : (step == 1 ? 'Next' : 'Done'), onPressed: () {
          if (!app.connected) return toast(context, 'Connect your band first');
          if (step == 2) return Navigator.pop(context);
          setState(() => step++);
        }),
      ],
      children: [
        const Headline('Only if readings look wrong.', sub: 'If heart rate cannot be measured or looks off, calibrate the sensor. Otherwise skip it.'),
        const SizedBox(height: 24),
        const Center(child: CoreIllustration(size: 170, pulsing: true)),
        const SizedBox(height: 24),
        Opacity(opacity: step >= 1 ? 1 : 0.6, child: const NumberedRow(1, 'Hold the core sensor-side up. Tap start. Wait for the light to stay on for 5 seconds.')),
        Opacity(opacity: step >= 2 ? 1 : 0.6, child: const NumberedRow(2, 'Put the band on, snug against your skin, until the light turns off.')),
        if (step == 2) Padding(padding: const EdgeInsets.only(top: 16), child: StatusWord('Calibrated (sample)', color: context.alvi.good)),
      ],
    );
  }
}

/// Band maintenance (QWatch Pro "More": reboot, factory reset).
class AdvancedScreen extends StatelessWidget {
  const AdvancedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(label: 'Band maintenance', children: [
      NavRow('Restart the band', subtitle: 'Takes about a minute. Data is kept.', onTap: () async {
        if (await confirmAction(context, title: 'Restart the band?', body: 'It reconnects on its own.', confirm: 'Restart')) {
          await app.wearable.restart();
          if (context.mounted) toast(context, 'Restarted');
        }
      }),
      NavRow('Reset to factory settings', danger: true, subtitle: 'Erases data on the band and unpairs it.', onTap: () async {
        if (await confirmAction(context,
            title: 'Reset the band?', body: 'Anything not yet synced is lost. The band unpairs from this phone.', confirm: 'Reset', destructive: true)) {
          await app.wearable.factoryReset();
          if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/device', (r) => r.isFirst);
        }
      }),
    ]);
  }
}

// ---------------- Capability-gated band features ----------------

class CallForwardingScreen extends StatelessWidget {
  const CallForwardingScreen({super.key});
  @override
  Widget build(BuildContext context) => const CapabilityGate(
        capability: 'cellular',
        featureName: 'Call forwarding',
        reason: 'Call forwarding needs a band with its own mobile connection.',
        child: ToggleSettingsScreen(
          label: 'Call forwarding',
          toggles: [('callForwarding', 'Call forwarding', 'Forward calls to the band\'s number')],
          note: 'Your operator may charge for forwarding. Changes can take about 5 minutes to apply.',
        ),
      );
}

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});
  @override
  Widget build(BuildContext context) => CapabilityGate(
        capability: 'display',
        featureName: 'Card on band',
        reason: 'Showing a contact card needs a band with a screen. Helium has none. Share My code from your phone instead.',
        child: AlviPage(label: 'Card on band', trailing: BarIcon(icon: Icons.help_outline, label: 'How it works', onTap: () => Navigator.pushNamed(context, '/device/card/guide')), children: [
          const Headline('Show a contact code on your band.'),
          for (final s in ['Instagram', 'WhatsApp', 'LinkedIn', 'X', 'Facebook']) NavRow(s, value: 'Add', onTap: () => toast(context, 'Paste your $s profile link')),
        ]),
      );
}

class CardGuideScreen extends StatelessWidget {
  const CardGuideScreen({super.key});
  @override
  Widget build(BuildContext context) => const CapabilityGate(
        capability: 'display',
        featureName: 'Card on band',
        child: ArticleScreen(label: 'How it works', headline: 'Three steps.', steps: [
          'Copy your profile link from the app.',
          'Paste it into the matching row.',
          'Open Card on your band and show the code.',
        ]),
      );
}

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});
  @override
  Widget build(BuildContext context) => CapabilityGate(
        capability: 'display',
        featureName: 'Photos on band',
        reason: 'Photos need a band with a screen. Helium has none.',
        child: EmptyListScreen(label: 'Photos on band', title: 'No photos yet.', body: 'Choose a photo to show on your band.', icon: Icons.image_outlined, action: 'Choose photo', onAction: () => Navigator.pushNamed(context, '/device/media/album/send')),
      );
}

class AlbumSendScreen extends StatelessWidget {
  const AlbumSendScreen({super.key});
  @override
  Widget build(BuildContext context) => CapabilityGate(
        capability: 'display',
        featureName: 'Photos on band',
        child: AlviPage(label: 'Send photo', footer: [PrimaryButton('Send to band', onPressed: () => toast(context, 'Sent (sample)'))], children: [
          AspectRatio(
              aspectRatio: 1,
              child: Container(
                  decoration: BoxDecoration(color: context.alvi.surfaceRaised, borderRadius: BorderRadius.circular(Radii.card)),
                  child: Icon(Icons.crop, color: context.alvi.inkMuted))),
          const Disclaimer('Crop to the band\'s screen shape before sending.'),
        ]),
      );
}

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});
  @override
  Widget build(BuildContext context) => CapabilityGate(
        capability: 'display',
        featureName: 'Books on band',
        child: EmptyListScreen(label: 'Books on band', title: 'No books yet.', body: 'Add a .txt book to read on your band.', icon: Icons.menu_book_outlined, action: 'Add book', onAction: () => toast(context, 'File picker opens here'),
            trailing: BarText('Edit', onTap: () {})),
      );
}

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});
  @override
  Widget build(BuildContext context) => CapabilityGate(
        capability: 'speaker',
        featureName: 'Music on band',
        child: EmptyListScreen(label: 'Music on band', title: 'No music yet.', body: 'Add tracks to play from your band.', icon: Icons.music_note_outlined, action: 'Add music', onAction: () => toast(context, 'File picker opens here'),
            trailing: BarText('Edit', onTap: () {})),
      );
}

class FacesScreen extends StatelessWidget {
  const FacesScreen({super.key});
  @override
  Widget build(BuildContext context) => CapabilityGate(
        capability: 'display',
        featureName: 'Band faces',
        child: AlviPage(label: 'Band faces', children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (var i = 1; i <= 6; i++)
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/device/media/faces/install'),
                  child: Container(
                    decoration: BoxDecoration(color: context.alvi.surfaceRaised, borderRadius: BorderRadius.circular(Radii.card)),
                    alignment: Alignment.center,
                    child: Text('Face $i', style: AlviType.bodySmall(context)),
                  ),
                ),
            ],
          ),
        ]),
      );
}

class FaceInstallScreen extends StatelessWidget {
  const FaceInstallScreen({super.key});
  @override
  Widget build(BuildContext context) => CapabilityGate(
        capability: 'display',
        featureName: 'Band faces',
        child: AlviPage(label: 'Install face', footer: [PrimaryButton('Install', onPressed: () => toast(context, 'Installed (sample)'))], children: [
          AspectRatio(aspectRatio: 1, child: Container(decoration: BoxDecoration(color: context.alvi.surfaceRaised, borderRadius: BorderRadius.circular(Radii.card)))),
          const Disclaimer('Previews are for illustration. The face on your band may look slightly different.'),
        ]),
      );
}
