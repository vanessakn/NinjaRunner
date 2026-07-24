# Ninja Runner Team Checkpoint

## Current Build

- Branch: `codex/ninja-runner-flutter`
- Repo: https://github.com/vanessakn/NinjaRunner
- Draft PR: https://github.com/vanessakn/NinjaRunner/pull/1
- Local preview used by Codex: http://localhost:8765/
- Status: playable Flutter POC for local iteration, not final production art.

## What Is In This Checkpoint

- Vertical single-lane runner concept with two answer gates.
- Jordan runner art with running, side-step, correct-hop, and wrong-recoil
  feedback poses.
- KidNation mobile-inspired shell, background, colors, and level-select states.
- Four-level progression with locking, unlocking, and best-score persistence.
- Correct/wrong gate glow, shake, hint, haptic, and system-sound feedback.
- Flutter web build output can be regenerated from source.

## Current Pacing

The level curve is tuned gently for ages 5-8:

- Level 1 `Warm-Up Dash`: `0.100`
- Level 2 `Quick Choice Dash`: `0.125`
- Level 3 `Star Streak Challenge`: `0.150`
- Level 4 `Friendship Focus Dash`: `0.175`

Level 1 should feel readable and low pressure. Levels 2-4 should feel only
slightly faster, not stressful.

## Run Locally

```bash
git clone https://github.com/vanessakn/NinjaRunner.git
cd NinjaRunner
git checkout codex/ninja-runner-flutter
flutter pub get
flutter run -d chrome
```

For a connected phone or emulator:

```bash
flutter devices
flutter run -d <device-id>
```

## Validate

```bash
flutter analyze
flutter test
flutter build web
```

## QA Focus

- Confirm no text, buttons, gates, badges, or Jordan poses overlap on small
  phones, large phones, and tablets.
- Confirm Level 1 gives enough reading time for ages 5-8.
- Confirm left/right taps and the visible answer buttons choose the expected
  gate.
- Confirm haptics and sounds feel helpful, not too strong.
- Confirm progress and best scores persist after restarting the app.

## Still Needed Before Final Game

- Real iOS and Android device QA.
- Final approved character/background production assets.
- Optional custom audio assets beyond system sounds.
- More level/content authoring after the core loop is approved.
