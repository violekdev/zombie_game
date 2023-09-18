import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:zombie_game/constants/assets.dart';
import 'package:zombie_game/zombie_game/widgets/components.dart';

class ZombieGame extends FlameGame with HasKeyboardHandlerComponents {
  ZombieGame() : world = ZombieWorld() {
    cameraComponent = CameraComponent(world: world);
    images.prefix = '';
  }

  late final CameraComponent cameraComponent;
  final ZombieWorld world;

  @override
  FutureOr<void> onLoad() async {
    //ImageCache
    await images.loadAll([
      Assets.assets_characters_Adventurer_Poses_adventurer_action1_png,
      Assets.assets_characters_Zombie_Poses_zombie_cheer1_png,
      Assets.assets_town_tile_0000_png,
    ]);

    await addAll([cameraComponent, world]);

    // TODO(dev): disable debug mode here
    debugMode = true;

    return super.onLoad();
  }
}
