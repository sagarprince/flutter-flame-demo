import 'package:flutter/material.dart';
import 'package:flame/util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flame_demo/provider.dart';
import 'package:flutter_flame_demo/box_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Util flameUtil = Util();
//  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);
  final Provider provider = new Provider();
  final BoxGame boxGame = new BoxGame(provider);
  runApp(MyGame(game: boxGame));
}

class MyGame extends StatelessWidget {
  final BoxGame game;

  MyGame({Key key, this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flame Game Demo',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xff222222),
        body: Home(game: game),
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
          ],
        ),
      ),
    );
  }
}
