import 'package:flutter/material.dart';
import 'package:flutter_flame_demo/utils/constants.dart';
import 'package:flutter_flame_demo/utils/styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flame_demo/models/player.dart';
import 'package:flutter_flame_demo/blocs/events.dart';
import 'package:flutter_flame_demo/blocs/state.dart';
import 'package:flutter_flame_demo/blocs/bloc.dart';
import 'package:flutter_flame_demo/widgets/animated_button.dart';
import 'package:flutter_flame_demo/widgets/color_chooser.dart';
import 'package:flutter_flame_demo/widgets/background.dart';
import 'package:flutter_flame_demo/widgets/positional_back_button.dart';

class MultiPlayerOfflineScreen extends StatefulWidget {
  MultiPlayerOfflineScreen({Key key}) : super(key: key);

  _MultiPlayerOfflineScreenState createState() =>
      _MultiPlayerOfflineScreenState();
}

class _MultiPlayerOfflineScreenState extends State<MultiPlayerOfflineScreen> {
  List<Player> players = [];
  List<Player> tempPlayers = [];
  int playersCount = 2;

  @override
  void initState() {
    for (int i = 0; i < playersCount; i++) {
      players.add(Player('Player ${i + 1}', '', true));
    }
    tempPlayers = players;
    super.initState();
  }

  void setPlayersCount(bool isIncrement) {
    setState(() {
      if (isIncrement) {
        if (playersCount < 5) {
          playersCount = playersCount + 1;
        }
      } else {
        if (playersCount > 2) {
          playersCount = playersCount - 1;
        }
      }
      players = [];
      for (int i = 0; i < playersCount; i++) {
        String name = 'Player ${i + 1}';
        int index = tempPlayers.indexWhere((p) => p.name == name);
        String color = index > -1 ? tempPlayers[index].color : '';
        players.add(Player(name, color, true));
      }
      tempPlayers = players;
    });
  }

  bool isPlayersColorsSelected() {
    List<String> colors = [];
    players.forEach((p) {
      if (p.color != '') {
        colors.add(p.color);
      }
    });
    if (colors.length == playersCount) {
      return true;
    }
    return false;
  }

  Widget playerColorChooser(Player player) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: <Widget>[
          Text('${player.name} Color', style: AppTextStyles.mediumText),
          SizedBox(height: 10.0),
          ColorChooser(
            activeColor: player.color,
            disableColors: players.map((p) => p.color).toList(),
            onSelection: (String color) {
              setState(() {
                player.color = color;
              });
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double paddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Background(
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: (paddingTop + 120)),
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: players.map((p) {
                          return playerColorChooser(p);
                        }).toList(),
                      ),
                      SizedBox(height: 60.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: (paddingTop + 25),
              child: Container(
                width: width,
                child: Column(
                  children: <Widget>[
                    Text('Number of Players', style: AppTextStyles.regularText),
                    SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 40.0,
                          height: 40.0,
                          child: AnimatedButton(
                              child: Icon(Icons.remove,
                                  size: 35.0, color: AppColors.white),
                              onPressed: () {
                                setPlayersCount(false);
                              }),
                        ),
                        SizedBox(
                          width: 100.0,
                          child: Center(
                            child: Text(playersCount.toString(),
                                style: AppTextStyles.regularText
                                    .copyWith(fontSize: 24.0)),
                          ),
                        ),
                        SizedBox(
                          width: 40.0,
                          height: 40.0,
                          child: AnimatedButton(
                            child: Icon(Icons.add,
                                size: 35.0, color: AppColors.white),
                            onPressed: () {
                              setPlayersCount(true);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 400),
              bottom: isPlayersColorsSelected() ? 15 : -100,
              curve: Curves.easeIn,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      width: 200,
                      height: 48.0,
                      child: AnimatedButton(
                          child: Text('START', style: AppTextStyles.buttonText),
                          onPressed: () {
                            BlocProvider.of<CRBloc>(context).add(StartGameEvent(
                                gameMode: GameMode.MultiPlayerOffline,
                                players: players));
                            Navigator.of(context)
                                .pushNamed(AppRoutes.play_game);
                          }),
                    )
                  ],
                ),
              ),
            ),
            PositionalBackButton(),
          ],
        ),
      ),
    );
  }
}
