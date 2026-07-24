import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/ninja_go_controller.dart';
import '../models/ninja_go_models.dart';
import '../rendering/ninja_go_painter.dart';

class NinjaGoScreen extends StatefulWidget {
  const NinjaGoScreen({super.key});

  @override
  State<NinjaGoScreen> createState() => _NinjaGoScreenState();
}

class _NinjaGoScreenState extends State<NinjaGoScreen>
    with SingleTickerProviderStateMixin {
  late final NinjaGoController _controller;
  late final Ticker _ticker;
  late final FocusNode _focusNode;
  Duration? _lastTick;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = NinjaGoController();
    _ticker = createTicker(_handleTick);
    _focusNode = FocusNode(debugLabel: 'NinjaGoControls');
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTick(Duration elapsed) {
    if (_controller.state.phase != NinjaGoPhase.running) {
      _stopTicker();
      return;
    }

    final lastTick = _lastTick;
    _lastTick = elapsed;
    if (lastTick == null) {
      return;
    }

    final delta =
        (elapsed - lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    setState(() {
      _controller.tick(delta);
    });
    if (_controller.state.phase != NinjaGoPhase.running) {
      _stopTicker();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8FAFF),
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(state: state),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => _focusNode.requestFocus(),
                  onPanStart: (_) => _dragOffset = Offset.zero,
                  onPanUpdate: _handlePanUpdate,
                  onPanEnd: (_) => _dragOffset = Offset.zero,
                  onPanCancel: () => _dragOffset = Offset.zero,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: NinjaGoPainter(state: state),
                        child: const SizedBox.expand(),
                      ),
                      _RunnerSprite(state: state),
                      _SwipeHint(
                          isRunning: state.phase == NinjaGoPhase.running),
                      _ActionButtons(
                        isRunning: state.phase == NinjaGoPhase.running,
                        onLeft: _moveLeft,
                        onJump: _jump,
                        onSlide: _slide,
                        onRight: _moveRight,
                      ),
                      if (state.phase == NinjaGoPhase.ready)
                        _ReadyOverlay(onStart: _startRun),
                      if (state.phase == NinjaGoPhase.gameOver)
                        _GameOverOverlay(state: state, onPlayAgain: _startRun),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startRun() {
    _focusNode.requestFocus();
    setState(_controller.startRun);
    _startTicker();
  }

  void _moveLeft() {
    setState(_controller.moveLeft);
  }

  void _moveRight() {
    setState(_controller.moveRight);
  }

  void _jump() {
    setState(_controller.jump);
  }

  void _slide() {
    setState(_controller.slide);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_controller.state.phase != NinjaGoPhase.running) {
      return;
    }

    _dragOffset += details.delta;
    const threshold = 26.0;
    final horizontal = _dragOffset.dx.abs();
    final vertical = _dragOffset.dy.abs();

    if (horizontal < threshold && vertical < threshold) {
      return;
    }

    if (horizontal > vertical) {
      _dragOffset.dx > 0 ? _moveRight() : _moveLeft();
    } else {
      _dragOffset.dy > 0 ? _slide() : _jump();
    }
    _dragOffset = Offset.zero;
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.keyA:
        _moveLeft();
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.keyD:
        _moveRight();
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.keyW:
      case LogicalKeyboardKey.space:
        _jump();
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.keyS:
        _slide();
    }
  }

  void _startTicker() {
    _lastTick = null;
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _stopTicker() {
    _lastTick = null;
    if (_ticker.isActive) {
      _ticker.stop();
    }
  }
}

class _RunnerSprite extends StatelessWidget {
  const _RunnerSprite({required this.state});

  static const _assetPath = 'assets/characters/jordan_ninja_go_runner.png';

  final NinjaGoState state;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final base = _lanePoint(
            size,
            state.currentLane,
            NinjaGoController.hitPosition,
          );
          final width = math.min(132.0, math.max(84.0, size.width * 0.25));
          final height = width * 2.58;
          final actionLift = switch (state.runnerAction) {
            NinjaGoRunnerAction.running => 0.0,
            NinjaGoRunnerAction.jumping => -size.height * 0.09,
            NinjaGoRunnerAction.sliding => size.height * 0.035,
          };
          final isSliding = state.runnerAction == NinjaGoRunnerAction.sliding;
          final top = base.dy - height * 0.8 + actionLift;
          final left = base.dx - width / 2;

          return IgnorePointer(
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 110),
                  curve: Curves.easeOut,
                  left: left,
                  top: top,
                  width: width,
                  height: height,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.diagonal3Values(
                      isSliding ? 1.14 : 1.0,
                      isSliding ? 0.62 : 1.0,
                      1,
                    ),
                    child: Image.asset(
                      _assetPath,
                      key: const Key('ninja-go-runner-sprite'),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Offset _lanePoint(Size size, NinjaGoLane lane, double position) {
    final laneCenter = switch (lane) {
      NinjaGoLane.left => 1 / 6,
      NinjaGoLane.center => 3 / 6,
      NinjaGoLane.right => 5 / 6,
    };
    final y = _yForPosition(size, position);
    final halfWidth = _trackHalfWidth(size, position);
    final centerX = size.width / 2;
    return Offset(centerX - halfWidth + halfWidth * 2 * laneCenter, y);
  }

  double _yForPosition(Size size, double position) {
    final horizon = size.height * 0.31;
    final bottom = size.height * 0.9;
    final t = (1 - position).clamp(0.0, 1.16);
    return horizon + (bottom - horizon) * math.pow(t, 1.35);
  }

  double _trackHalfWidth(Size size, double position) {
    final topHalf = size.width * 0.075;
    final bottomHalf = size.width * 0.41;
    final t = (1 - position).clamp(0.0, 1.2);
    return topHalf + (bottomHalf - topHalf) * math.pow(t, 1.18);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});

  final NinjaGoState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'KidNation Ninja Go',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          _HudChip(label: 'Score', value: '${state.score}'),
          const SizedBox(width: 8),
          _HudChip(label: 'Stars', value: '${state.stars}'),
          const SizedBox(width: 8),
          _HudChip(label: 'Meters', value: '${state.distance.floor()}'),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({required this.isRunning});

  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    if (!isRunning) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 16,
      top: 14,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            'Swipe anywhere',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ),
    );
  }
}

class _ReadyOverlay extends StatelessWidget {
  const _ReadyOverlay({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFF7A59), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ready, ninja?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Swipe anywhere. Dodge obstacles, grab stars, and keep moving.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: onStart,
                      child: const Text('Start Run'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.state,
    required this.onPlayAgain,
  });

  final NinjaGoState state;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2F80ED), width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Run Complete',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _RunStat(
                      label: 'Distance', value: '${state.distance.floor()} m'),
                  _RunStat(label: 'Stars', value: '${state.stars}'),
                  _RunStat(
                    label: 'Speed',
                    value: 'x${state.speed.toStringAsFixed(1)}',
                  ),
                  _RunStat(
                    label: 'Best',
                    value: '${state.bestDistance.floor()} m',
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: onPlayAgain,
                      child: const Text('Play Again'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RunStat extends StatelessWidget {
  const _RunStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isRunning,
    required this.onLeft,
    required this.onJump,
    required this.onSlide,
    required this.onRight,
  });

  final bool isRunning;
  final VoidCallback onLeft;
  final VoidCallback onJump;
  final VoidCallback onSlide;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 14,
      right: 14,
      bottom: 14,
      child: IgnorePointer(
        ignoring: !isRunning,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: isRunning ? 1 : 0,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    _ControlButton(
                      label: 'Left',
                      icon: Icons.arrow_back_rounded,
                      onPressed: isRunning ? onLeft : null,
                    ),
                    const SizedBox(width: 10),
                    _ControlButton(
                      label: 'Right',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: isRunning ? onRight : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    _ControlButton(
                      label: 'Jump',
                      icon: Icons.keyboard_arrow_up_rounded,
                      onPressed: isRunning ? onJump : null,
                    ),
                    const SizedBox(width: 10),
                    _ControlButton(
                      label: 'Slide',
                      icon: Icons.keyboard_arrow_down_rounded,
                      onPressed: isRunning ? onSlide : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF176D88),
            disabledBackgroundColor: const Color(0xFF176D88),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 22),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
