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

  SequentialWithVariation variation({
    Mutation? mutation,
    double percent = 1.0,
  }) {
    return SequentialWithVariation(
      learningRate: learningRate,
    )..layers.addAll(layers //
        .cast<LayerWithActivation>()
        .map((layer) => layer.isInput
            ? layer.copyWith()
            : layer.variation(mutation: mutation, percent: percent)));
  }

  SequentialWithVariation recombination(SequentialWithVariation network) {
    List<LayerWithActivation> l = [];
    for (int i = 0; i < this.layers.length; i++) {
      l.add(
        (layers[i] as LayerWithActivation).recombination(network.layers[i]),
      );
    }
    return SequentialWithVariation(
      learningRate: learningRate,
    )..layers.addAll(l);
  }

  SequentialWithVariation copy() {
    return SequentialWithVariation(
      learningRate: learningRate,
    )..layers.addAll(layers //
        .cast<LayerWithActivation>()
        .map((layer) => layer.copyWith()));
  }

  /// Loads a model from a JSON .
  SequentialWithVariation.loadModel(Map<String, dynamic> data)
      : super(learningRate: 0) {
    learningRate = data[learningRateField];
    LayerWithActivation? last;
    for (Map<String, dynamic> layer in data[layersField]) {
      layers.add(
        last = LayerWithActivation.fromMap(layer)
          ..initialise(
            parentLayerSize: last?.size ?? 0,
            learningRate: learningRate,
          ),
      );
    }
  }

  /// get model in JSON format.
  Map<String, dynamic> getModel() {
    return {
      learningRateField: learningRate,
      layersField: layers //
          .cast<LayerWithActivation>()
          .map((e) => e.toMap())
          .toList(),
    };
  }

  /// get Weight.
  List<List<List<double>>> getWeights() {
    return layers.map((e) {
      return e.neurons.map((e) => e.weights).toList();
    }).toList();
  }

  void loadWeights(List weights) {
    final weightsList = weights.map((e) {
      return (e as List).map((e) {
        return (e as List).map((e) {
          return double.parse(e.toString());
        }).toList();
      }).toList();
    }).toList();
    for (int l = 0; l < layers.length; l++) {
      for (int n = 0; n < layers[l].neurons.length; n++) {
        layers[l].neurons[n].weights = weightsList[l][n];
      }
    }
  }
}
