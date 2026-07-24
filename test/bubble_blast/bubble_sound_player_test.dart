import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/bubble_blast/audio/bubble_sound_player.dart';
import 'package:kidnation_mobile_games/bubble_blast/game/bubble_blast_controller.dart';

class FakeSoundAssetPlayer implements SoundAssetPlayer {
  final playedAssets = <String>[];

  @override
  Future<void> play(String assetPath) async {
    playedAssets.add(assetPath);
  }
}

void main() {
  test('maps BubbleAudioCue values to sound assets', () {
    expect(
      BubbleSoundPlayer.assetForCue(BubbleAudioCue.roundStart),
      'audio/bubble_blast/round_start.wav',
    );
    expect(
      BubbleSoundPlayer.assetForCue(BubbleAudioCue.correctPop),
      'audio/bubble_blast/correct_pop.wav',
    );
    expect(
      BubbleSoundPlayer.assetForCue(BubbleAudioCue.wrongBubble),
      'audio/bubble_blast/wrong_bubble.wav',
    );
    expect(
      BubbleSoundPlayer.assetForCue(BubbleAudioCue.levelComplete),
      'audio/bubble_blast/level_complete.wav',
    );
    expect(
      BubbleSoundPlayer.assetForCue(BubbleAudioCue.roundComplete),
      'audio/bubble_blast/round_complete.wav',
    );
  });

  test('plays the asset for a cue when unmuted', () async {
    final fakePlayer = FakeSoundAssetPlayer();
    final soundPlayer = BubbleSoundPlayer(assetPlayer: fakePlayer);

    await soundPlayer.playCue(BubbleAudioCue.correctPop);

    expect(fakePlayer.playedAssets, ['audio/bubble_blast/correct_pop.wav']);
  });

  test('does not play cues while muted', () async {
    final fakePlayer = FakeSoundAssetPlayer();
    final soundPlayer = BubbleSoundPlayer(assetPlayer: fakePlayer)
      ..isMuted = true;

    await soundPlayer.playCue(BubbleAudioCue.correctPop);

    expect(fakePlayer.playedAssets, isEmpty);
  });
}
