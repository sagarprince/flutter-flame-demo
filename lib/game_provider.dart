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

  void playMove(int i, int j) {
    int count = _matrix[i][j].electrons.length;
    _matrix[i][j].electrons.add(count + 1);
    _matrix[i][j].player = _playerTurn;
    _pTurnIndex = (players.length - 1) == _pTurnIndex ? 0 : (_pTurnIndex + 1);
    _playerTurn = players[_pTurnIndex];
    _pTurnCount++;
    checkChainReaction();
  }

  void checkChainReaction() {
    OUTER:
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        int electronsCount = _matrix[i][j].electrons.length;
        int explodeLimit = 4;

        // Corner Cells
        if ((i == 0 && j == 0) ||
            (i == 0 && j == (cols - 1)) ||
            (i == (rows - 1) && j == 0) ||
            (i == (rows - 1) && j == (cols - 1))) {
          explodeLimit = 2;
        }

        // Side Cells
        if (((i > 0 && i < (rows - 1)) && j == 0) ||
            ((i > 0 && i < (rows - 1)) && j == (cols - 1)) ||
            ((i == 0) && (j > 0 && j < (cols - 1))) ||
            ((i == (rows - 1)) && (j > 0 && j < (cols - 1)))) {
          explodeLimit = 3;
        }

        if (electronsCount >= explodeLimit) {
          _isChainReaction = true;
          if (winner == null) {
            Future.microtask(() {
              Future.delayed(new Duration(milliseconds: 150), () {
                Flame.audio.play('boom.wav');
                explode(i, j, () {
                  Future.delayed(new Duration(milliseconds: 200), () {
                    checkChainReaction();
                  });
                });
              });
            });
          }
          break OUTER;
        } else {
          _isChainReaction = false;
        }
      }
    }

    checkWinner();
  }

  void explode(int i, int j, Function callback) {
    if (!_matrix[i][j].isExplode) {
      String _player = _matrix[i][j].player;
      _matrix[i][j].isExplode = true;
      Future.delayed(new Duration(milliseconds: 250), () {
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
          callback();
        });
      });
    }
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
