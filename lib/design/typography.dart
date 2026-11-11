import 'package:flutter/material.dart';

import 'tokens.dart';

/// ALVI type scale (V1.2 page 2).
/// Display numeral Inter Light 72–104 / 1.0; Headline Inter SemiBold 30–36 / 1.18, -0.01em;
/// Insight Inter Light 20/29; Body Inter Regular 16/25; Label Inter Medium 11/16 caps +0.2em;
/// Spec/data JetBrains Mono Bold 11–13; Fine print Inter Regular 12/18.
class AlviType {
  static const String sans = 'Inter';
  static const String mono = 'JetBrainsMono';

  static TextStyle display(BuildContext c, {double size = 88, Color? color}) => TextStyle(
      fontFamily: sans, fontWeight: FontWeight.w300, fontSize: size, height: 1.0,
      letterSpacing: -size * 0.02, color: color ?? c.alvi.ink);

  static TextStyle headline(BuildContext c, {double size = 30, Color? color}) => TextStyle(
      fontFamily: sans, fontWeight: FontWeight.w600, fontSize: size, height: 1.18,
      letterSpacing: -size * 0.01, color: color ?? c.alvi.ink);

  static TextStyle insight(BuildContext c, {Color? color}) => TextStyle(
      fontFamily: sans, fontWeight: FontWeight.w300, fontSize: 20, height: 29 / 20, color: color ?? c.alvi.ink);

  static TextStyle body(BuildContext c, {Color? color, FontWeight weight = FontWeight.w400}) => TextStyle(
      fontFamily: sans, fontWeight: weight, fontSize: 16, height: 25 / 16, color: color ?? c.alvi.ink);

  static TextStyle bodySmall(BuildContext c, {Color? color}) => TextStyle(
      fontFamily: sans, fontWeight: FontWeight.w400, fontSize: 14, height: 20 / 14, color: color ?? c.alvi.inkBody);

  /// Labels drop tracking to 0.12em when longer than 18 characters (French rule).
  static TextStyle label(BuildContext c, {Color? color, String? text}) {
    final long = (text?.length ?? 0) > 18;
    return TextStyle(
        fontFamily: sans, fontWeight: FontWeight.w500, fontSize: 11, height: 16 / 11,
        letterSpacing: 11 * (long ? 0.12 : 0.2), color: color ?? c.alvi.inkMuted);
  }

  static TextStyle data(BuildContext c, {double size = 12, Color? color}) => TextStyle(
      fontFamily: mono, fontWeight: FontWeight.w700, fontSize: size, height: 1.3,
      letterSpacing: 0.4, color: color ?? c.alvi.inkBody);

  static TextStyle fine(BuildContext c, {Color? color}) => TextStyle(
      fontFamily: sans, fontWeight: FontWeight.w400, fontSize: 12, height: 18 / 12, color: color ?? c.alvi.inkMuted);

  static TextStyle stat(BuildContext c, {double size = 28, Color? color}) => TextStyle(
      fontFamily: sans, fontWeight: FontWeight.w300, fontSize: size, height: 1.1, color: color ?? c.alvi.ink);
}
