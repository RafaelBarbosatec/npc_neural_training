import 'package:bonfire/bonfire.dart';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:neurons_tree_widget/neurons_tree_widget.dart';
import 'package:npc_neural/game/components/generation_manager.dart';
import 'package:npc_neural/util/better_neural_listener.dart';

class TrainPanelWidget extends StatefulWidget {
  final bool withGraph;
  final VoidCallback? onTapStart;
  const TrainPanelWidget({
    super.key,
    this.withGraph = true,
    this.onTapStart,
  });

  @override
  State<TrainPanelWidget> createState() => _TrainPanelWidgetState();
}

class _TrainPanelWidgetState extends State<TrainPanelWidget> {
  late GenerationManager _generationManager;
  late BetterNeuralListener _neuralListener;
  bool started = false;

  @override
  void initState() {
    _generationManager = BonfireInjector().get();
    _neuralListener = BonfireInjector().get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: started
              ? [
                  _buildTitle(),
                  if (widget.withGraph) _buildGraph(),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text('Neural of the better'),
                  const SizedBox(height: 16),
                  _buildNeuralTree(),
                ]
              : [
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: _start,
                      child: const Text('Start'),
                    ),
                  )
                ],
        ),
      ),
    );
  }

  void _start() {
    widget.onTapStart?.call();
    setState(() {
      started = true;
    });
  }

  Widget _buildTitle() {
    if (widget.withGraph) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Trainig'),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('Running'),
    );
  }

  Widget _buildGraph() {
    return Center(
      child: ListenableBuilder(
        listenable: _generationManager,
        builder: (context, child) {
          List<Map<String, dynamic>> listGraph = [];
          _generationManager.scoreGenerations.forEach((key, value) {
            listGraph.add(
              {'domain': key, 'measure': value},
            );
          });
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Generation: ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${_generationManager.genNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Count win: ',
                  ),
                  Text(
                    '${_generationManager.countWin}/ ${_generationManager.countWinToFinish}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                key: Key(_generationManager.genNumber.toString()),
                width: 250,
                height: 200,
                child: DChartLine(
                  animate: false,
                  data: [
                    {'id': 'Line', 'data': listGraph},
                  ],
                  lineColor: (lineData, index, id) => Colors.red,
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildNeuralTree() {
    return Center(
      child: ListenableBuilder(
        listenable: _neuralListener,
        builder: (context, child) {
          return NeuronsTreeWidget(
            data: _neuralListener.neuralTree,
            neuronDiameter: 30,
            neuronSpacing: 10,
          );
        },
      ),
    );
  }
}
