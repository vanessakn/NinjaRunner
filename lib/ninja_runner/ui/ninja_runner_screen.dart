import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import '../analytics/analytics_logger.dart';
import '../data/sample_content_pack.dart';
import '../game/level_progress_store.dart';
import '../game/runner_controller.dart';
import '../models/ninja_runner_level.dart';
import '../rendering/runner_asset_resolver.dart';
import '../rendering/runner_painter.dart';

class NinjaRunnerScreen extends StatefulWidget {
  const NinjaRunnerScreen({
    super.key,
    this.progressStore,
    this.feedbackEffects,
  });

  final LevelProgressStore? progressStore;
  final RunnerFeedbackEffects? feedbackEffects;

  @override
  State<NinjaRunnerScreen> createState() => _NinjaRunnerScreenState();
}

class _NinjaRunnerScreenState extends State<NinjaRunnerScreen>
    with SingleTickerProviderStateMixin {
  late final List<NinjaRunnerLevel> _levels;
  late RunnerController _controller;
  late final Ticker _ticker;
  late final LevelProgressStore _progressStore;
  late final RunnerFeedbackEffects _feedbackEffects;
  _LoadedRunnerAssets _loadedAssets = const _LoadedRunnerAssets();
  var _selectedLevelIndex = 0;
  var _highestUnlockedLevelIndex = 0;
  var _bestScoresByLevelId = <String, int>{};
  var _feedbackRunCycleProgress = 0.0;
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _levels = sampleNinjaRunnerLevels();
    _progressStore =
        widget.progressStore ?? SharedPreferencesLevelProgressStore();
    _feedbackEffects =
        widget.feedbackEffects ?? PlatformRunnerFeedbackEffects();
    _controller = _createController(_levels[_selectedLevelIndex]);
    _ticker = createTicker(_handleTick);
    _restoreProgress();
    _loadVisualAssetsForCurrentLevel();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleTick(Duration elapsed) {
    if (_controller.state.phase != RunnerPhase.running &&
        _controller.state.phase != RunnerPhase.feedback) {
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
      if (_controller.state.phase == RunnerPhase.running) {
        _controller.tick(delta);
      } else {
        _feedbackRunCycleProgress =
            (_feedbackRunCycleProgress + delta).clamp(0, 0.55).toDouble();
      }
    });
    if (_controller.state.phase == RunnerPhase.feedback &&
        _feedbackRunCycleProgress >= 0.55) {
      _stopTicker();
    }
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
                _Header(
                  controller: _controller,
                  levelNumber: _selectedLevelIndex + 1,
                ),
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
                      key: const Key('runner-playfield'),
                      painter: RunnerPainter(
                        contentPack: _controller.contentPack,
                        state: state,
                        currentPrompt: _controller.currentPrompt,
                        runnerImage: _loadedAssets.runnerImage,
                        backgroundImage: _loadedAssets.backgroundImage,
                        visualRunCycleProgress: _feedbackRunCycleProgress,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                _Controls(
                  controller: _controller,
                  levels: _levels,
                  selectedLevelIndex: _selectedLevelIndex,
                  highestUnlockedLevelIndex: _highestUnlockedLevelIndex,
                  bestScoresByLevelId: _bestScoresByLevelId,
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
    setState(() {
      _feedbackRunCycleProgress = 0;
      _controller.startRound();
    });
    _feedbackEffects.playRoundStart();
    _startTicker();
  }

  void _selectLevel(int index) {
    if (_controller.state.phase != RunnerPhase.ready) {
      return;
    }
    if (index > _highestUnlockedLevelIndex) {
      return;
    }
    setState(() {
      _selectedLevelIndex = index;
      _feedbackRunCycleProgress = 0;
      _controller = _createController(_levels[index]);
      _loadedAssets = const _LoadedRunnerAssets();
    });
    _loadVisualAssetsForCurrentLevel();
  }

  void _continueAfterFeedback() {
    final wasRunning = _controller.state.phase == RunnerPhase.feedback;
    setState(() {
      _feedbackRunCycleProgress = 0;
      _controller.continueAfterFeedback();
    });
    if (wasRunning && _controller.state.phase == RunnerPhase.summary) {
      _saveBestScoreForCurrentLevel();
      if (_controller.isLevelComplete) {
        _feedbackEffects.playLevelComplete();
      }
    }
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
    _chooseAnswer(position.dx < width / 2 ? 0 : 1);
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
      _feedbackRunCycleProgress = 0;
      final result = _controller.selectAnswer(answers[index].id);
      if (result.isCorrect) {
        _feedbackEffects.playCorrectAnswer();
      } else {
        _feedbackEffects.playWrongAnswer();
      }
    });
    if (_controller.state.phase == RunnerPhase.feedback) {
      _startTicker();
    } else if (_controller.state.phase != RunnerPhase.running) {
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
      _highestUnlockedLevelIndex = _highestUnlockedLevelIndex < nextIndex
          ? nextIndex
          : _highestUnlockedLevelIndex;
      _selectedLevelIndex = nextIndex;
      _feedbackRunCycleProgress = 0;
      _controller = _createController(_levels[nextIndex]);
      _loadedAssets = const _LoadedRunnerAssets();
      _controller.startRound();
    });
    _loadVisualAssetsForCurrentLevel();
    _progressStore.saveHighestUnlockedLevelIndex(_highestUnlockedLevelIndex);
    _startTicker();
  }

  Future<void> _restoreProgress() async {
    final savedIndex = await _progressStore.loadHighestUnlockedLevelIndex();
    final bestScores = await _progressStore.loadBestScoresByLevelId();
    if (!mounted) {
      return;
    }
    setState(() {
      _highestUnlockedLevelIndex = savedIndex.clamp(0, _levels.length - 1);
      _bestScoresByLevelId = bestScores;
    });
  }

  void _saveBestScoreForCurrentLevel() {
    final levelId = _controller.level.id;
    final score = _controller.state.score;
    final bestScore = _bestScoresByLevelId[levelId] ?? 0;
    if (score <= bestScore) {
      return;
    }
    setState(() {
      _bestScoresByLevelId = {
        ..._bestScoresByLevelId,
        levelId: score,
      };
    });
    _progressStore.saveBestScore(levelId: levelId, score: score);
  }

  RunnerController _createController(NinjaRunnerLevel level) {
    return RunnerController(
      level: level,
      analyticsLogger: AnalyticsLogger(),
    );
  }

  Future<void> _loadVisualAssetsForCurrentLevel() async {
    final level = _controller.level;
    final runnerPath = RunnerAssetResolver.characterPath(
      level.contentPack.runner.portraitAssetId,
    );
    final backgroundPath = RunnerAssetResolver.backgroundPath(
      level.contentPack.theme.backgroundAssetId,
    );
    final runnerImage = await _loadOptionalImage(runnerPath);
    final backgroundImage = await _loadOptionalImage(backgroundPath);
    if (!mounted || level.id != _controller.level.id) {
      return;
    }
    setState(() {
      _loadedAssets = _LoadedRunnerAssets(
        runnerImage: runnerImage,
        backgroundImage: backgroundImage,
      );
    });
  }

  Future<ui.Image?> _loadOptionalImage(String? assetPath) async {
    if (assetPath == null) {
      return null;
    }
    try {
      final data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    } on FlutterError {
      return null;
    }
  }
}

class _LoadedRunnerAssets {
  const _LoadedRunnerAssets({
    this.runnerImage,
    this.backgroundImage,
  });

  final ui.Image? runnerImage;
  final ui.Image? backgroundImage;
}

abstract class RunnerFeedbackEffects {
  void playRoundStart();

  void playCorrectAnswer();

  void playWrongAnswer();

  void playLevelComplete();
}

class PlatformRunnerFeedbackEffects implements RunnerFeedbackEffects {
  @override
  void playRoundStart() {
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
  }

  @override
  void playCorrectAnswer() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  @override
  void playWrongAnswer() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  @override
  void playLevelComplete() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.levelNumber,
  });

  final RunnerController controller;
  final int levelNumber;

  @override
  Widget build(BuildContext context) {
    final pack = controller.contentPack;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
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
                const SizedBox(height: 2),
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    Text('Level $levelNumber'),
                    Text(
                      'Runner Mode',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(pack.runner.name),
                  ],
                ),
                Text(
                  'Help ${pack.runner.name} choose the kind gate.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    Text('${controller.level.name} - ${pack.theme.name}'),
                    Text('${pack.prompts.length} quick choices'),
                    Text(pack.ageRangeLabel),
                  ],
                ),
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
    required this.highestUnlockedLevelIndex,
    required this.bestScoresByLevelId,
    required this.onStart,
    required this.onContinue,
    required this.onAnswer,
    required this.onSelectLevel,
    required this.onNextLevel,
  });

  final RunnerController controller;
  final List<NinjaRunnerLevel> levels;
  final int selectedLevelIndex;
  final int highestUnlockedLevelIndex;
  final Map<String, int> bestScoresByLevelId;
  final VoidCallback onStart;
  final VoidCallback onContinue;
  final ValueChanged<int> onAnswer;
  final ValueChanged<int> onSelectLevel;
  final VoidCallback onNextLevel;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: switch (state.phase) {
        RunnerPhase.ready => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LevelChoices(
                levels: levels,
                selectedLevelIndex: selectedLevelIndex,
                highestUnlockedLevelIndex: highestUnlockedLevelIndex,
                bestScoresByLevelId: bestScoresByLevelId,
                onSelectLevel: onSelectLevel,
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: onStart,
                child: const Text('Start Run'),
              ),
            ],
          ),
        RunnerPhase.running => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose a gate',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Run up the lane',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Collect stars by choosing kind gates',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Streak ${state.streak}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => onAnswer(0),
                      icon: const Icon(Icons.keyboard_arrow_left_rounded),
                      label: Text(controller.currentPrompt.answers[0].label),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => onAnswer(1),
                      icon: const Icon(Icons.keyboard_arrow_right_rounded),
                      label: Text(controller.currentPrompt.answers[1].label),
                    ),
                  ),
                ],
              ),
            ],
          ),
        RunnerPhase.feedback => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.lastResult?.isCorrect == true
                    ? 'Streak Boost!'
                    : 'Slow down and try again',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                _feedbackDetail(controller),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Streak ${state.streak}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: onContinue,
                child: const Text('Keep Running'),
              ),
            ],
          ),
        RunnerPhase.summary => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                controller.roundResultTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              if (controller.roundResultTitle != 'Level Complete!' &&
                  controller.isLevelComplete)
                Text(
                  'Level Complete!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              Text(
                'Score: ${state.score}/${controller.contentPack.prompts.length} '
                '- Need ${controller.level.requiredScore}',
                textAlign: TextAlign.center,
              ),
              Text(
                'Best: ${bestScoresByLevelId[controller.level.id] ?? state.score}'
                '/${controller.contentPack.prompts.length}',
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

  String _feedbackDetail(RunnerController controller) {
    final result = controller.state.lastResult;
    if (result == null) {
      return '';
    }
    if (result.isCorrect) {
      return '+1 star';
    }
    return 'Correct gate: ${controller.currentPrompt.correctAnswer.label}';
  }
}

class _LevelChoices extends StatelessWidget {
  const _LevelChoices({
    required this.levels,
    required this.selectedLevelIndex,
    required this.highestUnlockedLevelIndex,
    required this.bestScoresByLevelId,
    required this.onSelectLevel,
  });

  final List<NinjaRunnerLevel> levels;
  final int selectedLevelIndex;
  final int highestUnlockedLevelIndex;
  final Map<String, int> bestScoresByLevelId;
  final ValueChanged<int> onSelectLevel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < levels.length; index++) ...[
            Padding(
              padding:
                  EdgeInsets.only(right: index == levels.length - 1 ? 0 : 8),
              child: _LevelChoice(
                level: levels[index],
                isSelected: index == selectedLevelIndex,
                isUnlocked: index <= highestUnlockedLevelIndex,
                bestScore: bestScoresByLevelId[levels[index].id],
                onSelect: () => onSelectLevel(index),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LevelChoice extends StatelessWidget {
  const _LevelChoice({
    required this.level,
    required this.isSelected,
    required this.isUnlocked,
    required this.bestScore,
    required this.onSelect,
  });

  final NinjaRunnerLevel level;
  final bool isSelected;
  final bool isUnlocked;
  final int? bestScore;
  final VoidCallback onSelect;

  bool get isComplete => bestScore != null && level.isComplete(bestScore!);

  @override
  Widget build(BuildContext context) {
    final status = isUnlocked
        ? isComplete
            ? 'Complete'
            : 'Unlocked'
        : 'Locked';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 166,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.white.withValues(alpha: 0.64),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFF151515).withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChoiceChip(
                  label: Text(level.name),
                  selected: isSelected,
                  onSelected: isUnlocked ? (_) => onSelect() : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Text(
                  status,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (bestScore != null)
                  Text(
                    'Best: $bestScore/${level.contentPack.prompts.length}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
