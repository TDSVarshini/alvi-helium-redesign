import 'dart:async';
import 'dart:math';

import 'wearable_service.dart';

/// Simulated band. Every value it produces is SAMPLE DATA and is labelled as such in the UI.
/// It exists so the full UI, including connection, disconnected and error states, can be
/// built and tested before the ALVI wearable SDK is available.
class SampleWearableService implements WearableService {
  SampleWearableService({BandConnection initial = BandConnection.notPaired, this.capabilitiesOverride})
      : _connection = initial {
    if (initial != BandConnection.notPaired) _band = _sampleBand();
  }

  final BandCapabilities? capabilitiesOverride;
  final _controller = StreamController<BandConnection>.broadcast();
  BandConnection _connection;
  BandInfo? _band;
  final _rng = Random(7);

  /// Simulator switches (Developer › Device simulator).
  bool failNextScan = false;
  bool failNextSync = false;
  BandCapabilities simulatedCapabilities = BandCapabilities.heliumDesignTarget;

  @override
  bool get isSample => true;

  @override
  BandConnection get connection => _connection;

  @override
  Stream<BandConnection> get connectionChanges => _controller.stream;

  @override
  BandCapabilities get capabilities => capabilitiesOverride ?? simulatedCapabilities;

  @override
  BandInfo? get band => _band;

  void _set(BandConnection c) {
    _connection = c;
    _controller.add(c);
  }

  /// Developer helper: jump straight to a state.
  void simulate(BandConnection c) {
    if (c == BandConnection.connected && _band == null) _band = _sampleBand();
    if (c == BandConnection.notPaired) _band = null;
    _set(c);
  }

  BandInfo _sampleBand() => BandInfo(
        id: 'SAMPLE-0001',
        name: 'Helium (sample)',
        firmware: '0.9.4',
        firmwareUpToDate: true,
        batteryPercent: 82,
        daysLeft: 6,
        spot: WearSpot.wrist,
        size: 'M',
        hand: 'Left',
        lastSync: DateTime.now().subtract(const Duration(hours: 2)),
        isSample: true,
      );

  @override
  Future<List<DiscoveredBand>> scan({Duration timeout = const Duration(seconds: 6)}) async {
    _set(BandConnection.searching);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (failNextScan) {
      failNextScan = false;
      _set(BandConnection.notFound);
      return const [];
    }
    _set(BandConnection.notPaired);
    return const [DiscoveredBand('SAMPLE-0001', 'Helium (sample)', -48)];
  }

  @override
  Future<void> pair(DiscoveredBand band) async {
    _set(BandConnection.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _band = _sampleBand();
    _set(BandConnection.connected);
  }

  @override
  Future<void> unpair() async {
    _band = null;
    _set(BandConnection.notPaired);
  }

  @override
  Future<void> reconnect() async {
    if (_band == null) return;
    _set(BandConnection.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _set(BandConnection.connected);
  }

  @override
  Future<void> sync() async {
    if (_band == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (failNextSync) {
      failNextSync = false;
      _set(BandConnection.syncFailed);
      return;
    }
    _band = _band!.copyWith(lastSync: DateTime.now());
    _set(BandConnection.connected);
  }

  @override
  Future<void> playHaptic(HapticPattern pattern) async {
    // A real implementation writes the pattern to the band. The simulator does nothing.
  }

  @override
  Future<void> setHapticStrength(HapticStrength strength) async {}

  @override
  Future<void> findBand() async {}

  @override
  Future<void> setWear({WearSpot? spot, String? size, String? hand}) async {
    if (_band != null) _band = _band!.copyWith(spot: spot, size: size, hand: hand);
  }

  @override
  Future<void> setMonitoring(String metric, bool enabled) async {}

  @override
  Future<void> setShareHeartRate(bool enabled) async {}

  @override
  Stream<int> measureHeartRate({Duration duration = const Duration(seconds: 30)}) async* {
    final ticks = duration.inSeconds.clamp(1, 120);
    for (var i = 0; i < ticks; i++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      yield 64 + _rng.nextInt(8);
    }
  }

  @override
  Future<void> restart() async {
    _set(BandConnection.connecting);
    await Future<void>.delayed(const Duration(seconds: 1));
    _set(BandConnection.connected);
  }

  @override
  Future<void> factoryReset() async {
    _band = null;
    _set(BandConnection.notPaired);
  }

  @override
  void dispose() => _controller.close();
}
