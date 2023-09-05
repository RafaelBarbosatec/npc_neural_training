import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:npc_neural/game/components/finish_line.dart';
import 'package:npc_neural/game/components/generation_manager.dart';
import 'package:npc_neural/game/npc_neural_game.dart';
import 'package:npc_neural/neural_network_utils/models/sequential_with_vatiation.dart';
import 'package:npc_neural/util/better_neural_listener.dart';
import 'package:npc_neural/util/spritesheet.dart';

class SeeResult {
  final double distance;
  final bool isTarget;
  final Vector2? intersectionPoint;

  SeeResult(this.distance, this.isTarget, this.intersectionPoint);
}

class Knight extends SimpleAlly with BlockMovementCollision {
  final Paint _rayCollisionPaint = Paint()
    ..color = Colors.red.withOpacity(0.4)
    ..strokeWidth = 1.2;

  final Paint _rayTargetPaint = Paint()
    ..color = Colors.green.withOpacity(0.4)
    ..strokeWidth = 1.4;

  final bool training;
  SequentialWithVariation neuralnetWork;
  late ShapeHitbox hitbox;
  List<SeeResult> eyesResult = [];

  IntervalTick? lifeTime;
  IntervalTick? checkStopTime;

  int timeLifeInterval = 10000;
  int checkStopInterval = 500;
  bool winner = false;
  double score = 0;
  double penalty = 0;
  int rank = 0;
  bool get isTheBest => !training ? true : rank == 1;

  final int countEyeLines;

  Knight({
    required super.position,
    required this.neuralnetWork,
    this.training = true,
    this.countEyeLines = 7,
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

  double get maxDistanceVision => NpcNeuralGame.tilesize * 3;

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    if (other is Knight) {
      return false;
    }
    return super.onComponentTypeCheck(other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is FinishLine) {
      if (training) {
        var manager = BonfireInjector().get<GenerationManager>();
        manager.setWin(this);
      }
      winner = true;
      stopMove();
    } else if (training) {
      die();
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
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
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (rank <= 50 && !isDead) {
      if (isTheBest) {
        _renderRayCast(canvas);
      }
      super.render(canvas);
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
    var target = getTarget();
    if (target == null) return;

    List<ShapeHitbox> ignoreHitboxes = _getIgnoreHitboxes(target);

    _watchTheWorld(ignoreHitboxes);

    if (eyesResult.length == countEyeLines) {
      List<double> inputs = eyesResult.map((e) => e.distance).toList();
      final actionresult = neuralnetWork.process(inputs);
      _moveByResult(actionresult);
    }

    if (isTheBest) {
      BonfireInjector().get<BetterNeuralListener>().setNeural(neuralnetWork);
    }
  }

  void _renderRayCast(Canvas canvas) {
    for (var result in eyesResult) {
      final intersectionPoint = result.intersectionPoint?.toOffset();
      if (intersectionPoint != null) {
        final intersection = intersectionPoint - position.toOffset();
        final p = result.isTarget ? _rayTargetPaint : _rayCollisionPaint;
        canvas.drawLine(
          absoluteCenter.toOffset() - position.toOffset(),
          intersection,
          p,
        );
        canvas.drawCircle(intersection, 3, p);
      }
    }
  }

  RaycastResult<ShapeHitbox>? _throwRay(
    double angle,
    List<ShapeHitbox> ignoreHitboxes,
  ) {
    return raycast(
      Vector2(1, 0)..rotate(angle),
      ignoreHitboxes: ignoreHitboxes,
      maxDistance: maxDistanceVision,
    );
  }

  void reset(Vector2 position, SequentialWithVariation newNetwork) {
    this.position = position;
    neuralnetWork = newNetwork;
    winner = false;
    rank = 0;
    score = 0;
    penalty = 0;
    _createTimers();
    revive();
    stopMove(forceIdle: true);
  }

  @override
  void die() {
    stopMove(forceIdle: true);
    super.die();
  }

  FinishLine? _target;

  FinishLine? getTarget() {
    if (hasGameRef) {
      if (_target == null) {
        var query = gameRef.query<FinishLine>();
        if (query.isNotEmpty) {
          return _target = query.first;
        }
      } else {
        return _target;
      }
    }
    return null;
  }

  List<ShapeHitbox> _getIgnoreHitboxes(FinishLine target) {
    List<ShapeHitbox> ignoreHitboxes = gameRef.query<Knight>().map((e) {
      return e.hitbox;
    }).toList();
    ignoreHitboxes.add(target.hitbox);
    return ignoreHitboxes;
  }

  void _watchTheWorld(List<ShapeHitbox> ignoreHitboxes) {
    eyesResult.clear();

    double startAngle = (-90 * pi / 180);
    double angle = (180 * pi / 180) / (countEyeLines - 1);

    List.generate(countEyeLines, (index) {
      final r = _throwRay(startAngle + (angle * index), ignoreHitboxes);
      eyesResult.add(
        SeeResult(
          r?.distance ?? maxDistanceVision,
          r?.hitbox?.parent is FinishLine,
          r?.intersectionPoint,
        ),
      );
    });
  }

  void _moveByResult(List<double> actionresult) {
    setZeroVelocity();

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
    lifeTime = IntervalTick(timeLifeInterval, onTick: die);
    checkStopTime = IntervalTick(checkStopInterval, onTick: _tickCheckStoped);
  }

  void _tickCheckStoped() {
    if (lastDisplacement.x.abs() < 0.2 && lastDisplacement.y.abs() < 0.2) {
      die();
    }
  }
}
