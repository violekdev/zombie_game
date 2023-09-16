import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Player extends SpriteComponent with KeyboardHandler {
  Player({super.position, super.sprite}) : super(size: Vector2.all(64), anchor: Anchor.center);

  Vector2 movement = Vector2.zero();
  double speed = 10;

  @override
  void update(double dt) {
    // final miliseconds = dt * 1000;
    position = position + (movement * speed * dt);
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
      //? return false;
    } else if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        movement = Vector2(movement.x, 0);
      }
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        movement = Vector2(movement.x, 0);
      }
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        movement = Vector2(0, movement.y);
      }
      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        movement = Vector2(0, movement.y);
      }
      //? return false;
    }
    return super.onKeyEvent(event, keysPressed);
    //? return true;
  }
}
