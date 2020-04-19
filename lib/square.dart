import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flutter_flame_demo/provider.dart';

class Square extends PositionComponent with Tapable {
  Provider provider;
  AtomModel atomModel;
  Rect boxRect;
  Paint _boxPaint;
  Paint _tappedPaint;

  bool _beenTapped = false;

  Square(
      {double x = 0,
      double y = 0,
      double width = 60,
      double height = 60,
      Provider provider,
      AtomModel atomModel}) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.provider = provider;
    this.atomModel = atomModel;

    boxRect = Rect.fromLTWH(this.x, this.y, this.width, this.height);
    _boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xff6ab04c);
    _tappedPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..color = const Color(0xff777777);
  }

  @override
  void render(Canvas c) {
    c.drawRect(boxRect, _beenTapped ? _tappedPaint : _boxPaint);
  }

  @override
  void update(double t) {}

  @override
  void onTapUp(TapUpDetails details) {
    _beenTapped = false;
  }

  @override
  void onTapDown(TapDownDetails details) {
    if (atomModel.electrons.length < 4) {
      _beenTapped = true;
      this.provider.playMove(atomModel.rowIndex, atomModel.colIndex);
    }
  }

  @override
  void onTapCancel() {
    _beenTapped = false;
  }
}
