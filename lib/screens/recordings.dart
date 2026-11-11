import 'dart:async';

import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../widgets/widgets.dart';
import 'templates.dart';

/// All recording screens need a microphone on the band. Helium does not report one,
/// so each is wrapped in a CapabilityGate (preview via Developer › Device simulator).
const _reason = 'Recordings need a band with a microphone. Helium has none.';

Widget _gate(Widget child) => CapabilityGate(capability: 'microphone', featureName: 'Recordings', reason: _reason, child: child);

/// Recordings (QWatch Pro "Recording Memos").
class RecordingsScreen extends StatelessWidget {
  const RecordingsScreen({super.key});
  @override
  Widget build(BuildContext context) => _gate(AlviPage(
        label: 'Recordings',
        sample: true,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          BarIcon(icon: Icons.checklist, label: 'Select', onTap: () => Navigator.pushNamed(context, '/recordings/select')),
          BarIcon(icon: Icons.help_outline, label: 'How transcription works', onTap: () => Navigator.pushNamed(context, '/recordings/help')),
        ]),
        children: [
          NavRow('Team stand-up', subtitle: '10 Nov · 00:11:24', onTap: () => Navigator.pushNamed(context, '/recordings/detail')),
          NavRow('Voice note', subtitle: '9 Nov · 00:00:48', onTap: () => Navigator.pushNamed(context, '/recordings/player')),
          const SectionLabel('More'),
          NavRow('Meeting minutes', onTap: () => Navigator.pushNamed(context, '/recordings/minutes')),
          NavRow('Audio files on this phone', onTap: () => Navigator.pushNamed(context, '/recordings/files')),
        ],
      ));
}

class _Player extends StatefulWidget {
  const _Player({this.length = 684});
  final int length;
  @override
  State<_Player> createState() => _PlayerState();
}

class _PlayerState extends State<_Player> {
  double pos = 0;
  bool playing = false;
  String speed = '1x';
  Timer? t;

  String fmt(double s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).floor().toString().padLeft(2, '0')}';

  void toggle() {
    setState(() => playing = !playing);
    t?.cancel();
    if (playing) {
      t = Timer.periodic(const Duration(milliseconds: 250), (_) {
        setState(() {
          pos += 0.25 * double.parse(speed.replaceAll('x', ''));
          if (pos >= widget.length) {
            pos = 0;
            playing = false;
            t?.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Column(children: [
      SliderTheme(
        data: SliderThemeData(activeTrackColor: c.ink, inactiveTrackColor: c.lineStrong, thumbColor: c.ink, trackHeight: 2, overlayShape: SliderComponentShape.noOverlay),
        child: Slider(value: pos, max: widget.length.toDouble(), onChanged: (v) => setState(() => pos = v), semanticFormatterCallback: (v) => fmt(v)),
      ),
      Row(children: [Text(fmt(pos), style: AlviType.data(context, size: 11)), const Spacer(), Text(fmt(widget.length.toDouble()), style: AlviType.data(context, size: 11))]),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(width: 56),
        CircleIconButton(icon: playing ? Icons.pause : Icons.play_arrow, label: playing ? 'Pause' : 'Play', filled: true, size: 72, onTap: toggle),
        const SizedBox(width: 16),
        SizedBox(
          width: 56,
          child: AlviChip(speed, selected: false, onTap: () => setState(() => speed = speed == '1x' ? '1.5x' : (speed == '1.5x' ? '2x' : '1x'))),
        ),
      ]),
    ]);
  }
}

/// Recording (QWatch Pro "Recording Details" with Start transcription).
class RecordingDetailScreen extends StatefulWidget {
  const RecordingDetailScreen({super.key});
  @override
  State<RecordingDetailScreen> createState() => _RecordingDetailScreenState();
}

class _RecordingDetailScreenState extends State<RecordingDetailScreen> {
  bool transcribed = false;
  @override
  Widget build(BuildContext context) => _gate(AlviPage(
        label: 'Recording',
        sample: true,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          BarIcon(icon: Icons.edit_outlined, label: 'Edit transcript', onTap: () => Navigator.pushNamed(context, '/recordings/detail/edit')),
          BarIcon(icon: Icons.ios_share, label: 'Share', onTap: () => toast(context, 'Share sheet opens here')),
        ]),
        footer: const [_Player()],
        children: [
          const Headline('Team stand-up', size: 26),
          Text('10 NOV · 00:11:24', style: AlviType.data(context, size: 11)),
          const SizedBox(height: 24),
          if (!transcribed) ...[
            Text('No transcript yet.', style: AlviType.bodySmall(context)),
            const SizedBox(height: 16),
            SecondaryButton('Start transcription', onPressed: () => setState(() => transcribed = true)),
          ] else
            Text('[Sample transcript] Sam: Morning everyone. Priya: The build is green. Leo: I will take the release notes.', style: AlviType.body(context)),
        ],
      ));
}

class TranscriptEditScreen extends StatelessWidget {
  const TranscriptEditScreen({super.key});
  @override
  Widget build(BuildContext context) => _gate(AlviPage(label: 'Edit transcript', trailing: BarText('Done', onTap: () => Navigator.pop(context)), children: [
        AlviField(label: 'Transcript', hint: 'Edit text', maxLines: 12, controller: TextEditingController(text: 'Sam: Morning everyone. Priya: The build is green.')),
      ]));
}

class TranscriptionHelpScreen extends StatelessWidget {
  const TranscriptionHelpScreen({super.key});
  @override
  Widget build(BuildContext context) => _gate(const ArticleScreen(label: 'How transcription works', headline: 'Two steps.', steps: [
        'Record on your band, then import the audio into Recordings.',
        'Open Audio files, choose a recording and start transcription.',
      ]));
}

class AudioFilesScreen extends StatelessWidget {
  const AudioFilesScreen({super.key});
  @override
  Widget build(BuildContext context) => _gate(EmptyListScreen(
        label: 'Audio files',
        title: 'No audio files.',
        body: 'Audio you import from this phone appears here.',
        icon: Icons.mic_none,
        trailing: BarIcon(icon: Icons.help_outline, label: 'Help', onTap: () => Navigator.pushNamed(context, '/recordings/help')),
      ));
}

class MinutesDetailScreen extends StatefulWidget {
  const MinutesDetailScreen({super.key});
  @override
  State<MinutesDetailScreen> createState() => _MinutesDetailScreenState();
}

class _MinutesDetailScreenState extends State<MinutesDetailScreen> {
  bool original = false;
  @override
  Widget build(BuildContext context) => _gate(AlviPage(
        label: 'Minutes',
        sample: true,
        trailing: BarIcon(icon: Icons.edit_outlined, label: 'Edit minutes', onTap: () => Navigator.pushNamed(context, '/recordings/minutes/edit')),
        footer: const [_Player(length: 11)],
        children: [
          Text('00:00:11 · 10 NOV', style: AlviType.data(context, size: 11)),
          const SizedBox(height: 12),
          Row(children: [AlviChip('Summary', selected: !original, onTap: () => setState(() => original = false)), const SizedBox(width: 8), AlviChip('Original text', selected: original, onTap: () => setState(() => original = true))]),
          const SizedBox(height: 16),
          Text(original ? '[Sample] Sam: Morning everyone…' : '[Sample summary] Build is green. Leo owns release notes.', style: AlviType.body(context)),
        ],
      ));
}

class MinutesEditScreen extends StatelessWidget {
  const MinutesEditScreen({super.key});
  @override
  Widget build(BuildContext context) => _gate(AlviPage(label: 'Edit minutes', trailing: BarText('Done', onTap: () => Navigator.pop(context)), children: [
        AlviField(label: 'Minutes', maxLines: 12, controller: TextEditingController(text: 'Build is green. Leo owns release notes.')),
      ]));
}

class MinutesScreen extends StatelessWidget {
  const MinutesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return _gate(AlviPage(
      label: 'Meeting minutes',
      footer: [Center(child: CircleIconButton(icon: Icons.mic, label: 'Start recording', filled: true, size: 72, onTap: () => toast(context, 'Recording starts on the band')))],
      children: [
        TextField(
          style: AlviType.body(context),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: c.inkMuted),
            hintText: 'Search recordings',
            hintStyle: AlviType.body(context, color: c.inkMuted),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.pill), borderSide: BorderSide(color: c.borderControl)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.pill), borderSide: BorderSide(color: c.ink)),
          ),
        ),
        const SizedBox(height: 16),
        NavRow('Team stand-up', subtitle: '10 Nov · sample', onTap: () => Navigator.pushNamed(context, '/recordings/minutes/detail')),
      ],
    ));
  }
}

class SelectRecordingsScreen extends StatefulWidget {
  const SelectRecordingsScreen({super.key});
  @override
  State<SelectRecordingsScreen> createState() => _SelectRecordingsScreenState();
}

class _SelectRecordingsScreenState extends State<SelectRecordingsScreen> {
  final items = ['Team stand-up', 'Voice note'];
  final selected = <String>{};
  @override
  Widget build(BuildContext context) => _gate(AlviPage(
        label: 'Select',
        lead: TopBarLead.close,
        trailing: BarText(selected.length == items.length ? 'None' : 'All',
            onTap: () => setState(() {
                  if (selected.length == items.length) {
                    selected.clear();
                  } else {
                    selected.addAll(items);
                  }
                })),
        footer: [
          SecondaryButton('Delete ${selected.length}', destructive: true, onPressed: selected.isEmpty
              ? null
              : () async {
                  if (await confirmAction(context, title: 'Delete ${selected.length} recordings?', body: 'They are removed from this phone.', confirm: 'Delete', destructive: true)) {
                    setState(() {
                      items.removeWhere(selected.contains);
                      selected.clear();
                    });
                  }
                }),
        ],
        children: [
          for (final i in items)
            ToggleRow(i, value: selected.contains(i), onChanged: (v) => setState(() => v ? selected.add(i) : selected.remove(i))),
          if (items.isEmpty) const EmptyState(title: 'No recordings.', body: 'Record and upload on the band.', icon: Icons.mic_none),
        ],
      ));
}

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});
  @override
  Widget build(BuildContext context) => _gate(AlviPage(label: 'Recording player', sample: true, children: [
        const SizedBox(height: 48),
        const Center(child: CoreIllustration(size: 160, pulsing: true)),
        const SizedBox(height: 32),
        Center(child: Text('Voice note', style: AlviType.headline(context, size: 24))),
        const SizedBox(height: 32),
        const _Player(length: 48),
      ]));
}
