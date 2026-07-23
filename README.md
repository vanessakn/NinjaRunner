# KidNation Mobile Games

Flutter prototypes for KidNation learning games.

## Ninja Runner Prototype

`Ninja Runner` is a Flutter-only answer-gate runner for ages 5-8. It uses the KidNation Game Ideas Playbook mechanic and only the characters, visual theme ingredients, celebration style, and event-pattern inspiration from `miasstack/knsoccer`.

It does not reuse the KNSoccer soccer-match concept or mechanics.

Level unlock progress is saved locally, so unlocked runs stay available after
the app restarts. Best scores are saved per level and shown in the level select
and round summary.

## Run

```bash
flutter pub get
flutter run
```

## Impeller Builds

Flutter 3.44 uses Impeller by default on iOS and Android API 29+. The Android
manifest explicitly opts into Impeller with
`io.flutter.embedding.android.EnableImpeller=true`.

iOS uses Impeller as its only supported Flutter rendering engine, so no opt-in
flag is needed for iOS builds.

## Test

```bash
flutter test
flutter analyze
```
