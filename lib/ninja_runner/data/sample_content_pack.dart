import '../models/content_pack.dart';

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
    },
    'runner': {'id': 'jordan', 'name': 'Jordan'},
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
