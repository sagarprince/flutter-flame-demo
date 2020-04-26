import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/flame.dart';
import 'package:flutter_flame_demo/models.dart';
import 'package:flutter_flame_demo/board.dart';

List<dynamic> allPlayers = ['red', 'green'];

class GameService with ChangeNotifier {
  int rows = 9;
  int cols = 6;

  Board _board;

  List<dynamic> _players = List.from(allPlayers).toList(growable: true);

  List<List<dynamic>> _matrix = [];
  List<List<dynamic>> get matrix => _matrix;

  String _playerTurn = allPlayers[0];
  String get playerTurn => _playerTurn;

  int _pTurnIndex = 0;
  int _totalMoves = 0;

  bool _isChainReaction = false;
  bool get isChainReaction => _isChainReaction;

  dynamic _winner;
  dynamic get winner => _winner;

  int _complexityLimit = 18;

  GameService() {
    _board = Board(rows, cols);
    _matrix = _board.buildMatrix();
//    testingData();
  }

  void setNextPlayer() {
    if (_pTurnIndex < _players.length - 1) {
      _pTurnIndex++;
    } else {
      _pTurnIndex = 0;
    }
    _playerTurn = _players[_pTurnIndex];
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
        _isChainReaction = true;
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

        // Evaluate winner
        _winner = evaluateWinner();

        // If unstable cells gets complex exit with winner
        if (unstable.length > 0) {
          setWinner();
          if (unstable.length > _complexityLimit) {
            if (_winner != null) {
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
      _isChainReaction = false;
      // Evaluate Winner when Exit From While Loop
      _winner = evaluateWinner();
      setWinner();
      if (_winner == null) {
        setNextPlayer();
      }
    });
  }

  Future<dynamic> explode(List<dynamic> unstable) async {
    return await Future.forEach(unstable, (_pos) async {
      var positionData = _matrix[_pos.i][_pos.j][1];
      positionData.isExplode = true;
//      await Flame.audio.play('pop.mp3');
      await new Future.delayed(Duration(
          milliseconds: unstable.length > (_complexityLimit - 2) ? 100 : 200));
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

  dynamic evaluateWinner() {
    dynamic winner;
    if (_totalMoves >= _players.length) {
      List<int> playersScores = _board.checkScores(_matrix, _players);
      int k = 0;
      dynamic player;
      List<dynamic> removedList = [];

      playersScores.forEach((sc) {
        if (sc == 0) {
          removedList.add(_players[k]);
        }
        k++;
      });

      if (removedList.length > 0) {
        player =
            _pTurnIndex <= (_players.length - 1) ? _players[_pTurnIndex] : null;
        removedList.forEach((v) {
          _players.remove(v);
        });
      }

      if (player != null) {
        _pTurnIndex =
            _players.indexOf(player) > -1 ? _players.indexOf(player) : 0;
      }

      print('=======================');
      print(_players);
      print('TURN INDEX : $_pTurnIndex, $player');
      print(playersScores);

      if (_players.length == 1) {
        winner = _players[0];
      }
    }
    return winner;
  }

  void setWinner() {
    if (_winner != null) {
      _playerTurn = _winner;
      notifyListeners();
    }
  }

  void reset() {
    _matrix = _board.reset(_matrix);
    _players = List.from(allPlayers).toList(growable: true);
    _pTurnIndex = 0;
    _playerTurn = _players[_pTurnIndex];
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

      _pTurnIndex =
          (_players.length - 1) == _pTurnIndex ? 0 : (_pTurnIndex + 1);
      _playerTurn = _players[_pTurnIndex];
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
