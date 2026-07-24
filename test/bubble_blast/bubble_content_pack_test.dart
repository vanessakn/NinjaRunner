import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/bubble_blast/data/sample_bubble_pack.dart';
import 'package:kidnation_mobile_games/bubble_blast/models/bubble_content_pack.dart';

void main() {
  group('BubbleContentPack', () {
    test('parses a valid pack from json', () {
      final pack = BubbleContentPack.fromJson({
        'id': 'kindness-bubbles',
        'title': 'Kindness Bubbles',
        'minAge': 5,
        'maxAge': 8,
        'theme': {
          'id': 'sunny-park',
          'name': 'Sunny Park',
          'primaryColor': 0xFF00A7E1,
          'secondaryColor': 0xFFFFD23F,
        },
        'character': {'id': 'nari', 'name': 'Nari'},
        'prompts': [
          {
            'id': 'find-kind',
            'level': 2,
            'prompt': 'Pop the kind word.',
            'spokenPrompt': 'Can you find the kind word?',
            'correctAnswerId': 'share',
            'feedback': 'Sharing is a kind choice.',
            'answers': [
              {'id': 'share', 'label': 'share'},
              {'id': 'wait', 'label': 'wait'},
              {'id': 'wave', 'label': 'wave'},
            ],
          },
        ],
      });

      expect(pack.id, 'kindness-bubbles');
      expect(pack.ageRangeLabel, 'Ages 5-8');
      expect(pack.levels, [2]);
      expect(pack.theme.name, 'Sunny Park');
      expect(pack.character.name, 'Nari');
      expect(pack.prompts.single.level, 2);
      expect(pack.prompts.single.correctAnswer.label, 'share');
      expect(pack.prompts.single.spokenPrompt, 'Can you find the kind word?');
    });

    test('rejects a prompt without its correct answer', () {
      expect(
        () => BubbleContentPack.fromJson({
          'id': 'bad-bubbles',
          'title': 'Bad Bubbles',
          'minAge': 3,
          'maxAge': 6,
          'theme': {
            'id': 'cloudy-park',
            'name': 'Cloudy Park',
            'primaryColor': 0xFF70D6FF,
            'secondaryColor': 0xFFFFFFFF,
          },
          'character': {'id': 'jordan', 'name': 'Jordan'},
          'prompts': [
            {
              'id': 'missing-answer',
              'prompt': 'Pop the helpful action.',
              'correctAnswerId': 'help',
              'feedback': 'Helping is kind.',
              'answers': [
                {'id': 'run', 'label': 'run'},
                {'id': 'jump', 'label': 'jump'},
              ],
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('sample pack targets ages 5-8 and includes levels', () {
      final pack = sampleBubblePack();

      expect(pack.minAge, 5);
      expect(pack.maxAge, 8);
      expect(pack.levels, [1, 2, 3]);
      expect(pack.prompts, hasLength(15));
      for (final level in pack.levels) {
        expect(
          pack.prompts.where((prompt) => prompt.level == level),
          hasLength(5),
          reason: 'Each Bubble Blast level should have 5 tries.',
        );
      }
      expect(
          pack.prompts.every((prompt) => prompt.answers.length >= 3), isTrue);
      expect(
          pack.prompts.every((prompt) => prompt.spokenPrompt != null), isTrue);
    });

    test('sample pack uses gentle age-appropriate distractor text', () {
      final pack = sampleBubblePack();
      const blockedWords = {
        'alone',
        'apart',
        'blame',
        'boss',
        'get mad',
        'give up',
        'go away',
        'grab',
        'hide',
        'hide it',
        'ignored',
        'keep all',
        'laugh at',
        'left out',
        'mine',
        'nope',
        'one wins',
        'push',
        'quit',
        'shout',
        'skip them',
        'stomp',
        'tease',
        'yell',
      };

      final labels = [
        for (final prompt in pack.prompts)
          for (final answer in prompt.answers) answer.label.toLowerCase(),
      ];

      expect(labels, isNot(containsAll(blockedWords)));
      expect(labels.where(blockedWords.contains), isEmpty);
    });
  });
}
