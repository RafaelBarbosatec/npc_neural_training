import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:npc_neural/game/components/finish_line.dart';
import 'package:npc_neural/game/components/knight.dart';
import 'package:npc_neural/game/npc_neural_game.dart';
import 'package:npc_neural/neural_network_utils/models.dart';
import 'package:npc_neural/util/strage.dart';

class GenerationManager extends GameComponent with ChangeNotifier {
  static const _checkLivesInvervalKey = 'checkLivesInterval';
  static const int checkLivesInterval = 25;
  static const int outputNeuros = 4;
  final int individualsCount;
  final Map<int, double> scoreGenerations = {};
  final List<Knight> _individuals = [];
  final double timeScale;
  final int countKnightEyeLines;
  bool win = false;

  static Vector2 get initPosition => Vector2(
        1 * NpcNeuralGame.tilesize,
        5 * NpcNeuralGame.tilesize,
      );

  int get genNumber => scoreGenerations.length;

  List<SequentialWithVariation> _progenitors = [];

  double maxDistanceToTarget = 0;

  FinishLine? target;
  double get lastBestScore =>
      scoreGenerations[scoreGenerations.length - 1] ?? 0;

  int countWin = 0;
  final Map<int, SequentialWithVariation> _wins = {};
  final int countWinToFinish;
  final int countProgenitor;
  final SequentialWithVariation? baseNeural;
  final NeuralWeightsStorage storage;
  final Map<String, dynamic> neuralModel;
  late DateTime _timeCreate;

  GenerationManager({
    this.individualsCount = 80,
    this.timeScale = 1.5,
    this.countWinToFinish = 4,
    this.countProgenitor = 2,
    this.baseNeural,
    this.countKnightEyeLines = 7,
    required this.neuralModel,
    required this.storage,
  }) : assert(individualsCount % countProgenitor == 0) {
    _timeCreate = DateTime.now();
  }

  void setWin(Knight knight) {
    if (_wins[genNumber] == null) {
      _wins[genNumber] = knight.neuralnetWork;
      countWin++;
      _saveNeural(knight.neuralnetWork);
      if (countWin == countWinToFinish && !win) {
        _showDialog();
        win = true;
      }
    }
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
    Future.delayed(Duration.zero, () {
      _startGeneration(isFirst: true);
    });
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
            countEyeLines: countKnightEyeLines,
          ),
        );
      });
      gameRef.addAll(_individuals);
    }
  }

  SequentialWithVariation _createNetwork(
    SequentialWithVariation? baseNeuralNetwork,
  ) {
    if (baseNeuralNetwork != null) {
      return baseNeuralNetwork.variation();
    }
    return SequentialWithVariation.loadModel(neuralModel);
  }

  void _sratNewGeneration() {
    _analyseGeneration();
    _createGeration();
    notifyListeners();
  }

  void _checkAllAlive() {
    _calculateScore();
    _orderIndividuals();

    bool anyLive = _updateRankAndCheckAnyLive();
    if (!anyLive) {
      _startGeneration();
    }
  }

  void _startGeneration({bool isFirst = false}) {
    resetInterval(_checkLivesInvervalKey);
    if (!isFirst && _wins[genNumber] == null && countWin > 0) {
      countWin--;
    }
    _calculateDistanceToTarget();
    _sratNewGeneration();
  }

  void _calculateScore() {
    if (target != null) {
      for (var element in _individuals) {
        final distance = element.position.distanceTo(
          target!.absoluteCenter,
        );
        element.score = maxDistanceToTarget - distance;
      }
    }
  }

  void _calculateDistanceToTarget() {
    if (maxDistanceToTarget == 0) {
      target ??= gameRef.query<FinishLine>().first;
      maxDistanceToTarget = initPosition.distanceTo(target!.absoluteCenter);
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

  List<SequentialWithVariation> _createProgenitors() {
    var progenitorsProrspect = _individuals.where((element) {
      return element.rank <= countProgenitor;
    });

    return progenitorsProrspect.map((e) {
      return e.neuralnetWork;
    }).toList();
  }

  void _orderIndividuals() {
    _individuals.sort(
      (a, b) {
        return b.score.compareTo(a.score);
      },
    );
  }

  bool _updateRankAndCheckAnyLive() {
    bool anyLive = false;
    for (var element in _individuals) {
      if (!element.isDead && !element.winner) {
        anyLive = true;
      }
      element.rank = _individuals.indexOf(element) + 1;
    }
    return anyLive;
  }

  void _analyseGeneration() {
    if (_individuals.isNotEmpty) {
      var bestOfGen = _individuals.first;
      scoreGenerations[scoreGenerations.length] = lastBestScore;
      if (bestOfGen.score >= lastBestScore * 0.8) {
        scoreGenerations[scoreGenerations.length] = bestOfGen.score;
        _progenitors = _createProgenitors();
      }
    }
  }

  void _saveNeural(SequentialWithVariation neuralnetWork) {
    storage.save(
      'neural-weights-${_timeCreate.toIso8601String()}',
      neuralnetWork.getWeights(),
    );
  }
}
