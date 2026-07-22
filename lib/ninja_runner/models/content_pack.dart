import 'package:flutter/material.dart';

class ContentPack {
  const ContentPack({
    required this.id,
    required this.title,
    required this.minAge,
    required this.maxAge,
    required this.theme,
    required this.runner,
    required this.prompts,
  });

  factory ContentPack.fromJson(Map<String, Object?> json) {
    final promptsJson = _list(json, 'prompts');
    final prompts = promptsJson.map(RunnerPrompt.fromJson).toList();
    if (prompts.isEmpty) {
      throw const FormatException(
          'Content pack must include at least one prompt.');
    }

    return ContentPack(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      minAge: _int(json, 'minAge'),
      maxAge: _int(json, 'maxAge'),
      theme: RunnerTheme.fromJson(_map(json, 'theme')),
      runner: RunnerCharacter.fromJson(_map(json, 'runner')),
      prompts: List.unmodifiable(prompts),
    );
  }

  final String id;
  final String title;
  final int minAge;
  final int maxAge;
  final RunnerTheme theme;
  final RunnerCharacter runner;
  final List<RunnerPrompt> prompts;

  String get ageRangeLabel => 'Ages $minAge-$maxAge';
}

class RunnerTheme {
  const RunnerTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
  });

  factory RunnerTheme.fromJson(Map<String, Object?> json) {
    return RunnerTheme(
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

class RunnerCharacter {
  const RunnerCharacter({
    required this.id,
    required this.name,
  });

  factory RunnerCharacter.fromJson(Map<String, Object?> json) {
    return RunnerCharacter(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
    );
  }

  final String id;
  final String name;
}

class RunnerPrompt {
  const RunnerPrompt({
    required this.id,
    required this.prompt,
    required this.correctAnswerId,
    required this.feedback,
    required this.answers,
  });

  factory RunnerPrompt.fromJson(Map<String, Object?> json) {
    final answers = _list(json, 'answers').map(RunnerAnswer.fromJson).toList();
    final correctAnswerId = _string(json, 'correctAnswerId');
    if (!answers.any((answer) => answer.id == correctAnswerId)) {
      throw FormatException('Correct answer "$correctAnswerId" is missing.');
    }

    return RunnerPrompt(
      id: _string(json, 'id'),
      prompt: _string(json, 'prompt'),
      correctAnswerId: correctAnswerId,
      feedback: _string(json, 'feedback'),
      answers: List.unmodifiable(answers),
    );
  }

  final String id;
  final String prompt;
  final String correctAnswerId;
  final String feedback;
  final List<RunnerAnswer> answers;

  RunnerAnswer get correctAnswer {
    return answers.firstWhere((answer) => answer.id == correctAnswerId);
  }
}

class RunnerAnswer {
  const RunnerAnswer({
    required this.id,
    required this.label,
  });

  factory RunnerAnswer.fromJson(Map<String, Object?> json) {
    return RunnerAnswer(
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

int _int(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  throw FormatException('Expected int for "$key".');
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
