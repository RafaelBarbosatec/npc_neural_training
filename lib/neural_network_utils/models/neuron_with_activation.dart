import 'dart:math';

import 'package:synadart/src/neurons/neuron.dart';
import 'package:synadart/src/utils/value_generator.dart';
import 'package:synadart/synadart.dart';

import '../mutation.dart';

class NeuronWithActivation extends Neuron {
  static const weightsField = 'weights';
  static const activationField = 'activation';
  static const learningRateField = 'learningRate';

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
                    if (percent == 1.0) {
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

  /// Create a [Neuron] from this Map
  static NeuronWithActivation fromMap(Map<String, dynamic> map) {
    final activationIndex = map[activationField] as int;
    final weights = (map[weightsField] as List).map((e) {
      return double.parse(e.toString());
    }).toList();
    return NeuronWithActivation(
      activationAlgorithm: ActivationAlgorithm.values[activationIndex],
      learningRate: map[learningRateField] as double,
      weights: weights,
      parentLayerSize: weights.length,
    );
  }

  /// Parse this [Neuron] in a Map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      weightsField: weights,
      activationField: activationAlgorithm.index,
      learningRateField: learningRate,
    };
  }
}
