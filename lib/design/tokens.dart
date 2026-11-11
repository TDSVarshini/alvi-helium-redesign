import 'package:flutter/material.dart';

/// ALVI Helium design tokens, V1.2 (developer handoff page 2 plus V1.1 additions).
/// Accent colours are for graphics only (rings, charts, dots), never body text.
@immutable
class AlviColors extends ThemeExtension<AlviColors> {
  final Color surface, surfaceRaised, chartBand, divider, lineStrong, borderControl;
  final Color ink, inkBody, inkMuted;
  final Color readiness, sleep, sleepRem, sleepLight, heart, oxygen, activity, tempWeather;
  final Color good, caution, alert;
  final bool isDark;

  const AlviColors({
    required this.surface,
    required this.surfaceRaised,
    required this.chartBand,
    required this.divider,
    required this.lineStrong,
    required this.borderControl,
    required this.ink,
    required this.inkBody,
    required this.inkMuted,
    required this.readiness,
    required this.sleep,
    required this.sleepRem,
    required this.sleepLight,
    required this.heart,
    required this.oxygen,
    required this.activity,
    required this.tempWeather,
    required this.good,
    required this.caution,
    required this.alert,
    required this.isDark,
  });

  static const dark = AlviColors(
    surface: Color(0xFF111111),
    surfaceRaised: Color(0xFF1B1B1B),
    chartBand: Color(0xFF1E1E1E),
    divider: Color(0xFF2A2A2A),
    lineStrong: Color(0xFF333333),
    borderControl: Color(0xFF707070),
    ink: Color(0xFFFFFFFF),
    inkBody: Color(0xFFCCCCCC),
    inkMuted: Color(0xFF999999),
    readiness: Color(0xFF5FB8B1),
    sleep: Color(0xFFB4BCF2),
    sleepRem: Color(0xFF8C97E0),
    sleepLight: Color(0xFF6A75BE),
    heart: Color(0xFFE07A6C),
    oxygen: Color(0xFF6FA3D8),
    activity: Color(0xFF6FB085),
    tempWeather: Color(0xFFD9A15B),
    good: Color(0xFF5FB8B1),
    caution: Color(0xFFD9A15B),
    alert: Color(0xFFE07A6C),
    isDark: true,
  );

  static const light = AlviColors(
    surface: Color(0xFFE4E4E4),
    surfaceRaised: Color(0xFFDADADA),
    chartBand: Color(0xFFD3D3D3),
    divider: Color(0xFFC6C6C6),
    lineStrong: Color(0xFFBDBDBD),
    borderControl: Color(0xFF757575),
    ink: Color(0xFF000000),
    inkBody: Color(0xFF2E2E2E),
    inkMuted: Color(0xFF555555),
    readiness: Color(0xFF2F7D78),
    sleep: Color(0xFF4C58A8),
    sleepRem: Color(0xFF7380C6),
    sleepLight: Color(0xFF9AA3D6),
    heart: Color(0xFFC4574A),
    oxygen: Color(0xFF3A6EA5),
    activity: Color(0xFF4E8264),
    tempWeather: Color(0xFFA8642A),
    good: Color(0xFF2F7D78),
    caution: Color(0xFFA8642A),
    alert: Color(0xFFC4574A),
    isDark: false,
  );

  /// Light theme background: linear-gradient(90deg, #D8D8D8 -> #E8E8E8). Dark: flat #111111.
  Gradient? get backgroundGradient => isDark
      ? null
      : const LinearGradient(colors: [Color(0xFFD8D8D8), Color(0xFFE8E8E8)]);

  @override
  AlviColors copyWith() => this;

  @override
  AlviColors lerp(ThemeExtension<AlviColors>? other, double t) =>
      (other is AlviColors && t > 0.5) ? other : this;
}

/// Spacing scale in logical points: 4, 8, 12, 16, 24, 32, 48, 64.
class Space {
  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s24 = 24, s32 = 32, s48 = 48, s64 = 64;

  /// Side margins 24 pt; top padding 40 pt below the OS status bar.
  static const double side = 24;
  static const double top = 40;
}

/// Corner radii: 0 dividers, 4 tags, 8 cards, pill buttons.
class Radii {
  static const double divider = 0, tag = 4, card = 8, pill = 999;
}

/// Motion: glyph pulses mirror the band (short 120 ms, long 400 ms, gap 150 ms).
class Motion {
  static const short = Duration(milliseconds: 120);
  static const long = Duration(milliseconds: 400);
  static const gap = Duration(milliseconds: 150);
}

/// Component sizes from the spec.
class Sizes {
  static const double primaryButton = 56, secondaryButton = 52, listRowMin = 56, touch = 44, tabBar = 84;
}

extension AlviContext on BuildContext {
  AlviColors get alvi => Theme.of(this).extension<AlviColors>() ?? AlviColors.dark;
}
