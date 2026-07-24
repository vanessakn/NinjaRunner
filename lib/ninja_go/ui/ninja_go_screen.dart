import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _controller = NinjaGoController();
    _ticker = createTicker(_handleTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
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
    return Scaffold(
      backgroundColor: const Color(0xFFE8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(state: state),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: _handleHorizontalDragEnd,
                onVerticalDragEnd: _handleVerticalDragEnd,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: NinjaGoPainter(state: state),
                      child: const SizedBox.expand(),
                    ),
                    if (state.phase == NinjaGoPhase.ready)
                      _ReadyOverlay(onStart: _startRun),
                    if (state.phase == NinjaGoPhase.gameOver)
                      _GameOverOverlay(state: state, onPlayAgain: _startRun),
                  ],
                ),
              ),
            ),
            _ActionButtons(
              isRunning: state.phase == NinjaGoPhase.running,
              onLeft: _moveLeft,
              onJump: _jump,
              onSlide: _slide,
              onRight: _moveRight,
            ),
          ],
        ),
      ),
    );
  }

  void _startRun() {
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

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < 0) {
      _moveRight();
    } else if (velocity > 0) {
      _moveLeft();
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < 0) {
      _jump();
    } else if (velocity > 0) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Score',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                '${state.score}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ],
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
                    'Dodge the obstacles, grab stars, and keep moving.',
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      child: Row(
        children: [
          _ControlButton(
            label: 'Left',
            icon: Icons.arrow_back_rounded,
            onPressed: isRunning ? onLeft : null,
          ),
          const SizedBox(width: 8),
          _ControlButton(
            label: 'Jump',
            icon: Icons.keyboard_arrow_up_rounded,
            onPressed: isRunning ? onJump : null,
          ),
          const SizedBox(width: 8),
          _ControlButton(
            label: 'Slide',
            icon: Icons.keyboard_arrow_down_rounded,
            onPressed: isRunning ? onSlide : null,
          ),
          const SizedBox(width: 8),
          _ControlButton(
            label: 'Right',
            icon: Icons.arrow_forward_rounded,
            onPressed: isRunning ? onRight : null,
          ),
        ],
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
        height: 54,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
