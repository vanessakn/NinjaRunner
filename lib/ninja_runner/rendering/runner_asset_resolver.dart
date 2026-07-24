class RunnerAssetResolver {
  const RunnerAssetResolver._();

  static String? characterPath(String? portraitAssetId) {
    return switch (portraitAssetId) {
      'character-jordan-placeholder' => 'assets/characters/jordan-runner.png',
      'character-nari-placeholder' => 'assets/characters/nari.png',
      'character-arjun-placeholder' => 'assets/characters/arjun.png',
      'character-bjorn-placeholder' => 'assets/characters/bjorn.png',
      _ => null,
    };
  }

  static String? backgroundPath(String? backgroundAssetId) {
    return switch (backgroundAssetId) {
      'theme-brazil-arena-placeholder' => 'assets/backgrounds/brazil_arena.png',
      'theme-france-arena-placeholder' => 'assets/backgrounds/france_arena.png',
      'theme-portugal-arena-placeholder' =>
        'assets/backgrounds/portugal_arena.png',
      'theme-argentina-arena-placeholder' =>
        'assets/backgrounds/argentina_arena.png',
      _ => null,
    };
  }
}
