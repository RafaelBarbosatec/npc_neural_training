import 'package:npc_neural/neural_network_utils/models/layer_with_activation.dart';
import 'package:synadart/synadart.dart';

import '../mutation.dart';

class SequentialWithVariation extends Sequential {
  static const layersField = 'layers';
  static const learningRateField = 'learningRate';

  SequentialWithVariation({
    required super.learningRate,
    List<LayerWithActivation>? super.layers,
  });

  SequentialWithVariation variation(
      {Mutation? mutation, double percent = 1.0}) {
    return SequentialWithVariation(
      learningRate: learningRate,
    )..layers.addAll(layers //
        .cast<LayerWithActivation>()
        .map((layer) => layer.isInput
            ? layer.copyWith()
            : layer.variation(mutation: mutation, percent: percent)));
  }

  /// Loads a model from a JSON .
  SequentialWithVariation.fromMap(Map<String, dynamic> data)
      : super(learningRate: 0) {
    learningRate = data[learningRateField];
    for (Map<String, dynamic> layer in data[layersField]) {
      layers.add(LayerWithActivation.fromMap(layer));
    }
  }

  /// Save the model to a JSON.
  Map<String, dynamic> toMap() {
    return {
      learningRateField: learningRate,
      layersField: layers //
          .cast<LayerWithActivation>()
          .map((e) => e.toMap())
          .toList(),
    };
  }
}
