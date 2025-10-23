import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:npc_neural/game/components/finish_line.dart';
import 'package:npc_neural/game/components/knight.dart';
import 'package:npc_neural/game/components/spikes_line.dart';
import 'package:npc_neural/game/npc_neural_game.dart';
import 'package:npc_neural/neural_network_utils/models.dart';
import 'package:npc_neural/neural_network_utils/npc_neural_model.dart';
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
  bool canChangeSpikes = false;

  Vector2 initPosition = Vector2(
    1 * NpcNeuralGame.tilesize,
    5 * NpcNeuralGame.tilesize,
  );

  int get genNumber => scoreGenerations.length;

  List<Knight> _progenitors = [];

  double maxDistanceToTarget = 0;

  FinishLine? target;
  double get lastBestScore =>
      scoreGenerations[scoreGenerations.length - 1] ?? 0;

  int countWin = 0;
  final Map<int, SequentialWithVariation> _wins = {};
  final int countWinToFinish;
  static final int countProgenitor = 2;
  final SequentialWithVariation? baseNeural;
  final NeuralWeightsStorage storage;
  late DateTime _timeCreate;

  GenerationManager({
    this.individualsCount = 80,
    this.timeScale = 1.3,
    this.countWinToFinish = 10,
    this.baseNeural,
    this.countKnightEyeLines = 7,
    required this.storage,
  }) : assert(individualsCount % countProgenitor == 0) {
    _timeCreate = DateTime.now();
  }

  void setWin(Knight knight) {
    canChangeSpikes = true;
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
    generateInitPosition();
    if (_individuals.isNotEmpty) {
      if (canChangeSpikes) {
        canChangeSpikes = false;
        gameRef.query<SpikesLine>().forEach((element) => element.reset());
      }

      int countMutations = ((individualsCount - _progenitors.length) * 0.8)
          .toInt(); // 80% of the individuals are mutations
      int indexIndividuo = 0;
      for (var pro in _progenitors) {
        // keep this projenitor
        if (_individuals.length > indexIndividuo) {
          _individuals[indexIndividuo].reset(
            initPosition,
            pro.neuralnetWork.copy(),
          );
          indexIndividuo++;
        }
      }
      if (_individuals.length > indexIndividuo) {
        // make recombination with projenitors
        _individuals[indexIndividuo].reset(
          initPosition,
          _recombinationNetwork(
            _progenitors[0].neuralnetWork.copy(),
            _progenitors[1].neuralnetWork.copy(),
          ),
        );
        indexIndividuo++;
      }

      if (countMutations > 0) {
        List.generate(
          countMutations,
          (index) {
            _individuals[indexIndividuo].reset(
              initPosition,
              _mutationOrCreateNetwork(_progenitors[0].neuralnetWork.copy()),
            );
            indexIndividuo++;
          },
        );
      }

      List.generate(
        individualsCount - indexIndividuo,
        (index) {
          _individuals[indexIndividuo].reset(
            initPosition,
            _mutationOrCreateNetwork(null),
          );
          indexIndividuo++;
        },
      );
    } else {
      List.generate(individualsCount, (index) {
        _individuals.add(
          Knight(
            position: initPosition,
            neuralnetWork: index == 0 && baseNeural != null
                ? baseNeural!
                : _mutationOrCreateNetwork(baseNeural),
            countEyeLines: countKnightEyeLines,
          ),
        );
      });
      gameRef.addAll(_individuals);
    }
  }

  SequentialWithVariation _mutationOrCreateNetwork(
    SequentialWithVariation? net,
  ) {
    return net?.variation(percent: 0.5) ?? NpcNeuralModel.createModel();
  }

  SequentialWithVariation _recombinationNetwork(
    SequentialWithVariation net1,
    SequentialWithVariation net2,
  ) {
    return net1.recombination(net2);
  }

  void _startNewGeneration() {
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
    _startNewGeneration();
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

  List<Knight> _createProgenitors() {
    return _individuals
        .where((element) {
          return element.rank <= countProgenitor;
        })
        .take(countProgenitor)
        .toList();
  }

  void _orderIndividuals() {
    _individuals.sort(
      (a, b) => b.score.compareTo(a.score),
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
    if (_individuals.isEmpty) return;
    var bestOfGen = _individuals.first;
    scoreGenerations[scoreGenerations.length] = bestOfGen.score;
    final _newProgenitors = _createProgenitors();
    if (_progenitors.isNotEmpty) {
      for (final i
          in List.generate(_progenitors.length - 1, (index) => index)) {
        if (_newProgenitors[i].rank < _progenitors[i].rank) {
          _progenitors[i] = _newProgenitors[i];
        }
      }
    } else {
      _progenitors = List.of(_newProgenitors);
    }

    //   var bestOfGen = _individuals.first;
    //   if (bestOfGen.score >= lastBestScore * 0.8) {
    //     scoreGenerations[scoreGenerations.length] = bestOfGen.score;
    //     _progenitors = _createProgenitors();
    //   }
  }

  void _saveNeural(SequentialWithVariation neuralnetWork) {
    storage.save(
      'neural-weights-${_timeCreate.toIso8601String()}',
      neuralnetWork.getWeights(),
    );
  }

  void generateInitPosition() {
    initPosition = Vector2(
      2 * NpcNeuralGame.tilesize,
      (2 + Random().nextInt(7)) * NpcNeuralGame.tilesize,
    );
  }
}
