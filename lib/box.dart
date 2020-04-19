import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/tapable.dart';

class Box extends PositionComponent with Tapable {
//  static final Paint _boxPaint = Paint()..color = const Color(0xff6ab04c);
  static final Paint _grey = Paint()..color = const Color(0xFFF7F7F7);
  static final Paint _color = Paint()..color = const Color(0xFF888888);

  Rect boxRect;
  Paint _boxPaint;

  bool _beenPressed = false;

  List<dynamic> circles = [];

  Box({
    double y = 100,
  }) {
    x = width = height = 100;
    this.y = y;
    boxRect = Rect.fromLTWH(x, y, width, height);
    _boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xff6ab04c);
  }

  @override
  void render(Canvas c) {
    c.drawRect(boxRect, _beenPressed ? _grey : _boxPaint);
//    print(circles);
    circles.forEach((i) {
      double l = x + 30;
      double t = y + 30;
      if (i == 1) {
        l = x + 50;
        t = y + 30;
      } else if (i == 2) {
        l = x + 30;
        t = y + 50;
      } else if (i == 3) {
        l = x + 50;
        t = y + 50;
      }
      c.drawArc(Rect.fromLTWH(l, t, 20, 20), 0, 360, true, _color);
    });
  }

  @override
  void update(double t) {}

  @override
  void onTapUp(TapUpDetails details) {
    _beenPressed = false;
  }

  @override
  void onTapDown(TapDownDetails details) {
    _beenPressed = true;
    if (circles.length < 4) {
      circles.add(circles.length);
    }
    print(circles);
  }

  @override
  void onTapCancel() {
    _beenPressed = false;
  }
}
