import 'package:bonfire/bonfire.dart';
import 'package:npc_neural/game/npc_neural_game.dart';

class FinishLineTile extends GameComponent with UseSprite {
  FinishLineTile({required Vector2 position, required Sprite sprite}) {
    this.position = position;
    size = Vector2.all(NpcNeuralGame.tilesize);
    this.sprite = sprite;
  }
}
