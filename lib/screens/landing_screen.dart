import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flame_demo/models/player.dart';
import 'package:flutter_flame_demo/utils/constants.dart';
import 'package:flutter_flame_demo/utils/styles.dart';
import 'package:flutter_flame_demo/blocs/events.dart';
import 'package:flutter_flame_demo/blocs/state.dart';
import 'package:flutter_flame_demo/blocs/bloc.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  color: Colors.transparent,
                  highlightColor: Colors.grey.withOpacity(0.6),
                  elevation: 0.0,
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'Play Game',
                    style: TextStyle(
                        fontFamily: AppFonts.secondary,
                        fontSize: 28.0,
                        color: AppColors.white),
                  ),
                  onPressed: () {
                    BlocProvider.of<CRBloc>(context).add(StartGameEvent(
                        gameMode: GameMode.PlayWithBot,
                        players: [
                          Player('Sagar', 'red', true),
                          Player('Vaishali', 'blue', false),
                          Player('Bot', 'green', false),
                        ]));
                    Navigator.of(context).pushNamed(AppRoutes.play_game);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
