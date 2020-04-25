import 'dart:async';
import 'dart:math';
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
  int _totalMoves = 0;
  bool _isSoundPlaying = false;

  bool _isChainReaction = false;
  bool get isChainReaction => _isChainReaction;

  dynamic _winner;
  dynamic get winner => _winner;
  Timer _winnerTimer;

  GameService() {
    _board = Board(rows, cols);
    _matrix = _board.buildMatrix();
    startCheckingWinner();
  }

  void startCheckingWinner() {
    _winnerTimer = Timer.periodic(Duration(milliseconds: 1000), (_) {
      checkWinner();
    });
  }

  void setNextPlayer() {
    _pTurnIndex = (players.length - 1) == _pTurnIndex ? 0 : (_pTurnIndex + 1);
    _playerTurn = players[_pTurnIndex];
  }

  void makeMove(Position pos, String player) {
    _matrix = _board.move(_matrix, pos, player);
    if (_winner == null) {
      checkChainReaction(pos, player);
      setNextPlayer();
    }
  }

  void playMove(Position pos, String player) {
    makeMove(pos, player);
    _totalMoves++;
  }

  void checkChainReaction(Position pos, String player) {
    var positionData = _matrix[pos.i][pos.j];
    int orbs = positionData[0];
    if (orbs == _board.criticalMass(pos)) {
      explode(pos, player);
    }
  }

  void explode(Position pos, String player) {
    Future.microtask(() {
      List<dynamic> neighbours = _board.getNeighbours(pos);
      _matrix[pos.i][pos.j][1].isExplode = true;
      _isChainReaction = true;
      Future.delayed(new Duration(milliseconds: 100), () {
        if (!_isSoundPlaying) {
          _isSoundPlaying = true;
          Flame.audio.play('pop.mp3');
        }
        Future.delayed(new Duration(milliseconds: 200), () {
          neighbours.forEach((n) {
            makeMove(n, player);
          });
          _matrix = _board.setMoveBlank(_matrix, pos);
          _isChainReaction = false;
          _isSoundPlaying = false;
        });
      });
    });
  }

  void checkWinner() {
    if (_winner == null) {
      Future.microtask(() {
        Future.delayed(Duration(milliseconds: 200), () {
          if (_totalMoves >= players.length) {
            Map<String, int> filledCells = {};
            int total = rows * cols;
            for (int k = 0; k < total; k++) {
              int i = k ~/ cols; // determines i
              int j = k % cols; // determines j
              int orbs = _matrix[i][j][0];
              CellInfo info = _matrix[i][j][1];
              if (info.player != '' && orbs > 0) {
                if (filledCells[info.player] != null) {
                  filledCells[info.player]++;
                } else {
                  filledCells[info.player] = 1;
                }
              }
            }

            var filtered = Map.of(filledCells)..removeWhere((k, v) => v == 0);
            var filteredList = filtered.keys.toList();
            if (filteredList.length == 1) {
              _winner = filteredList[0];
              _playerTurn = _winner;
              print(_winner);
              notifyListeners();
              _winnerTimer.cancel();
            }
          }
        });
      });
    }
  }

  void reset() {
    _matrix = _board.reset(_matrix);
    _pTurnIndex = 0;
    _playerTurn = players[_pTurnIndex];
    _totalMoves = 0;
    _winner = null;
    startCheckingWinner();
    notifyListeners();
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
