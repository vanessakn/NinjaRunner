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
- Three levels with increasing speed
- Locked/unlocked level progression
- Persistent local unlock progress
- Best score tracking per level
- Polished CustomPainter gameplay scene
- Android and iOS build targets
- Android Impeller opt-in via `AndroidManifest.xml`
- Flutter web export served through Sites

## Important Files

- `lib/main.dart`: app entrypoint
- `lib/ninja_runner/ui/ninja_runner_screen.dart`: screen, controls, level select
- `lib/ninja_runner/rendering/runner_painter.dart`: gameplay visuals
- `lib/ninja_runner/game/runner_controller.dart`: game state machine
- `lib/ninja_runner/game/level_progress_store.dart`: local progress and best scores
- `lib/ninja_runner/data/sample_content_pack.dart`: current level/content data
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

Native Android/iOS builds were not fully verified on the original machine
because the Android SDK was missing and Xcode/CocoaPods were incomplete there.

## Next Suggested Work

1. Add character portrait asset slots and placeholders for Jordan, Nari, and Arjun.
2. Add theme background asset slots for Brazil Arena, France Arena, and Portugal Arena.
3. Keep the KNSoccer boundary: no balls, goals, teams, matches, dribbling, passing, or shooting.
4. Replace placeholder art with official KidNation assets when available.
