import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/animation.dart';
import 'package:zombie_game/constants/assets.dart';
import 'package:zombie_game/constants/constants.dart';
import 'package:zombie_game/zombie_game/widgets/components.dart';
import 'package:zombie_game/zombie_game/widgets/utilities/utilities.dart';
import 'package:zombie_game/zombie_game/zombie_game.dart';

enum ZombieState { wander, chase }

class Zombie extends SpriteComponent with HasGameReference<ZombieGame>, UnwalkableTerrainChecker {
  Zombie({
    required super.position,
    this.speed = GameSizeConstants.worldTileSize * 4,
    this.debug = false,
  }) : super(
          size: Vector2.all(64),
          anchor: Anchor.center,
          priority: 1,
        );

  double speed;
  LineComponent? visualizedPathToPlayer;
  bool debug;
  final double maximumFollowDistance = GameSizeConstants.worldTileSize * 10;
  late ZombieState state;

  Random random = Random();

  Vector2? wanderPath;

  // The maximum angle to the left (and/or right) the zombie will veer between
  static const maxVeerDeg = 45;
  static const minVeerDurationMs = 3000; // in miliseconds
  static const maxVeerDurationMs = 6000; // in miliseconds
  late Duration veerDuration;
  late DateTime veerStartedAt;
  late bool clockwiseVeerFirst;

  // For Lurch of the Zombie steps
  static const minLurchDurationMs = 300; // in miliseconds
  static const maxLurchDurationMs = 1500; // in miliseconds
  late Duration lurchDuration;
  late DateTime lurchStartedAt;
  late Curve lurchCurve;

  static const minWanderDelta = -3;
  static const maxWanderDelta = 3;

  /// Amount of time to follow a given wander path before resetting
  Duration? wanderLength;
  DateTime? wanderStartedAt;
  int? wanderDeltaDeg;

  final curves = <Curve>[
    Curves.easeIn,
    Curves.easeInBack,
    Curves.easeInOut,
    Curves.easeInOutBack,
  ];

  @override
  FutureOr<void> onLoad() {
    // Zombie Sprite from cache
    sprite = Sprite(game.images.fromCache(Assets.assets_characters_Zombie_Poses_zombie_cheer1_png));

    setVeer();
    setLurch();
    setStateToWander();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateState(dt);
    final pathToPlayer = Line(position, game.world.player.position);

    switch (state) {
      case ZombieState.wander:
        wander(dt);
      case ZombieState.chase:
        chase(pathToPlayer, dt);
    }
    super.update(dt);
  }

  void updateState(double dt) {
    final pathToPlayer = Line(position, game.world.player.position);

    if (pathToPlayer.length > maximumFollowDistance) {
      if (state != ZombieState.wander) {
        setStateToWander();
      }
    } else {
      state = ZombieState.chase;
    }
  }

  // Previously followPlayer()
  void chase(Line pathToPlayer, double dt) {
    wanderPath = null;
    wanderDeltaDeg = null;
    final pathToTake = applyVeerToPath(pathToPlayer);
    _debugPathfinding(pathToPlayer: pathToTake);
    moveAlongPath(pathToPlayer: pathToTake, dt: dt);
  }

  void setStateToWander() {
    state = ZombieState.wander;
    wanderPath = getRandomWanderPath();
    wanderStartedAt = DateTime.now();
    wanderDeltaDeg ??= random.nextInt(maxWanderDelta - minWanderDelta) + minWanderDelta;
    wanderLength = const Duration(milliseconds: 1500);
  }

  void wander(double dt) {
    if (DateTime.now().difference(wanderStartedAt!) > wanderLength!) {
      setStateToWander();
    }
    wanderPath!.rotate(wanderDeltaDeg! * degrees2Radians);
    applyMovement(wanderPath!, applyLurch(dt / 2));
  }

  Vector2 getRandomWanderPath() {
    final deg = random.nextInt(360);
    return Vector2(1, 0)..rotate(deg * degrees2Radians);
  }

  Line applyVeerToPath(Line path) {
    // Percentage into the total veer we currently are
    var percentVeered = DateTime.now().difference(veerStartedAt).inMilliseconds / veerDuration.inMilliseconds;

    if (percentVeered > 1.0) {
      setVeer();
      percentVeered = 0;
    }

    late double veerAngleDeg;
    if (percentVeered < 0.25) {
      veerAngleDeg = percentVeered * 4 * maxVeerDeg;
    } else if (percentVeered < 0.5) {
      veerAngleDeg = (0.5 - percentVeered) * 4 * maxVeerDeg;
    } else if (percentVeered < 0.75) {
      veerAngleDeg = -((percentVeered - 0.5) * 4 * maxVeerDeg);
    } else {
      veerAngleDeg = -(1 - percentVeered) * 4 * maxVeerDeg;
    }

    if (!clockwiseVeerFirst) {
      veerAngleDeg *= -1;
    }

    final rotated = path.vector2..rotate(veerAngleDeg * degrees2Radians);

    return Line(path.start, path.start + rotated);
  }

  void setVeer() {
    veerStartedAt = DateTime.now();
    veerDuration = Duration(milliseconds: random.nextInt(maxVeerDurationMs - minVeerDurationMs) + minVeerDurationMs);
    clockwiseVeerFirst = random.nextBool();
  }

  void setLurch() {
    lurchStartedAt = DateTime.now();
    lurchDuration = Duration(milliseconds: random.nextInt(maxLurchDurationMs - minLurchDurationMs) + minLurchDurationMs);
    curves.shuffle();
    lurchCurve = curves.first;
  }

  double applyLurch(double speed) {
    var percentLurched = DateTime.now().difference(lurchStartedAt).inMilliseconds / lurchDuration.inMilliseconds;

    if (percentLurched > 1.0) {
      setLurch();
      percentLurched = 0;
    }

    percentLurched = Curves.easeIn.transform(percentLurched);

    return percentLurched * speed;
  }

  void moveAlongPath({required Line pathToPlayer, required double dt}) {
    final collision = _getUnwalkableCollision(pathToPlayer: pathToPlayer);

    var newPathToPlayer = pathToPlayer;

    if (collision != null) {
      final distanceToStart = Line(game.world.player.position, collision.start).length2;
      final distanceToEnd = Line(game.world.player.position, collision.end).length2;

      if (distanceToStart < distanceToEnd) {
        newPathToPlayer = Line(position, collision.start).extend(1.5);
      } else {
        newPathToPlayer = Line(position, collision.end).extend(1.5);
      }
    }

    final movement = newPathToPlayer.vector2.normalized();

    applyMovement(movement, applyLurch(dt));
  }

  void applyMovement(Vector2 movement, double dt) {
    final originalPosition = position.clone();
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
          unwalkableBoundary = line;
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
    if (!debug) return;

    if (visualizedPathToPlayer == null) {
      visualizedPathToPlayer = LineComponent.blue(line: pathToPlayer);
      game.world.add(visualizedPathToPlayer!);
    } else {
      visualizedPathToPlayer!.line = pathToPlayer;
    }
  }
}
