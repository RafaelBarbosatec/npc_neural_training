import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:npc_neural/util/strage.dart';
import 'package:synadart/synadart.dart';

class SavedNetworksDialog extends StatefulWidget {
  final Function(Sequential value, bool train) networkSlected;
  const SavedNetworksDialog({super.key, required this.networkSlected});

  static show(BuildContext context,
      Function(Sequential value, bool train) networkSlected) {
    return showDialog(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(54),
          child: Material(
            borderRadius: BorderRadius.circular(20),
            child: SavedNetworksDialog(networkSlected: networkSlected),
          ),
        );
      },
    );
  }

  @override
  State<SavedNetworksDialog> createState() => _SavedNetworksDialogState();
}

class _SavedNetworksDialogState extends State<SavedNetworksDialog> {
  late NeuralStorage storage;
  @override
  void initState() {
    storage = BonfireInjector().get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<String>>(
      future: storage.getKeys(),
      builder: (context, snapshot) {
        Set<String>? data = snapshot.data;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Select a network to use')),
                  IconButton(
                    onPressed: _deleteAll,
                    icon: const Icon(Icons.delete_forever_outlined),
                  )
                ],
              ),
              Container(
                width: double.maxFinite,
                color: Colors.black,
                height: 1,
              ),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: data?.length ?? 0,
                  itemBuilder: (context, index) {
                    var key = data!.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(key)),
                                  IconButton(
                                    onPressed: () => _copy(key, storage),
                                    icon: const Icon(Icons.copy),
                                  ),
                                  IconButton(
                                    onPressed: () => _delete(key, storage),
                                    icon: const Icon(Icons.delete),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final network = await storage.get(key);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                        if (network != null) {
                                          widget.networkSlected(
                                            network,
                                            false,
                                          );
                                        }
                                      },
                                      child: const Text('Use'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final network = await storage.get(key);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                        if (network != null) {
                                          widget.networkSlected(network, true);
                                        }
                                      },
                                      child: const Text('Train'),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: const Text('Sair'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _copy(String key, NeuralStorage storage) async {
    final network = await storage.get(key);
    if (network != null) {
      Clipboard.setData(ClipboardData(text: jsonEncode(network.toMap())));
    }
  }

  void _delete(String key, NeuralStorage storage) async {
    await storage.delete(key);
    setState(() {});
  }

  void _deleteAll() async {
    await storage.clear();
    setState(() {});
  }
}