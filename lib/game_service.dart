import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/flame.dart';
import 'package:flutter_flame_demo/models.dart';

class GameService with ChangeNotifier {
  int rows = 9;
  int cols = 6;

  List<List<CellModel>> _matrix = buildMatrix();
  List<List<CellModel>> get matrix => _matrix;

  bool _isChainReaction = false;
  bool get isChainReaction => _isChainReaction;

  String _playerTurn = players[0];
  String get playerTurn => _playerTurn;

  int _pTurnIndex = 0;

  int _pTurnCount = 0;

  dynamic _winner;
  dynamic get winner => _winner;

  bool isChainReactionChecking = false;
  bool isSoundPlaying = false;

  void playMove(int i, int j) {
    addOrbToCell(i, j, _playerTurn);
    _pTurnIndex = (players.length - 1) == _pTurnIndex ? 0 : (_pTurnIndex + 1);
    _playerTurn = players[_pTurnIndex];
    _pTurnCount++;
  }

  void addOrbToCell(int i, int j, String player) {
    print(_playerTurn);
    int count = _matrix[i][j].orbs.length;
    _matrix[i][j].orbs.add(count + 1);
    _matrix[i][j].player = player;
    if (_winner == null) {
      checkChainReaction(i, j, player);
    }
  }

  void checkChainReaction(int i, int j, String player) {
    int r = rows - 1;
    int c = cols - 1;

    // Corner Cells
    if (((i == 0 && j == 0 ||
            i == 0 && j == c ||
            i == r && j == 0 ||
            i == r && j == c)) &&
        _matrix[i][j].orbs.length >= 2) {
      explode(i, j);
    }

    // Vertical/Horizontal Side Cells
    else if (((i > 0 && i < r && (j == 0 || j == c)) ||
            (j > 0 && j < c && (i == 0 || i == r))) &&
        _matrix[i][j].orbs.length >= 3) {
      explode(i, j);
    }

    // Middle Cells
    else {
      if (_matrix[i][j].orbs.length >= 4) {
        explode(i, j);
      }
    }

    checkWinner();
  }

  void explode(int i, int j) {
    Future.microtask(() {
      _isChainReaction = true;
      if (!_matrix[i][j].isExplode) {
        String _player = _matrix[i][j].player;
        _matrix[i][j].isExplode = true;
        Future.delayed(new Duration(milliseconds: 100), () {
          if (!isSoundPlaying) {
            isSoundPlaying = true;
            Flame.audio.play('pop.mp3');
          }
          Future.delayed(new Duration(milliseconds: 200), () {
            CellModel topCell = i > 0 ? _matrix[i - 1][j] : null;
            CellModel rightCell = j < (cols - 1) ? _matrix[i][j + 1] : null;
            CellModel bottomCell = i < (rows - 1) ? _matrix[i + 1][j] : null;
            CellModel leftCell = j > 0 ? _matrix[i][j - 1] : null;
            if (topCell != null && topCell.orbs.length < 4) {
              addOrbToCell(i - 1, j, _player);
            }
            if (rightCell != null && rightCell.orbs.length < 4) {
              addOrbToCell(i, j + 1, _player);
            }
            if (bottomCell != null && bottomCell.orbs.length < 4) {
              addOrbToCell(i + 1, j, _player);
            }
            if (leftCell != null && leftCell.orbs.length < 4) {
              addOrbToCell(i, j - 1, _player);
            }

            _matrix[i][j].player = '';
            _matrix[i][j].orbs = [];
            _matrix[i][j].isExplode = false;
            _isChainReaction = false;
            isSoundPlaying = false;
          });
        });
      }
    });
  }

  void checkWinner() {
    if (winner == null) {
      Future.microtask(() {
        Future.delayed(Duration(milliseconds: 800), () {
          if (_pTurnCount >= players.length) {
            List<dynamic> playerCellsCount = [];
            for (int i = 0; i < rows; i++) {
              for (int j = 0; j < cols; j++) {
                CellModel cell = _matrix[i][j];
                if (cell.player != '' && cell.orbs.length > 0) {
                  int index = playerCellsCount
                      .indexWhere((x) => x['player'] == cell.player);
                  if (index == -1) {
                    playerCellsCount.add({'player': cell.player, 'count': 1});
                  } else {
                    playerCellsCount[index]['count']++;
                  }
                }
              }
            }

            if (playerCellsCount.length == 1) {
              _winner = playerCellsCount[0];
              _playerTurn = _winner['player'];
              notifyListeners();
              stopInfinityChainReactions();
            }
          }
        });
      });
    }
  }

  void stopInfinityChainReactions() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        // Corner Cells
        if (((i == 0 && j == 0 ||
                i == 0 && j == (cols - 1) ||
                i == (rows - 1) && j == 0 ||
                i == (rows - 1) && j == (cols - 1))) &&
            _matrix[i][j].orbs.length == 2) {
          _matrix[i][j].orbs = [1];
        }

        // Vertical/Horizontal Side Cells
        else if (((i > 0 && i < (rows - 1) && (j == 0 || j == (cols - 1))) ||
                (j > 0 && j < (cols - 1) && (i == 0 || i == (rows - 1)))) &&
            _matrix[i][j].orbs.length == 3) {
          _matrix[i][j].orbs = [1, 2];
        }

        // Middle Cells
        else {
          if (_matrix[i][j].orbs.length == 4) {
            _matrix[i][j].orbs = [1, 2, 3];
          }
        }
      }
    }
  }

  void reset() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        _matrix[i][j].player = '';
        _matrix[i][j].orbs = [];
      }
    }
    _pTurnIndex = 0;
    _playerTurn = players[_pTurnIndex];
    _pTurnCount = 0;
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
}

List<String> players = ['red', 'green'];

List<List<CellModel>> buildMatrix() {
  int m = 9; // rows
  int n = 6; // cols
  int i = 0;
  return new List.generate(m, (_) {
    int j = 0;
    List<CellModel> cols = new List.generate(n, (_) {
      var cell = new CellModel(i: i, j: j, orbs: [], player: '');
      j++;
      return cell;
    });
    i++;
    return cols;
  });
}

GameService gameService = GameService();