# Level 1 Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Level 1 of Ninja Runner feel like a stronger first playable slice without adding new mechanics.

**Architecture:** Keep gameplay logic in `RunnerController`, level/content copy in `sample_content_pack.dart`, widget state in `NinjaRunnerScreen`, and visual scene polish in `RunnerPainter`. Add focused widget/controller tests before behavior changes.

**Tech Stack:** Flutter, Dart, `flutter_test`, custom `CustomPainter`, existing shared preferences progress store.

---

### Task 1: Level 1 State Copy And Round Outcome

**Files:**
- Modify: `test/widget_test.dart`
- Modify: `test/ninja_runner/runner_controller_test.dart`
- Modify: `lib/ninja_runner/game/runner_controller.dart`
- Modify: `lib/ninja_runner/ui/ninja_runner_screen.dart`

- [ ] **Step 1: Write failing tests for Level 1 first-playable UI copy**

Add expectations that the ready state includes "Level 1", "Help Jordan choose the kind gate.", "5 quick choices", and that the summary clearly shows "Perfect run!" after a perfect Level 1 round.

- [ ] **Step 2: Run tests and verify failure**

Run: `flutter test test/widget_test.dart`

Expected: FAIL because the new Level 1 copy and summary copy are not present yet.

- [ ] **Step 3: Implement minimal UI copy and summary wording**

Update `_Header` and `_Controls` in `lib/ninja_runner/ui/ninja_runner_screen.dart` to expose clear first-run objective copy and a friendlier result message while preserving the existing controls.

- [ ] **Step 4: Run tests and verify pass**

Run: `flutter test test/widget_test.dart`

Expected: PASS.

### Task 2: Gameplay Readability Polish

**Files:**
- Modify: `lib/ninja_runner/rendering/runner_painter.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write failing test for visible answer guidance**

Add a widget test expectation that running state shows a "Choose a gate" action hint near the answer controls.

- [ ] **Step 2: Run test and verify failure**

Run: `flutter test test/widget_test.dart`

Expected: FAIL because the hint is not present yet.

- [ ] **Step 3: Implement painter and control readability polish**

Make gate labels more distinct, add selected/correct glow in feedback, add runner motion and progress cue improvements, and add a small visible hint above answer buttons.

- [ ] **Step 4: Run tests and verify pass**

Run: `flutter test test/widget_test.dart`

Expected: PASS.

### Task 3: Full Verification

**Files:**
- Modify: `docs/superpowers/plans/2026-07-24-level-1-vertical-slice.md`

- [ ] **Step 1: Run formatter**

Run: `dart format lib test`

Expected: Files are formatted.

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze`

Expected: No issues found.

- [ ] **Step 3: Run full tests**

Run: `flutter test`

Expected: All tests pass.

- [ ] **Step 4: Review git diff**

Run: `git diff --stat && git diff --check`

Expected: Focused Level 1 polish changes and no whitespace errors.
