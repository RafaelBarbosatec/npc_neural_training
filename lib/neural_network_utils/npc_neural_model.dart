import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:npc_neural/neural_network_utils/models.dart';
import 'package:synadart/synadart.dart';

class NpcNeuralModel {
  static const _assetModel = 'assets/json/model.json';

  static Future<SequentialWithVariation> loadNeuralNetwork(
    BuildContext context,
    dynamic weights,
  ) async {
    var model = await loadModel(context);
    return SequentialWithVariation.loadModel(model)..loadWeights(weights);
  }

  static Future<Map<String, dynamic>> loadModel(BuildContext context) async {
    String model = await DefaultAssetBundle.of(context).loadString(_assetModel);
    return (jsonDecode(model) as Map).cast();
  }

  static SequentialWithVariation createModel({int input = 7, int output = 4}) {
    return SequentialWithVariation(
      learningRate: 0.01,
      layers: [
        DenseLayerWithActivation(
          size: input,
          activation: ActivationAlgorithm.relu,
        ),
        DenseLayerWithActivation(
          size: (input + output) ~/ 2,
          activation: ActivationAlgorithm.relu,
        ),
        DenseLayerWithActivation(
          size: output,
          activation: ActivationAlgorithm.relu,
        ),
      ],
    );
  }
}
