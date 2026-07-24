import 'package:flutter/material.dart';

import 'kidnation_visual_theme.dart';

enum GateFeedbackTone {
  neutral,
  correctSelected,
  correctHint,
  wrongSelected,
}

class GateFeedbackStyle {
  const GateFeedbackStyle({
    required this.tone,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.glowColor,
    required this.portalColor,
    required this.shakeOffset,
    required this.badgeLabel,
    required this.labelColor,
  });

  final GateFeedbackTone tone;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final Color glowColor;
  final Color portalColor;
  final Offset shakeOffset;
  final String? badgeLabel;
  final Color labelColor;

  static GateFeedbackStyle resolve({
    required int gateIndex,
    required bool isFeedback,
    required bool isCorrect,
    required bool isSelected,
    required bool selectedAnswerWasCorrect,
    required double scale,
  }) {
    final neutralFill = gateIndex == 0
        ? KidNationVisualTheme.cream
        : KidNationVisualTheme.palePurple;
    final neutralPortal = (gateIndex == 0
            ? KidNationVisualTheme.yellow
            : KidNationVisualTheme.secondary)
        .withValues(alpha: 0.5);

    if (!isFeedback) {
      return GateFeedbackStyle(
        tone: GateFeedbackTone.neutral,
        fillColor: neutralFill,
        strokeColor: Colors.white.withValues(alpha: 0.96),
        strokeWidth: 4,
        glowColor: Colors.transparent,
        portalColor: neutralPortal,
        shakeOffset: Offset.zero,
        badgeLabel: null,
        labelColor: KidNationVisualTheme.deepPurple,
      );
    }

    if (isCorrect && selectedAnswerWasCorrect) {
      return GateFeedbackStyle(
        tone: GateFeedbackTone.correctSelected,
        fillColor: KidNationVisualTheme.gold,
        strokeColor: const Color(0xFF13794A),
        strokeWidth: 7,
        glowColor: const Color(0xFFFFD23F).withValues(alpha: 0.42),
        portalColor: KidNationVisualTheme.yellow.withValues(alpha: 0.78),
        shakeOffset: Offset.zero,
        badgeLabel: 'KIND!',
        labelColor: KidNationVisualTheme.deepPurple,
      );
    }

    if (isCorrect) {
      return GateFeedbackStyle(
        tone: GateFeedbackTone.correctHint,
        fillColor: KidNationVisualTheme.gold.withValues(alpha: 0.92),
        strokeColor: const Color(0xFF13794A),
        strokeWidth: 6,
        glowColor: const Color(0xFF7CFFB2).withValues(alpha: 0.28),
        portalColor: const Color(0xFF7CFFB2).withValues(alpha: 0.54),
        shakeOffset: Offset.zero,
        badgeLabel: 'THIS WAY',
        labelColor: KidNationVisualTheme.deepPurple,
      );
    }

    if (isSelected) {
      final shake = gateIndex.isEven ? -4.0 * scale : 4.0 * scale;
      return GateFeedbackStyle(
        tone: GateFeedbackTone.wrongSelected,
        fillColor: const Color(0xFFFFB4A8),
        strokeColor: const Color(0xFF8D2430),
        strokeWidth: 6,
        glowColor: const Color(0xFFFF8A80).withValues(alpha: 0.32),
        portalColor: const Color(0xFFFF8A80).withValues(alpha: 0.52),
        shakeOffset: Offset(shake, 0),
        badgeLabel: 'TRY AGAIN',
        labelColor: const Color(0xFF5F1530),
      );
    }

    return GateFeedbackStyle(
      tone: GateFeedbackTone.neutral,
      fillColor: neutralFill.withValues(alpha: 0.72),
      strokeColor: Colors.white.withValues(alpha: 0.48),
      strokeWidth: 3,
      glowColor: Colors.transparent,
      portalColor: neutralPortal.withValues(alpha: 0.44),
      shakeOffset: Offset.zero,
      badgeLabel: null,
      labelColor: KidNationVisualTheme.deepPurple.withValues(alpha: 0.72),
    );
  }
}
