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
    _ticker = createTicker(_handleTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleTick(Duration elapsed) {
    if (_controller.state.phase != RunnerPhase.running) {
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
                    onTapUp: (details) => _handleTap(
                      details.localPosition,
                      constraints.maxWidth,
                    ),
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
    _startTicker();
  }

  void _continueAfterFeedback() {
    setState(_controller.continueAfterFeedback);
    if (_controller.state.phase == RunnerPhase.running) {
      _startTicker();
    } else {
      _stopTicker();
    }
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
    if (_controller.state.phase != RunnerPhase.running) {
      _stopTicker();
    }
  }

  void _startTicker() {
    _lastTick = null;
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _stopTicker() {
    if (_ticker.isActive) {
      _ticker.stop();
    }
    _lastTick = null;
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
                  'KidNation Gate Dash',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(pack.runner.name),
                Text('${pack.theme.name} - ${pack.ageRangeLabel}'),
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
                'Great run! Score: '
                '${state.score}/${controller.contentPack.prompts.length}',
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
