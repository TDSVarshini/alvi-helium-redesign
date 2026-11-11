import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';
import '../state/app_state.dart';
import 'data.dart';

/// Paints the ALVI background: flat #111111 in dark, 90° grey gradient in light.
class AlviBackground extends StatelessWidget {
  const AlviBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return DecoratedBox(
      decoration: BoxDecoration(color: c.surface, gradient: c.backgroundGradient),
      child: child,
    );
  }
}

enum TopBarLead { back, close, none }

/// Centered caps label with a back or close control and optional trailing actions.
class AlviTopBar extends StatelessWidget {
  const AlviTopBar({super.key, this.label = '', this.lead = TopBarLead.back, this.trailing, this.onLead});
  final String label;
  final TopBarLead lead;
  final Widget? trailing;
  final VoidCallback? onLead;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    Widget? leading;
    if (lead != TopBarLead.none) {
      leading = Semantics(
        button: true,
        label: lead == TopBarLead.back ? 'Back' : 'Close',
        child: InkResponse(
          radius: 24,
          onTap: onLead ?? () => Navigator.of(context).maybePop(),
          child: SizedBox(
            width: Sizes.touch,
            height: Sizes.touch,
            child: Icon(lead == TopBarLead.back ? Icons.chevron_left : Icons.close, color: c.ink, size: 26),
          ),
        ),
      );
    }
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 72),
              child: Text(label.toUpperCase(),
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: AlviType.label(context, text: label)),
            ),
          if (leading != null) Positioned(left: Space.side - 12, child: leading),
          if (trailing != null) Positioned(right: Space.side - 12, child: trailing!),
        ],
      ),
    );
  }
}

/// Standard page: background, safe area, top bar, scrolling content with 24 pt side margins,
/// and an optional pinned footer for primary actions.
class AlviPage extends StatelessWidget {
  const AlviPage({
    super.key,
    this.label = '',
    this.lead = TopBarLead.back,
    this.trailing,
    required this.children,
    this.footer,
    this.sample = false,
    this.scroll = true,
    this.showTopBar = true,
    this.onLead,
    this.padding,
  });

  final String label;
  final TopBarLead lead;
  final Widget? trailing;
  final List<Widget> children;
  final List<Widget>? footer;
  final bool sample;
  final bool scroll;
  final bool showTopBar;
  final VoidCallback? onLead;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? const EdgeInsets.fromLTRB(Space.side, Space.s8, Space.side, Space.s24);
    final content = scroll
        ? ListView(padding: pad, children: [if (sample) const SampleNotice(), ...children])
        : Padding(
            padding: pad,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (sample) const SampleNotice(),
              ...children,
            ]));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlviBackground(
        child: SafeArea(
          child: Column(
            children: [
              if (showTopBar) AlviTopBar(label: label, lead: lead, trailing: trailing, onLead: onLead),
              Expanded(child: content),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(Space.side, Space.s8, Space.side, Space.s16),
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: footer!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps tab roots so the band's connection state is always visible when it matters.
class ConnectionAware extends StatelessWidget {
  const ConnectionAware({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Column(children: [
      if (!app.connected) const DeviceStateBanner(),
      Expanded(child: child),
    ]);
  }
}
