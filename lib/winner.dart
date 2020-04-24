import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_flame_demo/game_service.dart';

class Winner extends StatelessWidget {
  Winner({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GameService, dynamic>(
      selector: (_, service) => service.winner,
      builder: (_, winner, __) {
        return winner != null
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
                        Text(
                            '${winner != null ? winner.toString().toUpperCase() : 'RED'} is winner !!!',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0))
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          gameService.reset();
                        },
                      ),
                    )
                  ],
                ),
              )
            : SizedBox();
      },
    );
  }
}
