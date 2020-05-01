import 'package:flutter/material.dart';
import 'package:flutter_flame_demo/models/player.dart';
import 'package:flutter_flame_demo/game/engine/index.dart';

class WinnerView extends StatelessWidget {
  final Player winner;

  WinnerView({Key key, this.winner}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return winner.name != ''
        ? Container(
            width: 220.0,
            height: 140.0,
            decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('${winner.name} is winner !!!',
                        style: TextStyle(color: Colors.white, fontSize: 16.0))
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      CREngine().reset();
                    },
                  ),
                )
              ],
            ),
          )
        : SizedBox();
  }
}
