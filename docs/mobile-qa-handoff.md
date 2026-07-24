# Ninja Runner Mobile QA Handoff

Use this checklist to test the current vertical runner POC on real iOS,
Android, and small web/mobile preview sizes.

## Build Under Test

- Branch: `codex/ninja-runner-flutter`
- Draft PR: https://github.com/vanessakn/NinjaRunner/pull/1
- Review site: https://ninja-runner-review.vanessa296799.chatgpt.site
- Local preview during Codex work: http://localhost:8765/
- Current status: playable POC with Jordan art, KidNation mobile styling,
  level progress, best scores, haptics/sounds, and feedback polish. Not final
  production art/content.

## Setup

```bash
git clone https://github.com/vanessakn/NinjaRunner.git
cd NinjaRunner
git checkout codex/ninja-runner-flutter
flutter pub get
flutter devices
flutter run -d <device-id>
```

Also run the baseline checks:

```bash
flutter analyze
flutter test
flutter build web
```

## Devices To Cover

- iPhone small screen, if available.
- iPhone large screen, if available.
- Android small or mid-size phone.
- Android large phone.
- 320px-wide web/mobile preview for smallest-screen layout.

Record exact device model, OS version, and whether the build was debug or
release/profile.

## Pacing Baseline

The current four-level speed curve is intentionally gentle for ages 5-8:

- Level 1 `Warm-Up Dash`: `0.100`
- Level 2 `Quick Choice Dash`: `0.125`
- Level 3 `Star Streak Challenge`: `0.150`
- Level 4 `Friendship Focus Dash`: `0.175`

Treat notes like "too fast to read" as Must Fix for Level 1 and Tune for
Levels 2-4.

## Core QA Script

1. Launch the app in portrait.
2. Confirm the start screen shows Level 1, Runner Mode, Jordan, four level cards,
   and the Start Run button.
3. Start Level 1.
4. Tap the left gate for `share`; confirm `Nice choice!`,
   `Kind gate! +1 star`, Jordan's celebration hop, correct-gate glow/badge,
   and haptic or sound feedback.
5. Continue through all five correct Level 1 answers.
6. Confirm the summary shows `Perfect run!`, `Level Complete!`, score `5/5`,
   and `Next Level`.
7. Tap Next Level and confirm Level 2 starts with Nari.
8. Restart the app and confirm unlocked progress and best score persist.
9. Try one wrong answer and confirm `Almost there`,
   `Try the ... gate next`, selected-gate shake, correct-gate hint, and Jordan's
   small recoil.
10. Test left/right screen taps and left/right answer buttons.
11. On the smallest screen, confirm the header, playfield, feedback badge,
    level cards, and bottom controls do not overlap or clip.

## What To Judge

Use these buckets in notes:

- Must fix: blocks play, wrong answer chosen, overflow, crash, broken save,
  severe haptic/sound issue.
- Tune: pacing too fast or slow, feedback timing, visual crowding, tap zones,
  button size, sound/haptic intensity.
- Nice later: art, animation, celebration, content improvements.

## Specific Questions

- Can a 5-8 year old read the prompt before choosing?
- Are the gates easy to tap with one thumb?
- Does the vertical runner feel centered and stable?
- Are haptics/sounds helpful, distracting, or too strong?
- Does the app stay portrait and avoid safe-area issues?
- Is performance smooth with Impeller on Android/iOS?

## Report Format

```text
Device:
OS:
Build mode:
Level tested:

Must fix:
- ...

Tune:
- ...

Nice later:
- ...

Overall recommendation:
```
