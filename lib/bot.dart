import 'package:flutter_flame_demo/models.dart';
import 'package:flutter_flame_demo/board.dart';

class Bot {
  int rows = 9;
  int cols = 6;
  Board board;

  Bot(Board board) {
    this.board = board;
    this.rows = this.board.rows;
    this.cols = this.board.cols;
  }

  Position play(List<List<dynamic>> matrix, dynamic player) {
    List<List<dynamic>> _matrix = deepClone(matrix);
    Position bestMove = miniMax(_matrix, player)[0];
    print(bestMove);
    return bestMove;
  }

  miniMax(List<List<dynamic>> matrix, player,
      [int depth = 3, int breadth = 5]) {
    Position bestPos;
    int bestScore;
    dynamic bestMoves = bestN(matrix, player, breadth);
    bestPos = (bestMoves[0] as MapEntry).key;
    bestScore = score(reactions(matrix, bestPos, player), player);
    if (depth > 1) {
      bestMoves.forEach((bm) {
        List<List<dynamic>> bMatrix =
            reactions(matrix, (bm as MapEntry).key, player);
        int score = miniMax(bMatrix, player, depth = depth - 1)[1];
        if (score > bestScore) {
          bestScore = score;
          bestPos = (bm as MapEntry).key;
        }
      });
    }
    print(bestMoves);
    return [bestPos, bestScore];
  }

  bestN(List<List<dynamic>> matrix, dynamic player, [int n = 10]) {
    Map<Position, int> conf = Map();
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols;
      int j = k % cols;
      Position pos = Position(i, j);
      CellInfo info = matrix[pos.i][pos.j][1];
      if (info.player == player || info.player == '') {
        conf[pos] = score(
            reactions(matrix, pos, player), player); // conf[Position(2, 3] = 10
        // Return just the winning position in case you find one
        if (conf[pos] == 10000) {
          return [pos];
        }
      }
    }
    // Sort by higher score
    List<dynamic> sortedList = conf.entries.toList()
      ..sort((a, b) => b.value - a.value);
    // Take only n from list
    List<dynamic> confList = [];
    for (int index = 0; index < n; index++) {
      confList.add(sortedList[index]);
    }
    return confList;
  }

  int score(List<List<dynamic>> matrix, dynamic player) {
    int sc = 0;
    int myOrbs = 0, enemyOrbs = 0;
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols;
      int j = k % cols;

      if (matrix[i][j][1].player == player) {
        myOrbs += matrix[i][j][0];
        bool isVulnerable = false;
        Position pos = Position(i, j);
        List<dynamic> neighbours = board.getNeighbours(pos);
        neighbours.forEach((nPos) {
          CellInfo nInfo = matrix[nPos.i][nPos.j][1];
          if (nInfo.player != player) {
            sc -= 5 - board.criticalMass(nPos);
            isVulnerable = true;
          }
        });
        if (!isVulnerable) {
          // The Side Vertical/Horizontal Heuristic
          if (board.criticalMass(pos) == 3) {
            sc += 2;
          }
          // The Corner Heuristic
          if (board.criticalMass(pos) == 2) {
            sc += 3;
          }
          // The Unstability Heuristic
          if ((board.criticalMass(pos) - 1) == 2) {
            sc += 2;
          }
        }
      } else {
        enemyOrbs += matrix[i][j][0];
      }
    }
    // The number of Orbs Heuristic
    sc += myOrbs;
    // You win when the enemy has no orbs
    if (enemyOrbs == 0 && myOrbs > 1)
      return 10000;
    // You loose when you have no orbs
    else if (myOrbs == 0 && enemyOrbs > 1)
      return -10000;
    else {
      // The chain Heuristic
      List<dynamic> chainsList = chains(matrix, player);
      for (int c = 0; c < chainsList.length; c++) {
        if (c > 1) {
          sc += chainsList[c] * 2;
        }
      }
    }
    return sc;
  }

  List<List<dynamic>> reactions(
      List<List<dynamic>> matrix, Position pos, String player) {
    matrix = move(matrix, pos, player);
    int t1 = new DateTime.now().second;
    while (true) {
      List<dynamic> unstable = [];
      int total = rows * cols;
      for (int k = 0; k < total; k++) {
        int i = k ~/ cols;
        int j = k % cols;
        Position _pos = Position(i, j);
        int orbs = matrix[i][j][0];
        if (orbs >= board.criticalMass(_pos)) {
          unstable.add(_pos);
        }
      }
      int t2 = new DateTime.now().second;
      if (t2 - t1 >= 3) {
        // Can't afford to spend more time, strange loop here exit.
        break;
      }

      if (unstable.length == 0) {
        break;
      }

      unstable.forEach((uPos) {
        var positionData = matrix[uPos.i][uPos.j][1];
        matrix[uPos.i][uPos.j][0] -= board.criticalMass(uPos);
        List<dynamic> neighbours = board.getNeighbours(uPos);
        neighbours.forEach((nPos) {
          matrix = board.move(matrix, nPos, positionData.player);
        });
        int orbs = matrix[uPos.i][uPos.j][0];
        positionData.player = orbs > 0 ? positionData.player : '';
      });
    }
    return matrix;
  }

  List<List<dynamic>> move(
      List<List<dynamic>> matrix, Position pos, String player) {
    matrix[pos.i][pos.j][0]++;
    CellInfo info = matrix[pos.i][pos.j][1];
    info.player = player;
    return matrix;
  }

  List<dynamic> chains(List<List<dynamic>> matrix, dynamic player) {
    List<dynamic> lengths = [];
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols;
      int j = k % cols;
      Position pos = Position(i, j);
      int orbs = matrix[i][j][0];
      CellInfo info = matrix[pos.i][pos.j][1];
      if (orbs == (board.criticalMass(pos) - 1) && info.player == player) {
        int l = 0;
        List<dynamic> visitingStack = [];
        visitingStack.add(pos);
        while (visitingStack.length > 0) {
          Position _pos = visitingStack.removeLast();
          matrix[_pos.i][_pos.j][0] = 0;
          l += 1;
          List<dynamic> neighbours = board.getNeighbours(_pos);
          neighbours.forEach((nPos) {
            int nOrbs = matrix[nPos.i][nPos.j][0];
            CellInfo nInfo = matrix[nPos.i][nPos.j][1];
            if (nOrbs == (board.criticalMass(pos) - 1) &&
                nInfo.player == player) {
              visitingStack.add(nPos);
            }
          });
        }
        lengths.add(l);
      }
    }
    return lengths;
  }

  List<List<dynamic>> deepClone(List<List<dynamic>> matrix) {
    List<List<dynamic>> _matrix = board.buildMatrix();
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
