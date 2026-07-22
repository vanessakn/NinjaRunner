import 'content_pack.dart';

class GateDashLevel {
  const GateDashLevel({
    required this.id,
    required this.name,
    required this.runnerSpeed,
    required this.requiredScore,
    required this.contentPack,
  });

  final String id;
  final String name;
  final double runnerSpeed;
  final int requiredScore;
  final ContentPack contentPack;

  bool isComplete(int score) => score >= requiredScore;
}
