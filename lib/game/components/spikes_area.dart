import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:npc_neural/game/components/spikes.dart';

class SpikesArea extends GameComponent {
  final Vector2 spikeSize;
  int countPosition = 0;
  final List<Spikes> _spikesToAdd = [];
  SpikesArea({
    required Vector2 position,
    required Vector2 size,
    Vector2? spikeSize,
  }) : spikeSize = spikeSize ?? Vector2.all(16) {
    this.position = position;
    this.size = size;
    countPosition = size.y ~/ this.spikeSize.y;
    _generatePositions();
  }

  void _generatePositions() {
    Random random = Random();
    _spikesToAdd.clear();
    for (var element
        in _spikesPositions[random.nextInt(_spikesPositions.length)]) {
      _spikesToAdd.add(Spikes(position: Vector2(0, element * spikeSize.y)));
    }
    // do {
    //   int po = random.nextInt(countPosition);
    //   if (_spikesMap[po] == null &&
    //       _spikesMap[po + 1] == null &&
    //       _spikesMap[po - 1] == null) {
    //     _spikesMap[po] = Spikes(position: Vector2(0, po * spikeSize.y));
    //   }
    // } while (_spikesMap.length < countSpikes);
  }

  @override
  void onMount() {
    super.onMount();
    _addSpikes();
  }

  void reset() {
    for (var element in children) {
      element.removeFromParent();
    }
    _generatePositions();
    _addSpikes();
  }

  void _addSpikes() {
    for (var value in _spikesToAdd) {
      add(value);
    }
  }

  final List<List<int>> _spikesPositions = [
    [1, 3, 5],
    [0, 1, 3, 5, 6],
    [1, 2, 4, 5],
  ];
}
