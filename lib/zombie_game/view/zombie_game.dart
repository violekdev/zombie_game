import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:zombie_game/constants/assets.dart';
import 'package:zombie_game/zombie_game/widgets/components.dart';

class ZombieGame extends FlameGame with HasKeyboardHandlerComponents {
  ZombieGame() : _world = ZombieWorld() {
    cameraComponent = CameraComponent(world: _world);
    images.prefix = '';
  }

  late final CameraComponent cameraComponent;
  final ZombieWorld _world;

  @override
  FutureOr<void> onLoad() async {
    //ImageCache
    await images.loadAll([
      Assets.assets_characters_Adventurer_Poses_adventurer_action1_png,
      Assets.assets_town_tile_0000_png,
    ]);

    cameraComponent.viewfinder.anchor = Anchor.center;

    await addAll([cameraComponent, _world]);

    cameraComponent.follow(_world.player);

    return super.onLoad();
  }
}
