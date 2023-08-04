import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:npc_neural/game/npc_neural_game.dart';
import 'package:npc_neural/widgets/saved_networks_dialog.dart';
import 'package:synadart/synadart.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bonfire + Network neural'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => _goToGame(context),
                child: const Text('Train'),
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
                      Future.delayed(const Duration(milliseconds: 300), () {
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
                  const Text('Network trained'),
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
                              'assets/json/network1.json',
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
                              'assets/json/network1.json',
                              true,
                            );
                          },
                          child: const Text('Train model'),
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

  void _goToGame(BuildContext context,
      {Sequential? sequential, bool train = true}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NpcNeuralGame(
          neural: sequential,
          train: train,
        ),
      ),
    );
  }

  void _loadModel(BuildContext context, String path, bool train) async {
    String data = await DefaultAssetBundle.of(context).loadString(path);
    Sequential s = Sequential.fromMap(jsonDecode(data));
    if (context.mounted) {
      _goToGame(context, sequential: s, train: train);
    }
  }
}
