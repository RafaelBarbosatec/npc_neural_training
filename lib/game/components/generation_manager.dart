import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:npc_neural/game/components/chest.dart';
import 'package:npc_neural/game/components/knight.dart';
import 'package:npc_neural/game/npc_neural_game.dart';
import 'package:npc_neural/neural_network_utils/models.dart';
import 'package:npc_neural/util/strage.dart';
import 'package:synadart/synadart.dart';

class GenerationManager extends GameComponent with ChangeNotifier {
  static const _checkLivesInvervalKey = 'checkLivesInterval';
  static const int checkLivesInterval = 25;
  final int individualsCount;
  final Map<int, double> scoreGenerations = {};
  final List<Knight> _individuals = [];
  final double timeScale;
  bool win = false;

  static Vector2 get initPosition => Vector2(
        1 * NpcNeuralGame.tilesize,
        5 * NpcNeuralGame.tilesize,
      );

  int get genNumber => scoreGenerations.length;

  List<SequentialWithVariation> _progenitors = [];

  double maxDistanceToTarget = 0;

  bool startingNew = false;

  Chest? target;

  double get lastBestScore {
    return scoreGenerations[scoreGenerations.length - 1] ?? 0;
  }

  int countWin = 0;
  final Map<int, SequentialWithVariation> _wins = {};
  final int countWinToFinish;
  final int countProgenitor;
  final SequentialWithVariation? baseNeural;
  final NeuralStorage storage;

  GenerationManager({
    this.individualsCount = 80,
    this.timeScale = 1.2,
    this.countWinToFinish = 4,
    this.countProgenitor = 2,
    this.baseNeural,
    required this.storage,
  }) : assert(individualsCount % countProgenitor == 0);

  bool setWin(Knight knight) {
    if (_wins[genNumber] == null) {
      knight.score = lastBestScore + 1;
      _wins[genNumber] = knight.neuralnetWork;
      countWin++;
      storage.save(
        'better-${DateTime.now().toIso8601String()}',
        knight.neuralnetWork,
      );

      if (countWin == countWinToFinish && !win) {
        _showDialog();
        return win = true;
      }
    }
    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!win && checkInterval(_checkLivesInvervalKey, checkLivesInterval, dt)) {
      _checkAllAlive();
    }
  }

  @override
  void onMount() {
    super.onMount();
    gameRef.timeScale = timeScale;
    Future.delayed(Duration.zero, _startGeneration);
  }

  void _createGeration() {
    if (_individuals.isNotEmpty) {
      int countMutations = individualsCount ~/ _progenitors.length - 1;
      int indexIndividuo = 0;
      for (var pro in _progenitors) {
        _individuals[indexIndividuo].reset(initPosition, pro);
        indexIndividuo++;
        List.generate(
          countMutations,
          (index) {
            _individuals[indexIndividuo].reset(
              initPosition,
              _createNetwork(pro),
            );
            indexIndividuo++;
          },
        );
      }
    } else {
      List.generate(individualsCount, (index) {
        _individuals.add(
          Knight(
            position: initPosition,
            neuralnetWork: index == 0 && baseNeural != null
                ? baseNeural!
                : _createNetwork(baseNeural),
          ),
        );
      });
      gameRef.addAll(_individuals);
    }
  }

  SequentialWithVariation _createNetwork(
    SequentialWithVariation? mainNeuralNetwork,
  ) {
    if (mainNeuralNetwork != null) {
      return mainNeuralNetwork.variation();
    }
    return SequentialWithVariation(
      learningRate: 0.01,
      layers: [
        DenseLayerWithActivation(size: 6, activation: ActivationAlgorithm.relu),
        DenseLayerWithActivation(size: 4, activation: ActivationAlgorithm.relu),
        DenseLayerWithActivation(size: 4, activation: ActivationAlgorithm.relu),
      ],
    );
  }

  void _createNewGeneration() {
    if (_individuals.isNotEmpty) {
      var bestOfGen = _individuals.first;
      scoreGenerations[scoreGenerations.length] = bestOfGen.score;
      _progenitors = _individuals
          .where((element) => element.rank <= countProgenitor)
          .map((e) => e.neuralnetWork)
          .toList();
    }
    _createGeration();
    notifyListeners();
  }

  void _checkAllAlive() {
    if (startingNew) return;
    _calculateScore();

    _individuals.sort(
      (a, b) {
        return b.score.compareTo(a.score);
      },
    );

    bool anyLive = false;
    for (var element in _individuals) {
      if (!element.isDead) {
        anyLive = true;
      }
      element.rank = _individuals.indexOf(element) + 1;
    }
    if (!anyLive) {
      startingNew = true;
      _startGeneration();
    }
  }

  void _startGeneration() {
    resetInterval(_checkLivesInvervalKey);
    _calculateDistanceToTarget();
    _createNewGeneration();
    startingNew = false;
  }

  void _calculateScore() {
    if (target != null) {
      for (var element in _individuals) {
        element.score = maxDistanceToTarget - element.distance(target!);

        element.score = maxDistanceToTarget - element.distance(target!);
      }
    }
  }

  void _calculateDistanceToTarget() {
    target ??= gameRef.query<Chest>().first;
    if (maxDistanceToTarget == 0) {
      maxDistanceToTarget = initPosition.distanceTo(target!.position);
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Network trained with success!'),
          actions: [
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Sair'),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
