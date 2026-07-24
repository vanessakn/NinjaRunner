import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../audio/bubble_sound_player.dart';
import '../audio/spoken_prompt_reader.dart';
import '../data/sample_bubble_pack.dart';
import '../game/bubble_blast_controller.dart';
import '../rendering/bubble_blast_painter.dart';

class BubbleBlastScreen extends StatefulWidget {
  const BubbleBlastScreen({
    super.key,
    this.onAudioCue,
    this.spokenPromptReader,
  });

  final ValueChanged<BubbleAudioCue>? onAudioCue;
  final SpokenPromptReader? spokenPromptReader;

  @override
  State<BubbleBlastScreen> createState() => _BubbleBlastScreenState();
}

class _BubbleBlastScreenState extends State<BubbleBlastScreen>
    with SingleTickerProviderStateMixin {
  late final BubbleBlastController _controller;
  late final BubbleSoundPlayer _soundPlayer;
  late final SpokenPromptReader _spokenPromptReader;
  late final Ticker _ticker;
  Timer? _autoAdvanceTimer;
  Duration? _lastTick;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = BubbleBlastController(contentPack: sampleBubblePack());
    _soundPlayer = BubbleSoundPlayer();
    _spokenPromptReader = widget.spokenPromptReader ?? SpokenPromptReader();
    _ticker = createTicker(_handleTick)..start();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    unawaited(_soundPlayer.dispose());
    unawaited(_spokenPromptReader.stop());
    _ticker.dispose();
    super.dispose();
  }

  void _handleTick(Duration elapsed) {
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
      backgroundColor: const Color(0xFFB8F3FF),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              controller: _controller,
              isMuted: _isMuted,
              onToggleMute: _toggleMute,
              onReadPrompt: _readCurrentPrompt,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final playAreaSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) => _handleTap(
                      details.localPosition,
                      playAreaSize,
                    ),
                    child: CustomPaint(
                      painter: BubbleBlastPainter(
                        contentPack: _controller.contentPack,
                        state: state,
                        currentPrompt: _controller.currentPrompt,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              ),
            ),
            _Controls(
              controller: _controller,
              onStart: _startRound,
              onContinue: _continueAfterFeedback,
              onAnswer: _chooseBubble,
            ),
          ],
        ),
      ),
    );
  }

  void _startRound() {
    _autoAdvanceTimer?.cancel();
    setState(_controller.startRound);
    _emitAudioCue();
  }

  void _continueAfterFeedback() {
    _autoAdvanceTimer?.cancel();
    setState(_controller.continueAfterFeedback);
    _emitAudioCue();
  }

  void _handleTap(Offset position, Size playAreaSize) {
    if (_controller.state.phase != BubbleBlastPhase.playing) {
      return;
    }
    final answerId = _controller.answerIdAt(position, playAreaSize);
    if (answerId != null) {
      _chooseBubble(answerId);
    }
  }

  void _chooseBubble(String answerId) {
    if (_controller.state.phase != BubbleBlastPhase.playing) {
      return;
    }
    _autoAdvanceTimer?.cancel();
    setState(() {
      _controller.selectBubble(answerId);
    });
    _emitAudioCue();
    _scheduleFeedbackAdvance();
  }

  void _scheduleFeedbackAdvance() {
    if (_controller.state.phase != BubbleBlastPhase.feedback) {
      return;
    }
    _autoAdvanceTimer = Timer(_controller.feedbackAutoAdvanceDelay, () {
      if (!mounted || _controller.state.phase != BubbleBlastPhase.feedback) {
        return;
      }
      setState(_controller.continueAfterFeedback);
      _emitAudioCue();
    });
  }

  void _emitAudioCue() {
    final cue = _controller.state.audioCue;
    if (cue != null) {
      widget.onAudioCue?.call(cue);
      unawaited(_soundPlayer.playCue(cue));
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _soundPlayer.isMuted = _isMuted;
      _spokenPromptReader.isMuted = _isMuted;
    });
  }

  void _readCurrentPrompt() {
    final prompt = _controller.currentPrompt;
    unawaited(_spokenPromptReader.speak(prompt.spokenPrompt ?? prompt.prompt));
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.isMuted,
    required this.onToggleMute,
    required this.onReadPrompt,
  });

  final BubbleBlastController controller;
  final bool isMuted;
  final VoidCallback onToggleMute;
  final VoidCallback onReadPrompt;

  @override
  Widget build(BuildContext context) {
    final pack = controller.contentPack;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KidNation Bubble Blast',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  pack.character.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  '${pack.theme.name} - ${pack.ageRangeLabel} - '
                  'Level ${controller.currentPrompt.level}',
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
          IconButton(
            tooltip: 'Read prompt',
            onPressed: isMuted ? null : onReadPrompt,
            icon: const Icon(Icons.record_voice_over_rounded),
          ),
          IconButton(
            tooltip: isMuted ? 'Unmute sounds' : 'Mute sounds',
            onPressed: onToggleMute,
            icon: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
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

  final BubbleBlastController controller;
  final VoidCallback onStart;
  final VoidCallback onContinue;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: switch (state.phase) {
        BubbleBlastPhase.ready => FilledButton(
            onPressed: onStart,
            child: const Text('Start Popping'),
          ),
        BubbleBlastPhase.playing => Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for (final bubble in controller.visibleBubbles)
                FilledButton(
                  onPressed: () => onAnswer(bubble.answer.id),
                  child: Text(bubble.answer.label),
                ),
            ],
          ),
        BubbleBlastPhase.feedback => FilledButton(
            onPressed: onContinue,
            child: const Text('Next Bubble'),
          ),
        BubbleBlastPhase.levelComplete => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Level ${state.completedLevel} complete',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: onContinue,
                child: const Text('Next Level'),
              ),
            ],
          ),
        BubbleBlastPhase.summary => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bubble score: ${state.score}/'
                '${controller.contentPack.prompts.length}',
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
      },
    );
  }
}
