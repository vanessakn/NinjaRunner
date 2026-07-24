import 'package:flutter/material.dart';

class BubbleContentPack {
  const BubbleContentPack({
    required this.id,
    required this.title,
    required this.minAge,
    required this.maxAge,
    required this.theme,
    required this.character,
    required this.prompts,
  });

  factory BubbleContentPack.fromJson(Map<String, Object?> json) {
    final prompts = _list(json, 'prompts').map(BubblePrompt.fromJson).toList();
    if (prompts.isEmpty) {
      throw const FormatException('Bubble pack must include prompts.');
    }

    return BubbleContentPack(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      minAge: _int(json, 'minAge'),
      maxAge: _int(json, 'maxAge'),
      theme: BubbleTheme.fromJson(_map(json, 'theme')),
      character: BubbleCharacter.fromJson(_map(json, 'character')),
      prompts: List.unmodifiable(prompts),
    );
  }

  final String id;
  final String title;
  final int minAge;
  final int maxAge;
  final BubbleTheme theme;
  final BubbleCharacter character;
  final List<BubblePrompt> prompts;

  String get ageRangeLabel => 'Ages $minAge-$maxAge';

  List<int> get levels {
    final values = prompts.map((prompt) => prompt.level).toSet().toList()
      ..sort();
    return List.unmodifiable(values);
  }
}

class BubbleTheme {
  const BubbleTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
  });

  factory BubbleTheme.fromJson(Map<String, Object?> json) {
    return BubbleTheme(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
      primaryColor: Color(_int(json, 'primaryColor')),
      secondaryColor: Color(_int(json, 'secondaryColor')),
    );
  }

  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
}

class BubbleCharacter {
  const BubbleCharacter({
    required this.id,
    required this.name,
  });

  factory BubbleCharacter.fromJson(Map<String, Object?> json) {
    return BubbleCharacter(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
    );
  }

  final String id;
  final String name;
}

class BubblePrompt {
  const BubblePrompt({
    required this.id,
    required this.level,
    required this.prompt,
    required this.correctAnswerId,
    required this.feedback,
    required this.answers,
    this.spokenPrompt,
  });

  factory BubblePrompt.fromJson(Map<String, Object?> json) {
    final answers = _list(json, 'answers').map(BubbleAnswer.fromJson).toList();
    final correctAnswerId = _string(json, 'correctAnswerId');
    if (!answers.any((answer) => answer.id == correctAnswerId)) {
      throw FormatException('Correct answer "$correctAnswerId" is missing.');
    }

    return BubblePrompt(
      id: _string(json, 'id'),
      level: _optionalInt(json, 'level') ?? 1,
      prompt: _string(json, 'prompt'),
      spokenPrompt: _optionalString(json, 'spokenPrompt'),
      correctAnswerId: correctAnswerId,
      feedback: _string(json, 'feedback'),
      answers: List.unmodifiable(answers),
    );
  }

  final String id;
  final int level;
  final String prompt;
  final String? spokenPrompt;
  final String correctAnswerId;
  final String feedback;
  final List<BubbleAnswer> answers;

  BubbleAnswer get correctAnswer {
    return answers.firstWhere((answer) => answer.id == correctAnswerId);
  }
}

class BubbleAnswer {
  const BubbleAnswer({
    required this.id,
    required this.label,
  });

  factory BubbleAnswer.fromJson(Map<String, Object?> json) {
    return BubbleAnswer(
      id: _string(json, 'id'),
      label: _string(json, 'label'),
    );
  }

  final String id;
  final String label;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw FormatException('Expected non-empty string for "$key".');
}

String? _optionalString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw FormatException('Expected optional string for "$key".');
}

int _int(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  throw FormatException('Expected int for "$key".');
}

int? _optionalInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  throw FormatException('Expected optional int for "$key".');
}

Map<String, Object?> _map(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException('Expected map for "$key".');
}

List<Map<String, Object?>> _list(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is List) {
    return value.cast<Map<String, Object?>>();
  }
  throw FormatException('Expected list for "$key".');
}
