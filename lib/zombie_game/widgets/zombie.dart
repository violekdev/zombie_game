import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:zombie_game/constants/assets.dart';
import 'package:zombie_game/constants/constants.dart';
import 'package:zombie_game/zombie_game/widgets/components.dart';
import 'package:zombie_game/zombie_game/widgets/utilities/utilities.dart';
import 'package:zombie_game/zombie_game/zombie_game.dart';

class Zombie extends SpriteComponent with HasGameReference<ZombieGame>, UnwalkableTerrainChecker {
  Zombie({required super.position, this.speed = GameSizeConstants.worldTileSzie * 2})
      : super(
          size: Vector2.all(64),
          anchor: Anchor.center,
          priority: 1,
        );

  double speed;
  LineComponent? visualizedPathToPlayer;

  @override
  FutureOr<void> onLoad() {
    // Zombie Sprite from cache
    sprite = Sprite(game.images.fromCache(Assets.assets_characters_Zombie_Poses_zombie_cheer1_png));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    final pathToPlayer = Line(position, game.world.player.position);
    _debugPathfinding(pathToPlayer: pathToPlayer);
    moveAlongPath(pathToPlayer: pathToPlayer, dt: dt);
    super.update(dt);
  }

  void moveAlongPath({required Line pathToPlayer, required double dt}) {
    final originalPosition = position.clone();

    Line? collision = _getUnwalkableCollision(pathToPlayer: pathToPlayer);

    var newPathToPlayer = pathToPlayer;

    if (collision != null) {
      final distanceToStart = Line(game.world.player.position, collision.start).length2;
      final distanceToEnd = Line(game.world.player.position, collision.end).length2;

      if (distanceToStart < distanceToEnd) {
        newPathToPlayer = Line(position, collision.start).extend(1.1);
      } else {
        newPathToPlayer = Line(position, collision.end).extend(1.1);
      }
    }

    final movement = newPathToPlayer.vector2.normalized();
    final movementThisFrame = movement * speed * dt;

    position.add(movementThisFrame);

    checkMovement(movementThisFrame: movementThisFrame, originalPosition: originalPosition);
  }

  Line? _getUnwalkableCollision({required Line pathToPlayer}) {
    Vector2? nearestIntersection;
    double? shortestLength;
    Line? unwalkableBoundary;

    for (final line in game.world.unwalkableComponentEdges) {
      final intersection = pathToPlayer.intersectsAt(line);
      if (intersection != null) {
        if (nearestIntersection == null) {
          nearestIntersection = intersection;
          shortestLength = Line(position, intersection).length2;
        } else {
          final lengthToThisPoint = Line(position, intersection).length2;
          if (lengthToThisPoint < shortestLength!) {
            shortestLength = lengthToThisPoint;
            nearestIntersection = intersection;
            unwalkableBoundary = line;
          }
        }
      }
    }
    return unwalkableBoundary;
  }

  void _debugPathfinding({required Line pathToPlayer}) {
    if (visualizedPathToPlayer == null) {
      visualizedPathToPlayer = LineComponent.blue(line: pathToPlayer);
      game.world.add(visualizedPathToPlayer!);
    } else {
      visualizedPathToPlayer!.line = pathToPlayer;
    }
  }
}
