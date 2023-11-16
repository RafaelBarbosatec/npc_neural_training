import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:npc_neural/game/components/spikes.dart';

class SpikesLine extends GameDecoration {
  static const List<List<double>> _combinations = [
    [0, 2, 4, 6],
    [1, 3, 5],
    [0, 1, 3, 5, 6],
    [1, 2, 4, 5],
    [0, 1, 3, 4, 6],
  ];
  SpikesLine({required super.position}) : super(size: Vector2.all(16));

  @override
  void onMount() {
    _addSpikes();
    super.onMount();
  }

  void reset() {
    children.query<Spikes>().forEach((element) => element.removeFromParent());
    _addSpikes();
  }

  void _addSpikes() {
    final comb = _combinations[Random().nextInt(_combinations.length)];
    comb.forEach((element) {
      add(Spikes(position: Vector2(0, element * 16)));
    });
  }

  @override
  bool hasGesture() {
    return true;
  }
}
