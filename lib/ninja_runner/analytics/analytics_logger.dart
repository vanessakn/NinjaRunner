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
          payload: _safePayload(payload),
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
      switch (value) {
        case final String safeValue:
          safe[entry.key] = safeValue;
        case final num safeValue:
          safe[entry.key] = safeValue;
        case final bool safeValue:
          safe[entry.key] = safeValue;
      }
    }
    return safe;
  }
}
