import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/models/content_pack.dart';

void main() {
  group('ContentPack', () {
    test('parses a valid pack from json', () {
      final pack = ContentPack.fromJson({
        'id': 'kidnation-cup-kindness',
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
        ],
      });

      expect(pack.id, 'kidnation-cup-kindness');
      expect(pack.ageRangeLabel, 'Ages 5-8');
      expect(pack.theme.name, 'Brazil Arena');
      expect(pack.runner.name, 'Jordan');
      expect(pack.prompts.single.correctAnswer.label, 'share');
    });

    test('rejects a prompt without the correct answer in its options', () {
      expect(
        () => ContentPack.fromJson({
          'id': 'bad-pack',
          'title': 'Bad Pack',
          'minAge': 5,
          'maxAge': 8,
          'theme': {
            'id': 'france-arena',
            'name': 'France Arena',
            'primaryColor': 0xFF2867D4,
            'secondaryColor': 0xFFFFFFFF,
          },
          'runner': {'id': 'nari', 'name': 'Nari'},
          'prompts': [
            {
              'id': 'bad-prompt',
              'prompt': 'Choose one.',
              'correctAnswerId': 'missing',
              'feedback': 'Try again.',
              'answers': [
                {'id': 'kind', 'label': 'kind'},
                {'id': 'loud', 'label': 'loud'},
              ],
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects malformed answer list members', () {
      expect(
        () => ContentPack.fromJson({
          'id': 'bad-pack',
          'title': 'Bad Pack',
          'minAge': 5,
          'maxAge': 8,
          'theme': {
            'id': 'france-arena',
            'name': 'France Arena',
            'primaryColor': 0xFF2867D4,
            'secondaryColor': 0xFFFFFFFF,
          },
          'runner': {'id': 'nari', 'name': 'Nari'},
          'prompts': [
            {
              'id': 'bad-prompt',
              'prompt': 'Choose one.',
              'correctAnswerId': 'kind',
              'feedback': 'Try again.',
              'answers': [
                {'id': 'kind', 'label': 'kind'},
                'loud',
              ],
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
