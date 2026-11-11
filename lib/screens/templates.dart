import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../state/app_state.dart';
import '../widgets/widgets.dart';

/// Configuration for metric detail screens (oxygen, HRV, stress, temperature, glucose, UV, BP).
class MetricConfig {
  final String label;
  final List<String> numeral;
  final String insight;
  final String? toggleKey, toggleTitle, toggleBody;
  final List<num> series;
  final String tone;
  final String rangeLabel;
  final List<(String, String)> stats;
  final List<(String, String, double, String)> distribution; // label, value, fraction, tone
  final String? distributionTitle;
  final String? aboutRoute;
  final List<String> explainer;
  final String disclaimer;
  final bool periods;
  final String measuredAgo;

  const MetricConfig({
    required this.label,
    required this.numeral,
    required this.insight,
    this.toggleKey,
    this.toggleTitle,
    this.toggleBody,
    required this.series,
    required this.tone,
    required this.rangeLabel,
    this.stats = const [],
    this.distribution = const [],
    this.distributionTitle,
    this.aboutRoute,
    this.explainer = const [],
    this.disclaimer = 'General wellness guidance, not medical advice.',
    this.periods = false,
    this.measuredAgo = 'MEASURED 2 MIN AGO',
  });
}

class MetricScreen extends StatefulWidget {
  const MetricScreen(this.config, {super.key});
  final MetricConfig config;
  @override
  State<MetricScreen> createState() => _MetricScreenState();
}

class _MetricScreenState extends State<MetricScreen> {
  String period = 'Day';

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;
    final app = context.app;
    final color = toneColor(context, cfg.tone);
    return AlviPage(
      label: cfg.label,
      sample: true,
      trailing: cfg.aboutRoute == null
          ? null
          : BarIcon(icon: Icons.info_outline, label: 'About ${cfg.label}', onTap: () => Navigator.pushNamed(context, cfg.aboutRoute!)),
      children: [
        if (cfg.periods) ...[
          AlviSegmented(options: const ['Day', 'Week', 'Month'], selected: period, onChanged: (v) => setState(() => period = v)),
          const SizedBox(height: 8),
        ],
        DateStepper(period: period),
        Align(alignment: Alignment.centerRight, child: Text(cfg.measuredAgo, style: AlviType.data(context, size: 11, color: context.alvi.inkMuted))),
        DisplayNumeral(cfg.numeral, size: 80),
        const SizedBox(height: 12),
        Text(cfg.insight, style: AlviType.insight(context)),
        const SizedBox(height: 24),
        LineChartView(values: cfg.series, color: color, rangeLabel: cfg.rangeLabel, title: period == 'Day' ? 'TODAY' : period.toUpperCase()),
        const SizedBox(height: 16),
        if (cfg.stats.isNotEmpty) StatGrid([for (final s in cfg.stats) StatCell(s.$1, s.$2, size: 24)], columns: cfg.stats.length.clamp(1, 3)),
        if (cfg.toggleKey != null)
          ToggleRow(cfg.toggleTitle!, subtitle: cfg.toggleBody, value: app.toggle(cfg.toggleKey!), onChanged: (v) => app.setToggle(cfg.toggleKey!, v)),
        if (cfg.distribution.isNotEmpty) ...[
          SectionLabel(cfg.distributionTitle ?? 'Time in range today'),
          LabelledBars(rows: [for (final d in cfg.distribution) (d.$1, d.$2, d.$3, toneColor(context, d.$4))]),
        ],
        if (cfg.explainer.isNotEmpty) ...[
          const SectionLabel('What this means'),
          for (final p in cfg.explainer) Para(p, muted: true, top: 6),
        ],
        Disclaimer(cfg.disclaimer),
      ],
    );
  }
}

/// Long-form explainer: headline then titled sections or numbered steps.
class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.label, required this.headline, this.intro, this.sections = const [], this.steps = const [], this.footer, this.illustration});
  final String label, headline;
  final String? intro;
  final List<(String, String)> sections;
  final List<String> steps;
  final List<Widget>? footer;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) => AlviPage(
        label: label,
        footer: footer,
        children: [
          Headline(headline, sub: intro),
          if (illustration != null) Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Center(child: illustration)),
          for (var i = 0; i < steps.length; i++) NumberedRow(i + 1, steps[i]),
          for (final s in sections) ...[
            SectionLabel(s.$1),
            Text(s.$2, style: AlviType.body(context, color: context.alvi.inkBody)),
          ],
        ],
      );
}

/// Settings page made of toggle rows bound to AppState.toggles, plus optional value rows.
class ToggleSettingsScreen extends StatelessWidget {
  const ToggleSettingsScreen({super.key, required this.label, this.headline, this.intro, required this.toggles, this.extra = const [], this.note});
  final String label;
  final String? headline, intro;
  final List<(String key, String title, String? subtitle)> toggles;
  final List<Widget> extra;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(label: label, children: [
      if (headline != null) Headline(headline!, sub: intro),
      if (headline != null) const SizedBox(height: 16),
      for (final t in toggles) ToggleRow(t.$2, subtitle: t.$3, value: app.toggle(t.$1), onChanged: (v) => app.setToggle(t.$1, v)),
      ...extra,
      if (note != null) Disclaimer(note!),
    ]);
  }
}

/// Simple screen with an empty state (lists with no records yet).
class EmptyListScreen extends StatelessWidget {
  const EmptyListScreen({super.key, required this.label, required this.title, required this.body, this.icon, this.action, this.onAction, this.trailing, this.top = const []});
  final String label, title, body;
  final IconData? icon;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;
  final List<Widget> top;

  @override
  Widget build(BuildContext context) => AlviPage(label: label, trailing: trailing, children: [
        ...top,
        SizedBox(height: top.isEmpty ? Space.s48 : Space.s16),
        EmptyState(title: title, body: body, icon: icon, action: action, onAction: onAction),
      ]);
}

/// Single-choice list bound to AppState.values[key].
class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key, required this.label, required this.headline, this.intro, required this.valueKey, required this.options});
  final String label, headline, valueKey;
  final String? intro;
  final List<(String, String?)> options;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return AlviPage(label: label, children: [
      Headline(headline, sub: intro),
      const SizedBox(height: 16),
      for (final o in options) RadioRow(o.$1, subtitle: o.$2, selected: app.values[valueKey] == o.$1, onTap: () => app.setValue(valueKey, o.$1)),
    ]);
  }
}

/// About/explainer screen with titled sections and the wellness disclaimer.
class ArticleBody extends StatelessWidget {
  const ArticleBody({super.key, required this.label, required this.headline, required this.sections});
  final String label, headline;
  final List<(String, String)> sections;
  @override
  Widget build(BuildContext context) => AlviPage(label: label, children: [
        Headline(headline),
        for (final s in sections) ...[
          SectionLabel(s.$1),
          Text(s.$2, style: AlviType.body(context, color: context.alvi.inkBody)),
        ],
        const Disclaimer('General wellness guidance, not medical advice.'),
      ]);
}
