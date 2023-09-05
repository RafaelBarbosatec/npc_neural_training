import 'package:flutter/material.dart';
import 'package:npc_neural/neural_network_utils/models.dart';
import 'package:synadart/synadart.dart';

class NpcNeuralModel {
  static Future<SequentialWithVariation> loadNeuralNetwork(
    BuildContext context,
    List weights,
  ) async {
    return createModel()..loadWeights(weights);
  }

  static SequentialWithVariation createModel({int input = 7, int output = 4}) {
    return SequentialWithVariation(
      learningRate: 0.1,
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
