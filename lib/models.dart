class Position {
  int i, j;

  Position(this.i, this.j);

  Position copyWith(int i, int j) {
    return new Position(i ?? this.i, j ?? this.j);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && i == other.i && j == other.j;

  @override
  int get hashCode => i.hashCode ^ j.hashCode;

  @override
  String toString() => 'Position($i, $j)';
}

class CellInfo {
  String player;
  bool isExplode;

  CellInfo({this.player = '', this.isExplode = false});

  CellInfo copyWith({String player, bool isExplode}) {
    return new CellInfo(
        player: player ?? this.player, isExplode: isExplode ?? this.isExplode);
  }

  @override
  String toString() => 'CellInfo{player: $player, isExplode: $isExplode}';
}
