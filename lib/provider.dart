class Provider {
  List<List<AtomModel>> _matrix = buildMatrix();
  List<List<AtomModel>> get matrix => _matrix;

  List<dynamic> reactions = [];

  String _playerTurn = 'red';
  String get playerTurn => _playerTurn;

  void playMove(i, j, {pTurn = 'red'}) {
    _playerTurn = pTurn;
    int count = _matrix[i][j].electrons.length;
    _matrix[i][j].electrons.add(count + 1);
    _matrix[i][j].player = _playerTurn;
    _playerTurn = pTurn == 'blue' ? 'red' : 'blue';
    checkChainReaction();
  }

  void checkChainReaction() {
    int m = 9;
    int n = 6;

    OUTER:
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
        int electronsCount = _matrix[i][j].electrons.length;
        int explodeLimit = 4;

        // Corner Cells
        if ((i == 0 && j == 0) ||
            (i == 0 && j == (n - 1)) ||
            (i == (m - 1) && j == 0) ||
            (i == (m - 1) && j == (n - 1))) {
          explodeLimit = 2;
        }

        // Side Cells
        if (((i > 0 && i < (m - 1)) && j == 0) ||
            ((i > 0 && i < (m - 1)) && j == (n - 1)) ||
            ((i == 0) && (j > 0 && j < (n - 1))) ||
            ((i == (m - 1)) && (j > 0 && j < (n - 1)))) {
          explodeLimit = 3;
        }

        if (electronsCount == explodeLimit) {
          Future.microtask(() {
            Future.delayed(new Duration(milliseconds: 300), () {
              explode(i, j);
              Future.delayed(new Duration(milliseconds: 500), () {
                checkChainReaction();
              });
            });
          });
          break OUTER;
        }
      }
    }
  }

  void explode(i, j) {
    String _player = _matrix[i][j].player;
    _matrix[i][j].isExplode = true;
    Future.delayed(new Duration(milliseconds: 500), () {
      _matrix[i][j].electrons = [];
      _matrix[i][j].player = '';
      AtomModel topAtom = i > 0 ? _matrix[i - 1][j] : null;
      AtomModel rightAtom = j < 5 ? _matrix[i][j + 1] : null;
      AtomModel bottomAtom = i < 8 ? _matrix[i + 1][j] : null;
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
      _matrix[i][j].isExplode = false;
    });
  }
}

List<List<AtomModel>> buildMatrix() {
  int m = 9; // rows
  int n = 6; // cols
  int rowIndex = 0;
  return new List.generate(m, (_) {
    int colIndex = 0;
    List<AtomModel> cols = new List.generate(n, (_) {
      var model = new AtomModel(
          rowIndex: rowIndex, colIndex: colIndex, electrons: [], player: '');
      colIndex++;
      return model;
    });
    rowIndex++;
    return cols;
  });
}

class AtomModel {
  int rowIndex;
  int colIndex;
  List electrons;
  String player;
  bool isExplode;

  AtomModel(
      {this.rowIndex,
      this.colIndex,
      this.electrons,
      this.player = '',
      this.isExplode = false});

  @override
  String toString() => 'AtomModel{'
      'rowIndex: $rowIndex, '
      'colIndex: $colIndex, '
      'electrons: $electrons, '
      'player: $player, '
      'isExplode: $isExplode'
      '}';
}
