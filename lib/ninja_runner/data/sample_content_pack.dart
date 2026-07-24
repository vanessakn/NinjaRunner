import '../models/content_pack.dart';
import '../models/ninja_runner_level.dart';

List<NinjaRunnerLevel> sampleNinjaRunnerLevels() {
  return [
    NinjaRunnerLevel(
      id: 'warm-up-dash',
      name: 'Warm-Up Dash',
      runnerSpeed: 0.1,
      requiredScore: 0,
      contentPack: sampleContentPack(),
    ),
    NinjaRunnerLevel(
      id: 'quick-choice-dash',
      name: 'Quick Choice Dash',
      runnerSpeed: 0.125,
      requiredScore: 4,
      contentPack: _quickChoicePack(),
    ),
    NinjaRunnerLevel(
      id: 'star-streak-challenge',
      name: 'Star Streak Challenge',
      runnerSpeed: 0.15,
      requiredScore: 5,
      contentPack: _starStreakPack(),
    ),
    NinjaRunnerLevel(
      id: 'friendship-focus-dash',
      name: 'Friendship Focus Dash',
      runnerSpeed: 0.175,
      requiredScore: 5,
      contentPack: _friendshipFocusPack(),
    ),
  ];
}

ContentPack sampleContentPack() {
  return ContentPack.fromJson({
    'id': 'kidnation-cup-kindness-run',
    'title': 'KidNation Cup Kindness Run',
    'minAge': 5,
    'maxAge': 8,
    'theme': {
      'id': 'brazil-arena',
      'name': 'Brazil Arena',
      'primaryColor': 0xFF1BAA5D,
      'secondaryColor': 0xFFFFD23F,
      'backgroundAssetId': 'theme-brazil-arena-placeholder',
    },
    'runner': {
      'id': 'jordan',
      'name': 'Jordan',
      'portraitAssetId': 'character-jordan-placeholder',
    },
    'prompts': [
      {
        'id': 'helpful-action',
        'prompt': 'Choose the helpful action.',
        'correctAnswerId': 'share',
        'feedback': 'Nice choice! Sharing helps your friends.',
        'answers': [
          {'id': 'share', 'label': 'share'},
          {'id': 'grab', 'label': 'grab'},
        ],
      },
      {
        'id': 'kind-word',
        'prompt': 'Find the kind word.',
        'correctAnswerId': 'gentle',
        'feedback': 'Gentle words can make someone feel safe.',
        'answers': [
          {'id': 'gentle', 'label': 'gentle'},
          {'id': 'bossy', 'label': 'bossy'},
        ],
      },
      {
        'id': 'brave-choice',
        'prompt': 'Which choice shows bravery?',
        'correctAnswerId': 'try',
        'feedback': 'Trying again is a brave choice.',
        'answers': [
          {'id': 'try', 'label': 'try again'},
          {'id': 'hide', 'label': 'hide forever'},
        ],
      },
      {
        'id': 'friendship-listening',
        'prompt': 'What should Jordan do first?',
        'correctAnswerId': 'listen',
        'feedback': 'Listening first helps friends understand each other.',
        'answers': [
          {'id': 'listen', 'label': 'listen'},
          {'id': 'interrupt', 'label': 'interrupt'},
        ],
      },
      {
        'id': 'team-celebration',
        'prompt': 'Pick the friendly celebration.',
        'correctAnswerId': 'cheer',
        'feedback': 'Cheering for others makes the group stronger.',
        'answers': [
          {'id': 'cheer', 'label': 'cheer'},
          {'id': 'tease', 'label': 'tease'},
        ],
      },
    ],
  });
}

ContentPack _quickChoicePack() {
  return ContentPack.fromJson({
    'id': 'kidnation-cup-quick-choice',
    'title': 'KidNation Cup Quick Choice',
    'minAge': 5,
    'maxAge': 8,
    'theme': {
      'id': 'france-arena',
      'name': 'France Arena',
      'primaryColor': 0xFF2867D4,
      'secondaryColor': 0xFFFFFFFF,
      'backgroundAssetId': 'theme-france-arena-placeholder',
    },
    'runner': {
      'id': 'nari',
      'name': 'Nari',
      'portraitAssetId': 'character-nari-placeholder',
    },
    'prompts': [
      {
        'id': 'calm-choice',
        'prompt': 'Choose the calm choice.',
        'correctAnswerId': 'breathe',
        'feedback': 'A deep breath can help your body slow down.',
        'answers': [
          {'id': 'breathe', 'label': 'breathe'},
          {'id': 'shout', 'label': 'shout'},
        ],
      },
      {
        'id': 'help-a-friend',
        'prompt': 'What helps a friend feel included?',
        'correctAnswerId': 'invite',
        'feedback': 'Inviting someone in helps them feel welcome.',
        'answers': [
          {'id': 'invite', 'label': 'invite'},
          {'id': 'ignore', 'label': 'ignore'},
        ],
      },
      {
        'id': 'try-new-thing',
        'prompt': 'Pick the brave thought.',
        'correctAnswerId': 'practice',
        'feedback': 'Practice helps new things feel easier.',
        'answers': [
          {'id': 'practice', 'label': 'I can practice'},
          {'id': 'quit', 'label': 'I quit'},
        ],
      },
      {
        'id': 'fair-choice',
        'prompt': 'Choose the fair choice.',
        'correctAnswerId': 'take-turns',
        'feedback': 'Taking turns gives everyone a chance.',
        'answers': [
          {'id': 'take-turns', 'label': 'take turns'},
          {'id': 'keep-all', 'label': 'keep all'},
        ],
      },
      {
        'id': 'listen-close',
        'prompt': 'What shows good listening?',
        'correctAnswerId': 'look',
        'feedback': 'Looking and listening helps you understand.',
        'answers': [
          {'id': 'look', 'label': 'look and listen'},
          {'id': 'wander', 'label': 'wander away'},
        ],
      },
    ],
  });
}

ContentPack _starStreakPack() {
  return ContentPack.fromJson({
    'id': 'kidnation-cup-star-streak',
    'title': 'KidNation Cup Star Streak',
    'minAge': 5,
    'maxAge': 8,
    'theme': {
      'id': 'portugal-arena',
      'name': 'Portugal Arena',
      'primaryColor': 0xFFE53B44,
      'secondaryColor': 0xFF2AA757,
      'backgroundAssetId': 'theme-portugal-arena-placeholder',
    },
    'runner': {
      'id': 'arjun',
      'name': 'Arjun',
      'portraitAssetId': 'character-arjun-placeholder',
    },
    'prompts': [
      {
        'id': 'kind-repair',
        'prompt': 'Which words help repair a mistake?',
        'correctAnswerId': 'sorry',
        'feedback': 'Saying sorry can help repair hurt feelings.',
        'answers': [
          {'id': 'sorry', 'label': 'I am sorry'},
          {'id': 'whatever', 'label': 'whatever'},
        ],
      },
      {
        'id': 'patient-choice',
        'prompt': 'Choose the patient choice.',
        'correctAnswerId': 'wait',
        'feedback': 'Waiting calmly can be a strong choice.',
        'answers': [
          {'id': 'wait', 'label': 'wait calmly'},
          {'id': 'push', 'label': 'push ahead'},
        ],
      },
      {
        'id': 'notice-feelings',
        'prompt': 'What helps you notice feelings?',
        'correctAnswerId': 'ask',
        'feedback': 'Asking kindly helps you learn how someone feels.',
        'answers': [
          {'id': 'ask', 'label': 'ask kindly'},
          {'id': 'guess', 'label': 'guess loudly'},
        ],
      },
      {
        'id': 'share-space',
        'prompt': 'Pick the respectful action.',
        'correctAnswerId': 'make-room',
        'feedback': 'Making room shows respect for others.',
        'answers': [
          {'id': 'make-room', 'label': 'make room'},
          {'id': 'crowd', 'label': 'crowd in'},
        ],
      },
      {
        'id': 'encourage',
        'prompt': 'Choose the encouraging words.',
        'correctAnswerId': 'you-can',
        'feedback': 'Encouraging words can help friends keep trying.',
        'answers': [
          {'id': 'you-can', 'label': 'you can do it'},
          {'id': 'too-hard', 'label': 'too hard'},
        ],
      },
    ],
  });
}

ContentPack _friendshipFocusPack() {
  return ContentPack.fromJson({
    'id': 'kidnation-cup-friendship-focus',
    'title': 'KidNation Cup Friendship Focus',
    'minAge': 5,
    'maxAge': 8,
    'theme': {
      'id': 'argentina-arena',
      'name': 'Argentina Arena',
      'primaryColor': 0xFF5CB8E4,
      'secondaryColor': 0xFFFFFFFF,
      'backgroundAssetId': 'theme-argentina-arena-placeholder',
    },
    'runner': {
      'id': 'bjorn',
      'name': 'Bjorn',
      'portraitAssetId': 'character-bjorn-placeholder',
    },
    'prompts': [
      {
        'id': 'include-friend',
        'prompt': 'Who should Bjorn invite?',
        'correctAnswerId': 'new-friend',
        'feedback': 'Inviting a new friend helps everyone feel welcome.',
        'answers': [
          {'id': 'new-friend', 'label': 'new friend'},
          {'id': 'same-friend', 'label': 'same friend'},
        ],
      },
      {
        'id': 'ask-help',
        'prompt': 'Pick the helpful words.',
        'correctAnswerId': 'help-please',
        'feedback': 'Asking kindly for help is a strong choice.',
        'answers': [
          {'id': 'help-please', 'label': 'help please'},
          {'id': 'do-it', 'label': 'do it now'},
        ],
      },
      {
        'id': 'calm-body',
        'prompt': 'What helps a busy body?',
        'correctAnswerId': 'slow-breath',
        'feedback': 'A slow breath can help your body feel ready.',
        'answers': [
          {'id': 'slow-breath', 'label': 'slow breath'},
          {'id': 'fast-feet', 'label': 'fast feet'},
        ],
      },
      {
        'id': 'take-turn',
        'prompt': 'Choose the fair play choice.',
        'correctAnswerId': 'your-turn',
        'feedback': 'Letting someone have a turn keeps play fair.',
        'answers': [
          {'id': 'your-turn', 'label': 'your turn'},
          {'id': 'my-turn', 'label': 'my turn only'},
        ],
      },
      {
        'id': 'friend-feelings',
        'prompt': 'What should Bjorn ask?',
        'correctAnswerId': 'are-you-ok',
        'feedback': 'Checking on feelings shows you care.',
        'answers': [
          {'id': 'are-you-ok', 'label': 'are you ok?'},
          {'id': 'why-sad', 'label': 'why sad?'},
        ],
      },
    ],
  });
}
