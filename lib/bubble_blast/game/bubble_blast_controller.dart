import 'package:flutter/material.dart';

import '../models/bubble_content_pack.dart';

enum BubbleBlastPhase {
  ready,
  playing,
  feedback,
  levelComplete,
  summary,
}

enum BubbleAudioCue {
  roundStart,
  correctPop,
  wrongBubble,
  levelComplete,
  roundComplete,
}

class BubbleSelectionResult {
  const BubbleSelectionResult({
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

class BubbleSprite {
  const BubbleSprite({
    required this.answer,
    required this.x,
    required this.y,
    required this.radius,
  });

  final BubbleAnswer answer;
  final double x;
  final double y;
  final double radius;

  BubbleSprite copyWith({
    double? x,
    double? y,
    double? radius,
  }) {
    return BubbleSprite(
      answer: answer,
      x: x ?? this.x,
      y: y ?? this.y,
      radius: radius ?? this.radius,
    );
  }
}

class BubbleBlastState {
  const BubbleBlastState({
    required this.phase,
    required this.currentPromptIndex,
    required this.score,
    required this.streak,
    required this.bestStreak,
    required this.bubbles,
    required this.popProgress,
    this.audioCue,
    this.lastResult,
    this.completedLevel,
  });

  factory BubbleBlastState.initial() {
    return const BubbleBlastState(
      phase: BubbleBlastPhase.ready,
      currentPromptIndex: 0,
      score: 0,
      streak: 0,
      bestStreak: 0,
      bubbles: [],
      popProgress: 1,
    );
  }

  final BubbleBlastPhase phase;
  final int currentPromptIndex;
  final int score;
  final int streak;
  final int bestStreak;
  final List<BubbleSprite> bubbles;
  final double popProgress;
  final BubbleAudioCue? audioCue;
  final BubbleSelectionResult? lastResult;
  final int? completedLevel;

  BubbleBlastState copyWith({
    BubbleBlastPhase? phase,
    int? currentPromptIndex,
    int? score,
    int? streak,
    int? bestStreak,
    List<BubbleSprite>? bubbles,
    double? popProgress,
    BubbleAudioCue? audioCue,
    BubbleSelectionResult? lastResult,
    int? completedLevel,
    bool clearAudioCue = false,
    bool clearLastResult = false,
    bool clearCompletedLevel = false,
  }) {
    return BubbleBlastState(
      phase: phase ?? this.phase,
      currentPromptIndex: currentPromptIndex ?? this.currentPromptIndex,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      bubbles: bubbles ?? this.bubbles,
      popProgress: popProgress ?? this.popProgress,
      audioCue: clearAudioCue ? null : audioCue ?? this.audioCue,
      lastResult: clearLastResult ? null : lastResult ?? this.lastResult,
      completedLevel:
          clearCompletedLevel ? null : completedLevel ?? this.completedLevel,
    );
  }
}

class BubbleBlastController {
  BubbleBlastController({required this.contentPack})
      : state = BubbleBlastState.initial();

  final BubbleContentPack contentPack;
  BubbleBlastState state;

  BubblePrompt get currentPrompt {
    return contentPack.prompts[state.currentPromptIndex];
  }

  List<BubbleSprite> get visibleBubbles {
    return List.unmodifiable(state.bubbles);
  }

  Duration get feedbackAutoAdvanceDelay {
    return state.lastResult?.isCorrect ?? false
        ? const Duration(milliseconds: 850)
        : const Duration(milliseconds: 1350);
  }

  String? answerIdAt(Offset position, Size playAreaSize) {
    for (final bubble in state.bubbles.reversed) {
      final center = Offset(
        bubble.x * playAreaSize.width,
        bubble.y * playAreaSize.height,
      );
      final radius = bubble.radius * playAreaSize.shortestSide;
      if ((position - center).distance <= radius) {
        return bubble.answer.id;
      }
    }
    return null;
  }

  void startRound() {
    state = BubbleBlastState.initial().copyWith(
      phase: BubbleBlastPhase.playing,
      bubbles: _buildBubbles(contentPack.prompts.first),
      audioCue: BubbleAudioCue.roundStart,
    );
  }

  void tick(double deltaSeconds) {
    if (state.phase == BubbleBlastPhase.feedback) {
      state = state.copyWith(
        popProgress: (state.popProgress + deltaSeconds * 3).clamp(0, 1),
      );
      return;
    }
    if (state.phase != BubbleBlastPhase.playing) {
      return;
    }
    final speed = 0.1 + currentPrompt.level * 0.035;
    state = state.copyWith(
      bubbles: [
        for (final bubble in state.bubbles)
          bubble.copyWith(
              y: (bubble.y - deltaSeconds * speed).clamp(0.12, 0.9)),
      ],
    );
  }

  BubbleSelectionResult selectBubble(String answerId) {
    if (state.phase != BubbleBlastPhase.playing) {
      return state.lastResult ??
          BubbleSelectionResult(
            selectedAnswerId: answerId,
            correctAnswerId: currentPrompt.correctAnswerId,
            isCorrect: false,
            feedback: currentPrompt.feedback,
          );
    }

    final prompt = currentPrompt;
    final isCorrect = answerId == prompt.correctAnswerId;
    final nextStreak = isCorrect ? state.streak + 1 : 0;
    final result = BubbleSelectionResult(
      selectedAnswerId: answerId,
      correctAnswerId: prompt.correctAnswerId,
      isCorrect: isCorrect,
      feedback: prompt.feedback,
    );

    state = state.copyWith(
      phase: BubbleBlastPhase.feedback,
      score: isCorrect ? state.score + 1 : state.score,
      streak: nextStreak,
      bestStreak: nextStreak > state.bestStreak ? nextStreak : state.bestStreak,
      popProgress: 0,
      audioCue:
          isCorrect ? BubbleAudioCue.correctPop : BubbleAudioCue.wrongBubble,
      lastResult: result,
    );
    return result;
  }

  void continueAfterFeedback() {
    if (state.phase == BubbleBlastPhase.levelComplete) {
      _advanceToPrompt(state.currentPromptIndex + 1);
      return;
    }
    if (state.phase != BubbleBlastPhase.feedback) {
      return;
    }

    final nextIndex = state.currentPromptIndex + 1;
    if (nextIndex >= contentPack.prompts.length) {
      state = state.copyWith(
        phase: BubbleBlastPhase.summary,
        audioCue: BubbleAudioCue.roundComplete,
      );
      return;
    }

    final currentLevel = currentPrompt.level;
    final nextPrompt = contentPack.prompts[nextIndex];
    if (nextPrompt.level > currentLevel) {
      state = state.copyWith(
        phase: BubbleBlastPhase.levelComplete,
        audioCue: BubbleAudioCue.levelComplete,
        completedLevel: currentLevel,
      );
      return;
    }
    _advanceToPrompt(nextIndex);
  }

  void _advanceToPrompt(int promptIndex) {
    final nextPrompt = contentPack.prompts[promptIndex];
    state = state.copyWith(
      phase: BubbleBlastPhase.playing,
      currentPromptIndex: promptIndex,
      bubbles: _buildBubbles(nextPrompt),
      popProgress: 1,
      clearAudioCue: true,
      clearLastResult: true,
      clearCompletedLevel: true,
    );
  }

  List<BubbleSprite> _buildBubbles(BubblePrompt prompt) {
    final positions = [
      (x: 0.24, y: 0.76, radius: 0.105),
      (x: 0.52, y: 0.68, radius: 0.118),
      (x: 0.78, y: 0.79, radius: 0.1),
      (x: 0.36, y: 0.88, radius: 0.094),
      (x: 0.66, y: 0.9, radius: 0.098),
    ];
    return [
      for (var index = 0; index < prompt.answers.length; index++)
        BubbleSprite(
          answer: prompt.answers[index],
          x: positions[index % positions.length].x,
          y: positions[index % positions.length].y,
          radius: positions[index % positions.length].radius -
              (prompt.level - 1) * 0.008,
        ),
    ];
  }
}
