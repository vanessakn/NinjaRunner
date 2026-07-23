# Ninja Runner Mobile QA Handoff

Use this checklist to test the current vertical runner POC on real iOS and
Android devices.

## Build Under Test

- Branch: `codex/ninja-runner-flutter`
- Draft PR: https://github.com/vanessakn/NinjaRunner/pull/1
- Review site: https://ninja-runner-review.vanessa296799.chatgpt.site
- Current status: POC, not final art or production gameplay.

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
```

## Devices To Cover

- iPhone small screen, if available.
- iPhone large screen, if available.
- Android small or mid-size phone.
- Android large phone.

Record exact device model, OS version, and whether the build was debug or
release/profile.

## Core QA Script

1. Launch the app in portrait.
2. Confirm the start screen shows Level 1, Runner Mode, Jordan, four level cards,
   and the Start Run button.
3. Start Level 1.
4. Tap the left gate for `share`; confirm `Streak Boost!`, `+1 star`, and haptic
   or sound feedback.
5. Continue through all five correct Level 1 answers.
6. Confirm the summary shows `Perfect run!`, `Level Complete!`, score `5/5`,
   and `Next Level`.
7. Tap Next Level and confirm Level 2 starts with Nari.
8. Restart the app and confirm unlocked progress and best score persist.
9. Try one wrong answer and confirm `Slow down and try again` plus
   `Correct gate: ...` appears.
10. Test left/right screen taps and left/right answer buttons.

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
