# Ninja Runner Developer Handoff

This is the Flutter-only Ninja Runner prototype for KidNation. It uses
KidNation/KNSoccer-inspired characters and arena themes, but it does not reuse
soccer match mechanics.

## Links

- Draft PR: https://github.com/vanessakn/NinjaRunner/pull/1
- Playable review build: https://ninja-runner-review.vanessa296799.chatgpt.site

## Clone And Run

```bash
git clone https://github.com/vanessakn/NinjaRunner.git
cd NinjaRunner
git checkout codex/ninja-runner-flutter
flutter pub get
flutter run
```

For Chrome:

```bash
flutter run -d chrome
```

For available devices:

```bash
flutter devices
flutter run -d <device-id>
```

## Validate

```bash
flutter test
flutter analyze
flutter build web --release --base-href=/ --no-wasm-dry-run
```

## Current Features

- Single-runner answer-gate gameplay for ages 5-8
- Four levels with kid-friendly pacing
- Locked/unlocked level progression
- Persistent local unlock progress
- Best score tracking per level
- Vertical runner CustomPainter gameplay scene
- Runner-style star pickups, answer gates, boost feedback, and mobile HUD
- Lightweight haptic/system-sound hooks for start, correct, wrong, and complete states
- Character portrait asset slots with placeholder runner palettes
- Theme background asset slots with placeholder arena accents
- Android and iOS build targets
- Android Impeller opt-in via `AndroidManifest.xml`
- Flutter web export served through Sites

## Important Files

- `lib/main.dart`: app entrypoint
- `lib/ninja_runner/ui/ninja_runner_screen.dart`: screen, controls, level select
- `lib/ninja_runner/rendering/runner_painter.dart`: gameplay visuals
- `lib/ninja_runner/game/runner_controller.dart`: game state machine
- `lib/ninja_runner/game/level_progress_store.dart`: local progress and best scores
- `lib/ninja_runner/data/sample_content_pack.dart`: current level/content and asset id data
- `test/widget_test.dart`: end-to-end widget behavior
- `test/ninja_runner/`: model, controller, analytics, and progress tests

## Build Notes

Flutter 3.44 uses Impeller by default on iOS and Android API 29+. Android also
has an explicit Impeller opt-in:

```xml
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="true" />
```

iOS uses Impeller as its only supported Flutter renderer.

Native Android/iOS builds still need real device QA. The latest Codex machine
only had macOS and Chrome available:

```bash
flutter devices
```

reported no iOS/Android device or emulator.

## Next Suggested Work

1. Run the real device QA checklist in `docs/mobile-qa-handoff.md`.
2. Tune touch zones, pacing, and haptic/sound intensity from real iOS/Android notes.
3. Replace placeholder character/theme visuals with official KidNation assets when available.
4. Add an asset-loading layer that maps `portraitAssetId` and `backgroundAssetId` to image files.
5. Keep the KNSoccer boundary: no balls, goals, teams, matches, dribbling, passing, or shooting.
