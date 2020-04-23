class CellModel {
  int i;
  int j;
  List orbs;
  String player;
  bool isExplode;

  CellModel(
      {this.i, this.j, this.orbs, this.player = '', this.isExplode = false});

  @override
  String toString() => 'CellModel{'
      'i: $i, '
      'j: $j, '
      'orbs: $orbs, '
      'player: $player, '
      'isExplode: $isExplode'
      '}';
}
