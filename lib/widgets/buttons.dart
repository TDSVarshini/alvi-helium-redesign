import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/typography.dart';

/// Primary: filled pill, 56 pt. Ink on dark is white, on light is black.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.text, {super.key, this.onPressed, this.busy = false});
  final String text;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final enabled = onPressed != null && !busy;
    return Semantics(
      button: true,
      enabled: enabled,
      label: text,
      child: SizedBox(
        height: Sizes.primaryButton,
        child: Material(
          color: enabled ? c.ink : c.ink.withAlpha(90),
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: busy
                  ? SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: c.surface))
                  : Text(text,
                      style: TextStyle(
                          fontFamily: AlviType.sans, fontWeight: FontWeight.w600, fontSize: 16, color: c.surface)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary: outline pill, 52 pt, border-control token (3:1 against surface).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.text, {super.key, this.onPressed, this.destructive = false});
  final String text;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final color = destructive ? c.alert : c.ink;
    return Semantics(
      button: true,
      label: text,
      child: SizedBox(
        height: Sizes.secondaryButton,
        child: Material(
          color: Colors.transparent,
          shape: StadiumBorder(side: BorderSide(color: destructive ? c.alert : c.borderControl)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onPressed,
            child: Center(
              child: Text(text,
                  style: TextStyle(fontFamily: AlviType.sans, fontWeight: FontWeight.w600, fontSize: 16, color: color)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Underlined text link.
class AlviLink extends StatelessWidget {
  const AlviLink(this.text, {super.key, this.onTap, this.center = true});
  final String text;
  final VoidCallback? onTap;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    final link = Semantics(
      button: true,
      label: text,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Sizes.touch),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              widthFactor: 1,
              child: Text(text,
                  style: AlviType.bodySmall(context, color: c.ink).copyWith(
                      decoration: TextDecoration.underline, decorationColor: c.inkMuted, decorationThickness: 1)),
            ),
          ),
        ),
      ),
    );
    return center ? Center(child: link) : link;
  }
}

/// 44 pt circular icon button with an accessible label.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.filled = false,
    this.size = Sizes.touch,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.alvi;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: filled ? c.ink : Colors.transparent,
        shape: CircleBorder(side: BorderSide(color: filled ? c.ink : c.borderControl)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.42, color: filled ? c.surface : c.ink),
          ),
        ),
      ),
    );
  }
}

/// Plain icon action for top bars.
class BarIcon extends StatelessWidget {
  const BarIcon({super.key, required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: InkResponse(
          radius: 24,
          onTap: onTap,
          child: SizedBox(
              width: Sizes.touch, height: Sizes.touch, child: Icon(icon, size: 22, color: context.alvi.ink)),
        ),
      );
}

/// Text action for top bars (Save, Edit, Skip).
class BarText extends StatelessWidget {
  const BarText(this.text, {super.key, this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: text,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Sizes.touch, minWidth: Sizes.touch),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(text, style: AlviType.body(context, weight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      );
}
