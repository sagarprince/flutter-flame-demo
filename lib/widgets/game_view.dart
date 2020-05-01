import 'package:flutter/material.dart';
import 'package:flutter_flame_demo/game/cr_game.dart';
import 'package:flutter_flame_demo/blocs/bloc.dart';
import 'package:flutter_flame_demo/blocs/state.dart';
import 'package:flutter_flame_demo/game/engine/index.dart';

class GameView extends StatefulWidget {
  final CRBloc bloc;
  final CRState state;

  GameView({Key key, @required this.bloc, @required this.state})
      : assert(bloc != null),
        assert(state != null),
        super(key: key);

  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  CRGame _game;

  @override
  void initState() {
    CREngine engine = CREngine(widget.bloc, widget.state);
    _game = CRGame(engine);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _game.widget;
  }
}
