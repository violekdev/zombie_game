import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:zombie_game/constants/constants.dart';
import 'package:zombie_game/zombie_game/widgets/components.dart';
import 'package:zombie_game/zombie_game/widgets/utilities/utilities.dart';
import 'package:zombie_game/zombie_game/zombie_game.dart';

class ZombieWorld extends World with HasGameRef<ZombieGame> {
  ZombieWorld({super.children});

  final unwalkableComponentEdges = <Line>[];
  late final Player player;
  late TiledComponent map;
  late final Zombie zombie;

  late Vector2 size = Vector2(
    map.tileMap.map.width.toDouble() * GameSizeConstants.worldTileSize,
    map.tileMap.map.height.toDouble() * GameSizeConstants.worldTileSize,
  );

  @override
  FutureOr<void> onLoad() async {
    map = await TiledComponent.load('world.tmx', Vector2.all(GameSizeConstants.worldTileSize));

    final objectLayer = map.tileMap.getLayer<ObjectGroup>('Objects')!;
    for (final object in objectLayer.objects) {
      if (!object.isPolygon) continue;
      if (!object.properties.byName.containsKey('blocksMovement')) return;

      final vertices = <Vector2>[];

      Vector2? firstPoint;
      Vector2? nextPoint;
      Vector2? lastPoint;

      for (final point in object.polygon) {
        nextPoint = Vector2((point.x + object.x) * GameSizeConstants.worldScale, (point.y + object.y) * GameSizeConstants.worldScale);
        vertices.add(nextPoint);

        firstPoint ??= nextPoint;

        // If there is a last point, or this is the end of the list, we have a line to add to our cached list of lines
        if (lastPoint != null) {
          unwalkableComponentEdges.add(Line(lastPoint, nextPoint));
        }

        lastPoint = nextPoint;
      }
      unwalkableComponentEdges.add(Line(lastPoint!, firstPoint!));
      add(UnwalkableComponent(vertices));
    }

    for (final line in unwalkableComponentEdges) {
      add(LineComponent.red(line: line));
    }

    zombie = Zombie(
      position: Vector2(GameSizeConstants.worldTileSize * 14.6, GameSizeConstants.worldTileSize * 6.5),
    );

    player = Player();

    await addAll([map, player, zombie]);

    const zombiesToAdd = 15;
    var counter = 0;

    while (counter < zombiesToAdd) {
      final x = Random().nextInt(20) + 1;
      final y = Random().nextInt(20) + 1;
      add(
        Zombie(position: Vector2(GameSizeConstants.worldTileSize * x, GameSizeConstants.worldTileSize * y)),
      );
      counter++;
    }

    gameRef.cameraComponent.follow(player);

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    setCameraBounds(gameSize: size);
  }

  void setCameraBounds({required Vector2 gameSize}) {
    gameRef.cameraComponent.setBounds(
      Rectangle.fromLTRB(
        gameSize.x / 2,
        gameSize.y / 2,
        size.x - gameSize.x / 2,
        size.y - gameSize.y / 2,
      ),
    );
  }
}
