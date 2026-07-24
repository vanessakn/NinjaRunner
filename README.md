# KidNation Mobile Games

Flutter prototypes for KidNation learning games.

## Ninja Runner Prototype

`Ninja Runner` is a Flutter-only answer-gate runner for ages 5-8. It uses the KidNation Game Ideas Playbook mechanic and only the characters, visual theme ingredients, celebration style, and event-pattern inspiration from `miasstack/knsoccer`.

It does not reuse the KNSoccer soccer-match concept or mechanics.

## Bubble Blast Prototype

`Bubble Blast` is a Flutter-only bubble popping game for ages 5-8. Kids match a prompt by popping the correct word bubble while avoiding distractors. The current sample includes three levels with five tries each, auto-advancing feedback, generated sound effects, a mute toggle, and text-to-speech spoken prompts.

## Run

```bash
flutter pub get
flutter run
```

If Flutter is not on `PATH` on this machine, use:

```bash
/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter run
```

## Test

```bash
flutter test
flutter analyze
```

## Mobile Build Readiness

See `docs/mobile-build-readiness.md` for Android/iOS setup blockers, Impeller notes, and the repeatable build verification command.
