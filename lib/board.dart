import 'dart:math';
import 'package:flutter_flame_demo/models.dart';

class Board {
  int rows = 0;
  int cols = 0;

  Board([rows = 9, cols = 6]) {
    this.rows = rows;
    this.cols = cols;
  }

  List<List<dynamic>> buildMatrix() {
    return new List.generate(
        this.rows, (_) => new List.generate(this.cols, (_) => [0, CellInfo()]));
  }

  int criticalMass(Position pos) {
    int r = rows - 1;
    int c = cols - 1;
    int i = pos.i;
    int j = pos.j;

    // Corner Cells
    if (((i == 0 && j == 0 ||
        i == 0 && j == c ||
        i == r && j == 0 ||
        i == r && j == c))) {
      return 2;
    }

    // Vertical/Horizontal Side Cells
    if (((i > 0 && i < r && (j == 0 || j == c)) ||
        (j > 0 && j < c && (i == 0 || i == r)))) {
      return 3;
    }

    return 4;
  }

  List<dynamic> getNeighbours(Position pos) {
    var sides = [
      [pos.i, pos.j + 1],
      [pos.i, pos.j - 1],
      [pos.i + 1, pos.j],
      [pos.i - 1, pos.j]
    ];
    List<dynamic> neighbours = [];
    sides.forEach((n) {
      if ((n[0] > -1 && n[0] < rows) && (n[1] > -1 && n[1] < cols)) {
        neighbours.add(Position(n[0], n[1]));
      }
    });
    return neighbours;
  }

  move(List<List<dynamic>> matrix, Position pos, String player) {
    List<List<dynamic>> _matrix = deepCopy(matrix);
    _matrix[pos.i][pos.j][0]++;
    CellInfo info = _matrix[pos.i][pos.j][1];
    info.player = player;
    _matrix[pos.i][pos.j][1] = info;
    return _matrix;
  }

  List shuffleUnstableList(items) {
    var random = new Random();
    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }

  stopOnComplexReactions(List<List<dynamic>> matrix) {
    List<List<dynamic>> _matrix = deepCopy(matrix);
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols;
      int j = k % cols;
      if (_matrix[i][j][0] >= criticalMass(Position(i, j))) {
        _matrix[i][j][0] = criticalMass(Position(i, j)) - 1;
      }
    }
    return _matrix;
  }

  List<int> checkScores(List<List<dynamic>> matrix, List<dynamic> players) {
    List<int> playersScores = new List.generate(players.length, (_) => 0);
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols;
      int j = k % cols;
      int orbs = matrix[i][j][0];
      CellInfo info = matrix[i][j][1];
      if (info.player != '' && orbs > 0) {
        int pIndex = players.indexOf(info.player);
        if (pIndex > -1) {
          playersScores[pIndex]++;
        }
      }
    }
    return playersScores;
  }

  List<List<dynamic>> reset(List<List<dynamic>> matrix) {
    List<List<dynamic>> _matrix = deepCopy(matrix);
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols; // determines i
      int j = k % cols; // determines j
      _matrix[i][j][0] = 0;
      _matrix[i][j][1] = CellInfo();
    }
    return _matrix;
  }

  List<List<dynamic>> deepCopy(List<List<dynamic>> matrix) {
    return []..addAll(matrix);
  }

  List<List<dynamic>> deepClone(List<List<dynamic>> matrix) {
    List<List<dynamic>> _matrix = buildMatrix();
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols;
      int j = k % cols;
      CellInfo info = matrix[i][j][1];
      _matrix[i][j][0] = matrix[i][j][0];
      _matrix[i][j][1] = info.copyWith();
    }
    return _matrix;
  }
}
