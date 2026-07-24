import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/ninja_go_controller.dart';
import '../models/ninja_go_models.dart';

class NinjaGoPainter extends CustomPainter {
  const NinjaGoPainter({required this.state});

  final NinjaGoState state;

  static const _ink = Color(0xFF151515);
  static const _skyTop = Color(0xFF70D6FF);
  static const _skyBottom = Color(0xFFC7F7FF);
  static const _kidYellow = Color(0xFFFFD23F);
  static const _kidCoral = Color(0xFFFF7A59);
  static const _kidGreen = Color(0xFF6FCF97);
  static const _kidBlue = Color(0xFF2F80ED);
  static const _trackNear = Color(0xFF49516F);
  static const _trackFar = Color(0xFF6B73A0);
  static const _lanePaint = Color(0xFFFFF4C7);

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawTrack(canvas, size);
    _drawScenery(canvas, size);
    _drawEntities(canvas, size);
    _drawRunner(canvas, size);
    _drawHud(canvas, size);

    if (state.phase == NinjaGoPhase.gameOver) {
      _drawGameOverOverlay(canvas, size);
    }
  }

  void _drawSky(Canvas canvas, Size size) {
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.64);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_skyTop, _skyBottom],
        ).createShader(skyRect),
    );

    final sunCenter = Offset(size.width * 0.82, size.height * 0.14);
    final sunRadius = math.min(size.width, size.height) * 0.085;
    canvas.drawCircle(
      sunCenter,
      sunRadius * 1.45,
      Paint()..color = _kidYellow.withValues(alpha: 0.2),
    );
    canvas.drawCircle(sunCenter, sunRadius, Paint()..color = _kidYellow);

    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.82);
    _drawCloud(canvas, Offset(size.width * 0.18, size.height * 0.17),
        size.width * 0.08, cloudPaint);
    _drawCloud(canvas, Offset(size.width * 0.58, size.height * 0.1),
        size.width * 0.055, cloudPaint);

    for (var index = 0; index < 7; index += 1) {
      final x = (0.1 + index * 0.13) * size.width;
      final y = (0.27 + (index.isEven ? 0.04 : 0.0)) * size.height;
      _drawSpark(canvas, Offset(x, y), 5 + index % 3, _kidYellow);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawCircle(
        center.translate(-radius * 0.8, radius * 0.15), radius * 0.68, paint);
    canvas.drawCircle(
        center.translate(-radius * 0.1, -radius * 0.1), radius * 0.88, paint);
    canvas.drawCircle(
        center.translate(radius * 0.72, radius * 0.14), radius * 0.62, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, radius * 0.42),
          width: radius * 3.0,
          height: radius * 0.86,
        ),
        Radius.circular(radius),
      ),
      paint,
    );
  }

  void _drawTrack(Canvas canvas, Size size) {
    final topY = size.height * 0.36;
    final bottomY = size.height;
    final topHalf = size.width * 0.12;
    final bottomHalf = size.width * 0.54;
    final centerX = size.width / 2;
    final track = Path()
      ..moveTo(centerX - topHalf, topY)
      ..lineTo(centerX + topHalf, topY)
      ..lineTo(centerX + bottomHalf, bottomY)
      ..lineTo(centerX - bottomHalf, bottomY)
      ..close();

    canvas.drawRect(
      Rect.fromLTWH(0, topY - 12, size.width, bottomY - topY + 12),
      Paint()..color = _kidGreen,
    );
    canvas.drawPath(
      track,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_trackFar, _trackNear],
        ).createShader(track.getBounds()),
    );

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawLine(
      Offset(centerX - topHalf, topY),
      Offset(centerX - bottomHalf, bottomY),
      edgePaint,
    );
    canvas.drawLine(
      Offset(centerX + topHalf, topY),
      Offset(centerX + bottomHalf, bottomY),
      edgePaint,
    );

    for (final laneEdge in const [1 / 3, 2 / 3]) {
      final path = Path()
        ..moveTo(centerX - topHalf + topHalf * 2 * laneEdge, topY)
        ..lineTo(centerX - bottomHalf + bottomHalf * 2 * laneEdge, bottomY);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _lanePaint.withValues(alpha: 0.82),
      );
    }

    for (var index = 0; index < 6; index += 1) {
      final position = 0.17 + index * 0.14;
      final y = _yForPosition(size, position);
      final scale = _scaleForPosition(position);
      final halfWidth = _trackHalfWidth(size, position);
      canvas.drawLine(
        Offset(centerX - halfWidth * 0.9, y),
        Offset(centerX + halfWidth * 0.9, y),
        Paint()
          ..strokeWidth = 2 + scale * 2
          ..color = Colors.white.withValues(alpha: 0.18),
      );
    }
  }

  void _drawScenery(Canvas canvas, Size size) {
    final y = size.height * 0.47;
    final barrierPaint = Paint()..color = _kidCoral;
    final capPaint = Paint()..color = _kidYellow;

    for (var side = -1; side <= 1; side += 2) {
      for (var index = 0; index < 5; index += 1) {
        final x = size.width * (side < 0 ? 0.08 : 0.92);
        final postY = y + index * size.height * 0.105;
        final width = 28 + index * 8;
        final rect = Rect.fromCenter(
          center: Offset(x, postY),
          width: width.toDouble(),
          height: 12,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          barrierPaint,
        );
        canvas.drawCircle(Offset(x, postY - 7), 5, capPaint);
      }
    }
  }

  void _drawEntities(Canvas canvas, Size size) {
    final visibleEntities = state.entities
        .where((entity) => !entity.collected && entity.position > -0.2)
        .toList()
      ..sort((a, b) => b.position.compareTo(a.position));

    for (final entity in visibleEntities) {
      final center = _lanePoint(size, entity.lane, entity.position);
      final scale = _scaleForPosition(entity.position);
      switch (entity.kind) {
        case NinjaGoEntityKind.star:
          _drawStar(canvas, center, 12 + scale * 18);
        case NinjaGoEntityKind.groundBarrier:
          _drawGroundBarrier(canvas, center, scale);
        case NinjaGoEntityKind.overheadObstacle:
          _drawOverheadObstacle(canvas, center, scale);
        case NinjaGoEntityKind.laneBlocker:
          _drawLaneBlocker(canvas, center, scale);
      }
    }
  }

  void _drawGroundBarrier(Canvas canvas, Offset center, double scale) {
    final width = 36 + scale * 46;
    final height = 16 + scale * 18;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, 10 * scale),
        width: width,
        height: height,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(rect, Paint()..color = _kidCoral);
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + scale * 2
        ..color = Colors.white,
    );
  }

  void _drawOverheadObstacle(Canvas canvas, Offset center, double scale) {
    final width = 34 + scale * 56;
    final height = 14 + scale * 14;
    final yOffset = -(36 + scale * 34);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, yOffset),
        width: width,
        height: height,
      ),
      const Radius.circular(5),
    );
    canvas.drawLine(
      center.translate(-width * 0.42, yOffset - height),
      center.translate(-width * 0.42, yOffset + height),
      Paint()
        ..strokeWidth = 2 + scale
        ..color = _ink.withValues(alpha: 0.5),
    );
    canvas.drawLine(
      center.translate(width * 0.42, yOffset - height),
      center.translate(width * 0.42, yOffset + height),
      Paint()
        ..strokeWidth = 2 + scale
        ..color = _ink.withValues(alpha: 0.5),
    );
    canvas.drawRRect(rect, Paint()..color = _kidBlue);
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + scale * 2
        ..color = Colors.white,
    );
  }

  void _drawLaneBlocker(Canvas canvas, Offset center, double scale) {
    final radius = 15 + scale * 24;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center.translate(0, -radius * 0.1),
        width: radius * 1.7,
        height: radius * 1.7,
      ),
      Radius.circular(radius * 0.28),
    );
    canvas.drawRRect(rect, Paint()..color = _ink);
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 + scale
        ..color = _kidYellow,
    );
    _drawText(
      canvas,
      '!',
      rect.outerRect.center,
      maxWidth: radius,
      fontSize: 18 + scale * 18,
      fontWeight: FontWeight.w900,
      color: _kidYellow,
      textAlign: TextAlign.center,
    );
  }

  void _drawRunner(Canvas canvas, Size size) {
    final base = _lanePoint(
      size,
      state.currentLane,
      NinjaGoController.hitPosition,
    );
    final actionLift = switch (state.runnerAction) {
      NinjaGoRunnerAction.running => 0.0,
      NinjaGoRunnerAction.jumping => -size.height * 0.07,
      NinjaGoRunnerAction.sliding => size.height * 0.015,
    };
    final center = base.translate(0, actionLift);
    final isSliding = state.runnerAction == NinjaGoRunnerAction.sliding;
    final bodyWidth = math.min(72.0, size.width * 0.17);
    final bodyHeight = isSliding ? bodyWidth * 0.62 : bodyWidth * 1.2;

    final shadowRect = Rect.fromCenter(
      center: base.translate(0, bodyWidth * 0.62),
      width: bodyWidth * 1.05,
      height: bodyWidth * 0.2,
    );
    canvas.drawOval(
      shadowRect,
      Paint()..color = _ink.withValues(alpha: 0.18),
    );

    final legPaint = Paint()
      ..strokeWidth = math.max(4, bodyWidth * 0.08)
      ..strokeCap = StrokeCap.round
      ..color = _ink;
    final legY = center.dy + bodyHeight * 0.5;
    canvas.drawLine(
      Offset(center.dx - bodyWidth * 0.16, legY - bodyWidth * 0.08),
      Offset(center.dx - bodyWidth * 0.38, legY + bodyWidth * 0.28),
      legPaint,
    );
    canvas.drawLine(
      Offset(center.dx + bodyWidth * 0.16, legY - bodyWidth * 0.08),
      Offset(center.dx + bodyWidth * 0.42, legY + bodyWidth * 0.18),
      legPaint,
    );

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: bodyWidth,
        height: bodyHeight,
      ),
      Radius.circular(bodyWidth * 0.22),
    );
    canvas.drawRRect(body, Paint()..color = _kidYellow);
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(3, bodyWidth * 0.07)
        ..color = _ink,
    );

    final headRadius = bodyWidth * 0.34;
    final headCenter = Offset(center.dx, body.top - headRadius * 0.62);
    canvas.drawCircle(headCenter, headRadius, Paint()..color = _ink);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: headCenter.translate(0, headRadius * 0.05),
          width: headRadius * 1.15,
          height: headRadius * 0.58,
        ),
        Radius.circular(headRadius * 0.22),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      headCenter.translate(-headRadius * 0.27, headRadius * 0.04),
      headRadius * 0.08,
      Paint()..color = _ink,
    );
    canvas.drawCircle(
      headCenter.translate(headRadius * 0.27, headRadius * 0.04),
      headRadius * 0.08,
      Paint()..color = _ink,
    );

    canvas.drawCircle(
      Offset(center.dx, center.dy - bodyHeight * 0.05),
      bodyWidth * 0.23,
      Paint()..color = Colors.white,
    );
    _drawText(
      canvas,
      'KN',
      Offset(center.dx, center.dy - bodyHeight * 0.05),
      maxWidth: bodyWidth * 0.42,
      fontSize: bodyWidth * 0.2,
      fontWeight: FontWeight.w900,
      textAlign: TextAlign.center,
    );
  }

  void _drawHud(Canvas canvas, Size size) {
    final top = math.max(12.0, size.height * 0.035);
    _drawPill(
      canvas,
      Offset(14, top),
      'Score ${state.score}',
      width: math.min(124, size.width * 0.34),
      color: Colors.white.withValues(alpha: 0.9),
    );
    _drawPill(
      canvas,
      Offset(size.width / 2 - math.min(96, size.width * 0.25) / 2, top),
      'Stars ${state.stars}',
      width: math.min(96, size.width * 0.25),
      color: _kidYellow.withValues(alpha: 0.92),
    );
    _drawPill(
      canvas,
      Offset(size.width - math.min(132, size.width * 0.34) - 14, top),
      '${state.distance.floor()} m',
      width: math.min(132, size.width * 0.34),
      color: Colors.white.withValues(alpha: 0.9),
    );
  }

  void _drawPill(
    Canvas canvas,
    Offset offset,
    String label, {
    required double width,
    required Color color,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width, 32),
      const Radius.circular(16),
    );
    canvas.drawRRect(rect, Paint()..color = color);
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _ink.withValues(alpha: 0.12),
    );
    _drawText(
      canvas,
      label,
      rect.outerRect.center,
      maxWidth: width - 14,
      fontSize: 13,
      fontWeight: FontWeight.w900,
      textAlign: TextAlign.center,
    );
  }

  void _drawGameOverOverlay(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = _ink.withValues(alpha: 0.28),
    );
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.36),
        width: math.min(size.width - 44, 300),
        height: 106,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _kidCoral,
    );
    _drawText(
      canvas,
      'Run complete!',
      rect.outerRect.center.translate(0, -22),
      maxWidth: rect.outerRect.width - 32,
      fontSize: 24,
      fontWeight: FontWeight.w900,
      textAlign: TextAlign.center,
    );
    _drawText(
      canvas,
      'Best ${state.bestDistance.floor()} m  Score ${state.bestScore}',
      rect.outerRect.center.translate(0, 20),
      maxWidth: rect.outerRect.width - 36,
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: _ink.withValues(alpha: 0.78),
      textAlign: TextAlign.center,
    );
  }

  Offset _lanePoint(Size size, NinjaGoLane lane, double position) {
    const laneCenters = {
      NinjaGoLane.left: 1 / 6,
      NinjaGoLane.center: 3 / 6,
      NinjaGoLane.right: 5 / 6,
    };
    final y = _yForPosition(size, position);
    final halfWidth = _trackHalfWidth(size, position);
    final centerX = size.width / 2;
    final laneOffset = laneCenters[lane]! * 2 - 1;

    return Offset(centerX + laneOffset * halfWidth, y);
  }

  double _trackHalfWidth(Size size, double position) {
    final t = (1 - position).clamp(0.0, 1.2);
    final topHalf = size.width * 0.12;
    final bottomHalf = size.width * 0.54;

    return topHalf + (bottomHalf - topHalf) * t;
  }

  double _yForPosition(Size size, double position) {
    final horizon = size.height * 0.36;
    final bottom = size.height * 0.98;
    final t = (1 - position).clamp(0.0, 1.16);

    return horizon + (bottom - horizon) * math.pow(t, 1.35);
  }

  double _scaleForPosition(double position) {
    final t = (1 - position).clamp(0.0, 1.0);

    return 0.24 + t * 0.9;
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (var point = 0; point < 10; point += 1) {
      final angle = -math.pi / 2 + point * math.pi / 5;
      final r = point.isEven ? radius : radius * 0.45;
      final next = center.translate(math.cos(angle) * r, math.sin(angle) * r);
      if (point == 0) {
        path.moveTo(next.dx, next.dy);
      } else {
        path.lineTo(next.dx, next.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = _kidYellow);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, radius * 0.12)
        ..color = Colors.white,
    );
  }

  void _drawSpark(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.72);
    canvas.drawLine(
      center.translate(-radius, 0),
      center.translate(radius, 0),
      paint,
    );
    canvas.drawLine(
      center.translate(0, -radius),
      center.translate(0, radius),
      paint,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
    required double maxWidth,
    required double fontSize,
    required FontWeight fontWeight,
    Color color = _ink,
    TextAlign textAlign = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1.1,
        ),
      ),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: math.max(8, maxWidth));

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant NinjaGoPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
