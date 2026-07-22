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
    final nextProgress = (state.runnerProgress + deltaSeconds * 0.22)
        .clamp(0, 1)
        .toDouble();
    state = state.copyWith(runnerProgress: nextProgress);
  }

  RunnerSelectionResult selectAnswer(String answerId) {
    if (state.phase != RunnerPhase.running) {
      throw StateError('Answers can only be selected while running.');
    }

    final prompt = currentPrompt;
    if (!prompt.answers.any((answer) => answer.id == answerId)) {
      throw ArgumentError.value(
        answerId,
        'answerId',
        'Answer is not available for the current prompt.',
      );
    }

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
      state = state.copyWith(
        phase: RunnerPhase.summary,
        runnerProgress: 0,
        clearLastResult: true,
      );
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
