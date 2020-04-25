import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/flame.dart';
import 'package:flutter_flame_demo/models.dart';
import 'package:flutter_flame_demo/board.dart';

List<String> players = ['red', 'green'];

class GameService with ChangeNotifier {
  int rows = 9;
  int cols = 6;

  Board _board;

  List<List<dynamic>> _matrix = [];
  List<List<dynamic>> get matrix => _matrix;

  String _playerTurn = players[0];
  String get playerTurn => _playerTurn;

  int _pTurnIndex = 0;

  bool _isChainReaction = false;

  GameService() {
    _board = Board(rows, cols);
    _matrix = _board.buildMatrix();
  }

  setNextPlayer() {
    _pTurnIndex = (players.length - 1) == _pTurnIndex ? 0 : (_pTurnIndex + 1);
    _playerTurn = players[_pTurnIndex];
  }

  playMove(Position pos, String player) {
    _matrix = _board.move(_matrix, pos, player);
    bool reaction = checkChainReaction(pos, player);
    setNextPlayer();
    print(reaction);
    if (!reaction) {}
  }

  checkChainReaction(Position pos, String player) {
    var positionData = _matrix[pos.i][pos.j];
    int orbs = positionData[0];
    if (orbs == _board.criticalMass(pos)) {
      explode(pos, player);
      return true;
    }
    return false;
  }

  explode(Position pos, String player) {
    List<dynamic> neighbours = _board.getNeighbours(pos);
    _matrix[pos.i][pos.j][1].isExplode = true;
    Future.delayed(new Duration(milliseconds: 100), () {
      Future.delayed(new Duration(milliseconds: 200), () {
        neighbours.forEach((n) {
          playMove(n, player);
        });
        _matrix = _board.setMoveBlank(_matrix, pos);
      });
    });
  }

  Color getPlayerColor(player) {
    switch (player) {
      case 'blue':
        return Colors.blue;
        break;
      case 'yellow':
        return Colors.yellow;
        break;
      case 'green':
        return Colors.green;
        break;
      case 'orange':
        return Colors.orange;
        break;
      default:
        return Colors.red;
    }
  }
}

GameService gameService = GameService();
