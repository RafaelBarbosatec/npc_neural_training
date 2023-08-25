import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:npc_neural/game/npc_neural_game.dart';
import 'package:npc_neural/neural_network_utils/models.dart';
import 'package:npc_neural/neural_network_utils/npc_neural_model.dart';
import 'package:npc_neural/widgets/saved_networks_dialog.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int countGeneration = 50;
  int _maxCountGeneration = 100;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bonfire + Network Neural'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Train yourself',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Text('Count individuals of generation: $countGeneration'),
                  SizedBox(
                    width: 300,
                    child: Slider(
                      value: countGeneration / _maxCountGeneration,
                      onChanged: (value) {
                        var c = (_maxCountGeneration * value).toInt();
                        if (c % 2 == 0) {
                          setState(() {
                            countGeneration = c;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        _goToGame(context, individualsCount: countGeneration);
                      },
                      child: const Text('Train my network'),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () async {
                        SavedNetworksDialog.show(
                          context,
                          (network, train) {
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              _goToGame(
                                context,
                                sequential: network,
                                train: train,
                              );
                            });
                          },
                        );
                      },
                      child: const Text('Load my network'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Network trained',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            _loadModel(
                              context,
                              'assets/json/weights.json',
                              false,
                            );
                          },
                          child: const Text('Load model'),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            _loadModel(
                              context,
                              'assets/json/weights.json',
                              true,
                              individualsCount: countGeneration,
                            );
                          },
                          child: const Text('Retrain model'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _goToGame(
    BuildContext context, {
    SequentialWithVariation? sequential,
    bool train = true,
    int individualsCount = 40,
    double mutationPercent = 1.0,
  }) async {
    NpcNeuralGame.open(
      context: context,
      projenitorNeural: sequential,
      neuralModel: await NpcNeuralModel.loadModel(context),
      train: train,
      individualsCount: individualsCount,
      mutationPercent: mutationPercent,
    );
  }

  void _loadModel(
    BuildContext context,
    String path,
    bool train, {
    int individualsCount = 40,
  }) async {
    String weightsJson = await DefaultAssetBundle.of(context).loadString(path);
    final neuralNetwork = await NpcNeuralModel.loadNeuralNetwork(
      context,
      jsonDecode(weightsJson),
    );
    if (context.mounted) {
      _goToGame(
        context,
        sequential: neuralNetwork,
        train: train,
        mutationPercent: 0.5,
        individualsCount: individualsCount,
      );
    }
  }
}
