import 'package:shared_preferences/shared_preferences.dart';

abstract class LevelProgressStore {
  Future<int> loadHighestUnlockedLevelIndex();

  Future<void> saveHighestUnlockedLevelIndex(int index);

  Future<Map<String, int>> loadBestScoresByLevelId();

  Future<void> saveBestScore({
    required String levelId,
    required int score,
  });
}

class SharedPreferencesLevelProgressStore implements LevelProgressStore {
  SharedPreferencesLevelProgressStore({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _highestUnlockedLevelKey =
      'ninja_runner_highest_unlocked_level_index';
  static const _bestScoreKeyPrefix = 'ninja_runner_best_score_';

  final SharedPreferencesAsync _preferences;

  @override
  Future<int> loadHighestUnlockedLevelIndex() async {
    final savedIndex = await _preferences.getInt(_highestUnlockedLevelKey);
    if (savedIndex == null || savedIndex < 0) {
      return 0;
    }
    return savedIndex;
  }

  @override
  Future<void> saveHighestUnlockedLevelIndex(int index) {
    return _preferences.setInt(
      _highestUnlockedLevelKey,
      index < 0 ? 0 : index,
    );
  }

  @override
  Future<Map<String, int>> loadBestScoresByLevelId() async {
    final keys = await _preferences.getKeys();
    final scores = <String, int>{};
    for (final key in keys) {
      if (!key.startsWith(_bestScoreKeyPrefix)) {
        continue;
      }
      final score = await _preferences.getInt(key);
      if (score != null && score >= 0) {
        scores[key.substring(_bestScoreKeyPrefix.length)] = score;
      }
    }
    return scores;
  }

  @override
  Future<void> saveBestScore({
    required String levelId,
    required int score,
  }) {
    return _preferences.setInt(
      '$_bestScoreKeyPrefix$levelId',
      score < 0 ? 0 : score,
    );
  }
}

class MemoryLevelProgressStore implements LevelProgressStore {
  MemoryLevelProgressStore({
    int initialHighestUnlockedLevelIndex = 0,
    Map<String, int> initialBestScoresByLevelId = const {},
  })  : highestUnlockedLevelIndex = initialHighestUnlockedLevelIndex,
        bestScoresByLevelId = Map.of(initialBestScoresByLevelId);

  int highestUnlockedLevelIndex;
  final Map<String, int> bestScoresByLevelId;

  @override
  Future<int> loadHighestUnlockedLevelIndex() async {
    return highestUnlockedLevelIndex;
  }

  @override
  Future<void> saveHighestUnlockedLevelIndex(int index) async {
    highestUnlockedLevelIndex = index;
  }

  @override
  Future<Map<String, int>> loadBestScoresByLevelId() async {
    return Map.of(bestScoresByLevelId);
  }

  @override
  Future<void> saveBestScore({
    required String levelId,
    required int score,
  }) async {
    bestScoresByLevelId[levelId] = score;
  }
}
