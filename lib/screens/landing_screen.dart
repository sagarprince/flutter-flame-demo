import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flame_demo/models/player.dart';
import 'package:flutter_flame_demo/utils/constants.dart';
import 'package:flutter_flame_demo/utils/styles.dart';
import 'package:flutter_flame_demo/blocs/events.dart';
import 'package:flutter_flame_demo/blocs/state.dart';
import 'package:flutter_flame_demo/blocs/bloc.dart';
import 'package:flutter_flame_demo/widgets/full_background.dart';
import 'package:flutter_flame_demo/widgets/game_rules_modal.dart';
import 'package:flutter_flame_demo/widgets/play_game_button.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          FullBackground(),
          Positioned.fill(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/logo.png',
                        width: 100,
                      ),
                      SizedBox(height: 30.0),
                      Text('CHAIN', style: AppTextStyles.landingHeadingText),
                      Text(
                        'REACTION',
                        style: AppTextStyles.landingHeadingText,
                      ),
                      SizedBox(height: 60.0),
                      Row(
                        children: <Widget>[
                          PlayGameButton(
                            icon1: Icons.play_arrow,
                            icon2: Icons.computer,
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.versus_bot);
                            },
                          ),
                          SizedBox(width: 40.0),
                          PlayGameButton(
                            icon1: Icons.play_arrow,
                            icon2: Icons.group,
                            onPressed: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 30.0),
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 15,
            child: IconButton(
              icon: Icon(Icons.info_outline,
                  color: Colors.blueAccent, size: 38.0),
              onPressed: () {
                showGameRulesDialog(context);
              },
            ),
          )
        ],
      ),
    );
  }
}
