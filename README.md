# ALVI Helium — Flutter app

Every recoverable QWatch Pro screen, redesigned on the **ALVI Helium design system V1.2** and built in Flutter and Dart. The app keeps ALVI's identity. It contains no QWatch Pro branding, logo or product identity.

## What's here

| | |
|---|---|
| Old QWatch Pro screens identified | **125** (from the "QWatch Pro Screens" canvas: QWatch Pro 1.0.3.55, decoded APK, Android 15 emulator) |
| Redesigned | 95 fully, 1 merged into another screen, 28 capability-gated (built, but shown as "not on this band" unless the band reports the hardware) |
| Not applicable | 1 (Constellation/horoscope; see mapping) |
| Extra ALVI screens from the design PDF | 16 (welcome, pairing, wear, haptic language, plan, Ask ALVI, coaching, widgets, haptics, pool swim, sync failed, developer tools) |
| Routes | 139 unique routes in `lib/app/routes.dart` |

Full mapping: [`docs/SCREEN_MAPPING.md`](docs/SCREEN_MAPPING.md). Machine-readable versions are [`docs/screen_mapping.json`](docs/screen_mapping.json) and [`docs/screen_mapping.csv`](docs/screen_mapping.csv). Inside the app, **You › Developer › Screen index** lists every old screen and opens its redesign.

## Run it

This repository holds `lib/`, `test/`, `assets/` and `pubspec.yaml`. Generate the platform folders once:

```bash
flutter create --org com.alvi --project-name alvi_helium --platforms=android,ios,web .
flutter pub get
flutter analyze
flutter test
flutter run
```

Requires Flutter 3.27 or later. The only dependency is the Flutter SDK, with no third-party packages. Inter and JetBrains Mono are bundled under `assets/fonts` (SIL OFL).

On first launch, the Welcome screen offers **Explore with sample data**, which goes straight to Today.

## Structure

```
lib/
  main.dart                    entry; picks the WearableService implementation
  app/app.dart                 MaterialApp, dark/light themes, text scaling to 200%
  app/routes.dart              every route
  app/screen_catalog.dart      generated QWatch Pro → ALVI mapping (tool/screen_mapping.py)
  design/tokens.dart           colour tokens (dark/light), accents, status, spacing, radii, motion, sizes
  design/typography.dart       ALVI type scale (Inter, JetBrains Mono)
  design/theme.dart            ThemeData built from tokens
  widgets/                     reusable components: buttons, toggles, chips, segmented, list rows,
                               stat grids, contributor bars, charts (line, bars, sleep stages, ring,
                               ECG, compass), haptic glyphs, empty states, device banner,
                               capability gate, sheets
  services/wearable_service.dart        band contract (no proprietary SDK calls assumed)
  services/sample_wearable_service.dart simulator with labelled sample data
  data/sample_data.dart        SAMPLE DATA ONLY
  state/app_state.dart         app state (ChangeNotifier + InheritedNotifier)
  screens/                     onboarding, account, today, sleep, heart, activity, you, device,
                               body, circle, assistant, recordings, faith, dev, templates
test/screens_test.dart         route coverage test, render test for every route (dark/light,
                               Helium/all capabilities), pairing flow, tasbih
tool/screen_mapping.py         source of truth for the mapping; regenerates docs + catalog
```

## Design system applied

- **Tokens:** surface, surface-raised, chart-band, divider, line-strong, border-control (#707070/#757575 for 3:1), ink, ink-body and ink-muted, in dark and light. The light theme background is the 90° gradient #D8D8D8 → #E8E8E8.
- **Accent colours appear on graphics only.** The status colours good, caution and alert always come with a word.
- **Type:** Display numeral Inter Light, Headline SemiBold, Insight Light 20/29, Body 16/25, Label 11 caps +0.2em (0.12em past 18 characters), Spec/data JetBrains Mono Bold, Fine print 12/18.
- **Layout:**
  - Spacing follows the 4–64 scale, with 24 pt side margins.
  - Corner radii: 4 for tags, 8 for cards, and pill shapes for buttons.
  - Primary buttons are 56 pt and secondary buttons 52 pt.
  - List rows are at least 56 pt tall, and touch targets are at least 44 pt.
  - The tab bar has 5 items: Today, Sleep, Heart, Activity and You.
- **Charts:**
  - Lines are 2 px with an 8 px end dot and a mean band, with no gradients.
  - Sleep stages are shown as four labelled rows, with awake as a dotted line.
  - Donuts from QWatch Pro are replaced by labelled bars, so colour is never the only cue.
- **Haptic glyphs:** each glyph keeps one meaning everywhere it appears.
- **Copy:** sentence case, short declarative lines, ALVI in capitals, no emoji, wellness wording only.

## Wearable SDK and sample data

The ALVI SDK is not available yet, so the device layer is kept separate from the UI:

- `WearableService` covers connection state, capabilities, scan, pair, unpair, reconnect, sync, haptics, haptic strength, find band, wear spot and size, monitoring switches, heart-rate sharing, one-shot measurement, restart and factory reset.
- `SampleWearableService` simulates it. **Every data screen shows a "SAMPLE DATA · Not from a band" tag.** No screen presents sample values as live data.
- The app implements these connection states: not paired, searching, not found, connecting, connected, disconnected and sync failed. Data tabs show a banner when the band is not connected.
- **You › Developer › Device simulator** can jump to any state, make the next scan or sync fail, and enable every capability to preview the gated screens.

To integrate the SDK, implement `WearableService` with it and pass it in `main.dart`. Screens don't change.

## Known limits

- **No APK was supplied.** Old screens come from the 125 canvas screenshots. They were captured without a paired watch or an account, so many show empty states, and content that never loaded is noted in the mapping. Examples are the FAQ and privacy web views, the constellation page and the e-card guide.
- **Accounts, the assistant, AI body-goal previews, Strava and Health Connect, maps, the compass sensor and audio playback are stubbed.** The UI is complete, and each stub says so on screen.
- **Faith content:** surah names are standard transliterations. Verse text and the 99 Names need a verified, licensed source and are not bundled. Prayer times are sample values.
- **Not compiled in this environment.** This build session could not download the Flutter SDK, because its network blocks `storage.googleapis.com` and `pub.dev`. Every Dart file passes a full syntax parse (tree-sitter Dart grammar), and constructor arguments and member references were checked by script. Run `flutter analyze` and `flutter test` first, and expect a few minor fixes.
