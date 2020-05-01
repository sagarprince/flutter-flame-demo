import 'package:flutter_flame_demo/blocs/bloc.dart';
import 'package:flutter_flame_demo/blocs/events.dart';
import 'package:flutter_flame_demo/blocs/state.dart';
import 'package:flutter_flame_demo/models/player.dart';
import 'package:flutter_flame_demo/models/position.dart';
import 'package:flutter_flame_demo/models/cell_info.dart';
import 'package:flutter_flame_demo/game/engine/board.dart';

class CREngine {
  static CREngine _instance;
  CRBloc _bloc;
  CRState _state;

  int rows = 9;
  int cols = 6;

  Board _board;
  Board get board => _board;

  List<Player> allPlayers = [];

  List<String> _players = [];

  int _pTurnIndex = 0;

  dynamic _playerTurn = '';
  dynamic get playerTurn => _playerTurn;

  int _totalMoves = 0;

  bool _isChainReaction = false;
  bool get isChainReaction => _isChainReaction;

  String _winner = '';
  String get winner => _winner;

  factory CREngine([CRBloc bloc, CRState state]) {
    if (_instance == null) {
      _instance = new CREngine._internal(bloc, state);
    }
    return _instance;
  }

  CREngine._internal(this._bloc, this._state) {
    this._board = Board(rows, cols);
    this.allPlayers = this._state.players;
    this._players = _buildPlayers();
    _playerTurn = allPlayers[0].color;
//    _testing();
  }

  List<String> _buildPlayers() {
    List<String> players = [];
    _state.players.forEach((p) {
      players.add(p.color);
    });
    return players;
  }

  void _setNextPlayer() {
    if (_pTurnIndex < _players.length - 1) {
      _pTurnIndex++;
    } else {
      _pTurnIndex = 0;
    }
    _playerTurn = _players[_pTurnIndex];
  }

  void makeMove(Position pos, String player) async {
    _board.setMove(pos, player);
    if (_winner == '') {
      _reactions(pos, player);
    }
    _totalMoves++;
  }

  void humanMove(Position pos, String player) {
    if (_isHumanPlayer(player)) {
      makeMove(pos, player);
    }
  }

  void botMove() async {
    if (_isBotPlayer(_playerTurn)) {
      Position botPos = await _board.bot.play(_board.matrix, _playerTurn);
      if (botPos != null) {
        makeMove(botPos, _playerTurn);
      }
    }
  }

  void _reactions(Position pos, String player) async {
    Future.microtask(() async {
      while (_winner == '') {
        _isChainReaction = true;
        List<dynamic> unstable = _board.findUnstableCells();

        // Evaluate winner
        _winner = _evaluateWinner();
        // If Winner then Set It
        if (_winner != '') {
          unstable = [];
          _setWinner();
        }

        // If unstable size gets complex then shuffle unstable list
        if (unstable.length > 0 && unstable.length > _board.complexityLimit) {
          unstable = _board.shuffleUnstableList(unstable);
        }

        // If there are no unstable pos then exit
        if (unstable.length == 0) {
          break;
        }

        // Explode unstable positions
        await _board.explode(unstable);
      }

      _afterReactionsCompleted();
    });
  }

  void _afterReactionsCompleted() {
    _isChainReaction = false;
    _winner = _evaluateWinner();
    if (_winner == '') {
      _setNextPlayer();
      botMove();
    } else {
      _setWinner();
    }
  }

  String _evaluateWinner() {
    String winner = '';
    if (_totalMoves >= _players.length) {
      List<int> playersScores = _board.getScores(_players);
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

      if (_players.length == 1) {
        winner = _players[0];
      }
    }
    return winner;
  }

  void _setWinner() {
    if (_winner != '') {
      _playerTurn = _winner;
      _board.setEquivalentOrbs();
      _bloc.add(SetWinnerEvent(_getPlayer(_winner)));
    }
  }

  bool _isHumanPlayer(String color) {
    int index =
        allPlayers.indexWhere((p) => p.color == color && p.isHuman == true);
    return index > -1;
  }

  bool _isBotPlayer(String color) {
    int index =
        allPlayers.indexWhere((p) => p.color == color && p.isHuman == false);
    return index > -1;
  }

  Player _getPlayer(String color) {
    int index = allPlayers.indexWhere((p) => p.color == color);
    return index > -1 ? allPlayers[index] : null;
  }

  void reset() {
    _board.reset();
    _players = _buildPlayers();
    _pTurnIndex = 0;
    _playerTurn = _players[_pTurnIndex];
    _totalMoves = 0;
    _winner = '';
    _bloc.add(SetWinnerEvent(Player('', '', true)));
  }

  // Testing
  void _testing() {
    int total = rows * cols;
    for (int k = 0; k < total; k++) {
      int i = k ~/ cols; // determines i
      int j = k % cols; // determines j

      _pTurnIndex =
          (_players.length - 1) == _pTurnIndex ? 0 : (_pTurnIndex + 1);
      _playerTurn = _players[_pTurnIndex];
      _totalMoves++;
      _board.matrix[i][j][1] = CellInfo(player: _playerTurn);

      // Corner Cells
      if (((i == 0 && j == 0 ||
          i == 0 && j == (cols - 1) ||
          i == (rows - 1) && j == 0 ||
          i == (rows - 1) && j == (cols - 1)))) {
        _board.matrix[i][j][0] = 1;
      }

      // Vertical/Horizontal Side Cells
      else if (((i > 0 && i < (rows - 1) && (j == 0 || j == (cols - 1))) ||
          (j > 0 && j < (cols - 1) && (i == 0 || i == (rows - 1))))) {
        _board.matrix[i][j][0] = 2;
      }

      // Middle Cells
      else {
        _board.matrix[i][j][0] = 3;
      }
    }
  }
}
