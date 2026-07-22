enum AnalyticsEvent {
  gameReady('game_ready'),
  roundStart('round_start'),
  promptShown('prompt_shown'),
  gateSelected('gate_selected'),
  answerResult('answer_result'),
  roundComplete('round_complete'),
  gameError('game_error');

  const AnalyticsEvent(this.name);

  final String name;
}

class LoggedAnalyticsEvent {
  const LoggedAnalyticsEvent({
    required this.name,
    required this.payload,
  });

  final String name;
  final Map<String, Object> payload;
}

class AnalyticsLogger {
  final List<LoggedAnalyticsEvent> _events = [];

  List<LoggedAnalyticsEvent> get events => List.unmodifiable(_events);

  void track(
    AnalyticsEvent event, {
    Map<String, Object?> payload = const {},
  }) {
    try {
      _events.add(
        LoggedAnalyticsEvent(
          name: event.name,
          payload: Map.unmodifiable(_safePayload(payload)),
        ),
      );
    } catch (_) {
      // Analytics must never interrupt play.
    }
  }

  Map<String, Object> _safePayload(Map<String, Object?> payload) {
    final safe = <String, Object>{};
    for (final entry in payload.entries) {
      final value = entry.value;
      if (value is String) {
        safe[entry.key] = value;
      } else if (value is num) {
        safe[entry.key] = value;
      } else if (value is bool) {
        safe[entry.key] = value;
      }
    }
    return safe;
  }
}
