import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flame_demo/blocs/bloc.dart';
import 'package:flutter_flame_demo/blocs/state.dart';
import 'package:flutter_flame_demo/widgets/game_view.dart';
import 'package:flutter_flame_demo/widgets/winner_view.dart';

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
                    children: <Widget>[WinnerView(winner: state.winner)],
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
