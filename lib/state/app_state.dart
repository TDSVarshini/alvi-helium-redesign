import 'dart:async';

import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../services/wearable_service.dart';

class TodayCard {
  final String id;
  final String title;
  bool enabled;
  TodayCard(this.id, this.title, this.enabled);
}

class Goal {
  final String id, label, unit;
  double value;
  final double step, min, max;
  Goal(this.id, this.label, this.value, this.unit, this.step, this.min, this.max);

  String get display => value == value.roundToDouble() && step >= 1
      ? '${value.round()} $unit'
      : '${value.toStringAsFixed(1)} $unit';
}

/// App-wide UI state. In-memory only; persistence and the account backend are out of scope
/// for this UI build and sit behind this class.
class AppState extends ChangeNotifier {
  AppState(this.wearable) {
    _sub = wearable.connectionChanges.listen((_) => notifyListeners());
  }

  final WearableService wearable;
  late final StreamSubscription<BandConnection> _sub;

  ThemeMode themeMode = ThemeMode.dark;
  String language = 'EN';

  // Account (mock: no backend in this build)
  bool signedIn = false;
  String nickname = Sample.userName;
  String email = '';
  String gender = 'Prefer not to say';
  String birthday = '1995-01-01';
  int heightCm = 175;
  int weightKg = 60;
  bool metric = true;
  bool clock24 = true;

  final List<TodayCard> todayCards = [
    TodayCard('readiness', 'Readiness', true),
    TodayCard('sleep', 'Sleep', true),
    TodayCard('heart', 'Heart', true),
    TodayCard('activity', 'Activity', true),
    TodayCard('workouts', 'Workouts', true),
    TodayCard('outdoor', 'Outdoor run', false),
  ];

  final List<Goal> goals = [
    Goal('steps', 'Steps', 10000, 'steps', 500, 1000, 40000),
    Goal('energy', 'Active energy', 400, 'kcal', 50, 50, 2000),
    Goal('distance', 'Distance', 5, 'km', 0.5, 0.5, 50),
    Goal('exercise', 'Exercise time', 1.5, 'h', 0.25, 0.25, 6),
    Goal('sleep', 'Sleep', 8, 'h', 0.25, 4, 12),
  ];

  /// Generic switches used across settings screens, keyed by id.
  final Map<String, bool> toggles = {
    'monitor.heartRate': true,
    'monitor.oxygen': true,
    'monitor.stress': false,
    'monitor.hrv': true,
    'monitor.uv': false,
    'monitor.bloodPressure': false,
    'haptic.zone': true,
    'haptic.goal': true,
    'haptic.move': true,
    'haptic.alarm': true,
    'haptic.breathe': false,
    'shareHeartRate': false,
    'notify.all': true,
    'notify.calls': true,
    'notify.sms': false,
    'quietHours': true,
    'reminder.water': false,
    'reminder.move': true,
    'callForwarding': false,
    'prayer.reminders': false,
    'prayer.Fajr': true,
    'prayer.Dhuhr': true,
    'prayer.Asr': true,
    'prayer.Maghrib': true,
    'prayer.Isha': true,
    'tasbih.33': true,
    'tasbih.100': false,
    'tasbih.custom': false,
    'partner.dateTop': true,
  };

  final Map<String, String> values = {
    'hapticStrength': 'Medium',
    'quietHours': '22:00 — 06:30',
    'silentAlarm': '06:30 — 07:00',
    'moveAfter': '60 min',
    'waterEvery': '2 h',
    'asr': 'Shafi\'i, Maliki and Hanbali',
    'method': 'MWL',
    'tasbihCustom': '60',
    'tasbihTarget': '3000',
    'adhanOffset': 'At the Adhan',
  };

  final Map<String, String> notifyApps = {
    'Messages': 'on', 'WhatsApp': 'on', 'Messenger': 'on', 'Telegram': 'on', 'Signal': 'off',
    'Line': 'off', 'KakaoTalk': 'off', 'Viber': 'off', 'LinkedIn': 'off', 'X': 'off', 'Calendar': 'on', 'Email': 'off',
  };

  final List<String> checklistDone = [];

  List<PlanItem> plan = Sample.plan();
  int tasbihToday = 0;
  final List<String> tasbihHistory = [];
  final List<String> savedNames = [];
  final List<String> quranBookmarks = [];
  final List<String> partnerDates = [];
  bool partnerLinked = false;
  final List<String> chat = [];
  bool coachingTrial = true;
  int coachingDaysLeft = 24;

  BandConnection get connection => wearable.connection;
  bool get connected => wearable.connection == BandConnection.connected;
  BandCapabilities get caps => wearable.capabilities;

  bool toggle(String id) => toggles[id] ?? false;

  void setToggle(String id, bool v) {
    toggles[id] = v;
    if (id.startsWith('monitor.')) wearable.setMonitoring(id.substring(8), v);
    if (id == 'shareHeartRate') wearable.setShareHeartRate(v);
    notifyListeners();
  }

  void setValue(String id, String v) {
    values[id] = v;
    if (id == 'hapticStrength') {
      wearable.setHapticStrength(HapticStrength.values.firstWhere((s) => s.name == v.toLowerCase(),
          orElse: () => HapticStrength.medium));
    }
    notifyListeners();
  }

  void setTheme(ThemeMode m) {
    themeMode = m;
    notifyListeners();
  }

  void signIn(String mail) {
    signedIn = true;
    email = mail;
    notifyListeners();
  }

  void signOut() {
    signedIn = false;
    notifyListeners();
  }

  void update(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  void reorderCards(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final c = todayCards.removeAt(oldIndex);
    todayCards.insert(newIndex, c);
    notifyListeners();
  }

  void countTasbih() {
    tasbihToday++;
    notifyListeners();
  }

  void clearTasbih() {
    if (tasbihToday > 0) tasbihHistory.insert(0, '$tasbihToday');
    tasbihToday = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<AppScope>()!.widget as AppScope).notifier!;
}

extension AppStateContext on BuildContext {
  AppState get app => AppScope.of(this);
  AppState get appRead => AppScope.read(this);
}
