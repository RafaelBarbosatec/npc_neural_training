import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:npc_neural/game/components/chest.dart';
import 'package:npc_neural/game/components/generation_manager.dart';
import 'package:npc_neural/game/npc_neural_game.dart';
import 'package:npc_neural/neural_network_utils/models/sequential_with_vatiation.dart';
import 'package:npc_neural/util/better_neural_listener.dart';
import 'package:npc_neural/util/spritesheet.dart';

class Knight extends SimpleAlly with BlockMovementCollision {
  final Paint _rayPaint = Paint()
    ..color = Colors.green.withOpacity(0.4)
    ..strokeWidth = 1.5;

  final bool training;
  SequentialWithVariation neuralnetWork;
  late ShapeHitbox hitbox;
  List<RaycastResult<ShapeHitbox>> eyesResult = [];

  IntervalTick? lifeTime;
  IntervalTick? checkStopTime;

  int timeLifeInterval = 10000;
  int checkStopInterval = 500;
  bool winner = false;
  double score = 0;
  int rank = 0;
  bool get isTheBest => !training ? true : rank == 1;

  Knight({
    required super.position,
    required this.neuralnetWork,
    this.training = true,
  }) : super(
          size: Vector2.all(NpcNeuralGame.tilesize),
          animation: SimpleDirectionAnimation(
            idleRight: Spritesheet.knightIdle,
            runRight: Spritesheet.knightRun,
          ),
          speed: NpcNeuralGame.tilesize * 3,
        ) {
    _createTimers();
  }

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    if (other is Knight) {
      return false;
    }
    return super.onComponentTypeCheck(other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Chest) {
      if (training) {
        var manager = BonfireInjector().get<GenerationManager>();
        winner = manager.setWin(this);
      } else {
        winner = true;
      }
      stopMove();
    } else if (training) {
      die();
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isDead && !winner) {
      if (checkInterval('execNeural', 25, dt)) {
        _execNetwork(dt);
        opacity = isTheBest ? 1 : 0.4;
      }
      if (training) {
        lifeTime?.update(dt);
        checkStopTime?.update(dt);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (rank < 20 && !isDead) {
      super.render(canvas);
      if (isTheBest) {
        _renderRayCast(canvas);
      }
    }
  }

  @override
  Future<void> onLoad() async {
    hitbox = RectangleHitbox(
      size: Vector2((size.x / 4) - 1, size.x / 2),
      position: Vector2((size.x / 2) + 1, size.y / 4),
      isSolid: true,
    );
    await add(hitbox);
    return super.onLoad();
  }

  void _execNetwork(double dt) {
    var chest = getTarget();
    if (chest == null) return;

    List<ShapeHitbox> ignoreHitboxes = _getIgnoreHitboxes(chest);

    _watchTheWorld(ignoreHitboxes);

    if (eyesResult.length == 5) {
      List<double> inputs = eyesResult.map((e) => e.distance ?? 0).toList();
      inputs.add(angleTo(chest.absolutePosition));

      final actionresult = neuralnetWork.process(inputs);

      _moveByResult(actionresult);
    }

    if (isTheBest) {
      BonfireInjector().get<BetterNeuralListener>().setNeural(neuralnetWork);
    }
  }

  void _renderRayCast(Canvas canvas) {
    for (var result in eyesResult) {
      final intersectionPoint = result.intersectionPoint!.toOffset();
      canvas.drawLine(
        absoluteCenter.toOffset() - position.toOffset(),
        intersectionPoint - position.toOffset(),
        _rayPaint,
      );
    }
  }

  RaycastResult<ShapeHitbox>? _createRay(
    double angle,
    List<ShapeHitbox> ignoreHitboxes,
  ) {
    return gameRef.raycast(
      Ray2(
        origin: absoluteCenter,
        direction: Vector2(1, 0)..rotate(angle),
      ),
      ignoreHitboxes: ignoreHitboxes,
    );
  }

  void reset(Vector2 position, SequentialWithVariation? newNetwork) {
    this.position = position;
    neuralnetWork = newNetwork ?? neuralnetWork;
    winner = false;
    rank = 0;
    score = 0;
    _createTimers();
    revive();
    stopMove(forceIdle: true);
  }

  @override
  void die() {
    stopMove(forceIdle: true);
    super.die();
  }

  Chest? chest;

  Chest? getTarget() {
    if (hasGameRef) {
      if (chest == null) {
        var query = gameRef.query<Chest>();
        if (query.isNotEmpty) {
          return chest = query.first;
        }
      } else {
        return chest;
      }
    }
    return null;
  }

  List<ShapeHitbox> _getIgnoreHitboxes(Chest chest) {
    List<ShapeHitbox> ignoreHitboxes =
        gameRef.query<Knight>().map((e) => e.hitbox).toList();
    ignoreHitboxes.add(chest.hitbox);
    return ignoreHitboxes;
  }

  void _watchTheWorld(List<ShapeHitbox> ignoreHitboxes) {
    eyesResult.clear();

    var r1 = _createRay(0, ignoreHitboxes);
    if (r1 != null) {
      eyesResult.add(r1);
    }

    var r2 = _createRay(0.349066, ignoreHitboxes);
    if (r2 != null) {
      eyesResult.add(r2);
    }

    var r3 = _createRay(0.698132, ignoreHitboxes);
    if (r3 != null) {
      eyesResult.add(r3);
    }

    var r5 = _createRay(-0.349066, ignoreHitboxes);
    if (r5 != null) {
      eyesResult.add(r5);
    }

    var r6 = _createRay(-0.698132, ignoreHitboxes);
    if (r6 != null) {
      eyesResult.add(r6);
    }
  }

  void _moveByResult(List<double> actionresult) {
    velocity = Vector2.zero();

    bool goRight = actionresult[0] > 0;
    bool goLeft = actionresult[1] > 0;
    bool goUp = actionresult[2] > 0;
    bool goDown = actionresult[3] > 0;

    bool move = false;

    if (goRight && !goLeft) {
      moveRight();
      move = true;
    } else if (goLeft && !goRight) {
      moveLeft();
      move = true;
    }

    if (goUp && !goDown) {
      moveUp();
      move = true;
    } else if (goDown && !goUp) {
      moveDown();
      move = true;
    }

    if (!move) {
      stopMove();
    }
  }

  void _createTimers() {
    lifeTime = IntervalTick(timeLifeInterval, tick: die);
    checkStopTime = IntervalTick(checkStopInterval, tick: _tickCheckStoped);
  }

  void _tickCheckStoped() {
    if (lastDisplacement.x.abs() < 0.7 && lastDisplacement.y.abs() < 0.7) {
      die();
    }
    if (chest != null && absoluteCenter.x > chest!.absoluteCenter.x) {
      die();
    }
  }
}
