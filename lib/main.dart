import 'package:flutter/material.dart';

import 'app/app.dart';
import 'services/sample_wearable_service.dart';
import 'state/app_state.dart';

/// Entry point.
///
/// The ALVI wearable SDK is not available yet, so the app runs on [SampleWearableService],
/// which produces clearly labelled sample data. To integrate the SDK, implement
/// `WearableService` (lib/services/wearable_service.dart) and pass it here instead.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState(SampleWearableService());
  runApp(AlviApp(state: state));
}
