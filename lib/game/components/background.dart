import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flutter_flame_demo/utils/styles.dart';

class Background extends PositionComponent {
  static final Paint _paint = Paint()..color = AppColors.black;

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
