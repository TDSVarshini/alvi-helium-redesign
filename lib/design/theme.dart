import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

ThemeData buildAlviTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AlviColors.dark : AlviColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.ink,
    onPrimary: c.surface,
    secondary: c.inkBody,
    onSecondary: c.surface,
    error: c.alert,
    onError: c.surface,
    surface: c.surface,
    onSurface: c.ink,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: c.surface,
    fontFamily: AlviType.sans,
    dividerColor: c.divider,
    splashFactory: NoSplash.splashFactory,
    highlightColor: c.ink.withAlpha(12),
    extensions: [c],
    textSelectionTheme: TextSelectionThemeData(cursorColor: c.ink, selectionColor: c.ink.withAlpha(50)),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surfaceRaised,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.card * 2))),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.ink,
      contentTextStyle: TextStyle(fontFamily: AlviType.sans, color: c.surface, fontSize: 14),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
