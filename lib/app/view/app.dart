import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:zombie_game/l10n/l10n.dart';
import 'package:zombie_game/zombie_game/zombie_game.dart';

class App extends StatelessWidget {
  const App({
    required this.game,
    super.key,
  });

  final ZombieGame game;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Color(0xFF13B9FF)),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: GameWidget(game: game),
    );
  }
}
