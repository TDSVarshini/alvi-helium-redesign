import 'package:flutter/material.dart';

import '../screens/account.dart';
import '../screens/activity.dart';
import '../screens/assistant.dart';
import '../screens/body.dart';
import '../screens/circle.dart';
import '../screens/dev.dart';
import '../screens/device.dart';
import '../screens/faith.dart';
import '../screens/heart.dart';
import '../screens/home_shell.dart';
import '../screens/onboarding.dart';
import '../screens/recordings.dart';
import '../screens/today.dart';
import '../screens/you.dart';

/// Every route in the app. Keys match docs/SCREEN_MAPPING.md and lib/app/screen_catalog.dart.
final Map<String, WidgetBuilder> appRoutes = {
  // Onboarding and account
  '/': (_) => const WelcomeScreen(),
  '/account/sign-in': (_) => const SignInScreen(),
  '/account/create': (_) => const CreateAccountScreen(),
  '/account/reset': (_) => const ResetPasswordScreen(),
  '/onboarding/profile': (_) => const ProfileSetupScreen(),
  '/permissions': (_) => const PermissionsScreen(),
  '/pair': (_) => const PairIntroScreen(),
  '/pair/searching': (_) => const PairSearchingScreen(),
  '/pair/not-found': (_) => const PairNotFoundScreen(),
  '/pair/trouble': (_) => const ConnectionHelpScreen(),
  '/onboarding/wear': (_) => const WearScreen(),
  '/onboarding/haptics': (_) => const HapticLanguageScreen(),
  '/sync-failed': (_) => const SyncFailedScreen(),

  // Tabs
  '/today': (_) => const HomeShell(initial: 0),
  '/sleep': (_) => const HomeShell(initial: 1),
  '/heart': (_) => const HomeShell(initial: 2),
  '/activity': (_) => const HomeShell(initial: 3),
  '/you': (_) => const HomeShell(initial: 4),

  // Today
  '/today/edit': (_) => const EditTodayScreen(),
  '/today/readiness': (_) => const ReadinessScreen(),
  '/today/readiness/about': (_) => const ReadinessAboutScreen(),
  '/today/readiness/data': (_) => const ReadinessDataScreen(),
  '/today/readiness/trends': (_) => const ReadinessTrendsScreen(),
  '/plan': (_) => const PlanScreen(),

  // Heart and body measures
  '/heart/oxygen': (_) => const OxygenScreen(),
  '/heart/oxygen/about': (_) => const OxygenAboutScreen(),
  '/heart/glucose': (_) => const GlucoseScreen(),
  '/heart/blood-pressure': (_) => const BloodPressureScreen(),
  '/heart/ecg': (_) => const EcgScreen(),
  '/heart/ecg/record': (_) => const EcgRecordScreen(),
  '/heart/ecg/about': (_) => const EcgAboutScreen(),
  '/heart/ecg/how': (_) => const EcgHowScreen(),
  '/heart/ecg/all': (_) => const EcgAllScreen(),
  '/heart/ecg/risk': (_) => const EcgRiskScreen(),
  '/heart/hrv': (_) => const HrvScreen(),
  '/heart/hrv/about': (_) => const HrvAboutScreen(),
  '/heart/stress': (_) => const StressScreen(),
  '/heart/temperature': (_) => const TemperatureScreen(),
  '/heart/spot-check': (_) => const SpotCheckScreen(),
  '/heart/zones/about': (_) => const ZonesAboutScreen(),
  '/body/cycle': (_) => const CycleScreen(),
  '/body/goal': (_) => const BodyGoalScreen(),
  '/body/goal/new': (_) => const NewBodyGoalScreen(),
  '/body/goal/progress': (_) => const GoalProgressScreen(),
  '/body/uv': (_) => const UvScreen(),

  // Activity
  '/activity/steps': (_) => const StepsScreen(),
  '/activity/workouts': (_) => const WorkoutsScreen(),
  '/activity/start': (_) => const StartWorkoutScreen(),
  '/activity/outdoor': (_) => const OutdoorScreen(),
  '/activity/outdoor/history': (_) => const OutdoorHistoryScreen(),
  '/activity/countdown': (_) => const CountdownScreen(),
  '/activity/live': (_) => const LiveWorkoutScreen(),
  '/activity/summary': (_) => const RunSummaryScreen(),
  '/activity/summary/simple': (_) => const SimpleSummaryScreen(),
  '/activity/summary/swim': (_) => const SimpleSummaryScreen(swim: true),

  // You
  '/you/more': (_) => const MoreFeaturesScreen(),
  '/you/profile': (_) => const ProfileScreen(),
  '/you/goals': (_) => const GoalsScreen(),
  '/you/appearance': (_) => const AppearanceScreen(),
  '/you/connections': (_) => const ConnectionsScreen(),
  '/you/connections/strava': (_) => const StravaScreen(),
  '/you/faq': (_) => const FaqScreen(),
  '/you/feedback': (_) => const FeedbackScreen(),
  '/you/feedback/new': (_) => const FeedbackNewScreen(),
  '/you/about': (_) => const AboutScreen(),
  '/you/privacy': (_) => const PrivacyScreen(),
  '/you/background': (_) => const BackgroundScreen(),
  '/you/background/checklist': (_) => const ChecklistScreen(),
  '/you/background/phones': (_) => const PhoneGuideScreen(),
  '/you/widgets': (_) => const WidgetsScreen(),

  // Device
  '/device': (_) => const DeviceHomeScreen(),
  '/device/haptics': (_) => const HapticsScreen(),
  '/device/wear': (_) => const WearScreen(inSettings: true),
  '/device/monitoring': (_) => const MonitoringScreen(),
  '/device/reminders': (_) => const RemindersScreen(),
  '/device/reminders/move': (_) => const MoveNudgesScreen(),
  '/device/reminders/water': (_) => const WaterNudgesScreen(),
  '/device/quiet-hours': (_) => const QuietHoursScreen(),
  '/device/notifications': (_) => const NotificationsScreen(),
  '/device/notifications/other': (_) => const OtherAppsScreen(),
  '/device/calibration': (_) => const CalibrationScreen(),
  '/device/advanced': (_) => const AdvancedScreen(),
  '/device/call-forwarding': (_) => const CallForwardingScreen(),
  '/device/card': (_) => const CardScreen(),
  '/device/card/guide': (_) => const CardGuideScreen(),
  '/device/media/album': (_) => const AlbumScreen(),
  '/device/media/album/send': (_) => const AlbumSendScreen(),
  '/device/media/books': (_) => const BooksScreen(),
  '/device/media/music': (_) => const MusicScreen(),
  '/device/media/faces': (_) => const FacesScreen(),
  '/device/media/faces/install': (_) => const FaceInstallScreen(),

  // Circle
  '/circle/partner': (_) => const PartnerScreen(),
  '/circle/partner/health': (_) => const PartnerHealthScreen(),
  '/circle/partner/milestones': (_) => const MilestonesScreen(),
  '/circle/partner/dates': (_) => const DatesScreen(),
  '/circle/partner/dates/add': (_) => const AddDateScreen(),
  '/circle/partner/remove': (_) => const RemovePartnerScreen(),
  '/circle/partner/requests': (_) => const PartnerRequestsScreen(),
  '/circle/family': (_) => const FamilyScreen(),
  '/circle/requests': (_) => const RequestsScreen(),
  '/circle/cheers': (_) => const CheersScreen(),
  '/circle/invite': (_) => const InviteScreen(),
  '/circle/invite/sent': (_) => const InviteSentScreen(),
  '/circle/my-code': (_) => const MyCodeScreen(),

  // Assistant
  '/assistant/ask': (_) => const AskAlviScreen(),
  '/assistant/coaching': (_) => const CoachingScreen(),
  '/assistant/reports': (_) => const ReportsScreen(),
  '/assistant/report': (_) => const ReportScreen(),
  '/assistant/settings': (_) => const AssistantSettingsScreen(),

  // Recordings (microphone-gated)
  '/recordings': (_) => const RecordingsScreen(),
  '/recordings/detail': (_) => const RecordingDetailScreen(),
  '/recordings/detail/edit': (_) => const TranscriptEditScreen(),
  '/recordings/help': (_) => const TranscriptionHelpScreen(),
  '/recordings/files': (_) => const AudioFilesScreen(),
  '/recordings/minutes': (_) => const MinutesScreen(),
  '/recordings/minutes/detail': (_) => const MinutesDetailScreen(),
  '/recordings/minutes/edit': (_) => const MinutesEditScreen(),
  '/recordings/select': (_) => const SelectRecordingsScreen(),
  '/recordings/player': (_) => const PlayerScreen(),

  // Faith
  '/faith': (_) => const FaithScreen(),
  '/faith/more': (_) => const FaithMoreScreen(),
  '/faith/prayer-times': (_) => const PrayerTimesScreen(),
  '/faith/qibla': (_) => const QiblaScreen(),
  '/faith/reminders': (_) => const PrayerRemindersScreen(),
  '/faith/reminders/prayer': (_) => const PrayerReminderScreen(),
  '/faith/settings': (_) => const FaithSettingsScreen(),
  '/faith/settings/asr': (_) => const AsrScreen(),
  '/faith/settings/method': (_) => const MethodScreen(),
  '/faith/tasbih/goals': (_) => const TasbihGoalsScreen(),
  '/faith/tasbih/target': (_) => const TasbihTargetScreen(),
  '/faith/tasbih/custom': (_) => const TasbihCustomScreen(),
  '/faith/tasbih/history': (_) => const TasbihHistoryScreen(),
  '/faith/quran': (_) => const QuranScreen(),
  '/faith/quran/chapters': (_) => const SurahsScreen(),
  '/faith/quran/bookmarks': (_) => const QuranBookmarksScreen(),
  '/faith/names': (_) => const NamesScreen(),
  '/faith/names/saved': (_) => const SavedNamesScreen(),

  // Developer
  '/dev/screens': (_) => const ScreenIndexScreen(),
  '/dev/device': (_) => const DeviceSimulatorScreen(),
};

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final builder = appRoutes[settings.name] ?? (_) => const _NotFound();
  return MaterialPageRoute<dynamic>(builder: builder, settings: settings);
}

class _NotFound extends StatelessWidget {
  const _NotFound();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Screen not found')));
}
