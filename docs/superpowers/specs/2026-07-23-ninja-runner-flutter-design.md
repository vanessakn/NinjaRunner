# Ninja Runner Flutter Prototype Design

## Summary

Build a Flutter-only prototype of **Ninja Runner**, a short, replayable answer-gate learning game inspired by the KidNation Game Ideas Playbook. The prototype targets ages **5-8** and uses a single-runner lane: a KidNation character runs forward, receives a prompt, and chooses the correct answer gate.

The prototype may reuse **characters, themes, visual flavor, and event-pattern inspiration** from `miasstack/knsoccer`, but it must not reuse the KNSoccer game concept.

## Source Inputs

- `KidNation_Game_Ideas_Playbook.pdf`
  - First-build recommendation includes `Ninja Runner`.
  - Core principles: fun first, short and replayable, content-aware, age-adaptive, template-driven, character-rich.
  - System direction: a structured content pack should drive reusable mechanics.
- `miasstack/knsoccer`
  - Use only character names, KidNation Cup theme ingredients, country-flavored palettes, bright arcade presentation, celebration/audio mood, and analytics-style event naming.
  - Do not copy soccer match mechanics.

## Explicit KNSoccer Boundary

Allowed from KNSoccer:

- Characters: Jordan, Nari, Bjorn, Arjun.
- Thematic ingredients: KidNation Cup arena energy, country-opponent flavor such as Brazil, France, Argentina, and Portugal.
- Presentation inspiration: bright arcade colors, celebratory feedback, announcer-like copy, upbeat audio mood.
- Engineering pattern inspiration: analytics events that never interrupt play.

Not allowed from KNSoccer:

- No soccer match or 3v3 team-play concept.
- No dribbling, passing, shooting, tackling, blocking, headers, or goal-scoring objective.
- No copied soccer controls.
- No gameplay loop where KidNation competes in a soccer match against another team.

## Product Goals

- Prove the playbook's `Ninja Runner` mechanic as a reusable Flutter game template.
- Keep the first version small enough to build, test, and iterate quickly.
- Make the experience clear for ages 5-8 through large targets, simple prompts, readable text, and audio-ready copy.
- Shape the content as a JSON-like pack so future KidNation songs and videos can feed the same mechanic.

## Gameplay

The player starts a short round with one KidNation runner. A prompt appears, such as "Choose the helpful action" or "Find the word that means brave." The runner moves along a single lane toward two answer gates. The child taps or swipes toward the chosen gate before the runner reaches it.

Each round contains five prompts. Correct answers trigger a celebratory character reaction and award a star. Incorrect answers show a friendly correction, then quickly continue to the next prompt. At the end, the game shows score, best streak, and a play-again action.

## Sample Content Pack

The first pack should use KNSoccer cast and visual theme ingredients without becoming a soccer game:

- Characters: Jordan, Nari, Bjorn, Arjun.
- Themes: Brazil Arena, France Arena, Argentina Arena, Portugal Arena.
- Prompt categories: helpful actions, friendship words, character traits, simple vocabulary, listening comprehension.
- Example prompt:
  - prompt: "Choose the helpful action."
  - correct answer: "share"
  - distractor: "grab"
  - feedback: "Nice choice! Sharing helps your friends."

The content model should support:

- pack id and title
- age range
- theme id
- playable character id
- prompts
- answers and distractors
- short feedback
- optional image/audio asset ids for future use

## Architecture

Use a Flutter-only implementation for the first prototype.

Core modules:

- `ContentPack`: structured data for a generated game pack.
- `RunnerPrompt`: prompt, answer options, correct answer id, and feedback text.
- `RunnerGameState`: current prompt, score, streak, runner position, gate positions, round status, and timing.
- `RunnerController`: advances the game loop, handles gate selection, validates answers, and emits events.
- `RunnerPainter`: draws the field, runner, gates, prompt HUD, and feedback effects.
- `AnalyticsLogger`: records local event payloads and keeps analytics failures from affecting play.

Rendering should use `CustomPainter` and a `Ticker`-driven loop. This keeps the prototype lightweight while leaving room to migrate to Flame later if the broader KidNation game library needs a full game engine.

## Screens

1. Start screen
   - Shows game title, selected character, theme, and start button.
2. Active runner
   - Shows prompt, score progress, runner, and answer gates.
3. Feedback moment
   - Shows correct/incorrect response, short explanation, and reward animation.
4. Round summary
   - Shows score, streak, replay button, and next theme/character suggestion.

## Controls And Accessibility

- Tap a gate or swipe left/right to choose an answer.
- Use large answer gates and high-contrast text.
- Keep prompts short and readable for ages 5-8.
- Include audio-ready prompt and feedback fields in the data model, even if audio playback is not required in the first build.
- Support portrait and landscape layouts without overlapping HUD, runner, or gates.

## Analytics Events

Events should be local-only in the prototype:

- `game_ready`
- `round_start`
- `prompt_shown`
- `gate_selected`
- `answer_result`
- `round_complete`
- `game_error`

Payloads should avoid personal data and include only gameplay metadata such as pack id, prompt id, selected answer id, correctness, score, streak, and round duration.

## Error Handling

- If a content pack fails to load, show a friendly fallback state and emit `game_error`.
- If a prompt is malformed, skip it and continue when possible.
- Analytics errors must be swallowed after logging a safe internal status.
- The game should never crash because of missing optional image or audio asset ids.

## Testing

Add focused tests for:

- content pack parsing and validation
- correct answer detection
- score and streak updates
- round completion
- analytics payload shape
- widget smoke test for the app shell

## Out Of Scope For First Prototype

- Backend-generated content packs.
- Real audio recording or announcer clips.
- Production character art integration if assets require manual extraction.
- Flame migration.
- Persistent player profiles.
- App-store packaging.
- Any KNSoccer soccer-match mechanic.
