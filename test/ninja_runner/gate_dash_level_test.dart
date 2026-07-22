import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/data/sample_content_pack.dart';

void main() {
  test('sample levels define increasing speed and unlock requirements', () {
    final levels = sampleGateDashLevels();

    expect(levels.map((level) => level.name), [
      'Warm-Up Dash',
      'Quick Choice Dash',
      'Star Streak Challenge',
    ]);
    expect(levels.map((level) => level.runnerSpeed), [0.18, 0.24, 0.3]);
    expect(levels.map((level) => level.requiredScore), [0, 4, 5]);
    expect(
        levels.every((level) => level.contentPack.prompts.length == 5), isTrue);
  });

  test('level completion uses required score', () {
    final levels = sampleGateDashLevels();

    expect(levels[0].isComplete(0), isTrue);
    expect(levels[1].isComplete(3), isFalse);
    expect(levels[1].isComplete(4), isTrue);
    expect(levels[2].isComplete(4), isFalse);
    expect(levels[2].isComplete(5), isTrue);
  });
}
