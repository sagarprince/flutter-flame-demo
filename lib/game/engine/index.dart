import 'dart:async';
import 'package:flutter_flame_demo/blocs/bloc.dart';
import 'package:flutter_flame_demo/blocs/events.dart';
import 'package:flutter_flame_demo/blocs/state.dart';
import 'package:flutter_flame_demo/models/player.dart';
import 'package:flutter_flame_demo/models/position.dart';
import 'package:flutter_flame_demo/game/engine/board.dart';

class CREngine {
  static CREngine instance;
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

  bool _isBotEnabled = false;

  factory CREngine([CRBloc bloc, CRState state]) {
    if (instance == null) {
      instance = new CREngine._internal(bloc, state);
    }
    return instance;
  }

  CREngine._internal(this._bloc, this._state) {
    _isBotEnabled = this._state.gameMode == GameMode.PlayWithBot ? true : false;
    this._board = Board(rows, cols, _isBotEnabled);
    this.allPlayers = this._state.players;
    this._players = _buildPlayers();
    _playerTurn = allPlayers[0].color;
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

  void _setBotMove() async {
    if (_isBotPlayer(_playerTurn) && _isBotEnabled) {
      Position botPos = await _board.bot.play(_board.matrix, _playerTurn);
      if (botPos != null) {
        makeMove(botPos, _playerTurn);
      }
    }
  }

  static _reactionsIsolate(pos) {
    print(pos);
    print(CREngine.instance);
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
      _setBotMove();
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

  void destroy() {
    _board.bot.stopIsolate();
  }
}
