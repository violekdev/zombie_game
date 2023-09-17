import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:zombie_game/constants/constants.dart';
import 'package:zombie_game/zombie_game/widgets/land.dart';
import 'package:zombie_game/zombie_game/widgets/player.dart';
import 'package:zombie_game/zombie_game/zombie_game.dart';

class ZombieWorld extends World with HasGameRef<ZombieGame> {
  ZombieWorld({super.children});

  final List<Land> land = [];
  late final Player player;
  late TiledComponent map;

  late Vector2 size = Vector2(
    map.tileMap.map.width.toDouble() * GameSizeConstants.worldTileSzie,
    map.tileMap.map.height.toDouble() * GameSizeConstants.worldTileSzie,
  );

  @override
  FutureOr<void> onLoad() async {
    map = await TiledComponent.load('world.tmx', Vector2.all(GameSizeConstants.worldTileSzie));

    player = Player();

    await addAll([map, player]);

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
