import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flame/flame.dart';

class GameProvider with ChangeNotifier {
  int rows = 9;
  int cols = 6;

  List<List<AtomModel>> _matrix = buildMatrix();
  List<List<AtomModel>> get matrix => _matrix;

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

  List<dynamic> cornerCells = [
    [0, 0],
    [8, 0],
    [8, 5],
    [0, 5]
  ];

  void startChainReactionChecking() {
    if (!isChainReactionChecking) {
      isChainReactionChecking = true;
      Timer.periodic(Duration(milliseconds: 600), (timer) {
        print(DateTime.now());
        if (!_isChainReaction) {
          if (winner == null) {
            checkChainReaction();
          } else {
            timer.cancel();
            isChainReactionChecking = false;
          }
        }
      });
    }
  }

  void playMove(int i, int j) {
    int count = _matrix[i][j].electrons.length;
    _matrix[i][j].electrons.add(count + 1);
    _matrix[i][j].player = _playerTurn;
    _pTurnIndex = (players.length - 1) == _pTurnIndex ? 0 : (_pTurnIndex + 1);
    _playerTurn = players[_pTurnIndex];
    _pTurnCount++;
    startChainReactionChecking();
  }

  void checkChainReaction() {
    int r = rows - 1;
    int c = cols - 1;

    // Corner Cells
    for (var k = 0; k < 4; k++) {
      if (_matrix[cornerCells[k][0]][cornerCells[k][1]].electrons.length >= 2) {
        explode(cornerCells[k][0], cornerCells[k][1]);
        break;
      }
    }

    // Left/Right Side Vertical Cells
    for (var i = 1; i < r; i++) {
      if (_matrix[i][0].electrons.length >= 3) {
        explode(i, 0);
        break;
      }
      if (_matrix[i][c].electrons.length >= 3) {
        explode(i, c);
        break;
      }
    }

    // Top/Bottom Side Horizontal Cells
    for (var j = 1; j < c; j++) {
      if (_matrix[0][j].electrons.length >= 3) {
        explode(0, j);
        break;
      }
      if (_matrix[r][j].electrons.length >= 3) {
        explode(r, j);
        break;
      }
    }

    // Middle Section Cells by Excluding Side & Corner Cells
    OUTER:
    for (var i = 1; i < r; i++) {
      for (var j = 1; j < c; j++) {
        if (_matrix[i][j].electrons.length >= 4) {
          explode(i, j);
          break OUTER;
        }
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
            Flame.audio.play('boom.wav');
          }
          Future.delayed(new Duration(milliseconds: 200), () {
            AtomModel topAtom = i > 0 ? _matrix[i - 1][j] : null;
            AtomModel rightAtom = j < (cols - 1) ? _matrix[i][j + 1] : null;
            AtomModel bottomAtom = i < (rows - 1) ? _matrix[i + 1][j] : null;
            AtomModel leftAtom = j > 0 ? _matrix[i][j - 1] : null;
            if (topAtom != null && topAtom.electrons.length < 4) {
              topAtom.electrons.add(topAtom.electrons.length + 1);
              topAtom.player = _player;
            }
            if (rightAtom != null && rightAtom.electrons.length < 4) {
              rightAtom.electrons.add(rightAtom.electrons.length + 1);
              rightAtom.player = _player;
            }
            if (bottomAtom != null && bottomAtom.electrons.length < 4) {
              bottomAtom.electrons.add(bottomAtom.electrons.length + 1);
              bottomAtom.player = _player;
            }
            if (leftAtom != null && leftAtom.electrons.length < 4) {
              leftAtom.electrons.add(leftAtom.electrons.length + 1);
              leftAtom.player = _player;
            }
            _matrix[i][j].player = '';
            _matrix[i][j].electrons = [];
            _matrix[i][j].isExplode = false;
            _isChainReaction = false;
            isSoundPlaying = false;
          });
        });
      }
    });
  }

  void checkWinner() {
    if (_pTurnCount >= players.length) {
      List<dynamic> playerCellsCount = [];
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          AtomModel atom = _matrix[i][j];
          if (atom.player != '' && atom.electrons.length > 0) {
            int index =
                playerCellsCount.indexWhere((x) => x['player'] == atom.player);
            if (index == -1) {
              playerCellsCount.add({'player': atom.player, 'count': 1});
            } else {
              playerCellsCount[index]['count']++;
            }
          }
        }
      }

      if (playerCellsCount.length == 1) {
        _winner = playerCellsCount[0];
        notifyListeners();
      }
    }
  }

  void reset() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        _matrix[i][j].player = '';
        _matrix[i][j].electrons = [];
      }
    }
    _pTurnIndex = 0;
    _playerTurn = players[_pTurnIndex];
    _pTurnCount = 0;
    _winner = null;
    notifyListeners();
  }
}

List<String> players = ['red', 'blue'];

List<List<AtomModel>> buildMatrix() {
  int m = 9; // rows
  int n = 6; // cols
  int i = 0;
  return new List.generate(m, (_) {
    int j = 0;
    List<AtomModel> cols = new List.generate(n, (_) {
      var model = new AtomModel(i: i, j: j, electrons: [], player: '');
      j++;
      return model;
    });
    i++;
    return cols;
  });
}

class AtomModel {
  int i;
  int j;
  List electrons;
  String player;
  bool isExplode;

  AtomModel(
      {this.i,
      this.j,
      this.electrons,
      this.player = '',
      this.isExplode = false});

  @override
  String toString() => 'AtomModel{'
      'i: $i, '
      'j: $j, '
      'electrons: $electrons, '
      'player: $player, '
      'isExplode: $isExplode'
      '}';
}

GameProvider gameProvider = GameProvider();
