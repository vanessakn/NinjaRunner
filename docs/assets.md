# Ninja Runner Asset Pipeline

The game now supports optional image assets while preserving the current
painted placeholder fallback.

## Folders

```text
assets/characters/
assets/backgrounds/
assets/effects/
```

## Character Files

These files are optional. If a file is missing, the game uses the painted
placeholder runner.

```text
assets/characters/jordan.png
assets/characters/jordan-purple.png
assets/characters/nari.png
assets/characters/arjun.png
assets/characters/bjorn.png
```

Recommended character art: transparent PNG, portrait/full-body runner, centered
in the image.

The current character files are first-pass prototype cuts from supplied art.
They are suitable for visual playtesting, but should be replaced with clean
production exports when final KidNation art is available. Jordan currently uses
the newer purple-kit full-body artwork with its background removed at
`assets/characters/jordan-purple.png`. The original `jordan.png` prototype is
kept only as an older reference.

## Background Files

These files are optional. If a file is missing, the game uses the painted arena
placeholder.

```text
assets/backgrounds/brazil_arena.png
assets/backgrounds/france_arena.png
assets/backgrounds/portugal_arena.png
assets/backgrounds/argentina_arena.png
```

Recommended background art: wide PNG that can crop safely with `BoxFit.cover`.
Keep important details away from the edges.

## Mapping

Asset IDs from `lib/ninja_runner/data/sample_content_pack.dart` are resolved in
`lib/ninja_runner/rendering/runner_asset_resolver.dart`.

Add new character or theme files by:

1. Adding the image file to the matching asset folder.
2. Adding the asset ID to `RunnerAssetResolver`.
3. Adding or updating resolver tests.
4. Running `flutter test` and `flutter build web`.
