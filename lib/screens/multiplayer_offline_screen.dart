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
  List<Map<String, dynamic>> players = [];
  List<Map<String, dynamic>> tempPlayers = [];
  int playersCount = 2;
  TextEditingController controller;
  BuildContext _context;

  @override
  void initState() {
    controller = TextEditingController();
    for (int i = 0; i < playersCount; i++) {
      players.add(_playerToMap((i + 1), 'Player ${i + 1}', '', false));
    }
    tempPlayers = players;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!isKeyboardOpened) {
      setPlayerNameEditing();
    }
    super.didChangeDependencies();
  }

  bool get isKeyboardOpened {
    if (_context != null) {
      return MediaQuery.of(context).viewInsets.bottom > 0 ? true : false;
    }
    return false;
  }

  Map<String, dynamic> _playerToMap(
      int id, String name, String color, bool isEditing) {
    return {
      'id': id,
      'name': name,
      'color': color,
      'isHuman': true,
      'isEditing': isEditing
    };
  }

  Player _playerFromMap(Map<String, dynamic> player) {
    return Player(player['name'], player['color'], player['isHuman']);
  }

  List<String> get disabledColors {
    List<String> colors = [];
    players.forEach((p) {
      String color = p['color'];
      if (color != '') {
        colors.add(color);
      }
    });
    return colors;
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
        int id = (i + 1);
        int index = tempPlayers.indexWhere((p) => p['id'] == id);
        String name =
            index > -1 ? tempPlayers[index]['name'] : 'Player ${i + 1}';
        String color = index > -1 ? tempPlayers[index]['color'] : '';
        players.add(_playerToMap(id, name, color, false));
      }
      tempPlayers = players;
    });
  }

  bool isPlayersColorsSelected() {
    List<String> colors = [];
    players.forEach((p) {
      if (p['color'] != '') {
        colors.add(p['color']);
      }
    });
    if (colors.length == playersCount) {
      return true;
    }
    return false;
  }

  void setPlayerNameEditing([Map<String, dynamic> player]) {
    players = players.map((p) {
      p['isEditing'] = false;
      return p;
    }).toList();
    setState(() {
      if (player != null) {
        player['isEditing'] = !player['isEditing'];
      }
    });
  }

  Widget playerWidget(Map<String, dynamic> player) {
    String name = player['name'];
    bool isEditing = player['isEditing'];
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: <Widget>[
          !isEditing
              ? GestureDetector(
                  child: Text('$name Color', style: AppTextStyles.mediumText),
                  onTap: () {
                    controller.text = name;
                    setPlayerNameEditing(player);
                  },
                )
              : Container(
                  padding: EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.cardinal, width: 2.0),
                            ),
                          ),
                          autofocus: true,
                          cursorColor: AppColors.white,
                          style: AppTextStyles.mediumText,
                          textAlign: TextAlign.center,
                          onChanged: (String value) {
                            player['name'] = value;
                          },
                        ),
                      ),
                      Text(' Color', style: AppTextStyles.mediumText)
                    ],
                  ),
                ),
          SizedBox(height: 10.0),
          ColorChooser(
            activeColor: player['color'],
            disableColors: disabledColors,
            onSelection: (String color) {
              setState(() {
                player['color'] = color;
              });
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    double width = MediaQuery.of(context).size.width;
    double paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Background(
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top:
                      !isKeyboardOpened ? (paddingTop + 120) : paddingTop + 50),
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: players.map((p) {
                          return playerWidget(p);
                        }).toList(),
                      ),
                      SizedBox(height: 60.0),
                    ],
                  ),
                ),
              ),
            ),
            !isKeyboardOpened
                ? Positioned(
                    top: (paddingTop + 22),
                    child: Container(
                      width: width,
                      child: Column(
                        children: <Widget>[
                          Text('Number of Players',
                              style: AppTextStyles.regularText),
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
                  )
                : SizedBox(),
            !isKeyboardOpened
                ? AnimatedPositioned(
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
                                child: Text('START',
                                    style: AppTextStyles.buttonText),
                                onPressed: () {
                                  BlocProvider.of<CRBloc>(context).add(
                                      StartGameEvent(
                                          gameMode: GameMode.MultiPlayerOffline,
                                          players: players
                                              .map((p) => _playerFromMap(p))
                                              .toList()));
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.play_game);
                                }),
                          )
                        ],
                      ),
                    ),
                  )
                : SizedBox(),
            PositionalBackButton(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
