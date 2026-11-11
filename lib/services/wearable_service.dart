import 'dart:async';

/// Contract between the ALVI Helium UI and the band.
///
/// The ALVI wearable SDK is not available yet. Screens depend only on this interface;
/// [SampleWearableService] (sample_wearable_service.dart) simulates it with clearly
/// labelled sample values. When the SDK ships, implement [WearableService] with it
/// (Bluetooth scan, pairing, sync, haptics) and swap it in `main.dart`. No proprietary
/// SDK calls are assumed here: every method is a generic band operation.

enum BandConnection { notPaired, searching, notFound, connecting, connected, disconnected, syncFailed }

/// Haptic glyphs from the design system: one meaning each, everywhere.
enum HapticPattern {
  inZone('One pulse', 'You\'re in your zone'),
  goal('Two pulses', 'Goal reached'),
  move('One long pulse', 'Time to move'),
  silentAlarm('Rising pulses', 'Silent alarm'),
  breathe('Slow swell', 'Breathe in, and out'),
  batteryLow('Short, then long', 'Battery low'),
  tick('Tick', 'Double tap ok');

  final String title;
  final String meaning;
  const HapticPattern(this.title, this.meaning);
}

enum HapticStrength { soft, medium, strong }

enum WearSpot { wrist, upperArm }

/// What the connected band can do. Screens for features a band does not report
/// show a "not on this band" state instead of fake data.
class BandCapabilities {
  final bool haptics, heartRate, hrv, oxygen, skinTemperature, steps, sleep, doubleTap, silentAlarm, shareHeartRate;
  final bool display, microphone, speaker, cellular, ecg, bloodPressure, glucose, uv, stress;

  const BandCapabilities({
    this.haptics = true,
    this.heartRate = true,
    this.hrv = true,
    this.oxygen = true,
    this.skinTemperature = true,
    this.steps = true,
    this.sleep = true,
    this.doubleTap = true,
    this.silentAlarm = true,
    this.shareHeartRate = true,
    this.stress = true,
    this.display = false,
    this.microphone = false,
    this.speaker = false,
    this.cellular = false,
    this.ecg = false,
    this.bloodPressure = false,
    this.glucose = false,
    this.uv = false,
  });

  /// Capabilities shown in the ALVI Helium design files (design targets, unverified).
  static const heliumDesignTarget = BandCapabilities();

  /// Everything on: lets designers and testers preview capability-gated screens.
  static const all = BandCapabilities(
      display: true, microphone: true, speaker: true, cellular: true, ecg: true, bloodPressure: true, glucose: true, uv: true);

  bool has(String key) {
    switch (key) {
      case 'display':
        return display;
      case 'microphone':
        return microphone;
      case 'speaker':
        return speaker;
      case 'cellular':
        return cellular;
      case 'ecg':
        return ecg;
      case 'bloodPressure':
        return bloodPressure;
      case 'glucose':
        return glucose;
      case 'uv':
        return uv;
      case 'oxygen':
        return oxygen;
      case 'hrv':
        return hrv;
      case 'stress':
        return stress;
      case 'skinTemperature':
        return skinTemperature;
      default:
        return true;
    }
  }
}

class DiscoveredBand {
  final String id;
  final String name;
  final int signal; // dBm
  const DiscoveredBand(this.id, this.name, this.signal);
}

class BandInfo {
  final String id;
  final String name;
  final String firmware;
  final bool firmwareUpToDate;
  final int batteryPercent;
  final int daysLeft;
  final WearSpot spot;
  final String size;
  final String hand;
  final DateTime lastSync;
  final bool isSample;

  const BandInfo({
    required this.id,
    required this.name,
    required this.firmware,
    required this.firmwareUpToDate,
    required this.batteryPercent,
    required this.daysLeft,
    required this.spot,
    required this.size,
    required this.hand,
    required this.lastSync,
    required this.isSample,
  });

  BandInfo copyWith({int? batteryPercent, WearSpot? spot, String? size, String? hand, DateTime? lastSync}) => BandInfo(
        id: id,
        name: name,
        firmware: firmware,
        firmwareUpToDate: firmwareUpToDate,
        batteryPercent: batteryPercent ?? this.batteryPercent,
        daysLeft: daysLeft,
        spot: spot ?? this.spot,
        size: size ?? this.size,
        hand: hand ?? this.hand,
        lastSync: lastSync ?? this.lastSync,
        isSample: isSample,
      );
}

abstract class WearableService {
  /// True while values come from the simulator rather than a real band.
  bool get isSample;

  BandConnection get connection;
  Stream<BandConnection> get connectionChanges;

  BandCapabilities get capabilities;
  BandInfo? get band;

  Future<List<DiscoveredBand>> scan({Duration timeout = const Duration(seconds: 6)});
  Future<void> pair(DiscoveredBand band);
  Future<void> unpair();
  Future<void> reconnect();
  Future<void> sync();

  Future<void> playHaptic(HapticPattern pattern);
  Future<void> setHapticStrength(HapticStrength strength);
  Future<void> findBand();
  Future<void> setWear({WearSpot? spot, String? size, String? hand});

  /// Background monitoring switches: 'heartRate', 'oxygen', 'stress', 'hrv', 'uv', 'bloodPressure'.
  Future<void> setMonitoring(String metric, bool enabled);
  Future<void> setShareHeartRate(bool enabled);

  /// One-shot measurement (spot check, ECG). Emits values while measuring.
  Stream<int> measureHeartRate({Duration duration = const Duration(seconds: 30)});

  Future<void> restart();
  Future<void> factoryReset();

  void dispose();
}
