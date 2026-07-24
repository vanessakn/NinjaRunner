import 'dart:math' as math;

import '../models/ninja_go_models.dart';

class NinjaGoController {
  NinjaGoController({int? seed})
      : _random = math.Random(seed),
        state = NinjaGoState.initial();

  final math.Random _random;
  NinjaGoState state;

  void startRun() {
    state = NinjaGoState.initial(
      bestDistance: state.bestDistance,
      bestScore: state.bestScore,
    ).copyWith(phase: NinjaGoPhase.running);
  }
}
