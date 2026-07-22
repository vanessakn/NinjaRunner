import 'package:flutter_test/flutter_test.dart';
import 'package:kidnation_mobile_games/ninja_runner/analytics/analytics_logger.dart';

void main() {
  test('records local events with safe payloads', () {
    final logger = AnalyticsLogger();

    logger.track(
      AnalyticsEvent.gateSelected,
      payload: const {
        'pack_id': 'kidnation-cup-kindness-run',
        'prompt_id': 'helpful-action',
        'selected_answer_id': 'share',
      },
    );

    expect(logger.events, hasLength(1));
    expect(logger.events.single.name, 'gate_selected');
    expect(logger.events.single.payload['selected_answer_id'], 'share');
  });

  test('ignores unsupported payload value types', () {
    final logger = AnalyticsLogger();

    logger.track(
      AnalyticsEvent.gameError,
      payload: {
        'error_stage': 'content',
        'bad_value': Object(),
      },
    );

    expect(logger.events.single.payload, {'error_stage': 'content'});
  });

  test('exposes payloads as unmodifiable maps', () {
    final logger = AnalyticsLogger();

    logger.track(
      AnalyticsEvent.roundStart,
      payload: const {'round_number': 1},
    );

    expect(
      () => logger.events.single.payload['round_number'] = 2,
      throwsUnsupportedError,
    );
  });
}
