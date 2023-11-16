import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:neurons_tree_widget/neurons_tree_widget.dart';
import 'package:npc_neural/game/components/generation_manager.dart';
import 'package:npc_neural/main.dart';
import 'package:npc_neural/util/better_neural_listener.dart';

class TrainPanelWidget extends StatefulWidget {
  final bool withGraph;
  final VoidCallback? onTapStart;
  final VoidCallback? onTapGenerateSpikes;
  final Orientation orientation;
  const TrainPanelWidget({
    super.key,
    this.withGraph = true,
    this.onTapStart,
    this.onTapGenerateSpikes,
    required this.orientation,
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
    _generationManager = getIt.get();
    _neuralListener = getIt.get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.orientation == Orientation.landscape ? 300 : null,
      padding: const EdgeInsets.all(16),
      child: _buildContent(),
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
      child: SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildNeuralTree() {
    return Center(
      child: SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildLandscapeForm() {
    return SingleChildScrollView(
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
                const SizedBox(height: 16),
                if (!widget.withGraph) ..._getTestButtons()
              ]
            : [
                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    onPressed: _start,
                    child: Text(started ? 'Again' : 'Start'),
                  ),
                )
              ],
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.orientation) {
      case Orientation.portrait:
        return _buildPortraitForm();
      default:
        return _buildLandscapeForm();
    }
  }

  Widget _buildPortraitForm() {
    double height = MediaQuery.of(context).size.height * 0.5;
    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: started
              ? [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTitle(),
                      if (widget.withGraph) Expanded(child: _buildGraph()),
                    ],
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  Column(
                    children: [
                      const Text('Neural of the better'),
                      const SizedBox(height: 16),
                      Expanded(child: _buildNeuralTree()),
                    ],
                  ),
                  if (!widget.withGraph) ..._getTestButtons(),
                ]
              : [
                  SizedBox(
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

  _getTestButtons() {
    return [
      SizedBox(
        width: double.maxFinite,
        child: ElevatedButton(
          onPressed: _start,
          child: Text(started ? 'Again' : 'Start'),
        ),
      ),
      SizedBox(height: 16),
      SizedBox(
        width: double.maxFinite,
        child: ElevatedButton(
          onPressed: widget.onTapGenerateSpikes,
          child: Text('Generate spikes'),
        ),
      )
    ];
  }
}
