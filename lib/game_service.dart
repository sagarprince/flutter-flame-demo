import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/flame.dart';
import 'package:flutter_flame_demo/models.dart';
import 'package:flutter_flame_demo/board.dart';

List<String> players = ['red', 'green', 'blue'];

class GameService with ChangeNotifier {
  int rows = 9;
  int cols = 6;

  Board _board;

  List<List<dynamic>> _matrix = [];
  List<List<dynamic>> get matrix => _matrix;

  String _playerTurn = players[0];
  String get playerTurn => _playerTurn;

  int _pTurnIndex = 2;
  int _totalMoves = 0;

  bool _isChainReaction = false;
  bool get isChainReaction => _isChainReaction;

  dynamic _winner;
  dynamic get winner => _winner;

  GameService() {
    _board = Board(rows, cols);
    _matrix = _board.buildMatrix();
//    testingData();
  }

  void setNextPlayer() {
    _pTurnIndex = (players.length - 1) == _pTurnIndex ? 0 : (_pTurnIndex + 1);
    _playerTurn = players[_pTurnIndex];
  }

  void makeMove(Position pos, String player) {
    _matrix = _board.move(_matrix, pos, player);
    if (_winner == null) {
      checkChainReactions(pos, player);
    }
  }

  void playMove(Position pos, String player) {
    makeMove(pos, player);
    _totalMoves++;
  }

  void checkChainReactions(Position pos, String player) async {
    Future.microtask(() async {
      while (true) {
        List<dynamic> unstable = [];
        int total = rows * cols;
        for (int k = 0; k < total; k++) {
          int i = k ~/ cols;
          int j = k % cols;
          Position _pos = Position(i, j);
          int orbs = _matrix[i][j][0];
          if (orbs >= _board.criticalMass(_pos)) {
            unstable.add(_pos);
          }
        }

        // Check for winner also if unstable cells gets complex exit with winner
        if (unstable.length > 0) {
          String winner = getWinner();
          if (winner != null) {
            _winner = winner;
            _playerTurn = _winner;
            notifyListeners();
          }
          if (unstable.length > 18) {
            if (winner != null) {
              _matrix = _board.stopOnComplexReactions(_matrix);
              unstable = [];
            } else {
              // shuffle unstable list
              unstable = _board.shuffleUnstableList(unstable);
            }
          }
        }

        // If there are no unstable pos then exit
        if (unstable.length == 0) {
          break;
        }

        await explode(unstable);
      }

      if (_winner == null) {
        setNextPlayer();
      }
    });
  }

  Future<dynamic> explode(List<dynamic> unstable) async {
    return await Future.forEach(unstable, (_pos) async {
      var positionData = _matrix[_pos.i][_pos.j][1];
      positionData.isExplode = true;
      Flame.audio.play('pop.mp3');
      await new Future.delayed(
          Duration(milliseconds: unstable.length > 16 ? 100 : 200));
      _matrix[_pos.i][_pos.j][0] -= _board.criticalMass(_pos);
      List<dynamic> neighbours = _board.getNeighbours(_pos);
      neighbours.forEach((n) {
        _matrix = _board.move(_matrix, n, positionData.player);
      });
      // check for remaining orbs and then apply player
      int orbs = _matrix[_pos.i][_pos.j][0];
      positionData.player = orbs > 0 ? positionData.player : '';
      positionData.isExplode = false;
    });
  }

  dynamic getWinner() {
    dynamic winner;
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
        winner = filteredList[0];
      }
    }
    return winner;
  }

  void reset() {
    _matrix = _board.reset(_matrix);
    _pTurnIndex = 0;
    _playerTurn = players[_pTurnIndex];
    _totalMoves = 0;
    _winner = null;
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

  // Testing
  void testingData() {
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols; // determines i
      int j = k % cols; // determines j

      _pTurnIndex = (players.length - 1) == _pTurnIndex ? 0 : (_pTurnIndex + 1);
      _playerTurn = players[_pTurnIndex];
      _totalMoves++;
      _matrix[i][j][1] = CellInfo(player: _playerTurn);

      // Corner Cells
      if (((i == 0 && j == 0 ||
          i == 0 && j == (cols - 1) ||
          i == (rows - 1) && j == 0 ||
          i == (rows - 1) && j == (cols - 1)))) {
        _matrix[i][j][0] = 1;
      }

      // Vertical/Horizontal Side Cells
      else if (((i > 0 && i < (rows - 1) && (j == 0 || j == (cols - 1))) ||
          (j > 0 && j < (cols - 1) && (i == 0 || i == (rows - 1))))) {
        _matrix[i][j][0] = 2;
      }

      // Middle Cells
      else {
        _matrix[i][j][0] = 3;
      }
    }
  }
}

GameService gameService = GameService();
