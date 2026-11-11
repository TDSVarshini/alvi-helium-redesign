/// SAMPLE DATA ONLY.
///
/// Values here mirror the ALVI Helium sample designs (Sam, readiness 78, 7 h 42 m sleep).
/// They are not live device data. Screens that render them show the "Sample" tag.
/// Replace with a HealthRepository backed by the wearable SDK when available.
library;

class SleepSegment {
  final String stage; // deep, light, rem, awake
  final double startHour; // hours after 22:00
  final double endHour;
  const SleepSegment(this.stage, this.startHour, this.endHour);
}

class Contributor {
  final String name;
  final String word; // status word, never colour alone
  final double value; // 0..1
  final String tone; // good, caution, alert
  const Contributor(this.name, this.word, this.value, this.tone);
}

class WorkoutRecord {
  final String id, type, date, title, insight;
  final String time, distance, pace, energy, avgHr, maxHr, effort, cadence;
  final List<int> zoneMinutes; // Z5..Z2
  final bool startedByDoubleTap;
  const WorkoutRecord({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.insight,
    required this.time,
    this.distance = '',
    this.pace = '',
    required this.energy,
    this.avgHr = '',
    this.maxHr = '',
    this.effort = '',
    this.cadence = '',
    this.zoneMinutes = const [],
    this.startedByDoubleTap = true,
  });
}

class PlanItem {
  final String title, detail, amount, tone;
  bool done;
  PlanItem(this.title, this.detail, this.amount, this.tone, {this.done = false});
}

class Sample {
  static const userName = 'Sam';
  static const city = 'Mississauga';
  static const double latitude = 43.589, longitude = -79.644; // used for Qibla bearing
  static const weather = '12° · Clear · Mississauga';
  static const weatherLine = 'Cool and dry. A good morning to run outside.';

  // Today
  static const readiness = 78;
  static const readinessDelta = '+6 VS AVG';
  static const readinessWord = 'READY FOR EFFORT';
  static const readinessInsight = 'Your HRV rose overnight. A good day to push a little harder.';
  static const readinessLong = 'You slept well and recovered overnight. Effort will feel easier today.';
  static const contributors = [
    Contributor('Sleep', 'Good', 0.84, 'good'),
    Contributor('HRV balance', 'High', 0.90, 'good'),
    Contributor('Resting heart rate', 'Good', 0.76, 'good'),
    Contributor('Recent training load', 'Fair', 0.52, 'caution'),
    Contributor('Skin temperature', 'Normal', 0.80, 'good'),
  ];
  static const readinessWeek = [61, 74, 58, 70, 76, 72, 78];
  static const readinessWeekTone = ['caution', 'good', 'caution', 'good', 'good', 'good', 'good'];
  static const weekDays = ['W', 'T', 'F', 'S', 'S', 'M', 'T'];
  static const energyByHour = [62, 66, 70, 74, 78, 77, 74, 71, 69, 66, 63, 61, 60, 58, 57, 55, 54, 53];
  static const energyConsumed = '-24';
  static const energyCharged = '+31';

  // Sleep
  static const sleepWindow = '22:48 — 06:52';
  static const sleepHours = 7, sleepMinutes = 42;
  static const sleepHeadline = 'Deep, unbroken rest.';
  static const sleepInsight = 'Your longest deep sleep this month, mostly before 02:00.';
  static const sleepScore = 84;
  static const sleepDeep = '1:38', sleepRem = '1:52', sleepLight = '3:58', sleepAwake = '0:14';
  static const sleepSegments = [
    SleepSegment('light', 0.8, 1.1),
    SleepSegment('deep', 1.1, 1.9),
    SleepSegment('light', 1.9, 2.4),
    SleepSegment('rem', 2.4, 2.8),
    SleepSegment('light', 2.8, 3.3),
    SleepSegment('deep', 3.3, 3.9),
    SleepSegment('light', 3.9, 4.6),
    SleepSegment('awake', 4.6, 4.75),
    SleepSegment('light', 4.75, 5.3),
    SleepSegment('rem', 5.3, 6.1),
    SleepSegment('light', 6.1, 6.6),
    SleepSegment('rem', 6.6, 7.2),
    SleepSegment('light', 7.2, 7.8),
    SleepSegment('rem', 7.8, 8.1),
  ];
  static const sleepWeek = [6.9, 7.4, 6.2, 7.0, 8.1, 7.3, 7.7];
  static const silentAlarm = '06:30 — 07:00';

  // Heart
  static const heartNow = 68, restingHr = 54, hrv = 62, oxygen = 97;
  static const heartInsight = 'Calm and steady, five below your daytime average.';
  static const heartRange = '48 — 142';
  static const heartDay = [
    58, 56, 55, 54, 55, 54, 56, 62, 75, 88, 84, 96, 120, 142, 104, 92, 90, 86, 88, 84, 80, 78, 74, 70, 68
  ];
  static const zoneMinutesWeek = 142;
  static const skinTempDelta = '+0.2 °C';
  static const hrvDay = [58, 61, 66, 70, 64, 60, 57, 55, 52, 54, 59, 62];
  static const stressDay = [22, 18, 15, 20, 34, 48, 52, 40, 36, 30, 28, 26];
  static const oxygenDay = [97, 96, 98, 97, 95, 97, 98, 97, 96, 97, 98, 97];
  static const tempDay = [0.1, 0.0, -0.1, 0.0, 0.2, 0.3, 0.2, 0.2, 0.1, 0.2, 0.2, 0.2];

  // Activity
  static const steps = 5620, stepGoal = 10000;
  static const activityInsight = 'Halfway there. A 30-minute walk closes it.';
  static const activeMin = 38;
  static const distanceKm = '4.1';
  static const energyKcal = 412;
  static const stepsByHour = [
    0, 0, 0, 0, 0, 0, 120, 640, 820, 310, 260, 540, 900, 380, 220, 290, 410, 330, 0, 0, 0, 0, 0, 0
  ];
  static const stepsWeek = [8200, 10450, 6400, 9100, 12030, 7300, 5620];

  static const run = WorkoutRecord(
    id: 'run-1013',
    type: 'Outdoor run',
    date: 'MON 13 OCT',
    title: '8.20',
    insight: 'Strong and even. Your fastest last kilometre yet.',
    time: '42:10',
    distance: '8.20',
    pace: '5:08',
    energy: '512',
    avgHr: '148',
    maxHr: '171',
    effort: '14.2',
    cadence: '168',
    zoneMinutes: [2, 11, 22, 6],
  );
  static const swim = WorkoutRecord(
    id: 'swim-1012',
    type: 'Pool swim',
    date: 'SUN 12 OCT',
    title: '34:05',
    insight: 'A steady half hour in the water.',
    time: '34:05',
    energy: '296',
  );
  static const workouts = [run, swim];

  static const sportModes = [
    'Walk', 'Outdoor run', 'Indoor run', 'Cycling', 'Hike', 'Spin bike', 'Pool swim', 'Rope skipping',
    'Rowing machine', 'Elliptical', 'Yoga', 'Basketball', 'Volleyball', 'Badminton', 'Aerobics', 'Strength',
  ];

  // Plan
  static List<PlanItem> plan() => [
        PlanItem('Walk', 'After lunch. Breaks up long sitting.', '15 MIN', 'activity'),
        PlanItem('Workout', 'Moderate, mostly zone 3.', '40 MIN', 'heart'),
        PlanItem('Recovery', 'Gentle stretching this evening.', '10 MIN', 'readiness'),
        PlanItem('Hydrate', 'Steady through the day.', '2 L', 'oxygen'),
        PlanItem('Bedtime', 'Inside your usual window.', '22:45', 'sleep'),
      ];

  // Circle
  static const family = [
    ['Sam', '5,620', '3'],
    ['Priya', '8,104', '5'],
    ['Leo', '3,980', '1'],
  ];

  // Faith (sample, not computed)
  static const prayerTimes = [
    ['Fajr', '05:52'],
    ['Sunrise', '07:14'],
    ['Dhuhr', '12:13'],
    ['Asr', '14:41'],
    ['Maghrib', '17:02'],
    ['Isha', '18:24'],
  ];

  /// The 114 surahs, standard transliteration.
  static const surahs = [
    'Al-Fatihah', 'Al-Baqarah', 'Ali \'Imran', 'An-Nisa', 'Al-Ma\'idah', 'Al-An\'am', 'Al-A\'raf', 'Al-Anfal',
    'At-Tawbah', 'Yunus', 'Hud', 'Yusuf', 'Ar-Ra\'d', 'Ibrahim', 'Al-Hijr', 'An-Nahl', 'Al-Isra', 'Al-Kahf',
    'Maryam', 'Ta-Ha', 'Al-Anbiya', 'Al-Hajj', 'Al-Mu\'minun', 'An-Nur', 'Al-Furqan', 'Ash-Shu\'ara', 'An-Naml',
    'Al-Qasas', 'Al-\'Ankabut', 'Ar-Rum', 'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba', 'Fatir', 'Ya-Sin',
    'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir', 'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah',
    'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf', 'Adh-Dhariyat', 'At-Tur', 'An-Najm', 'Al-Qamar',
    'Ar-Rahman', 'Al-Waqi\'ah', 'Al-Hadid', 'Al-Mujadilah', 'Al-Hashr', 'Al-Mumtahanah', 'As-Saff', 'Al-Jumu\'ah',
    'Al-Munafiqun', 'At-Taghabun', 'At-Talaq', 'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Ma\'arij',
    'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir', 'Al-Qiyamah', 'Al-Insan', 'Al-Mursalat', 'An-Naba',
    'An-Nazi\'at', '\'Abasa', 'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj', 'At-Tariq',
    'Al-A\'la', 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad', 'Ash-Shams', 'Al-Layl', 'Ad-Duha', 'Ash-Sharh', 'At-Tin',
    'Al-\'Alaq', 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-\'Adiyat', 'Al-Qari\'ah', 'At-Takathur', 'Al-\'Asr',
    'Al-Humazah', 'Al-Fil', 'Quraysh', 'Al-Ma\'un', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr', 'Al-Masad',
    'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
  ];
}
