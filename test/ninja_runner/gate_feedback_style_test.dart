import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/rendering/gate_feedback_style.dart';
import 'package:kidnation_mobile_games/ninja_runner/rendering/kidnation_visual_theme.dart';

void main() {
  test('correct selection makes the correct gate celebratory', () {
    final style = GateFeedbackStyle.resolve(
      gateIndex: 0,
      isFeedback: true,
      isCorrect: true,
      isSelected: true,
      selectedAnswerWasCorrect: true,
      scale: 1,
    );

    expect(style.tone, GateFeedbackTone.correctSelected);
    expect(style.fillColor, KidNationVisualTheme.gold);
    expect(style.strokeWidth, greaterThan(6));
    expect(style.badgeLabel, 'KIND!');
    expect(style.shakeOffset.dx, 0);
  });

  test('wrong selection shakes selected gate and hints correct gate', () {
    final wrongSelected = GateFeedbackStyle.resolve(
      gateIndex: 1,
      isFeedback: true,
      isCorrect: false,
      isSelected: true,
      selectedAnswerWasCorrect: false,
      scale: 1,
    );
    final correctHint = GateFeedbackStyle.resolve(
      gateIndex: 0,
      isFeedback: true,
      isCorrect: true,
      isSelected: false,
      selectedAnswerWasCorrect: false,
      scale: 1,
    );

    expect(wrongSelected.tone, GateFeedbackTone.wrongSelected);
    expect(wrongSelected.shakeOffset.dx.abs(), greaterThan(1));
    expect(wrongSelected.fillColor, const Color(0xFFFFB4A8));
    expect(wrongSelected.badgeLabel, 'TRY AGAIN');
    expect(correctHint.tone, GateFeedbackTone.correctHint);
    expect(correctHint.badgeLabel, 'THIS WAY');
    expect(correctHint.strokeColor, const Color(0xFF13794A));
  });

  test('neutral gates keep left and right KidNation colors', () {
    final left = GateFeedbackStyle.resolve(
      gateIndex: 0,
      isFeedback: false,
      isCorrect: false,
      isSelected: false,
      selectedAnswerWasCorrect: false,
      scale: 1,
    );
    final right = GateFeedbackStyle.resolve(
      gateIndex: 1,
      isFeedback: false,
      isCorrect: false,
      isSelected: false,
      selectedAnswerWasCorrect: false,
      scale: 1,
    );

    expect(left.fillColor, KidNationVisualTheme.cream);
    expect(right.fillColor, KidNationVisualTheme.palePurple);
    expect(left.badgeLabel, isNull);
    expect(right.badgeLabel, isNull);
  });
}
