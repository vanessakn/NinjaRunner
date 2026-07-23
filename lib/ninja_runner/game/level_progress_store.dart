import 'package:shared_preferences/shared_preferences.dart';

abstract class LevelProgressStore {
  Future<int> loadHighestUnlockedLevelIndex();

  Future<void> saveHighestUnlockedLevelIndex(int index);
}

class SharedPreferencesLevelProgressStore implements LevelProgressStore {
  SharedPreferencesLevelProgressStore({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _highestUnlockedLevelKey =
      'ninja_runner_highest_unlocked_level_index';

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
}

class MemoryLevelProgressStore implements LevelProgressStore {
  MemoryLevelProgressStore({
    int initialHighestUnlockedLevelIndex = 0,
  }) : highestUnlockedLevelIndex = initialHighestUnlockedLevelIndex;

  int highestUnlockedLevelIndex;

  @override
  Future<int> loadHighestUnlockedLevelIndex() async {
    return highestUnlockedLevelIndex;
  }

  @override
  Future<void> saveHighestUnlockedLevelIndex(int index) async {
    highestUnlockedLevelIndex = index;
  }
}
