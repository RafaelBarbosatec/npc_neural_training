import 'package:flutter/widgets.dart';
import 'package:synadart/synadart.dart';

class BetterNeuralListener extends ChangeNotifier {
  List<List<bool>> neuralTree = [];

  void setNeural(Sequential network) {
    neuralTree.clear();
    for (var layers in network.layers) {
      List<bool> layer = [];
      for (var neuron in layers.neurons) {
        layer.add(neuron.output > 0);
      }
      neuralTree.add(layer);
    }
    notifyListeners();
  }
}
