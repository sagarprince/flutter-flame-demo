import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_demo/screens/versus_bot_screen.dart';
import 'package:flutter_flame_demo/utils/constants.dart';
import 'package:flutter_flame_demo/screens/landing_screen.dart';
import 'package:flutter_flame_demo/screens/game_screen.dart';
import 'package:flutter_flame_demo/screens/winner_screen.dart';
import 'package:flutter_flame_demo/screens/result_screen.dart';

class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastLinearToSlowEaseIn,
              ),
            ),
            child: child,
          ),
        );
}

class Routes {
  static builder(settings) {
    switch (settings.name) {
      case AppRoutes.base:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => LandingScreen());
        break;
      case AppRoutes.versus_bot:
        return CupertinoPageRoute(
            settings: settings, builder: (_) => VersusBotScreen());
        break;
      case AppRoutes.play_game:
        return ScaleRoute(page: GameScreen());
        break;
      case AppRoutes.winner:
        return ScaleRoute(page: WinnerScreen());
        break;
      case AppRoutes.result:
        return ScaleRoute(page: ResultScreen());
        break;
    }
  }
}
