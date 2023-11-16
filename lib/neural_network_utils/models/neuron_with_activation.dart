import 'dart:math';

import 'package:synadart/src/neurons/neuron.dart';
import 'package:synadart/src/utils/value_generator.dart';
import 'package:synadart/synadart.dart';

import '../mutation.dart';

class NeuronWithActivation extends Neuron {
  final ActivationAlgorithm activationAlgorithm;
  NeuronWithActivation({
    required this.activationAlgorithm,
    required super.parentLayerSize,
    required super.learningRate,
    super.weights,
  }) : super(activationAlgorithm: activationAlgorithm);

  NeuronWithActivation variation({Mutation? mutation, double percent = 1.0}) {
    var random = Random();
    return copyWith(
      weights: weights
          .map(mutation ??
              (e) {
                switch (random.nextInt(4)) {
                  case 0:
                    if (random.nextDouble() > 0.5) {
                      final limit = 1 / sqrt(weights.length);
                      return nextDouble(from: -limit, to: limit);
                    } else {
                      return e;
                    }
                  case 1:
                    return e + (nextDouble(from: -1, to: 1) * percent);
                  case 2:
                    return e * (random.nextDouble() * percent);
                  default:
                    return e;
                }
              })
          .toList(),
    );
  }

  NeuronWithActivation copyWith({
    ActivationAlgorithm? activationAlgorithm,
    double? learningRate,
    List<double>? weights,
  }) {
    return NeuronWithActivation(
      activationAlgorithm: activationAlgorithm ?? this.activationAlgorithm,
      learningRate: learningRate ?? this.learningRate,
      weights: weights ?? this.weights,
      parentLayerSize: (weights ?? this.weights).length,
    );
  }

  NeuronWithActivation recombination(Neuron neuron) {
    return copyWith(weights: _doRecombination(weights, neuron.weights));
  }

  List<double> _doRecombination(List<double> weights, List<double> weights2) {
    List<double> newWeights = [];
    Random _r = Random();
    List<bool> baseRecombination = List.generate(
      weights.length,
      (index) => _r.nextBool(),
    );
    for (int i = 0; i < baseRecombination.length; i++) {
      if (baseRecombination[i]) {
        newWeights.add(weights[i]);
      } else {
        newWeights.add(weights2[i]);
      }
    }
    return newWeights;
  }
}
