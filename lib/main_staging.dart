import 'package:flutter/material.dart';
import 'package:zombie_game/app/app.dart';
import 'package:zombie_game/bootstrap.dart';
import 'package:zombie_game/zombie_game/zombie_game.dart';

void main() {
  bootstrap(() {
    WidgetsFlutterBinding.ensureInitialized();
    final game = ZombieGame();
    return App(game: game);
  });
}
