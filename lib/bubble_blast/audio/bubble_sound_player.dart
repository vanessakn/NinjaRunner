import 'package:audioplayers/audioplayers.dart';

import '../game/bubble_blast_controller.dart';

abstract class SoundAssetPlayer {
  Future<void> play(String assetPath);
}

class AudioPlayersSoundAssetPlayer implements SoundAssetPlayer {
  AudioPlayersSoundAssetPlayer({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> play(String assetPath) async {
    await _player.stop();
    await _player.play(AssetSource(assetPath));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

class BubbleSoundPlayer {
  BubbleSoundPlayer({SoundAssetPlayer? assetPlayer})
      : _assetPlayer = assetPlayer ?? AudioPlayersSoundAssetPlayer();

  final SoundAssetPlayer _assetPlayer;
  bool isMuted = false;

  static String assetForCue(BubbleAudioCue cue) {
    return switch (cue) {
      BubbleAudioCue.roundStart => 'audio/bubble_blast/round_start.wav',
      BubbleAudioCue.correctPop => 'audio/bubble_blast/correct_pop.wav',
      BubbleAudioCue.wrongBubble => 'audio/bubble_blast/wrong_bubble.wav',
      BubbleAudioCue.levelComplete => 'audio/bubble_blast/level_complete.wav',
      BubbleAudioCue.roundComplete => 'audio/bubble_blast/round_complete.wav',
    };
  }

  Future<void> playCue(BubbleAudioCue cue) async {
    if (isMuted) {
      return;
    }
    await _assetPlayer.play(assetForCue(cue));
  }

  Future<void> dispose() async {
    final player = _assetPlayer;
    if (player is AudioPlayersSoundAssetPlayer) {
      await player.dispose();
    }
  }
}
