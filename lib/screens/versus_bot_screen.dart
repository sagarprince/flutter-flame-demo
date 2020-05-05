import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_flame_demo/utils/constants.dart';
import 'package:flutter_flame_demo/utils/styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flame_demo/models/player.dart';
import 'package:flutter_flame_demo/blocs/events.dart';
import 'package:flutter_flame_demo/blocs/state.dart';
import 'package:flutter_flame_demo/blocs/bloc.dart';
import 'package:flutter_flame_demo/widgets/animated_button.dart';
import 'package:flutter_flame_demo/widgets/positional_back_button.dart';
import 'package:flutter_flame_demo/widgets/color_chooser.dart';
import 'package:flutter_flame_demo/widgets/full_background.dart';

class VersusBotScreen extends StatefulWidget {
  VersusBotScreen({Key key}) : super(key: key);
  _VersusBotScreenState createState() => _VersusBotScreenState();
}

class _VersusBotScreenState extends State<VersusBotScreen> {
  String yourColor = '';
  String botColor = '';
  bool isBotChoosingColor = false;

  String getBotColor() {
    int index = Random().nextInt(PlayerColors.length);
    String color = PlayerColors[index];
    if (color == yourColor) {
      color = getBotColor();
    }
    return color;
  }

  void botChoosingColor() {
    Timer(Duration(milliseconds: 1500), () {
      setState(() {
        isBotChoosingColor = false;
        botColor = getBotColor();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double paddingTop = MediaQuery.of(context).padding.top + 60;
    double paddingBottom = 70.0;
    return Scaffold(
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            FullBackground(),
            Positioned.fill(
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    padding:
                        EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Choose Your Color',
                            style: AppTextStyles.mediumText),
                        SizedBox(height: 20.0),
                        ColorChooser(
                          disabled: isBotChoosingColor,
                          activeColor: yourColor,
                          onSelection: (String color) {
                            setState(() {
                              yourColor = color;
                              isBotChoosingColor = true;
                            });
                            botChoosingColor();
                          },
                        ),
                        SizedBox(height: 40.0),
                        yourColor != ''
                            ? Text(isBotChoosingColor ? 'Wait...' : 'Bot Color',
                                style: AppTextStyles.mediumText)
                            : SizedBox(),
                        yourColor != ''
                            ? ColorChooser(
                                activeColor: botColor,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 400),
              bottom: (yourColor != '' && botColor != '' && !isBotChoosingColor)
                  ? 10
                  : -200,
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
                                gameMode: GameMode.PlayVersusBot,
                                players: [
                                  Player('You', yourColor, true),
                                  Player('Bot', botColor, false),
                                ]));
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
