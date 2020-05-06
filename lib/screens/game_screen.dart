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
import 'package:flutter_flame_demo/utils/ui_utils.dart';
import 'package:flutter_flame_demo/widgets/background.dart';
import 'package:flutter_flame_demo/widgets/volume_button.dart';

class GameScreen extends StatelessWidget {
  GameScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return UiUtils.confirmDialog(
            context: context,
            title: 'Exit Game',
            message: 'Do you want to exit game?');
      },
      child: Scaffold(
        body: BlocBuilder<CRBloc, CRState>(
          condition: (prevState, state) {
            return prevState != state;
          },
          builder: (context, state) {
            return Background(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned.fill(
                    child: SafeArea(
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 50, bottom: 10),
                        child: GameView(
                            bloc: BlocProvider.of<CRBloc>(context),
                            state: state),
                      ),
                    ),
                  ),
                  Positioned.fill(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[],
                  )),
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Image.asset(
                              'assets/images/close.png',
                            ),
                            iconSize: 32.0,
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.maybePop(context);
                              }
                            },
                          ),
                          Row(
                            children: <Widget>[
                              VolumeButton(),
                              IconButton(
                                icon: Image.asset(
                                  'assets/images/rules.png',
                                ),
                                iconSize: 34.0,
                                onPressed: () {
                                  UiUtils.showGameRulesDialog(context);
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
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
      Keys.navigatorKey.currentState.pushReplacementNamed(AppRoutes.result);
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
