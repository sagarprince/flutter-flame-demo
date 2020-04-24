import 'package:flutter/material.dart';
import 'package:flame/util.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_flame_demo/game_service.dart';
import 'package:flutter_flame_demo/chain_reaction_game.dart';
import 'package:flutter_flame_demo/winner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white, // Color for Android
      statusBarBrightness:
          Brightness.dark // Dark == white status bar -- for IOS.
      ));
  Flame.audio.disableLog();
  Util flameUtil = Util();
//  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);
  await Flame.audio.loadAll(<String>[
    'pop.mp3',
  ]);
  final ChainReactionGame chainReactionGame = new ChainReactionGame();
  runApp(MyGame(game: chainReactionGame));
}

class MyGame extends StatelessWidget {
  final ChainReactionGame game;

  MyGame({Key key, this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => gameService),
      ],
      child: MaterialApp(
        title: 'Chain Reaction Game',
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
  final ChainReactionGame game;

  Home({Key key, this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
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
