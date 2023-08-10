import 'package:bonfire/bonfire.dart';
import 'package:npc_neural/util/spritesheet.dart';

class Spikes extends GameDecoration with DragGesture {
  Spikes({
    required super.position,
  }) : super.withAnimation(
          size: Vector2.all(16),
          animation: Spritesheet.spikes,
        );

  @override
  Future<void> onLoad() {
    add(RectangleHitbox(size: size, isSolid: true));
    return super.onLoad();
  }
}
