import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:zombie_game/constants/constants.dart';
import 'package:zombie_game/zombie_game/widgets/components.dart';
import 'package:zombie_game/zombie_game/zombie_game.dart';

class ZombieWorld extends World with HasGameRef<ZombieGame> {
  ZombieWorld({super.children});

  final unwalkableComponentEdges = <Line>[];
  late final Player player;
  late TiledComponent map;
  late final Zombie zombie;

  late Vector2 size = Vector2(
    map.tileMap.map.width.toDouble() * GameSizeConstants.worldTileSzie,
    map.tileMap.map.height.toDouble() * GameSizeConstants.worldTileSzie,
  );

  @override
  FutureOr<void> onLoad() async {
    map = await TiledComponent.load('world.tmx', Vector2.all(GameSizeConstants.worldTileSzie));

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
          unwalkableComponentEdges.add(Line(start: lastPoint, end: nextPoint));
        }

        lastPoint = nextPoint;
      }
      unwalkableComponentEdges.add(Line(start: lastPoint!, end: firstPoint!));
      add(UnwalkableComponent(vertices));
    }

    zombie = Zombie(
      position: Vector2(GameSizeConstants.worldTileSzie * 14.6, GameSizeConstants.worldTileSzie * 6.5),
    );

    player = Player();

    await addAll([map, player, zombie]);

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

class Line {
  Line({
    required this.start,
    required this.end,
  });

  final Vector2 start;
  final Vector2 end;

  List<double> asList() => [start.x, start.y, end.x, end.y];

  double get slope {
    return end.y - start.y / end.x - start.x;
  }
}
