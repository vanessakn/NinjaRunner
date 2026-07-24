# Ninja Runner Flutter Prototype Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter-only `Ninja Runner` prototype for ages 5-8 using the KidNation Game Ideas Playbook's `Ninja Runner` mechanic and only the characters/theme/style/event inspiration from `miasstack/knsoccer`.

**Architecture:** Scaffold a small Flutter app, then split the game into focused model, sample data, controller, analytics, rendering, and screen files. Use `CustomPainter` plus a `Ticker`-driven loop for the playable runner while keeping the learning/content logic testable without Flutter rendering.

**Tech Stack:** Flutter SDK, Dart, `flutter_test`, Material 3, `CustomPainter`, `Ticker`.

---

## Current Repo And Tooling Notes

The repo currently contains only planning docs and `.gitignore`. On this machine, `which flutter` currently returns `flutter not found`. Before executing Flutter tasks, install Flutter or add it to `PATH`; then confirm with `flutter --version`.

## File Structure

- Create `pubspec.yaml`: Flutter package metadata and asset declarations.
- Create `analysis_options.yaml`: lints using Flutter's recommended rules.
- Create `lib/main.dart`: app entrypoint and Material shell.
- Create `lib/ninja_runner/models/content_pack.dart`: immutable content-pack models and JSON parsing.
- Create `lib/ninja_runner/data/sample_content_pack.dart`: KNSoccer cast/theme-inspired sample pack with no soccer-match mechanics.
- Create `lib/ninja_runner/analytics/analytics_logger.dart`: local analytics event model and safe logger.
- Create `lib/ninja_runner/game/runner_controller.dart`: game state machine, scoring, prompt advancement, and event emission.
- Create `lib/ninja_runner/rendering/runner_painter.dart`: field, runner, gates, HUD, and feedback drawing.
- Create `lib/ninja_runner/ui/ninja_runner_screen.dart`: start, active run, feedback, and summary UI.
- Create `test/ninja_runner/content_pack_test.dart`: content model tests.
- Create `test/ninja_runner/runner_controller_test.dart`: game logic tests.
- Create `test/ninja_runner/analytics_logger_test.dart`: event payload tests.
- Create `test/widget_test.dart`: app shell smoke test.

---

### Task 1: Tooling And Flutter Scaffold

**Files:**
- Create: `pubspec.yaml`
- Create: `analysis_options.yaml`
- Create: `lib/main.dart`
- Create: `test/widget_test.dart`

- [ ] **Step 1: Verify Flutter is available**

Run:

```bash
flutter --version
```

Expected: command exits `0` and prints a Flutter version. If it exits with `command not found`, install Flutter or add the Flutter SDK `bin` directory to `PATH` before continuing.

- [ ] **Step 2: Write the initial Flutter package files**

Create `pubspec.yaml`:

```yaml
name: kidnation_mobile_games
description: KidNation Flutter mini-game prototypes.
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
```

Create `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
```

Create `lib/main.dart`:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const KidNationMobileGamesApp());
}

class KidNationMobileGamesApp extends StatelessWidget {
  const KidNationMobileGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ninja Runner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A7E1)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Ninja Runner'),
        ),
      ),
    );
  }
}
```

Create `test/widget_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/main.dart';

void main() {
  testWidgets('shows the app title', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    expect(find.text('Ninja Runner'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Install dependencies**

Run:

```bash
flutter pub get
```

Expected: exits `0` and creates `pubspec.lock`.

- [ ] **Step 4: Run the scaffold test**

Run:

```bash
flutter test test/widget_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit scaffold**

```bash
git add pubspec.yaml pubspec.lock analysis_options.yaml lib/main.dart test/widget_test.dart
git commit -m "feat: scaffold Flutter Ninja Runner app"
```

---

### Task 2: Content Pack Models

**Files:**
- Create: `lib/ninja_runner/models/content_pack.dart`
- Create: `test/ninja_runner/content_pack_test.dart`

- [ ] **Step 1: Write failing model tests**

Create `test/ninja_runner/content_pack_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/models/content_pack.dart';

void main() {
  group('ContentPack', () {
    test('parses a valid pack from json', () {
      final pack = ContentPack.fromJson({
        'id': 'kidnation-cup-kindness',
        'title': 'KidNation Cup Kindness Run',
        'minAge': 5,
        'maxAge': 8,
        'theme': {
          'id': 'brazil-arena',
          'name': 'Brazil Arena',
          'primaryColor': 0xFF1BAA5D,
          'secondaryColor': 0xFFFFD23F,
        },
        'runner': {'id': 'jordan', 'name': 'Jordan'},
        'prompts': [
          {
            'id': 'helpful-action',
            'prompt': 'Choose the helpful action.',
            'correctAnswerId': 'share',
            'feedback': 'Nice choice! Sharing helps your friends.',
            'answers': [
              {'id': 'share', 'label': 'share'},
              {'id': 'grab', 'label': 'grab'},
            ],
          },
        ],
      });

      expect(pack.id, 'kidnation-cup-kindness');
      expect(pack.ageRangeLabel, 'Ages 5-8');
      expect(pack.theme.name, 'Brazil Arena');
      expect(pack.runner.name, 'Jordan');
      expect(pack.prompts.single.correctAnswer.label, 'share');
    });

    test('rejects a prompt without the correct answer in its options', () {
      expect(
        () => ContentPack.fromJson({
          'id': 'bad-pack',
          'title': 'Bad Pack',
          'minAge': 5,
          'maxAge': 8,
          'theme': {
            'id': 'france-arena',
            'name': 'France Arena',
            'primaryColor': 0xFF2867D4,
            'secondaryColor': 0xFFFFFFFF,
          },
          'runner': {'id': 'nari', 'name': 'Nari'},
          'prompts': [
            {
              'id': 'bad-prompt',
              'prompt': 'Choose one.',
              'correctAnswerId': 'missing',
              'feedback': 'Try again.',
              'answers': [
                {'id': 'kind', 'label': 'kind'},
                {'id': 'loud', 'label': 'loud'},
              ],
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
```

- [ ] **Step 2: Run tests to verify failure**

Run:

```bash
flutter test test/ninja_runner/content_pack_test.dart
```

Expected: fails because `content_pack.dart` does not exist.

- [ ] **Step 3: Implement content models**

Create `lib/ninja_runner/models/content_pack.dart`:

```dart
import 'package:flutter/material.dart';

class ContentPack {
  const ContentPack({
    required this.id,
    required this.title,
    required this.minAge,
    required this.maxAge,
    required this.theme,
    required this.runner,
    required this.prompts,
  });

  factory ContentPack.fromJson(Map<String, Object?> json) {
    final promptsJson = _list(json, 'prompts');
    final prompts = promptsJson.map(RunnerPrompt.fromJson).toList();
    if (prompts.isEmpty) {
      throw const FormatException('Content pack must include at least one prompt.');
    }

    return ContentPack(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      minAge: _int(json, 'minAge'),
      maxAge: _int(json, 'maxAge'),
      theme: RunnerTheme.fromJson(_map(json, 'theme')),
      runner: RunnerCharacter.fromJson(_map(json, 'runner')),
      prompts: List.unmodifiable(prompts),
    );
  }

  final String id;
  final String title;
  final int minAge;
  final int maxAge;
  final RunnerTheme theme;
  final RunnerCharacter runner;
  final List<RunnerPrompt> prompts;

  String get ageRangeLabel => 'Ages $minAge-$maxAge';
}

class RunnerTheme {
  const RunnerTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
  });

  factory RunnerTheme.fromJson(Map<String, Object?> json) {
    return RunnerTheme(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
      primaryColor: Color(_int(json, 'primaryColor')),
      secondaryColor: Color(_int(json, 'secondaryColor')),
    );
  }

  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
}

class RunnerCharacter {
  const RunnerCharacter({
    required this.id,
    required this.name,
  });

  factory RunnerCharacter.fromJson(Map<String, Object?> json) {
    return RunnerCharacter(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
    );
  }

  final String id;
  final String name;
}

class RunnerPrompt {
  const RunnerPrompt({
    required this.id,
    required this.prompt,
    required this.correctAnswerId,
    required this.feedback,
    required this.answers,
  });

  factory RunnerPrompt.fromJson(Map<String, Object?> json) {
    final answers = _list(json, 'answers').map(RunnerAnswer.fromJson).toList();
    final correctAnswerId = _string(json, 'correctAnswerId');
    if (!answers.any((answer) => answer.id == correctAnswerId)) {
      throw FormatException('Correct answer "$correctAnswerId" is missing.');
    }

    return RunnerPrompt(
      id: _string(json, 'id'),
      prompt: _string(json, 'prompt'),
      correctAnswerId: correctAnswerId,
      feedback: _string(json, 'feedback'),
      answers: List.unmodifiable(answers),
    );
  }

  final String id;
  final String prompt;
  final String correctAnswerId;
  final String feedback;
  final List<RunnerAnswer> answers;

  RunnerAnswer get correctAnswer {
    return answers.firstWhere((answer) => answer.id == correctAnswerId);
  }
}

class RunnerAnswer {
  const RunnerAnswer({
    required this.id,
    required this.label,
  });

  factory RunnerAnswer.fromJson(Map<String, Object?> json) {
    return RunnerAnswer(
      id: _string(json, 'id'),
      label: _string(json, 'label'),
    );
  }

  final String id;
  final String label;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw FormatException('Expected non-empty string for "$key".');
}

int _int(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  throw FormatException('Expected int for "$key".');
}

Map<String, Object?> _map(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException('Expected map for "$key".');
}

List<Map<String, Object?>> _list(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is List) {
    return value.cast<Map<String, Object?>>();
  }
  throw FormatException('Expected list for "$key".');
}
```

- [ ] **Step 4: Run model tests**

Run:

```bash
flutter test test/ninja_runner/content_pack_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit content models**

```bash
git add lib/ninja_runner/models/content_pack.dart test/ninja_runner/content_pack_test.dart
git commit -m "feat: add Ninja Runner content models"
```

---

### Task 3: Sample Content Pack

**Files:**
- Create: `lib/ninja_runner/data/sample_content_pack.dart`
- Modify: `test/ninja_runner/content_pack_test.dart`

- [ ] **Step 1: Add a sample pack test**

Append this test inside the `group('ContentPack', () { ... })` block in `test/ninja_runner/content_pack_test.dart`:

```dart
test('sample pack uses KNSoccer cast and avoids soccer mechanics', () {
  final pack = sampleContentPack();

  expect(pack.minAge, 5);
  expect(pack.maxAge, 8);
  expect(['Jordan', 'Nari', 'Bjorn', 'Arjun'], contains(pack.runner.name));
  expect(pack.prompts, hasLength(5));

  final forbiddenWords = RegExp(
    r'\b(dribble|pass|shoot|tackle|header|goal|match|3v3)\b',
    caseSensitive: false,
  );
  final text = [
    pack.title,
    pack.theme.name,
    for (final prompt in pack.prompts) ...[
      prompt.prompt,
      prompt.feedback,
      for (final answer in prompt.answers) answer.label,
    ],
  ].join(' ');

  expect(forbiddenWords.hasMatch(text), isFalse);
});
```

Add this import at the top:

```dart
import 'package:kidnation_mobile_games/ninja_runner/data/sample_content_pack.dart';
```

- [ ] **Step 2: Run test to verify failure**

Run:

```bash
flutter test test/ninja_runner/content_pack_test.dart
```

Expected: fails because `sample_content_pack.dart` does not exist.

- [ ] **Step 3: Implement sample content**

Create `lib/ninja_runner/data/sample_content_pack.dart`:

```dart
import '../models/content_pack.dart';

ContentPack sampleContentPack() {
  return ContentPack.fromJson({
    'id': 'kidnation-cup-kindness-run',
    'title': 'KidNation Cup Kindness Run',
    'minAge': 5,
    'maxAge': 8,
    'theme': {
      'id': 'brazil-arena',
      'name': 'Brazil Arena',
      'primaryColor': 0xFF1BAA5D,
      'secondaryColor': 0xFFFFD23F,
    },
    'runner': {'id': 'jordan', 'name': 'Jordan'},
    'prompts': [
      {
        'id': 'helpful-action',
        'prompt': 'Choose the helpful action.',
        'correctAnswerId': 'share',
        'feedback': 'Nice choice! Sharing helps your friends.',
        'answers': [
          {'id': 'share', 'label': 'share'},
          {'id': 'grab', 'label': 'grab'},
        ],
      },
      {
        'id': 'kind-word',
        'prompt': 'Find the kind word.',
        'correctAnswerId': 'gentle',
        'feedback': 'Gentle words can make someone feel safe.',
        'answers': [
          {'id': 'gentle', 'label': 'gentle'},
          {'id': 'bossy', 'label': 'bossy'},
        ],
      },
      {
        'id': 'brave-choice',
        'prompt': 'Which choice shows bravery?',
        'correctAnswerId': 'try',
        'feedback': 'Trying again is a brave choice.',
        'answers': [
          {'id': 'try', 'label': 'try again'},
          {'id': 'hide', 'label': 'hide forever'},
        ],
      },
      {
        'id': 'friendship-listening',
        'prompt': 'What should Jordan do first?',
        'correctAnswerId': 'listen',
        'feedback': 'Listening first helps friends understand each other.',
        'answers': [
          {'id': 'listen', 'label': 'listen'},
          {'id': 'interrupt', 'label': 'interrupt'},
        ],
      },
      {
        'id': 'team-celebration',
        'prompt': 'Pick the friendly celebration.',
        'correctAnswerId': 'cheer',
        'feedback': 'Cheering for others makes the group stronger.',
        'answers': [
          {'id': 'cheer', 'label': 'cheer'},
          {'id': 'tease', 'label': 'tease'},
        ],
      },
    ],
  });
}
```

- [ ] **Step 4: Run content tests**

Run:

```bash
flutter test test/ninja_runner/content_pack_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit sample pack**

```bash
git add lib/ninja_runner/data/sample_content_pack.dart test/ninja_runner/content_pack_test.dart
git commit -m "feat: add KNSoccer cast-inspired runner content pack"
```

---

### Task 4: Analytics Logger

**Files:**
- Create: `lib/ninja_runner/analytics/analytics_logger.dart`
- Create: `test/ninja_runner/analytics_logger_test.dart`

- [ ] **Step 1: Write analytics tests**

Create `test/ninja_runner/analytics_logger_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/analytics/analytics_logger.dart';

void main() {
  test('records local events with safe payloads', () {
    final logger = AnalyticsLogger();

    logger.track(
      AnalyticsEvent.gateSelected,
      payload: const {
        'pack_id': 'kidnation-cup-kindness-run',
        'prompt_id': 'helpful-action',
        'selected_answer_id': 'share',
      },
    );

    expect(logger.events, hasLength(1));
    expect(logger.events.single.name, 'gate_selected');
    expect(logger.events.single.payload['selected_answer_id'], 'share');
  });

  test('ignores unsupported payload value types', () {
    final logger = AnalyticsLogger();

    logger.track(
      AnalyticsEvent.gameError,
      payload: {
        'error_stage': 'content',
        'bad_value': Object(),
      },
    );

    expect(logger.events.single.payload, {'error_stage': 'content'});
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run:

```bash
flutter test test/ninja_runner/analytics_logger_test.dart
```

Expected: fails because `analytics_logger.dart` does not exist.

- [ ] **Step 3: Implement analytics logger**

Create `lib/ninja_runner/analytics/analytics_logger.dart`:

```dart
enum AnalyticsEvent {
  gameReady('game_ready'),
  roundStart('round_start'),
  promptShown('prompt_shown'),
  gateSelected('gate_selected'),
  answerResult('answer_result'),
  roundComplete('round_complete'),
  gameError('game_error');

  const AnalyticsEvent(this.name);

  final String name;
}

class LoggedAnalyticsEvent {
  const LoggedAnalyticsEvent({
    required this.name,
    required this.payload,
  });

  final String name;
  final Map<String, Object> payload;
}

class AnalyticsLogger {
  final List<LoggedAnalyticsEvent> _events = [];

  List<LoggedAnalyticsEvent> get events => List.unmodifiable(_events);

  void track(
    AnalyticsEvent event, {
    Map<String, Object?> payload = const {},
  }) {
    try {
      _events.add(
        LoggedAnalyticsEvent(
          name: event.name,
          payload: _safePayload(payload),
        ),
      );
    } catch (_) {
      // Analytics must never interrupt play.
    }
  }

  Map<String, Object> _safePayload(Map<String, Object?> payload) {
    final safe = <String, Object>{};
    for (final entry in payload.entries) {
      final value = entry.value;
      if (value is String || value is num || value is bool) {
        safe[entry.key] = value;
      }
    }
    return safe;
  }
}
```

- [ ] **Step 4: Run analytics tests**

Run:

```bash
flutter test test/ninja_runner/analytics_logger_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit analytics logger**

```bash
git add lib/ninja_runner/analytics/analytics_logger.dart test/ninja_runner/analytics_logger_test.dart
git commit -m "feat: add local Ninja Runner analytics logger"
```

---

### Task 5: Runner Controller

**Files:**
- Create: `lib/ninja_runner/game/runner_controller.dart`
- Create: `test/ninja_runner/runner_controller_test.dart`

- [ ] **Step 1: Write controller tests**

Create `test/ninja_runner/runner_controller_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/analytics/analytics_logger.dart';
import 'package:kidnation_mobile_games/ninja_runner/data/sample_content_pack.dart';
import 'package:kidnation_mobile_games/ninja_runner/game/runner_controller.dart';

void main() {
  test('starts a round and shows the first prompt', () {
    final logger = AnalyticsLogger();
    final controller = RunnerController(
      contentPack: sampleContentPack(),
      analyticsLogger: logger,
    );

    controller.startRound();

    expect(controller.state.phase, RunnerPhase.running);
    expect(controller.state.currentPrompt.id, 'helpful-action');
    expect(logger.events.map((event) => event.name), contains('round_start'));
    expect(logger.events.map((event) => event.name), contains('prompt_shown'));
  });

  test('correct answer increases score and streak', () {
    final controller = RunnerController(
      contentPack: sampleContentPack(),
      analyticsLogger: AnalyticsLogger(),
    )..startRound();

    final result = controller.selectAnswer('share');

    expect(result.isCorrect, isTrue);
    expect(controller.state.score, 1);
    expect(controller.state.streak, 1);
    expect(controller.state.phase, RunnerPhase.feedback);
  });

  test('incorrect answer resets streak and keeps score', () {
    final controller = RunnerController(
      contentPack: sampleContentPack(),
      analyticsLogger: AnalyticsLogger(),
    )..startRound();

    final result = controller.selectAnswer('grab');

    expect(result.isCorrect, isFalse);
    expect(controller.state.score, 0);
    expect(controller.state.streak, 0);
    expect(result.feedback, 'Nice choice! Sharing helps your friends.');
  });

  test('advances through five prompts and completes the round', () {
    final controller = RunnerController(
      contentPack: sampleContentPack(),
      analyticsLogger: AnalyticsLogger(),
    )..startRound();

    for (final answerId in ['share', 'gentle', 'try', 'listen', 'cheer']) {
      controller.selectAnswer(answerId);
      controller.continueAfterFeedback();
    }

    expect(controller.state.phase, RunnerPhase.summary);
    expect(controller.state.score, 5);
    expect(controller.state.currentPromptIndex, 4);
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run:

```bash
flutter test test/ninja_runner/runner_controller_test.dart
```

Expected: fails because `runner_controller.dart` does not exist.

- [ ] **Step 3: Implement runner controller**

Create `lib/ninja_runner/game/runner_controller.dart`:

```dart
import '../analytics/analytics_logger.dart';
import '../models/content_pack.dart';

enum RunnerPhase {
  ready,
  running,
  feedback,
  summary,
  error,
}

class RunnerSelectionResult {
  const RunnerSelectionResult({
    required this.selectedAnswerId,
    required this.correctAnswerId,
    required this.isCorrect,
    required this.feedback,
  });

  final String selectedAnswerId;
  final String correctAnswerId;
  final bool isCorrect;
  final String feedback;
}

class RunnerGameState {
  const RunnerGameState({
    required this.phase,
    required this.currentPromptIndex,
    required this.score,
    required this.streak,
    required this.runnerProgress,
    this.lastResult,
  });

  factory RunnerGameState.initial() {
    return const RunnerGameState(
      phase: RunnerPhase.ready,
      currentPromptIndex: 0,
      score: 0,
      streak: 0,
      runnerProgress: 0,
    );
  }

  final RunnerPhase phase;
  final int currentPromptIndex;
  final int score;
  final int streak;
  final double runnerProgress;
  final RunnerSelectionResult? lastResult;

  RunnerPrompt get currentPrompt {
    throw StateError('Use RunnerController.currentPrompt for prompt access.');
  }

  RunnerGameState copyWith({
    RunnerPhase? phase,
    int? currentPromptIndex,
    int? score,
    int? streak,
    double? runnerProgress,
    RunnerSelectionResult? lastResult,
    bool clearLastResult = false,
  }) {
    return RunnerGameState(
      phase: phase ?? this.phase,
      currentPromptIndex: currentPromptIndex ?? this.currentPromptIndex,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      runnerProgress: runnerProgress ?? this.runnerProgress,
      lastResult: clearLastResult ? null : lastResult ?? this.lastResult,
    );
  }
}

class RunnerController {
  RunnerController({
    required this.contentPack,
    required this.analyticsLogger,
  }) : state = RunnerGameState.initial() {
    analyticsLogger.track(
      AnalyticsEvent.gameReady,
      payload: {'pack_id': contentPack.id},
    );
  }

  final ContentPack contentPack;
  final AnalyticsLogger analyticsLogger;
  RunnerGameState state;

  RunnerPrompt get currentPrompt {
    return contentPack.prompts[state.currentPromptIndex];
  }

  void startRound() {
    state = RunnerGameState.initial().copyWith(phase: RunnerPhase.running);
    analyticsLogger.track(
      AnalyticsEvent.roundStart,
      payload: {'pack_id': contentPack.id},
    );
    _trackPromptShown();
  }

  void tick(double deltaSeconds) {
    if (state.phase != RunnerPhase.running) {
      return;
    }
    final nextProgress = (state.runnerProgress + deltaSeconds * 0.22).clamp(0, 1).toDouble();
    state = state.copyWith(runnerProgress: nextProgress);
  }

  RunnerSelectionResult selectAnswer(String answerId) {
    final prompt = currentPrompt;
    final isCorrect = answerId == prompt.correctAnswerId;
    final result = RunnerSelectionResult(
      selectedAnswerId: answerId,
      correctAnswerId: prompt.correctAnswerId,
      isCorrect: isCorrect,
      feedback: prompt.feedback,
    );

    analyticsLogger.track(
      AnalyticsEvent.gateSelected,
      payload: {
        'pack_id': contentPack.id,
        'prompt_id': prompt.id,
        'selected_answer_id': answerId,
      },
    );
    analyticsLogger.track(
      AnalyticsEvent.answerResult,
      payload: {
        'pack_id': contentPack.id,
        'prompt_id': prompt.id,
        'selected_answer_id': answerId,
        'correct_answer_id': prompt.correctAnswerId,
        'is_correct': isCorrect,
      },
    );

    state = state.copyWith(
      phase: RunnerPhase.feedback,
      score: isCorrect ? state.score + 1 : state.score,
      streak: isCorrect ? state.streak + 1 : 0,
      lastResult: result,
    );
    return result;
  }

  void continueAfterFeedback() {
    if (state.phase != RunnerPhase.feedback) {
      return;
    }
    final nextIndex = state.currentPromptIndex + 1;
    if (nextIndex >= contentPack.prompts.length) {
      state = state.copyWith(phase: RunnerPhase.summary);
      analyticsLogger.track(
        AnalyticsEvent.roundComplete,
        payload: {
          'pack_id': contentPack.id,
          'score': state.score,
          'prompt_count': contentPack.prompts.length,
          'streak': state.streak,
        },
      );
      return;
    }

    state = state.copyWith(
      phase: RunnerPhase.running,
      currentPromptIndex: nextIndex,
      runnerProgress: 0,
      clearLastResult: true,
    );
    _trackPromptShown();
  }

  void _trackPromptShown() {
    analyticsLogger.track(
      AnalyticsEvent.promptShown,
      payload: {
        'pack_id': contentPack.id,
        'prompt_id': currentPrompt.id,
        'prompt_index': state.currentPromptIndex,
      },
    );
  }
}
```

- [ ] **Step 4: Fix test prompt access**

In `test/ninja_runner/runner_controller_test.dart`, replace:

```dart
expect(controller.state.currentPrompt.id, 'helpful-action');
```

with:

```dart
expect(controller.currentPrompt.id, 'helpful-action');
```

- [ ] **Step 5: Run controller tests**

Run:

```bash
flutter test test/ninja_runner/runner_controller_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 6: Commit controller**

```bash
git add lib/ninja_runner/game/runner_controller.dart test/ninja_runner/runner_controller_test.dart
git commit -m "feat: add Ninja Runner game controller"
```

---

### Task 6: Runner Painter

**Files:**
- Create: `lib/ninja_runner/rendering/runner_painter.dart`

- [ ] **Step 1: Implement painter**

Create `lib/ninja_runner/rendering/runner_painter.dart`:

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/runner_controller.dart';
import '../models/content_pack.dart';

class RunnerPainter extends CustomPainter {
  RunnerPainter({
    required this.contentPack,
    required this.state,
    required this.currentPrompt,
  });

  final ContentPack contentPack;
  final RunnerGameState state;
  final RunnerPrompt currentPrompt;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawTrack(canvas, size);
    _drawHud(canvas, size);
    _drawGates(canvas, size);
    _drawRunner(canvas, size);
    if (state.phase == RunnerPhase.feedback && state.lastResult != null) {
      _drawFeedback(canvas, size, state.lastResult!);
    }
  }

  void _drawSky(Canvas canvas, Size size) {
    final skyPaint = Paint()..color = const Color(0xFF70D6FF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.55), skyPaint);

    final sunPaint = Paint()..color = contentPack.theme.secondaryColor;
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.16), 34, sunPaint);
  }

  void _drawTrack(Canvas canvas, Size size) {
    final groundTop = size.height * 0.52;
    final groundPaint = Paint()..color = contentPack.theme.primaryColor;
    canvas.drawRect(Rect.fromLTWH(0, groundTop, size.width, size.height - groundTop), groundPaint);

    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 3;
    for (var i = 0; i < 6; i++) {
      final y = groundTop + 28 + i * 24;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), stripePaint);
    }
  }

  void _drawHud(Canvas canvas, Size size) {
    _drawPill(canvas, const Offset(16, 14), '${state.currentPromptIndex + 1}/${contentPack.prompts.length}');
    _drawPill(canvas, Offset(size.width - 118, 14), 'Stars ${state.score}');
    _drawPrompt(canvas, size);
  }

  void _drawPrompt(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 58, size.width - 40, 58),
      const Radius.circular(16),
    );
    canvas.drawRRect(rect, Paint()..color = Colors.white.withOpacity(0.92));
    _drawText(
      canvas,
      currentPrompt.prompt,
      Offset(size.width / 2, 87),
      maxWidth: size.width - 70,
      fontSize: 20,
      fontWeight: FontWeight.w800,
      textAlign: TextAlign.center,
    );
  }

  void _drawPill(Canvas canvas, Offset offset, String text) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, 102, 34),
      const Radius.circular(20),
    );
    canvas.drawRRect(rect, Paint()..color = Colors.white.withOpacity(0.92));
    _drawText(
      canvas,
      text,
      Offset(offset.dx + 51, offset.dy + 17),
      maxWidth: 92,
      fontSize: 14,
      fontWeight: FontWeight.w800,
      textAlign: TextAlign.center,
    );
  }

  void _drawGates(Canvas canvas, Size size) {
    final answers = currentPrompt.answers.take(2).toList();
    final gateY = size.height * 0.54;
    final gateWidth = math.min(132.0, size.width * 0.27);
    final gateHeight = math.min(150.0, size.height * 0.32);
    final centers = [size.width * 0.62, size.width * 0.84];

    for (var i = 0; i < answers.length; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centers[i], gateY + gateHeight / 2),
          width: gateWidth,
          height: gateHeight,
        ),
        const Radius.circular(16),
      );
      final isCorrect = answers[i].id == currentPrompt.correctAnswerId;
      final color = state.phase == RunnerPhase.feedback && isCorrect
          ? const Color(0xFFFFD23F)
          : Colors.white.withOpacity(0.82);
      canvas.drawRRect(rect, Paint()..color = color);
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = Colors.white,
      );
      _drawText(
        canvas,
        answers[i].label,
        Offset(centers[i], gateY + gateHeight / 2),
        maxWidth: gateWidth - 18,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        textAlign: TextAlign.center,
      );
    }
  }

  void _drawRunner(Canvas canvas, Size size) {
    final baseX = size.width * (0.15 + state.runnerProgress * 0.34);
    final baseY = size.height * 0.74;
    final bodyPaint = Paint()..color = const Color(0xFFFFD166);
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xFF151515);

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(baseX, baseY), width: 66, height: 88),
      const Radius.circular(18),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outlinePaint);
    _drawText(
      canvas,
      contentPack.runner.name,
      Offset(baseX, baseY),
      maxWidth: 58,
      fontSize: 13,
      fontWeight: FontWeight.w900,
      textAlign: TextAlign.center,
    );
  }

  void _drawFeedback(Canvas canvas, Size size, RunnerSelectionResult result) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24, size.height * 0.22, size.width - 48, 82),
      const Radius.circular(18),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFF151515).withOpacity(0.88));
    _drawText(
      canvas,
      result.isCorrect ? 'Great choice!' : 'Good try!',
      Offset(size.width / 2, size.height * 0.22 + 28),
      maxWidth: size.width - 80,
      fontSize: 24,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
    _drawText(
      canvas,
      result.feedback,
      Offset(size.width / 2, size.height * 0.22 + 58),
      maxWidth: size.width - 86,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
    required double maxWidth,
    required double fontSize,
    required FontWeight fontWeight,
    Color color = const Color(0xFF151515),
    TextAlign textAlign = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth);

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant RunnerPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.currentPrompt.id != currentPrompt.id ||
        oldDelegate.contentPack.id != contentPack.id;
  }
}
```

- [ ] **Step 2: Run analyzer**

Run:

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 3: Commit painter**

```bash
git add lib/ninja_runner/rendering/runner_painter.dart
git commit -m "feat: add Ninja Runner custom painter"
```

---

### Task 7: Playable Screen

**Files:**
- Create: `lib/ninja_runner/ui/ninja_runner_screen.dart`
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Update widget smoke test**

Replace `test/widget_test.dart` with:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/main.dart';

void main() {
  testWidgets('shows the Ninja Runner start screen', (tester) async {
    await tester.pumpWidget(const KidNationMobileGamesApp());

    expect(find.text('Ninja Runner'), findsOneWidget);
    expect(find.text('Start Run'), findsOneWidget);
    expect(find.text('Jordan'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run widget test to verify failure**

Run:

```bash
flutter test test/widget_test.dart
```

Expected: fails because the real screen is not wired yet.

- [ ] **Step 3: Implement Ninja Runner screen**

Create `lib/ninja_runner/ui/ninja_runner_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../analytics/analytics_logger.dart';
import '../data/sample_content_pack.dart';
import '../game/runner_controller.dart';
import '../rendering/runner_painter.dart';

class NinjaRunnerScreen extends StatefulWidget {
  const NinjaRunnerScreen({super.key});

  @override
  State<NinjaRunnerScreen> createState() => _NinjaRunnerScreenState();
}

class _NinjaRunnerScreenState extends State<NinjaRunnerScreen>
    with SingleTickerProviderStateMixin {
  late final RunnerController _controller;
  late final Ticker _ticker;
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _controller = RunnerController(
      contentPack: sampleContentPack(),
      analyticsLogger: AnalyticsLogger(),
    );
    _ticker = createTicker(_handleTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleTick(Duration elapsed) {
    final lastTick = _lastTick;
    _lastTick = elapsed;
    if (lastTick == null) {
      return;
    }
    final delta = (elapsed - lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    setState(() {
      _controller.tick(delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1DF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _Header(controller: _controller),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) => _handleTap(details.localPosition, constraints.maxWidth),
                    onHorizontalDragEnd: (details) {
                      final velocity = details.primaryVelocity ?? 0;
                      if (velocity < 0) {
                        _chooseAnswer(1);
                      } else if (velocity > 0) {
                        _chooseAnswer(0);
                      }
                    },
                    child: CustomPaint(
                      painter: RunnerPainter(
                        contentPack: _controller.contentPack,
                        state: state,
                        currentPrompt: _controller.currentPrompt,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                _Controls(
                  controller: _controller,
                  onStart: _startRound,
                  onContinue: _continueAfterFeedback,
                  onAnswer: _chooseAnswer,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _startRound() {
    setState(_controller.startRound);
  }

  void _continueAfterFeedback() {
    setState(_controller.continueAfterFeedback);
  }

  void _handleTap(Offset position, double width) {
    if (_controller.state.phase != RunnerPhase.running) {
      return;
    }
    _chooseAnswer(position.dx < width * 0.73 ? 0 : 1);
  }

  void _chooseAnswer(int index) {
    if (_controller.state.phase != RunnerPhase.running) {
      return;
    }
    final answers = _controller.currentPrompt.answers;
    if (index < 0 || index >= answers.length) {
      return;
    }
    setState(() {
      _controller.selectAnswer(answers[index].id);
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final RunnerController controller;

  @override
  Widget build(BuildContext context) {
    final pack = controller.contentPack;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ninja Runner',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text('${pack.runner.name} • ${pack.theme.name} • ${pack.ageRangeLabel}'),
              ],
            ),
          ),
          Text(
            '${controller.state.score}/${pack.prompts.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.controller,
    required this.onStart,
    required this.onContinue,
    required this.onAnswer,
  });

  final RunnerController controller;
  final VoidCallback onStart;
  final VoidCallback onContinue;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: switch (state.phase) {
        RunnerPhase.ready => FilledButton(
            onPressed: onStart,
            child: const Text('Start Run'),
          ),
        RunnerPhase.running => Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => onAnswer(0),
                  child: Text(controller.currentPrompt.answers[0].label),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => onAnswer(1),
                  child: Text(controller.currentPrompt.answers[1].label),
                ),
              ),
            ],
          ),
        RunnerPhase.feedback => FilledButton(
            onPressed: onContinue,
            child: const Text('Keep Running'),
          ),
        RunnerPhase.summary => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Great run! Score: ${state.score}/${controller.contentPack.prompts.length}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: onStart,
                child: const Text('Play Again'),
              ),
            ],
          ),
        RunnerPhase.error => const Text('The run needs a quick reset.'),
      },
    );
  }
}
```

- [ ] **Step 4: Wire main app to the screen**

Replace `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';

import 'ninja_runner/ui/ninja_runner_screen.dart';

void main() {
  runApp(const KidNationMobileGamesApp());
}

class KidNationMobileGamesApp extends StatelessWidget {
  const KidNationMobileGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ninja Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A7E1)),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const NinjaRunnerScreen(),
    );
  }
}
```

- [ ] **Step 5: Run widget test**

Run:

```bash
flutter test test/widget_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 6: Run full test suite and analyzer**

Run:

```bash
flutter test && flutter analyze
```

Expected: tests pass and analyzer reports `No issues found!`

- [ ] **Step 7: Commit playable screen**

```bash
git add lib/main.dart lib/ninja_runner/ui/ninja_runner_screen.dart test/widget_test.dart
git commit -m "feat: add playable Ninja Runner screen"
```

---

### Task 8: Final Verification And Run Instructions

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Create README**

Create `README.md`:

```markdown
# KidNation Mobile Games

Flutter prototypes for KidNation learning games.

## Ninja Runner Prototype

`Ninja Runner` is a Flutter-only answer-gate runner for ages 5-8. It uses the KidNation Game Ideas Playbook mechanic and only the characters, visual theme ingredients, celebration style, and event-pattern inspiration from `miasstack/knsoccer`.

It does not reuse the KNSoccer soccer-match concept or mechanics.

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter test
flutter analyze
```
```

- [ ] **Step 2: Run final verification**

Run:

```bash
flutter test && flutter analyze
```

Expected: tests pass and analyzer reports `No issues found!`

- [ ] **Step 3: Start local app**

Run one of these depending on available devices:

```bash
flutter devices
flutter run -d chrome
```

Expected: the app opens and shows the `Ninja Runner` start screen. If Chrome is not available, run on any listed simulator/device from `flutter devices`.

- [ ] **Step 4: Commit README and final verification state**

```bash
git add README.md
git commit -m "docs: add Ninja Runner run instructions"
```

---

## Self-Review Against Spec

- Spec coverage:
  - Flutter-only prototype: Tasks 1, 6, and 7.
  - KNSoccer boundary: Tasks 3 and 8 explicitly guard against copied soccer-match mechanics.
  - Content pack model: Tasks 2 and 3.
  - Single runner lane: Tasks 5, 6, and 7.
  - Four screen states: Task 7.
  - Tap/swipe controls: Task 7.
  - Local analytics: Task 4 and Task 5.
  - Error-safe analytics: Task 4.
  - Tests: Tasks 2, 3, 4, 5, 7, and 8.
- Placeholder scan:
  - No placeholder markers, deferred implementation notes, or unspecified edge-case steps.
- Type consistency:
  - `ContentPack`, `RunnerPrompt`, `RunnerAnswer`, `RunnerTheme`, `RunnerCharacter`, `AnalyticsLogger`, `RunnerController`, `RunnerGameState`, `RunnerPhase`, and `RunnerPainter` are introduced before use.
