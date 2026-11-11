# QWatch Pro → ALVI Helium screen mapping

Old screens identified: **125** (from the QWatch Pro Screens canvas; no APK was supplied).

- Redesigned: 95
- Redesigned (merged): 1
- Redesigned (capability-gated): 28
- Not applicable: 1

Status meanings: *Redesigned* = rebuilt in ALVI Helium. *Merged* = covered by another redesigned screen. *Capability-gated* = fully built, shown with a 'not on this band' state unless the band reports that capability (display, microphone, cellular, ECG, blood pressure, glucose, UV). *Not applicable* = omitted with the reason given.

| # | Old QWatch Pro screen | Section | Functionality | ALVI design reference | Redesigned ALVI screen | Route | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | Data — Home (`Main`) | Data tab | Daily step total with hourly chart, permission warning row, heart-rate, sleep and exercise cards, tab bar Data/Device/My. | p5 Today | Today | `/today` | Redesigned | Data tab becomes Today: readiness ring, insight, sleep/HRV/steps/skin strip, cards reorderable. Tab bar becomes Today/Sleep/Heart/Activity/You. |
| 2 | First-launch permission prompt (`Data-PermissionPrompt`) | Data tab | Explains contacts/calls/SMS permission for call and SMS reminders, and location for GPS and Bluetooth. | p4 Onboarding list rows | Permissions | `/permissions` | Redesigned | Each permission is a row with why-it-is-needed copy and an Allow action. Never blocks the app. |
| 3 | Data — Steps (`Data-Steps`) | Data tab | Day/Week/Month steps chart with date stepper; total, average, distance, calorie tiles. | p6 Activity | Steps | `/activity/steps` | Redesigned |  |
| 4 | Data — Heart rate (`Data-HeartRate`) | Data tab | Continuous HR toggle, daily HR chart, detail data, real-time HR, zone minutes donut. | p5 Heart | Heart | `/heart` | Redesigned | Heart tab. Zone minutes become labelled bars (colour never the only cue). |
| 5 | Data — Sleep (`Data-Sleep`) | Data tab | Day/Week/Month sleep stages chart, total, deep continuity score, deep/light percentages and durations, awake time, explainer. | p5 Sleep | Sleep | `/sleep` | Redesigned | Four-row stage chart (deep, light, REM, awake dotted) per V1.1 rules. |
| 6 | Data — Exercise record (`Data-Exercise`) | Data tab | Day/Week/Month total exercise time, count, kcal, recent activities, empty state. | p8 Workouts, empty | Workouts | `/activity/workouts` | Redesigned | Shows the ALVI empty state when there are no workouts. |
| 7 | Data — Edit card (`Data-EditCard`) | Data tab | Drag to reorder home cards, toggle Heart Rate / Sleep / Exercise / GPS cards. | p2 Toggle rows | Edit Today | `/today/edit` | Redesigned | ReorderableListView with toggle per card. |
| 8 | Device — Home (no watch) (`Device-Home`) | Device tab | Add device card, Find device, Health monitoring, Unit system, Time format, More. | p8 Your Helium | Your Helium | `/device` | Redesigned | Shows not-paired state with Pair button, or paired state with battery, haptics, wear, find, firmware. |
| 9 | Add: searching (`Device-AddSearching`) | Device tab | Animated search for nearby devices. | p4 Pair your band | Pair: looking for your band | `/pair/searching` | Redesigned |  |
| 10 | Add: search again (`Device-AddSearchAgain`) | Device tab | Nothing found; Search again; 'Problem with connection?' tooltip. | p8 Sync failed | Pair: band not found | `/pair/not-found` | Redesigned |  |
| 11 | Add: connection help menu (`Device-AddHelpMenu`) | Device tab | Help menu (?) opening connection help. | p8 Sync failed | Pair: band not found (help sheet) | `/pair/not-found` | Redesigned (merged) | Help menu is a bottom sheet on the not-found screen linking to Connection help. |
| 12 | My — Home (`My-Home`) | My tab | Login/Register, background protection guide, profile, goal, theme, third-party, FAQ, feedback, about. | p2 List rows | You | `/you` | Redesigned | Adds More features: Circle, Faith, Recordings, Cycle, Body goal, Assistant. |
| 13 | Background protection guide 1 (`My-BackgroundGuide1`) | My tab | Explains effects of disconnection (no notifications, no call alerts); 'to set'. | p8 Sync failed layout | Keep ALVI connected | `/you/background` | Redesigned |  |
| 14 | Background protection guide 2 (`My-BackgroundGuide2`) | My tab | Checklist: notification access, battery whitelist, auto-start, lock app, power protection; each 'not completed'. | p2 Navigation rows + status tokens | Connection checklist | `/you/background/checklist` | Redesigned | Each item carries a word status (Done/To do), not colour alone. |
| 15 | My — Goal (`My-Goal`) | My tab | Steps, calorie, distance, exercise time, sleep time goals; Save. | p2 Navigation rows | Goals | `/you/goals` | Redesigned | Editable with steppers in a bottom sheet. |
| 16 | My — Theme style (`My-Theme`) | My tab | Pick default/pink/Diablo/blue colour theme. | p2 Dark and light tokens | Appearance | `/you/appearance` | Redesigned | ALVI ships Dark, Light and System only; decorative colour themes are not part of the design system. |
| 17 | Third-party services (`My-ThirdParty`) | My tab | Google Fit and Strava links. | p2 Navigation rows | Connected services | `/you/connections` | Redesigned | No third-party logos are reproduced. |
| 18 | FAQ (web, blank offline) (`My-FAQ`) | My tab | Web view of FAQ (blank offline). | p2 List rows | Help and FAQ | `/you/faq` | Redesigned | Original content was not recoverable (blank web view). Questions shown are ALVI placeholders to be replaced by approved copy. |
| 19 | Feedback (`My-Feedback`) | My tab | Feedback categories: suggestions, function faults, device faults, hardware. | p2 List rows | Feedback | `/you/feedback` | Redesigned | Display-specific categories (raise to wake, SMS on watch) adapted to band equivalents. |
| 20 | About (`My-About`) | My tab | App icon, name, version, clear cache, privacy statement link. | p2 | About | `/you/about` | Redesigned | ALVI identity, not QWatch Pro. |
| 21 | Account — Login (`Account-Login`) | Account | Email/password login, forgot password, register, privacy link. | p4 Welcome | Sign in | `/account/sign-in` | Redesigned |  |
| 22 | Account — Register (`Account-Register`) | Account | Email, password, confirm password; Register. | p4 | Create account | `/account/create` | Redesigned |  |
| 23 | Account — Retrieve password (`Account-ForgotPassword`) | Account | Email, verification code with Send, new password twice; Confirm. | p4 | Reset password | `/account/reset` | Redesigned |  |
| 24 | Blood Oxygen (`Health-BloodOxygen`) | Health | Timed SpO2 toggle, SpO2 chart, detail data, distribution, explainer. | p5 Heart row | Oxygen and breathing | `/heart/oxygen` | Redesigned |  |
| 25 | Data Source – Blood Oxygen (`Health-BloodOxygenGuide`) | Health | Where SpO2 data comes from, how to wear. | p4 Wear | About oxygen readings | `/heart/oxygen/about` | Redesigned |  |
| 26 | Blood Sugar (`Health-BloodSugar`) | Health | Glucose chart, real-time glucose, start measurement, explainer. | p5 Heart | Glucose (estimate) | `/heart/glucose` | Redesigned (capability-gated) | Hidden unless the band reports a glucose capability. Wellness wording only. |
| 27 | Energy Score (`Health-BodyBattery`) | Health | All-day energy score chart, consumed/charged, energy recovery bars, missing-sleep banner. | p5 Readiness | Readiness | `/today/readiness` | Redesigned | Energy Score maps to ALVI Readiness with 'what shaped it' bars and energy-through-the-day line. |
| 28 | Energy Score – Description (`Health-BodyBatteryGuide`) | Health | What it is, how to improve, rules, action guide. | p5 | About readiness | `/today/readiness/about` | Redesigned |  |
| 29 | Energy Score – More Data (`Health-BodyBatteryMoreData`) | Health | Hourly data list for a day (No data). | p2 Spec/data rows | Readiness data | `/today/readiness/data` | Redesigned |  |
| 30 | Energy Score – Week/Month (`Health-BodyBatteryWeekMonth`) | Health | Week/Month bar chart. | p5 Last 7 days | Readiness trends | `/today/readiness/trends` | Redesigned |  |
| 31 | Blood Pressure (`Health-BloodPressure`) | Health | Timed BP toggle, SBP/DBP chart, normal ranges, explainer. | p5 | Blood pressure (estimate) | `/heart/blood-pressure` | Redesigned (capability-gated) | Capability-gated. Wellness wording only. |
| 32 | ECG (`Health-Ecg`) | Health | Live ECG trace, bpm/QTc/HRV, start measurement, latest record, how to measure. | p5 | ECG | `/heart/ecg` | Redesigned (capability-gated) | Capability-gated. |
| 33 | ECG Details (`Health-EcgDetail`) | Health | Trace, HR avg/high/low, HRV SDNN/RMSSD, share/delete. | p5 | ECG record | `/heart/ecg/record` | Redesigned (capability-gated) |  |
| 34 | ECG – Description (`Health-EcgGuide`) | Health | About ECG, principle, usage, results. | p2 | About ECG | `/heart/ecg/about` | Redesigned (capability-gated) |  |
| 35 | ECG – How to Measure (`Health-EcgGuideMeasure`) | Health | Measurement method with illustration. | p4 numbered steps | How to take an ECG | `/heart/ecg/how` | Redesigned (capability-gated) |  |
| 36 | ECG – All Data (`Health-EcgList`) | Health | Filter tabs (All/Sinus/AF/...), list, calendar. | p8 empty state | All ECG records | `/heart/ecg/all` | Redesigned (capability-gated) |  |
| 37 | ECG Risk Analysis (`Health-EcgRiskAnalysis`) | Health | Sign-in-required dialog before analysis. | p8 States | ECG analysis (sign-in gate) | `/heart/ecg/risk` | Redesigned (capability-gated) | Shows the permission/sign-in state from V1.1 'states to spec'. |
| 38 | Add Anniversary (`Health-AddMemorial`) | Health / social | Event name, date, pin to top; Save. | p2 Rows | Add a date | `/circle/partner/dates/add` | Redesigned |  |
| 39 | Unpair Partner (`Health-DeleteLover`) | Health / social | Warning about unpairing and 180-day restore; Unpair. | p8 Unpair | Stop sharing with partner | `/circle/partner/remove` | Redesigned |  |
| 40 | Family Ranking (`Health-FriendRanking`) | Health / social | Ranking of family steps with likes, share, add. | p2 Rows | Family | `/circle/family` | Redesigned | Stock photo header removed. |
| 41 | New Friends (`Health-FriendsInviteList`) | Health / social | Friend requests list, empty state, Invite friends. | p8 empty state | Requests | `/circle/requests` | Redesigned |  |
| 42 | Choose a Pair (`Health-InviterUser`) | Health / social | Enter other person's email, scan, Send invitation. | p4 | Invite someone | `/circle/invite` | Redesigned |  |
| 43 | Friends Who Like Me (`Health-LikeFriendsList`) | Health / social | List of friends who liked you. | p8 empty state | Cheers | `/circle/cheers` | Redesigned |  |
| 44 | Love Certificates (`Health-LoverCertificateList`) | Health / social | Locked milestone cards by days together. | p2 Rows | Milestones | `/circle/partner/milestones` | Redesigned | Photographic cards replaced by text milestones. |
| 45 | Partner Health (`Health-LoverHealth`) | Health / social | Week strip, partner activity, sleep, HR, SpO2. | p5 | Partner's day | `/circle/partner/health` | Redesigned | Only data the partner chose to share. |
| 46 | Pairing Requests (`Health-LoverInviteList`) | Health / social | Pending partner requests. | p8 empty | Partner requests | `/circle/partner/requests` | Redesigned |  |
| 47 | Invitation Sent (`Health-LoverInviterResult`) | Health / social | Invitation sent copy, expires in 1 day; I know. | p4 | Invitation sent | `/circle/invite/sent` | Redesigned |  |
| 48 | Anniversary (`Health-LoverMemorial`) | Health / social | Days together card, add date. | p5 display numeral | Dates | `/circle/partner/dates` | Redesigned |  |
| 49 | Space of Love (`Health-LoverSpace`) | Health / social | Hero image, explainer, invite significant other. | p4 haptic language | Partner | `/circle/partner` | Redesigned | Reframed as sending a touch (haptic) to your partner. |
| 50 | My QR Code (`Health-MyQrCode`) | Health / social | QR code to add me as friend; save picture. | p2 | My code | `/circle/my-code` | Redesigned | QR is drawn from a sample payload placeholder. |
| 51 | GPS Running (`Health-Gps`) | Health / activity | Map, distance, running record, start. | p6 Activity | Outdoor run | `/activity/outdoor` | Redesigned | Map tile area is a placeholder; no map SDK bundled. |
| 52 | GPS Running – History (`Health-GpsHistory`) | Health / activity | Totals and recent runs by date. | p6 | Run history | `/activity/outdoor/history` | Redesigned |  |
| 53 | GPS Run Countdown (`Health-GpsPrepare`) | Health / activity | 3-2-1 countdown. | p6 | Countdown | `/activity/countdown` | Redesigned |  |
| 54 | GPS Run In Progress (`Health-GpsRun`) | Health / activity | Distance, time, kcal, GPS signal, pause, lock. | p6 Live workout | Live workout | `/activity/live` | Redesigned |  |
| 55 | Heart Rate Zone Description (`Health-ExerciseHeartGuide`) | Health | Zone thresholds and descriptions. | p6 Time in zones | About heart-rate zones | `/heart/zones/about` | Redesigned |  |
| 56 | HRV (`Health-Hrv`) | Health | Scheduled HRV toggle, chart, avg/low/high, distribution. | p5 | HRV | `/heart/hrv` | Redesigned |  |
| 57 | HRV Note (`Health-HrvGuide`) | Health | HRV explainer. | p2 | About HRV | `/heart/hrv/about` | Redesigned |  |
| 58 | Menstrual Cycle (`Health-Menstruation`) | Health | Month calendar with period/fertile/safe markers, settings. | p2 | Cycle | `/body/cycle` | Redesigned | Phase is shown by label and pattern, not colour alone. |
| 59 | One Key Measurement (`Health-OneKeyCheck`) | Health | Body illustration, HR result, one-key measurement button. | p5 | Spot check | `/heart/spot-check` | Redesigned |  |
| 60 | Stress (`Health-RingPressure`) | Health | Day/Week/Month stress chart, detection toggle, stats, distribution. | p5 | Stress | `/heart/stress` | Redesigned |  |
| 61 | AI Body Reshaping (`Health-ReduceFat`) | Health | Monthly attempts banner, body outline, records empty. | p7 | Body goal | `/body/goal` | Redesigned | AI photo generation needs a backend service; UI is complete, the call is stubbed. |
| 62 | Photo Generation (`Health-ReduceFatAdd`) | Health | Upload photo, gender/age/height/weight, fat loss/muscle gain, target, months; Start. | p4 chips | New body goal | `/body/goal/new` | Redesigned |  |
| 63 | Completion Progress (`Health-ReduceFinishProgress`) | Health | Month calendar of completion. | p7 | Goal progress | `/body/goal/progress` | Redesigned |  |
| 64 | Exercise Detail – Calories (`Health-SportDetailCalorie`) | Health / activity | Kcal and duration for a workout. | p6 Pool swim | Workout summary (time and energy) | `/activity/summary/simple` | Redesigned |  |
| 65 | Exercise Detail – Distance (`Health-SportDetailDistance`) | Health / activity | Distance, duration, kcal, pace, speed, cadence, stride, steps. | p6 Run summary | Run summary | `/activity/summary` | Redesigned |  |
| 66 | Sports Mode (`Health-SportGo`) | Health / activity | List of 13+ sport modes. | p6 | Start a workout | `/activity/start` | Redesigned |  |
| 67 | Body Temperature (`Health-Temperature`) | Health | Temperature chart, distribution, explainer. | p5 Heart row | Skin temperature | `/heart/temperature` | Redesigned | Shown as deviation from baseline (skin temperature). |
| 68 | Ultraviolet (`Health-RingUltraViolet`) | Health | Timed UV toggle, UV chart, stats, distribution. | p5 | UV exposure | `/body/uv` | Redesigned (capability-gated) | Capability-gated. |
| 69 | Smart Reminder (`Device-AiReminder`) | Watch settings | Sedentary, drink water reminders, alarms list (+). | p8 Haptics | Reminders | `/device/reminders` | Redesigned | Alarms become the silent alarm with wake window. |
| 70 | Album (`Device-Album`) | Watch settings | Select picture for watch display. | p8 | Photos on band | `/device/media/album` | Redesigned (capability-gated) | Requires a display; Helium has none, so this shows the not-available state unless a display capability is reported. |
| 71 | Album To Device (`Device-AlbumToDevice`) | Watch settings | Crop/send selected picture to watch. | p8 | Send photo to band | `/device/media/album/send` | Redesigned (capability-gated) | As above. |
| 72 | Wearing Calibration (`Device-BandRevision`) | Watch settings | Two-step calibration with illustrations. | p4 Wear | Wear calibration | `/device/calibration` | Redesigned |  |
| 73 | Call Forwarding (`Device-CallForwarding`) | Watch settings | Toggle; operator fees warning. | p8 | Call forwarding | `/device/call-forwarding` | Redesigned (capability-gated) | Requires cellular capability. |
| 74 | Having Trouble Connecting (`Device-DeviceConnectWarming`) | Watch settings | 4 troubleshooting steps. | p8 Sync failed | Connection help | `/pair/trouble` | Redesigned |  |
| 75 | Do-Not-Disturb Mode (`Device-Disturb`) | Watch settings | DND toggle; Save. | p8 Haptics, Quiet hours | Quiet hours | `/device/quiet-hours` | Redesigned |  |
| 76 | Drink Water Reminder (`Device-Drink`) | Watch settings | Toggle; Save. | p8 toggle rows | Hydration nudges | `/device/reminders/water` | Redesigned |  |
| 77 | Steps (e-card guide) (`Device-ECardGuide`) | Watch settings | Blank guide page. | p8 | Card on band: how it works | `/device/card/guide` | Redesigned (capability-gated) | Original page was blank; requires a display. |
| 78 | Business Card (`Device-ECardList`) | Watch settings | Facebook/WhatsApp/Twitter/Instagram QR cards for watch. | p8 | Card on band | `/device/card` | Redesigned (capability-gated) | Requires a display. |
| 79 | E-book (`Device-EbookManager`) | Watch settings | My books, Add book, Edit. | p8 | Books on band | `/device/media/books` | Redesigned (capability-gated) | Requires a display. |
| 80 | Health Monitoring (`Device-HealthyCheck`) | Watch settings | HR every 5 min, SpO2 hourly, stress every 30 min toggles. | p8 toggle rows | Background monitoring | `/device/monitoring` | Redesigned |  |
| 81 | Sedentary Reminder (`Device-LongSit`) | Watch settings | Toggle; Save. | p8 Haptics | Move nudges | `/device/reminders/move` | Redesigned |  |
| 82 | Notification (`Device-MessagePush`) | Watch settings | Allow notification, SMS, per-app toggles. | p8 toggle rows | Notifications | `/device/notifications` | Redesigned | Notifications arrive as a haptic pattern. |
| 83 | More (`Device-MoreSetting`) | Watch settings | Reboot device, factory reset. | p8 | Band maintenance | `/device/advanced` | Redesigned | Destructive actions confirm first. |
| 84 | Music List (`Device-MyMenuMusic`) | Watch settings | Music list, Edit. | p8 | Music on band | `/device/media/music` | Redesigned (capability-gated) | Requires speaker/storage. |
| 85 | Other Software (`Device-OtherSoftware`) | Watch settings | Toggles for other apps' notifications. | p8 toggle rows | Other app alerts | `/device/notifications/other` | Redesigned |  |
| 86 | Recording Player (`Device-PlayFile`) | Watch settings | Play a recording. | p6 Live workout controls | Recording player | `/recordings/player` | Redesigned (capability-gated) | Requires microphone. |
| 87 | Watch Theme (`Device-ThemeList`) | Watch settings | Watch face list. | p8 | Band faces | `/device/media/faces` | Redesigned (capability-gated) | Requires a display. |
| 88 | Watch Face Install (`Device-WatchFaceInstall`) | Watch settings | Preview + Install. | p8 | Install face | `/device/media/faces/install` | Redesigned (capability-gated) | Requires a display. |
| 89 | AI Analysis History (`My-AiHealthAnalysisHistory`) | My extras | Day/Week/Month history; No records. | p7 | Reports | `/assistant/reports` | Redesigned |  |
| 90 | AI Health Analysis Report (`My-AiHealthAnalysisResult`) | My extras | Health score gauge, loading. | p7 Coaching | Weekly report | `/assistant/report` | Redesigned |  |
| 91 | Chat Settings (`My-ChatSetting`) | My extras | Clear local chat history. | p7 Ask ALVI | Ask ALVI settings | `/assistant/settings` | Redesigned |  |
| 92 | Constellation (`My-ConstellationFortune`) | My extras | Horoscope by day/week/month (content never loaded). |  | — | `` | Not applicable | Content was not recoverable (loading only) and horoscopes conflict with ALVI's wellness-only copy rules. |
| 93 | Submit Feedback (`My-FeedbackSubmit`) | My extras | Description 0/200, contact, photos 0/3, send. | p2 | Send feedback | `/you/feedback/new` | Redesigned |  |
| 94 | Profile Setup (`My-FirstProfile`) | My extras | Avatar, nickname, next step, skip. | p4 step header | Set up profile | `/onboarding/profile` | Redesigned |  |
| 95 | Background Running Guide (`My-Guide`) | My extras | Why background running; per-phone settings list. | p2 rows | Phone settings guide | `/you/background/phones` | Redesigned |  |
| 96 | Strava (`My-StravaCallback`) | My extras | Connect Strava. | p2 | Strava | `/you/connections/strava` | Redesigned |  |
| 97 | User Profile (`My-UserProfile`) | My extras | Avatar, nickname, email, gender, birthday, height, weight, cancel account. | p2 Navigation rows | Profile | `/you/profile` | Redesigned |  |
| 98 | Privacy Statement (`My-Web`) | My extras | Web view (blank offline). | p2 | Privacy | `/you/privacy` | Redesigned | Privacy contact is a placeholder, as stated in the ALVI PDF. |
| 99 | Recording Details (`Meetings-AudioDetailImport`) | Meetings | Recording header, start transcription, player. | p6 controls | Recording | `/recordings/detail` | Redesigned (capability-gated) | Requires microphone on the band. |
| 100 | Recording Text Edit (`Meetings-AudioTextEdit`) | Meetings | Edit transcript text. | p2 | Edit transcript | `/recordings/detail/edit` | Redesigned (capability-gated) |  |
| 101 | Transcription Help (`Meetings-FileTranscriptionHelp`) | Meetings | How to transcribe audio files. | p4 numbered steps | How transcription works | `/recordings/help` | Redesigned (capability-gated) |  |
| 102 | Audio File (`Meetings-LocalAudio`) | Meetings | Imported audio list; empty. | p8 empty | Audio files | `/recordings/files` | Redesigned (capability-gated) |  |
| 103 | Meeting Minutes Detail (`Meetings-MeetingDetail`) | Meetings | Minutes text, original text toggle, player. | p7 | Minutes | `/recordings/minutes/detail` | Redesigned (capability-gated) |  |
| 104 | Edit Text (`Meetings-MeetingEdit`) | Meetings | Edit minutes; Completed. | p2 | Edit minutes | `/recordings/minutes/edit` | Redesigned (capability-gated) |  |
| 105 | Meeting Minutes (`Meetings-MeetingMinute`) | Meetings | Search, empty, record button. | p8 empty | Meeting minutes | `/recordings/minutes` | Redesigned (capability-gated) |  |
| 106 | Delete Recordings (`Meetings-RecordingDelete`) | Meetings | Select all / cancel, Delete. | p2 | Select recordings | `/recordings/select` | Redesigned (capability-gated) |  |
| 107 | Recording Memos (`Meetings-RecordingList`) | Meetings | Recordings list, select, translate; empty. | p8 empty | Recordings | `/recordings` | Redesigned (capability-gated) |  |
| 108 | 99 Names of Allah (`Prayer-AnlaName`) | Prayer | Entry: list and collection. | p2 rows | 99 Names | `/faith/names` | Redesigned | Names list loads from a verified content source (not bundled). |
| 109 | 99 Names of Allah List (`Prayer-AnlaNameList`) | Prayer | Favourites; empty. | p8 empty | Saved names | `/faith/names/saved` | Redesigned |  |
| 110 | Praise Record (`Prayer-CustomerPraiseHistory`) | Prayer | Tasbih history; empty. | p8 empty | Tasbih history | `/faith/tasbih/history` | Redesigned |  |
| 111 | Muslim (`Prayer-Muslim`) | Prayer | Daily tasbih count card, Day/Month chart, avg/min/max, settings, more. | p5 display numeral | Faith | `/faith` | Redesigned | Tasbih counter is fully interactive; double-tap on band is the future input. |
| 112 | Prayer Settings (`Prayer-MuslimCalculateType`) | Prayer | Calculation of prayer times, calculation of Asr. | p2 | Prayer settings | `/faith/settings` | Redesigned |  |
| 113 | Prayer Time (`Prayer-MuslimDetail`) | Prayer | Prayer times card (image). | p5 Sleep rows | Prayer times | `/faith/prayer-times` | Redesigned | Times are sample values until location and calculation are connected. |
| 114 | Tasbih Target Setting (`Prayer-MuslimGoal`) | Prayer | Custom target 3000 toggle. | p2 | Tasbih target | `/faith/tasbih/target` | Redesigned |  |
| 115 | Custom Praise (`Prayer-MuslimGoalCustomer`) | Prayer | Select target clicks; Start. | p4 chips | Custom tasbih | `/faith/tasbih/custom` | Redesigned |  |
| 116 | Target Setting (`Prayer-MuslimGoalV2`) | Prayer | Daily goal 33xN/100xN, custom goal toggles. | p2 | Tasbih goals | `/faith/tasbih/goals` | Redesigned |  |
| 117 | More (`Prayer-MuslimMore`) | Prayer | Prayer reminder, Quran, 99 names, prayer time, Qibla. | p2 | More | `/faith/more` | Redesigned |  |
| 118 | Prayer Reminder (`Prayer-MuslimRemind`) | Prayer | Toggle; Save. | p8 Haptics | Prayer reminders | `/faith/reminders` | Redesigned | Per-prayer rows added. |
| 119 | Fajr Prayer Reminder (`Prayer-MuslimTimerSetting`) | Prayer | Turn on reminder, before/after Adhan, offset. | p8 | Prayer reminder | `/faith/reminders/prayer` | Redesigned |  |
| 120 | Calculation of Asr (`Prayer-MuslimTypeAsr`) | Prayer | Shafi'i/Maliki/Hanbali or Hanafi. | p2 radio | Asr calculation | `/faith/settings/asr` | Redesigned |  |
| 121 | Prayer Times Calculation (`Prayer-MuslimTypeCalc`) | Prayer | MWL, Jaafari, Karachi, ISNA, Mecca, Egypt. | p2 radio | Calculation method | `/faith/settings/method` | Redesigned |  |
| 122 | Qibla Direction (`Prayer-PrayDirection`) | Prayer | Compass with Qibla angle. | p5 ring | Qibla | `/faith/qibla` | Redesigned | Bearing computed from sample location; compass heading needs a sensor service. |
| 123 | Quran (`Prayer-Quran`) | Prayer | Chapter, Bookmark. | p2 | Quran | `/faith/quran` | Redesigned |  |
| 124 | Quran Chapters (`Prayer-QuranChapterList`) | Prayer | Chapter list. | p2 | Surahs | `/faith/quran/chapters` | Redesigned | Standard transliterated surah names. Verse text needs a licensed source. |
| 125 | Quran Bookmarks (`Prayer-QuranCollectionList`) | Prayer | Bookmarks; empty. | p8 empty | Bookmarks | `/faith/quran/bookmarks` | Redesigned |  |

## ALVI screens added from the design system

| Screen | Route | Reference |
|---|---|---|
| Welcome | `/` | p4 Welcome |
| Wake the core (pair) | `/pair` | p4 Pair your band |
| Where will you wear it? | `/onboarding/wear` | p4 Where you wear it |
| It speaks in touch (haptic language) | `/onboarding/haptics` | p4 Haptic language |
| Your plan | `/plan` | p7 Daily plan |
| Ask ALVI | `/assistant/ask` | p7 Ask ALVI |
| ALVI Intelligence coaching | `/assistant/coaching` | p7 Coaching |
| Widgets | `/you/widgets` | p7 Widgets |
| Haptics | `/device/haptics` | p8 Haptics |
| Pool swim summary | `/activity/summary/swim` | p6 Pool swim |
| Activity | `/activity` | p6 Activity |
| Sync failed | `/sync-failed` | p8 Sync failed |
| Wear settings | `/device/wear` | p4 Wear |
| More features | `/you/more` | p2 rows |
| Developer: screen index | `/dev/screens` | — |
| Developer: device simulator | `/dev/device` | — |
