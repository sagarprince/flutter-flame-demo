import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flutter_flame_demo/models.dart';
import 'package:flutter_flame_demo/game_service.dart';

class Cell extends PositionComponent with Tapable {
  GameService service;
  CellModel cellModel;
  Rect boxRect;
  Paint _boxPaint;
  Paint _tappedPaint;
  bool _beenTapped = false;

  Cell(
      {double x = 0,
      double y = 0,
      double width = 60,
      double height = 60,
      CellModel cellModel}) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.service = gameService;
    this.cellModel = cellModel;

    boxRect = Rect.fromLTWH(this.x, this.y, this.width, this.height);
    _tappedPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..color = const Color(0xff777777);
  }

  @override
  void render(Canvas c) {
    Color playerColor = service.getPlayerColor(service.playerTurn);
    _boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = playerColor;
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
    if (cellModel.orbs.length < 4 &&
        (cellModel.player == service.playerTurn || cellModel.player == '') &&
        !service.isChainReaction) {
      _beenTapped = true;
      this.service.playMove(cellModel.i, cellModel.j);
    }
  }

  @override
  void onTapCancel() {
    _beenTapped = false;
  }
}
