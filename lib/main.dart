import 'package:flutter/material.dart';
import 'package:flame/util.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_flame_demo/game_provider.dart';
import 'package:flutter_flame_demo/box_game.dart';
import 'package:flutter_flame_demo/winner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white, // Color for Android
      statusBarBrightness:
          Brightness.dark // Dark == white status bar -- for IOS.
      ));
  Util flameUtil = Util();
//  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);
  final BoxGame boxGame = new BoxGame();
  runApp(MyGame(game: boxGame));
}

class MyGame extends StatelessWidget {
  final BoxGame game;

  MyGame({Key key, this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => gameProvider),
      ],
      child: MaterialApp(
        title: 'Flame Game Demo',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xff222222),
          body: Home(game: game),
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  final BoxGame game;

  Home({Key key, this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: game.widget,
            ),
            Positioned.fill(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[Winner()],
            )),
          ],
        ),
      ),
    );
  }
}
