# Ninja Go Flutter Prototype Design

## Summary

Build **Ninja Go** as a separate Flutter-only KidNation mini-game. It is a pure reflex runner, not an educational word game and not a rework of the existing `Ninja Runner` module.

The first prototype uses a behind-the-runner, three-lane running view with KidNation branding, custom-drawn placeholder character art, and arcade-style obstacle dodging. The goal is a quick, playable mobile prototype that can later swap in official KidNation sprite and audio assets.

## Product Goals

- Create a separate `Ninja Go` game module alongside the existing mini-games.
- Deliver a pure reflex runner with no prompts, answer gates, quizzes, or word mechanics.
- Keep the first version small enough to build, test, and tune quickly in Flutter.
- Make the controls readable for young players through large gestures, clear lanes, and obvious obstacle silhouettes.
- Leave clear hooks for future official KidNation art, sound, and content themes.

## Non-Goals

- Do not modify `Ninja Runner` into this game.
- Do not add educational prompts, vocabulary mechanics, answer choices, or learning interruptions.
- Do not copy assets, branding, or implementation from the Play Store reference game.
- Do not add Flame or another game engine in the first prototype.
- Do not require production KidNation character art before gameplay exists.

## Gameplay

The player controls a KidNation runner moving forward through three lanes. The runner advances automatically while the player reacts to incoming obstacles and collectibles.

Core controls:

- Swipe left: move one lane left.
- Swipe right: move one lane right.
- Swipe up: jump over low ground obstacles.
- Swipe down: slide under overhead obstacles.

Core loop:

1. The player starts a run from a KidNation-branded start screen.
2. Obstacles and star collectibles spawn ahead in lanes.
3. The player changes lanes, jumps, or slides to avoid obstacles and collect stars.
4. Distance, score, and speed increase while the run continues.
5. Collision with an unavoided obstacle ends the run.
6. The summary screen shows score, distance, stars collected, best run, and replay.

The first prototype should feel forgiving. Lane changes should snap clearly, jump and slide windows should be generous, and obstacle spacing should avoid impossible patterns.

## Visual Direction

Use custom-drawn placeholder art in Flutter:

- Bright KidNation palette with blue sky, energetic green/yellow track accents, and high-contrast obstacle shapes.
- Runner represented as a friendly KidNation-style character block with a clear `KN` mark or KidNation label.
- Three lanes drawn in perspective from behind the runner.
- Stars as collectibles.
- Obstacles as visually distinct types:
  - ground barrier: must jump, change lane, or avoid
  - overhead sign/arch: must slide or change lane
  - lane blocker: must change lane

The custom art is intentionally replaceable. Painter code should keep drawing concerns separate enough that future image assets can replace shapes without changing game logic.

## Screens

1. **Start**
   - Title: `KidNation Ninja Go`
   - Shows runner, current best score if available in memory, and a start button.

2. **Active Run**
   - Full-screen runner scene.
   - HUD shows distance, score, stars, and current speed level.
   - Gesture area covers the main playfield.

3. **Pause/Game Over Overlay**
   - The first prototype may skip pause if it slows implementation.
   - Game over must show immediately after collision with a friendly retry path.

4. **Summary**
   - Shows distance, score, stars, best distance, and best score for the app session.
   - Includes replay and back-to-games actions.

## Architecture

Use Flutter with `CustomPainter`, matching the existing repo pattern.

Proposed files:

- `lib/ninja_go/models/ninja_go_models.dart`
  - Lane, obstacle type, collectible type, spawned entity, run metrics, and immutable game state.
- `lib/ninja_go/game/ninja_go_controller.dart`
  - Game loop, player movement, obstacle spawning, speed ramp, scoring, collision checks, and reset behavior.
- `lib/ninja_go/rendering/ninja_go_painter.dart`
  - Sky, track perspective, runner, obstacles, collectibles, motion cues, and collision/collection feedback.
- `lib/ninja_go/ui/ninja_go_screen.dart`
  - Start, active run, summary UI, gestures, ticker lifecycle, and navigation callbacks.

If needed, `lib/home_screen.dart` can add a separate entry point for `Ninja Go` without removing the existing `Ninja Runner` or `Bubble Blast` entries.

## State And Mechanics

The controller owns all gameplay state and should be testable without rendering.

State includes:

- phase: ready, running, gameOver
- current lane
- runner action: running, jumping, sliding
- action timer
- distance
- score
- stars collected
- speed
- best distance and best score for the current app session
- spawned obstacles and collectibles
- random seed support for deterministic tests

Scoring rules for the first prototype:

- Distance increases score over time.
- Star collectibles add a fixed score bonus.
- Speed ramps gradually based on distance or elapsed time.
- Collision ends the run and freezes the final metrics.

Collision rules:

- Lane blocker collides when runner and obstacle share a lane at the hit window.
- Ground barrier is avoided if the runner is jumping during the hit window or is in another lane.
- Overhead obstacle is avoided if the runner is sliding during the hit window or is in another lane.
- Stars are collected when runner and collectible share a lane at the collection window.

## Error Handling

- Missing optional visual or audio assets must not crash the game.
- Spawn generation must avoid impossible immediate collisions at run start.
- Ticker updates should ignore negative or zero delta values.
- Gesture input outside the running phase should be ignored.
- Invalid lane movement should clamp at the leftmost and rightmost lanes.

## Testing

Add focused tests for:

- start/reset transitions
- lane movement clamping
- jump and slide action timing
- collision detection for each obstacle type
- star collection and score bonus
- distance and speed ramp
- game-over freeze behavior
- deterministic spawning with a seed

Add or update a widget smoke test only as needed to confirm the game can be reached from the app shell.

## Implementation Notes

The first build should favor predictable feel over complex physics. Use simple normalized entity positions moving toward the runner, then tune speed, spawn spacing, and action durations through constants in the controller.

The module should remain separate from `ninja_runner` so each game can evolve independently:

- `Ninja Runner`: word/answer-gate learning runner.
- `Ninja Go`: pure reflex running game.
