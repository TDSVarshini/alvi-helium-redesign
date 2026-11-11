"""Single source of truth for the QWatch Pro -> ALVI Helium screen mapping.

Run:  python3 tool/screen_mapping.py
Writes docs/SCREEN_MAPPING.md, docs/screen_mapping.json and lib/app/screen_catalog.dart.

Source of old screens: the 125 screenshots on the "QWatch Pro Screens" design canvas
(QWatch Pro 1.0.3.55, Android 15 emulator, no watch paired). No APK was supplied to
this project, so layouts are taken from those screenshots only.

Design references: ALVI Helium design system and sample designs V1.2 (PDF pages):
  p2 Design specs, p4 Onboarding, p5 Today and body, p6 Activity,
  p7 Plan and assistant, p8 States and device.
"""
import json, os

R, M, G, NA = "Redesigned", "Redesigned (merged)", "Redesigned (capability-gated)", "Not applicable"

# (old_id, old_title, old_section, functionality, new_title, route, design_ref, status, notes)
S = [
 # ---------------- Main flows: Data tab ----------------
 ("Main", "Data — Home", "Data tab", "Daily step total with hourly chart, permission warning row, heart-rate, sleep and exercise cards, tab bar Data/Device/My.", "Today", "/today", "p5 Today", R, "Data tab becomes Today: readiness ring, insight, sleep/HRV/steps/skin strip, cards reorderable. Tab bar becomes Today/Sleep/Heart/Activity/You."),
 ("Data-PermissionPrompt", "First-launch permission prompt", "Data tab", "Explains contacts/calls/SMS permission for call and SMS reminders, and location for GPS and Bluetooth.", "Permissions", "/permissions", "p4 Onboarding list rows", R, "Each permission is a row with why-it-is-needed copy and an Allow action. Never blocks the app."),
 ("Data-Steps", "Data — Steps", "Data tab", "Day/Week/Month steps chart with date stepper; total, average, distance, calorie tiles.", "Steps", "/activity/steps", "p6 Activity", R, ""),
 ("Data-HeartRate", "Data — Heart rate", "Data tab", "Continuous HR toggle, daily HR chart, detail data, real-time HR, zone minutes donut.", "Heart", "/heart", "p5 Heart", R, "Heart tab. Zone minutes become labelled bars (colour never the only cue)."),
 ("Data-Sleep", "Data — Sleep", "Data tab", "Day/Week/Month sleep stages chart, total, deep continuity score, deep/light percentages and durations, awake time, explainer.", "Sleep", "/sleep", "p5 Sleep", R, "Four-row stage chart (deep, light, REM, awake dotted) per V1.1 rules."),
 ("Data-Exercise", "Data — Exercise record", "Data tab", "Day/Week/Month total exercise time, count, kcal, recent activities, empty state.", "Workouts", "/activity/workouts", "p8 Workouts, empty", R, "Shows the ALVI empty state when there are no workouts."),
 ("Data-EditCard", "Data — Edit card", "Data tab", "Drag to reorder home cards, toggle Heart Rate / Sleep / Exercise / GPS cards.", "Edit Today", "/today/edit", "p2 Toggle rows", R, "ReorderableListView with toggle per card."),
 # ---------------- Device tab ----------------
 ("Device-Home", "Device — Home (no watch)", "Device tab", "Add device card, Find device, Health monitoring, Unit system, Time format, More.", "Your Helium", "/device", "p8 Your Helium", R, "Shows not-paired state with Pair button, or paired state with battery, haptics, wear, find, firmware."),
 ("Device-AddSearching", "Add: searching", "Device tab", "Animated search for nearby devices.", "Pair: looking for your band", "/pair/searching", "p4 Pair your band", R, ""),
 ("Device-AddSearchAgain", "Add: search again", "Device tab", "Nothing found; Search again; 'Problem with connection?' tooltip.", "Pair: band not found", "/pair/not-found", "p8 Sync failed", R, ""),
 ("Device-AddHelpMenu", "Add: connection help menu", "Device tab", "Help menu (?) opening connection help.", "Pair: band not found (help sheet)", "/pair/not-found", "p8 Sync failed", M, "Help menu is a bottom sheet on the not-found screen linking to Connection help."),
 # ---------------- My tab ----------------
 ("My-Home", "My — Home", "My tab", "Login/Register, background protection guide, profile, goal, theme, third-party, FAQ, feedback, about.", "You", "/you", "p2 List rows", R, "Adds More features: Circle, Faith, Recordings, Cycle, Body goal, Assistant."),
 ("My-BackgroundGuide1", "Background protection guide 1", "My tab", "Explains effects of disconnection (no notifications, no call alerts); 'to set'.", "Keep ALVI connected", "/you/background", "p8 Sync failed layout", R, ""),
 ("My-BackgroundGuide2", "Background protection guide 2", "My tab", "Checklist: notification access, battery whitelist, auto-start, lock app, power protection; each 'not completed'.", "Connection checklist", "/you/background/checklist", "p2 Navigation rows + status tokens", R, "Each item carries a word status (Done/To do), not colour alone."),
 ("My-Goal", "My — Goal", "My tab", "Steps, calorie, distance, exercise time, sleep time goals; Save.", "Goals", "/you/goals", "p2 Navigation rows", R, "Editable with steppers in a bottom sheet."),
 ("My-Theme", "My — Theme style", "My tab", "Pick default/pink/Diablo/blue colour theme.", "Appearance", "/you/appearance", "p2 Dark and light tokens", R, "ALVI ships Dark, Light and System only; decorative colour themes are not part of the design system."),
 ("My-ThirdParty", "Third-party services", "My tab", "Google Fit and Strava links.", "Connected services", "/you/connections", "p2 Navigation rows", R, "No third-party logos are reproduced."),
 ("My-FAQ", "FAQ (web, blank offline)", "My tab", "Web view of FAQ (blank offline).", "Help and FAQ", "/you/faq", "p2 List rows", R, "Original content was not recoverable (blank web view). Questions shown are ALVI placeholders to be replaced by approved copy."),
 ("My-Feedback", "Feedback", "My tab", "Feedback categories: suggestions, function faults, device faults, hardware.", "Feedback", "/you/feedback", "p2 List rows", R, "Display-specific categories (raise to wake, SMS on watch) adapted to band equivalents."),
 ("My-About", "About", "My tab", "App icon, name, version, clear cache, privacy statement link.", "About", "/you/about", "p2", R, "ALVI identity, not QWatch Pro."),
 ("Account-Login", "Account — Login", "Account", "Email/password login, forgot password, register, privacy link.", "Sign in", "/account/sign-in", "p4 Welcome", R, ""),
 ("Account-Register", "Account — Register", "Account", "Email, password, confirm password; Register.", "Create account", "/account/create", "p4", R, ""),
 ("Account-ForgotPassword", "Account — Retrieve password", "Account", "Email, verification code with Send, new password twice; Confirm.", "Reset password", "/account/reset", "p4", R, ""),
 # ---------------- Health & activity ----------------
 ("Health-BloodOxygen", "Blood Oxygen", "Health", "Timed SpO2 toggle, SpO2 chart, detail data, distribution, explainer.", "Oxygen and breathing", "/heart/oxygen", "p5 Heart row", R, ""),
 ("Health-BloodOxygenGuide", "Data Source – Blood Oxygen", "Health", "Where SpO2 data comes from, how to wear.", "About oxygen readings", "/heart/oxygen/about", "p4 Wear", R, ""),
 ("Health-BloodSugar", "Blood Sugar", "Health", "Glucose chart, real-time glucose, start measurement, explainer.", "Glucose (estimate)", "/heart/glucose", "p5 Heart", G, "Hidden unless the band reports a glucose capability. Wellness wording only."),
 ("Health-BodyBattery", "Energy Score", "Health", "All-day energy score chart, consumed/charged, energy recovery bars, missing-sleep banner.", "Readiness", "/today/readiness", "p5 Readiness", R, "Energy Score maps to ALVI Readiness with 'what shaped it' bars and energy-through-the-day line."),
 ("Health-BodyBatteryGuide", "Energy Score – Description", "Health", "What it is, how to improve, rules, action guide.", "About readiness", "/today/readiness/about", "p5", R, ""),
 ("Health-BodyBatteryMoreData", "Energy Score – More Data", "Health", "Hourly data list for a day (No data).", "Readiness data", "/today/readiness/data", "p2 Spec/data rows", R, ""),
 ("Health-BodyBatteryWeekMonth", "Energy Score – Week/Month", "Health", "Week/Month bar chart.", "Readiness trends", "/today/readiness/trends", "p5 Last 7 days", R, ""),
 ("Health-BloodPressure", "Blood Pressure", "Health", "Timed BP toggle, SBP/DBP chart, normal ranges, explainer.", "Blood pressure (estimate)", "/heart/blood-pressure", "p5", G, "Capability-gated. Wellness wording only."),
 ("Health-Ecg", "ECG", "Health", "Live ECG trace, bpm/QTc/HRV, start measurement, latest record, how to measure.", "ECG", "/heart/ecg", "p5", G, "Capability-gated."),
 ("Health-EcgDetail", "ECG Details", "Health", "Trace, HR avg/high/low, HRV SDNN/RMSSD, share/delete.", "ECG record", "/heart/ecg/record", "p5", G, ""),
 ("Health-EcgGuide", "ECG – Description", "Health", "About ECG, principle, usage, results.", "About ECG", "/heart/ecg/about", "p2", G, ""),
 ("Health-EcgGuideMeasure", "ECG – How to Measure", "Health", "Measurement method with illustration.", "How to take an ECG", "/heart/ecg/how", "p4 numbered steps", G, ""),
 ("Health-EcgList", "ECG – All Data", "Health", "Filter tabs (All/Sinus/AF/...), list, calendar.", "All ECG records", "/heart/ecg/all", "p8 empty state", G, ""),
 ("Health-EcgRiskAnalysis", "ECG Risk Analysis", "Health", "Sign-in-required dialog before analysis.", "ECG analysis (sign-in gate)", "/heart/ecg/risk", "p8 States", G, "Shows the permission/sign-in state from V1.1 'states to spec'."),
 ("Health-AddMemorial", "Add Anniversary", "Health / social", "Event name, date, pin to top; Save.", "Add a date", "/circle/partner/dates/add", "p2 Rows", R, ""),
 ("Health-DeleteLover", "Unpair Partner", "Health / social", "Warning about unpairing and 180-day restore; Unpair.", "Stop sharing with partner", "/circle/partner/remove", "p8 Unpair", R, ""),
 ("Health-FriendRanking", "Family Ranking", "Health / social", "Ranking of family steps with likes, share, add.", "Family", "/circle/family", "p2 Rows", R, "Stock photo header removed."),
 ("Health-FriendsInviteList", "New Friends", "Health / social", "Friend requests list, empty state, Invite friends.", "Requests", "/circle/requests", "p8 empty state", R, ""),
 ("Health-InviterUser", "Choose a Pair", "Health / social", "Enter other person's email, scan, Send invitation.", "Invite someone", "/circle/invite", "p4", R, ""),
 ("Health-LikeFriendsList", "Friends Who Like Me", "Health / social", "List of friends who liked you.", "Cheers", "/circle/cheers", "p8 empty state", R, ""),
 ("Health-LoverCertificateList", "Love Certificates", "Health / social", "Locked milestone cards by days together.", "Milestones", "/circle/partner/milestones", "p2 Rows", R, "Photographic cards replaced by text milestones."),
 ("Health-LoverHealth", "Partner Health", "Health / social", "Week strip, partner activity, sleep, HR, SpO2.", "Partner's day", "/circle/partner/health", "p5", R, "Only data the partner chose to share."),
 ("Health-LoverInviteList", "Pairing Requests", "Health / social", "Pending partner requests.", "Partner requests", "/circle/partner/requests", "p8 empty", R, ""),
 ("Health-LoverInviterResult", "Invitation Sent", "Health / social", "Invitation sent copy, expires in 1 day; I know.", "Invitation sent", "/circle/invite/sent", "p4", R, ""),
 ("Health-LoverMemorial", "Anniversary", "Health / social", "Days together card, add date.", "Dates", "/circle/partner/dates", "p5 display numeral", R, ""),
 ("Health-LoverSpace", "Space of Love", "Health / social", "Hero image, explainer, invite significant other.", "Partner", "/circle/partner", "p4 haptic language", R, "Reframed as sending a touch (haptic) to your partner."),
 ("Health-MyQrCode", "My QR Code", "Health / social", "QR code to add me as friend; save picture.", "My code", "/circle/my-code", "p2", R, "QR is drawn from a sample payload placeholder."),
 ("Health-Gps", "GPS Running", "Health / activity", "Map, distance, running record, start.", "Outdoor run", "/activity/outdoor", "p6 Activity", R, "Map tile area is a placeholder; no map SDK bundled."),
 ("Health-GpsHistory", "GPS Running – History", "Health / activity", "Totals and recent runs by date.", "Run history", "/activity/outdoor/history", "p6", R, ""),
 ("Health-GpsPrepare", "GPS Run Countdown", "Health / activity", "3-2-1 countdown.", "Countdown", "/activity/countdown", "p6", R, ""),
 ("Health-GpsRun", "GPS Run In Progress", "Health / activity", "Distance, time, kcal, GPS signal, pause, lock.", "Live workout", "/activity/live", "p6 Live workout", R, ""),
 ("Health-ExerciseHeartGuide", "Heart Rate Zone Description", "Health", "Zone thresholds and descriptions.", "About heart-rate zones", "/heart/zones/about", "p6 Time in zones", R, ""),
 ("Health-Hrv", "HRV", "Health", "Scheduled HRV toggle, chart, avg/low/high, distribution.", "HRV", "/heart/hrv", "p5", R, ""),
 ("Health-HrvGuide", "HRV Note", "Health", "HRV explainer.", "About HRV", "/heart/hrv/about", "p2", R, ""),
 ("Health-Menstruation", "Menstrual Cycle", "Health", "Month calendar with period/fertile/safe markers, settings.", "Cycle", "/body/cycle", "p2", R, "Phase is shown by label and pattern, not colour alone."),
 ("Health-OneKeyCheck", "One Key Measurement", "Health", "Body illustration, HR result, one-key measurement button.", "Spot check", "/heart/spot-check", "p5", R, ""),
 ("Health-RingPressure", "Stress", "Health", "Day/Week/Month stress chart, detection toggle, stats, distribution.", "Stress", "/heart/stress", "p5", R, ""),
 ("Health-ReduceFat", "AI Body Reshaping", "Health", "Monthly attempts banner, body outline, records empty.", "Body goal", "/body/goal", "p7", R, "AI photo generation needs a backend service; UI is complete, the call is stubbed."),
 ("Health-ReduceFatAdd", "Photo Generation", "Health", "Upload photo, gender/age/height/weight, fat loss/muscle gain, target, months; Start.", "New body goal", "/body/goal/new", "p4 chips", R, ""),
 ("Health-ReduceFinishProgress", "Completion Progress", "Health", "Month calendar of completion.", "Goal progress", "/body/goal/progress", "p7", R, ""),
 ("Health-SportDetailCalorie", "Exercise Detail – Calories", "Health / activity", "Kcal and duration for a workout.", "Workout summary (time and energy)", "/activity/summary/simple", "p6 Pool swim", R, ""),
 ("Health-SportDetailDistance", "Exercise Detail – Distance", "Health / activity", "Distance, duration, kcal, pace, speed, cadence, stride, steps.", "Run summary", "/activity/summary", "p6 Run summary", R, ""),
 ("Health-SportGo", "Sports Mode", "Health / activity", "List of 13+ sport modes.", "Start a workout", "/activity/start", "p6", R, ""),
 ("Health-Temperature", "Body Temperature", "Health", "Temperature chart, distribution, explainer.", "Skin temperature", "/heart/temperature", "p5 Heart row", R, "Shown as deviation from baseline (skin temperature)."),
 ("Health-RingUltraViolet", "Ultraviolet", "Health", "Timed UV toggle, UV chart, stats, distribution.", "UV exposure", "/body/uv", "p5", G, "Capability-gated."),
 # ---------------- Watch settings & features ----------------
 ("Device-AiReminder", "Smart Reminder", "Watch settings", "Sedentary, drink water reminders, alarms list (+).", "Reminders", "/device/reminders", "p8 Haptics", R, "Alarms become the silent alarm with wake window."),
 ("Device-Album", "Album", "Watch settings", "Select picture for watch display.", "Photos on band", "/device/media/album", "p8", G, "Requires a display; Helium has none, so this shows the not-available state unless a display capability is reported."),
 ("Device-AlbumToDevice", "Album To Device", "Watch settings", "Crop/send selected picture to watch.", "Send photo to band", "/device/media/album/send", "p8", G, "As above."),
 ("Device-BandRevision", "Wearing Calibration", "Watch settings", "Two-step calibration with illustrations.", "Wear calibration", "/device/calibration", "p4 Wear", R, ""),
 ("Device-CallForwarding", "Call Forwarding", "Watch settings", "Toggle; operator fees warning.", "Call forwarding", "/device/call-forwarding", "p8", G, "Requires cellular capability."),
 ("Device-DeviceConnectWarming", "Having Trouble Connecting", "Watch settings", "4 troubleshooting steps.", "Connection help", "/pair/trouble", "p8 Sync failed", R, ""),
 ("Device-Disturb", "Do-Not-Disturb Mode", "Watch settings", "DND toggle; Save.", "Quiet hours", "/device/quiet-hours", "p8 Haptics, Quiet hours", R, ""),
 ("Device-Drink", "Drink Water Reminder", "Watch settings", "Toggle; Save.", "Hydration nudges", "/device/reminders/water", "p8 toggle rows", R, ""),
 ("Device-ECardGuide", "Steps (e-card guide)", "Watch settings", "Blank guide page.", "Card on band: how it works", "/device/card/guide", "p8", G, "Original page was blank; requires a display."),
 ("Device-ECardList", "Business Card", "Watch settings", "Facebook/WhatsApp/Twitter/Instagram QR cards for watch.", "Card on band", "/device/card", "p8", G, "Requires a display."),
 ("Device-EbookManager", "E-book", "Watch settings", "My books, Add book, Edit.", "Books on band", "/device/media/books", "p8", G, "Requires a display."),
 ("Device-HealthyCheck", "Health Monitoring", "Watch settings", "HR every 5 min, SpO2 hourly, stress every 30 min toggles.", "Background monitoring", "/device/monitoring", "p8 toggle rows", R, ""),
 ("Device-LongSit", "Sedentary Reminder", "Watch settings", "Toggle; Save.", "Move nudges", "/device/reminders/move", "p8 Haptics", R, ""),
 ("Device-MessagePush", "Notification", "Watch settings", "Allow notification, SMS, per-app toggles.", "Notifications", "/device/notifications", "p8 toggle rows", R, "Notifications arrive as a haptic pattern."),
 ("Device-MoreSetting", "More", "Watch settings", "Reboot device, factory reset.", "Band maintenance", "/device/advanced", "p8", R, "Destructive actions confirm first."),
 ("Device-MyMenuMusic", "Music List", "Watch settings", "Music list, Edit.", "Music on band", "/device/media/music", "p8", G, "Requires speaker/storage."),
 ("Device-OtherSoftware", "Other Software", "Watch settings", "Toggles for other apps' notifications.", "Other app alerts", "/device/notifications/other", "p8 toggle rows", R, ""),
 ("Device-PlayFile", "Recording Player", "Watch settings", "Play a recording.", "Recording player", "/recordings/player", "p6 Live workout controls", G, "Requires microphone."),
 ("Device-ThemeList", "Watch Theme", "Watch settings", "Watch face list.", "Band faces", "/device/media/faces", "p8", G, "Requires a display."),
 ("Device-WatchFaceInstall", "Watch Face Install", "Watch settings", "Preview + Install.", "Install face", "/device/media/faces/install", "p8", G, "Requires a display."),
 # ---------------- My & account extras ----------------
 ("My-AiHealthAnalysisHistory", "AI Analysis History", "My extras", "Day/Week/Month history; No records.", "Reports", "/assistant/reports", "p7", R, ""),
 ("My-AiHealthAnalysisResult", "AI Health Analysis Report", "My extras", "Health score gauge, loading.", "Weekly report", "/assistant/report", "p7 Coaching", R, ""),
 ("My-ChatSetting", "Chat Settings", "My extras", "Clear local chat history.", "Ask ALVI settings", "/assistant/settings", "p7 Ask ALVI", R, ""),
 ("My-ConstellationFortune", "Constellation", "My extras", "Horoscope by day/week/month (content never loaded).", "—", "", "", NA, "Content was not recoverable (loading only) and horoscopes conflict with ALVI's wellness-only copy rules."),
 ("My-FeedbackSubmit", "Submit Feedback", "My extras", "Description 0/200, contact, photos 0/3, send.", "Send feedback", "/you/feedback/new", "p2", R, ""),
 ("My-FirstProfile", "Profile Setup", "My extras", "Avatar, nickname, next step, skip.", "Set up profile", "/onboarding/profile", "p4 step header", R, ""),
 ("My-Guide", "Background Running Guide", "My extras", "Why background running; per-phone settings list.", "Phone settings guide", "/you/background/phones", "p2 rows", R, ""),
 ("My-StravaCallback", "Strava", "My extras", "Connect Strava.", "Strava", "/you/connections/strava", "p2", R, ""),
 ("My-UserProfile", "User Profile", "My extras", "Avatar, nickname, email, gender, birthday, height, weight, cancel account.", "Profile", "/you/profile", "p2 Navigation rows", R, ""),
 ("My-Web", "Privacy Statement", "My extras", "Web view (blank offline).", "Privacy", "/you/privacy", "p2", R, "Privacy contact is a placeholder, as stated in the ALVI PDF."),
 # ---------------- Meetings & recordings ----------------
 ("Meetings-AudioDetailImport", "Recording Details", "Meetings", "Recording header, start transcription, player.", "Recording", "/recordings/detail", "p6 controls", G, "Requires microphone on the band."),
 ("Meetings-AudioTextEdit", "Recording Text Edit", "Meetings", "Edit transcript text.", "Edit transcript", "/recordings/detail/edit", "p2", G, ""),
 ("Meetings-FileTranscriptionHelp", "Transcription Help", "Meetings", "How to transcribe audio files.", "How transcription works", "/recordings/help", "p4 numbered steps", G, ""),
 ("Meetings-LocalAudio", "Audio File", "Meetings", "Imported audio list; empty.", "Audio files", "/recordings/files", "p8 empty", G, ""),
 ("Meetings-MeetingDetail", "Meeting Minutes Detail", "Meetings", "Minutes text, original text toggle, player.", "Minutes", "/recordings/minutes/detail", "p7", G, ""),
 ("Meetings-MeetingEdit", "Edit Text", "Meetings", "Edit minutes; Completed.", "Edit minutes", "/recordings/minutes/edit", "p2", G, ""),
 ("Meetings-MeetingMinute", "Meeting Minutes", "Meetings", "Search, empty, record button.", "Meeting minutes", "/recordings/minutes", "p8 empty", G, ""),
 ("Meetings-RecordingDelete", "Delete Recordings", "Meetings", "Select all / cancel, Delete.", "Select recordings", "/recordings/select", "p2", G, ""),
 ("Meetings-RecordingList", "Recording Memos", "Meetings", "Recordings list, select, translate; empty.", "Recordings", "/recordings", "p8 empty", G, ""),
 # ---------------- Prayer & Quran ----------------
 ("Prayer-AnlaName", "99 Names of Allah", "Prayer", "Entry: list and collection.", "99 Names", "/faith/names", "p2 rows", R, "Names list loads from a verified content source (not bundled)."),
 ("Prayer-AnlaNameList", "99 Names of Allah List", "Prayer", "Favourites; empty.", "Saved names", "/faith/names/saved", "p8 empty", R, ""),
 ("Prayer-CustomerPraiseHistory", "Praise Record", "Prayer", "Tasbih history; empty.", "Tasbih history", "/faith/tasbih/history", "p8 empty", R, ""),
 ("Prayer-Muslim", "Muslim", "Prayer", "Daily tasbih count card, Day/Month chart, avg/min/max, settings, more.", "Faith", "/faith", "p5 display numeral", R, "Tasbih counter is fully interactive; double-tap on band is the future input."),
 ("Prayer-MuslimCalculateType", "Prayer Settings", "Prayer", "Calculation of prayer times, calculation of Asr.", "Prayer settings", "/faith/settings", "p2", R, ""),
 ("Prayer-MuslimDetail", "Prayer Time", "Prayer", "Prayer times card (image).", "Prayer times", "/faith/prayer-times", "p5 Sleep rows", R, "Times are sample values until location and calculation are connected."),
 ("Prayer-MuslimGoal", "Tasbih Target Setting", "Prayer", "Custom target 3000 toggle.", "Tasbih target", "/faith/tasbih/target", "p2", R, ""),
 ("Prayer-MuslimGoalCustomer", "Custom Praise", "Prayer", "Select target clicks; Start.", "Custom tasbih", "/faith/tasbih/custom", "p4 chips", R, ""),
 ("Prayer-MuslimGoalV2", "Target Setting", "Prayer", "Daily goal 33xN/100xN, custom goal toggles.", "Tasbih goals", "/faith/tasbih/goals", "p2", R, ""),
 ("Prayer-MuslimMore", "More", "Prayer", "Prayer reminder, Quran, 99 names, prayer time, Qibla.", "More", "/faith/more", "p2", R, ""),
 ("Prayer-MuslimRemind", "Prayer Reminder", "Prayer", "Toggle; Save.", "Prayer reminders", "/faith/reminders", "p8 Haptics", R, "Per-prayer rows added."),
 ("Prayer-MuslimTimerSetting", "Fajr Prayer Reminder", "Prayer", "Turn on reminder, before/after Adhan, offset.", "Prayer reminder", "/faith/reminders/prayer", "p8", R, ""),
 ("Prayer-MuslimTypeAsr", "Calculation of Asr", "Prayer", "Shafi'i/Maliki/Hanbali or Hanafi.", "Asr calculation", "/faith/settings/asr", "p2 radio", R, ""),
 ("Prayer-MuslimTypeCalc", "Prayer Times Calculation", "Prayer", "MWL, Jaafari, Karachi, ISNA, Mecca, Egypt.", "Calculation method", "/faith/settings/method", "p2 radio", R, ""),
 ("Prayer-PrayDirection", "Qibla Direction", "Prayer", "Compass with Qibla angle.", "Qibla", "/faith/qibla", "p5 ring", R, "Bearing computed from sample location; compass heading needs a sensor service."),
 ("Prayer-Quran", "Quran", "Prayer", "Chapter, Bookmark.", "Quran", "/faith/quran", "p2", R, ""),
 ("Prayer-QuranChapterList", "Quran Chapters", "Prayer", "Chapter list.", "Surahs", "/faith/quran/chapters", "p2", R, "Standard transliterated surah names. Verse text needs a licensed source."),
 ("Prayer-QuranCollectionList", "Quran Bookmarks", "Prayer", "Bookmarks; empty.", "Bookmarks", "/faith/quran/bookmarks", "p8 empty", R, ""),
]

# ALVI screens from the PDF that had no direct QWatch Pro screen, added so the app is complete.
NEW = [
 ("Welcome", "/", "p4 Welcome"), ("Wake the core (pair)", "/pair", "p4 Pair your band"),
 ("Where will you wear it?", "/onboarding/wear", "p4 Where you wear it"),
 ("It speaks in touch (haptic language)", "/onboarding/haptics", "p4 Haptic language"),
 ("Your plan", "/plan", "p7 Daily plan"), ("Ask ALVI", "/assistant/ask", "p7 Ask ALVI"),
 ("ALVI Intelligence coaching", "/assistant/coaching", "p7 Coaching"),
 ("Widgets", "/you/widgets", "p7 Widgets"), ("Haptics", "/device/haptics", "p8 Haptics"),
 ("Pool swim summary", "/activity/summary/swim", "p6 Pool swim"),
 ("Activity", "/activity", "p6 Activity"),
 ("Sync failed", "/sync-failed", "p8 Sync failed"),
 ("Wear settings", "/device/wear", "p4 Wear"),
 ("More features", "/you/more", "p2 rows"),
 ("Developer: screen index", "/dev/screens", "—"), ("Developer: device simulator", "/dev/device", "—"),
]

def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    rows = [dict(n=i+1, old_id=a, old_title=b, old_section=c, functionality=d, new_title=e,
                 route=f, design_ref=g, status=h, notes=k) for i,(a,b,c,d,e,f,g,h,k) in enumerate(S)]
    os.makedirs(os.path.join(root,'docs'), exist_ok=True)
    json.dump({"screens": rows, "new_alvi_screens": [dict(title=t, route=r, design_ref=d) for t,r,d in NEW]},
              open(os.path.join(root,'docs','screen_mapping.json'),'w'), indent=2, ensure_ascii=False)
    from collections import Counter
    c = Counter(r['status'] for r in rows)
    md = ["# QWatch Pro → ALVI Helium screen mapping", "",
          f"Old screens identified: **{len(rows)}** (from the QWatch Pro Screens canvas; no APK was supplied).", ""]
    md += [f"- {k}: {v}" for k,v in c.items()]
    md += ["", "Status meanings: *Redesigned* = rebuilt in ALVI Helium. *Merged* = covered by another redesigned screen. "
           "*Capability-gated* = fully built, shown with a 'not on this band' state unless the band reports that capability "
           "(display, microphone, cellular, ECG, blood pressure, glucose, UV). *Not applicable* = omitted with the reason given.", "",
           "| # | Old QWatch Pro screen | Section | Functionality | ALVI design reference | Redesigned ALVI screen | Route | Status | Notes |",
           "|---|---|---|---|---|---|---|---|---|"]
    for r in rows:
        md.append(f"| {r['n']} | {r['old_title']} (`{r['old_id']}`) | {r['old_section']} | {r['functionality']} | {r['design_ref']} | {r['new_title']} | `{r['route']}` | {r['status']} | {r['notes']} |")
    md += ["", "## ALVI screens added from the design system", "", "| Screen | Route | Reference |", "|---|---|---|"]
    md += [f"| {t} | `{r}` | {d} |" for t,r,d in NEW]
    open(os.path.join(root,'docs','SCREEN_MAPPING.md'),'w').write("\n".join(md)+"\n")
    esc = lambda s: s.replace("\\","\\\\").replace("'", "\\'").replace("$","\\$")
    dart = ["// GENERATED by tool/screen_mapping.py. Do not edit by hand.", "",
            "class ScreenMapping {", "  final int n;", "  final String oldId, oldTitle, oldSection, functionality, newTitle, route, designRef, status, notes;",
            "  const ScreenMapping(this.n, this.oldId, this.oldTitle, this.oldSection, this.functionality, this.newTitle, this.route, this.designRef, this.status, this.notes);", "}", "",
            "const List<ScreenMapping> screenMappings = ["]
    for r in rows:
        dart.append("  ScreenMapping(%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')," % (
            r['n'], *[esc(r[k]) for k in ('old_id','old_title','old_section','functionality','new_title','route','design_ref','status','notes')]))
    dart += ["];", "", "const List<List<String>> newAlviScreens = ["]
    dart += ["  ['%s', '%s', '%s']," % (esc(t), esc(r), esc(d)) for t,r,d in NEW]
    dart += ["];", ""]
    os.makedirs(os.path.join(root,'lib','app'), exist_ok=True)
    open(os.path.join(root,'lib','app','screen_catalog.dart'),'w').write("\n".join(dart))
    print(len(rows), dict(c))

if __name__ == '__main__':
    main()
