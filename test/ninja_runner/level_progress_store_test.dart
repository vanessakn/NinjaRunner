import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/game/level_progress_store.dart';

void main() {
  test('memory progress store restores best scores defensively', () async {
    final store = MemoryLevelProgressStore(
      initialHighestUnlockedLevelIndex: 2,
      initialBestScoresByLevelId: {'warm-up-dash': 5},
    );

    final scores = await store.loadBestScoresByLevelId();
    scores['warm-up-dash'] = 1;

    expect(await store.loadHighestUnlockedLevelIndex(), 2);
    expect(await store.loadBestScoresByLevelId(), {'warm-up-dash': 5});
  });

  test('memory progress store saves best scores by level id', () async {
    final store = MemoryLevelProgressStore();

    await store.saveBestScore(levelId: 'quick-choice-dash', score: 4);

    expect(await store.loadBestScoresByLevelId(), {'quick-choice-dash': 4});
  });
}
