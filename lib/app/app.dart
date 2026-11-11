import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../state/app_state.dart';
import 'routes.dart';

class AlviApp extends StatelessWidget {
  const AlviApp({super.key, required this.state, this.initialRoute = '/'});
  final AppState state;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: Builder(
        builder: (context) {
          final app = AppScope.of(context);
          return MaterialApp(
            title: 'ALVI Helium',
            debugShowCheckedModeBanner: false,
            theme: buildAlviTheme(Brightness.light),
            darkTheme: buildAlviTheme(Brightness.dark),
            themeMode: app.themeMode,
            initialRoute: initialRoute,
            onGenerateRoute: onGenerateRoute,
            // Text scales with the system up to 200%; layouts grow rather than truncate.
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(textScaler: mq.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 2.0)),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
