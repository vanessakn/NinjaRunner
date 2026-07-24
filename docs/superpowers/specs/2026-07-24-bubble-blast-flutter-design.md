# Bubble Blast Flutter Prototype Design

## Summary

Build **Bubble Blast** as the next KidNation Flutter mini-game beside Ninja Runner. Bubble Blast is a short, replayable recognition game for early readers and pre-readers: a prompt appears, bubbles float with answer labels, and the child taps the matching bubble while avoiding distractors.

## Source Inputs

- `KidNation_Game_Ideas_Playbook.pdf`
  - Bubble Blast: "Pop the bubble matching a word, image or spoken prompt."
  - Learning value: recognition and listening.
  - System direction: short, content-aware, age-adaptive, template-driven, character-rich rounds.
- Existing Flutter app
  - Keep the implementation Flutter-only with `CustomPainter`, `Ticker`, and local testable game logic.
  - Keep Bubble Blast self-contained so Ninja Runner remains stable.

## Product Goals

- Add a second playable KidNation game mechanic without changing Ninja Runner internals.
- Prove a pre-reader friendly interaction pattern using large moving targets and audio-ready prompt fields.
- Keep the content structured so future generated packs can feed Bubble Blast.
- Maintain Impeller-friendly rendering with Flutter canvas drawing and lightweight animation.

## Gameplay

The player starts a 15-prompt round split into three levels with five tries per level. Each prompt asks for a word, object, emotion, color, or action. Bubbles float upward with one correct answer and distractors. The child taps the correct bubble to pop it, earn a star, and see a brief celebration. Tapping a distractor shows a gentle wobble and friendly correction, then continues to the next prompt.

Feedback auto-advances after a short pause so the round keeps moving. Correct answers use a shorter celebration pause than incorrect answers. The controller emits audio cue hooks for round start, correct pop, wrong bubble, level complete, and round complete. The Flutter screen maps those cues to generated WAV sound effects and includes a mute toggle.

Each prompt can also be read aloud through the prompt's `spokenPrompt` field. The screen includes a speaker button that uses text-to-speech, respects the mute toggle, and falls back to the visible prompt text if no spoken prompt is provided.

## Content Pack

Bubble Blast uses its own first-pass model:

- pack id and title
- age range
- theme colors
- character name
- prompts
- answers
- correct answer id
- feedback
- optional `spokenPrompt` for future audio-first play

The first sample pack uses KidNation-style social-emotional and vocabulary prompts, without depending on Ninja Runner code.

## Architecture

Core modules:

- `BubbleContentPack`: structured Bubble Blast content data and validation.
- `BubblePrompt`: prompt, spoken prompt, answer options, correct answer id, and feedback.
- `BubbleBlastController`: state machine, scoring, prompt advancement, bubble layout, and selection handling.
- `BubbleBlastPainter`: draws the sky, bubbles, prompt HUD, pop/wobble feedback, and score.
- `BubbleBlastScreen`: Flutter screen with start, active play, feedback, and summary states.

The app shell adds a simple home screen with buttons for Ninja Runner and Bubble Blast.

## Testing

Add focused tests for:

- content pack parsing and validation
- sample pack structure
- correct bubble selection
- incorrect bubble selection
- prompt advancement and round completion
- app shell navigation smoke test

## Out Of Scope

- Real audio playback.
- Asset images inside bubbles.
- Backend-generated packs.
- Persistent profiles.
- Production art or sound effects.
- Replacing Ninja Runner's content model.
