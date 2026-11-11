import 'package:alvi_helium/app/app.dart';
import 'package:alvi_helium/app/routes.dart';
import 'package:alvi_helium/app/screen_catalog.dart';
import 'package:alvi_helium/screens/faith.dart';
import 'package:alvi_helium/services/sample_wearable_service.dart';
import 'package:alvi_helium/services/wearable_service.dart';
import 'package:alvi_helium/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every mapped QWatch Pro screen has a registered ALVI route', () {
    for (final m in screenMappings) {
      if (m.status == 'Not applicable') {
        expect(m.notes, isNotEmpty, reason: '${m.oldId} needs a documented reason');
        continue;
      }
      expect(appRoutes.containsKey(m.route), isTrue, reason: '${m.oldId} -> ${m.route} is not registered');
    }
    for (final n in newAlviScreens) {
      expect(appRoutes.containsKey(n[1]), isTrue, reason: '${n[0]} -> ${n[1]} is not registered');
    }
    expect(screenMappings.length, 125);
  });

  test('Qibla bearing from Mississauga points north-east', () {
    final b = qiblaBearing(43.589, -79.644);
    expect(b, inInclusiveRange(50, 60));
  });

  for (final theme in [ThemeMode.dark, ThemeMode.light]) {
    for (final caps in ['helium', 'all']) {
      for (final route in appRoutes.keys) {
        testWidgets('renders $route ($theme, caps: $caps)', (tester) async {
          tester.view.physicalSize = const Size(1206, 2622); // 402 x 874 pt at 3x
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);
          final wearable = SampleWearableService(initial: BandConnection.connected);
          if (caps == 'all') wearable.simulatedCapabilities = BandCapabilities.all;
          final state = AppState(wearable)..themeMode = theme;
          await tester.pumpWidget(AlviApp(state: state, initialRoute: route));
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 5));
        });
      }
    }
  }

  testWidgets('pairing flow reaches Today', (tester) async {
    final state = AppState(SampleWearableService());
    await tester.pumpWidget(AlviApp(state: state, initialRoute: '/pair'));
    await tester.tap(find.text('I felt the pulse'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining('Pair Helium'), findsOneWidget);
    await tester.tap(find.textContaining('Pair Helium'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(state.connected, isTrue);
    expect(find.text('Where will you wear it?'), findsOneWidget);
  });

  testWidgets('tasbih counts on tap', (tester) async {
    final state = AppState(SampleWearableService(initial: BandConnection.connected));
    await tester.pumpWidget(AlviApp(state: state, initialRoute: '/faith'));
    await tester.pump();
    await tester.tap(find.textContaining('Tap to count'));
    await tester.pump();
    expect(state.tasbihToday, 1);
  });
}
