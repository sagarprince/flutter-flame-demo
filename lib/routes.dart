import 'package:flutter/material.dart';
import 'package:flutter_flame_demo/utils/constants.dart';
import 'package:flutter_flame_demo/screens/landing_screen.dart';
import 'package:flutter_flame_demo/screens/game_screen.dart';

class Routes {
  static builder(settings) {
    switch (settings.name) {
      case AppRoutes.base:
        return MaterialPageRoute(
            settings: settings, builder: (_) => LandingScreen());
        break;
      case AppRoutes.play_game:
        return MaterialPageRoute(
            settings: settings, builder: (_) => GameScreen());
        break;
    }
  }
}
