import 'package:synadart/src/layers/core/dense.dart';
import 'package:synadart/src/layers/layer.dart';
import 'package:synadart/synadart.dart';

import '../mutation.dart';
import 'neuron_with_activation.dart';

class DenseLayerWithActivation extends LayerWithActivation implements Dense {
  DenseLayerWithActivation({
    required ActivationAlgorithm activation,
    required super.size,
    List<NeuronWithActivation>? neuros,
  }) : super(activationAlgorithm: activation);
}

class LayerWithActivation extends Layer {
  static const activationField = 'activation';
  static const neuronsField = 'neurons';
  static const isInputField = 'isInput';

  final ActivationAlgorithm activationAlgorithm;
  LayerWithActivation({
    required this.activationAlgorithm,
    required super.size,
    List<NeuronWithActivation>? neuros,
  }) : super(activation: activationAlgorithm);

  @override
  void initialise({
    required int parentLayerSize,
    required double learningRate,
  }) {
    isInput = parentLayerSize == 0;

    neurons.addAll(
      Iterable.generate(
        size,
        (_) => NeuronWithActivation(
          activationAlgorithm: activation,
          parentLayerSize: parentLayerSize,
          learningRate: learningRate,
        ),
      ),
    );
  }

  Layer variation({Mutation? mutation, double percent = 1.0}) {
    return copyWith(
      neurons: neurons
          .cast<NeuronWithActivation>()
          .map((e) => e.variation(mutation: mutation, percent: percent))
          .toList(),
    );
  }

  LayerWithActivation copyWith({
    ActivationAlgorithm? activationAlgorithm,
    bool? isInput,
    List<NeuronWithActivation>? neurons,
  }) {
    return LayerWithActivation(
      activationAlgorithm: activationAlgorithm ?? this.activationAlgorithm,
      size: (neurons ?? this.neurons).length,
    )
      ..isInput = isInput ?? this.isInput
      ..neurons.addAll(neurons ?? this.neurons);
  }

  factory LayerWithActivation.fromMap(Map<String, dynamic> map) {
    final activationAlgorithm =
        ActivationAlgorithm.values[map[activationField] as int];

    final neurons = (map[neuronsField] as List)
        .map((e) => NeuronWithActivation.fromMap((e as Map).cast()))
        .toList();
    final isInput = map[isInputField];

    return LayerWithActivation(
      size: neurons.length,
      activationAlgorithm: activationAlgorithm,
    )
      ..isInput = isInput
      ..neurons.addAll(neurons);
  }

  Map<String, dynamic> toMap() {
    return {
      activationField: activation.index,
      isInputField: isInput,
      neuronsField: neurons
          .cast<NeuronWithActivation>()
          .map((neuron) => neuron.toMap())
          .toList(),
    };
  }
}
