import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flame_demo/blocs/bloc.dart';
import 'package:flutter_flame_demo/blocs/state.dart';
import 'package:flutter_flame_demo/blocs/events.dart';
import 'package:flutter_flame_demo/game/cr_game.dart';
import 'package:flutter_flame_demo/game/engine/engine.dart';
import 'package:flutter_flame_demo/shared_instances.dart';
import 'package:flutter_flame_demo/utils/constants.dart';
import 'package:flutter_flame_demo/utils/keys.dart';

class GameScreen extends StatelessWidget {
  GameScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CRBloc, CRState>(
          condition: (prevState, state) {
            return prevState != state;
          },
          builder: (context, state) {
            return Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned.fill(
                    child: GameView(
                        bloc: BlocProvider.of<CRBloc>(context), state: state),
                  ),
                  Positioned.fill(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[],
                  )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

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
  CREngine _engine;
  CRGame _game;

  @override
  void initState() {
    _engine = CREngine(widget.state, (winner) {
      print('Winner');
      print(winner);
      widget.bloc.add(SetWinnerEvent(winner));
      Keys.navigatorKey.currentState.pushReplacementNamed(AppRoutes.winner);
    });
    _game = CRGame(_engine);
    SharedInstances.engine = _engine;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _game.widget;
  }

  @override
  void dispose() {
    _engine.destroy();
    super.dispose();
  }
}
