import 'package:bonfire/bonfire.dart';
import 'package:npc_neural/game/components/knight.dart';
import 'package:npc_neural/game/npc_neural_game.dart';
import 'package:npc_neural/util/spritesheet.dart';

class Chest extends GameDecoration with DragGesture {
  late ShapeHitbox hitbox;
  Chest({
    required super.position,
  }) : super.withAnimation(
          animation: Spritesheet.chest,
          size: Vector2.all(NpcNeuralGame.tilesize),
        );

  @override
  Future<void> onLoad() {
    add(hitbox = RectangleHitbox(size: size));
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Knight) {
      Spritesheet.chestOpen.then((value) => setAnimation(value));
    }
    super.onCollision(intersectionPoints, other);
  }
}
