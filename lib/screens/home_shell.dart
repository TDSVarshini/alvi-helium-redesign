import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import 'activity.dart';
import 'heart.dart';
import 'sleep.dart';
import 'today.dart';
import 'you.dart';

/// Tab bar: 5 items (Today, Sleep, Heart, Activity, You), 84 pt including the home indicator.
/// Replaces QWatch Pro's Data / Device / My bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initial = 0});
  final int initial;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int index = widget.initial;

  static const tabs = [
    ('Today', Icons.radio_button_checked),
    ('Sleep', Icons.nightlight_outlined),
    ('Heart', Icons.monitor_heart_outlined),
    ('Activity', Icons.directions_walk),
    ('You', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final accents = [c.readiness, c.sleep, c.heart, c.activity, c.ink];
    return Scaffold(
      backgroundColor: c.surface,
      body: IndexedStack(index: index, children: const [TodayTab(), SleepTab(), HeartTab(), ActivityTab(), YouTab()]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.divider))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == index,
                    button: true,
                    label: tabs[i].$1,
                    child: InkWell(
                      onTap: () => setState(() => index = i),
                      child: ExcludeSemantics(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(tabs[i].$2, size: 22, color: i == index ? accents[i] : c.inkMuted),
                          const SizedBox(height: 4),
                          Text(tabs[i].$1,
                              style: TextStyle(
                                  fontFamily: AlviType.sans,
                                  fontSize: 11,
                                  fontWeight: i == index ? FontWeight.w600 : FontWeight.w400,
                                  color: i == index ? c.ink : c.inkMuted)),
                        ]),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Tab root layout: background, safe area, connection banner, scrolling content, no top bar.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.children, this.header});
  final List<Widget> children;
  final Widget? header;
  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return DecoratedBox(
      decoration: BoxDecoration(color: c.surface, gradient: c.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          if (header != null) header!,
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Space.side, Space.s24, Space.side, Space.s32),
              children: children,
            ),
          ),
        ]),
      ),
    );
  }
}
