import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/rendering/runner_asset_resolver.dart';

void main() {
  test('maps known placeholder character ids to future asset paths', () {
    expect(
      RunnerAssetResolver.characterPath('character-jordan-placeholder'),
      'assets/characters/jordan.png',
    );
    expect(
      RunnerAssetResolver.characterPath('character-nari-placeholder'),
      'assets/characters/nari.png',
    );
    expect(
      RunnerAssetResolver.characterPath('character-arjun-placeholder'),
      'assets/characters/arjun.png',
    );
    expect(
      RunnerAssetResolver.characterPath('character-bjorn-placeholder'),
      'assets/characters/bjorn.png',
    );
  });

  test('maps known placeholder theme ids to future background paths', () {
    expect(
      RunnerAssetResolver.backgroundPath('theme-brazil-arena-placeholder'),
      'assets/backgrounds/brazil_arena.png',
    );
    expect(
      RunnerAssetResolver.backgroundPath('theme-france-arena-placeholder'),
      'assets/backgrounds/france_arena.png',
    );
    expect(
      RunnerAssetResolver.backgroundPath('theme-portugal-arena-placeholder'),
      'assets/backgrounds/portugal_arena.png',
    );
    expect(
      RunnerAssetResolver.backgroundPath('theme-argentina-arena-placeholder'),
      'assets/backgrounds/argentina_arena.png',
    );
  });

  test('returns null for missing asset ids so painter fallback can render', () {
    expect(RunnerAssetResolver.characterPath(null), isNull);
    expect(RunnerAssetResolver.characterPath('unknown'), isNull);
    expect(RunnerAssetResolver.backgroundPath(null), isNull);
    expect(RunnerAssetResolver.backgroundPath('unknown'), isNull);
  });
}
