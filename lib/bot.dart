import 'dart:collection';
import 'dart:async';
import 'dart:isolate';
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

  static computeBotMoveOnIsolate(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    await for (var args in receivePort) {
      Bot bot = args[0];
      List<List<dynamic>> matrix = args[1];
      dynamic player = args[2];
      SendPort callbackPort = args[3];
      List<List<dynamic>> _matrix = bot.deepClone(matrix);
      List<dynamic> calculatedMove = bot.miniMax(_matrix, player);
      callbackPort.send(calculatedMove);
    }
  }

  Future<Position> play(List<List<dynamic>> matrix, dynamic player) async {
    ReceivePort receivePort = ReceivePort();
    await Future.delayed(Duration(milliseconds: 100));
    await Isolate.spawn(computeBotMoveOnIsolate, receivePort.sendPort);
    // Get the listener port for the new isolate
    SendPort sendPort = await receivePort.first;
    dynamic result = await _sendReceive(sendPort, matrix, player);
    return result[0];
  }

  // Create your own listening port and send a message to the new isolate
  Future _sendReceive(
      SendPort sendPort, List<List<dynamic>> matrix, dynamic player) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send([this, matrix, player, receivePort.sendPort]);
    // Receive the return value and return it to the caller
    return receivePort.first;
  }

  List<dynamic> miniMax(List<List<dynamic>> matrix, player,
      [int depth = 3, int breadth = 5]) {
    dynamic bestMoves = bestN(matrix, player, breadth);
    Position bestPos = bestMoves[0];
    int bestScore = score(reactions(matrix, bestPos, player), player);
    return [bestPos, bestScore];
  }

  bestN(List<List<dynamic>> matrix, dynamic player, [int n = 10]) {
    HashMap<Position, int> conf = HashMap();
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols;
      int j = k % cols;
      Position pos = Position(i, j);
      CellInfo info = matrix[pos.i][pos.j][1];
      if (info.player == player || info.player == '') {
        conf[pos] = score(reactions(matrix, pos, player), player);
        // Return just the winning position in case you find one
        if (conf[pos] == 10000) {
          return [pos];
        }
      }
    }

    // Sort by higher score
    Map<Position, int> sorted = Map.fromEntries(
        conf.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    return sorted.keys.toList().take(n).toList();
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
        bool isNotVulnerable = true;
        Position pos = Position(i, j);
        List<dynamic> neighbours = board.getNeighbours(pos);
        neighbours.forEach((nPos) {
          CellInfo nInfo = matrix[nPos.i][nPos.j][1];
          if (nInfo.player != player &&
              matrix[nPos.i][nPos.j][0] == (board.criticalMass(nPos) - 1)) {
            sc -= 5 - board.criticalMass(pos);
            isNotVulnerable = false;
          }
        });
        if (isNotVulnerable) {
          // The Side Vertical/Horizontal Heuristic
          if (board.criticalMass(pos) == 3) {
            sc += 2;
          }
          // The Corner Heuristic
          else if (board.criticalMass(pos) == 2) {
            sc += 3;
          }
          // The Unstability Heuristic
          if (matrix[i][j][0] == (board.criticalMass(pos) - 1)) {
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
    List<List<dynamic>> _matrix = deepClone(matrix);
    _matrix = move(_matrix, pos, player);
    int t1 = new DateTime.now().second;
    while (true) {
      List<dynamic> unstable = [];
      int total = rows * cols;
      for (int k = 0; k < total; k++) {
        int i = k ~/ cols;
        int j = k % cols;
        Position _pos = Position(i, j);
        int orbs = _matrix[i][j][0];
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
        var positionData = _matrix[uPos.i][uPos.j][1];
        _matrix[uPos.i][uPos.j][0] -= board.criticalMass(uPos);
        List<dynamic> neighbours = board.getNeighbours(uPos);
        neighbours.forEach((nPos) {
          _matrix = move(_matrix, nPos, positionData.player);
        });
        int orbs = _matrix[uPos.i][uPos.j][0];
        positionData.player = orbs > 0 ? positionData.player : '';
      });
    }
    return _matrix;
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
