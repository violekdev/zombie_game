import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:zombie_game/constants/assets.dart';
import 'package:zombie_game/zombie_game/zombie_game.dart';

class Zombie extends SpriteComponent with HasGameReference<ZombieGame> {
  Zombie({required super.position})
      : super(
          size: Vector2.all(64),
          anchor: Anchor.center,
          priority: 1,
        );

  @override
  FutureOr<void> onLoad() {
    // Zombie Sprite from cache
    sprite = Sprite(game.images.fromCache(Assets.assets_characters_Zombie_Poses_zombie_cheer1_png));

    return super.onLoad();
  }
}
