import 'package:flutter/material.dart';

import '../app/screen_catalog.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../services/sample_wearable_service.dart';
import '../services/wearable_service.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';

/// Screen index: every QWatch Pro screen, its ALVI redesign, and a link to open it.
class ScreenIndexScreen extends StatefulWidget {
  const ScreenIndexScreen({super.key});
  @override
  State<ScreenIndexScreen> createState() => _ScreenIndexScreenState();
}

class _ScreenIndexScreenState extends State<ScreenIndexScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final items = screenMappings
        .where((m) => query.isEmpty || '${m.oldTitle} ${m.newTitle} ${m.oldId}'.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final sections = <String>{for (final m in items) m.oldSection};
    return Scaffold(
      backgroundColor: c.surface,
      body: AlviBackground(
        child: SafeArea(
          child: Column(children: [
            const AlviTopBar(label: 'Screen index'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.side),
              child: TextField(
                style: AlviType.body(context),
                onChanged: (v) => setState(() => query = v),
                decoration: InputDecoration(
                  hintText: 'Search ${screenMappings.length} QWatch Pro screens',
                  hintStyle: AlviType.body(context, color: c.inkMuted),
                  prefixIcon: Icon(Icons.search, color: c.inkMuted),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.lineStrong)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.ink)),
                ),
              ),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(Space.side, 8, Space.side, 32), children: [
                for (final s in sections) ...[
                  SectionLabel(s),
                  for (final m in items.where((m) => m.oldSection == s))
                    NavRow(
                      '${m.n}. ${m.oldTitle}',
                      subtitle: m.route.isEmpty ? '${m.status}: ${m.notes}' : '→ ${m.newTitle} · ${m.status}',
                      value: m.route.isEmpty ? 'N/A' : null,
                      onTap: m.route.isEmpty ? null : () => Navigator.pushNamed(context, m.route),
                    ),
                ],
                const SectionLabel('ALVI screens added from the design system'),
                for (final n in newAlviScreens) NavRow(n[0], subtitle: n[2], onTap: () => Navigator.pushNamed(context, n[1])),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Device simulator: drives SampleWearableService so every connection state and
/// capability-gated screen can be reviewed without the ALVI SDK.
class DeviceSimulatorScreen extends StatelessWidget {
  const DeviceSimulatorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final w = app.wearable;
    if (w is! SampleWearableService) {
      return AlviPage(label: 'Device simulator', children: const [Para('A real wearable service is active. The simulator is off.')]);
    }
    final allCaps = identical(w.simulatedCapabilities, BandCapabilities.all);
    return AlviPage(label: 'Device simulator', children: [
      const SampleNotice(),
      Text('Connection: ${w.connection.name}', style: AlviType.data(context, size: 12)),
      const SectionLabel('Jump to a state'),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in [BandConnection.notPaired, BandConnection.connected, BandConnection.disconnected, BandConnection.syncFailed, BandConnection.connecting])
          AlviChip(s.name, selected: w.connection == s, onTap: () => app.update(() => w.simulate(s))),
      ]),
      const SectionLabel('Failures'),
      ToggleRow('Next scan finds nothing', value: w.failNextScan, onChanged: (v) => app.update(() => w.failNextScan = v)),
      ToggleRow('Next sync fails', value: w.failNextSync, onChanged: (v) => app.update(() => w.failNextSync = v)),
      const SectionLabel('Capabilities'),
      ToggleRow('Enable every capability',
          subtitle: 'Display, microphone, speaker, cellular, ECG, blood pressure, glucose, UV. For reviewing gated screens only.',
          value: allCaps,
          onChanged: (v) => app.update(() => w.simulatedCapabilities = v ? BandCapabilities.all : BandCapabilities.heliumDesignTarget)),
      const SectionLabel('Theme'),
      Wrap(spacing: 8, children: [
        AlviChip('Dark', selected: app.themeMode == ThemeMode.dark, onTap: () => app.setTheme(ThemeMode.dark)),
        AlviChip('Light', selected: app.themeMode == ThemeMode.light, onTap: () => app.setTheme(ThemeMode.light)),
      ]),
      const Disclaimer('Everything here is simulated. Replace SampleWearableService with the ALVI SDK implementation of WearableService.'),
    ]);
  }
}
