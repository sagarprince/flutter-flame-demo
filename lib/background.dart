import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flutter_flame_demo/chain_reaction_game.dart';

class Background extends PositionComponent with HasGameRef<ChainReactionGame> {
  static final Paint _paint = Paint()..color = const Color(0xff222222);

  Background() {
    x = y = 0;
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
    c.drawRect(toRect(), _paint);
  }

  @override
  void update(double t) {}

  @override
  void resize(Size size) {
    this.width = size.width;
    this.height = size.height;
  }
}
