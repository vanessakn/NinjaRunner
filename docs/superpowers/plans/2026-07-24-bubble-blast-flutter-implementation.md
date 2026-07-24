# Bubble Blast Flutter Prototype Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a playable Bubble Blast prototype beside Ninja Runner in the Flutter app.

**Architecture:** Keep Bubble Blast self-contained under `lib/bubble_blast` with model, data, controller, painter, and UI files. Add a small app home screen that launches Ninja Runner or Bubble Blast without changing Ninja Runner game logic.

**Tech Stack:** Flutter SDK, Dart, `flutter_test`, Material 3, `CustomPainter`, `Ticker`.

---

## File Structure

- Create `lib/bubble_blast/models/bubble_content_pack.dart`: Bubble Blast content model and validation.
- Create `lib/bubble_blast/data/sample_bubble_pack.dart`: sample KidNation Bubble Blast content.
- Create `lib/bubble_blast/game/bubble_blast_controller.dart`: state machine, scoring, bubble positions, and selection logic.
- Create `lib/bubble_blast/rendering/bubble_blast_painter.dart`: canvas rendering for bubbles, prompt, score, and feedback.
- Create `lib/bubble_blast/ui/bubble_blast_screen.dart`: playable Flutter screen.
- Create `lib/home_screen.dart`: game picker for Ninja Runner and Bubble Blast.
- Modify `lib/main.dart`: use the home screen as the app entry.
- Create `test/bubble_blast/bubble_content_pack_test.dart`: model and sample pack tests.
- Create `test/bubble_blast/bubble_blast_controller_test.dart`: controller behavior tests.
- Modify `test/widget_test.dart`: app shell and Bubble Blast navigation smoke tests.
- Modify `README.md`: mention Bubble Blast.

## Tasks

### Task 1: Bubble Blast Content Model

- [ ] Write failing tests for parsing valid packs, rejecting missing correct answers, and sample pack shape.
- [ ] Run `flutter test test/bubble_blast/bubble_content_pack_test.dart` and confirm failure because production files do not exist.
- [ ] Implement `bubble_content_pack.dart` and `sample_bubble_pack.dart`.
- [ ] Re-run the content pack tests and confirm they pass.

### Task 2: Bubble Blast Controller

- [ ] Write failing tests for start, correct selection, incorrect selection, and round completion.
- [ ] Run `flutter test test/bubble_blast/bubble_blast_controller_test.dart` and confirm failure because the controller does not exist.
- [ ] Implement `bubble_blast_controller.dart`.
- [ ] Re-run controller tests and confirm they pass.

### Task 3: Bubble Blast Screen And App Navigation

- [ ] Write failing widget tests for the home screen and Bubble Blast launch path.
- [ ] Run `flutter test test/widget_test.dart` and confirm failure because the home screen and Bubble Blast UI do not exist.
- [ ] Implement `home_screen.dart`, `bubble_blast_painter.dart`, `bubble_blast_screen.dart`, and update `main.dart`.
- [ ] Re-run widget tests and confirm they pass.

### Task 4: Docs And Verification

- [ ] Update `README.md` with Bubble Blast run/test notes.
- [ ] Run `flutter test`.
- [ ] Run `flutter analyze`.
- [ ] Report mobile build blockers separately from test/analyze results.

## Self-Review

- Spec coverage: the plan covers model validation, reusable sample content, game state, rendering, UI, navigation, tests, and docs.
- Placeholder scan: no TBD/TODO implementation placeholders remain in the plan.
- Type consistency: all planned Bubble Blast file names and class names use the `Bubble`/`BubbleBlast` prefixes consistently.
