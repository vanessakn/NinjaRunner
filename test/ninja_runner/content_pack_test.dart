import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/data/sample_content_pack.dart';
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

    test('rejects prompts without exactly two answers', () {
      expect(
        () => ContentPack.fromJson({
          'id': 'one-answer-pack',
          'title': 'One Answer Pack',
          'minAge': 5,
          'maxAge': 8,
          'theme': {
            'id': 'argentina-arena',
            'name': 'Argentina Arena',
            'primaryColor': 0xFF5CB8E4,
            'secondaryColor': 0xFFFFFFFF,
          },
          'runner': {'id': 'bjorn', 'name': 'Bjorn'},
          'prompts': [
            {
              'id': 'one-answer',
              'prompt': 'Choose one.',
              'correctAnswerId': 'kind',
              'feedback': 'Kind is a good choice.',
              'answers': [
                {'id': 'kind', 'label': 'kind'},
              ],
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );

      expect(
        () => ContentPack.fromJson({
          'id': 'three-answer-pack',
          'title': 'Three Answer Pack',
          'minAge': 5,
          'maxAge': 8,
          'theme': {
            'id': 'portugal-arena',
            'name': 'Portugal Arena',
            'primaryColor': 0xFFE53B44,
            'secondaryColor': 0xFF2AA757,
          },
          'runner': {'id': 'arjun', 'name': 'Arjun'},
          'prompts': [
            {
              'id': 'three-answer',
              'prompt': 'Choose one.',
              'correctAnswerId': 'kind',
              'feedback': 'Kind is a good choice.',
              'answers': [
                {'id': 'kind', 'label': 'kind'},
                {'id': 'loud', 'label': 'loud'},
                {'id': 'sleepy', 'label': 'sleepy'},
              ],
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('sample pack uses KNSoccer cast and avoids soccer mechanics', () {
      final pack = sampleContentPack();

      expect(pack.minAge, 5);
      expect(pack.maxAge, 8);
      expect(['Jordan', 'Nari', 'Bjorn', 'Arjun'], contains(pack.runner.name));
      expect(pack.prompts, hasLength(5));

      final forbiddenWords = RegExp(
        r'\b(dribble|pass|shoot|tackle|header|goal|match|3v3)\b',
        caseSensitive: false,
      );
      final text = [
        pack.title,
        pack.theme.name,
        for (final prompt in pack.prompts) ...[
          prompt.prompt,
          prompt.feedback,
          for (final answer in prompt.answers) answer.label,
        ],
      ].join(' ');

      expect(forbiddenWords.hasMatch(text), isFalse);
    });
  });
}
