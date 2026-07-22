import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../analytics/analytics_logger.dart';
import '../data/sample_content_pack.dart';
import '../game/runner_controller.dart';
import '../models/gate_dash_level.dart';
import '../rendering/runner_painter.dart';

class NinjaRunnerScreen extends StatefulWidget {
  const NinjaRunnerScreen({super.key});

  @override
  State<NinjaRunnerScreen> createState() => _NinjaRunnerScreenState();
}

class _NinjaRunnerScreenState extends State<NinjaRunnerScreen>
    with SingleTickerProviderStateMixin {
  late final List<GateDashLevel> _levels;
  late RunnerController _controller;
  late final Ticker _ticker;
  var _selectedLevelIndex = 0;
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _levels = sampleGateDashLevels();
    _controller = _createController(_levels[_selectedLevelIndex]);
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
                  levels: _levels,
                  selectedLevelIndex: _selectedLevelIndex,
                  onStart: _startRound,
                  onContinue: _continueAfterFeedback,
                  onAnswer: _chooseAnswer,
                  onSelectLevel: _selectLevel,
                  onNextLevel: _goToNextLevel,
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

  void _selectLevel(int index) {
    if (_controller.state.phase != RunnerPhase.ready) {
      return;
    }
    setState(() {
      _selectedLevelIndex = index;
      _controller = _createController(_levels[index]);
    });
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

  void _goToNextLevel() {
    final nextIndex = _selectedLevelIndex + 1;
    if (nextIndex >= _levels.length || !_controller.isLevelComplete) {
      return;
    }
    setState(() {
      _selectedLevelIndex = nextIndex;
      _controller = _createController(_levels[nextIndex]);
      _controller.startRound();
    });
    _startTicker();
  }

  RunnerController _createController(GateDashLevel level) {
    return RunnerController(
      level: level,
      analyticsLogger: AnalyticsLogger(),
    );
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
                Text('${controller.level.name} - ${pack.theme.name}'),
                Text(pack.ageRangeLabel),
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
    required this.levels,
    required this.selectedLevelIndex,
    required this.onStart,
    required this.onContinue,
    required this.onAnswer,
    required this.onSelectLevel,
    required this.onNextLevel,
  });

  final RunnerController controller;
  final List<GateDashLevel> levels;
  final int selectedLevelIndex;
  final VoidCallback onStart;
  final VoidCallback onContinue;
  final ValueChanged<int> onAnswer;
  final ValueChanged<int> onSelectLevel;
  final VoidCallback onNextLevel;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: switch (state.phase) {
        RunnerPhase.ready => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LevelChoices(
                levels: levels,
                selectedLevelIndex: selectedLevelIndex,
                onSelectLevel: onSelectLevel,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onStart,
                child: const Text('Start Run'),
              ),
            ],
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
                controller.isLevelComplete ? 'Level Complete!' : 'Try Again',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Score: ${state.score}/${controller.contentPack.prompts.length} '
                '- Need ${controller.level.requiredScore}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (controller.isLevelComplete &&
                  selectedLevelIndex < levels.length - 1)
                FilledButton(
                  onPressed: onNextLevel,
                  child: const Text('Next Level'),
                )
              else
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

class _LevelChoices extends StatelessWidget {
  const _LevelChoices({
    required this.levels,
    required this.selectedLevelIndex,
    required this.onSelectLevel,
  });

  final List<GateDashLevel> levels;
  final int selectedLevelIndex;
  final ValueChanged<int> onSelectLevel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < levels.length; index++)
          ChoiceChip(
            label: Text(levels[index].name),
            selected: index == selectedLevelIndex,
            onSelected: (_) => onSelectLevel(index),
          ),
      ],
    );
  }
}
