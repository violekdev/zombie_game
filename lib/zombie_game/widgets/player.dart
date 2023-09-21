import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/services.dart';
import 'package:zombie_game/constants/assets.dart';
import 'package:zombie_game/constants/constants.dart';
import 'package:zombie_game/zombie_game/widgets/utilities/utilities.dart';
import 'package:zombie_game/zombie_game/zombie_game.dart';

class Player extends SpriteComponent with KeyboardHandler, HasGameReference<ZombieGame>, UnwalkableTerrainChecker {
  Player()
      : super(
          position: Vector2(GameSizeConstants.worldTileSzie * 9.6, GameSizeConstants.worldTileSzie * 2.5),
          size: Vector2.all(64),
          anchor: Anchor.center,
          priority: 1,
        ) {
    halfSize = size / 2;
  }

  late Vector2 halfSize;
  late Vector2 maxPosition = game.world.size - halfSize;
  Vector2 movement = Vector2.zero();
  double speed = GameSizeConstants.worldTileSzie * 4; // TODO(dev): change speed here when needed

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache(Assets.assets_characters_Adventurer_Poses_adventurer_action1_png));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Save this to use after we zero out movement for unwalkable terrain
    final originalPosition = position.clone();

    final movementThisFrame = movement * speed * dt;

    // Fake update the positio so our anchot calculations take into account what we want to do this turn.
    position.add(movementThisFrame);

    checkMovement(movementThisFrame: movementThisFrame, originalPosition: originalPosition);

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        movement = Vector2(movement.x, -1);
      }
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        movement = Vector2(movement.x, 1);
      }
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        movement = Vector2(-1, movement.y);
      }
      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        movement = Vector2(1, movement.y);
      }
      return false;
    } else if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        movement.y = keysPressed.contains(LogicalKeyboardKey.keyS) ? 1 : 0;
        // movement = Vector2(movement.x, keysPressed.contains(LogicalKeyboardKey.keyS) ? 1 : 0);
      }
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        movement.y = keysPressed.contains(LogicalKeyboardKey.keyW) ? -1 : 0;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        movement.x = keysPressed.contains(LogicalKeyboardKey.keyD) ? 1 : 0;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        movement.x = keysPressed.contains(LogicalKeyboardKey.keyA) ? -1 : 0;
      }
      return false;
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
