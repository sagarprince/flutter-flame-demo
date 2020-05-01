import 'package:flutter_flame_demo/blocs/state.dart';
import 'package:flutter_flame_demo/models/player.dart';

/// Generic Game event.
abstract class CREvent {}

/// Called when user want to start a new game.
class StartGameEvent extends CREvent {
  GameMode gameMode;
  List<Player> players;

  StartGameEvent({this.gameMode = GameMode.PlayWithBot, this.players})
      : assert(players != null && players.length != 0);
}

/// Set Winner Event
class SetWinnerEvent extends CREvent {
  Player winner;
  SetWinnerEvent(this.winner);
}
