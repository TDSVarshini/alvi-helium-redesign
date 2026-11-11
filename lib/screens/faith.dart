import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../services/wearable_service.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';
import 'templates.dart';

/// Faith home (QWatch Pro "Muslim"): daily tasbih counter, day/month chart, entries.
class FaithScreen extends StatefulWidget {
  const FaithScreen({super.key});
  @override
  State<FaithScreen> createState() => _FaithScreenState();
}

class _FaithScreenState extends State<FaithScreen> {
  String period = 'Day';
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final c = context.alvi;
    final target = app.toggle('tasbih.33') ? 33 : (app.toggle('tasbih.100') ? 100 : int.tryParse(app.values['tasbihCustom'] ?? '') ?? 33);
    return AlviPage(
      label: 'Faith',
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        BarIcon(icon: Icons.settings_outlined, label: 'Prayer settings', onTap: () => Navigator.pushNamed(context, '/faith/settings')),
        BarIcon(icon: Icons.more_horiz, label: 'More', onTap: () => Navigator.pushNamed(context, '/faith/more')),
      ]),
      children: [
        const CapsLabel('Daily tasbih'),
        const SizedBox(height: 12),
        Center(
          child: Semantics(
            button: true,
            label: 'Count. ${app.tasbihToday} of $target',
            child: GestureDetector(
              onTap: () {
                app.countTasbih();
                if (app.tasbihToday % target == 0) app.wearable.playHaptic(HapticPattern.goal);
              },
              child: RingView(
                progress: (app.tasbihToday % target) / target,
                color: c.readiness,
                size: 240,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${app.tasbihToday}', style: AlviType.display(context, size: 88)),
                  CapsLabel('Tap to count · round of $target'),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          AlviChip('Clear', selected: false, onTap: app.clearTasbih),
          const SizedBox(width: 8),
          AlviChip('Goals', selected: false, onTap: () => Navigator.pushNamed(context, '/faith/tasbih/goals')),
          const SizedBox(width: 8),
          AlviChip('History', selected: false, onTap: () => Navigator.pushNamed(context, '/faith/tasbih/history')),
        ]),
        const SizedBox(height: 8),
        Center(child: Text('Double-tap the core to count without your phone (needs the ALVI SDK).', style: AlviType.fine(context))),
        const SizedBox(height: 24),
        AlviSegmented(options: const ['Day', 'Month'], selected: period, onChanged: (v) => setState(() => period = v)),
        DateStepper(period: period),
        BarsView(
          values: period == 'Day' ? [0, 0, 0, 33, 0, 0, 66, 0, 0, 33, 0, app.tasbihToday] : [for (var i = 0; i < 30; i++) (i * 37) % 120],
          labels: period == 'Day' ? ['06', '', '', '09', '', '', '12', '', '', '15', '', 'NOW'] : [for (var i = 1; i <= 30; i++) i % 5 == 0 ? '$i' : ''],
          colors: [c.readiness],
          height: 100,
        ),
        const SizedBox(height: 8),
        const StatGrid([StatCell('Average', '44'), StatCell('Lowest', '0'), StatCell('Highest', '99')]),
        const SectionLabel('Prayer'),
        NavRow('Prayer times', value: _nextPrayer(), mono: true, onTap: () => Navigator.pushNamed(context, '/faith/prayer-times')),
        NavRow('Qibla', onTap: () => Navigator.pushNamed(context, '/faith/qibla')),
        NavRow('Prayer reminders', value: app.toggle('prayer.reminders') ? 'On' : 'Off', onTap: () => Navigator.pushNamed(context, '/faith/reminders')),
        NavRow('Quran', onTap: () => Navigator.pushNamed(context, '/faith/quran')),
        NavRow('99 Names', onTap: () => Navigator.pushNamed(context, '/faith/names')),
      ],
    );
  }

  String _nextPrayer() {
    final now = TimeOfDay.now();
    for (final p in Sample.prayerTimes) {
      final parts = p[1].split(':');
      final t = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (t > now.hour * 60 + now.minute && p[0] != 'Sunrise') return '${p[0].toUpperCase()} ${p[1]}';
    }
    return 'FAJR ${Sample.prayerTimes.first[1]}';
  }
}

class FaithMoreScreen extends StatelessWidget {
  const FaithMoreScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(label: 'More', children: [
        NavRow('Prayer reminders', onTap: () => Navigator.pushNamed(context, '/faith/reminders')),
        NavRow('Quran', onTap: () => Navigator.pushNamed(context, '/faith/quran')),
        NavRow('99 Names', onTap: () => Navigator.pushNamed(context, '/faith/names')),
        NavRow('Prayer times', onTap: () => Navigator.pushNamed(context, '/faith/prayer-times')),
        NavRow('Qibla', onTap: () => Navigator.pushNamed(context, '/faith/qibla')),
      ]);
}

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(
      label: 'Prayer times',
      sample: true,
      trailing: BarIcon(icon: Icons.settings_outlined, label: 'Prayer settings', onTap: () => Navigator.pushNamed(context, '/faith/settings')),
      children: [
        Text('${Sample.city.toUpperCase()} · ${app.values['method']}', style: AlviType.data(context, size: 11)),
        const SizedBox(height: 8),
        for (final p in Sample.prayerTimes) NavRow(p[0], value: p[1], mono: true, chevron: false),
        const Disclaimer('Sample times. Live times need your location and the chosen calculation method.'),
      ],
    );
  }
}

/// Great-circle bearing from a location to the Kaaba (21.4225° N, 39.8262° E).
double qiblaBearing(double lat, double lon) {
  const kLat = 21.4225 * math.pi / 180, kLon = 39.8262 * math.pi / 180;
  final p1 = lat * math.pi / 180, l1 = lon * math.pi / 180;
  final y = math.sin(kLon - l1) * math.cos(kLat);
  final x = math.cos(p1) * math.sin(kLat) - math.sin(p1) * math.cos(kLat) * math.cos(kLon - l1);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final b = qiblaBearing(Sample.latitude, Sample.longitude);
    return AlviPage(label: 'Qibla', children: [
      Row(children: [
        Expanded(child: StatCell('Qibla bearing', '${b.round()}°')),
        const Expanded(child: StatCell('Phone heading', '—')),
      ]),
      const SizedBox(height: 32),
      Center(child: CompassView(bearing: b)),
      const SizedBox(height: 24),
      Text('Calculated for ${Sample.city} (sample location). The live compass needs the phone\'s heading sensor; hold your phone flat.', style: AlviType.fine(context)),
    ]);
  }
}

class PrayerRemindersScreen extends StatelessWidget {
  const PrayerRemindersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return ToggleSettingsScreen(
      label: 'Prayer reminders',
      headline: 'A gentle tap at each prayer.',
      toggles: const [('prayer.reminders', 'Prayer reminders', 'Not during quiet hours unless you choose')],
      extra: [
        if (app.toggle('prayer.reminders'))
          for (final p in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'])
            NavRow(p, value: app.toggle('prayer.$p') ? 'On' : 'Off', onTap: () => Navigator.pushNamed(context, '/faith/reminders/prayer', arguments: p)),
      ],
    );
  }
}

class PrayerReminderScreen extends StatelessWidget {
  const PrayerReminderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final p = ModalRoute.of(context)?.settings.arguments as String? ?? 'Fajr';
    return AlviPage(label: '$p reminder', children: [
      ToggleRow('Remind me', value: app.toggle('prayer.$p'), onChanged: (v) => app.setToggle('prayer.$p', v)),
      NavRow('When', value: app.values['adhanOffset'], onTap: () async {
        final v = await pickOption(context, title: 'When', options: const ['10 min before the Adhan', '5 min before the Adhan', 'At the Adhan', '5 min after the Adhan'], selected: app.values['adhanOffset']);
        if (v != null) app.setValue('adhanOffset', v);
      }),
      NavRow('$p time offset', value: '0 min', onTap: () async {
        await pickNumber(context, title: 'Offset', value: 0, step: 1, min: -30, max: 30, unit: 'min');
      }),
    ]);
  }
}

class FaithSettingsScreen extends StatelessWidget {
  const FaithSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(label: 'Prayer settings', children: [
      NavRow('Calculation method', value: app.values['method'], onTap: () => Navigator.pushNamed(context, '/faith/settings/method')),
      NavRow('Asr calculation', subtitle: app.values['asr'], onTap: () => Navigator.pushNamed(context, '/faith/settings/asr')),
    ]);
  }
}

class AsrScreen extends StatelessWidget {
  const AsrScreen({super.key});
  @override
  Widget build(BuildContext context) => const ChoiceScreen(label: 'Asr calculation', headline: 'Asr calculation', valueKey: 'asr', options: [
        ('Shafi\'i, Maliki and Hanbali', 'Shadow equals object length'),
        ('Hanafi', 'Shadow equals twice object length'),
      ]);
}

class MethodScreen extends StatelessWidget {
  const MethodScreen({super.key});
  @override
  Widget build(BuildContext context) => const ChoiceScreen(label: 'Calculation method', headline: 'Calculation method', valueKey: 'method', options: [
        ('MWL', 'Muslim World League'),
        ('Jafari', 'Shia Ithna Ashari, Leva Institute, Qum'),
        ('Karachi', 'University of Islamic Sciences, Karachi'),
        ('ISNA', 'Islamic Society of North America'),
        ('Makkah', 'Umm al-Qura University, Makkah'),
        ('Egypt', 'Egyptian General Authority of Survey'),
      ]);
}

class TasbihGoalsScreen extends StatelessWidget {
  const TasbihGoalsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    void pick(String key) {
      for (final k in ['tasbih.33', 'tasbih.100', 'tasbih.custom']) {
        app.toggles[k] = k == key;
      }
      app.update(() {});
    }

    return AlviPage(label: 'Tasbih goals', children: [
      const Headline('Choose a round.', sub: 'Two pulses on your wrist at the end of each round.'),
      const SectionLabel('Daily'),
      RadioRow('33 × N', subtitle: 'Rounds of 33', selected: app.toggle('tasbih.33'), onTap: () => pick('tasbih.33')),
      RadioRow('100 × N', subtitle: 'Rounds of 100', selected: app.toggle('tasbih.100'), onTap: () => pick('tasbih.100')),
      const SectionLabel('Custom'),
      RadioRow('${app.values['tasbihCustom']}', subtitle: 'Your own round', selected: app.toggle('tasbih.custom'), onTap: () => pick('tasbih.custom')),
      NavRow('Set custom round', onTap: () => Navigator.pushNamed(context, '/faith/tasbih/custom')),
      NavRow('Long target', value: app.values['tasbihTarget'], onTap: () => Navigator.pushNamed(context, '/faith/tasbih/target')),
    ]);
  }
}

class TasbihTargetScreen extends StatelessWidget {
  const TasbihTargetScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(label: 'Tasbih target', children: [
      const Headline('A longer target.', sub: 'For a day of remembrance.'),
      const SizedBox(height: 16),
      NavRow('Target', value: app.values['tasbihTarget'], onTap: () async {
        final v = await pickNumber(context, title: 'Target', value: double.parse(app.values['tasbihTarget']!), step: 100, min: 100, max: 10000, unit: 'count');
        if (v != null) app.setValue('tasbihTarget', v.round().toString());
      }),
    ]);
  }
}

class TasbihCustomScreen extends StatelessWidget {
  const TasbihCustomScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(
      label: 'Custom tasbih',
      trailing: BarIcon(icon: Icons.history, label: 'History', onTap: () => Navigator.pushNamed(context, '/faith/tasbih/history')),
      footer: [PrimaryButton('Start', onPressed: () => Navigator.popUntil(context, (r) => r.settings.name == '/faith' || r.isFirst))],
      children: [
        const Headline('Pick a round size.'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final n in ['11', '21', '33', '60', '99', '100', '500'])
            AlviChip(n, selected: app.values['tasbihCustom'] == n, onTap: () {
              app.setValue('tasbihCustom', n);
              for (final k in ['tasbih.33', 'tasbih.100']) {
                app.toggles[k] = false;
              }
              app.setToggle('tasbih.custom', true);
            }),
        ]),
      ],
    );
  }
}

class TasbihHistoryScreen extends StatelessWidget {
  const TasbihHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    if (app.tasbihHistory.isEmpty) {
      return const EmptyListScreen(label: 'Tasbih history', title: 'No records yet.', body: 'Cleared counts are saved here.', icon: Icons.event_note_outlined);
    }
    return AlviPage(label: 'Tasbih history', children: [for (final h in app.tasbihHistory) NavRow('Count', value: h, mono: true, chevron: false)]);
  }
}

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(label: 'Quran', children: [
        NavRow('Surahs', value: '114', onTap: () => Navigator.pushNamed(context, '/faith/quran/chapters')),
        NavRow('Bookmarks', value: '${context.app.quranBookmarks.length}', onTap: () => Navigator.pushNamed(context, '/faith/quran/bookmarks')),
      ]);
}

class SurahsScreen extends StatelessWidget {
  const SurahsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Scaffold(
      backgroundColor: context.alvi.surface,
      body: AlviBackground(
        child: SafeArea(
          child: Column(children: [
            const AlviTopBar(label: 'Surahs'),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: Space.side),
                itemCount: Sample.surahs.length,
                itemBuilder: (context, i) {
                  final name = '${i + 1}. ${Sample.surahs[i]}';
                  final saved = app.quranBookmarks.contains(name);
                  return NavRow(name,
                      value: saved ? 'Saved' : null,
                      onTap: () => showSheet<void>(context, (ctx) => [
                            Text(name, style: AlviType.headline(ctx, size: 24)),
                            const SizedBox(height: 12),
                            Text('Verse text needs a licensed, verified source, which is not bundled in this build.', style: AlviType.bodySmall(ctx)),
                            const SizedBox(height: 24),
                            PrimaryButton(saved ? 'Remove bookmark' : 'Bookmark', onPressed: () {
                              app.update(() {
                                if (saved) {
                                  app.quranBookmarks.remove(name);
                                } else {
                                  app.quranBookmarks.add(name);
                                }
                              });
                              Navigator.pop(ctx);
                            }),
                          ]));
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class QuranBookmarksScreen extends StatelessWidget {
  const QuranBookmarksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    if (app.quranBookmarks.isEmpty) {
      return const EmptyListScreen(label: 'Bookmarks', title: 'No bookmarks.', body: 'Bookmark a surah to find it here.', icon: Icons.bookmark_border);
    }
    return AlviPage(label: 'Bookmarks', children: [for (final b in app.quranBookmarks) NavRow(b, chevron: false)]);
  }
}

class NamesScreen extends StatelessWidget {
  const NamesScreen({super.key});
  @override
  Widget build(BuildContext context) => AlviPage(label: '99 Names', children: [
        NavRow('The 99 Names', onTap: () => showSheet<void>(context, (ctx) => [
              Text('The 99 Names', style: AlviType.headline(ctx, size: 24)),
              const SizedBox(height: 12),
              Text('The list loads from a verified content source, which is not bundled in this build.', style: AlviType.bodySmall(ctx)),
            ])),
        NavRow('Saved names', value: '${context.app.savedNames.length}', onTap: () => Navigator.pushNamed(context, '/faith/names/saved')),
      ]);
}

class SavedNamesScreen extends StatelessWidget {
  const SavedNamesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const EmptyListScreen(label: 'Saved names', title: 'No saved names.', body: 'Names you save appear here.', icon: Icons.star_border);
}
