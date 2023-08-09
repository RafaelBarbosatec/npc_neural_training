import 'package:bonfire/bonfire.dart';

class Spritesheet {
  static Future<SpriteAnimation> get knightRun {
    return SpriteAnimation.load(
      'knight_run.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.1,
        textureSize: Vector2.all(16),
      ),
    );
  }

  static Future<SpriteAnimation> get knightIdle {
    return SpriteAnimation.load(
      'knight_idle.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.1,
        textureSize: Vector2.all(16),
      ),
    );
  }

  static Future<SpriteAnimation> get chest {
    return SpriteAnimation.load(
      'chest_spritesheet.png',
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.1,
        textureSize: Vector2.all(16),
      ),
    );
  }

  static Future<SpriteAnimation> get chestOpen {
    return Sprite.load(
      'chest_open.png',
    ).toAnimation();
  }

  static Future<SpriteAnimation> get fireball {
    return SpriteAnimation.load(
      'fireball_right.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.15,
        textureSize: Vector2.all(23),
      ),
    );
  }

  static Future<SpriteAnimation> get spikes {
    return SpriteAnimation.load(
      'spikes.png',
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.1,
        textureSize: Vector2.all(16),
      ),
    );
  }

  static Future<Sprite> get finishLine {
    return Sprite.load('finish_line.png', srcSize: Vector2.all(16));
  }
  static Future<Sprite> get finishLineInverted {
    return Sprite.load('finish_line_inverted.png', srcSize: Vector2.all(16));
  }
}
